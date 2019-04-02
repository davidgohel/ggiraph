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

}



HTMLWidgets.widget({

  name: "girafe",

  type: "output",

  factory: function(el, width, height) {
    var ggobj = ggiraphjs.newgi(el.id);

    return {
      renderValue: function(x) {
        ggobj.setSvgId(x.uid);
        ggobj.addStyle(x.settings.tooltip.css, x.settings.hover.css, x.settings.capture.css);
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
          ggobj.setSizeLimits(width+'px', 0, height+'px', 0);
          ggobj.removeContainerLimits();
        } else {
          ggobj.autoScale(Math.round(x.settings.sizing.width * 100) + "%");
          ggobj.IEFixResize(x.settings.sizing.width, 1/x.ratio);
          ggobj.setSizeLimits("unset", "unset", "unset", "unset");
          ggobj.removeContainerLimits();
        }

        var addSelection = ggobj.isSelectable() && HTMLWidgets.shinyMode && x.settings.capture.only_shiny;
        var addZoom = true;
        if( x.settings.zoom.min === 1 && x.settings.zoom.max <= 1 ){
          addZoom = false;
        }

        if( addSelection && x.settings.capture.type == "single" ){
          ggobj.selectizeSingle();
          addSelection = false;
        } else if( addSelection && x.settings.capture.type == "multiple" ){
          ggobj.selectizeMultiple();
        } else {
          ggobj.selectizeNone();
          addSelection = false;
        }
        ggobj.addUI(addSelection, addZoom,
          x.settings.toolbar.saveaspng,
          'ggiraph-toolbar-' + x.settings.toolbar.position);

        if( HTMLWidgets.shinyMode ){
          ggobj.setInputId(el.id + "_selected");
          set_reactive(ggobj, el.id );
        }

      },

      resize: function(width, height) {
        //ggobj.setSize(width, height);
      }

    };
  }
});
