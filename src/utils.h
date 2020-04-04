// Various utilities for dsvg

// tinyxml2 must be included first
#include "tinyxml2.h"
#include <Rcpp.h>

std::string to_string( const double& d );
std::string to_string( const int& i );

typedef tinyxml2::XMLDocument SVGDocument;
typedef tinyxml2::XMLElement SVGElement;
typedef tinyxml2::XMLText SVGText;
void set_attr(SVGElement* element, const char* name, const char* value);
void set_attr(SVGElement* element, const char* name, const double& value);
void set_attr(SVGElement* element, const char* name, const int& value);
void set_attr(SVGElement* element, const char* name, const std::string value);
void set_fill(SVGElement* element, const int col);
void set_stroke(SVGElement* element, const double width, const int col, const int type, const int join, const int end);
void set_clip(SVGElement* element, const char* clipid);
void svg_to_file(SVGDocument* doc, FILE* file, const bool compact = true);
SVGDocument* new_svg_doc(const bool declaration = true, const bool bom = false);
SVGElement* new_svg_element(const char* name, SVGDocument* doc);
SVGText* new_svg_text(const char* str, SVGDocument* doc, const bool cdata = true);
void append_element(SVGElement* child, SVGElement* parent);
void prepend_element(SVGElement* child, SVGElement* parent);
const char* svg_attribute(const SVGElement* element, const char * name);
