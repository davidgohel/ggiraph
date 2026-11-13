/*
 * DSVG device - Groups and compositing operators
 *
 * A group is drawn by R in two layers: the destination, then the source
 * composited on the destination with an operator. Both layers are written
 * once in the defs, as <g> elements, and the group is a <g> (in the defs
 * too, isolated) that combines them with <use> elements:
 *
 * - the blend modes ("multiply", "screen"...) use the CSS property
 *   mix-blend-mode on the source;
 * - the Porter-Duff operators ("in", "out", "atop", "xor"...) are written
 *   with masks made of the alpha of the other layer (alpha or 1 - alpha);
 *   the two terms of a sum ("atop", "dest.atop", "xor", "add") are added
 *   with mix-blend-mode: plus-lighter;
 * - "saturate" has no equivalent and is drawn as "over", with a warning.
 *
 * dsvg_use_group() draws a group with a <use> element, with the
 * transformation given by R.
 */
#include "dsvg.h"
#include "geom.h"
#include <vector>

#if R_GE_version >= 15

std::string& dsvg_alpha_filter(DSVG_dev *svgd);

namespace {

enum Layer { SOURCE, DESTINATION };
enum MaskKind { NO_MASK, ALPHA, INVERSE_ALPHA };

/* one <use> of a layer in the composition of a group */
struct Part {
  Layer layer;
  MaskKind mask;
  const char* blend;
};

const char* blend_mode(int op) {
  switch (op) {
  case R_GE_compositeMultiply: return "multiply";
  case R_GE_compositeScreen: return "screen";
  case R_GE_compositeOverlay: return "overlay";
  case R_GE_compositeDarken: return "darken";
  case R_GE_compositeLighten: return "lighten";
  case R_GE_compositeColorDodge: return "color-dodge";
  case R_GE_compositeColorBurn: return "color-burn";
  case R_GE_compositeHardLight: return "hard-light";
  case R_GE_compositeSoftLight: return "soft-light";
  case R_GE_compositeDifference: return "difference";
  case R_GE_compositeExclusion: return "exclusion";
  default: return NULL;
  }
}

const char* PLUS = "plus-lighter";

/*
 * The parts of the composition of an operator, in drawing order.
 * A mask is made of the alpha of the other layer.
 */
std::vector<Part> composition(int op) {
  const char* blend = blend_mode(op);
  if (blend) {
    return {{DESTINATION, NO_MASK, NULL}, {SOURCE, NO_MASK, blend}};
  }
  switch (op) {
  case R_GE_compositeClear:
    return {};
  case R_GE_compositeSource:
    return {{SOURCE, NO_MASK, NULL}};
  case R_GE_compositeIn:
    return {{SOURCE, ALPHA, NULL}};
  case R_GE_compositeOut:
    return {{SOURCE, INVERSE_ALPHA, NULL}};
  case R_GE_compositeAtop:
    return {{DESTINATION, INVERSE_ALPHA, NULL}, {SOURCE, ALPHA, PLUS}};
  case R_GE_compositeDest:
    return {{DESTINATION, NO_MASK, NULL}};
  case R_GE_compositeDestOver:
    return {{SOURCE, NO_MASK, NULL}, {DESTINATION, NO_MASK, NULL}};
  case R_GE_compositeDestIn:
    return {{DESTINATION, ALPHA, NULL}};
  case R_GE_compositeDestOut:
    return {{DESTINATION, INVERSE_ALPHA, NULL}};
  case R_GE_compositeDestAtop:
    return {{SOURCE, INVERSE_ALPHA, NULL}, {DESTINATION, ALPHA, PLUS}};
  case R_GE_compositeXor:
    return {{SOURCE, INVERSE_ALPHA, NULL}, {DESTINATION, INVERSE_ALPHA, PLUS}};
  case R_GE_compositeAdd:
    return {{DESTINATION, NO_MASK, NULL}, {SOURCE, NO_MASK, PLUS}};
  default: // over, and saturate drawn as over
    return {{DESTINATION, NO_MASK, NULL}, {SOURCE, NO_MASK, NULL}};
  }
}

void set_href(SVGElement* el, const std::string& id, DSVG_dev* svgd) {
  set_attr(el, "xlink:href", "#" + id);
  if (svgd->standalone)
    set_attr(el, "xmlns:xlink", "http://www.w3.org/1999/xlink");
}

/* a layer drawn by an R function in a <g> of the defs */
void define_layer(SEXP fun, const std::string& id, DSVG_dev* svgd) {
  SVGElement* g = svgd->svg_definition("g");
  set_attr(g, "id", id);
  svgd->push_definition(g, true, true);
  eval_function_ref(fun);
  svgd->pop_definition();
}

/* filter painting its input in opaque black, keeping the transparency */
const std::string& black_filter(DSVG_dev* svgd) {
  std::string& filter_id = svgd->groups.black_filter_id;
  if (filter_id.empty()) {
    SVGElement* filter = svgd->svg_definition("filter");
    filter_id = svgd->canvas_id + "_filter_black";
    set_attr(filter, "id", filter_id);
    set_attr(filter, "filterUnits", "objectBoundingBox");
    set_attr(filter, "x", "0%");
    set_attr(filter, "y", "0%");
    set_attr(filter, "width", "100%");
    set_attr(filter, "height", "100%");
    SVGElement* matrix = svgd->svg_element("feColorMatrix", filter);
    set_attr(matrix, "type", "matrix");
    set_attr(matrix, "in", "SourceGraphic");
    set_attr(matrix, "values", "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0");
  }
  return filter_id;
}

/* sets a region covering the content, wherever it is drawn */
void set_large_region(SVGElement* el, DSVG_dev* svgd) {
  set_attr(el, "x", -svgd->width);
  set_attr(el, "y", -svgd->height);
  set_attr(el, "width", 3 * svgd->width);
  set_attr(el, "height", 3 * svgd->height);
}

/*
 * A luminance mask whose value is the alpha of a layer (the layer painted
 * in white) or 1 - alpha (the layer painted in black over a white
 * rectangle).
 */
void define_alpha_mask(const std::string& id, const std::string& layer_id,
                       bool inverse, DSVG_dev* svgd) {
  SVGElement* mask = svgd->svg_definition("mask");
  set_attr(mask, "id", id);
  set_attr(mask, "maskUnits", "userSpaceOnUse");
  set_large_region(mask, svgd);
  if (inverse) {
    SVGElement* rect = svgd->svg_element("rect", mask);
    set_large_region(rect, svgd);
    set_attr(rect, "fill", "#FFFFFF");
  }
  SVGElement* use = svgd->svg_element("use", mask);
  set_href(use, layer_id, svgd);
  set_filter_ref(use, inverse ? black_filter(svgd) : dsvg_alpha_filter(svgd));
}

} // namespace

bool dsvg_supports_operator(int op) {
  return op != R_GE_compositeSaturate;
}

SEXP dsvg_define_group(SEXP source, int op, SEXP destination, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  if (!dsvg_supports_operator(op)) {
    Rf_warning("The compositing operator 'saturate' is not supported by dsvg, 'over' is used instead.");
  }

  SVGElement* group = svgd->svg_definition("g");
  const INDEX index = svgd->groups.push(group, true);
  const std::string id = svgd->groups.make_id(index);
  // blending and compositing only apply inside the group
  set_attr(group, "style", "isolation:isolate");

  const bool has_source = is_function_ref(source);
  const bool has_destination = is_function_ref(destination);
  const std::vector<Part> parts = composition(op);

  // layers: drawn once, only if used
  bool use_source = false, use_destination = false;
  for (const Part& part : parts) {
    if (part.layer == SOURCE || part.mask != NO_MASK) use_source = true;
    if (part.layer == DESTINATION || part.mask != NO_MASK) use_destination = true;
  }
  const std::string source_id = id + "_s";
  const std::string destination_id = id + "_d";
  // the destination is drawn first, as R does
  use_destination = use_destination && has_destination;
  use_source = use_source && has_source;
  if (use_destination) define_layer(destination, destination_id, svgd);
  if (use_source) define_layer(source, source_id, svgd);

  for (const Part& part : parts) {
    const bool on_source = part.layer == SOURCE;
    if (on_source ? !use_source : !use_destination) continue;

    std::string mask_id;
    if (part.mask != NO_MASK) {
      const bool other_exists = on_source ? use_destination : use_source;
      const bool inverse = part.mask == INVERSE_ALPHA;
      if (!other_exists) {
        // the other layer is empty: alpha is 0 everywhere
        if (!inverse) continue;
      } else {
        const std::string& other_id = on_source ? destination_id : source_id;
        mask_id = other_id + (inverse ? "_ia" : "_a");
        define_alpha_mask(mask_id, other_id, inverse, svgd);
      }
    }

    SVGElement* use = svgd->svg_element("use", group);
    set_href(use, on_source ? source_id : destination_id, svgd);
    if (!mask_id.empty()) set_mask_ref(use, mask_id);
    if (part.blend) {
      set_attr(use, "style", std::string("mix-blend-mode:") + part.blend);
    }
  }

  return index_to_ref(index);
}

void dsvg_use_group(SEXP ref, SEXP trans, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  const INDEX index = svgd->groups.valid_index(ref);
  if (!IS_VALID_INDEX(index)) {
    Rf_warning("Unknown group");
    return;
  }
  SVGElement* use = svgd->svg_element("use");
  set_href(use, svgd->groups.make_id(index), svgd);
  if (!Rf_isNull(trans)) {
    // R gives X = t[0] x + t[1] y + t[2] and Y = t[3] x + t[4] y + t[5]
    const double* t = REAL(trans);
    AffineTransform transform(t[0], t[3], t[1], t[4], t[2], t[5]);
    set_attr(use, "transform", transform.to_string());
  }
}

void dsvg_release_group(SEXP ref, pDevDesc dd) {
  // nothing to do: the definitions stay in the document
}

#endif // R_GE_version >= 15
