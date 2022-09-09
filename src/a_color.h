#ifndef DSVG_COLOR_INCLUDED
#define DSVG_COLOR_INCLUDED

#include <string>

class a_color {
public:
  a_color (int);
  bool is_visible();
  std::string color();
  std::string opacity();

private:
  int col;
  int alpha;
};

#endif // DSVG_COLOR_INCLUDED
