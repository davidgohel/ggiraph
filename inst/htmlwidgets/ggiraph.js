
HTMLWidgets.widget({

  name: "ggiraph",

  type: "output",

  factory: function(el, width, height) {

    return {
      renderValue: function(x) {
        //el.innerHTML = x.html;
        set_svg(el.id, x, x.width);
        var fn = Function(x.code);
        fn();
        window[el.id + '_width'] = x.width;
        window[el.id + '_ratio'] = x.ratio;
        window[el.id + '_flexdashboard'] = x.flexdashboard || HTMLWidgets.viewerMode;
        // generate css elements
        var data_id_css = css_highlight(el.id, x.hover_css);
        var tooltip_css = css_tooltip(el.id, x.tooltip_extra_css);
        var selected_css = css_selected(el.id, x.selected_css);

        // add css to page
        var sheet = document.createElement('style');
        sheet.innerHTML = data_id_css + tooltip_css + selected_css;
        document.body.appendChild(sheet);

        set_highlight(el.id);

        if( HTMLWidgets.shinyMode ){
          set_selector(el.id, x.selection_type);
        }

        set_tooltip(el.id, x.tooltip_opacity, x.tooltip_offx, x.tooltip_offy);

        if(x.zoom_max>1.0) {
          d3.select('#' + el.id ).call(d3.zoom()
                .scaleExtent([1, x.zoom_max])
                .on("zoom", (function() {
                              d3.select('#' + el.id + ' g').attr("transform", d3.event.transform);
                            })));
        }

        resize_(el.id, width, height);
        resize__(el.id, width, height);

      },

      resize: function(width, height) {
        resize_(el.id, width, height);
        resize__(el.id, width, height);
      }

    };
  }
});