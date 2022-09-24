import * as d3 from 'd3';
import { isIE, parseFunction } from './utils';
import ToolbarHandler from './toolbar.js';
import ZoomHandler from './zoom.js';
import TooltipHandler from './tooltip.js';
import HoverHandler from './hover.js';
import SelectionHandler from './selection.js';
import { MouseHandler, EVENT_TYPES } from './mouse.js';
import NearestHandler from './nearest.js';
import PngHandler from './png.js';

export default class SVGObject {
  constructor(containerid, shinyMode) {
    this.containerid = containerid;
    this.svgid = null;
    this.handlers = new Map();
    this.shinyMode = shinyMode;
  }

  clear() {
    // clear all handlers
    this.handlers.forEach((h) => h.destroy());
    this.handlers.clear();

    // remove any old style element
    d3.select('#' + this.containerid + ' style').remove();

    // remove any old container element
    d3.select('#' + this.containerid + ' div.girafe_container_std').remove();
  }

  setSvgId(id) {
    this.svgid = id;
  }

  addStyle(styleArray) {
    const css = styleArray.join('\n').replace(/SVGID_/g, this.svgid);

    d3.select('#' + this.containerid)
      .append('style')
      .attr('type', 'text/css')
      .text(css);
  }

  addSvg(svg, jsstr) {
    d3.select('#' + this.containerid)
      .append('div')
      .attr('class', 'girafe_container_std')
      .html(svg);

    if (jsstr) {
      const fun_ = parseFunction(jsstr);
      fun_();
    }
  }

  IEFixResize(width, ratio) {
    if (isIE()) {
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
    d3.select('#' + this.containerid + ' .girafe_container_std').style(
      'width',
      '100%'
    );
    d3.select('#' + this.svgid)
      .attr('width', width)
      .attr('height', height);
    d3.select('#' + this.svgid)
      .style('width', width + 'px')
      .style('height', height + 'px');
  }

  setSizeLimits(width_max, width_min, height_max, height_min) {
    d3.select('#' + this.svgid)
      .style('max-width', width_max)
      .style('max-height', height_max)
      .style('min-width', width_min)
      .style('min-height', height_min);
  }

  removeContainerLimits() {
    if (!isIE()) {
      d3.select('#' + this.containerid)
        .style('width', null)
        .style('height', null);
    }
  }

  setupTooltip(options) {
    // register tooltip handler
    try {
      options.classPrefix = 'tooltip';
      const handler = new TooltipHandler(this.svgid, options);
      if (handler.init()) this.handlers.set('tooltip', handler);
    } catch (e) {
      console.error(e);
    }
  }

  setupHover(hover, hover_inv, hover_key, hover_theme) {
    hover.classPrefix = 'hover_data';
    hover.attrName = 'data-id';
    hover.shinyInputSuffix = '_hovered';
    hover.shinyMessageSuffix = '_hovered_set';
    hover.invClassPrefix = hover_inv.css.length > 0 ? 'hover_inv' : null;
    hover_key.classPrefix = 'hover_key';
    hover_key.attrName = 'key-id';
    hover_key.shinyInputSuffix = '_key_hovered';
    hover_key.shinyMessageSuffix = '_key_hovered_set';
    hover_theme.classPrefix = 'hover_theme';
    hover_theme.attrName = 'theme-id';
    hover_theme.shinyInputSuffix = '_theme_hovered';
    hover_theme.shinyMessageSuffix = '_theme_hovered_set';

    const hoverItems = [hover, hover_key, hover_theme];
    let handler;
    // register hover handlers
    try {
      hoverItems.forEach(function (options) {
        options.shinyInputId =
          this.shinyMode && options.reactive
            ? this.containerid + options.shinyInputSuffix
            : null;
        options.shinyMessageId =
          this.shinyMode && options.reactive
            ? this.containerid + options.shinyMessageSuffix
            : null;
        handler = new HoverHandler(this.svgid, options);
        if (handler.init()) this.handlers.set(options.classPrefix, handler);
      }, this);
    } catch (e) {
      console.error(e);
    }
    // register nearest handler
    try {
      handler = new NearestHandler(
        this.svgid,
        [hover.attrName],
        hover.nearest_distance
      );
      if (handler.init()) this.handlers.set('nearest', handler);
    } catch (e) {
      console.error(e);
    }
  }

  setupSelection(select, select_inv, select_key, select_theme) {
    select.classPrefix = 'select_data';
    select.attrName = 'data-id';
    select.shinyInputSuffix = '_selected';
    select.shinyMessageSuffix = '_set';
    select.invClassPrefix = select_inv.css.length > 0 ? 'select_inv' : null;
    select_key.classPrefix = 'select_key';
    select_key.attrName = 'key-id';
    select_key.shinyInputSuffix = '_key_selected';
    select_key.shinyMessageSuffix = '_key_set';
    select_theme.classPrefix = 'select_theme';
    select_theme.attrName = 'theme-id';
    select_theme.shinyInputSuffix = '_theme_selected';
    select_theme.shinyMessageSuffix = '_theme_set';

    const selectionItems = [select, select_key, select_theme];
    let handler;
    // register selection handlers
    try {
      selectionItems.forEach(function (options) {
        // only add it in shiny or if only_shiny is false
        if (this.shinyMode || !options.only_shiny) {
          options.shinyInputId = this.shinyMode
            ? this.containerid + options.shinyInputSuffix
            : null;
          options.shinyMessageId = this.shinyMode
            ? this.containerid + options.shinyMessageSuffix
            : null;
          handler = new SelectionHandler(this.svgid, options);
          // init will return false if there is nothing to select
          if (handler.init()) this.handlers.set(options.classPrefix, handler);
        }
      }, this);
    } catch (e) {
      console.error(e);
    }
  }

  setupMouse() {
    // register mouse handler
    try {
      // a map with arrays of the handlers that should act on each event
      const mouseHandlers = new Map();
      EVENT_TYPES.forEach((type) => mouseHandlers.set(type, []));

      this.handlers.forEach(function (h) {
        if (h instanceof TooltipHandler) {
          mouseHandlers.get('mouseover').push(h);
          mouseHandlers.get('mouseout').push(h);
          mouseHandlers.get('mousemove').push(h);
          mouseHandlers.get('mousedown').push(h);
          mouseHandlers.get('wheel').push(h);
          mouseHandlers.get('nearest').push(h);
        } else if (h instanceof HoverHandler) {
          mouseHandlers.get('mouseover').push(h);
          mouseHandlers.get('mouseout').push(h);
          mouseHandlers.get('nearest').push(h);
        } else if (h instanceof SelectionHandler) {
          mouseHandlers.get('click').push(h);
        } else if (h instanceof ToolbarHandler) {
          mouseHandlers.get('mouseover').push(h);
          mouseHandlers.get('mouseout').push(h);
        }
      });

      const handler = new MouseHandler(
        this.svgid,
        mouseHandlers,
        this.handlers.get('nearest')
      );
      if (handler.init()) this.handlers.set('mouse', handler);
    } catch (e) {
      console.error(e);
    }
  }

  setupZoom(options) {
    // register zoom handler
    try {
      const handler = new ZoomHandler(this.svgid, options);
      if (handler.init()) this.handlers.set('zoom', handler);
    } catch (e) {
      console.error(e);
    }
  }

  setupToolbar(options) {
    // register png handler
    let handler;
    try {
      if (!options.hidden.includes('saveaspng')) {
        handler = new PngHandler(this.svgid, { pngname: options.pngname });
        if (handler.init()) this.handlers.set('png', handler);
      }
    } catch (e) {
      console.error(e);
    }
    // register toolbar handler
    try {
      const providers = [];
      this.handlers.forEach(function (h) {
        if (
          h instanceof PngHandler ||
          h instanceof ZoomHandler ||
          (h instanceof SelectionHandler &&
            h.attrName == 'data-id' &&
            h.type == 'multiple')
        )
          providers.push(h);
      });
      options.clsName = 'ggiraph-toolbar';
      handler = new ToolbarHandler(this.containerid, this.svgid, options);
      if (handler.init(providers)) this.handlers.set('toolbar', handler);
    } catch (e) {
      console.error(e);
    }
  }
}
