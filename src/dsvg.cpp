/*
 * This file is part of rvg.
 * Copyright (c) 2018, David Gohel All rights reserved.
 *
 * rvg is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * rvg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with rvg. If not, see <http://www.gnu.org/licenses/>.
 **/

#include "Rcpp.h"
#include <gdtools.h>
#include <string.h>
#include "fonts.h"
#include "R_ext/GraphicsEngine.h"
#include "a_color.h"


std::string line_style(double width, int col, int type, int join, int end)
{
  a_color col_(col);

  if( col_.is_visible() < 1 || width < 0.0001 || type < 0 )
    return col_.svg_stroke_attr();


  std::stringstream os;

  os << " stroke-width=\""<< width * 72 / 96 << "\"";
  os << col_.svg_stroke_attr();

  int lty = type;
  double lwd = width;

  switch (type) {
  case LTY_BLANK:
    break;
  case LTY_SOLID:
    break;
  default:
    os << " stroke-dasharray=\"";
  os << (int) lwd * (lty & 15);
  lty = lty >> 4;
  for(int i = 0 ; i < 8 && lty & 15 ; i++) {
    os << ","<< (int) lwd * (lty & 15);
    lty = lty >> 4;
  }
  os << "\"";
  break;
  }

  switch (join) {
  case GE_ROUND_JOIN: //round
    os << " stroke-linejoin=\"round\"";
    break;
  case GE_MITRE_JOIN: //mitre
    os << " stroke-linejoin=\"miter\"";
    break;
  case GE_BEVEL_JOIN: //bevel
    os << " stroke-linejoin=\"bevel\"";
    break;
  default:
    os << " stroke-linejoin=\"round\"";
  break;
  }

  switch (end) {
  case GE_ROUND_CAP:
    os << " stroke-linecap=\"round\"";
    break;
  case GE_BUTT_CAP:
    os << " stroke-linecap=\"butt\"";
    break;
  case GE_SQUARE_CAP:
    os << " stroke-linecap=\"square\"";
    break;
  default:
    os << " stroke-linecap=\"round\"";
  break;
  }

  return os.str();
}



// SVG device metadata
class DSVG_dev {
public:
  FILE *file;
  std::string filename;
  int pageno;
  int id;
  std::string canvas_id;
  std::string clip_id_root;
  int clip_id;
  double clipleft, clipright, cliptop, clipbottom;
  bool standalone;
  /*   */
  int tracer_first_elt;
  int tracer_last_elt;
  int tracer_on;
  int tracer_is_init;

  Rcpp::List system_aliases;
  Rcpp::List user_aliases;

  XPtrCairoContext cc;

  DSVG_dev(std::string filename_, bool standalone_,
           std::string canvas_id_,
           std::string clip_id_root_,
           int bg_,
           Rcpp::List& aliases_,
           double width_, double height_ ):
      filename(filename_),
      pageno(0),
	    id(-1),
	    canvas_id(canvas_id_),
	    clip_id_root(clip_id_root_),
      standalone(standalone_),
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
  }

  bool ok() const {
    return file != NULL;
  }

  int new_id() {
  	id++;
  	return id;
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
        tracer_first_elt = id;
        tracer_is_init = 1;
      }
      tracer_last_elt = id;
    }
  }

  ~DSVG_dev() {
    if (ok())
      fclose(file);
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

  svgd->clip_id++;

  fputs("<defs>", svgd->file);
  fprintf(svgd->file, "<clipPath id='cl_%s_%d'>", svgd->clip_id_root.c_str(), svgd->clip_id );
  fprintf(svgd->file, "<rect x='%.2f' y='%.2f' width='%.2f' height='%.2f'/>",
          std::min(x0, x1), std::min(y0, y1),
          std::abs(x1 - x0),
          std::abs(y1 - y0) );
  fputs("</clipPath>", svgd->file);
  fputs("</defs>", svgd->file);
}

static void dsvg_close(pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  if (svgd->pageno > 0)
    fputs("</g></svg>\n", svgd->file);

  delete(svgd);
}

static void dsvg_line(double x1, double y1, double x2, double y2,
                     const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  int idx = svgd->new_id();
  svgd->register_element();
  fprintf(svgd->file, "<line x1='%.2f' y1='%.2f' x2='%.2f' y2='%.2f' id='%d'",
    x1, y1, x2, y2, idx);
  fprintf(svgd->file, " clip-path='url(#cl_%s_%d)'", svgd->canvas_id.c_str(), svgd->clip_id);
  std::string line_style_ = line_style(gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  fprintf(svgd->file, "%s", line_style_.c_str());
  a_color col_(gc->fill);
  fprintf(svgd->file, "%s", col_.svg_fill_attr().c_str());

  fputs("/>", svgd->file);
}

static void dsvg_polyline(int n, double *x, double *y, const pGEcontext gc,
                         pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  int idx = svgd->new_id();
  svgd->register_element();
  fputs("<polyline points='", svgd->file);
  fprintf(svgd->file, "%.2f,%.2f", x[0], y[0]);
  for (int i = 1; i < n; i++) {
    fprintf(svgd->file, " %.2f,%.2f", x[i], y[i]);
  }
  fputs("'", svgd->file);
  fprintf(svgd->file, " id='%d'", idx);
  fprintf(svgd->file, " clip-path='url(#cl_%s_%d)'", svgd->canvas_id.c_str(), svgd->clip_id);
  fputs(" fill=\"none\"", svgd->file);

  std::string line_style_ = line_style(gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  fprintf(svgd->file, "%s", line_style_.c_str());

  fputs("/>", svgd->file);
}
static void dsvg_polygon(int n, double *x, double *y, const pGEcontext gc,
                        pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  int idx = svgd->new_id();
  svgd->register_element();
  fputs("<polygon points='", svgd->file);
  fprintf(svgd->file, "%.2f,%.2f", x[0], y[0]);
  for (int i = 1; i < n; i++) {
    fprintf(svgd->file, " %.2f,%.2f", x[i], y[i]);
  }
  fputs("'", svgd->file);
  fprintf(svgd->file, " id='%d'", idx);
  fprintf(svgd->file, " clip-path='url(#cl_%s_%d)'", svgd->clip_id_root.c_str(), svgd->clip_id);

  a_color col_(gc->fill);
  fprintf(svgd->file, "%s", col_.svg_fill_attr().c_str());

  std::string line_style_ = line_style(gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  fprintf(svgd->file, "%s", line_style_.c_str());

  fputs("/>", svgd->file);
}

void dsvg_path(double *x, double *y,
              int npoly, int *nper,
              Rboolean winding,
              const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  int idx = svgd->new_id();
  svgd->register_element();
  int index = 0;

  fputs("<path d='", svgd->file);
  for (int i = 0; i < npoly; i++) {
    fprintf(svgd->file, "M %.2f %.2f ", x[index], y[index]);
    index++;
    for (int j = 1; j < nper[i]; j++) {
      fprintf(svgd->file, "L %.2f %.2f ", x[index], y[index]);
      index++;
    }
    fputs("Z ", svgd->file);
  }
  fprintf(svgd->file, "' id='%d'", idx);
  fprintf(svgd->file, " clip-path='url(#cl_%s_%d)'", svgd->clip_id_root.c_str(), svgd->clip_id);

  a_color fill_(gc->fill);
  fprintf(svgd->file, "%s", fill_.svg_fill_attr().c_str());

  if (winding)
    fputs(" fill-rule='nonzero'", svgd->file);
  else
    fputs(" fill-rule='evenodd'", svgd->file);

  std::string line_style_ = line_style(gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  fprintf(svgd->file, "%s", line_style_.c_str());
  fputs("/>", svgd->file);
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
  int idx = svgd->new_id();
  svgd->register_element();

  fprintf(svgd->file,
      "<rect x='%.2f' y='%.2f' width='%.2f' height='%.2f'",
      fmin(x0, x1), fmin(y0, y1), fabs(x1 - x0), fabs(y1 - y0));
  fprintf(svgd->file, " id='%d'", idx);
  fprintf(svgd->file, " clip-path='url(#cl_%s_%d)'", svgd->clip_id_root.c_str(), svgd->clip_id);

  a_color fill_(gc->fill);
  fprintf(svgd->file, "%s", fill_.svg_fill_attr().c_str());
  std::string line_style_ = line_style(gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  fprintf(svgd->file, "%s", line_style_.c_str());

  fputs("/>", svgd->file);
}

static void dsvg_circle(double x, double y, double r, const pGEcontext gc,
                       pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  int idx = svgd->new_id();
  svgd->register_element();

  fprintf(svgd->file, "<circle cx='%.2f' cy='%.2f' r='%.2fpt'", x, y, r * .75 );
  fprintf(svgd->file, " id='%d'", idx);
  fprintf(svgd->file, " clip-path='url(#cl_%s_%d)'", svgd->clip_id_root.c_str(), svgd->clip_id);
  a_color fill_(gc->fill);
  fprintf(svgd->file, "%s", fill_.svg_fill_attr().c_str());
  std::string line_style_ = line_style(gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  fprintf(svgd->file, "%s", line_style_.c_str());
  fputs("/>", svgd->file);
}

static void dsvg_text_utf8(double x, double y, const char *str, double rot,
                     double hadj, const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  int idx = svgd->new_id();
  svgd->register_element();
  fprintf(svgd->file, "<g clip-path='url(#cl_%s_%d)'>", svgd->clip_id_root.c_str(), svgd->clip_id);

  fputs("<text", svgd->file);
  if (rot == 0) {
    fprintf(svgd->file, " x='%.2f' y='%.2f'", x, y);
  } else {
    fprintf(svgd->file, " transform='translate(%.2f,%.2f) rotate(%0.0f)'", x, y,
      -1.0 * rot);
  }
  fprintf(svgd->file, " id='%d'", idx);
  fprintf(svgd->file, " font-size='%.2fpt'", gc->cex * gc->ps * .75 );
  if (is_bold(gc->fontface))
    fputs(" font-weight='bold'", svgd->file);
  if (is_italic(gc->fontface))
    fputs(" font-style='italic'", svgd->file);
  if (gc->col != -16777216){
    a_color fill_(gc->col);
    fprintf(svgd->file, "%s", fill_.svg_fill_attr().c_str());
  } // black

  std::string font = fontname(gc->fontfamily, gc->fontface, svgd->system_aliases, svgd->user_aliases);

  fprintf(svgd->file, " font-family='%s'", font.c_str());

  fputs(">", svgd->file);

  for(const char* cur = str; *cur != '\0'; ++cur) {
    switch(*cur) {
    case '&': fputs("&amp;", svgd->file); break;
    case '<': fputs("&lt;",  svgd->file); break;
    case '>': fputs("&gt;",  svgd->file); break;
    default:  fputc(*cur,    svgd->file);
    }
  }

  fputs("</text>", svgd->file);
  fputs("</g>", svgd->file);
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
  int idx = svgd->new_id();
  svgd->register_element();

  if (height < 0)
    height = -height;

  std::vector<unsigned int> raster_(w*h);
  for ( size_t i = 0 ; i < raster_.size(); i++) {
    raster_[i] = raster[i] ;
  }

  std::string base64_str = gdtools::raster_to_str(raster_, w, h, width*(25/6), height*(25/6), interpolate);

  fprintf(svgd->file, "<image x='%.2f' y='%.2f' ", x, y - height );
  fprintf(svgd->file, "width='%.2f' height='%.2f' ", width, height);
  fprintf(svgd->file, "id='%d' ", idx);
  fprintf(svgd->file, "clip-path='url(#cl_%s_%d)' ", svgd->clip_id_root.c_str(), svgd->clip_id);

  if (fabs(rot)>0.001) {
    fprintf(svgd->file, "transform='rotate(%0.0f,%0.0f,%0.0f)' ", -1.0 * rot, x, y );
  }
  fprintf(svgd->file, "xlink:href='data:image/png;base64,%s'", base64_str.c_str());
  if (svgd->standalone) fputs( " xmlns:xlink='http://www.w3.org/1999/xlink'", svgd->file);
  fputs( "/>", svgd->file);


}

static void dsvg_new_page(const pGEcontext gc, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  if (svgd->pageno > 0) {
    Rf_error("svgd only supports one page");
  }
  svgd->new_id();

  if (svgd->standalone)
    fputs("<?xml version='1.0' encoding='UTF-8'?>\n", svgd->file);

  fputs("<svg ", svgd->file);
  if (svgd->standalone){
    fputs("xmlns='http://www.w3.org/2000/svg' ", svgd->file);
    fputs("xmlns:xlink='http://www.w3.org/1999/xlink' ", svgd->file);
  }

  fprintf(svgd->file, "id='%s' ", svgd->canvas_id.c_str());
  fprintf(svgd->file, "viewBox='0 0 %.2f %.2f' ", dd->right, dd->bottom);
  fprintf(svgd->file, "width='%.2f' ", dd->right);
  fprintf(svgd->file, "height='%.2f'", dd->bottom);
  fputs("><g>' ", svgd->file);

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
    dsvg_clip(0, 0, dd->right, dd->bottom, dd);
    dsvg_rect(0, 0, dd->right, dd->bottom, gc, dd);
    gc->fill = fill;
    gc->col = col;
  }

  svgd->pageno++;
}


pDevDesc dsvg_driver_new(std::string filename, int bg, double width,
                        double height, int pointsize, bool standalone, std::string canvas_id,
                        std::string clip_id_root,
                        Rcpp::List aliases) {

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

  dd->deviceSpecific = new DSVG_dev(filename, standalone,
                                    canvas_id, clip_id_root,
                                    bg, aliases,
                                    width * 72, height * 72);
  return dd;
}

// [[Rcpp::export]]
bool DSVG_(std::string file, double width, double height, std::string bg,
             int pointsize, bool standalone, std::string canvas_id, std::string clip_id_root, Rcpp::List aliases) {

  int bg_ = R_GE_str2col(bg.c_str());

  R_GE_checkVersionOrDie(R_GE_version);
  R_CheckDeviceAvailable();
  BEGIN_SUSPEND_INTERRUPTS {
    pDevDesc dev = dsvg_driver_new(file, bg_, width, height, pointsize, standalone, canvas_id, clip_id_root,
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


// [[Rcpp::export]]
bool add_attribute(int dn, Rcpp::IntegerVector id,
                  std::vector< std::string > str,
                  std::string name){
  int nb_elts = id.size();
  pGEDevDesc dev= GEgetDevice(dn);

  if (!dev) return false;

  DSVG_dev *svgd = (DSVG_dev *) dev->dev->deviceSpecific;

  fputs("<script type='text/javascript'><![CDATA[", svgd->file);

  for( int i = 0 ; i < nb_elts ; i++ ){
    fprintf(svgd->file,
            "document.querySelectorAll('#%s')[0].getElementById('%d').setAttribute('%s','%s');",
            svgd->canvas_id.c_str(), id[i], name.c_str(), str[i].c_str());
  }
  fputs("]]></script>", svgd->file);
  return true;
}

