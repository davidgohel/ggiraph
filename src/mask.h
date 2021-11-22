/*
 * DSVG device - Mask elements
 */
#ifndef DSVG_MASK_INCLUDED
#define DSVG_MASK_INCLUDED

#if R_GE_version >= 13

SEXP dsvg_set_mask(SEXP path, SEXP ref, pDevDesc dd);
void dsvg_release_mask(SEXP ref, pDevDesc dd);

#endif // R_GE_version >= 13

#endif // DSVG_MASK_INCLUDED
