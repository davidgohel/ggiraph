/*
 * DSVG device - ClipPath elements
 */
#ifndef DSVG_CLIP_INCLUDED
#define DSVG_CLIP_INCLUDED

#include "indexed.h"

/*
 * Class for indexing clip elements
 */
class Clips : public IndexedElements {
public:
  /*
   * Constructor
   *
   * prefix_  The svg canvas id
   */
  Clips(const std::string& prefix_) : IndexedElements(prefix_, "_c") {}

  /*
   * Overload of inherited method
   *
   * key  Optional string key. If specified, the clip index is added to an internal map.
   *      The simple clips (via dsvg_clip) can use this, to avoid duplication of clip definitions.
   */
  INDEX push(SVGElement* el, const char* key = NULL);

  /* Returns the index of a clip with specified key or NULL if not found */
  INDEX find(const std::string& key) const;

  /* Returns a key for the clip, using rect coords */
  static std::string make_key(const double& x0, const double& x1,
                              const double& y0, const double& y1);

private:
  /* map with clip indices by key */
  std::unordered_map<std::string, INDEX> map;
};

void dsvg_clip(double x0, double x1, double y0, double y1, pDevDesc dd);

#if R_GE_version >= 13

SEXP dsvg_set_clip_path(SEXP path, SEXP ref, pDevDesc dd);
void dsvg_release_clip_path(SEXP ref, pDevDesc dd);

#endif // R_GE_version >= 13

#endif // DSVG_CLIP_INCLUDED
