/*
 * DSVG device - Base SVG shapes handling
 */
#include "dsvg.h"

void dsvg_line(double x1, double y1, double x2, double y2,
               const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  svgd->new_element();
  const char *clipid = svgd->clip_id.c_str();
  const char *eltid = svgd->element_id.c_str();

  SVGElement* line = svgd->svg_element("line", true);
  set_attr(line, "x1", x1);
  set_attr(line, "y1", y1);
  set_attr(line, "x2", x2);
  set_attr(line, "y2", y2);
  set_attr(line, "id", eltid);
  set_clip(line, clipid);
  set_stroke(line, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  set_fill(line, gc->fill);
}

void dsvg_polyline(int n, double *x, double *y,
                   const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  svgd->new_element();
  const char *clipid = svgd->clip_id.c_str();
  const char *eltid = svgd->element_id.c_str();

  SVGElement* polyline = svgd->svg_element("polyline", true);

  std::stringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os.precision(2);
  os << x[0] << "," << y[0];
  for (int i = 1; i < n; i++) {
    os << " " << x[i] << "," << y[i];
  }
  set_attr(polyline, "points", os.str());
  set_attr(polyline, "id", eltid);
  set_clip(polyline, clipid);
  set_attr(polyline, "fill", "none");
  set_stroke(polyline, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
}

void dsvg_polygon(int n, double *x, double *y,
                  const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  svgd->new_element();
  const char *clipid = svgd->clip_id.c_str();
  const char *eltid = svgd->element_id.c_str();

  SVGElement* polygon = svgd->svg_element("polygon", true);

  std::stringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os.precision(2);
  os << x[0] << "," << y[0];
  for (int i = 1; i < n; i++) {
    os << " " << x[i] << "," << y[i];
  }
  set_attr(polygon, "points", os.str());
  set_attr(polygon, "id", eltid);
  set_clip(polygon, clipid);
  set_fill(polygon, gc->fill);
  set_stroke(polygon, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
}

void dsvg_path(double *x, double *y, int npoly, int *nper, Rboolean winding,
               const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  svgd->new_element();
  const char *clipid = svgd->clip_id.c_str();
  const char *eltid = svgd->element_id.c_str();
  int index = 0;

  SVGElement* path = svgd->svg_element("path", true);

  std::stringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  for (int i = 0; i < npoly; i++) {
    os << "M " << x[index] << " " << y[index] << " ";
    index++;
    for (int j = 1; j < nper[i]; j++) {
      os << "L " << x[index] << " " << y[index] << " ";
      index++;
    }
    os << "Z ";
  }
  set_attr(path, "d", os.str());
  set_attr(path, "id", eltid);
  set_clip(path, clipid);
  set_fill(path, gc->fill);

  if (winding)
    set_attr(path, "fill-rule", "nonzero");
  else
    set_attr(path, "fill-rule", "evenodd");

  set_stroke(path, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
}

void dsvg_rect(double x0, double y0, double x1, double y1,
               const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  svgd->new_element();
  const char *eltid = svgd->element_id.c_str();
  const char *clipid = svgd->clip_id.c_str();

  SVGElement* rect = svgd->svg_element("rect", true);
  set_attr(rect, "x", fmin(x0, x1));
  set_attr(rect, "y", fmin(y0, y1));
  set_attr(rect, "width", fabs(x1 - x0));
  set_attr(rect, "height", fabs(y1 - y0));
  set_attr(rect, "id", eltid);
  set_clip(rect, clipid);
  set_fill(rect, gc->fill);
  set_stroke(rect, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
}

void dsvg_circle(double x, double y, double r,
                 const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  svgd->new_element();
  const char *eltid = svgd->element_id.c_str();
  const char *clipid = svgd->clip_id.c_str();

  SVGElement* circle = svgd->svg_element("circle", true);
  set_attr(circle, "cx", x);
  set_attr(circle, "cy", y);
  set_attr(circle, "r", to_string(r * .75) + "pt");
  set_attr(circle, "id", eltid);
  set_clip(circle, clipid);
  set_fill(circle, gc->fill);
  set_stroke(circle, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
}
