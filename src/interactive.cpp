/*
 * DSVG device - Interactive elements
 */
#include "dsvg.h"
#include <regex>

INDEX InteractiveElements::push(SVGElement* el) {
  const INDEX index = IndexedElements::push(el);
  if (el) {
    map.insert(std::pair<INDEX, SVGElement*>(index, el));
    if (tracing) {
      if (!initialized) {
        first_index = get_current_index();
        initialized = true;
      }
      last_index = get_current_index();
    }
  }
  return index;
}

SVGElement* InteractiveElements::find(const INDEX index) const {
  SVGElement* ret = NULL;
  std::unordered_map<INDEX, SVGElement*>::const_iterator got = map.find(index);
  if (got != map.end())
    ret = got->second;
  return ret;
}

void InteractiveElements::trace(const bool on) {
  tracing = on;
  initialized = false;
  first_index = NULL_INDEX;
  last_index = NULL_INDEX;
}

// [[Rcpp::export]]
bool set_tracer_on(int dn) {
  pGEDevDesc dev = get_ge_device(dn);
  if (!dev)
    return false;
  DSVG_dev *svgd = (DSVG_dev *) dev->dev->deviceSpecific;
  svgd->interactives.trace(true);
  return true;
}

// [[Rcpp::export]]
bool set_tracer_off(int dn) {
  pGEDevDesc dev = get_ge_device(dn);
  if (!dev)
    return false;
  DSVG_dev *svgd = (DSVG_dev *) dev->dev->deviceSpecific;
  svgd->interactives.trace(false);
  return true;
}

// [[Rcpp::export]]
Rcpp::IntegerVector collect_id(int dn) {
  Rcpp::IntegerVector empty(0);
  pGEDevDesc dev = get_ge_device(dn);
  if (!dev)
    return empty;

  DSVG_dev *svgd = (DSVG_dev *) dev->dev->deviceSpecific;

  INDEX first = svgd->interactives.get_first_index();
  INDEX last = svgd->interactives.get_last_index();
  if (!IS_VALID_INDEX(first) || !IS_VALID_INDEX(last) || first > last) {
    return empty;
  }

  INDEX l_ = 1 + last - first;
  Rcpp::IntegerVector result(l_);
  for (INDEX i = first; i <= last; i++) {
    result[i-first] = (int)i;
  }
  return result;
}

std::string compile_css(const std::string& cls_prefix, const char* cls_suffix,
                        const std::string& canvas_id, const char* data_attr,
                        const char* data_value, const char* css) {
  std::string cls = cls_prefix + cls_suffix + canvas_id + "[" + data_attr + " = \"" + data_value + "\"]";
  std::regex pattern("_CLASSNAME_");
  return std::regex_replace(css, pattern, cls);
}

// [[Rcpp::export]]
bool add_attribute(int dn, std::string name,
                   Rcpp::IntegerVector ids, Rcpp::CharacterVector values) {
  pGEDevDesc dev = get_ge_device(dn);
  if (!dev)
    return false;

  DSVG_dev *svgd = (DSVG_dev *) dev->dev->deviceSpecific;

  std::string hover("hover_css");
  std::string select("select_css");
  std::string cls_prefix("");
  std::string nearest("hover_nearest");
  std::string true_value("TRUE");

  int nb_elts = ids.size();
  for (int i = 0; i < nb_elts; i++) {
    if (values[i].size() == 0)
      continue;

    INDEX index = (INDEX)ids[i];
    SVGElement* el = svgd->interactives.find(index);
    if (el) {
      const bool isHoverNearest = nearest.compare(name) == 0;
      const bool isHoverCss = hover.compare(name) == 0;
      const bool isSelectCss = select.compare(name) == 0;
      if (isHoverCss || isSelectCss) {
        if (isHoverCss) {
          cls_prefix.assign("hover_");
        } else {
          cls_prefix.assign("select_");
        }
        const char * data_id = svg_attribute(el, "data-id");
        if (data_id != NULL) {
          std::string css = compile_css(cls_prefix, "data_", svgd->canvas_id,
                                        "data-id", data_id, values[i]);
          if (css.length() > 0)
            svgd->add_css(std::string(cls_prefix + "_data_id_" + data_id), css);
          continue;
        }
        const char * key_id = svg_attribute(el, "key-id");
        if (key_id != NULL) {
          std::string css = compile_css(cls_prefix, "key_", svgd->canvas_id,
                                        "key-id", key_id, values[i]);
          if (css.length() > 0)
            svgd->add_css(std::string(cls_prefix + "_key_id_" + key_id), css);
          continue;
        }
        const char * theme_id = svg_attribute(el, "theme-id");
        if (theme_id != NULL) {
          std::string css = compile_css(cls_prefix, "theme_", svgd->canvas_id,
                                        "theme-id", theme_id, values[i]);
          if (css.length() > 0)
            svgd->add_css(std::string(cls_prefix + "_theme_id_" + theme_id), css);
          continue;
        }
      } else if (isHoverNearest) {
        if (true_value.compare(values[i]) == 0) {
          set_attr(el, "nearest", "true");
        }
      } else {
        set_attr(el, name.c_str(), values[i]);
      }
    } else {
      Rf_warning("Failed to find element with index %d", index);
    }
  }
  return true;
}
