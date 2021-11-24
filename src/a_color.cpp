#include "a_color.h"
#include "utils.h"

std::string a_color::color() {
  char buf[ 100 ];
  sprintf( buf, "#%02X%02X%02X", R_RED(col), R_GREEN(col), R_BLUE(col));
  std::string str = buf;
  return str;
}

std::string a_color::opacity() {
  return to_string(alpha / 255.0);
}

bool a_color::is_visible() {
  return (col != NA_INTEGER) && (alpha != 0);
}

bool a_color::is_transparent() {
  return (alpha == 0);
}

bool a_color::has_alpha() {
  return (alpha < 255);
}

a_color::a_color (int col):
  col(col) {
  alpha = R_ALPHA(col);
}
