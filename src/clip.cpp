/*
 * DSVG device - ClipPath elements
 */
#include "dsvg.h"

void dsvg_clip(double x0, double x1, double y0, double y1, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  if (std::abs(x0 - svgd->clipleft) < 0.01 && std::abs(x1 - svgd->clipright) < 0.01 &&
      std::abs(y0 - svgd->clipbottom) < 0.01 && std::abs(y1 - svgd->cliptop) < 0.01)
    return;

  svgd->clipleft = x0;
  svgd->clipright = x1;
  svgd->clipbottom = y0;
  svgd->cliptop = y1;

  svgd->new_clip();

  const char *clipid = svgd->clip_id.c_str();
  SVGElement* defs = svgd->svg_element("defs", false);
  SVGElement* clipPath = svgd->svg_element("clipPath", false, defs);
  set_attr(clipPath, "id", clipid);
  SVGElement* rect = svgd->svg_element("rect", false, clipPath);
  set_attr(rect, "x", std::min(x0, x1));
  set_attr(rect, "y", std::min(y0, y1));
  set_attr(rect, "width", std::abs(x1 - x0));
  set_attr(rect, "height", std::abs(y1 - y0));
}

#if R_GE_version >= 13

SEXP dsvg_set_clip_path(SEXP path, SEXP ref, pDevDesc dd) {
  return R_NilValue;
}

void dsvg_release_clip_path(SEXP ref, pDevDesc dd) {
}

#endif // R_GE_version >= 13
