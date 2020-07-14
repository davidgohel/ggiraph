import * as d3 from 'd3';

export default class ToolbarHandler {
  constructor(
    containerid,
    svgid,
    classname,
    position,
    zoomHandler,
    selectionHandler,
    saveaspng,
    pngname
  ) {
    this.containerid = containerid;
    this.svgid = svgid;
    this.clsName = classname;
    this.position = position;
    this.zoomHandler = zoomHandler;
    this.selectionHandler = selectionHandler;
    // use feature only if save-svg-as-png module is loaded
    this.saveaspng = saveaspng && typeof saveSvgAsPng === 'function';
    this.pngname = pngname;
  }

  init(standaloneMode) {
    // we need at least one of zoom/lasso/savesapng buttons
    if (!(this.zoomHandler || this.selectionHandler || this.saveaspng)) {
      // nothing to do here, return false to discard this
      return false;
    }

    let containerEl;
    if (standaloneMode) {
      containerEl = d3.select(
        '#' + this.svgid + ' > foreignObject.girafe-svg-foreign-object'
      );
    } else {
      containerEl = d3.select(
        '#' + this.containerid + ' .girafe_container_std'
      );
    }
    const toolbarEl = containerEl
      .insert('xhtml:div', standaloneMode ? ':first-child' : null)
      .classed(this.clsName, true)
      .classed(this.clsName + '-' + this.position, true)
      .style('pointer-events', 'all');

    const that = this;
    if (this.selectionHandler) {
      const divToolbarSelect = toolbarEl
        .append('xhtml:div')
        .classed(this.clsName + '-block', true);

      divToolbarSelect
        .append('xhtml:a')
        .classed(this.clsName + '-icon', true)
        .classed('neutral', true)
        .attr('title', 'lasso selection')
        .on('click', function () {
          that.selectionHandler.lasso(true);
        })
        .html(ICONS.lasso_on);

      divToolbarSelect
        .append('xhtml:a')
        .classed(this.clsName + '-icon', true)
        .classed('drop', true)
        .attr('title', 'lasso deselection')
        .on('click', function () {
          that.selectionHandler.lasso(false);
        })
        .html(ICONS.lasso_off);
    }

    if (this.zoomHandler) {
      const divToolbarZoom = toolbarEl
        .append('xhtml:div')
        .classed(this.clsName + '-block', true);

      divToolbarZoom
        .append('xhtml:a')
        .classed(this.clsName + '-icon', true)
        .classed('neutral', true)
        .attr('title', 'pan-zoom reset')
        .on('click', function () {
          that.zoomHandler.zoomIdentity();
        })
        .html(ICONS.pan_zoom_reset);

      divToolbarZoom
        .append('xhtml:a')
        .classed(this.clsName + '-icon', true)
        .classed('neutral', true)
        .attr('title', 'activate pan-zoom')
        .on('click', function () {
          that.zoomHandler.zoomOn();
        })
        .html(ICONS.zoom_on);

      divToolbarZoom
        .append('xhtml:a')
        .classed(this.clsName + '-icon', true)
        .classed('drop', true)
        .attr('title', 'deactivate pan-zoom')
        .on('click', function () {
          that.zoomHandler.zoomOff();
        })
        .html(ICONS.zoom_off);
    }

    if (this.saveaspng) {
      const divToolbarMisc = toolbarEl
        .append('xhtml:div')
        .classed(this.clsName + '-block', true);

      divToolbarMisc
        .append('xhtml:a')
        .classed(this.clsName + '-icon', true)
        .classed('neutral', true)
        .attr('title', 'download png')
        .on('click', function () {
          if (
            typeof Promise !== 'undefined' &&
            Promise.toString().indexOf('[native code]') !== -1
          ) {
            saveSvgAsPng(
              document.getElementById(that.svgid),
              that.pngname + '.png',
              { encoderOptions: 1 }
            );
          } else {
            console.error('This navigator does not support Promises');
          }
        })
        .html(ICONS.save_as_png);
    }

    // add event listeners
    const containerNode = d3.select('#' + this.containerid).node();
    containerNode.addEventListener('mouseover', this);
    containerNode.addEventListener('mouseout', this);

    // return true to add to list of handLers
    return true;
  }

  destroy() {
    const container = d3.select('#' + this.containerid);
    const toolbarEl = container.select('.' + this.clsName);

    // remove event listeners
    try {
      container.node().removeEventListener('mouseover', this);
      container.node().removeEventListener('mouseout', this);
    } catch (e) {
      console.error(e);
    }

    // remove button listeners
    try {
      toolbarEl.selectAll('.' + this.clsName + '-icon').on('click', null);
    } catch (e) {
      console.error(e);
    }

    // remove element
    toolbarEl.remove();
  }

  handleEvent(event) {
    try {
      const toolbarEl = d3
        .select('#' + this.containerid)
        .select('.' + this.clsName);
      if (event.type == 'mouseover') {
        toolbarEl.transition().duration(200).style('opacity', 0.8);
      } else if (event.type == 'mouseout') {
        toolbarEl.transition().duration(500).style('opacity', 0);
      }
    } catch (e) {
      console.error(e);
    }
  }
}

const ICONS = {
  lasso_on:
    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 230 230'><g><ellipse ry='65.5' rx='86.5' cy='94' cx='115.5' stroke-width='20' fill='transparent'/><ellipse ry='11.500001' rx='10.5' cy='153' cx='91.5' stroke-width='20' fill='transparent'/><line y2='210.5' x2='105' y1='164.5' x1='96' stroke-width='20'/></g></svg>",

  lasso_off:
    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 230 230'><g><ellipse ry='65.5' rx='86.5' cy='94' cx='115.5' stroke-width='20' fill='transparent'/><ellipse ry='11.500001' rx='10.5' cy='153' cx='91.5' stroke-width='20' fill='transparent'/><line y2='210.5' x2='105' y1='164.5' x1='96' stroke-width='20'/></g></svg>",

  pan_zoom_reset:
    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 512 512'><g><polygon points='274,209.7 337.9,145.9 288,96 416,96 416,224 366.1,174.1 302.3,238 '/><polygon points='274,302.3 337.9,366.1 288,416 416,416 416,288 366.1,337.9 302.3,274'/><polygon points='238,302.3 174.1,366.1 224,416 96,416 96,288 145.9,337.9 209.7,274'/><polygon points='238,209.7 174.1,145.9 224,96 96,96 96,224 145.9,174.1 209.7,238'/></g></svg>",

  zoom_on:
    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/></g></svg>",

  zoom_off:
    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/><line y2='455' x2='0' y1='0' x1='416' stroke-width='30'/></g></svg>",

  save_as_png:
    "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 512 512'><g><polygon points='95 275 95 415 415 415 415 275 375 275 375 380 135 380 135 275'/><polygon points='220 30 220 250 150 175 150 245 250 345 350 245 350 175 280 250 280 30'/></g></svg>"
};
