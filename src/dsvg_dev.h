/*
 * DSVG device - Device specific data handling
 */
#ifndef DSVG_DEV_INCLUDED
#define DSVG_DEV_INCLUDED

#include "svg.h"
#include "utils.h"

/*
 * Class for handling device specific data
 */
class DSVG_dev {
public:
  FILE *file;
  std::string filename;
  int pageno;
  std::string canvas_id;
  int element_index;
  std::string element_id;
  int clip_index;
  std::string clip_id;
  double clipleft, clipright, cliptop, clipbottom;
  bool standalone;
  bool setdims;
  /*   */
  int tracer_first_elt;
  int tracer_last_elt;
  int tracer_on;
  int tracer_is_init;

  Rcpp::List system_aliases;

  DSVG_dev(std::string filename_, bool standalone_, bool setdims_,
           std::string canvas_id_,
           int bg_,
           Rcpp::List& aliases_,
           double width_, double height_ ):
    filename(filename_),
    pageno(0),
    canvas_id(canvas_id_),
    element_index(0),
    element_id(canvas_id_ + "_el_0"),
    clip_index(0),
    clip_id(canvas_id_ + "_cl_0"),
    standalone(standalone_),
    setdims(setdims_),
    tracer_first_elt(-1),
    tracer_last_elt(-1),
    tracer_on(0),
    tracer_is_init(0),
    system_aliases(Rcpp::wrap(aliases_["system"])) {
    file = fopen(R_ExpandFileName(filename.c_str()), "w");
    clipleft = 0.0;
    clipright = width_;
    cliptop = 0.0;
    clipbottom = height_;
    doc_ = 0;
    root_ = 0;
    root_g_ = 0;
    element_map_ = 0;
    css_map_ = 0;
  }

  bool ok() const {
    return file != NULL;
  }

  void new_element() {
    element_index++;
    element_id.assign(canvas_id + "_el_" + to_string(element_index));
    register_element();
  }

  void new_clip() {
    clip_index++;
    clip_id.assign(canvas_id + "_cl_" + to_string(clip_index));
  }

  void set_tracer_on(){
    tracer_on = 1;
    tracer_is_init = 0;
    tracer_first_elt = -1;
    tracer_last_elt = -1;
  }

  void set_tracer_off(){
    tracer_on = 0;
    tracer_is_init = 0;
    tracer_first_elt = -1;
    tracer_last_elt = -1;
  }

  void register_element() {
    if( tracer_on > 0 ){
      if( tracer_is_init < 1 ){
        tracer_first_elt = element_index;
        tracer_is_init = 1;
      }
      tracer_last_elt = element_index;
    }
  }

  SVGElement* svg_root() {
    if (doc_)
      return root_;
    this->doc_ = new_svg_doc(standalone, false);
    this->root_ = svg_element("svg", false, (SVGElement*)doc_);
    if (standalone){
      set_attr(root_, "xmlns", "http://www.w3.org/2000/svg");
      set_attr(root_, "xmlns:xlink", "http://www.w3.org/1999/xlink");
    }
    this->root_g_ = svg_element("g", false, root_);
    this->element_map_ = new std::unordered_map<int, SVGElement*>();
    this->css_map_ = new std::unordered_map<std::string, std::string>();
    return root_;
  }

  SVGElement* svg_element(const char* name, const bool track, SVGElement* parent = NULL) {
    SVGElement* el = new_svg_element(name, doc_);
    if (parent) {
      append_element(el, parent);
    } else {
      append_element(el, root_g_);
    }
    if (track) {
      element_map_->insert(std::pair<int, SVGElement*>(element_index, el));
    }
    return el;
  }

  SVGText* svg_text(const char* str, SVGElement* parent = NULL, const bool cdata = true) {
    SVGText* el = new_svg_text(str, doc_, cdata);
    if (parent) {
      append_element((SVGElement*)el, parent);
    } else {
      append_element((SVGElement*)el, root_g_);
    }
    return el;
  }

  SVGElement* get_svg_element(const int id) {
    std::unordered_map<int, SVGElement*>::const_iterator got = element_map_->find(id);
    if ( got == element_map_->end() )
      return NULL;
    else
      return got->second;
  }

  void add_css(const std::string key, const std::string value) {
    css_map_->insert(std::pair<std::string, std::string>(key, value));
  }

  ~DSVG_dev() {
    if (ok()) {
      if (doc_) {
        add_styles();
        svg_to_file(doc_, file, false);
        delete(element_map_);
        delete(css_map_);
        delete(doc_);
      }
      fclose(file);
    }
  }

private:
  SVGDocument* doc_;
  SVGElement* root_;
  SVGElement* root_g_;
  std::unordered_map<int, SVGElement*>* element_map_;
  std::unordered_map<std::string, std::string>* css_map_;

  void add_styles() {
    if (css_map_->size() > 0) {
      SVGElement* styleEl = new_svg_element("style", doc_);
      prepend_element(styleEl, root_);
      std::stringstream os;
      for ( auto it = css_map_->begin(); it != css_map_->end(); ++it ) {
        os << it->second;
      }
      svg_text(os.str().c_str(), styleEl, true);
    }
  }
};

#endif // DSVG_DEV_INCLUDED
