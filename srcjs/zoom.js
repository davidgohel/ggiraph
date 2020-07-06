import * as d3 from 'd3';

export default class ZoomHandler {
  constructor(containerid, svgid, min, max) {
    this.containerid = containerid;
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
    const svgid = this.svgid;
    d3.select('#' + this.containerid).call(
      this.zoomer.on('zoom', function () {
        d3.select('#' + svgid + ' > g').attr('transform', d3.event.transform);
      })
    );
  }

  zoomIdentity() {
    d3.select('#' + this.containerid).call(
      this.zoomer.transform,
      d3.zoomIdentity
    );
  }

  zoomOff() {
    d3.select('#' + this.containerid).call(this.zoomer.on('zoom', null));
  }
}
