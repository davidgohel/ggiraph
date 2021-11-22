/*
 * DSVG device - Text handling
 */
#ifndef DSVG_TEXT_INCLUDED
#define DSVG_TEXT_INCLUDED

void dsvg_metric_info(int c, const pGEcontext gc, double* ascent,
                      double* descent, double* width, pDevDesc dd);

double dsvg_strwidth_utf8(const char *str, const pGEcontext gc, pDevDesc dd);

double dsvg_strwidth(const char *str, const pGEcontext gc, pDevDesc dd);

void dsvg_text_utf8(double x, double y, const char *str, double rot,
                    double hadj, const pGEcontext gc, pDevDesc dd);

void dsvg_text(double x, double y, const char *str, double rot,
               double hadj, const pGEcontext gc, pDevDesc dd);

#endif // DSVG_TEXT_INCLUDED
