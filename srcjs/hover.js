import * as d3 from 'd3';

export default class HoverHandler {
  constructor(
    svgid,
    classPrefix,
    invClassPrefix,
    attrName,
    shinyInputId,
    shinyMessageId
  ) {
    this.svgid = svgid;
    this.clsName = classPrefix + '_' + svgid;
    this.invClsName = invClassPrefix ? invClassPrefix + '_' + svgid : null;
    this.attrName = attrName;
    this.shinyInputId = shinyInputId;
    this.shinyMessageId = shinyMessageId;
    this.dataHovered = [];
  }

  init() {
    // select elements
    const elements = d3
      .select('#' + this.svgid)
      .selectAll('*[' + this.attrName + ']');
    if (elements.empty()) {
      // nothing to do here, return false to discard this
      return false;
    }
    const that = this;

    // add event listeners
    elements.each(function () {
      this.addEventListener('mouseover', that);
      this.addEventListener('mouseout', that);
    });

    // add shiny listener
    if (this.shinyMessageId) {
      Shiny.addCustomMessageHandler(this.shinyMessageId, function (message) {
        if (typeof message === 'string') {
          that.setHovered([message]);
        } else if (Array.isArray(message)) {
          that.setHovered(message);
        }
      });
    }

    // return true to add to list of handLers
    return true;
  }

  destroy() {
    const that = this;
    // remove event listeners
    try {
      d3.select('#' + this.svgid)
        .selectAll('*[' + this.attrName + ']')
        .each(function () {
          this.removeEventListener('mouseover', that);
          this.removeEventListener('mouseout', that);
        });
    } catch (e) {
      console.error(e);
    }

    // remove shiny listener
    if (this.shinyMessageId) {
      try {
        // For Shiny the only way to really remove it
        // is to replace it with a void one
        Shiny.addCustomMessageHandler(this.shinyMessageId, function (
          message
        ) {});
      } catch (e) {
        console.error(e);
      }
    }
    this.dataHovered = [];
  }

  handleEvent(event) {
    try {
      if (event.type == 'mouseover') {
        this.setHovered([event.target.getAttribute(this.attrName)]);
      } else if (event.type == 'mouseout') {
        this.setHovered([]);
      }
    } catch (e) {
      console.error(e);
    }
  }

  setHovered(hovered) {
    this.dataHovered = hovered;
    this.refreshHovered();
    if (this.shinyInputId) {
      Shiny.onInputChange(this.shinyInputId, this.dataHovered);
    }
  }

  refreshHovered() {
    const svgEl = d3.select('#' + this.svgid);
    svgEl
      .selectAll('*[' + this.attrName + '].' + this.clsName)
      .classed(this.clsName, false);
    if (this.invClsName) {
      svgEl
        .selectAll('*[' + this.attrName + '].' + this.invClsName)
        .classed(this.invClsName, false);
    }

    const that = this;
    for (let i = 0; i < that.dataHovered.length; i++) {
      svgEl
        .selectAll('*[' + that.attrName + '="' + that.dataHovered[i] + '"]')
        .classed(that.clsName, true);
    }
    if (this.invClsName && this.dataHovered.length > 0) {
      svgEl
        .selectAll('*[' + this.attrName + ']:not(.' + this.clsName + ')')
        .classed(this.invClsName, true);
    }
  }
}
