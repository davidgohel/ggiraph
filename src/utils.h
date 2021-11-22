/*
 * Misc utilities
 */
#ifndef DSVG_UTILS_INCLUDED
#define DSVG_UTILS_INCLUDED

#include <Rcpp.h>
#include <string>

/*
 * Conversions to string
 */
std::string to_string(const double& d);
std::string to_string(const int& i);

/* Returns the current graphics engine version */
pGEDevDesc get_ge_device(int dn);

#endif // DSVG_UTILS_INCLUDED
