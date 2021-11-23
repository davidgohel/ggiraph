/*
 * DSVG device - Pattern elements
 */
#include "dsvg.h"
#include "geom.h"

#if R_GE_version >= 13

const char* pattern_spread_method[3] = {
  "pad", // R_GE_patternExtendPad
  "repeat", // R_GE_patternExtendRepeat
  "reflect" // R_GE_patternExtendReflect
};

INDEX dsvg_linear_gradient(SEXP gradient, DSVG_dev *svgd) {
  SVGElement* lg = svgd->svg_definition("linearGradient");
  const INDEX pattern_index = svgd->patterns.push(lg, true);

  // element attributes
  set_attr(lg, "x1", R_GE_linearGradientX1(gradient));
  set_attr(lg, "y1", R_GE_linearGradientY1(gradient));
  set_attr(lg, "x2", R_GE_linearGradientX2(gradient));
  set_attr(lg, "y2", R_GE_linearGradientY2(gradient));
  set_attr(lg, "gradientUnits", "userSpaceOnUse");
  const int extend = R_GE_linearGradientExtend(gradient) - 1;
  if (extend >= 0 && extend < 3) {
    set_attr(lg, "spreadMethod", pattern_spread_method[extend]);
  }

  // element children
  const int stopcnt = R_GE_linearGradientNumStops(gradient);
  for (int i = 0; i < stopcnt; i++) {
    SVGElement* stop_el = svgd->svg_element("stop", lg);
    set_attr(stop_el, "offset", R_GE_linearGradientStop(gradient, i));
    set_stop_color(stop_el, R_GE_linearGradientColour(gradient, i));
  }

  return pattern_index;
}

INDEX dsvg_radial_gradient(SEXP gradient, DSVG_dev *svgd) {
  SVGElement* rg = svgd->svg_definition("radialGradient");
  const INDEX pattern_index = svgd->patterns.push(rg, true);

  // element attributes
  set_attr(rg, "fx", R_GE_radialGradientCX1(gradient));
  set_attr(rg, "fy", R_GE_radialGradientCY1(gradient));
  set_attr(rg, "fr", R_GE_radialGradientR1(gradient));
  set_attr(rg, "cx", R_GE_radialGradientCX2(gradient));
  set_attr(rg, "cy", R_GE_radialGradientCY2(gradient));
  set_attr(rg, "r", R_GE_radialGradientR2(gradient));
  set_attr(rg, "gradientUnits", "userSpaceOnUse");
  const int extend = R_GE_radialGradientExtend(gradient) - 1;
  if (extend >= 0 && extend < 3) {
    set_attr(rg, "spreadMethod", pattern_spread_method[extend]);
  }

  // element children
  const int stopcnt = R_GE_radialGradientNumStops(gradient);
  SVGElement* stop_el = NULL;
  for (int i = 0; i < stopcnt; i++) {
    stop_el = svgd->svg_element("stop", rg);
    set_attr(stop_el, "offset", R_GE_radialGradientStop(gradient, i));
    set_stop_color(stop_el, R_GE_radialGradientColour(gradient, i));
  }

  return pattern_index;
}

INDEX dsvg_tiling_pattern(SEXP pattern, DSVG_dev *svgd) {
  INDEX pattern_index = NULL_INDEX;
  // validate the pattern func
  SEXP path = R_GE_tilingPatternFunction(pattern);
  if (is_function_ref(path)) {
    SVGElement* tp = svgd->svg_definition("pattern");
    pattern_index = svgd->patterns.push(tp, true);
    // push definition context, organized in g elements
    svgd->push_definition(tp, true, true);
    // draw the pattern by calling the passed path function
    eval_function_ref(path);

    // element attributes
    set_attr(tp, "width", svgd->width);
    set_attr(tp, "height", svgd->height);
    set_attr(tp, "patternUnits", "userSpaceOnUse");

    // set the pattern transform
    AffineTransform t;
    t.translate(R_GE_tilingPatternX(pattern),
                R_GE_tilingPatternY(pattern));
    t.scale(R_GE_tilingPatternWidth(pattern)/svgd->width,
            R_GE_tilingPatternHeight(pattern)/svgd->height);
    set_attr(tp, "patternTransform", t.to_string());

    // set the inverse transform to the pattern elements
    const std::string transform = t.inverse().to_string();
    SVGElement* child = (SVGElement*)tp->FirstChild();
    while (child) {
      set_attr(child, "transform", transform);
      child = (SVGElement*)child->NextSibling();
    }

    // exit definition context
    svgd->pop_definition();
  }
  return pattern_index;
}

SEXP dsvg_set_pattern(SEXP pattern, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  SEXP newref = R_NilValue;

  if (R_GE_isPattern(pattern)) {
    // create new pattern
    INDEX pattern_index = NULL_INDEX;
    switch(R_GE_patternType(pattern)) {
    case R_GE_linearGradientPattern:
      pattern_index = dsvg_linear_gradient(pattern, svgd);
      break;
    case R_GE_radialGradientPattern:
      pattern_index = dsvg_radial_gradient(pattern, svgd);
      break;
    case R_GE_tilingPattern:
      pattern_index = dsvg_tiling_pattern(pattern, svgd);
      break;
    }
    // set the ref from new index
    newref = index_to_ref(pattern_index);
  }
  return newref;
}

void dsvg_release_pattern(SEXP ref, pDevDesc dd) {
  // nothing to do here
}

#endif // R_GE_version >= 13
