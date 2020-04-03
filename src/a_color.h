class a_color
{
public:
  a_color (int);
  int is_visible();
  int has_alpha();
  std::string svg_fill_attr();
  std::string svg_stroke_attr();
  int is_transparent();
  std::string color();
  std::string opacity();

private:
  int col;
  int alpha;
};
