function d3_set_attr(selection, name, value) {
  selection.attr(name, value);
}

function zoomed() {
    d3.select(this).attr("transform", d3.event.transform);
}

function select_data_id_single(selection, js_varname, svg_id) {
  selection.on("click", function(d,i) {
    d3.selectAll(svg_id + ' *[data-id]').classed('selected_', false);
    var dataid = d3.select(this).attr("data-id");

    if( window[js_varname][0] == dataid ){
      window[js_varname] = [];
    }
    else {
      window[js_varname] = [dataid];
      d3.selectAll(svg_id + ' *[data-id="' + dataid + '"]').classed('selected_', true);
    }
    Shiny.onInputChange(js_varname, window[js_varname]);
  });
}

function select_data_id_multiple(selection, js_varname, svg_id) {
  selection.on("click", function(d,i) {

    var dataid = d3.select(this).attr("data-id");
    var index = window[js_varname].indexOf(dataid);
    if( index < 0 ){
      window[js_varname].push( dataid );
      d3.selectAll(svg_id + ' *[data-id="' + dataid + '"]').classed('selected_', true);
    } else {
      window[js_varname].splice(index,1);
      d3.selectAll(svg_id + ' *[data-id="' + dataid + '"]').classed('selected_', false);
    }

    Shiny.onInputChange(js_varname, window[js_varname]);
  });
}

HTMLWidgets.widget({

  name: "ggiraph",

  type: "output",

  factory: function(el, width, height) {

    // create our sigma object and bind it to the element

    return {
      renderValue: function(x) {
        el.innerHTML = x.html;
        var fn = Function(x.code);
        fn();

        var svg_id = '#svg_' + x.canvas_id;
        var selected_id = el.id + '_selected';
        window[el.id + '_canvas'] = '#svg_' + x.canvas_id;
        d3.select(el).attr("style", "text-align:center;");
        window[el.id + '_id'] = svg_id;
        var tooltip_class = "tooltip" + x.canvas_id;

        // generate css elements
        var data_id_css = "." + x.data_id_class +  ":{}." +
          x.data_id_class +  ":hover{" + x.hover_css + "}";

        var tooltip_css = "div." + tooltip_class +
          " {position:absolute;pointer-events:none;z-index:999;";
        tooltip_css += x.tooltip_extra_css;
        tooltip_css += "}";

        var selected_css = ".selected_{" + x.selected_css + "}";

        // add css to page
        var sheet = document.createElement('style');
        sheet.innerHTML = data_id_css + tooltip_css + selected_css;
        document.body.appendChild(sheet);

        var div = d3.select("body").append("div")
          .attr("class", tooltip_class)
          .style("opacity", 0);

        var sel_data_id = d3.selectAll(svg_id + ' *[data-id]');
        sel_data_id.call(d3_set_attr, "class", x.data_id_class);

        if( HTMLWidgets.shinyMode ){

          if( !( el.id + "_selected" in window ) )
            window[el.id + "_selected"] = [];
          if( x.selection_type == "single")
            sel_data_id.call(select_data_id_single, selected_id, svg_id);
          else if( x.selection_type == "multiple")
            sel_data_id.call(select_data_id_multiple, selected_id, svg_id);

          d3.selectAll(window[el.id + "_selected"]).each(function(d, i) {
            d3.selectAll(svg_id + ' *[data-id=\"'+ window[el.id + "_selected"][i] + '\"]').classed('selected_', true);
            });

        }

        var sel_tooltiped = d3.selectAll(svg_id + ' *[title]');
        sel_tooltiped.on("mouseover", function(d) {
                div.transition()
                    .duration(200)
                    .style("opacity", x.tooltip_opacity);
                div.html(d3.select(this).attr("title"))
                    .style("left", (d3.event.pageX + x.tooltip_offx ) + "px")
                    .style("top", (d3.event.pageY + x.tooltip_offy ) + "px");
                })
            .on("mouseout", function(d) {
                div.transition()
                    .duration(500)
                    .style("opacity", 0);
            });

        d3.select('#svg_' + x.canvas_id)
          .attr("preserveAspectRatio", "xMinYMin meet")
          .classed("svg-content-responsive", true)
          .attr("width", "100%").attr("height", "100%");
        if(x.zoompan===true) {
          d3.select('#svg_' + x.canvas_id + ' g').call(d3.zoom()
                .scaleExtent([1, x.zoom_max])
                .on("zoom", zoomed));
        }
        d3.select(el)
            .style( "position", "relative")
            .style( "padding-bottom", x.padding_bottom)
            .style( "vertical-align", "top")
            .style( "margin", "auto")
            .style( "overflow", "hidden")
            .style( "width", x.width);
      },

      resize: function(width, height) {

      }

    };
  }
});