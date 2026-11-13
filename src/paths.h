/*
 * DSVG device - Stroking and filling paths
 */
#ifndef DSVG_PATHS_INCLUDED
#define DSVG_PATHS_INCLUDED

#if R_GE_version >= 15

void dsvg_stroke(SEXP path, const pGEcontext gc, pDevDesc dd);
void dsvg_fill(SEXP path, int rule, const pGEcontext gc, pDevDesc dd);
void dsvg_fill_stroke(SEXP path, int rule, const pGEcontext gc, pDevDesc dd);

#endif // R_GE_version >= 15

#endif // DSVG_PATHS_INCLUDED
