/*
 * DSVG device - Text handling
 */
#include "dsvg.h"
#include <systemfonts.h>
#include "geom.h"

bool is_bold(int face) {
  return face == 2 || face == 4;
}

bool is_italic(int face) {
  return face == 3 || face == 4;
}

bool is_symbol(int face) {
  return face == 5;
}

inline std::string find_system_alias(std::string& family,
                                     Rcpp::List const& aliases) {
  std::string out;
  if (aliases.containsElementNamed(family.c_str())) {
    SEXP alias = aliases[family];
    if (TYPEOF(alias) == STRSXP && Rf_length(alias) == 1)
      out = Rcpp::as<std::string>(alias);
  }
  return out;
}

std::string fontname(const char* family_, int face, Rcpp::List const& system_aliases) {

  std::string family(family_);
  if (face == 5)
    family = "symbol";
  else if (family == "")
    family = "sans";

  std::string alias = find_system_alias(family, system_aliases);

  if (alias.size())
    return alias;
  else
    return family;
}

// Copied from the package svglite maintained by Thomas Lin Pedersen
FontSettings get_font_file(const char* family, int face) {
  const char* fontfamily = family;
  if (is_symbol(face)) {
    fontfamily = "symbol";
  } else if (strcmp(family, "") == 0) {
    fontfamily = "sans";
  }
  return locate_font_with_features(fontfamily, is_italic(face), is_bold(face));
}

void dsvg_metric_info(int c, const pGEcontext gc, double* ascent,
                             double* descent, double* width, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  if (c < 0) {
    c = -c;
  }

  std::string fontname_ = fontname(gc->fontfamily, gc->fontface, svgd->system_aliases);
  FontSettings font = get_font_file(fontname_.c_str(), gc->fontface);
  int error = glyph_metrics(c, font.file, font.index, gc->ps * gc->cex, 1e4, ascent, descent, width);
  if (error != 0) {
    *ascent = 0;
    *descent = 0;
    *width = 0;
  }

  double mod = 72./1e4;
  *ascent *= mod;
  *descent *= mod;
  *width *= mod;
}

double dsvg_strwidth_utf8(const char *str, const pGEcontext gc, pDevDesc dd) {

  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  std::string fontname_ = fontname(gc->fontfamily, gc->fontface, svgd->system_aliases);
  FontSettings font = get_font_file(fontname_.c_str(), gc->fontface);
  double width = 0.0;
  int error = string_width(str, font.file, font.index, gc->ps * gc->cex, 1e4, 1, &width);
  if (error != 0) {
    width = 0.0;
  }
  return width * 72. / 1e4;
}

double dsvg_strwidth(const char *str, const pGEcontext gc, pDevDesc dd) {
  return dsvg_strwidth_utf8(Rf_translateCharUTF8(Rf_mkChar(str)), gc, dd);
}

void dsvg_text_utf8(double x, double y, const char *str, double rot,
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
    std::ostringstream os;
    os.flags(std::ios_base::fixed | std::ios_base::dec);
    os.precision(2);
    os << "translate(" << x << "," << y << ") rotate(" << -1.0 * rot << ")";
    set_attr(text, "transform", os.str());
  }
  set_attr(text, "id", eltid);
  set_attr(text, "font-size", to_string(gc->cex * gc->ps * .75) + "pt");
  if (is_bold(gc->fontface))
    set_attr(text, "font-weight", "bold");
  if (is_italic(gc->fontface))
    set_attr(text, "font-style", "italic");
  if (gc->col != -16777216) {
    set_fill(text, gc->col);
  } // black

  std::string font = fontname(gc->fontfamily, gc->fontface, svgd->system_aliases);
  set_attr(text, "font-family", font);

  text->SetText(str);
}

void dsvg_text(double x, double y, const char *str, double rot,
                      double hadj, const pGEcontext gc, pDevDesc dd) {
  return dsvg_text_utf8(x, y, Rf_translateCharUTF8(Rf_mkChar(str)), rot, hadj, gc, dd);
}

/*
 * Returns the bounding rectangle for a string.
 * x and y MUST be in INCHES.
 *
 * Algorithm from grid's textRect
 */
Rect2D textRect(const double& x, const double& y,
                const SEXP& text,
                const double& xadj, const double& yadj,
                const double& rot,
                const R_xlen_t& i,
                const pGEcontext& gc,
                const pGEDevDesc dev) {
  // calc text width/height
  double w, h;
  if (Rf_isExpression(text)) {
    SEXP expr = VECTOR_ELT(text, i % XLENGTH(text));
    w = fromDeviceWidth(GEExpressionWidth(expr, gc, dev), GE_INCHES, dev);
    h = fromDeviceHeight(GEExpressionHeight(expr, gc, dev), GE_INCHES, dev);
  } else {
    const char* string = CHAR(STRING_ELT(text, i % XLENGTH(text)));
    cetype_t enc = (gc->fontface == 5) ? CE_SYMBOL :
      Rf_getCharCE(STRING_ELT(text, i % XLENGTH(text)));
    w = fromDeviceWidth(GEStrWidth(string, enc, gc, dev), GE_INCHES, dev);
    h = fromDeviceHeight(GEStrHeight(string, enc, gc, dev), GE_INCHES, dev);
  }

  // calc transform
  AffineTransform t_just, t_loc, t_rot;
  t_just.translate(-xadj * w, -yadj * h);
  t_loc.translate(x, y);
  if (rot != 0)
    t_rot.rotate(rot);
  AffineTransform t = t_just.multiply(t_rot).multiply(t_loc);

  // create rect and apply transform
  Rect2D rect(Point2D(0, 0), Point2D(w, 0), Point2D(w, h), Point2D(0, h));
  rect.transform(t);
  return rect;
}

// [[Rcpp::export]]
Rcpp::IntegerVector non_overlapping_texts(
    int dn, Rcpp::RObject label,
    Rcpp::DoubleVector x, Rcpp::DoubleVector y,
    Rcpp::DoubleVector hjust, Rcpp::DoubleVector vjust,
    Rcpp::DoubleVector rot,
    Rcpp::DoubleVector fontsize,
    Rcpp::CharacterVector fontfamily,
    Rcpp::IntegerVector fontface,
    Rcpp::DoubleVector lineheight) {

  // result vector of indices
  Rcpp::IntegerVector result(0);

  // get device
  pGEDevDesc dev = get_ge_device(dn);
  if (!dev) return result;

  // check number of elements
  R_xlen_t nx = Rf_imax2(x.length(), y.length());
  if (nx == 0) return result;

  // check label
  if (Rf_isNull(label) || !Rf_isVector(label) || LENGTH(label) == 0)
    return result;

  // check vectors
  if (fontsize.length() == 0)
    fontsize = Rcpp::DoubleVector({12});
  if (fontfamily.length() == 0)
    fontfamily = Rcpp::CharacterVector({""});
  if (fontface.length() == 0)
    fontface = Rcpp::IntegerVector({1});
  if (lineheight.length() == 0)
    lineheight = Rcpp::DoubleVector({1.2});

  // store lengths
  R_xlen_t hjust_len = hjust.length();
  R_xlen_t vjust_len = vjust.length();
  R_xlen_t rot_len = rot.length();
  R_xlen_t fontsize_len = fontsize.length();
  R_xlen_t fontfamily_len = fontfamily.length();
  R_xlen_t fontface_len = fontface.length();
  R_xlen_t lineheight_len = lineheight.length();

  // vector with non overlapping rects
  std::vector<Rect2D> rects;
  rects.reserve(nx);

  R_GE_gcontext gc;
  for (R_xlen_t i = 0; i < nx; i++) {
    // reset gc
    gc.ps = fontsize[i % fontsize_len];
    strcpy(gc.fontfamily, fontfamily[i % fontfamily_len]);
    gc.fontface = fontface[i % fontface_len];
    gc.lineheight = lineheight[i % lineheight_len];
    gc.cex = 1;
    // get rect
    Rect2D rect = textRect(
      x[i], y[i], label,
      hjust[i % hjust_len],
           vjust[i % vjust_len],
                rot[i % rot_len],
                   i, &gc, dev
    );
    // check overlap
    bool overlaps = false;
    std::size_t j = 0;
    while (!overlaps && (j < rects.size())) {
      overlaps = rect.intersects(rects[j++]);
    }
    if (!overlaps) {
      result.push_back(i + 1); // R index 1-based
      rects.push_back(rect);
    }
  }
  return result;
}
