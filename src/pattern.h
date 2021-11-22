/*
 * DSVG device - Pattern elements
 */
#ifndef DSVG_PATTERN_INCLUDED
#define DSVG_PATTERN_INCLUDED

#if R_GE_version >= 13

SEXP dsvg_set_pattern(SEXP pattern, pDevDesc dd);
void dsvg_release_pattern(SEXP ref, pDevDesc dd);

#endif // R_GE_version >= 13

#endif // DSVG_PATTERN_INCLUDED
