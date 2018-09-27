
bool is_bold(int face);
bool is_italic(int face);
bool is_bolditalic(int face);
bool is_symbol(int face);

std::string fontname(const char* family_, int face,
                     Rcpp::List const& system_aliases,
                     Rcpp::List const& user_aliases);
std::string fontfile(const char* family_, int face,
                     Rcpp::List user_aliases);

