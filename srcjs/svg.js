import * as d3 from 'd3';
import * as utils from './utils';
import ToolbarHandler from './toolbar.js';
import ZoomHandler from './zoom.js';
import TooltipHandler from './tooltip.js';
import HoverHandler from './hover.js';
import SelectionHandler from './selection.js';

export default class SVGObject {
  constructor(containerid, shinyMode, standaloneMode) {
    this.containerid = containerid;
    this.svgid = null;
    this.handlers = [];
    this.shinyMode = shinyMode;
    this.standaloneMode = standaloneMode;
    this.isIE =
      utils.navigator_id() == 'IE 11' ||
      utils.navigator_id().substring(0, 4) === 'MSIE';
  }

  clear() {
    // clear all handlers
    for (let i = 0; i < this.handlers.length; i++) {
      this.handlers[i].destroy();
    }
    this.handlers = [];

    if (!this.standaloneMode) {
      // remove any old style element
      d3.select('#' + this.containerid + ' style').remove();
    }
    // remove any old container element
    d3.select('#' + this.containerid + ' div.girafe_container_std').remove();
  }

  setSvgId(id) {
    this.svgid = id;
  }

  addStyle(styleArray) {
    const css = styleArray.join(' ').replace(/SVGID_/g, this.svgid);

    d3.select('#' + this.containerid)
      .append('style')
      .attr('type', 'text/css')
      .text(css);
  }

  addSvg(svg, jsstr) {
    if (this.standaloneMode) {
      // append a foreignObject to the svg, as a container for tooltip & toolbar
      d3.select('#' + this.svgid)
        .append('svg:foreignObject')
        .attr('width', '100%')
        .attr('height', '100%')
        .classed('girafe-svg-foreign-object', true)
        .style('pointer-events', 'none');
    } else {
      // append the svg to container
      d3.select('#' + this.containerid)
        .append('div')
        .attr('class', 'girafe_container_std')
        .html(svg);
    }

    if (jsstr) {
      const fun_ = utils.parseFunction(jsstr);
      fun_();
    }
  }

  IEFixResize(width, ratio) {
    if (this.isIE) {
      d3.select('#' + this.svgid).classed('girafe_svg_ie', true);
      d3.select('#' + this.containerid + ' div')
        .classed('girafe_container_ie', true)
        .style('width', Math.round(width * 100) + '%')
        .style('padding-bottom', Math.round(width * ratio * 100) + '%');
    }
  }

  autoScale(csswidth) {
    d3.select('#' + this.svgid)
      .style('width', csswidth)
      .style('height', '100%')
      .style('margin-left', 'auto')
      .style('margin-right', 'auto');
  }

  fixSize(width, height) {
    d3.select('#' + this.svgid).attr('preserveAspectRatio', 'xMidYMin meet');
    if (!this.standaloneMode)
      d3.select('#' + this.containerid + ' .girafe_container_std').style(
        'width',
        '100%'
      );
    d3.select('#' + this.svgid)
      .attr('width', width)
      .attr('height', height);
    d3.select('#' + this.svgid)
      .style('width', width)
      .style('height', height);
  }

  setSizeLimits(width_max, width_min, height_max, height_min) {
    d3.select('#' + this.svgid)
      .style('max-width', width_max)
      .style('max-height', height_max)
      .style('min-width', width_min)
      .style('min-height', height_min);
  }

  removeContainerLimits() {
    if (!this.standaloneMode && !this.isIE) {
      d3.select('#' + this.containerid)
        .style('width', null)
        .style('height', null);
    }
  }

  setupTooltip(
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
    // register tooltip handler
    try {
      const handler = new TooltipHandler(
        this.svgid,
        classPrefix,
        opacity,
        offx,
        offy,
        usecursor,
        usefill,
        usestroke,
        delayover,
        delayout
      );
      if (handler.init(this.standaloneMode)) this.handlers.push(handler);
    } catch (e) {
      console.error(e);
    }
  }

  setupHover(hoverItems) {
    // register hover handlers
    for (let i = 0; i < hoverItems.length; i++) {
      const item = hoverItems[i];
      try {
        const inputId =
          this.shinyMode && item.reactive
            ? this.containerid + item.inputSuffix
            : null;
        const messageId =
          this.shinyMode && item.reactive
            ? this.containerid + item.messageSuffix
            : null;
        const handler = new HoverHandler(
          this.svgid,
          item.classPrefix,
          item.invClassPrefix,
          item.attrName,
          inputId,
          messageId
        );
        if (handler.init(this.standaloneMode)) this.handlers.push(handler);
      } catch (e) {
        console.error(e);
      }
    }
  }

  setupSelection(selectionItems) {
    // register selection handlers
    for (let i = 0; i < selectionItems.length; i++) {
      const item = selectionItems[i];
      try {
        // only add it in shiny or if only_shiny is false
        // also must have a valid selection type
        const addHandler =
          (this.shinyMode || !item.only_shiny) &&
          (item.type == 'single' || item.type == 'multiple');
        if (addHandler) {
          const inputId = this.shinyMode
            ? this.containerid + item.inputSuffix
            : null;
          const messageId = this.shinyMode
            ? this.containerid + item.messageSuffix
            : null;
          const handler = new SelectionHandler(
            this.svgid,
            item.classPrefix,
            item.attrName,
            inputId,
            messageId,
            item.type,
            item.selected
          );
          // init will return false if there is nothing to select
          if (handler.init(this.standaloneMode)) this.handlers.push(handler);
        }
      } catch (e) {
        console.error(e);
      }
    }
  }

  setupZoom(min, max) {
    // register zoom handler
    try {
      const handler = new ZoomHandler(this.containerid, this.svgid, min, max);
      if (handler.init(this.standaloneMode)) this.handlers.push(handler);
    } catch (e) {
      console.error(e);
    }
  }

  setupToolbar(className, position, saveaspng, pngname) {
    // register toolbar handler
    try {
      // for zoom tools, we need the active zoom handler if exists
      let zoomHandler = null;
      // for lasso tools, we only need the active data selection handler if exists
      let selectionHandler = null;
      for (let i = 0; i < this.handlers.length; i++) {
        const h = this.handlers[i];
        if (h instanceof ZoomHandler) {
          zoomHandler = h;
        } else if (
          h instanceof SelectionHandler &&
          h.attrName == 'data-id' &&
          h.type == 'multiple'
        ) {
          selectionHandler = h;
        }
      }
      const handler = new ToolbarHandler(
        this.containerid,
        this.svgid,
        className,
        position,
        zoomHandler,
        selectionHandler,
        saveaspng,
        pngname
      );
      if (handler.init(this.standaloneMode)) this.handlers.push(handler);
    } catch (e) {
      console.error(e);
    }
  }
}
