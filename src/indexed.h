#ifndef DSVG_INDEXED_INCLUDED
#define DSVG_INDEXED_INCLUDED

#include "svg.h"
#include "utils.h"

/*
 * Base class for managing indexed elements
 */
class IndexedElements {
public:
  /*
   * Constructor
   *
   * prefix_  The svg canvas id
   * suffix_  A suffix for the element id
   */
  IndexedElements(const std::string& prefix_, const char* suffix_) :
    current_index(NULL_INDEX), prefix(prefix_ + suffix_) {};

  /*
   * Adds an element to the structure and returns its index.
   * This base implementation only increments the current index,
   * it does not really "add" the element somewhere.
   * Subclasses can add the element to some structure.
   *
   * add_id   If true (default) it assigns an id attribute to the element.
   */
  virtual INDEX push(SVGElement* el, const bool& add_id = true);

  /*
   * Ensures that the passed index is valid (within the bounds).
   * Returns NULL_INDEX otherwise
   */
  INDEX valid_index(const INDEX index) const;

  /* Overload with an index reference */
  INDEX valid_index(const SEXP ref) const;

  /*
   * Returns an id for an element, specified by index
   */
  const std::string make_id(const INDEX index) const;

  /* Overload with an index reference */
  const std::string make_id(const SEXP ref) const;

  /* Overload with current last index */
  const std::string make_id() const;

  /* returns the current index */
  INDEX get_current_index() const;

private:
  /* The current index */
  INDEX current_index;

  /* The prefix used for ids */
  const std::string prefix;
};

#endif // DSVG_INDEXED_INCLUDED
