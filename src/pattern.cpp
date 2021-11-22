/*
 * DSVG device - Pattern elements
 */
#include "dsvg.h"

#if R_GE_version >= 13

SEXP dsvg_set_pattern(SEXP pattern, pDevDesc dd) {
  return R_NilValue;
}

void dsvg_release_pattern(SEXP ref, pDevDesc dd) {
}

#endif // R_GE_version >= 13
