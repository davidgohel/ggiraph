/*
 * DSVG device - Mask elements
 */
#include "dsvg.h"

#if R_GE_version >= 13

std::string& dsvg_alpha_filter(DSVG_dev *svgd) {
  // try the stored index
  std::string& filter_id = svgd->masks.alpha_filter_id;

  // create alpha filter
  if (filter_id.empty()) {
    SVGElement* filter = svgd->svg_definition("filter");
    filter_id.append(svgd->canvas_id).append("_filter_alpha");
    set_attr(filter, "id", filter_id);
    svgd->masks.alpha_filter_id = filter_id;

    set_attr(filter, "filterUnits", "objectBoundingBox");
    set_attr(filter, "x", "0%");
    set_attr(filter, "y", "0%");
    set_attr(filter, "width", "100%");
    set_attr(filter, "height", "100%");

    SVGElement* feColorMatrix = svgd->svg_element("feColorMatrix", filter);
    set_attr(feColorMatrix, "type", "matrix");
    set_attr(feColorMatrix, "in", "SourceGraphic");
    set_attr(feColorMatrix, "values", "0 0 0 0 1 0 0 0 0 1 0 0 0 0 1 0 0 0 1 0");
  }

  return filter_id;
}

SEXP dsvg_set_mask(SEXP path, SEXP ref, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  SEXP newref = R_NilValue;

  // try the passed reference
  INDEX mask_index = svgd->masks.valid_index(ref);

  if (!IS_VALID_INDEX(mask_index) && is_function_ref(path)) {
    // create new mask
    SVGElement* mask = svgd->svg_definition("mask");
    mask_index = svgd->masks.push(mask, true);
    newref = index_to_ref(mask_index);
    // push definition context, organized in g elements
    svgd->push_definition(mask, true, true);
    // draw the mask by calling the passed path function
    eval_function_ref(path);

    // set the alpha filter to mask's elements
    std::string& filter_id = dsvg_alpha_filter(svgd);
    if (!filter_id.empty()) {
      SVGElement* child = (SVGElement*)mask->FirstChild();
      while (child) {
        set_filter_ref(child, filter_id);
        child = (SVGElement*)child->NextSibling();
      }
    }

    // exit definition context
    svgd->pop_definition();
  }

  svgd->use_mask(mask_index);
  return newref;
}

void dsvg_release_mask(SEXP ref, pDevDesc dd) {
  // nothing to do here
}

#endif // R_GE_version >= 13
