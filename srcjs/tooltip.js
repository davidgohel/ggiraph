import * as d3 from 'd3';

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
    const tooltipRect = tooltipEl.getBoundingClientRect();
    const containerRect = containerEl.getBoundingClientRect();
    let xpos, ypos;
    if (this.usecursor) {
      xpos = event.pageX;
      ypos = event.pageY;

      const maxx = window.innerWidth + window.pageXOffset;
      const maxy = window.innerHeight + window.pageYOffset;
      let xoffset = this.offx;
      let yoffset = this.offy;
      // needed so that the mouse doesn't fall inside tooltip
      if (xoffset < 3) xoffset = 3;
      if (yoffset < 3) yoffset = 3;

      // try setting the tooltip on the right side of the point
      const rightMargin = xpos + xoffset + tooltipRect.width;
      if (rightMargin <= maxx) {
        xpos += xoffset;
      } else {
        // try setting the tooltip on the left side of the point
        const leftMargin = xpos - xoffset - tooltipRect.width;
        if (leftMargin >= window.pageXOffset) {
          xpos -= xoffset + tooltipRect.width;
        } else {
          // anchor to left
          xpos = window.pageXOffset;
        }
      }

      // try setting the tooltip on the bottom side of the point
      const bottomMargin = ypos + yoffset + tooltipRect.height;
      if (bottomMargin <= maxy) {
        ypos += yoffset;
      } else {
        // try setting the tooltip on the top side of the point
        const topMargin = ypos - yoffset - tooltipRect.height;
        if (topMargin >= window.pageYOffset) {
          ypos -= yoffset + tooltipRect.height;
        } else {
          // anchor to top
          ypos = window.pageYOffset;
        }
      }

      if (
        this.standaloneMode &&
        containerEl.createSVGPoint &&
        containerEl.getScreenCTM
      ) {
        // must convert the position to svg coords
        const transform = containerEl.getScreenCTM().inverse();
        let point = containerEl.createSVGPoint();
        point.x = xpos;
        point.y = ypos;
        point = point.matrixTransform(transform);
        xpos = point.x;
        ypos = point.y;
      }
    } else {
      xpos = this.offx + containerRect.left;
      ypos = this.offy + containerRect.top;
    }
    return [xpos, ypos];
  }
}
