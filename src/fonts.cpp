#include "Rcpp.h"
#include <systemfonts.h>

bool is_bold(int face) {
  return face == 2 || face == 4;
}
bool is_italic(int face) {
  return face == 3 || face == 4;
}

bool is_bolditalic(int face) {
  return face == 4;
}

bool is_symbol(int face) {
  return face == 5;
}





inline std::string find_system_alias(std::string& family,
                                     Rcpp::List const& aliases) {
  std::string out;
  if (aliases.containsElementNamed(family.c_str())) {
    SEXP alias = aliases[family];
    if (TYPEOF(alias) == STRSXP && Rf_length(alias) == 1)
      out = Rcpp::as<std::string>(alias);
  }
  return out;
}

std::string fontname(const char* family_, int face, Rcpp::List const& system_aliases) {

  std::string family(family_);
  if (face == 5)
    family = "symbol";
  else if (family == "")
    family = "sans";

  std::string alias = find_system_alias(family, system_aliases);

  if (alias.size())
    return alias;
  else
    return family;
}

// This code has been copied from the package svglite maintained by Thomas Lin Pedersen
FontSettings get_font_file(const char* family, int face) {
  const char* fontfamily = family;
  if (is_symbol(face)) {
    fontfamily = "symbol";
  } else if (strcmp(family, "") == 0) {
    fontfamily = "sans";
  }

  return locate_font_with_features(fontfamily, is_italic(face), is_bold(face));
}


