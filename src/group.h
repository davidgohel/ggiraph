/*
 * DSVG device - Groups and compositing operators
 */
#ifndef DSVG_GROUP_INCLUDED
#define DSVG_GROUP_INCLUDED

#include "indexed.h"

/*
 * Class for indexing group elements
 */
class Groups : public IndexedElements {
public:
  /*
   * Constructor
   *
   * prefix_  The svg canvas id
   */
  Groups(const std::string& prefix_) : IndexedElements(prefix_, "_grp") {}

  /*
   * Filter painting a layer in opaque black, keeping its transparency,
   * used for the masks made of the inverse of the alpha of a layer.
   * It is created only once and this member holds its id.
   */
  std::string black_filter_id;
};

#if R_GE_version >= 15

SEXP dsvg_define_group(SEXP source, int op, SEXP destination, pDevDesc dd);
void dsvg_use_group(SEXP ref, SEXP trans, pDevDesc dd);
void dsvg_release_group(SEXP ref, pDevDesc dd);

/* returns true if dsvg can draw the compositing operator */
bool dsvg_supports_operator(int op);

#endif // R_GE_version >= 15

#endif // DSVG_GROUP_INCLUDED
