/*
 * DSVG device - ClipPath elements
 */
#include "dsvg.h"

INDEX Clips::push(SVGElement* el, const char* key) {
  const INDEX index = IndexedElements::push(el, true);
  if (el && key) {
    map.insert(std::pair<std::string, INDEX>(key, index));
  }
  return index;
}

INDEX Clips::find(const std::string& key) const {
  std::unordered_map<std::string, INDEX>::const_iterator got = map.find(key);
  if (got == map.end())
    return 0;
  else
    return got->second;
}

std::string Clips::make_key(const double& x0, const double& x1,
                            const double& y0, const double& y1) {
  const double left = fmin(x0, x1);
  const double right = fmax(x0, x1);
  const double top = fmin(y0, y1);
  const double bottom = fmax(y0, y1);
  std::ostringstream os;
  os.flags(std::ios_base::fixed | std::ios_base::dec);
  os.precision(2);
  os << left << "|" << right << "|" << top << "|" << bottom;
  return os.str();
}

void dsvg_clip(double x0, double x1, double y0, double y1, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;

  // create a key with the coords
  const std::string key = Clips::make_key(x0, x1, y0, y1);
  // try to find an existing clip with this key
  INDEX clip_index = svgd->clips.find(key);

  if (!IS_VALID_INDEX(clip_index)) {
    // create new clip
    SVGElement* clip = svgd->svg_definition("clipPath");
    // add it to the clips
    clip_index = svgd->clips.push(clip, key.c_str());
    // push a simple definition context
    svgd->push_definition(clip, false, false);
    // draw the clip
    dsvg_rect(x0, y0, x1, y1, NULL, dd);
    // exit definition context
    svgd->pop_definition();
  }

  svgd->use_clip(clip_index);
}

#if R_GE_version >= 13

SEXP dsvg_set_clip_path(SEXP path, SEXP ref, pDevDesc dd) {
  DSVG_dev *svgd = (DSVG_dev*) dd->deviceSpecific;
  SEXP newref = R_NilValue;

  // try the passed reference
  INDEX clip_index = svgd->clips.valid_index(ref);
  if (!IS_VALID_INDEX(clip_index) && is_function_ref(path)) {
    // create new clip
    SVGElement* clip = svgd->svg_definition("clipPath");
    clip_index = svgd->clips.push(clip);
    newref = index_to_ref(clip_index);
    // push a simple definition context
    svgd->push_definition(clip, false, false);
    // draw the clip by calling the passed path function
    eval_function_ref(path);
    // exit definition context
    svgd->pop_definition();
  }

  svgd->use_clip(clip_index);
  return newref;
}

void dsvg_release_clip_path(SEXP ref, pDevDesc dd) {
  // nothing to do here
}

#endif // R_GE_version >= 13
