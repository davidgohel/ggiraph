/*
 * DSVG device - Base SVG shapes handling
 */
#include "dsvg.h"

void dsvg_line(double x1, double y1, double x2, double y2,
               const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  SVGElement* line = svgd->svg_element("line");
  set_attr(line, "x1", x1);
  set_attr(line, "y1", y1);
  set_attr(line, "x2", x2);
  set_attr(line, "y2", y2);

  if (svgd->should_paint()) {
    set_stroke(line, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  }
}

void dsvg_polyline(int n, double *x, double *y,
                   const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  SVGElement* polyline = svgd->svg_element("polyline");

  std::ostringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os.precision(2);
  os << x[0] << "," << y[0];
  for (int i = 1; i < n; i++) {
    os << " " << x[i] << "," << y[i];
  }
  set_attr(polyline, "points", os.str());

  if (svgd->should_paint()) {
    set_attr(polyline, "fill", "none");
    set_stroke(polyline, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  }
}

void dsvg_polygon(int n, double *x, double *y,
                  const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  SVGElement* polygon = svgd->svg_element("polygon");

  std::ostringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os.precision(2);
  os << x[0] << "," << y[0];
  for (int i = 1; i < n; i++) {
    os << " " << x[i] << "," << y[i];
  }
  set_attr(polygon, "points", os.str());

  if (svgd->should_paint()) {
    set_fill(polygon, gc->fill);
    set_stroke(polygon, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  }
}

void dsvg_path(double *x, double *y, int npoly, int *nper, Rboolean winding,
               const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  SVGElement* path = svgd->svg_element("path");

  int index = 0;
  std::ostringstream os;
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

  if (svgd->should_paint()) {
    set_fill(path, gc->fill);
    if (winding)
      set_attr(path, "fill-rule", "nonzero");
    else
      set_attr(path, "fill-rule", "evenodd");

    set_stroke(path, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  }
}

void dsvg_rect(double x0, double y0, double x1, double y1,
               const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  SVGElement* rect = svgd->svg_element("rect");

  set_attr(rect, "x", fmin(x0, x1));
  set_attr(rect, "y", fmin(y0, y1));
  set_attr(rect, "width", fabs(x1 - x0));
  set_attr(rect, "height", fabs(y1 - y0));

  if (svgd->should_paint()) {
    set_fill(rect, gc->fill);
    set_stroke(rect, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  }
}

void dsvg_circle(double x, double y, double r,
                 const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  SVGElement* circle = svgd->svg_element("circle");

  set_attr(circle, "cx", x);
  set_attr(circle, "cy", y);
  set_attr(circle, "r", to_string(r * .75) + "pt");

  if (svgd->should_paint()) {
    set_fill(circle, gc->fill);
    set_stroke(circle, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  }
}
