import * as d3 from 'd3';
import {
  getWindowViewport,
  getHTMLElementMatrix,
  rectContainsRect
} from './geom';

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
    return (
      target instanceof SVGGraphicsElement &&
      !(target instanceof SVGSVGElement) &&
      target.hasAttribute('title')
    );
  }

  applyOn(target, event) {
    try {
      if (this.isValidTarget(target)) {
        const mousePos = new DOMPoint(event.pageX, event.pageY);
        const tooltipEl = d3.select('div.' + this.clsName);
        let tooltipPos;
        if (target.id === this.lastTargetId) {
          tooltipPos = this.calculatePosition(tooltipEl, target, mousePos);
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

          tooltipPos = this.calculatePosition(tooltipEl, target, mousePos);
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

  calculatePosition(tooltipEl, target, mousePos) {
    let p, matrix;
    const svgNode = target.ownerSVGElement;
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

      // target node bounding rect
      const brect = target.getBoundingClientRect();

      // calculate possible horizontal positions
      const possibleX = [];
      const spaceRight = maxp.x - (p.x + this.offx);
      const spaceLeft = p.x - this.offx - minp.x;
      if (spaceRight >= tooltipWidth) {
        // fits on right
        possibleX.push(Math.max(minp.x, p.x + this.offx));
      }
      if (spaceLeft >= tooltipWidth) {
        // fits on left
        possibleX.push(
          Math.min(maxp.x - tooltipWidth, p.x - this.offx - tooltipWidth)
        );
      }
      // set at middle, as fallback
      possibleX.push(
        Math.max(
          minp.x,
          Math.min(maxp.x, p.x + tooltipWidth / 2) - tooltipWidth
        )
      );

      // calculate possible vertical positions
      const possibleY = [];
      const spaceBottom = maxp.y - (p.y + this.offy);
      const spaceTop = p.y - this.offy - minp.y;
      if (spaceBottom >= tooltipHeight) {
        // fits on bottom
        possibleY.push(Math.max(minp.y, p.y + this.offy));
      }
      if (spaceTop >= tooltipHeight) {
        // fits on top
        possibleY.push(
          Math.min(maxp.y - tooltipHeight, p.y - this.offy - tooltipHeight)
        );
      }
      // set at middle, as fallback
      possibleY.push(
        Math.max(
          minp.y,
          Math.min(maxp.y, p.y + tooltipHeight / 2) - tooltipHeight
        )
      );

      // combine them into possible tooltip rects
      const possibleRects = [];
      possibleX.forEach(function (x) {
        possibleY.forEach(function (y) {
          possibleRects.push(new DOMRect(x, y, tooltipWidth, tooltipHeight));
        });
      });

      // find the first rect that does not contain the target's rect
      let found = possibleRects.find((r) => !rectContainsRect(r, brect));
      if (!found) found = possibleRects[0];
      p.x = found.x;
      p.y = found.y;
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
