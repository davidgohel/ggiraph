import * as d3 from 'd3';

export default class ZoomHandler {
  constructor(svgid, options) {
    this.svgid = svgid;
    this.min = options.min;
    this.max = options.max;
    this.duration = options.duration;
    this.tooltips = options.tooltips || {};
    this.default_on = options.default_on || false;
    this.zoomer = null;
    this.on = false;
  }

  init() {
    if (this.max <= this.min) {
      // nothing to do here, return false to discard this
      return false;
    }
    this.zoomer = d3
      .zoom()
      .scaleExtent([this.min, this.max])
      .duration(this.duration);
    this.on = false;

    // Auto-activate zoom if requested
    if (this.default_on) {
      // Delay activation to ensure SVG is ready
      setTimeout(() => {
        this.zoomOn();
        // Update button state if toolbar exists
        this.updateButtonState();
      }, 100);
    }

    return true;
  }

  destroy() {
    this.zoomOff();
    this.zoomer = null;
  }

  getButtons() {
    const that = this;
    return [
      {
        key: 'zoom_onoff',
        block: 'zoom',
        current_state: 'zoom_on',
        states: {
          zoom_on: {
            class: 'neutral',
            unclass: 'drop',
            tooltip: 'activate pan/zoom',
            icon: "<svg xmlns='http://www.w3.org/2000/svg' role='img' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/></g></svg>"
          },
          zoom_off: {
            class: 'drop',
            unclass: 'neutral',
            tooltip: 'deactivate pan/zoom',
            icon: "<svg xmlns='http://www.w3.org/2000/svg' role='img' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/><line y2='455' x2='0' y1='0' x1='416' stroke-width='30'/></g></svg>"
          }
        },
        onclick: function (dat) {
          const el = d3.select(this);
          let state;
          let stateKey;
          if (that.on) {
            that.zoomOff();
            state = dat.zoom_on;
            stateKey = 'zoom_on';
          } else {
            that.zoomOn();
            state = dat.zoom_off;
            stateKey = 'zoom_off';
          }
          const tooltip = that.tooltips[stateKey] || state.tooltip;
          el.attr('title', tooltip)
            .classed(state.class, true)
            .classed(state.unclass, false)
            .html(state.icon);
        }
      },
      {
        key: 'zoom_rect',
        block: 'zoom',
        class: 'neutral',
        tooltip: 'zoom with rectangle',
        icon: "<svg xmlns='http://www.w3.org/2000/svg' role='img' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/><rect x='126' y='153' width='152' height='116' stroke-width='25' fill='transparent'/></g></svg>",
        onclick: function () {
          that.zoomRect();
        }
      },
      {
        key: 'zoom_reset',
        block: 'zoom',
        class: 'neutral',
        tooltip: 'reset pan/zoom',
        icon: "<svg xmlns='http://www.w3.org/2000/svg' role='img' viewBox='0 0 512 512'><g><polygon points='274,209.7 337.9,145.9 288,96 416,96 416,224 366.1,174.1 302.3,238 '/><polygon points='274,302.3 337.9,366.1 288,416 416,416 416,288 366.1,337.9 302.3,274'/><polygon points='238,302.3 174.1,366.1 224,416 96,416 96,288 145.9,337.9 209.7,274'/><polygon points='238,209.7 174.1,145.9 224,96 96,96 96,224 145.9,174.1 209.7,238'/></g></svg>",
        onclick: function () {
          that.zoomIdentity();
        }
      }
    ];
  }

  zoomOn() {
    if (!this.on) {
      this.on = true;
      const targetEl = d3.select('#' + this.svgid + '_rootg');
      d3.select('#' + this.svgid).call(
        this.zoomer
          .on('start', function () {
            targetEl.style('cursor', 'move');
          })
          .on('zoom', function (event) {
            targetEl.attr('transform', event.transform);
          })
          .on('end', function () {
            targetEl.style('cursor', 'auto');
          })
      );
    }
  }

  zoomIdentity() {
    // check the current transfrom, if it's already identity
    const t = d3.zoomTransform(d3.select('#' + this.svgid + '_rootg').node());
    if (t.k === 1 && t.x === 0 && t.y === 0) return;

    // temporarirly activate zoom
    const wason = this.on;
    if (!wason) this.zoomOn();

    // apply identity
    const that = this;
    d3.select('#' + this.svgid)
      .transition()
      .duration(this.duration)
      .on('end', function () {
        if (!wason) that.zoomOff();
      })
      .call(this.zoomer.transform, d3.zoomIdentity);
  }

  zoomOff() {
    if (this.on) {
      this.on = false;
      d3.select('#' + this.svgid).on('.zoom', null);
    }
  }

  updateButtonState() {
    // Update the toolbar button state to reflect current zoom state
    const button = d3.select('.ggiraph-toolbar-icon-zoom_onoff');
    if (!button.empty()) {
      const data = button.datum();
      if (data) {
        const state = this.on ? data.zoom_off : data.zoom_on;
        const stateKey = this.on ? 'zoom_off' : 'zoom_on';
        const tooltip = this.tooltips[stateKey] || state.tooltip;

        button
          .attr('title', tooltip)
          .classed(state.class, true)
          .classed(state.unclass, false)
          .html(state.icon);
      }
    }
  }

  zoomRect() {
    // temporarirly activate zoom
    const wason = this.on;
    if (!wason) this.zoomOn();

    const svgEl = d3.select('#' + this.svgid);
    const targetEl = d3.select('#' + this.svgid + '_rootg');
    const that = this;

    // define dragrect
    const dragrect_ = dragrect();
    const dragrect_start = function () {
      targetEl.style('cursor', 'zoom-in');
    };
    const dragrect_end = function () {
      try {
        targetEl.style('cursor', 'auto');
        targetEl.on('.dragstart', null).on('.drag', null).on('.dragend', null);
        targetEl.selectAll('g.dragrect').remove();
        // get the rect
        const rect = dragrect_.rect();

        // check that it's large enough
        const minsize = 10;
        if (rect.width >= minsize && rect.height >= minsize) {
          // center point
          const rx = rect.x + rect.width / 2;
          const ry = rect.y + rect.height / 2;

          // viewbox
          const box = targetEl.node().getBBox();
          const bx = box.x + box.width / 2;
          const by = box.y + box.height / 2;
          const asp = box.width / box.height;

          // adapt rect to aspect ratio
          if (rect.height > rect.width) {
            rect.width = rect.height * asp;
            rect.x = rx - rect.width / 2;
          } else {
            rect.height = rect.width / asp;
            rect.y = ry - rect.height / 2;
          }

          // calculate new scale
          const scale = Math.max(
            Math.min(box.width / rect.width, that.max),
            that.min
          );

          // adapt rect to scale
          rect.width = box.width / scale;
          rect.height = box.height / scale;
          rect.x = rx - rect.width / 2;
          rect.y = ry - rect.height / 2;

          // calculate new translate
          const tx = (bx - rx - (box.width - rect.width) / 2) * scale;
          const ty = (by - ry - (box.height - rect.height) / 2) * scale;

          // set the transform
          svgEl
            .transition()
            .duration(that.duration)
            .on('end', function () {
              if (!wason) that.zoomOff();
            })
            .call(
              that.zoomer.transform,
              d3.zoomIdentity.translate(tx, ty).scale(scale)
            );
        }
      } catch (e) {
        console.error(e);
      }
    };

    try {
      // call dragrect
      targetEl.call(
        dragrect_
          .targetArea(targetEl)
          .on('start', dragrect_start)
          .on('end', dragrect_end)
      );
    } catch (e) {
      console.error(e);
    }
  }
}

// draw a rect by dragging
function dragrect() {
  let targetArea;
  const rect = new DOMRect();
  const on = {
    start: function () {},
    draw: function () {},
    end: function () {}
  };

  // function to execute on call
  function dragrect(_this) {
    // add a new group for the rect
    const g = _this.append('g').attr('class', 'dragrect');
    // add the drawn rect
    const rectEl = g.append('rect');

    // rect points
    let p1;
    let p2;

    // drag behavior
    const dragAction = d3
      .drag()
      .on('start', dragstart)
      .on('drag', dragmove)
      .on('end', dragend);
    targetArea.call(dragAction);

    function dragstart() {
      p1 = null;
      p2 = null;
      on.start();
    }

    function dragmove(event) {
      // mouse position within drawing area
      const point = d3.pointer(event, this);
      const tx = point[0];
      const ty = point[1];

      // initialize the points or set the latest point
      if (!p1) {
        p1 = new DOMPoint(tx, ty);
        p2 = new DOMPoint(tx, ty);
      } else {
        p2.x = tx;
        p2.y = ty;
      }

      // draw rect
      const minx = Math.min(p1.x, p2.x);
      const maxx = Math.max(p1.x, p2.x);
      const miny = Math.min(p1.y, p2.y);
      const maxy = Math.max(p1.y, p2.y);
      rect.x = minx;
      rect.y = miny;
      rect.width = maxx - minx;
      rect.height = maxy - miny;
      rectEl.attr('x', rect.x);
      rectEl.attr('y', rect.y);
      rectEl.attr('width', rect.width);
      rectEl.attr('height', rect.height);

      on.draw();
    }

    function dragend() {
      rectEl.attr('display', 'none');

      on.end();
    }
  }

  // events
  dragrect.on = function (type, _) {
    if (!arguments.length) return on;
    if (arguments.length === 1) return on[type];
    const types = ['start', 'draw', 'end'];
    if (types.indexOf(type) > -1) {
      on[type] = _;
    }
    return dragrect;
  };

  // area where dragrect can be triggered from
  dragrect.targetArea = function (_) {
    if (!arguments.length) return targetArea;
    targetArea = _;
    return dragrect;
  };

  // the rect
  dragrect.rect = function () {
    return rect;
  };

  return dragrect;
}
