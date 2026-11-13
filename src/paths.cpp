/*
 * DSVG device - Stroking and filling paths
 */
#include "dsvg.h"

#if R_GE_version >= 15

/*
 * Records the shapes drawn by the path function as a single path data
 * string. Returns false if nothing was recorded.
 */
static bool record_path(SEXP path, DSVG_dev* svgd) {
  if (!is_function_ref(path)) return false;
  svgd->path_data.clear();
  svgd->appending_path = true;
  try {
    eval_function_ref(path);
  } catch (...) {
    svgd->appending_path = false;
    throw;
  }
  svgd->appending_path = false;
  return !svgd->path_data.empty();
}

static void draw_path(SEXP path, int rule, const pGEcontext gc, pDevDesc dd,
                      bool fill, bool stroke) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  if (!record_path(path, svgd)) return;

  SVGElement* el = svgd->svg_element("path");
  set_attr(el, "d", svgd->path_data);
  svgd->path_data.clear();
  if (!svgd->should_paint()) return;

  if (fill) {
    set_fill_color_or_pattern(el, gc, svgd);
    set_attr(el, "fill-rule",
             rule == R_GE_evenOddRule ? "evenodd" : "nonzero");
  } else {
    set_attr(el, "fill", "none");
  }
  if (stroke) {
    set_stroke(el, gc->lwd, gc->col, gc->lty, gc->ljoin, gc->lend);
  } else {
    set_attr(el, "stroke", "none");
  }
}

void dsvg_stroke(SEXP path, const pGEcontext gc, pDevDesc dd) {
  draw_path(path, R_GE_nonZeroWindingRule, gc, dd, false, true);
}

void dsvg_fill(SEXP path, int rule, const pGEcontext gc, pDevDesc dd) {
  draw_path(path, rule, gc, dd, true, false);
}

void dsvg_fill_stroke(SEXP path, int rule, const pGEcontext gc, pDevDesc dd) {
  draw_path(path, rule, gc, dd, true, true);
}

#endif // R_GE_version >= 15
