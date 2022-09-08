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
          x.settings.capture.css,
          x.settings.captureinv.css,
          x.settings.capturekey.css,
          x.settings.capturetheme.css,
          x.settings.hoverinv.css,
          x.settings.hover.css,
          x.settings.hoverkey.css,
          x.settings.hovertheme.css
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

        ggobj.setupHover([
          {
            classPrefix: 'hover',
            attrName: 'data-id',
            inputSuffix: '_hovered',
            messageSuffix: '_hovered_set',
            reactive: x.settings.hover.reactive,
            invClassPrefix:
              x.settings.hoverinv.css.length > 0 ? 'hover_inv' : null
          },
          {
            classPrefix: 'hover_key',
            attrName: 'key-id',
            inputSuffix: '_key_hovered',
            messageSuffix: '_key_hovered_set',
            reactive: x.settings.hoverkey.reactive,
            invClassPrefix: null
          },
          {
            classPrefix: 'hover_theme',
            attrName: 'theme-id',
            inputSuffix: '_theme_hovered',
            messageSuffix: '_theme_hovered_set',
            reactive: x.settings.hovertheme.reactive,
            invClassPrefix: null
          }
        ]);

        ggobj.setupSelection([
          {
            classPrefix: 'selected',
            attrName: 'data-id',
            inputSuffix: '_selected',
            messageSuffix: '_set',
            type: x.settings.capture.type,
            only_shiny: x.settings.capture.only_shiny,
            selected: x.settings.capture.selected,
            invClassPrefix:
              x.settings.captureinv.css.length > 0 ? 'selected_inv' : null
          },
          {
            classPrefix: 'selected_key',
            attrName: 'key-id',
            inputSuffix: '_key_selected',
            messageSuffix: '_key_set',
            type: x.settings.capturekey.type,
            only_shiny: x.settings.capturekey.only_shiny,
            selected: x.settings.capturekey.selected
          },
          {
            classPrefix: 'selected_theme',
            attrName: 'theme-id',
            inputSuffix: '_theme_selected',
            messageSuffix: '_theme_set',
            type: x.settings.capturetheme.type,
            only_shiny: x.settings.capturetheme.only_shiny,
            selected: x.settings.capturetheme.selected
          }
        ]);

        ggobj.setupZoom(x.settings.zoom.min, x.settings.zoom.max);

        ggobj.setupToolbar(
          'ggiraph-toolbar',
          x.settings.toolbar.position,
          x.settings.toolbar.saveaspng,
          x.settings.toolbar.pngname
        );

        ggobj.setupTooltip(
          'tooltip',
          x.settings.tooltip.placement,
          x.settings.tooltip.opacity,
          x.settings.tooltip.offx,
          x.settings.tooltip.offy,
          x.settings.tooltip.use_cursor_pos,
          x.settings.tooltip.usefill,
          x.settings.tooltip.usestroke,
          x.settings.tooltip.delay.over,
          x.settings.tooltip.delay.out
        );
      },

      resize: function (width, height) {}
    };
  };
}
