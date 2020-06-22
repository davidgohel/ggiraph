/*
 * This file is part of ggiraph.
 * Copyright (c) 2019, David Gohel All rights reserved.
 *
 **/

#include "utils.h"
#include "Rcpp.h"
#include <gdtools.h>
#include <string.h>
#include "fonts.h"
#include "R_ext/GraphicsEngine.h"
#include "a_color.h"
#include <locale>
#include <sstream>
#include <regex>

// SVG device metadata
class DSVG_dev {
public:
  FILE *file;
  std::string filename;
  int pageno;
  std::string canvas_id;
  int element_index;
  std::string element_id;
  int clip_index;
  std::string clip_id;
  double clipleft, clipright, cliptop, clipbottom;
  bool standalone;
  bool setdims;
  /*   */
  int tracer_first_elt;
  int tracer_last_elt;
  int tracer_on;
  int tracer_is_init;

  Rcpp::List system_aliases;
  Rcpp::List user_aliases;

  XPtrCairoContext cc;

  DSVG_dev(std::string filename_, bool standalone_, bool setdims_,
           std::string canvas_id_,
           int bg_,
           Rcpp::List& aliases_,
           double width_, double height_ ):
      filename(filename_),
      pageno(0),
      canvas_id(canvas_id_),
      element_index(0),
      element_id(canvas_id_ + "_el_0"),
      clip_index(0),
      clip_id(canvas_id_ + "_cl_0"),
      standalone(standalone_),
      setdims(setdims_),
      tracer_first_elt(-1),
      tracer_last_elt(-1),
      tracer_on(0),
      tracer_is_init(0),
      system_aliases(Rcpp::wrap(aliases_["system"])),
      user_aliases(Rcpp::wrap(aliases_["user"])),
      cc(gdtools::context_create() ) {
    file = fopen(R_ExpandFileName(filename.c_str()), "w");
    clipleft = 0.0;
    clipright = width_;
    cliptop = 0.0;
    clipbottom = height_;
    doc_ = 0;
    root_ = 0;
    root_g_ = 0;
    element_map_ = 0;
    css_map_ = 0;
  }

  bool ok() const {
    return file != NULL;
  }

  void new_element() {
    element_index++;
    element_id.assign(canvas_id + "_el_" + to_string(element_index));
    register_element();
  }

  void new_clip() {
    clip_index++;
    clip_id.assign(canvas_id + "_cl_" + to_string(clip_index));
  }

  void set_tracer_on(){
    tracer_on = 1;
    tracer_is_init = 0;
    tracer_first_elt = -1;
    tracer_last_elt = -1;
  }

  void set_tracer_off(){
    tracer_on = 0;
    tracer_is_init = 0;
    tracer_first_elt = -1;
    tracer_last_elt = -1;
  }

  void register_element() {
    if( tracer_on > 0 ){
      if( tracer_is_init < 1 ){
        tracer_first_elt = element_index;
        tracer_is_init = 1;
      }
      tracer_last_elt = element_index;
    }
  }

  SVGElement* svg_root() {
    if (doc_)
      return root_;
    this->doc_ = new_svg_doc(standalone, false);
    this->root_ = svg_element("svg", false, (SVGElement*)doc_);
    if (standalone){
      set_attr(root_, "xmlns", "http://www.w3.org/2000/svg");
      set_attr(root_, "xmlns:xlink", "http://www.w3.org/1999/xlink");
    }
    this->root_g_ = svg_element("g", false, root_);
    this->element_map_ = new std::unordered_map<int, SVGElement*>();
    this->css_map_ = new std::unordered_map<std::string, std::string>();
    return root_;
  }

  SVGElement* svg_element(const char* name, const bool track, SVGElement* parent = NULL) {
    SVGElement* el = new_svg_element(name, doc_);
    if (parent) {
      append_element(el, parent);
    } else {
      append_element(el, root_g_);
    }
    if (track) {
      element_map_->insert(std::pair<int, SVGElement*>(element_index, el));
    }
    return el;
  }

  SVGText* svg_text(const char* str, SVGElement* parent = NULL, const bool cdata = true) {
    SVGText* el = new_svg_text(str, doc_, cdata);
    if (parent) {
      append_element((SVGElement*)el, parent);
    } else {
      append_element((SVGElement*)el, root_g_);
    }
    return el;
  }

  SVGElement* get_svg_element(const int id) {
    std::unordered_map<int, SVGElement*>::const_iterator got = element_map_->find(id);
    if ( got == element_map_->end() )
      return NULL;
    else
      return got->second;
  }

  void add_css(const std::string key, const std::string value) {
    css_map_->insert(std::pair<std::string, std::string>(key, value));
  }

  ~DSVG_dev() {
    if (ok()) {
      if (doc_) {
        add_styles();
        svg_to_file(doc_, file, false);
        delete(element_map_);
        delete(css_map_);
        delete(doc_);
      }
      fclose(file);
    }
  }

private:
  SVGDocument* doc_;
  SVGElement* root_;
  SVGElement* root_g_;
  std::unordered_map<int, SVGElement*>* element_map_;
  std::unordered_map<std::string, std::string>* css_map_;

  void add_styles() {
    if (css_map_->size() > 0) {
      SVGElement* styleEl = new_svg_element("style", doc_);
      prepend_element(styleEl, root_);
      std::stringstream os;
      for ( auto it = css_map_->begin(); it != css_map_->end(); ++it ) {
        os << it->second;
      }
      svg_text(os.str().c_str(), styleEl, true);
    }
  }
};

static void dsvg_metric_info(int c, const pGEcontext gc, double* ascent,
                             double* descent, double* width, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  bool Unicode = mbcslocale;
  if (c < 0) {
    Unicode = TRUE;
    c = -c;
  }
  char str[16];
  if (!c) {
    str[0]='M'; str[1]='g'; str[2]=0;
  } else if (Unicode) {
    Rf_ucstoutf8(str, (unsigned int) c);
  } else {
    str[0] = (char) c;
    str[1] = '\0';
  }

  std::string file = fontfile(gc->fontfamily, gc->fontface, svgd->user_aliases);
  std::string name = fontname(gc->fontfamily, gc->fontface, svgd->system_aliases, svgd->user_aliases);
  gdtools::context_set_font(svgd->cc, name, gc->cex * gc->ps, is_bold(gc->fontface), is_italic(gc->fontface), file);
  FontMetric fm = gdtools::context_extents(svgd->cc, std::string(str));

  *ascent = fm.ascent;
  *descent = fm.descent;
  *width = fm.width;
}

static void dsvg_clip(double x0, double x1, double y0, double y1, pDevDesc dd) {
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

static void dsvg_close(pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  delete(svgd);
}

static void dsvg_line(double x1, double y1, double x2, double y2,
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

static void dsvg_polyline(int n, double *x, double *y, const pGEcontext gc,
                          pDevDesc dd) {
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
  set_attr(polyline, "points", os.str().c_str());
  set_attr(polyline, "id", eltid);
  set_clip(polyline, clipid);
  set_attr(polyline, "fill", "none");
  set_stroke(polyline, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
}
static void dsvg_polygon(int n, double *x, double *y, const pGEcontext gc,
                         pDevDesc dd) {
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
  set_attr(polygon, "points", os.str().c_str());
  set_attr(polygon, "id", eltid);
  set_clip(polygon, clipid);
  set_fill(polygon, gc->fill);
  set_stroke(polygon, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
}

void dsvg_path(double *x, double *y,
               int npoly, int *nper,
               Rboolean winding,
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
  set_attr(path, "d", os.str().c_str());
  set_attr(path, "id", eltid);
  set_clip(path, clipid);
  set_fill(path, gc->fill);

  if (winding)
    set_attr(path, "fill-rule", "nonzero");
  else
    set_attr(path, "fill-rule", "evenodd");

  set_stroke(path, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
}

static double dsvg_strwidth_utf8(const char *str, const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  std::string file = fontfile(gc->fontfamily, gc->fontface, svgd->user_aliases);
  std::string name = fontname(gc->fontfamily, gc->fontface, svgd->system_aliases, svgd->user_aliases);
  gdtools::context_set_font(svgd->cc, name, gc->cex * gc->ps, is_bold(gc->fontface), is_italic(gc->fontface), file);
  FontMetric fm = gdtools::context_extents(svgd->cc, std::string(str));
  return fm.width;
}
static double dsvg_strwidth(const char *str, const pGEcontext gc, pDevDesc dd) {
  return dsvg_strwidth_utf8(Rf_translateCharUTF8(Rf_mkChar(str)), gc, dd);
}

static void dsvg_rect(double x0, double y0, double x1, double y1,
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

static void dsvg_circle(double x, double y, double r, const pGEcontext gc,
                        pDevDesc dd) {
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

static void dsvg_text_utf8(double x, double y, const char *str, double rot,
                           double hadj, const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  svgd->new_element();
  const char *clipid = svgd->clip_id.c_str();
  const char *eltid = svgd->element_id.c_str();

  SVGElement* g = svgd->svg_element("g", false);
  set_clip(g, clipid);
  SVGElement* text = svgd->svg_element("text", true, g);

  if (rot == 0) {
    set_attr(text, "x", x);
    set_attr(text, "y", y);
  } else {
    std::ostringstream ost;
    ost.flags(std::ios_base::fixed | std::ios_base::dec);
    ost.precision(2);
    ost << "translate(" << x << "," << y << ") rotate(" << -1.0 * rot << ")";
    set_attr(text, "transform", ost.str().c_str());
  }
  set_attr(text, "id", eltid);
  set_attr(text, "font-size", to_string(gc->cex * gc->ps * .75) + "pt");
  if (is_bold(gc->fontface))
    set_attr(text, "font-weight", "bold");
  if (is_italic(gc->fontface))
    set_attr(text, "font-style", "italic");
  if (gc->col != -16777216){
    set_fill(text, gc->col);
  } // black

  std::string font = fontname(gc->fontfamily, gc->fontface, svgd->system_aliases, svgd->user_aliases);
  set_attr(text, "font-family", font.c_str());

  text->SetText(str);
}

static void dsvg_text(double x, double y, const char *str, double rot,
                      double hadj, const pGEcontext gc, pDevDesc dd) {
  return dsvg_text_utf8(x, y, Rf_translateCharUTF8(Rf_mkChar(str)), rot, hadj, gc, dd);
}

static void dsvg_size(double *left, double *right, double *bottom, double *top,
                      pDevDesc dd) {
  *left = dd->left;
  *right = dd->right;
  *bottom = dd->bottom;
  *top = dd->top;
}

static void dsvg_raster(unsigned int *raster, int w, int h,
                        double x, double y,
                        double width, double height,
                        double rot,
                        Rboolean interpolate,
                        const pGEcontext gc, pDevDesc dd)
{
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  svgd->new_element();
  const char *clipid = svgd->clip_id.c_str();
  const char *eltid = svgd->element_id.c_str();

  if (height < 0)
    height = -height;

  std::vector<unsigned int> raster_(w*h);
  for ( size_t i = 0 ; i < raster_.size(); i++) {
    raster_[i] = raster[i] ;
  }

  std::string base64_str = gdtools::raster_to_str(raster_, w, h, width*(25/6), height*(25/6), interpolate);

  SVGElement* image = svgd->svg_element("image", true);
  set_attr(image, "x", x);
  set_attr(image, "y", y - height);
  set_attr(image, "width", width);
  set_attr(image, "height", height);
  set_attr(image, "id", eltid);
  set_clip(image, clipid);

  if (fabs(rot)>0.001) {
    std::ostringstream ost;
    ost.flags(std::ios_base::fixed | std::ios_base::dec);
    ost.precision(2);
    ost << "rotate(" << -1.0 * rot << "," << x << "," << y << ")";
    set_attr(image, "transform", ost.str().c_str());
  }

  std::stringstream os;
  os << "data:image/png;base64," << base64_str.c_str();
  set_attr(image, "xlink:href", os.str().c_str());

  if (svgd->standalone)
    set_attr(image, "xmlns:xlink", "http://www.w3.org/1999/xlink");
}

static SEXP dsvg_setPattern(SEXP pattern, pDevDesc dd) {
    return R_NilValue;
}

static void dsvg_releasePattern(SEXP ref, pDevDesc dd) {} 

static SEXP dsvg_setClipPath(SEXP path, SEXP ref, pDevDesc dd) {
    return R_NilValue;
}

static void dsvg_releaseClipPath(SEXP ref, pDevDesc dd) {}

static SEXP dsvg_setMask(SEXP path, SEXP ref, pDevDesc dd) {
    return R_NilValue;
}

static void dsvg_releaseMask(SEXP ref, pDevDesc dd) {}
  
static void dsvg_new_page(const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  if (svgd->pageno > 0) {
    Rf_error("svgd only supports one page");
  }

  SVGElement* root = svgd->svg_root();
  set_attr(root, "id", svgd->canvas_id.c_str());
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
  if( bg_color.is_transparent() < 1 ){
    fill = gc->fill;
    col = gc->col;
    gc->fill = bg_fill;
    gc->col = bg_fill;
    dsvg_clip(0, dd->right, 0, dd->bottom, dd);
    dsvg_rect(0, 0, dd->right, dd->bottom, gc, dd);
    gc->fill = fill;
    gc->col = col;
  }

  svgd->pageno++;
}


pDevDesc dsvg_driver_new(std::string filename, int bg, double width,
                         double height, int pointsize, bool standalone, bool setdims,
                         std::string canvas_id, Rcpp::List aliases) {

  pDevDesc dd = (DevDesc*) calloc(1, sizeof(DevDesc));
  if (dd == NULL)
    return dd;

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
  dd->setPattern      = dsvg_setPattern;
  dd->releasePattern  = dsvg_releasePattern;
  dd->setClipPath     = dsvg_setClipPath;
  dd->releaseClipPath = dsvg_releaseClipPath;
  dd->setMask         = dsvg_setMask;
  dd->releaseMask     = dsvg_releaseMask;
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

  dd->deviceSpecific = new DSVG_dev(filename, standalone, setdims,
                                    canvas_id,
                                    bg, aliases,
                                    width * 72, height * 72);
  return dd;
}

// [[Rcpp::export]]
bool DSVG_(std::string file, double width, double height, std::string bg,
           int pointsize, bool standalone, bool setdims, std::string canvas_id, Rcpp::List aliases) {

  int bg_ = R_GE_str2col(bg.c_str());

  R_GE_checkVersionOrDie(R_GE_version);
  R_CheckDeviceAvailable();
  BEGIN_SUSPEND_INTERRUPTS {
    setlocale(LC_NUMERIC, "C");

    pDevDesc dev = dsvg_driver_new(file, bg_, width, height, pointsize, standalone, setdims, canvas_id,
                                   aliases);
    if (dev == NULL)
      Rcpp::stop("Failed to start SVG2 device");

    pGEDevDesc dd = GEcreateDevDesc(dev);
    GEaddDevice2(dd, "dsvg_device");
    GEinitDisplayList(dd);

  } END_SUSPEND_INTERRUPTS;

  return true;
}


// [[Rcpp::export]]
bool set_tracer_on(int dn) {
  pGEDevDesc dev= GEgetDevice(dn);
  if (dev) {
    DSVG_dev *pd = (DSVG_dev *) dev->dev->deviceSpecific;
    pd->set_tracer_on();
  }
  return true;
}

// [[Rcpp::export]]
bool set_tracer_off(int dn) {
  pGEDevDesc dev= GEgetDevice(dn);
  if (dev) {
    DSVG_dev *pd = (DSVG_dev *) dev->dev->deviceSpecific;
    pd->set_tracer_off();
  }
  return true;
}

// [[Rcpp::export]]
Rcpp::IntegerVector collect_id(int dn) {
  pGEDevDesc dev= GEgetDevice(dn);

  if (dev) {
    DSVG_dev *pd = (DSVG_dev *) dev->dev->deviceSpecific;

    int first = pd->tracer_first_elt;
    int last = pd->tracer_last_elt;

    if( first < 0 || last < 0 ){
      Rcpp::IntegerVector res(0);
      return res;
    } else if( first > last ){
      Rcpp::IntegerVector res(0);
      return res;
    }

    int l_ = 1 + last - first;

    Rcpp::IntegerVector res(l_);

    for( int i = first ; i <= last ; i++ ){
      res[i-first] = i;
    }
    return res;
  }
  return R_NilValue;
}

std::string compile_css(const std::string& cls_prefix,
                        const char * cls_suffix,
                        const std::string& canvas_id,
                        const char * data_attr,
                        const char * data_value,
                        const char * css) {
  std::string cls = cls_prefix + cls_suffix + canvas_id + "[" + data_attr + " = \"" + data_value + "\"]";
  std::regex pattern("_CLASSNAME_");
  return std::regex_replace(css, pattern, cls);
}


// [[Rcpp::export]]
bool add_attribute(int dn, Rcpp::IntegerVector id,
                   std::vector< std::string > str,
                   std::string name){
  int nb_elts = id.size();
  pGEDevDesc dev= GEgetDevice(dn);

  if (!dev) return false;

  DSVG_dev *svgd = (DSVG_dev *) dev->dev->deviceSpecific;

  std::string hover("hover_css");
  std::string selected("selected_css");
  std::string cls_prefix("");

  for( int i = 0 ; i < nb_elts ; i++ ){
    if (str[i].length() == 0)
      continue;

    SVGElement* el = svgd->get_svg_element(id[i]);
    if (el != NULL) {
      const bool isHoverCss = hover.compare(name) == 0;
      const bool isSelectedCss = selected.compare(name) == 0;
      if (isHoverCss || isSelectedCss) {
        if (isHoverCss) {
          cls_prefix.assign("hover_");
        } else {
          cls_prefix.assign("selected_");
        }
        const char * data_id = svg_attribute(el, "data-id");
        if (data_id != NULL) {
          std::string css = compile_css(cls_prefix,
                                        "",
                                        svgd->canvas_id,
                                        "data-id",
                                        data_id,
                                        str[i].c_str());
          if (css.length() > 0)
            svgd->add_css(std::string(cls_prefix + "_data_id_" + data_id), css);
          continue;
        }
        const char * key_id = svg_attribute(el, "key-id");
        if (key_id != NULL) {
          std::string css = compile_css(cls_prefix,
                                        "key_",
                                        svgd->canvas_id,
                                        "key-id",
                                        key_id,
                                        str[i].c_str());
          if (css.length() > 0)
            svgd->add_css(std::string(cls_prefix + "_key_id_" + key_id), css);
          continue;
        }
        const char * theme_id = svg_attribute(el, "theme-id");
        if (theme_id != NULL) {
          std::string css = compile_css(cls_prefix,
                                        "theme_",
                                        svgd->canvas_id,
                                        "theme-id",
                                        theme_id,
                                        str[i].c_str());
          if (css.length() > 0)
            svgd->add_css(std::string(cls_prefix + "_theme_id_" + theme_id), css);
          continue;
        }

      } else {
        set_attr(el, name.c_str(), str[i].c_str());
      }
    }
  }
  return true;
}
