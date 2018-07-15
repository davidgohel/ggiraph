function isArray(x) {
    return x.constructor.toString().indexOf("Array") > -1;
}

function set_shiny_env(x, htmlwidegt_id ){
  set_selector(x.uid, x.sel_array_name, x.selected_class, x.selection_type);
  var varname = htmlwidegt_id + '_selected';
  var settername = htmlwidegt_id + '_set';
  Shiny.addCustomMessageHandler(settername, function(message) {
    if( typeof message === 'string' ) {
      window[x.sel_array_name] = [message];
    } else if( isArray(message) ){
      window[x.sel_array_name] = message;
    }
    refresh_selected(x.sel_array_name, x.selected_class, x.uid);
    Shiny.onInputChange(varname, window[x.sel_array_name]);
  });
}


HTMLWidgets.widget({

  name: "ggiraph",

  type: "output",

  factory: function(el, width, height) {


    return {
      renderValue: function(x) {
        var div_htmlwidget = d3.select("#" + el.id );

        var html_str = x.ui_html + x.html + "<style>" + x.css + "</style>";
        html_str = "<div class='ggiraph_container_std'>" +
                    html_str + "</div>";

        div_htmlwidget.html(html_str);

        window[el.id] = x.uid;
        var fun_ = window[x.funname];
        fun_();
        //set_highlight(x.uid);
        //add_tooltip(x.uid, x.tooltip_opacity, x.tooltip_offx, x.tooltip_offy);
        mouseover_behavior(x.uid, x.tooltip_opacity, x.tooltip_offx, x.tooltip_offy, "hover_" + x.uid);
        set_over_effect(x.uid);

        if( HTMLWidgets.shinyMode ){
          set_shiny_env(x, el.id );
        } else{
          d3.selectAll(".ggiraph-toolbar-block").filter(".shinyonly").remove();
        }
        if( HTMLWidgets.shinyMode || typeof FlexDashboard != "undefined" ){
          d3.select("#" + x.uid).attr("width", width);
          d3.select("#" + x.uid).attr("height", height);
        } else if(navigator_id() == "IE 11" ){
          d3.select("#" + x.uid).attr("width", width);
          d3.select("#" + x.uid).attr("height", height);
        } else {
          d3.select("#" + el.id).style("width", x.width).style("height", null);
        }

        d3.select("#" + x.uid).attr("preserveAspectRatio", "xMidYMin");
        d3.select("#" + el.id).style("margin-left", "auto").style("margin-right", "auto");
        d3.select("#" + el.id + " .ggiraph_container_std").style("position", "relative");
      },

      resize: function(width, height) {
        if( HTMLWidgets.shinyMode || typeof FlexDashboard != "undefined" ){
          d3.select("#" + window[el.id]).attr("width", width);
          d3.select("#" + window[el.id]).attr("height", height);
        }
      }

    };
  }
});