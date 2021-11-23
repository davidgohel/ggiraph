#include "svg.h"
#include "utils.h"
#include "a_color.h"

void svg_to_file(const SVGDocument* doc, FILE* file, const bool compact) {
  tinyxml2::XMLPrinter* printer = new tinyxml2::XMLPrinter(file, compact);
  doc->Print( printer );
  delete(printer);
}

SVGDocument* new_svg_doc(const bool declaration, const bool bom) {
  SVGDocument* doc = new SVGDocument();
  doc->SetBOM( bom );
  if (declaration)
    ((tinyxml2::XMLNode*)doc)->InsertEndChild(doc->NewDeclaration());
  return doc;
}

SVGElement* new_svg_element(const char* name, SVGDocument* doc) {
  return doc->NewElement(name);
}

SVGText* new_svg_text(const char* str, SVGDocument* doc, const bool cdata) {
  SVGText* t = doc->NewText(str);
  t->SetCData(cdata);
  return t;
}

void append_element(SVGElement* child, SVGElement* parent) {
  parent->InsertEndChild(child);
}

void prepend_element(SVGElement* child, SVGElement* parent) {
  parent->InsertFirstChild(child);
}

void insert_element_before(SVGElement* child, SVGElement* parent, SVGElement* sibling) {
  if (sibling->PreviousSibling())
    parent->InsertAfterChild(sibling->PreviousSibling(), child);
  else
    parent->InsertEndChild(child);
}

const char* svg_attribute(const SVGElement* element, const char* name) {
  const tinyxml2::XMLAttribute* a = element->FindAttribute(name);
  if (a != 0) {
    return a->Value();
  }
  return NULL;
}

void set_attr(SVGElement* element, const char* name, const char* value) {
  if (value && strlen(value) > 0) {
    element->SetAttribute(name, value);
  } else {
    element->DeleteAttribute(name);
  }
}
void set_attr(SVGElement* element, const char* name, const double& value) {
  set_attr(element, name, to_string(value).c_str());
}

void set_fill(SVGElement* element, const int& col) {
  a_color col_(col);
  if (col_.is_transparent()) {
    set_attr(element, "fill", "none");
  } else {
    set_attr(element, "fill", col_.color());
    set_attr(element, "fill-opacity", col_.opacity());
  }
}

void set_stroke(SVGElement* element, const double& width, const int& col,
                const int& type, const int& join, const int& end) {
  a_color col_(col);
  if (col_.is_transparent()) {
    set_attr(element, "stroke", "none");
  } else {
    set_attr(element, "stroke", col_.color());
    set_attr(element, "stroke-opacity", col_.opacity());
  }
  if (!col_.is_visible() || width < 0.0001 || type < 0) {
    return;
  }

  set_attr(element, "stroke-width", width * 72 / 96);

  if (type > LTY_SOLID) {
    int lty = type;
    double lwd = width;
    std::ostringstream os;
    os << (int) lwd * (lty & 15);
    lty = lty >> 4;
    for (int i = 0; i < 8 && lty & 15; i++) {
      os << ","<< (int) lwd * (lty & 15);
      lty = lty >> 4;
    }
    set_attr(element, "stroke-dasharray", os.str());
  }

  switch (join) {
  case GE_MITRE_JOIN: //mitre
    set_attr(element, "stroke-linejoin", "miter");
    break;
  case GE_BEVEL_JOIN: //bevel
    set_attr(element, "stroke-linejoin", "bevel");
    break;
  case GE_ROUND_JOIN: //round
  default:
    set_attr(element, "stroke-linejoin", "round");
  break;
  }

  switch (end) {
  case GE_BUTT_CAP:
    set_attr(element, "stroke-linecap", "butt");
    break;
  case GE_SQUARE_CAP:
    set_attr(element, "stroke-linecap", "square");
    break;
  case GE_ROUND_CAP:
  default:
    set_attr(element, "stroke-linecap", "round");
  break;
  }
}

void set_ref(SVGElement* element, const char* name, const std::string& id) {
  if (!id.empty()) {
    set_attr(element, name, "url(#" + id + ")");
  } else {
    set_attr(element, name, "");
  }
}

void set_clip_ref(SVGElement* element, const std::string& clip_id) {
  set_ref(element, "clip-path", clip_id);
}

