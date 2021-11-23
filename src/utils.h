/*
 * Misc utilities
 */
#ifndef DSVG_UTILS_INCLUDED
#define DSVG_UTILS_INCLUDED

#include <Rcpp.h>
#include <string>

// #define DSVG_DEBUG 1
#if defined(DSVG_DEBUG)
#  include <assert.h>
#  define DSVGASSERT assert
#else
#  define DSVGASSERT(x) {}
#endif

/*
 * Conversions to string
 */
std::string to_string(const double& d, const std::streamsize& precision = 2);
std::string to_string(const int& i);
std::string to_string(const unsigned int& i);

/*
 * SVG element numeric index.
 * A valid index starts from 1.
 */
typedef unsigned int INDEX;
#define NULL_INDEX 0
#define IS_VALID_INDEX(i) (i > NULL_INDEX)

/*
 * Helpers to convert between index and references
 */
INDEX ref_to_index(const SEXP& ref);
SEXP index_to_ref(const INDEX& index);

/* Checks if supplied SEXP is a function call */
bool is_function_ref(SEXP& path);

/* Evaluates the function in supplied SEXP */
void eval_function_ref(SEXP& path, SEXP env = R_GlobalEnv);

/* Returns the current graphics engine version */
pGEDevDesc get_ge_device(int dn);

#endif // DSVG_UTILS_INCLUDED
