/*
 * DSVG device - Raster handling
 */
#include "dsvg.h"

extern "C" {
#include <png.h>
}
#include <cstdint>
#include <cmath>
#include <cstdlib>
#include <vector>

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

/*
 * Enlargement factor of a raster of `pixels` pixels drawn on `size` points.
 * Without interpolation, a raster smaller than its size is enlarged by
 * repeating its pixels, so that it stays sharp in viewers that ignore the
 * attribute image-rendering: about one pixel per point.
 */
static int enlargement(int pixels, double size, bool interpolate) {
  if (interpolate || pixels <= 0 || size <= pixels) return 1;
  return (int) std::ceil(size / pixels);
}

/*
 * RGBA bytes of a raster of R colours (h rows of w pixels, top row first),
 * each pixel repeated fx times horizontally and fy times vertically.
 * The components are read with the macros of R, whatever the byte order
 * of the machine.
 */
static std::vector<std::uint8_t> raster_rgba(const unsigned int *raster,
                                             int w, int h, int fx, int fy) {
  const size_t out_w = (size_t) w * fx;
  const size_t out_h = (size_t) h * fy;
  std::vector<std::uint8_t> bytes(out_w * out_h * 4);
  std::uint8_t* p = bytes.data();
  for (size_t y = 0; y < out_h; ++y) {
    const unsigned int* row = raster + (y / fy) * w;
    for (size_t x = 0; x < out_w; ++x) {
      const unsigned int col = row[x / fx];
      *p++ = R_RED(col);
      *p++ = R_GREEN(col);
      *p++ = R_BLUE(col);
      *p++ = R_ALPHA(col);
    }
  }
  return bytes;
}

/*
 * PNG file (in memory) of RGBA bytes, h rows of w pixels.
 * Returns an empty vector if libpng fails.
 */
static std::vector<std::uint8_t> png_encode(const std::vector<std::uint8_t>& rgba,
                                            int w, int h) {
  std::vector<std::uint8_t> out;
  png_structp png = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if (!png) return out;
  png_infop info = png_create_info_struct(png);
  if (!info) {
    png_destroy_write_struct(&png, NULL);
    return out;
  }
  // libpng jumps back here on error
  if (setjmp(png_jmpbuf(png))) {
    png_destroy_write_struct(&png, &info);
    out.clear();
    return out;
  }
  png_set_write_fn(png, &out, png_memory_write, NULL);
  png_set_IHDR(png, info, w, h, 8, PNG_COLOR_TYPE_RGBA, PNG_INTERLACE_NONE,
               PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
  png_write_info(png, info);
  const size_t row_size = (size_t) w * 4;
  for (int y = 0; y < h; ++y) {
    png_write_row(png, (png_const_bytep) (rgba.data() + y * row_size));
  }
  png_write_end(png, NULL);
  png_destroy_write_struct(&png, &info);
  return out;
}

/*
 * A raster as a PNG file encoded in base64, for the attribute href of an
 * <image>. `width` and `height` are the size of the image in points.
 */
std::string raster_to_string(unsigned int *raster, int w, int h, double width, double height, bool interpolate) {
  w = std::abs(w);
  h = std::abs(h);
  const int fx = enlargement(w, width, interpolate);
  const int fy = enlargement(h, height, interpolate);
  const std::vector<std::uint8_t> png = png_encode(
    raster_rgba(raster, w, h, fx, fy), w * fx, h * fy
  );
  if (png.empty()) return "";
  return base64_encode(png.data(), png.size());
}

void dsvg_raster(unsigned int *raster, int w, int h, double x, double y,
                 double width, double height, double rot, Rboolean interpolate,
                 const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  // rasters are not part of a stroked/filled path
  if (svgd->appending_path) return;
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
