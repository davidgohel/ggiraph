function d3_set_attr(selection, name, value) {
  selection.attr(name, value);
}

function refresh_selected(sel_array_name, selected_class, id){

    d3.select('#' + id +' svg').selectAll('*[data-id]').classed(selected_class, false);

    var selid = window[sel_array_name];
    d3.selectAll(selid).each(function(d, i) {
      d3.select("#"+id).selectAll('*[data-id=\"'+ selid[i] + '\"]').classed(selected_class, true);
    });

}

function select_data_id_single(selection, sel_array_name, selected_class, id ) {

  selection.on("click", function(d,i) {

    var dataid = d3.select(this).attr("data-id");

    if( window[sel_array_name][0] == dataid ){
      window[sel_array_name] = [];
    }
    else {
      window[sel_array_name] = [dataid];
    }
    refresh_selected(sel_array_name, selected_class, id);
    Shiny.onInputChange(id + "_selected", window[sel_array_name]);
  });
}

function select_data_id_multiple(selection, sel_array_name, selected_class, id) {

  selection.on("click", function(d,i) {

    var dataid = d3.select(this).attr("data-id");
    var index = window[sel_array_name].indexOf(dataid);
    if( index < 0 ){
      window[sel_array_name].push( dataid );
    } else {
      window[sel_array_name].splice(index,1);
    }
    refresh_selected(sel_array_name, selected_class, id);
    Shiny.onInputChange(id + "_selected", window[sel_array_name]);
  });
}


function lasso_on(id_str, add ){

  var ggi_obj = window[ id_str + "_ggi"];
  if( this.sel_type != "multiple" ) false;

  var lasso_start = function() {};
  var lasso_draw = function() {};
  var lasso_end = function() {
    lasso.selectedItems().each( function(d, i){
          d3.select(this).classed(ggi_obj.selected_class, true);
          var dataid = d3.select(this).attr("data-id");
          var index = window[ggi_obj.sel_array_name].indexOf(dataid);
          if( index < 0 && add ){
            window[ggi_obj.sel_array_name].push( dataid );
          } else if( index >= 0 && !add ){
            window[ggi_obj.sel_array_name].splice(index,1);
          }

    });
    refresh_selected(ggi_obj.sel_array_name, ggi_obj.selected_class, id_str);

    ggi_obj.svg.on(".dragstart", null)
      .on(".drag", null)
      .on(".dragend", null);

    Shiny.onInputChange(ggi_obj.sel_array_name, window[ggi_obj.sel_array_name]);
  };

  var lasso = ggi_obj.objlasso
    .closePathSelect(true)
    .closePathDistance(100)
    .items(ggi_obj.svg.selectAll('*[data-id]'))
    .targetArea(ggi_obj.svg)
    .on("start",lasso_start)
    .on("draw",lasso_draw)
    .on("end",lasso_end);

  ggi_obj.svg.call(lasso);
}

function zoom_off(id) {
  var ggi_obj = window[ id + "_ggi"];
  ggi_obj.zoom_off();
}

function zoom_on(id) {
  var ggi_obj = window[ id + "_ggi"];
  ggi_obj.zoom_on();
}

function zoom_identity(id) {
  var ggi_obj = window[ id + "_ggi"];
  ggi_obj.zoom_identity();
}


var zoom_logo_on = "<svg width='1.5em' height='1.5em' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/></g></svg>";
var zoom_logo_off = "<svg width='1.5em' height='1.5em' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/><line y2='455' x2='0' y1='0' x1='416' stroke-width='30'/></g></svg>";
var lasso_logo = "<svg width='1.5em' height='1.5em' viewBox='0 0 230 230'><g><ellipse ry='65.5' rx='86.5' cy='94' cx='115.5' stroke-width='20' fill='transparent'/><ellipse ry='11.500001' rx='10.5' cy='153' cx='91.5' stroke-width='20' fill='transparent'/><line y2='210.5' x2='105' y1='164.5' x1='96' stroke-width='20'/></g></svg>";
var arrow_expand_logo = "<svg width='1.5em' height='1.5em' viewBox='0 0 512 512'><g><polygon points='274,209.7 337.9,145.9 288,96 416,96 416,224 366.1,174.1 302.3,238 '/><polygon points='274,302.3 337.9,366.1 288,416 416,416 416,288 366.1,337.9 302.3,274'/><polygon points='238,302.3 174.1,366.1 224,416 96,416 96,288 145.9,337.9 209.7,274'/><polygon points='238,209.7 174.1,145.9 224,96 96,96 96,224 145.9,174.1 209.7,238'/></g><svg>";

function ui_div(id, zoomable, letlasso){

  var bar = "<div class='ggiraph-toolbar'>";

  if( letlasso ){
    bar += "<div class='ggiraph-toolbar-block'>";
    bar += "<a class='ggiraph-toolbar-icon neutral' title='lasso selection' href='javascript:lasso_on(\""+ id + "\", true);'>" + lasso_logo + "</a>";
    bar += "<a class='ggiraph-toolbar-icon drop' title='lasso anti-selection' href='javascript:lasso_on(\"" + id + "\", false);'>" + lasso_logo + "</a>";
    bar += "</div>";
  }
  if( zoomable ){
    bar += "<div class='ggiraph-toolbar-block'>";
    bar += "<a class='ggiraph-toolbar-icon neutral' title='pan-zoom reset' href='javascript:zoom_identity(\"" + id + "\");'>" + arrow_expand_logo + "</a>";
    bar += "<a class='ggiraph-toolbar-icon neutral' title='activate pan-zoom' href='javascript:zoom_on(\"" + id + "\");'>" + zoom_logo_on + "</a>";
    bar += "<a class='ggiraph-toolbar-icon neutral' title='desactivate pan-zoom' href='javascript:zoom_off(\"" + id + "\");'>" + zoom_logo_off + "</a>";
    bar += "</div>";
  }
  bar += "</div>";


  return bar;
}

