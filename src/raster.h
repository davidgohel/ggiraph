/*
 * DSVG device - Raster handling
 */
#ifndef DSVG_RASTER_INCLUDED
#define DSVG_RASTER_INCLUDED

void dsvg_raster(unsigned int *raster, int w, int h, double x, double y,
                 double width, double height, double rot, Rboolean interpolate,
                 const pGEcontext gc, pDevDesc dd);

#endif // DSVG_RASTER_INCLUDED
