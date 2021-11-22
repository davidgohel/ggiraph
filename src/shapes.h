/*
 * DSVG device - Base SVG shapes handling
 */
#ifndef DSVG_SHAPES_INCLUDED
#define DSVG_SHAPES_INCLUDED

void dsvg_line(double x1, double y1, double x2, double y2,
               const pGEcontext gc, pDevDesc dd);

void dsvg_polyline(int n, double *x, double *y,
                   const pGEcontext gc, pDevDesc dd);

void dsvg_polygon(int n, double *x, double *y,
                  const pGEcontext gc, pDevDesc dd);

void dsvg_path(double *x, double *y, int npoly, int *nper, Rboolean winding,
               const pGEcontext gc, pDevDesc dd);

void dsvg_rect(double x0, double y0, double x1, double y1,
               const pGEcontext gc, pDevDesc dd);

void dsvg_circle(double x, double y, double r,
                 const pGEcontext gc, pDevDesc dd);

#endif // DSVG_SHAPES_INCLUDED
