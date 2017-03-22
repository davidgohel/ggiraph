function d3_set_attr(selection, name, value) {
  selection.attr(name, value);
}

function select_data_id_single(selection, js_varname, id_str) {
  selection.on("click", function(d,i) {

    d3.selectAll("#" + id_str + ' *[data-id]').classed('selected_'+id_str, false);
    var dataid = d3.select(this).attr("data-id");

    if( window[js_varname][0] == dataid ){
      window[js_varname] = [];
    }
    else {
      window[js_varname] = [dataid];
      d3.selectAll("#" + id_str + ' *[data-id="' + dataid + '"]').classed('selected_' + id_str, true);
    }
    Shiny.onInputChange(js_varname, window[js_varname]);
  });
}

function select_data_id_multiple(selection, js_varname, id_str) {
  selection.on("click", function(d,i) {
    var dataid = d3.select(this).attr("data-id");
    var index = window[js_varname].indexOf(dataid);
    if( index < 0 ){
      window[js_varname].push( dataid );
      d3.selectAll("#" + id_str + ' *[data-id="' + dataid + '"]').classed('selected_'+id_str, true);
    } else {
      window[js_varname].splice(index,1);
      d3.selectAll("#" + id_str + ' *[data-id="' + dataid + '"]').classed('selected_'+id_str, false);
    }

    Shiny.onInputChange(js_varname, window[js_varname]);
  });
}



function set_selector(id_str, selection) {

    var sel_data_id = d3.selectAll('#' + id_str + ' *[data-id]');

    var selected_id = id_str + '_selected';

    if( !( selected_id in window ) )
      window[selected_id] = [];

    if( selection == "single")
      sel_data_id.call(select_data_id_single, selected_id, id_str);
    else if( selection == "multiple")
      sel_data_id.call(select_data_id_multiple, selected_id, id_str);


    d3.selectAll(window[selected_id]).each(function(d, i) {
      d3.selectAll(id_str + ' *[data-id=\"'+ window[selected_id][i] + '\"]').classed('selected_'+id_str, true);
    });

}


function set_highlight(id_str) {
  var sel_data_id = d3.selectAll('#' + id_str + ' *[data-id]');
  sel_data_id.call(d3_set_attr, "class", "cl_data_id_" + id_str);
}

function css_highlight(id_str, hover_css) {
  var data_id_css = ".cl_data_id_" + id_str +  ":{}.cl_data_id_" + id_str +  ":hover{" + hover_css + "}";
  return data_id_css;
}


function set_tooltip(id_str, tooltip_opacity, tooltip_offx, tooltip_offy) {
  var div = d3.select("body").append("div")
    .attr("class", "tooltip_" + id_str)
    .style("opacity", 0);

    var sel_tooltiped = d3.selectAll("#" + id_str + ' *[title]');
    sel_tooltiped.on("mouseover", function(d) {
            div.transition()
                .duration(200)
                .style("opacity", tooltip_opacity);
            div.html(d3.select(this).attr("title"))
                .style("left", (d3.event.pageX + tooltip_offx ) + "px")
                .style("top", (d3.event.pageY + tooltip_offy ) + "px");
            })
        .on("mouseout", function(d) {
            div.transition()
                .duration(500)
                .style("opacity", 0);
        });
}

function css_tooltip(id_str, tooltip_extra_css) {
  var tooltip_css = "div.tooltip_" + id_str +
    " {position:absolute;pointer-events:none;z-index:999;";
  tooltip_css += tooltip_extra_css;
  tooltip_css += "}";
  return tooltip_css;
}


function css_selected(id_str, selected_css) {
  var selected_css_ = ".selected_" + id_str + "{" + selected_css + "}";
  return selected_css_;
}

function set_svg(id_str, x, width ){
  d3.select("#" + id_str ).html("<div class=\"container\">" + x.html + "</div>")
    .style("width", null).style("height", null);
  var scale_ = Math.round(width * 100);
  var ct_obj = d3.select("#" + id_str + " div" );
  ct_obj.style("width", scale_+"%").style("height", "0")
    .style("position", "relative")
    .style("margin", "auto")
    .style("padding-top", Math.round(1 / x.ratio * scale_) + "%" );

  var svg_obj = d3.select("#" + id_str + " svg");
  svg_obj.classed("svg-inline-container", true);


}

function resize_(id_str, width, height) {

  if( !window[id_str + '_flexdashboard'] ) return ;

  var svg_elt = d3.select('#' + id_str + " svg");
  var ratio = window[id_str + '_ratio'];
  var h_max = width / ratio;
  if( h_max > height ){
    var width_ = width * (height / h_max );
    svg_elt.style("width", width_ ).style("height", height );
  } else {
    svg_elt.style("width", width ).style("height", height );
  }

}

function resize__(id_str, width, height) {
  if( window[id_str + '_flexdashboard'] ) return ;

  var width = window[id_str + '_width'];
  var scale_ = Math.round(width * 100);

  var ct_obj = d3.select("#" + id_str + " div" );
  ct_obj.style("width", scale_+"%").style("height", "0")
    .style("position", "relative")
    .style("margin", "auto")
    .style("padding-top", Math.round(1 / window[id_str + '_ratio'] * scale_) + "%" );

}


