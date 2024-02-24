#include "dsvg_dev.h"

#define CHECK_STACK_NOT_EMPTY(note) \
  if (contexts->size() < 1) Rf_error("Invalid contexts stack state (%s)", note);

DSVG_dev::DSVG_dev(std::string filename_,
                   double width_, double height_,
                   std::string canvas_id_,
                   std::string title_, std::string desc_,
                   bool standalone_, bool setdims_,
                   Rcpp::List& aliases_):
    filename(filename_),
    width(width_),
    height(height_),
    canvas_id(canvas_id_),
    title(title_),
    desc(desc_),
    standalone(standalone_),
    setdims(setdims_),
    system_aliases(Rcpp::wrap(aliases_["system"])),
    interactives(canvas_id_),
    clips(canvas_id_),
    masks(canvas_id_),
    patterns(canvas_id_) {

  file = fopen(R_ExpandFileName(filename.c_str()), "w");
  if (!file) Rf_error("Failed to open file for writing: \"%s\"", filename.c_str());

  doc = NULL;
  root = NULL;
  root_g = NULL;
  root_defs = NULL;
  contexts = NULL;
  css_map = NULL;
}

DSVG_dev::~DSVG_dev() {
  if (doc) {
    add_styles();
    svg_to_file(doc, file, false);
    delete(contexts);
    delete(css_map);
    delete(doc);
  }
  fclose(file);
}

/************************ Init ************************/

bool DSVG_dev::is_init() const {
  return doc != NULL;
}

SVGElement* DSVG_dev::svg_root() {
  if (doc) return root;
  // create document and root svg element
  doc = new_svg_doc(standalone, false);
  root = create_element("svg", (SVGElement*)doc);
  if (standalone) {
    set_attr(root, "xmlns", "http://www.w3.org/2000/svg");
    set_attr(root, "xmlns:xlink", "http://www.w3.org/1999/xlink");
  }
  set_attr(root, "class", "ggiraph-svg");
  set_attr(root, "role", "graphics-document");

  std::string id;

  if (!title.empty()) {
    SVGElement* titleEl = create_element("title", root);
    SVGText* titleT = new_svg_text(title.c_str(), doc, false);
    append_element((SVGElement*)titleT, titleEl);
    id.assign(canvas_id + "_title");
    set_attr(titleEl, "id", id);
    set_attr(root, "aria-labelledby", id);
  }

  if (!desc.empty()) {
    SVGElement* descEl = create_element("desc", root);
    SVGText* descT = new_svg_text(desc.c_str(), doc, false);
    append_element((SVGElement*)descT, descEl);
    id.assign(canvas_id + "_desc");
    set_attr(descEl, "id", id);
    set_attr(root, "aria-describedby", id);
  }

  // create main defs element
  // all definitions (clips, masks, gradients, etc) will go here
  root_defs = create_element("defs", root);
  id.assign(canvas_id + "_defs");
  set_attr(root_defs, "id", id);

  // create main g element
  // all regular elements will go here
  root_g = create_element("g", root);
  id.assign(canvas_id + "_rootg");
  set_attr(root_g, "id", id);
  set_attr(root_g, "class", "ggiraph-svg-rootg");

  // initialize contexts stack
  contexts = new std::stack<ContainerContext*>();
  // insert a context for root g element
  contexts->push(new ContainerContext(root_g, false, true, true));

  // initialize maps
  css_map = new std::unordered_map<std::string, std::string>();
  return root;
}

/************************ Elements ************************/

SVGElement* DSVG_dev::svg_element(const char* name, SVGElement* parent) {
  if (!name) Rf_error("Invalid name (svg_element)");
  SVGElement* p = parent;
  if (!p) p = resolve_parent();
  if (!p) Rf_error("Invalid parent (svg_element)");
  SVGElement* el = create_element(name, p);
  if (!parent) {
    if (!is_adding_definition() && interactives.is_tracing()) {
      interactives.push(el);
    }
    ContainerContext* ctx = contexts->top();
    if (IS_VALID_INDEX(ctx->mask_index)) {
      set_mask_ref(el, masks.make_id(ctx->mask_index));
    }
  }
  return el;
}

SVGElement* DSVG_dev::create_element(const char* name,
                                     SVGElement* parent,
                                     const EPosition position,
                                     SVGElement* sibling) {
  SVGElement* el = new_svg_element(name, doc);
  if (parent) {
    switch(position) {
    case BOTTOM:
      append_element(el, parent);
      break;
    case TOP:
      prepend_element(el, parent);
      break;
    case BEFORE:
      DSVGASSERT(sibling);
      if (!sibling) Rf_error("Invalid sibling (create_element)");
      insert_element_before(el, parent, sibling);
      break;
    }
  }
  return el;
}

SVGElement* DSVG_dev::resolve_parent() {
  DSVGASSERT(contexts);
  CHECK_STACK_NOT_EMPTY("resolve_parent");
  // get the active context
  ContainerContext* ctx = contexts->top();
  // get the active container
  Container* container = ctx->container;
  if (!ctx->use_grouping) {
    DSVGASSERT(container);
    DSVGASSERT(container->element);
    return container->element;
  }
  // compare the clip_index
  if (container && container->clip_index != ctx->clip_index) {
    // create a new container
    container = NULL;
  }
  if (!container) {
    // Add a g element under the context's base element
    SVGElement* g = create_element("g", ctx->element);
    // Add a new container and update the context
    container = new Container(g, ctx->clip_index);
    ctx->container = container;
    // set the clip reference
    set_clip_ref(container->element, clips.make_id(container->clip_index));
  }
  // parent is the container's base element
  return container->element;
}

/************************ Definitions ************************/

SVGElement* DSVG_dev::svg_definition(const char* name) {
  DSVGASSERT(root_defs);
  EPosition pos = EPosition::BOTTOM;
  SVGElement* sibling = NULL;
  if (is_adding_definition()) {
    pos = EPosition::BEFORE;
    sibling = contexts->top()->element;
  }
  return create_element(name, root_defs, pos, sibling);
}

void DSVG_dev::push_definition(SVGElement* element,
                               const bool& use_grouping, const bool& paint_children) {
  DSVGASSERT(contexts);
  CHECK_STACK_NOT_EMPTY("push_definition");
  if (!element) Rf_error("Invalid element (push_definition)");
  // add a new context at the top of the stack
  contexts->push(new ContainerContext(element, true, use_grouping, paint_children));
}

void DSVG_dev::pop_definition() {
  DSVGASSERT(contexts);
  if (contexts->size() > 1) {
    contexts->pop();
  }
  CHECK_STACK_NOT_EMPTY("pop_definition");
}

const bool DSVG_dev::is_adding_definition() const {
  DSVGASSERT(contexts);
  CHECK_STACK_NOT_EMPTY("is_adding_definition");
  return contexts->top()->is_definition;
}

const bool DSVG_dev::should_paint() const {
  DSVGASSERT(contexts);
  CHECK_STACK_NOT_EMPTY("should_paint");
  return contexts->top()->paint_children;
}

void DSVG_dev::use_clip(const INDEX index) {
  DSVGASSERT(contexts);
  CHECK_STACK_NOT_EMPTY("use_clip");
  contexts->top()->clip_index = index;
}

void DSVG_dev::use_mask(const INDEX index) {
  DSVGASSERT(contexts);
  CHECK_STACK_NOT_EMPTY("use_mask");
  contexts->top()->mask_index = index;
}

/************************ Styles ************************/

void DSVG_dev::add_css(const std::string key, const std::string value) {
  DSVGASSERT(css_map);
  css_map->insert(std::pair<std::string, std::string>(key, value));
}

void DSVG_dev::add_styles() {
  DSVGASSERT(css_map);
  if (css_map->size() > 0) {
    SVGElement* styleEl = create_element("style", root, EPosition::TOP);
    std::ostringstream os;
    for ( auto it = css_map->begin(); it != css_map->end(); ++it ) {
      os << it->second;
    }
    SVGText* t = new_svg_text(os.str().c_str(), doc, true);
    append_element((SVGElement*)t, styleEl);
  }
}
