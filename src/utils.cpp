#include "utils.h"

std::string to_string(const double& d, const std::streamsize& precision) {
  std::ostringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os.precision(precision);
  os << std::noshowpoint << d;
  // remove trailing zeros
  std::string str(os.str());
  const std::string::size_type sep_pos = str.find_first_of(".,");
  if (sep_pos != std::string::npos) {
    const std::string::size_type last_zero_pos = str.find_last_of('0');
    const std::string::size_type last_not_zero_pos = str.find_last_not_of('0');
    if (last_not_zero_pos == sep_pos) {
      str.erase(sep_pos);
    } else if (
        last_zero_pos != std::string::npos &&
          last_not_zero_pos != std::string::npos &&
          sep_pos < last_zero_pos && last_not_zero_pos < last_zero_pos) {
      str.erase(last_not_zero_pos + 1);
    }
  }
  return str;
}

std::string to_string(const int& i) {
  std::ostringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os.precision(0);
  os << i;
  return os.str();
}

std::string to_string(const unsigned int& i) {
  std::ostringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os.precision(0);
  os << i;
  return os.str();
}

INDEX ref_to_index(const SEXP& ref) {
  Rcpp::RObject o(ref);
  if (o.sexp_type() == INTSXP) {
    Rcpp::IntegerVector v = Rcpp::as<Rcpp::IntegerVector>(o);
    if (v.size() == 1)
      return Rcpp::as<Rcpp::IntegerVector>(o)[0];
  }
  return NULL_INDEX;
}

SEXP index_to_ref(const INDEX& index) {
  SEXP ret = R_NilValue;
  if (IS_VALID_INDEX(index)) {
    Rcpp::IntegerVector v(1);
    v[0] = (int)index;
    ret = v;
  }
  return ret;
}

pGEDevDesc get_ge_device(int dn) {
  pGEDevDesc dev = NULL;
  // check for valid number because passing dn <= 0 crashes R
  if (dn > 0) {
    dev = GEgetDevice(dn);
  }
  return dev;
}
