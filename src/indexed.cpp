#include "indexed.h"

INDEX IndexedElements::valid_index(const INDEX index) const {
  return (IS_VALID_INDEX(index) && index <= current_index) ? index : NULL_INDEX;
}

INDEX IndexedElements::valid_index(const SEXP ref) const {
  return valid_index(ref_to_index(ref));
}

const std::string IndexedElements::make_id() const {
  return make_id(current_index);
}

static const std::string EMPTY_STR;

const std::string IndexedElements::make_id(const INDEX index) const {
  return IS_VALID_INDEX(index) ? (prefix + to_string(index)) : EMPTY_STR;
}

const std::string IndexedElements::make_id(const SEXP ref) const {
  return make_id(valid_index(ref));
}

INDEX IndexedElements::get_current_index() const {
  return current_index;
}

INDEX IndexedElements::push(SVGElement* el, const bool& add_id) {
  INDEX ret = NULL_INDEX;
  if (el) {
    current_index++;
    if (add_id)
      set_attr(el, "id", make_id());
    ret = current_index;
  }
  return ret;
}
