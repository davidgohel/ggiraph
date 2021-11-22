#include "geom.h"
#include <Rcpp.h>
#include <math.h>

void Point2D::transform(const AffineTransform& t) {
  double ox = x, oy = y;
  x = ox * t.a + oy * t.c + t.e;
  y = ox * t.b + oy * t.d + t.f;
}

/*
 * Algorithm from Paul Bourke
 * http://www.paulbourke.net/geometry/pointlineplane/
 * Adapted from grid's implementation
 */
bool lines_intersect(const Point2D& p1, const Point2D& p2,
                     const Point2D& p3, const Point2D& p4) {
  bool result = false;
  double denom = ((p4.y - p3.y) * (p2.x - p1.x) -
                  (p4.x - p3.x) * (p2.y - p1.y));
  double num_a = ((p4.x - p3.x) * (p1.y - p3.y) -
                  (p4.y - p3.y) * (p1.x - p3.x));
  double num_b = ((p2.x - p1.x) * (p1.y - p3.y) -
                  (p2.y - p1.y) * (p1.x - p3.x));
  /* If the lines are parallel ... */
  if (denom == 0) {
    /* If the lines are coincident ... */
    if (num_a == 0) {
      /* If the lines are vertical ... */
      if (p1.x == p2.x) {
        /* Compare y-values */
        if (!(
            (p1.y < p3.y && Rf_fmax2(p1.y, p2.y) < Rf_fmin2(p3.y, p4.y)) ||
            (p3.y < p1.y && Rf_fmax2(p3.y, p4.y) < Rf_fmin2(p1.y, p2.y))
        ))
          result = true;
      } else {
        /* Compare x-values */
        if (!(
            (p1.x < p3.x && Rf_fmax2(p1.x, p2.x) < Rf_fmin2(p3.x, p4.x)) ||
            (p3.x < p1.x && Rf_fmax2(p3.x, p4.x) < Rf_fmin2(p1.x, p2.x))
        ))
          result = true;
      }
    }
  } else {
    /* ... otherwise, calculate where the lines intersect */
    num_a = num_a / denom;
    num_b = num_b / denom;
    /* Check for overlap */
    if ((num_a > 0 && num_a < 1) && (num_b > 0 && num_b < 1))
      result = true;
  }
  return result;
}

bool rect_edges_intersect(const Point2D& p1, const Point2D& p2, const Rect2D& r) {
  return (
    lines_intersect(p1, p2, r.p1, r.p2) ||
    lines_intersect(p1, p2, r.p2, r.p3) ||
    lines_intersect(p1, p2, r.p3, r.p4) ||
    lines_intersect(p1, p2, r.p4, r.p1)
  );
}

bool Rect2D::rects_intersect(const Rect2D& r1, const Rect2D& r2) {
  return (
    rect_edges_intersect(r1.p1, r1.p2, r2) ||
    rect_edges_intersect(r1.p2, r1.p3, r2) ||
    rect_edges_intersect(r1.p3, r1.p4, r2) ||
    rect_edges_intersect(r1.p4, r1.p1, r2)
  );
}

void Rect2D::transform(const AffineTransform& t) {
  p1.transform(t);
  p2.transform(t);
  p3.transform(t);
  p4.transform(t);
}


void AffineTransform::set_matrix(double a_, double b_, double c_,
                                 double d_, double e_, double f_) {
  a = a_;
  b = b_;
  c = c_;
  d = d_;
  e = e_;
  f = f_;
}

/*
bool AffineTransform::is_identity() const {
  return (a == 1 && b == 0 && c == 0 &&
          d == 1 && e == 0 && f == 0);
}
*/

bool AffineTransform::is_identity_or_translation() const {
  return a == 1 && b == 0 && c == 0 && d == 1;
}

void AffineTransform::to_identity() {
  set_matrix(1, 0, 0, 1, 0, 0);
}

/*
bool AffineTransform::is_invertible() const {
  return (a * d - b * c) != 0.0;
}
*/

AffineTransform AffineTransform::inverse() const {
  double determinant = a * d - b * c;
  AffineTransform result;

  if (determinant == 0.0) return result;

  if (is_identity_or_translation()) {
    result.e = -e;
    result.f = -f;
    return result;
  }

  result.a = d / determinant;
  result.b = -b / determinant;
  result.c = -c / determinant;
  result.d = a / determinant;
  result.e = (c * f - d * e) / determinant;
  result.f = (b * e - a * f) / determinant;

  return result;
}

void multiply_transforms(const AffineTransform& t1,
                         const AffineTransform& t2,
                         AffineTransform* res) {
  res->a = (t1.a * t2.a + t1.b * t2.c);
  res->b = (t1.a * t2.b + t1.b * t2.d);
  res->c = (t1.c * t2.a + t1.d * t2.c);
  res->d = (t1.c * t2.b + t1.d * t2.d);
  res->e = (t1.e * t2.a + t1.f * t2.c + t2.e);
  res->f = (t1.e * t2.b + t1.f * t2.d + t2.f);
}

AffineTransform& AffineTransform::multiply(const AffineTransform& other) {
  AffineTransform trans;
  multiply_transforms(*this, other, &trans);
  set_transform(trans);
  return *this;
}

AffineTransform& AffineTransform::scale(double sx, double sy) {
  a *= sx;
  b *= sx;
  c *= sy;
  d *= sy;
  return *this;
}

AffineTransform& AffineTransform::rotate(double degrees) {
  double radians = deg2rad(degrees);
  double cos_angle = cos(radians);
  double sin_angle = sin(radians);
  AffineTransform rot(cos_angle, sin_angle, -sin_angle, cos_angle, 0, 0);
  multiply(rot);
  return *this;
}

AffineTransform& AffineTransform::translate(double tx, double ty) {
  if (is_identity_or_translation()) {
    e += tx;
    f += ty;
    return *this;
  }
  e += tx * a + ty * c;
  f += tx * b + ty * d;
  return *this;
}

std::string AffineTransform::to_string() const {
  std::ostringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os << "matrix("
    << a << "," << b << "," << c << ","
    << d << "," << e << "," << f << ")";
  return os.str();
}

const double deg2rad (double degrees) {
  return degrees * 4.0 * atan (1.0) / 180.0;
}
