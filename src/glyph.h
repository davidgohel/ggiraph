/*
 * DSVG device - Glyphs
 */
#ifndef DSVG_GLYPH_INCLUDED
#define DSVG_GLYPH_INCLUDED

#if R_GE_version >= 16

void dsvg_glyph(int n, int *glyphs, double *x, double *y,
                SEXP font, double size,
                int colour, double rot, pDevDesc dd);

#endif // R_GE_version >= 16

#endif // DSVG_GLYPH_INCLUDED
