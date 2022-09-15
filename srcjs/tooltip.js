import * as d3 from 'd3';
import { getWindowViewport, getHTMLElementMatrix } from './geom';

export default class TooltipHandler {
  constructor(
    svgid,
    classPrefix,
    placement,
    opacity,
    offx,
    offy,
    usecursor,
    usefill,
    usestroke,
    delayover,
    delayout
  ) {
    this.svgid = svgid;
    this.clsName = classPrefix + '_' + this.svgid;
    this.placement = placement;
    this.opacity = opacity;
    this.offx = offx;
    this.offy = offy;
    this.usecursor = usecursor;
    this.usefill = usefill;
    this.usestroke = usestroke;
    this.delayover = delayover;
    this.delayout = delayout;
    this.lastTargetId = null;
  }

  init() {
    const rootNode = document.getElementById(this.svgid + '_rootg');
    // check if an alement with title is found
    if (!rootNode.querySelector('*[title]')) {
      // nothing to do here, return false to discard this
      return false;
    }

    // remove any old elements
    d3.select('.' + this.clsName).remove();

    // create tooltip
    let containerEl;
    if (this.placement == 'doc') {
      containerEl = d3.select('body');
    } else {
      containerEl = d3.select(rootNode.ownerSVGElement.parentNode);
    }
    containerEl
      .append('xhtml:div')
      .classed(this.clsName, true)
      .style('position', 'absolute')
      .style('opacity', 0);

    // create a textarea to decode content
    this.decodingTextarea = document.createElementNS(
      'http://www.w3.org/1999/xhtml',
      'textarea'
    );

    // return true to add to list of handLers
    return true;
  }

  destroy() {
    this.lastTargetId = null;

    // remove element
    d3.select('.' + this.clsName).remove();
  }

  clear() {
    if (this.lastTargetId) {
      this.lastTargetId = null;
      const tooltipEl = d3.select('div.' + this.clsName);
      tooltipEl.transition().duration(this.delayout).style('opacity', 0);
    }
  }

  isValidTarget(target) {
    return target instanceof SVGGraphicsElement && target.hasAttribute('title');
  }

  applyOn(target, mousePos) {
    try {
      if (this.isValidTarget(target)) {
        const svgNode = target.ownerSVGElement;
        const tooltipEl = d3.select('div.' + this.clsName);
        let tooltipPos;
        if (target.id === this.lastTargetId) {
          tooltipPos = this.calculatePosition(tooltipEl, svgNode, mousePos);
          tooltipEl
            .style('left', tooltipPos.x + 'px')
            .style('top', tooltipPos.y + 'px');
        } else {
          this.lastTargetId = target.id;
          if (this.usefill) {
            let clr = target.getAttribute('tooltip_fill');
            if (!clr) clr = target.getAttribute('fill');
            if (clr) tooltipEl.style('background-color', clr);
          }
          if (this.usestroke) {
            tooltipEl.style('border-color', target.getAttribute('stroke'));
          }
          tooltipEl.html(this.decodeContent(target.getAttribute('title')));

          tooltipPos = this.calculatePosition(tooltipEl, svgNode, mousePos);
          tooltipEl
            .style('left', tooltipPos.x + 'px')
            .style('top', tooltipPos.y + 'px')
            .transition()
            .duration(this.delayover)
            .style('opacity', this.opacity);
        }
        return true;
      }
    } catch (e) {
      console.error(e);
    }
    return false;
  }

  decodeContent(txt) {
    // decodes html encoded text
    this.decodingTextarea.innerHTML = txt;
    return this.decodingTextarea.value;
  }

  calculatePosition(tooltipEl, svgNode, mousePos) {
    let p, matrix;
    const tooltipNode = tooltipEl.node();
    const containerNode = svgNode.parentNode;
    if (this.usecursor) {
      // Calculate tooltip position, preventing collisions and overflow if possible.
      // First we try to fit the tooltip on right and bottom of the mouse position.
      // If it doesn't fit we try the opposite direction and negate the passed offset.
      // Otherwise we use the center/middle position.

      // tooltip dimensions
      const tooltipWidth = Math.ceil(tooltipNode.offsetWidth);
      const tooltipHeight = Math.ceil(tooltipNode.offsetHeight);

      // boundaries where the tooltip must not cross, set to window viewport
      const viewport = getWindowViewport(svgNode);
      let minp = new DOMPoint(viewport.left, viewport.top);
      let maxp = new DOMPoint(viewport.right, viewport.bottom);

      // current mouse/touch coordinates in document coord system
      p = mousePos;

      if (this.placement != 'doc') {
        // convert the coords to be relative to the container
        matrix = getHTMLElementMatrix(containerNode).inverse();
        p = p.matrixTransform(matrix);
        minp = minp.matrixTransform(matrix);
        maxp = maxp.matrixTransform(matrix);
      }

      // calculate horizontal position
      const spaceRight = maxp.x - (p.x + this.offx);
      const spaceLeft = p.x - this.offx - minp.x;
      if (spaceRight >= tooltipWidth) {
        // fits on right
        p.x = Math.max(minp.x, p.x + this.offx);
      } else if (spaceLeft >= tooltipWidth) {
        // fits on left
        p.x = Math.min(maxp.x - tooltipWidth, p.x - this.offx - tooltipWidth);
      } else {
        // set at middle
        p.x = Math.max(
          minp.x,
          Math.min(maxp.x, p.x + tooltipWidth / 2) - tooltipWidth
        );
      }

      // calculate vertical position
      const spaceBottom = maxp.y - (p.y + this.offy);
      const spaceTop = p.y - this.offy - minp.y;
      if (spaceBottom >= tooltipHeight) {
        // fits on bottom
        p.y = Math.max(minp.y, p.y + this.offy);
      } else if (spaceTop >= tooltipHeight) {
        // fits on top
        p.y = Math.min(maxp.y - tooltipHeight, p.y - this.offy - tooltipHeight);
      } else {
        // set at middle
        p.y = Math.max(
          minp.y,
          Math.min(maxp.y, p.y + tooltipHeight / 2) - tooltipHeight
        );
      }
    } else {
      // Fixed position
      p = new DOMPoint(this.offx, this.offy);

      if (this.placement == 'doc') {
        // correct the position to be relative to the document
        matrix = getHTMLElementMatrix(containerNode);
        p = p.matrixTransform(matrix);
      }
    }
    return p;
  }
}
