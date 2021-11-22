/*
 * DSVG device - ClipPath elements
 */
#ifndef DSVG_CLIP_INCLUDED
#define DSVG_CLIP_INCLUDED

void dsvg_clip(double x0, double x1, double y0, double y1, pDevDesc dd);

#if R_GE_version >= 13

SEXP dsvg_set_clip_path(SEXP path, SEXP ref, pDevDesc dd);
void dsvg_release_clip_path(SEXP ref, pDevDesc dd);

#endif // R_GE_version >= 13

#endif // DSVG_CLIP_INCLUDED
