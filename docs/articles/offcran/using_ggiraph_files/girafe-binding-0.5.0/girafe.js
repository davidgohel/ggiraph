function isArray(x) {
    return x.constructor.toString().indexOf("Array") > -1;
}

function set_reactive(x, id ){
  var varname = id + '_selected';
  var settername = id + '_set';

  Shiny.addCustomMessageHandler(settername, function(message) {
    if( typeof message === 'string' ) {
      x.dataSelected = [message];
    } else if( isArray(message) ){
      x.dataSelected = message;
    }
    x.refreshSelected();
    Shiny.onInputChange(varname, x.dataSelected);
  });
}



HTMLWidgets.widget({

  name: "girafe",

  type: "output",

  factory: function(el, width, height) {
    var ggobj = ggiraphjs.newgi(el.id);
    return {
      renderValue: function(x) {
        ggobj.setSvgWidth(x.width);
        ggobj.setSvgId(x.uid);
        ggobj.setZoomer(x.settings.zoom.min, x.settings.zoom.max);
        var css = ".tooltip_" + x.uid + x.settings.tooltip.css + "\n" +
                  ".hover_" + x.uid + x.settings.hover.css + "\n" +
                  ".clicked_" + x.uid + x.settings.capture.css + "\n"
                  ;
        ggobj.addStyle(css);
        ggobj.addSvg(x.html, x.js);
        ggobj.animateGElements(x.settings.tooltip.opacity,
            x.settings.tooltip.offx, x.settings.tooltip.offy,
            x.settings.tooltip.use_cursor_pos,
            x.settings.tooltip.delay.over, x.settings.tooltip.delay.out,
            x.settings.tooltip.usefill, x.settings.tooltip.usestroke);
        ggobj.animateToolbar();
        ggobj.adjustSize(width, height);
        ggobj.IEFixResize(x.width, 1/x.ratio);

        var addLasso = ggobj.isSelectable() && HTMLWidgets.shinyMode;
        var addZoom = true;
        if( x.settings.zoom.min === 1 && x.settings.zoom.max <= 1 ){
          addZoom = false;
        }

        if( x.settings.capture.type == "single" ){
          ggobj.selectizeSingle();
          addLasso = false;
        } else if( x.settings.capture.type == "multiple" ){
          ggobj.selectizeMultiple();
        } else {
          ggobj.selectizeNone();
          addLasso = false;
        }
        ggobj.addUI(addLasso, addZoom,
          x.settings.toolbar.saveaspng,
          'ggiraph-toolbar-' + x.settings.toolbar.position);

        if( HTMLWidgets.shinyMode ){
          ggobj.setInputId(el.id + "_selected");
          set_reactive(ggobj, el.id );
        }

      },

      resize: function(width, height) {
        ggobj.setSize(width, height);
      }

    };
  }
});
