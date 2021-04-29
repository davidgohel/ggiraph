#include <systemfonts.h>

bool is_bold(int face);
bool is_italic(int face);
bool is_bolditalic(int face);
bool is_symbol(int face);

std::string fontname(const char* family_, int face, Rcpp::List const& system_aliases);
FontSettings get_font_file(const char* family, int face);
