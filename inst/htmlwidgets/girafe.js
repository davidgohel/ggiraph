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
        ggobj.setZoomer(1, x.zoom_max);
        ggobj.addStyle(x.css);
        ggobj.addSvg(x.html, x.js);
        ggobj.animateGElements(x.tooltip_opacity, x.tooltip_offx, x.tooltip_offy);
        ggobj.animateToolbar();
        ggobj.adjustSize(width, height);
        ggobj.IEFixResize(x.width, x.ratio);

        if( x.selection_type == "single" ){
          ggobj.selectizeSingle();
        } else if( x.selection_type == "multiple" ){
          ggobj.selectizeMultiple();
        } else {
          ggobj.selectizeNone();
        }
        ggobj.addUI(true, true);
        ggobj.setZoomer(1, 4);

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
