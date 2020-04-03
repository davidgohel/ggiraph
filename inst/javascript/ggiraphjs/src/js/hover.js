import * as d3 from 'd3'

export default class HoverHandler {

  constructor(svgid, classPrefix, attrName) {
    this.svgid = svgid;
    this.clsName = classPrefix + '_' + svgid;
    this.attrName = attrName;
    this.dataHovered = [];
  }

  init() {
    // select elements
    const elements = d3.select('#' + this.svgid)
      .selectAll('*[' + this.attrName + ']');
    if (elements.empty()) {
      // nothing to do here, return false to discard this
      return false;
    }
    const that = this;

    // add event listeners
    elements.each(function() {
      this.addEventListener("mouseover", that);
      this.addEventListener("mouseout", that);
    });

    // return true to add to list of handLers
    return true;
  }

  destroy() {
    const that = this;
    // remove event listeners
    try {
      d3.select('#' + this.svgid)
        .selectAll('*[' + this.attrName + ']')
        .each(function() {
          this.removeEventListener("mouseover", that);
          this.removeEventListener("mouseout", that);
        });
    } catch (e) { console.error(e) }
    //
    this.dataHovered = [];
  }

  handleEvent(event) {
    try {
      if (event.type == 'mouseover') {
        this.setHovered([event.target.getAttribute(this.attrName)]);

      } else if (event.type == 'mouseout') {
        this.setHovered([]);
      }
    } catch (e) { console.error(e) }
  }

  setHovered(hovered) {
    this.dataHovered = hovered;
    this.refreshHovered();
  }

  refreshHovered() {
    const svgEl = d3.select('#' + this.svgid);
    svgEl
      .selectAll('*[' + this.attrName + '].' + this.clsName)
      .classed(this.clsName, false);

    const that = this;
    for (var i = 0; i < that.dataHovered.length; i++) {
      svgEl
        .selectAll('*[' + that.attrName + '="' + that.dataHovered[i] + '"]')
        .classed(that.clsName, true);
    }
  }
}
