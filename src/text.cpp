#include "utils.h"
#include "geom.h"

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
