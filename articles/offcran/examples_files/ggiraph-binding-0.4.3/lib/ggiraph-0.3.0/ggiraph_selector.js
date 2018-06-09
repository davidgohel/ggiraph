function refresh_selected(sel_array_name, selected_class, svg_id){

    var svg = d3.select('#' + svg_id);
    svg.selectAll('*[data-id]').classed(selected_class, false);

    var selid = window[sel_array_name];
    d3.selectAll(selid).each(function(d, i) {
      svg.selectAll('*[data-id=\"'+ selid[i] + '\"]').classed(selected_class, true);
    });

}

function select_data_id_single(selection, sel_array_name, selected_class, svg_id, input_id ) {

  selection.on("click", function(d,i) {

    var dataid = d3.select(this).attr("data-id");

    if( window[sel_array_name][0] == dataid ){
      window[sel_array_name] = [];
    }
    else {
      window[sel_array_name] = [dataid];
    }
    refresh_selected(sel_array_name, selected_class, svg_id);
    Shiny.onInputChange(input_id, window[sel_array_name]);
  });
}

function select_data_id_multiple(selection, sel_array_name, selected_class, svg_id, input_id) {

  selection.on("click", function(d,i) {

    var dataid = d3.select(this).attr("data-id");
    var index = window[sel_array_name].indexOf(dataid);
    if( index < 0 ){
      window[sel_array_name].push( dataid );
    } else {
      window[sel_array_name].splice(index,1);
    }
    refresh_selected(sel_array_name, selected_class, svg_id);
    Shiny.onInputChange(input_id, window[sel_array_name]);
  });
}


function set_selector(svg_id, sel_array_name, selected_class, sel_type) {

  var sel_data_id = d3.selectAll('#' + svg_id + ' *[data-id]');
  var id = get_htmlwidget_id(svg_id);
  var input_id = id + "_selected";
  window[input_id] = [];
  if( sel_type == "single" ){
    sel_data_id.call(select_data_id_single, sel_array_name, selected_class, svg_id, input_id);
  } else if( sel_type == "multiple" ){
    sel_data_id.call(select_data_id_multiple, sel_array_name, selected_class, svg_id, input_id);
  } else {
    sel_data_id.call(function(selection) {selection.on("click", null);});
  }
}

function lasso_on(svg_id, add, sel_array_name, selected_class ){

  if( typeof Shiny === 'undefined' ) return false;

  var svg = d3.select("#" + svg_id);
  var id = get_htmlwidget_id(svg_id);

  var input_id = id + "_selected";

  var lasso_start = function() {};
  var lasso_draw = function() {};
  var lasso_end = function() {
    lasso.selectedItems().each( function(d, i){
          d3.select(this).classed(selected_class, true);
          var dataid = d3.select(this).attr("data-id");
          var index = window[sel_array_name].indexOf(dataid);
          if( index < 0 && add ){
            window[sel_array_name].push( dataid );
          } else if( index >= 0 && !add ){
            window[sel_array_name].splice(index,1);
          }

    });
    refresh_selected(sel_array_name, selected_class, svg_id);

    svg.on(".dragstart", null)
      .on(".drag", null)
      .on(".dragend", null);

    Shiny.onInputChange(input_id, window[sel_array_name]);
  };

  var lasso = window["lasso_"+svg_id]
    .closePathSelect(true)
    .closePathDistance(100)
    .items(svg.selectAll('*[data-id]'))
    .targetArea(svg)
    .on("start",lasso_start)
    .on("draw",lasso_draw)
    .on("end",lasso_end);

  svg.call(lasso);
}

