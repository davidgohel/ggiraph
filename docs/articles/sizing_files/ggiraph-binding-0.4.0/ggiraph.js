
HTMLWidgets.widget({

  name: "ggiraph",

  type: "output",

  factory: function(el, width, height) {
    var ggi_obj = new ggiraph(el.id);

    return {
      renderValue: function(x) {
        //el.innerHTML = x.html;
        ggi_obj.set_width(x.width);
        ggi_obj.set_ratio(x.ratio);
        ggi_obj.set_flexdashboard(x.flexdashboard || HTMLWidgets.viewerMode);
        ggi_obj.set_sel_type(x.selection_type);
        ggi_obj.set_zoom( 1, x.zoom_max );
        ggi_obj.set_content_str( x.html );

        var fn = Function(x.code);
        fn();

        ggi_obj.set_tooltip(x.tooltip_opacity, x.tooltip_offx, x.tooltip_offy, x.tooltip_extra_css);
        ggi_obj.set_highlight(x.hover_css);

        if( HTMLWidgets.shinyMode){
          ggi_obj.set_selector(x.selected_css);
        }

        ggi_obj.resize(width, height);
        window[el.id + "_ggi"] = ggi_obj;
      },

      resize: function(width, height) {
        ggi_obj.resize(width, height);
      }

    };
  }
});