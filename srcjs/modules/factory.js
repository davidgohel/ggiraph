import * as d3 from 'd3';
import SVGObject from './svg.js';

// Returns a factory function for HTMLWidgets
export function factory(shinyMode) {
  return function (el, width, height) {
    const ggobj = new SVGObject(el.id, shinyMode);

    return {
      renderValue: function (x) {
        ggobj.clear();

        ggobj.setSvgId(x.uid);
        ggobj.addStyle([
          x.settings.tooltip.css,
          x.settings.select_inv.css,
          x.settings.select.css,
          x.settings.select_key.css,
          x.settings.select_theme.css,
          x.settings.hover_inv.css,
          x.settings.hover.css,
          x.settings.hover_key.css,
          x.settings.hover_theme.css
        ]);
        ggobj.addSvg(x.html, x.js);

        const box = d3.select('#' + ggobj.svgid).property('viewBox').baseVal;
        if (!x.settings.sizing.rescale) {
          ggobj.fixSize(box.width, box.height);
          d3.select(el).style('width', null).style('height', null);
        } else if (shinyMode) {
          ggobj.autoScale('100%');
          ggobj.IEFixResize(1, 1 / x.ratio);
          ggobj.setSizeLimits(
            d3.select(el).style('width'),
            0,
            d3.select(el).style('height'),
            0
          );
          //ggobj.removeContainerLimits();
        } else {
          ggobj.autoScale(Math.round(x.settings.sizing.width * 100) + '%');
          ggobj.IEFixResize(x.settings.sizing.width, 1 / x.ratio);
          ggobj.setSizeLimits('unset', 'unset', 'unset', 'unset');
          ggobj.removeContainerLimits();
        }

        ggobj.setupHover(
          x.settings.hover,
          x.settings.hover_inv,
          x.settings.hover_key,
          x.settings.hover_theme
        );

        ggobj.setupSelection(
          x.settings.select,
          x.settings.select_inv,
          x.settings.select_key,
          x.settings.select_theme
        );

        ggobj.setupZoom(x.settings.zoom);

        ggobj.setupToolbar(x.settings.toolbar);

        ggobj.setupTooltip(x.settings.tooltip);

        ggobj.setupMouse();
      },

      resize: function (width, height) {}
    };
  };
}
