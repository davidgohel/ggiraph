function isArray(x) {
    return x.constructor.toString().indexOf("Array") > -1;
}

function set_reactive(x, id ){

  Shiny.addCustomMessageHandler(id + '_set', function(message) {
    if( typeof message === 'string' ) {
      x.setSelected([message]);
    } else if( isArray(message) ){
      x.setSelected(message);
    }
  });
  Shiny.addCustomMessageHandler(id + '_key_set', function(message) {
    if( typeof message === 'string' ) {
      x.setKeySelected([message]);
    } else if( isArray(message) ){
      x.setKeySelected(message);
    }
  });
  Shiny.addCustomMessageHandler(id + '_theme_set', function(message) {
    if( typeof message === 'string' ) {
      x.setThemeSelected([message]);
    } else if( isArray(message) ){
      x.setThemeSelected(message);
    }
  });

}



HTMLWidgets.widget({

  name: "girafe",

  type: "output",

  factory: function(el, width, height) {
    var ggobj = ggiraphjs.newgi(el.id);

    return {
      renderValue: function(x) {
        ggobj.setSvgId(x.uid);
        ggobj.addStyle(x.settings.tooltip.css,
            x.settings.hover.css, x.settings.hoverkey.css, x.settings.hovertheme.css,
            x.settings.capture.css, x.settings.capturekey.css, x.settings.capturetheme.css);
        ggobj.setZoomer(x.settings.zoom.min, x.settings.zoom.max);
        ggobj.addSvg(x.html, x.js);
        ggobj.animateGElements(x.settings.tooltip.opacity,
            x.settings.tooltip.offx, x.settings.tooltip.offy,
            x.settings.tooltip.use_cursor_pos,
            x.settings.tooltip.delay.over, x.settings.tooltip.delay.out,
            x.settings.tooltip.usefill, x.settings.tooltip.usestroke);
        ggobj.animateToolbar();

        if( !x.settings.sizing.rescale ){
          var width_ = d3.select(el).style("width");
          var height_ = d3.select(el).style("height");
          ggobj.fixSize(width_, height_);
        } else if( HTMLWidgets.shinyMode ){
          ggobj.autoScale("100%");
          ggobj.IEFixResize(1, 1/x.ratio);
          var maxWidth = width;
          var maxHeight = height;
          try {
            const box = d3.select("#" + ggobj.svgid).property("viewBox").baseVal;
            maxWidth = box.width;
            maxHeight = box.height;
          } catch (e) {}
          ggobj.setSizeLimits(maxWidth+'px', 0, maxHeight+'px', 0);
          ggobj.removeContainerLimits();
        } else {
          ggobj.autoScale(Math.round(x.settings.sizing.width * 100) + "%");
          ggobj.IEFixResize(x.settings.sizing.width, 1/x.ratio);
          ggobj.setSizeLimits("unset", "unset", "unset", "unset");
          ggobj.removeContainerLimits();
        }

        var addSelection = ggobj.isSelectable() &&
          (( HTMLWidgets.shinyMode &&
            ( x.settings.capture.only_shiny ||
              x.settings.capturekey.only_shiny ||
              x.settings.capturetheme.only_shiny)
          ) ||
          ( !HTMLWidgets.shinyMode &&
            ( !x.settings.capture.only_shiny ||
              !x.settings.capturekey.only_shiny ||
              !x.settings.capturetheme.only_shiny)
          ));

        var addZoom = true;
        if( x.settings.zoom.min === 1 && x.settings.zoom.max <= 1 ){
          addZoom = false;
        }

        if( addSelection && x.settings.capturetheme.type == "single" ){
          ggobj.selectizeThemeSingle();
          if( typeof x.settings.capturetheme.selected === 'string' ) {
            ggobj.setThemeSelected([x.settings.capturetheme.selected]);
          }
        } else if( addSelection && x.settings.capturetheme.type == "multiple" ){
          ggobj.selectizeThemeMultiple();
          if( typeof x.settings.capturetheme.selected === 'string' ) {
            ggobj.setThemeSelected([x.settings.capturetheme.selected]);
          } else if( isArray(x.settings.capturetheme.selected) ){
            ggobj.setThemeSelected(x.settings.capturetheme.selected);
          }
        } else {
          ggobj.selectizeThemeNone();
        }

        if( addSelection && x.settings.capturekey.type == "single" ){
          ggobj.selectizeKeySingle();
          if( typeof x.settings.capturekey.selected === 'string' ) {
            ggobj.setKeySelected([x.settings.capturekey.selected]);
          }
        } else if( addSelection && x.settings.capturekey.type == "multiple" ){
          ggobj.selectizeKeyMultiple();
          if( typeof x.settings.capturekey.selected === 'string' ) {
            ggobj.setKeySelected([x.settings.capturekey.selected]);
          } else if( isArray(x.settings.capturekey.selected) ){
            ggobj.setKeySelected(x.settings.capturekey.selected);
          }
        } else {
          ggobj.selectizeKeyNone();
        }

        if( addSelection && x.settings.capture.type == "single" ){
          ggobj.selectizeSingle();
          addSelection = false;
          if( typeof x.settings.capture.selected === 'string' ) {
            ggobj.setSelected([x.settings.capture.selected]);
          }

        } else if( addSelection && x.settings.capture.type == "multiple" ){
          ggobj.selectizeMultiple();
          if( typeof x.settings.capture.selected === 'string' ) {
            ggobj.setSelected([x.settings.capture.selected]);
          } else if( isArray(x.settings.capture.selected) ){
            ggobj.setSelected(x.settings.capture.selected);
          }
        } else {
          ggobj.selectizeNone();
          addSelection = false;
        }

        ggobj.addUI(addSelection, addZoom,
          x.settings.toolbar.saveaspng,
          'ggiraph-toolbar-' + x.settings.toolbar.position);

        if( HTMLWidgets.shinyMode ){
          ggobj.setInputId(el.id + "_selected");
          ggobj.setInputKeyId(el.id + "_key_selected");
          ggobj.setInputThemeId(el.id + "_theme_selected");
          set_reactive(ggobj, el.id );
        }

      },

      resize: function(width, height) {
        //ggobj.setSize(width, height);
      }

    };
  }
});
