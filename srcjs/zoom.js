import * as d3 from 'd3';

export default class ZoomHandler {
  constructor(svgid, min, max) {
    this.svgid = svgid;
    this.min = min;
    this.max = max;
    this.zoomer = null;
  }

  init() {
    if (this.min === 1 && this.max <= 1) {
      // nothing to do here, return false to discard this
      return false;
    }
    this.zoomer = d3.zoom().scaleExtent([this.min, this.max]);
    return true;
  }

  destroy() {
    this.zoomOff();
    this.zoomer = null;
  }

  zoomOn() {
    const targetEl = d3.select('#' + this.svgid + '_rootg');
    d3.select('#' + this.svgid).call(
      this.zoomer
        .on('start', function () {
          targetEl.style('cursor', 'move');
        })
        .on('zoom', function () {
          targetEl.attr('transform', d3.event.transform);
        })
        .on('end', function () {
          targetEl.style('cursor', 'auto');
        })
    );
  }

  zoomIdentity() {
    d3.select('#' + this.svgid).call(this.zoomer.transform, d3.zoomIdentity);
  }

  zoomOff() {
    d3.select('#' + this.svgid).call(this.zoomer.on('zoom', null));
  }
}
