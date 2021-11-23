/*
 * This file is part of ggiraph.
 * Copyright (c) 2021, David Gohel All rights reserved.
 **/

/*
 * DSVG device
 */
#include "dsvg.h"
#include "a_color.h"
#include <locale>

void dsvg_close(pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  delete(svgd);
}

void dsvg_size(double *left, double *right, double *bottom, double *top,
               pDevDesc dd) {
  *left = dd->left;
  *right = dd->right;
  *bottom = dd->bottom;
  *top = dd->top;
}

void dsvg_new_page(const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  if (svgd->is_init())
    Rf_error("svgd only supports one page");

  SVGElement* root = svgd->svg_root();
  set_attr(root, "id", svgd->canvas_id);
  set_attr(root, "viewBox", to_string(0) + " " + to_string(0) + " " +
    to_string(dd->right) + " " + to_string(dd->bottom));
  if (svgd->setdims) {
    set_attr(root, "width", dd->right);
    set_attr(root, "height", dd->bottom);
  }

  int bg_fill, fill, col;
  a_color bg_temp(gc->fill);
  if (bg_temp.is_visible())
    bg_fill = gc->fill;
  else bg_fill = dd->startfill;

  a_color bg_color(bg_fill);
  if (!bg_color.is_transparent()) {
    fill = gc->fill;
    col = gc->col;
    gc->fill = bg_fill;
    gc->col = bg_fill;
    dsvg_clip(0, dd->right, 0, dd->bottom, dd);
    dsvg_rect(0, 0, dd->right, dd->bottom, gc, dd);
    gc->fill = fill;
    gc->col = col;
  }
}

pDevDesc dsvg_driver_new(std::string filename,
                         double width, double height,
                         std::string canvas_id,
                         bool standalone, bool setdims,
                         int pointsize, rcolor bg,
                         Rcpp::List aliases) {

  pDevDesc dd = (DevDesc*) calloc(1, sizeof(DevDesc));
  if (!dd) return dd;

  dd->startfill = bg;
  dd->startcol = R_RGB(0, 0, 0);
  dd->startps = pointsize;
  dd->startlty = 0;
  dd->startfont = 1;
  dd->startgamma = 1;

  // Callbacks
  dd->activate = NULL;
  dd->deactivate = NULL;
  dd->close = dsvg_close;
  dd->clip = dsvg_clip;
  dd->size = dsvg_size;
  dd->newPage = dsvg_new_page;
  dd->line = dsvg_line;
  dd->text = dsvg_text;
  dd->strWidth = dsvg_strwidth;
  dd->rect = dsvg_rect;
  dd->circle = dsvg_circle;
  dd->polygon = dsvg_polygon;
  dd->polyline = dsvg_polyline;
  dd->path = dsvg_path;
  dd->mode = NULL;
  dd->metricInfo = dsvg_metric_info;
  dd->cap = NULL;
  dd->raster = dsvg_raster;
#if R_GE_version >= 13
  dd->setClipPath     = dsvg_set_clip_path;
  dd->releaseClipPath = dsvg_release_clip_path;
  dd->setMask         = dsvg_set_mask;
  dd->releaseMask     = dsvg_release_mask;
  dd->setPattern      = dsvg_set_pattern;
  dd->releasePattern  = dsvg_release_pattern;
#endif
  // UTF-8 support
  dd->wantSymbolUTF8 = (Rboolean) 1;
  dd->hasTextUTF8 = (Rboolean) 1;
  dd->textUTF8 = dsvg_text_utf8;
  dd->strWidthUTF8 = dsvg_strwidth_utf8;

  // Screen Dimensions in pts
  dd->left = 0;
  dd->top = 0;
  dd->right = width * 72;
  dd->bottom = height * 72;

  // Magic constants copied from other graphics devices
  // nominal character sizes in pts
  dd->cra[0] = 0.9 * pointsize;
  dd->cra[1] = 1.2 * pointsize;
  // character alignment offsets
  dd->xCharOffset = 0.4900;
  dd->yCharOffset = 0.3333;
  dd->yLineBias = 0.2;
  // inches per pt
  dd->ipr[0] = 1.0 / 72.0;
  dd->ipr[1] = 1.0 / 72.0;

  // Capabilities
  dd->canClip = TRUE;
  dd->canHAdj = 0;
  dd->canChangeGamma = FALSE;
  dd->displayListOn = FALSE;
  dd->haveTransparency = 2;
  dd->haveTransparentBg = 2;

#if R_GE_version >= 13
  dd->deviceVersion = R_GE_definitions;
#endif

  dd->deviceSpecific = new DSVG_dev(filename,
                                    width * 72, height * 72,
                                    canvas_id,
                                    standalone, setdims,
                                    aliases);
  return dd;
}

// [[Rcpp::export]]
bool DSVG_(std::string filename,
           double width, double height,
           std::string canvas_id,
           bool standalone, bool setdims,
           int pointsize, std::string bg,
           Rcpp::List aliases) {

  R_GE_checkVersionOrDie(R_GE_version);
  R_CheckDeviceAvailable();
  BEGIN_SUSPEND_INTERRUPTS {
    setlocale(LC_NUMERIC, "C");

    rcolor bg_ = R_GE_str2col(bg.c_str());

    pDevDesc dd = dsvg_driver_new(filename,
                                  width, height,
                                  canvas_id,
                                  standalone, setdims,
                                  pointsize, bg_,
                                  aliases);
    if (!dd) Rf_error("Failed to start DSVG device");

    pGEDevDesc dev = GEcreateDevDesc(dd);
    GEaddDevice2(dev, "dsvg_device");
    GEinitDisplayList(dev);

  } END_SUSPEND_INTERRUPTS;

  return true;
}
