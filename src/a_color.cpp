#include <Rcpp.h>
#include "a_color.h"
#include <iostream>
#include "R_ext/GraphicsDevice.h"

std::string a_color::color()
{
  char buf[ 100 ];
  sprintf( buf, "#%02X%02X%02X", R_RED(this->col), R_GREEN(this->col), R_BLUE(this->col));
  std::string str = buf;
  return str;
}

std::string a_color::opacity() {
  std::stringstream os;
  os.precision(2);
  os << this->alpha / 255.0 ;
  return os.str();
}

std::string a_color::svg_fill_attr()
{

  if( this->is_transparent() > 0 )
    return " fill=\"none\"";

  char col_buf[ 100 ];
  sprintf( col_buf, " fill=\"#%02X%02X%02X\"", R_RED(this->col), R_GREEN(this->col), R_BLUE(this->col));
  std::string col_str = col_buf;

  std::stringstream os;
  os << col_str;

  os << " fill-opacity=\"";

  os.precision(2);
  os << this->alpha / 255.0 << "\"";
  return os.str();
}

std::string a_color::svg_stroke_attr()
{

  if( this->is_transparent() > 0 )
    return " stroke=\"none\"";

  char col_buf[ 100 ];
  sprintf( col_buf, " stroke=\"#%02X%02X%02X\"", R_RED(this->col), R_GREEN(this->col), R_BLUE(this->col));
  std::string col_str = col_buf;

  std::stringstream os;
  os << col_str;
  os.precision(2);

  os << " stroke-opacity=\"" << this->alpha / 255.0 << "\"";
  return os.str();
}

int a_color::is_visible() {
  return (this->col != NA_INTEGER) && (this->alpha != 0);
}
int a_color::has_alpha() {
  return (this->alpha < 255);
}

int a_color::is_transparent() {
  return (R_ALPHA(this->col) == 0);
}

a_color::a_color (int col ):
  col(col){
  this->alpha = R_ALPHA(col);

}
