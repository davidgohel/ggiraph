/*
 * DSVG device - Interactive elements
 */
#ifndef DSVG_INTERACTIVE_INCLUDED
#define DSVG_INTERACTIVE_INCLUDED

#include "indexed.h"

/*
 * Class for indexing interactive elements
 */
class InteractiveElements : public IndexedElements {
public:
  /*
   * Constructor
   *
   * prefix_  The svg canvas id
   */
  InteractiveElements(const std::string& prefix_) :
    IndexedElements(prefix_, "_e") { trace(false); }

  /* Overload of base method */
  INDEX push(SVGElement* el);

  /* Returns an element with specified index or NULL if not found */
  SVGElement* find(const INDEX index) const;

  /* Enables/disables the tracing of element ids */
  void trace(const bool onoff);

  /* Returns the tracer status */
  bool is_tracing() const {
    return tracing;
  };

  /* Returns the index of the first tracked element */
  INDEX get_first_index() const {
    return first_index;
  };

  /* Returns the index of the last tracked element */
  INDEX get_last_index() const {
    return last_index;
  };

private:
  /* A map with all elements by index */
  std::unordered_map<INDEX, SVGElement*> map;

  /* tracing vars */
  bool tracing;
  bool initialized;
  INDEX first_index;
  INDEX last_index;
};

#endif // DSVG_INTERACTIVE_INCLUDED
