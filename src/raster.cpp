/*
 * DSVG device - Raster handling
 */
#include "dsvg.h"

extern "C" {
#include <png.h>
}
#include <cstdint>

static const char encode_lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const char pad_character = '=';

std::string base64_encode(const std::uint8_t* buffer, size_t size) {
  std::string encoded_string;
  encoded_string.reserve(((size/3) + (size % 3 > 0)) * 4);
  std::uint32_t temp{};
  int index = 0;
  for (size_t idx = 0; idx < size/3; idx++) {
    temp  = buffer[index++] << 16; //Convert to big endian
    temp += buffer[index++] << 8;
    temp += buffer[index++];
    encoded_string.append(1, encode_lookup[(temp & 0x00FC0000) >> 18]);
    encoded_string.append(1, encode_lookup[(temp & 0x0003F000) >> 12]);
    encoded_string.append(1, encode_lookup[(temp & 0x00000FC0) >> 6 ]);
    encoded_string.append(1, encode_lookup[(temp & 0x0000003F)      ]);
  }
  switch (size % 3) {
  case 1:
    temp  = buffer[index++] << 16; //Convert to big endian
    encoded_string.append(1, encode_lookup[(temp & 0x00FC0000) >> 18]);
    encoded_string.append(1, encode_lookup[(temp & 0x0003F000) >> 12]);
    encoded_string.append(2, pad_character);
    break;
  case 2:
    temp  = buffer[index++] << 16; //Convert to big endian
    temp += buffer[index++] << 8;
    encoded_string.append(1, encode_lookup[(temp & 0x00FC0000) >> 18]);
    encoded_string.append(1, encode_lookup[(temp & 0x0003F000) >> 12]);
    encoded_string.append(1, encode_lookup[(temp & 0x00000FC0) >> 6 ]);
    encoded_string.append(1, pad_character);
    break;
  }
  return encoded_string;
}

static void png_memory_write(png_structp  png_ptr, png_bytep data, png_size_t length) {
  std::vector<uint8_t> *p = (std::vector<uint8_t>*)png_get_io_ptr(png_ptr);
  p->insert(p->end(), data, data + length);
}

// This code has been copied from the package svglite maintained by Thomas Lin Pedersen
std::string raster_to_string(unsigned int *raster, int w, int h, double width, double height, bool interpolate) {
  h = h < 0 ? -h : h;
  w = w < 0 ? -w : w;
  bool resize = false;
  int w_fac = 1, h_fac = 1;
  std::vector<unsigned int> raster_resize;

  if (!interpolate && double(w) < width) {
    resize = true;
    w_fac = std::ceil(width / w);
  }
  if (!interpolate && double(h) < height) {
    resize = true;
    h_fac = std::ceil(height / h);
  }

  if (resize) {
    int w_new = w * w_fac;
    int h_new = h * h_fac;
    raster_resize.reserve(w_new * h_new);
    for (int i = 0; i < h; ++i) {
      for (int j = 0; j < w; ++j) {
        unsigned int val = raster[i * w + j];
        for (int wrep = 0; wrep < w_fac; ++wrep) {
          raster_resize.push_back(val);
        }
      }
      for (int hrep = 1; hrep < h_fac; ++hrep) {
        raster_resize.insert(raster_resize.end(), raster_resize.end() - w_new, raster_resize.end());
      }
    }
    raster = raster_resize.data();
    w = w_new;
    h = h_new;
  }

  png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (!png) {
    return "";
  }
  png_infop info = png_create_info_struct(png);
  if (!info) {
    png_destroy_write_struct(&png, (png_infopp)NULL);
    return "";
  }
  if (setjmp(png_jmpbuf(png))) {
    png_destroy_write_struct(&png, &info);
    return "";
  }
  png_set_IHDR(
    png,
    info,
    w, h,
    8,
    PNG_COLOR_TYPE_RGBA,
    PNG_INTERLACE_NONE,
    PNG_COMPRESSION_TYPE_DEFAULT,
    PNG_FILTER_TYPE_DEFAULT
  );
  std::vector<uint8_t*> rows(h);
  for (int y = 0; y < h; ++y) {
    rows[y] = (uint8_t*)raster + y * w * 4;
  }

  std::vector<std::uint8_t> buffer;
  png_set_rows(png, info, &rows[0]);
  png_set_write_fn(png, &buffer, png_memory_write, NULL);
  png_write_png(png, info, PNG_TRANSFORM_IDENTITY, NULL);
  png_destroy_write_struct(&png, &info);

  return base64_encode(buffer.data(), buffer.size());
}

void dsvg_raster(unsigned int *raster, int w, int h, double x, double y,
                 double width, double height, double rot, Rboolean interpolate,
                 const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  SVGElement* image = svgd->svg_element("image");

  if (height < 0)
    height = -height;

  std::string base64_str = raster_to_string(raster, w, h, width, height, interpolate);

  set_attr(image, "x", x);
  set_attr(image, "y", y - height);
  set_attr(image, "width", width);
  set_attr(image, "height", height);
  set_attr(image, "preserveAspectRatio", "none");
  if (!interpolate) {
    set_attr(image, "image-rendering", "pixelated");
  }

  if (fabs(rot) > 0.001) {
    std::ostringstream ost;
    ost.flags(std::ios_base::fixed | std::ios_base::dec);
    ost.precision(2);
    ost << "rotate(" << -1.0 * rot << "," << x << "," << y << ")";
    set_attr(image, "transform", ost.str());
  }

  std::ostringstream os;
  os << "data:image/png;base64," << base64_str;
  set_attr(image, "xlink:href", os.str());

  if (svgd->standalone)
    set_attr(image, "xmlns:xlink", "http://www.w3.org/1999/xlink");
}
