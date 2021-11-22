#include "utils.h"

std::string to_string(const double& d) {
  std::ostringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os.precision(2);
  os << d;
  return os.str();
}

std::string to_string(const int& i) {
  std::ostringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os.precision(0);
  os << i;
  return os.str();
}

pGEDevDesc get_ge_device(int dn) {
  pGEDevDesc dev = NULL;
  // check for valid number because passing dn <= 0 crashes R
  if (dn > 0) {
    dev = GEgetDevice(dn);
  }
  return dev;
}
