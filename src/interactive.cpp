/*
 * DSVG device - Interactive elements
 */
#include "dsvg.h"
#include <regex>

// [[Rcpp::export]]
bool set_tracer_on(int dn) {
  pGEDevDesc dev = get_ge_device(dn);
  if (!dev)
    return false;
  DSVG_dev *svgd = (DSVG_dev *) dev->dev->deviceSpecific;
  svgd->set_tracer_on();
  return true;
}

// [[Rcpp::export]]
bool set_tracer_off(int dn) {
  pGEDevDesc dev = get_ge_device(dn);
  if (!dev)
    return false;
  DSVG_dev *svgd = (DSVG_dev *) dev->dev->deviceSpecific;
  svgd->set_tracer_off();
  return true;
}

// [[Rcpp::export]]
Rcpp::IntegerVector collect_id(int dn) {
  Rcpp::IntegerVector empty(0);
  pGEDevDesc dev = get_ge_device(dn);
  if (!dev)
    return empty;

  DSVG_dev *svgd = (DSVG_dev *) dev->dev->deviceSpecific;

  int first = svgd->tracer_first_elt;
  int last = svgd->tracer_last_elt;
  if (first < 0 || last < 0 || first > last) {
    return empty;
  }

  int l_ = 1 + last - first;
  Rcpp::IntegerVector result(l_);
  for (int i = first; i <= last; i++) {
    result[i-first] = i;
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
  std::string selected("selected_css");
  std::string cls_prefix("");

  int nb_elts = ids.size();
  for (int i = 0; i < nb_elts; i++) {
    if (values[i].size() == 0)
      continue;

    SVGElement* el = svgd->get_svg_element(ids[i]);
    if (el) {
      const bool isHoverCss = hover.compare(name) == 0;
      const bool isSelectedCss = selected.compare(name) == 0;
      if (isHoverCss || isSelectedCss) {
        if (isHoverCss) {
          cls_prefix.assign("hover_");
        } else {
          cls_prefix.assign("selected_");
        }
        const char * data_id = svg_attribute(el, "data-id");
        if (data_id != NULL) {
          std::string css = compile_css(cls_prefix, "", svgd->canvas_id,
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
      } else {
        set_attr(el, name.c_str(), values[i]);
      }
    }
  }
  return true;
}
