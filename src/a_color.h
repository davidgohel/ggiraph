class a_color
{
public:
  a_color (int);
  int is_visible();
  int is_transparent();
  std::string color();
  std::string opacity();

private:
  int col;
  int alpha;
};
