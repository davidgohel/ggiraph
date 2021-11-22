/*
 * Utilities for creating and handling SVG elements
 */
#ifndef DSVG_SVG_INCLUDED
#define DSVG_SVG_INCLUDED

// tinyxml2 must be included before Rcpp
#include "tinyxml2.h"
#include <Rcpp.h>
#include <string>

typedef tinyxml2::XMLDocument SVGDocument;
typedef tinyxml2::XMLElement SVGElement;
typedef tinyxml2::XMLText SVGText;

void svg_to_file(const SVGDocument* doc, FILE* file, const bool compact = true);

SVGDocument* new_svg_doc(const bool declaration = true, const bool bom = false);
SVGElement* new_svg_element(const char* name, SVGDocument* doc);
SVGText* new_svg_text(const char* str, SVGDocument* doc, const bool cdata = true);

void append_element(SVGElement* child, SVGElement* parent);
void prepend_element(SVGElement* child, SVGElement* parent);

const char* svg_attribute(const SVGElement* element, const char* name);

void set_attr(SVGElement* element, const char* name, const char* value);
inline void set_attr(SVGElement* element, const char* name, const std::string& value) {
  set_attr(element, name, value.c_str());
}
void set_attr(SVGElement* element, const char* name, const double& value);

void set_fill(SVGElement* element, const int& col);
void set_stroke(SVGElement* element, const double& width, const int& col,
                const int& type, const int& join, const int& end);

void set_clip(SVGElement* element, const char* clipid);

#endif // DSVG_SVG_INCLUDED
