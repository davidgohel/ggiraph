/*
 * DSVG device - Device specific data handling
 */
#ifndef DSVG_DEV_INCLUDED
#define DSVG_DEV_INCLUDED

#include "interactive.h"
#include "clip.h"
#include "mask.h"
#include "pattern.h"
#include <stack>

/* helper enum for positioning svg elements inside their parent */
typedef enum {
  /* insert to bottom */
  BOTTOM = 0,
  /* insert to top */
  TOP = 1,
  /* insert before sibling */
  BEFORE = 2
} EPosition;

/*
 * Class for handling device specific data
 */
class DSVG_dev {
public:
  /* the output filename */
  const std::string filename;
  /* svg dimensions */
  const double width;
  const double height;
  /* id for the svg */
  const std::string canvas_id;
  /* is the svg standalone? */
  const bool standalone;
  /* set svg dimension attributes? */
  const bool setdims;
  /* font aliases */
  const Rcpp::List system_aliases;

  /* indexed interactive elements */
  InteractiveElements interactives;
  /* indexed clip elements */
  Clips clips;
  /* indexed mask elements */
  Masks masks;
  /* indexed pattern elements */
  Patterns patterns;

  /*
   * Constructor
   *
   * filename_    The filename to use
   * width_       SVG width in pixels
   * height_      SVG height in pixels
   * canvas_id_   SVG id
   * standalone_  Add XML header?
   * setdims_     Add dimensions?
   * aliases_     Font aliases
   */
  DSVG_dev(std::string filename_,
           double width_, double height_,
           std::string canvas_id_,
           bool standalone_, bool setdims_,
           Rcpp::List& aliases_);
  ~DSVG_dev();

  /* Returns init status */
  bool is_init() const;

  /* Initializes and returns the root SVG element */
  SVGElement* svg_root();

  /*
   * Creates and returns an SVG element.
   *
   * name     The tag name to use
   * parent   The parent element. If it's not specified, it is resolved internally.
   *
   * For most cases leave the parent unset.
   * It will be added inside the proper parent element according to the current context.
   * If the tracing is on and we are not inside a definition element,
   * it will be automatically added to the 'interactives' member.
   */
  SVGElement* svg_element(const char* name, SVGElement* parent = NULL);

  /*
   * Creates and returns an SVG 'definition' element (clipPath/mask/pattern/etc).
   * The root defs node is used as its parent.
   * After its creation it should be added manually inside the proper indexing member
   * (clips/masks/patterns/etc)
   *
   * name     The tag name to use
   */
  SVGElement* svg_definition(const char* name);

  /*
   * Basic method for creating an SVG element.
   *
   * name     The tag name to use
   * parent   The parent element. If it's specified, the new element is added inside it,
   * position The position to use for positioning the element
   * sibling  A sibling to use for position (in case of EPosition::BEFORE or EPosition::AFTER)
   */
  SVGElement* create_element(const char* name,
                             SVGElement* parent,
                             const EPosition position = EPosition::BOTTOM,
                             SVGElement* sibling = NULL);

  /*
   * Declares that a new active context should be created, based on a new definition element.
   * All subsequent elements will be appended somewhere under that element.
   * Look at ContainerContext class for parameter meaning.
   */
  void push_definition(SVGElement* element,
                       const bool& use_grouping, const bool& paint_children = true);

  /*
   * Declares the exit of the active definition context.
   */
  void pop_definition();

  /*
   * Returns true if the active context is a definition
   */
  const bool is_adding_definition() const;

  /*
   * Returns true if the elements added in the active context should be painted.
   * For regular context it will be true, for elements under definition,
   * it will depend on the 'paint' argument supplied when pushing the definition.
   */
  const bool should_paint() const;

  /* Sets the active clip index */
  void use_clip(const INDEX index);

  /* Sets the active mask index */
  void use_mask(const INDEX index);

  /*  Adds a css style */
  void add_css(const std::string key, const std::string value);

private:
  // Helper classes defined later
  class ContainerContext;
  class GroupContext;

  /* the output file handle */
  FILE* file;
  /* the svg document */
  SVGDocument* doc;
  /* the root svg element */
  SVGElement* root;
  /* the root g element */
  SVGElement* root_g;
  /* the root defs element */
  SVGElement* root_defs;
  /*
   * Stack of contexts (see ContainerContext).
   * The top of the stack is the active context and
   * all subsequent elements are added under that.
   */
  std::stack<ContainerContext*>* contexts;

  /* returns the element to use as parent in current context */
  SVGElement* resolve_parent();

  /* a map with all styles */
  std::unordered_map<std::string, std::string>* css_map;
  /* adds the css styles in the svg */
  void add_styles();

  /*
   * Helper class defining a container structure,
   * identified by an element (usually g) and a clipPath index
   */
  class Container {
  public:
    /* container's element, serves as a parent for next elements */
    SVGElement* element;
    /* container's clip index */
    INDEX clip_index;

    /* Constructor */
    Container(SVGElement* element_, const INDEX clip_index_ = NULL_INDEX) :
      element(element_), clip_index(clip_index_) {}
  };

  /*
   * Class for a container context.
   */
  class ContainerContext {
  public:

    /* base context element, serves as a parent for the containers */
    SVGElement* element;

    /* flag indicating if this is a definition context */
    bool is_definition;

    /* flag indicating if this is context uses element grouping */
    bool use_grouping;

    /* flag indicating if the children elements should get painted */
    bool paint_children;

    /* pointer to active container */
    Container* container;

    /*
     * The context's clip index. Initially it's NULL,
     * but it can be changed via the 'use_clip' method.
     * When the context's clip_index is different from the active container's clip_index, then
     * a new container is created, with the new clip_index (see resolveParent).
     */
    INDEX clip_index;

    /*
     * The context's mask index. Initially it's NULL,
     * but it can be changed via the 'use_mask' method.
     * When it's a valid index all subsequent elements, will have a relevant mask attribute set
     */
    INDEX mask_index;

    /*
     * Constructor
     *
     * element_          The base element
     *
     * is_definition_    A flag indicating if this is a definition context (under svg/defs)
     *
     * use_grouping_     If true, specifies that the base element can contain group (g) elements,
     *                   and the context is organized by group container elements.
     *                   All subsequent children will be appended to a group container.
     *                   If false, then the base element cannot contain group (g) elements,
     *                   and all subsequent children will be appended directly
     *                   under the base element.
     *
     *                   Contexts for clipPath, filters and gradients need this to be false.
     *                   Contexts for regular elements, masks and patterns need this to be true.
     *
     *                   See 'push_definition' and 'resolveParent'.
     *
     * paint_children_   If true, specifies that children elements added to the definition node
     *                   should get painted (fill/stroke).
     *                   If false (like in the case of clipPaths), children elements will not get painted.
     */
    ContainerContext(SVGElement* element_,
                     const bool is_definition_,
                     const bool use_grouping_,
                     const bool paint_children_) :
      element(element_),
      is_definition(is_definition_),
      use_grouping(use_grouping_),
      paint_children(paint_children_),
      container(use_grouping_ ? NULL : new Container(element_)),
      clip_index(NULL_INDEX),
      mask_index(NULL_INDEX) {}
  };
};

#endif // DSVG_DEV_INCLUDED
