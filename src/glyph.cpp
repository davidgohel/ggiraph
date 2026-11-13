/*
 * DSVG device - Glyphs
 */
#include "dsvg.h"
#include <systemfonts.h>
#include <cmath>

#if R_GE_version >= 16

/*
 * Draws a run of glyphs.
 *
 * Glyph coordinates are in points with the y axis going up, device
 * coordinates have the y axis going down. With a rotation of 'rot' degrees
 * (counterclockwise), the point (u, v) of a glyph whose origin is (x0, y0)
 * is drawn at:
 *   X = x0 + u * cos - v * sin
 *   Y = y0 - u * sin - v * cos
 *
 * Glyphs with an outline are written in a single <path> (one element for
 * the interactive attributes). Glyphs without outline (bitmap emojis) are
 * written as images.
 *
 * The outlines are read at OUTLINE_SIZE points and scaled down by the
 * transformation: at small sizes, FreeType applies the hinting of the font
 * and the outlines are distorted to fit a grid of a few pixels, which shows
 * once the SVG is zoomed.
 */
static const double OUTLINE_SIZE = 1000.0;

void dsvg_glyph(int n, int *glyphs, double *x, double *y,
                SEXP font, double size,
                int colour, double rot, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  const char* font_file = R_GE_glyphFontFile(font);
  const int font_index = R_GE_glyphFontIndex(font);

  const double angle = rot * M_PI / 180.0;
  const double cos_a = std::cos(angle);
  const double sin_a = std::sin(angle);

  std::string d;
  for (int i = 0; i < n; ++i) {
    // affine transformation expected by systemfonts:
    // X = t[0] * u + t[2] * v + t[4], Y = t[1] * u + t[3] * v + t[5]
    // with (u, v) in points of the outline read at OUTLINE_SIZE
    const double k = size / OUTLINE_SIZE;
    double t[6] = {k * cos_a, -k * sin_a, -k * sin_a, -k * cos_a, x[i], y[i]};

    bool no_outline = false;
    std::string outline = get_glyph_path(glyphs[i], t, font_file, font_index,
                                         OUTLINE_SIZE, &no_outline);
    if (!no_outline) {
      d.append(outline);
      continue;
    }

    // bitmap glyph: not part of a path or of a clipping path
    if (svgd->appending_path || !svgd->should_paint()) continue;

    SEXP raster = PROTECT(get_glyph_raster(glyphs[i], font_file, font_index,
                                           size, 300.0, colour));
    if (Rf_isNull(raster)) {
      UNPROTECT(1);
      continue;
    }
    // 'size' is (height, width) and 'offset' is (top, left), in points,
    // relative to the origin of the glyph
    SEXP r_size = PROTECT(Rf_getAttrib(raster, Rf_install("size")));
    SEXP r_offset = PROTECT(Rf_getAttrib(raster, Rf_install("offset")));
    const double height = REAL(r_size)[0];
    const double width = REAL(r_size)[1];
    const double left = REAL(r_offset)[1];
    const double bottom = REAL(r_offset)[0] - height;
    // dsvg_raster() places the bottom left corner of the image at (x, y)
    // and rotates the image around it
    dsvg_raster((unsigned int*) INTEGER(raster),
                Rf_ncols(raster), Rf_nrows(raster),
                x[i] + left * cos_a - bottom * sin_a,
                y[i] - left * sin_a - bottom * cos_a,
                width, height, rot, (Rboolean) TRUE, NULL, dd);
    UNPROTECT(3);
  }

  if (d.empty()) return;

  if (svgd->appending_path) {
    svgd->path_data.append(d).append(" ");
    return;
  }

  SVGElement* path = svgd->svg_element("path");
  set_attr(path, "d", d);
  if (svgd->should_paint()) {
    set_fill(path, colour);
    set_attr(path, "stroke", "none");
  }
}

#endif // R_GE_version >= 16
