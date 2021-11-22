/*
 * DSVG device - Mask elements
 */
#include "dsvg.h"

#if R_GE_version >= 13

SEXP dsvg_set_mask(SEXP path, SEXP ref, pDevDesc dd) {
  return R_NilValue;
}

void dsvg_release_mask(SEXP ref, pDevDesc dd) {
}

#endif // R_GE_version >= 13
