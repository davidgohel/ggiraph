#ifndef DSVG_GEOM_INCLUDED
#define DSVG_GEOM_INCLUDED

/*
 * Geometry utilities
 */

#include <string>

class Point2D;
class Rect2D;
class AffineTransform;

class Point2D {
public:
  double x;
  double y;

  Point2D(const double x_ = 0, const double y_ = 0) :
    x(x_), y(y_) {}

  void transform(const AffineTransform& t);
};

class Rect2D {
public:
  Point2D p1;
  Point2D p2;
  Point2D p3;
  Point2D p4;

  Rect2D(const Point2D p1_, const Point2D p2_, const Point2D p3_, const Point2D p4_) :
    p1(p1_), p2(p2_), p3(p3_), p4(p4_) {}

  bool intersects(const Rect2D& other) const{
    return Rect2D::rects_intersect(*this, other);
  }

  static bool rects_intersect(const Rect2D& r1, const Rect2D& r2);

  void transform(const AffineTransform& t);
};

// Minimal AffineTransform, adapted from Chromium/Blink
// https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/platform/transforms/affine_transform.cc
class AffineTransform {

public:
  double a;
  double b;
  double c;
  double d;
  double e;
  double f;

  AffineTransform() { to_identity(); }
  AffineTransform(double a, double b, double c, double d, double e, double f) {
    set_matrix(a, b, c, d, e, f);
  }

  void set_matrix(double a, double b, double c, double d, double e, double f);

  void set_transform(const AffineTransform& other) {
    set_matrix(other.a, other.b, other.c, other.d, other.e, other.f);
  }

  /*
  bool is_identity() const;
  */
  bool is_identity_or_translation() const;
  void to_identity();

  /*
  bool is_invertible() const;
  */
  AffineTransform inverse() const;

  AffineTransform& multiply(const AffineTransform& other);
  AffineTransform& scale(double sx, double sy);
  AffineTransform& rotate(double degrees);
  AffineTransform& translate(double tx, double ty);

  std::string to_string() const;
};

const double deg2rad (double degrees);

#endif // DSVG_GEOM_INCLUDED
