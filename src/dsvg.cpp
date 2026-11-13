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
  else
    bg_fill = dd->startfill;

  a_color bg_color(bg_fill);
  if (bg_color.is_visible()) {
    fill = gc->fill;
    col = gc->col;
    gc->fill = bg_fill;
    gc->col = bg_fill;
    dsvg_clip(0, dd->right, 0, dd->bottom, dd);
    dsvg_rect(0, 0, dd->right, dd->bottom, gc, dd);
    gc->fill = fill;
    gc->col = col;

    // get the root g
    SVGElement* child = root->LastChildElement();
    if (child) {
      // get the container g
      child = child->FirstChildElement();
      if (child) {
        // get the background rect we just created
        child = child->FirstChildElement();
        if (child) {
          // set class
          set_attr(child, "class", "ggiraph-svg-bg");
        }
      }
    }
  }
}

#if R_GE_version >= 15
SEXP dsvg_define_group(SEXP source, int op, SEXP destination, pDevDesc dd) {
  // grid warns that the group definition failed
  return R_NilValue;
}

void dsvg_use_group(SEXP ref, SEXP trans, pDevDesc dd) {
}

void dsvg_release_group(SEXP ref, pDevDesc dd) {
}

void dsvg_stroke(SEXP path, const pGEcontext gc, pDevDesc dd) {
  Rf_warning("Stroking a path is not supported by dsvg, the path is ignored.");
}

void dsvg_fill(SEXP path, int rule, const pGEcontext gc, pDevDesc dd) {
  Rf_warning("Filling a path is not supported by dsvg, the path is ignored.");
}

void dsvg_fill_stroke(SEXP path, int rule, const pGEcontext gc, pDevDesc dd) {
  Rf_warning("Filling and stroking a path is not supported by dsvg, the path is ignored.");
}

SEXP dsvg_capabilities(SEXP capabilities) {
  SEXP pat = PROTECT(Rf_allocVector(INTSXP, 3));
  INTEGER(pat)[0] = R_GE_linearGradientPattern;
  INTEGER(pat)[1] = R_GE_radialGradientPattern;
  INTEGER(pat)[2] = R_GE_tilingPattern;
  SET_VECTOR_ELT(capabilities, R_GE_capability_patterns, pat);
  UNPROTECT(1);

  SET_VECTOR_ELT(capabilities, R_GE_capability_clippingPaths,
                 Rf_ScalarInteger(1));

  // luminance masks are drawn as alpha masks
  SET_VECTOR_ELT(capabilities, R_GE_capability_masks,
                 Rf_ScalarInteger(R_GE_alphaMask));

  SET_VECTOR_ELT(capabilities, R_GE_capability_compositing,
                 Rf_ScalarInteger(0));
  SET_VECTOR_ELT(capabilities, R_GE_capability_transformations,
                 Rf_ScalarInteger(0));
  SET_VECTOR_ELT(capabilities, R_GE_capability_paths,
                 Rf_ScalarInteger(0));
  return capabilities;
}
#endif // R_GE_version >= 15

pDevDesc dsvg_driver_new(std::string filename,
                         double width, double height,
                         std::string canvas_id,
                         std::string title, std::string desc,
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
  // new GE features: non-rect clipPaths, masks, gradients and patterns
  dd->setClipPath     = dsvg_set_clip_path;
  dd->releaseClipPath = dsvg_release_clip_path;
  dd->setMask         = dsvg_set_mask;
  dd->releaseMask     = dsvg_release_mask;
  dd->setPattern      = dsvg_set_pattern;
  dd->releasePattern  = dsvg_release_pattern;

  // version 13 fully supported
  dd->deviceVersion = R_GE_definitions;
#endif

#if R_GE_version >= 14
  // With this flag, all clipping is delegated to device.
  // No need to do anything special.
  dd->deviceClip = TRUE;

  // version 14 fully supported
  dd->deviceVersion = R_GE_deviceClip;
#endif

#if R_GE_version >= 15
  // The engine calls these callbacks without checking for NULL once
  // deviceVersion is 15: groups and path stroking/filling are not
  // supported yet, the callbacks only warn.
  dd->defineGroup  = dsvg_define_group;
  dd->useGroup     = dsvg_use_group;
  dd->releaseGroup = dsvg_release_group;
  dd->stroke       = dsvg_stroke;
  dd->fill         = dsvg_fill;
  dd->fillStroke   = dsvg_fill_stroke;
  dd->capabilities = dsvg_capabilities;

  dd->deviceVersion = R_GE_group;
#endif

  dd->deviceSpecific = new DSVG_dev(filename,
                                    width * 72, height * 72,
                                    canvas_id,
                                    title, desc,
                                    standalone, setdims,
                                    aliases);
  return dd;
}

// [[Rcpp::export]]
bool DSVG_(std::string filename,
           double width, double height,
           std::string canvas_id,
           std::string title, std::string desc,
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
                                  title, desc,
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

// [[Rcpp::export]]
Rcpp::IntegerVector get_ge_version() {
  Rcpp::IntegerVector res{ R_GE_version };
  return res;
}
