import * as d3 from 'd3';

export default class HoverHandler {
  constructor(svgid, options) {
    this.svgid = svgid;
    this.clsName = options.classPrefix + '_' + svgid;
    this.invClsName = options.invClassPrefix
      ? options.invClassPrefix + '_' + svgid
      : null;
    this.attrName = options.attrName;
    this.shinyInputId = options.shinyInputId;
    this.shinyMessageId = options.shinyMessageId;
    this.nodeIds = [];
    this.dataHovered = [];
    this.lastTargetId = null;
  }

  init() {
    const rootNode = document.getElementById(this.svgid + '_rootg');
    // select elements
    const nodes = rootNode.querySelectorAll('*[' + this.attrName + ']');
    if (!nodes.length) {
      // nothing to do here, return false to discard this
      return false;
    }

    // store ids
    this.nodeIds = Array(nodes.length);
    let n = 0;
    nodes.forEach(function (node) {
      this.nodeIds[n++] = node.id;
    }, this);

    // add shiny listener
    const that = this;
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
    this.lastTargetId = null;
    this.nodeIds = [];

    // remove shiny listener
    if (this.shinyMessageId) {
      try {
        // For Shiny the only way to really remove it
        // is to replace it with a void one
        Shiny.addCustomMessageHandler(
          this.shinyMessageId,
          function (message) {}
        );
      } catch (e) {
        console.error(e);
      }
    }
    this.dataHovered = [];
  }

  clear() {
    if (this.lastTargetId) {
      this.lastTargetId = null;
      this.setHovered([]);
    }
  }

  isValidTarget(target) {
    return (
      target instanceof SVGGraphicsElement &&
      !(target instanceof SVGSVGElement) &&
      target.hasAttribute(this.attrName)
    );
  }

  applyOn(target, event) {
    try {
      if (this.isValidTarget(target)) {
        if (target.id !== this.lastTargetId) {
          this.lastTargetId = target.id;
          this.setHovered([target.getAttribute(this.attrName)]);
        }
        return true;
      }
    } catch (e) {
      console.error(e);
    }
    return false;
  }

  setHovered(hovered) {
    if (
      this.dataHovered.length !== hovered.length ||
      !this.dataHovered.every((item) => hovered.includes(item))
    ) {
      this.dataHovered = hovered;
      this.refreshHovered();
      if (this.shinyInputId) {
        Shiny.onInputChange(this.shinyInputId, this.dataHovered);
      }
    }
  }

  refreshHovered() {
    let node, hovered, element;
    this.nodeIds.forEach(function (id) {
      node = document.getElementById(id);
      if (node) {
        hovered = this.dataHovered.includes(node.getAttribute(this.attrName));
        element = d3.select(node);
        element.classed(this.clsName, hovered);
        if (this.invClsName) {
          if (this.dataHovered.length) {
            element.classed(this.invClsName, !hovered);
          } else {
            element.classed(this.invClsName, false);
          }
        }
      }
    }, this);
  }
}
