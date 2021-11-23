/*
 * DSVG device - Mask elements
 */
#ifndef DSVG_MASK_INCLUDED
#define DSVG_MASK_INCLUDED

#include "indexed.h"

/*
 * Class for indexing mask elements
 */
class Masks : public IndexedElements {
public:
  /*
   * Constructor
   *
   * prefix_  The svg canvas id
   */
  Masks(const std::string& prefix_) : IndexedElements(prefix_, "_m") {}

  /*
   * Each mask needs a translucent filter.
   * It is created only once and this member holds its id.
   */
  std::string alpha_filter_id;
};

#if R_GE_version >= 13

SEXP dsvg_set_mask(SEXP path, SEXP ref, pDevDesc dd);
void dsvg_release_mask(SEXP ref, pDevDesc dd);

#endif // R_GE_version >= 13

#endif // DSVG_MASK_INCLUDED
