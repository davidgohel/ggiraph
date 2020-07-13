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
      let xpos, ypos, xdiff, ydiff, tooltipRect, clientRect;
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
        tooltipRect = tooltipEl.node().getBoundingClientRect();
        clientRect = svgContainerEl.getBoundingClientRect();
        if (this.usecursor) {
          xpos = event.pageX + this.offx;
          xdiff = xpos + tooltipRect.width - (clientRect.x + clientRect.width);
          if (xdiff > 0) {
            xpos -= xdiff;
          }
          ypos = event.pageY + this.offy;
          ydiff =
            ypos +
            tooltipRect.height -
            (clientRect.y + clientRect.height + window.pageYOffset);
          if (ydiff > 0) {
            ypos -= ydiff;
          }
        } else {
          xpos = this.offx + clientRect.left;
          ypos = document.documentElement.scrollTop + clientRect.y + this.offy;
        }
        tooltipEl
          .style('left', xpos + 'px')
          .style('top', ypos + 'px')
          .transition()
          .duration(this.delayover)
          .style('opacity', this.opacity);
      } else if (event.type == 'mousemove') {
        tooltipRect = tooltipEl.node().getBoundingClientRect();
        clientRect = svgContainerEl.getBoundingClientRect();
        if (this.usecursor) {
          xpos = event.pageX + this.offx;
          xdiff = xpos + tooltipRect.width - (clientRect.x + clientRect.width);
          if (xdiff > 0) {
            xpos -= xdiff;
          }
          ypos = event.pageY + this.offy;
          ydiff =
            ypos +
            tooltipRect.height -
            (clientRect.y + clientRect.height + window.pageYOffset);
          if (ydiff > 0) {
            ypos -= ydiff;
          }
        } else {
          xpos = this.offx + clientRect.left;
          ypos = document.documentElement.scrollTop + clientRect.y + this.offy;
        }
        tooltipEl.style('left', xpos + 'px').style('top', ypos + 'px');
      } else if (event.type == 'mouseout') {
        tooltipEl.transition().duration(this.delayout).style('opacity', 0);
      }
    } catch (e) {
      console.error(e);
    }
  }
}
