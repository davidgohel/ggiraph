import * as d3 from 'd3';
import { svgClientPoint } from './utils';

export default class TooltipHandler {
  constructor(
    svgid,
    classPrefix,
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
    this.opacity = opacity;
    this.offx = offx;
    this.offy = offy;
    this.usecursor = usecursor;
    this.usefill = usefill;
    this.usestroke = usestroke;
    this.delayover = delayover;
    this.delayout = delayout;
  }

  init(standaloneMode) {
    this.standaloneMode = standaloneMode;
    // select elements
    const elements = d3.select('#' + this.svgid).selectAll('*[title]');
    // check selection type
    if (elements.empty()) {
      // nothing to do here, return false to discard this
      return false;
    }

    // create tooltip
    if (d3.select('div.' + this.clsName).empty()) {
      let containerEl;
      if (this.standaloneMode) {
        containerEl = d3.select(
          '#' + this.svgid + ' > foreignObject.girafe-svg-foreign-object'
        );
      } else {
        containerEl = d3.select('body');
      }
      containerEl
        .append('xhtml:div')
        .classed(this.clsName, true)
        .style('position', 'absolute')
        .style('opacity', 0);
    }

    // add event listeners
    const that = this;
    elements.each(function () {
      this.addEventListener('mouseover', that);
      this.addEventListener('mousemove', that);
      this.addEventListener('mouseout', that);
    });
    // return true to add to list of handLers
    return true;
  }

  destroy() {
    const that = this;
    // remove event listeners
    try {
      d3.select('#' + this.svgid)
        .selectAll('*[title]')
        .each(function () {
          this.removeEventListener('mouseover', that);
          this.removeEventListener('mousemove', that);
          this.removeEventListener('mouseout', that);
        });
    } catch (e) {
      console.error(e);
    }

    // remove element
    d3.select('.' + this.clsName).remove();
  }

  handleEvent(event) {
    try {
      let pos;
      const tooltipEl = d3.select('div.' + this.clsName);
      let svgContainerEl = d3.select('#' + this.svgid).node();
      if (!this.standaloneMode) {
        svgContainerEl = svgContainerEl.parentNode;
      }
      if (event.type == 'mouseover') {
        if (this.usefill) {
          tooltipEl.style(
            'background-color',
            event.target.getAttribute('fill')
          );
        }
        if (this.usestroke) {
          tooltipEl.style('border-color', event.target.getAttribute('stroke'));
        }
        tooltipEl.html(event.target.getAttribute('title'));
        // set the tooltip again so that html entities are properly decoded
        tooltipEl.html(tooltipEl.text());

        pos = this.calculateTooltipPosition(
          tooltipEl.node(),
          svgContainerEl,
          event
        );
        tooltipEl
          .style('left', pos[0] + 'px')
          .style('top', pos[1] + 'px')
          .transition()
          .duration(this.delayover)
          .style('opacity', this.opacity);
      } else if (event.type == 'mousemove') {
        pos = this.calculateTooltipPosition(
          tooltipEl.node(),
          svgContainerEl,
          event
        );
        tooltipEl.style('left', pos[0] + 'px').style('top', pos[1] + 'px');
      } else if (event.type == 'mouseout') {
        // move tooltip offscreen on exit
        pos = [-4000, -4000];
        tooltipEl
          .style('left', pos[0] + 'px')
          .style('top', pos[1] + 'px')
          .transition()
          .duration(this.delayout)
          .style('opacity', 0);
      }
    } catch (e) {
      console.error(e);
    }
  }

  calculateTooltipPosition(tooltipEl, containerEl, event, standaloneMode) {
    let xpos, ypos;
    if (this.usecursor) {
      // Calculate tooltip position, preventing collisions and overflow if possible.
      // First we try to fit the tooltip on right and bottom of the event.
      // If it doesn't fit we try the opposite direction and negate the passed offset.
      // Otherwise use the center/middle position.

      // tooltip dimensions
      let tooltipWidth, tooltipHeight;

      // boundaries where the tooltip must not cross
      let minx, miny, maxx, maxy;

      if (this.standaloneMode) {
        // current mouse/touch coordinates in local coord system
        const cp = svgClientPoint(containerEl, event);
        xpos = cp[0];
        ypos = cp[1];
        // boundaries set to foreignObject box
        const box = tooltipEl.parentElement.getBBox();
        minx = 0;
        miny = 0;
        maxx = box.width;
        maxy = box.height;
        // tooltip dimensions
        tooltipWidth = tooltipEl.offsetWidth;
        tooltipHeight = tooltipEl.offsetHeight;
      } else {
        // current mouse/touch coordinates in page coord system
        xpos = event.pageX;
        ypos = event.pageY;
        // boundaries set to window viewport
        minx = window.pageXOffset;
        miny = window.pageYOffset;
        maxx = window.innerWidth + window.pageXOffset;
        maxy = window.innerHeight + window.pageYOffset;
        // tooltip dimensions
        const tooltipRect = tooltipEl.getBoundingClientRect();
        tooltipWidth = tooltipRect.width;
        tooltipHeight = tooltipRect.height;
      }

      // calculate horizontal position
      const spaceRight = maxx - (xpos + this.offx);
      const spaceLeft = xpos - this.offx - minx;
      if (spaceRight >= tooltipWidth) {
        // fits on right
        xpos = Math.max(minx, xpos + this.offx);
      } else if (spaceLeft >= tooltipWidth) {
        // fits on left
        xpos = Math.min(maxx - tooltipWidth, xpos - this.offx - tooltipWidth);
      } else {
        // set at middle
        xpos = Math.max(
          minx,
          Math.min(maxx, xpos + tooltipWidth / 2) - tooltipWidth
        );
      }

      // calculate vertical position
      const spaceBottom = maxy - (ypos + this.offy);
      const spaceTop = ypos - this.offy - miny;
      if (spaceBottom >= tooltipHeight) {
        // fits on bottom
        ypos = Math.max(miny, ypos + this.offy);
      } else if (spaceTop >= tooltipHeight) {
        // fits on top
        ypos = Math.min(maxy - tooltipHeight, ypos - this.offy - tooltipHeight);
      } else {
        // set at middle
        ypos = Math.max(
          miny,
          Math.min(maxy, ypos + tooltipHeight / 2) - tooltipHeight
        );
      }
    } else {
      // Fixed position
      if (this.standaloneMode) {
        xpos = this.offx;
        ypos = this.offy;
      } else {
        const containerRect = containerEl.getBoundingClientRect();
        const doc = document.documentElement;
        xpos = this.offx + containerRect.left + doc.scrollLeft;
        ypos = this.offy + containerRect.top + doc.scrollTop;
      }
    }
    return [xpos, ypos];
  }
}
