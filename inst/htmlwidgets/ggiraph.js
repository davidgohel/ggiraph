/*
    set_over_effect
*/
function set_over_effect(id){
    d3.select("#" + id ).on("mouseover", function(d) {
            d3.select('#' + id +' div.ggiraph-toolbar').transition()
              .duration(200)
              .style("opacity", 0.8);
            })
            .on("mouseout", function(d) {
              d3.select('#' + id +' div.ggiraph-toolbar').transition()
               .duration(500)
               .style("opacity", 0);
              });
}

function set_tooltip(id, tooltip_opacity, tooltip_offx, tooltip_offy) {

  var div = d3.select('body').append("div")
      .attr("class", 'tooltip_' + id)
      .style("opacity", 0);
  var sel_tooltiped = d3.selectAll('#' + id + ' svg *[title]');
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



function set_selector(container_id, sel_array_name, selected_class, sel_type, widget_id) {

  var sel_data_id = d3.selectAll('#' + container_id + ' svg *[data-id]');

  if( sel_type == "single" ){
    sel_data_id.call(select_data_id_single, sel_array_name, selected_class, widget_id, container_id);
  } else if( sel_type == "multiple" ){
    sel_data_id.call(select_data_id_multiple, sel_array_name, selected_class, widget_id, container_id);
  } else {
    sel_data_id.call(function(selection) {selection.on("click", null);});
  }
}

function set_highlight(id) {
  var sel_data_id = d3.selectAll('#' + id + ' svg *[data-id]');
  sel_data_id.classed("cl_data_id_" + id, true);
}


function resize(id, width, height) {
  var containerdiv = d3.select('#' + id + " div");
  var is_fd = window["fd_" + containerdiv.attr("id")];
  if(is_fd > 0){
    var ratio = window["ratio_" + containerdiv.attr("id")];
    var dady = containerdiv.node().parentNode;
    var dadybb = dady.getBoundingClientRect();
    containerdiv.style("width", (dadybb.bottom - dadybb.top) * ratio + "px");
  }
}



function lasso_on(id_str, add, sel_array_name, selected_class ){

  if( typeof Shiny === 'undefined' ) return false;

  var widget_id = window["widget_" + id_str];
  var svg = d3.select('#' + id_str + ' svg');

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
    refresh_selected(sel_array_name, selected_class, id_str);

    svg.on(".dragstart", null)
      .on(".drag", null)
      .on(".dragend", null);

    Shiny.onInputChange(widget_id + "_selected", window[sel_array_name]);
  };

  var lasso = window["lasso_"+id_str]
    .closePathSelect(true)
    .closePathDistance(100)
    .items(svg.selectAll('*[data-id]'))
    .targetArea(svg)
    .on("start",lasso_start)
    .on("draw",lasso_draw)
    .on("end",lasso_end);

  svg.call(lasso);
}



function zoom_on(id, zoom_min, zoom_max){
  var zoom_ = window["zoom_" + id];
  d3.select('#' + id ).call(zoom_
    .on("zoom", (function() {
                  d3.select('#' + id + ' svg g').attr("transform", d3.event.transform);
                })));
}

function zoom_off(id){
  var elt = d3.select('#' + id );
  var zoom_ = window["zoom_" + id];
  elt.call(zoom_.on("zoom", null));
}

function zoom_identity(id){
  var zoom_ = window["zoom_" + id];
  var elt = d3.select('#' + id );
  elt.call(zoom_.transform, d3.zoomIdentity);
}




function refresh_selected(sel_array_name, selected_class, id){

    var widget_id = window["widget_" + id];
    var svg = d3.select('#' + widget_id +' svg');
    svg.selectAll('*[data-id]').classed(selected_class, false);

    var selid = window[sel_array_name];
    d3.selectAll(selid).each(function(d, i) {
      svg.selectAll('*[data-id=\"'+ selid[i] + '\"]').classed(selected_class, true);
    });

}

function select_data_id_single(selection, sel_array_name, selected_class, id, container_id ) {

  selection.on("click", function(d,i) {

    var dataid = d3.select(this).attr("data-id");

    if( window[sel_array_name][0] == dataid ){
      window[sel_array_name] = [];
    }
    else {
      window[sel_array_name] = [dataid];
    }
    refresh_selected(sel_array_name, selected_class, container_id);
    Shiny.onInputChange(id + "_selected", window[sel_array_name]);
  });
}

function select_data_id_multiple(selection, sel_array_name, selected_class, id, container_id) {

  selection.on("click", function(d,i) {

    var dataid = d3.select(this).attr("data-id");
    var index = window[sel_array_name].indexOf(dataid);
    if( index < 0 ){
      window[sel_array_name].push( dataid );
    } else {
      window[sel_array_name].splice(index,1);
    }
    refresh_selected(sel_array_name, selected_class, container_id);
    Shiny.onInputChange(id + "_selected", window[sel_array_name]);
  });
}


function tooltip_remove(id){
    var subid = d3.select('#' + id + " div" ).attr("id");
    d3.selectAll(".tooltip_" + subid ).remove();
}



HTMLWidgets.widget({

  name: "ggiraph",

  type: "output",

  factory: function(el, width, height) {


    return {
      renderValue: function(x) {
        window["widget_" + x.uid] = el.id;
        var div_htmlwidget = d3.select("#" + el.id );

        if( HTMLWidgets.shinyMode || x.flexdashboard ){
          div_htmlwidget.html(x.html);
        }
        else if( x.use_wh ){
          div_htmlwidget.html("<div style='width:"+ width + "px;height:"+ height + "px;'>" +
            x.html + "</div>");
        } else {
          div_htmlwidget.html("<div style='width:"+ x.width + ";'>" +
            x.html + "</div>");
        }


        div_htmlwidget.style("width", null).style("height", null);

        var fun_ = window[x.funname];
        fun_();
        set_over_effect(el.id);
        set_highlight(x.uid);
        set_tooltip(x.uid, x.tooltip_opacity, x.tooltip_offx, x.tooltip_offy);
        if( HTMLWidgets.shinyMode ){

          set_selector(x.uid, x.sel_array_name, x.selected_class, x.selection_type, el.id);
          Shiny.addCustomMessageHandler(el.id+'_set',function(message) {

            var varname = el.id + '_selected';
            d3.selectAll('#' + el.id + ' svg *[data-id]').classed('clicked_'+x.uid, false);
            d3.selectAll(message).each(function(d, i) {
                d3.selectAll('#' + el.id + ' svg *[data-id="'+ message[i] + '"]').classed('clicked_'+x.uid, true);
              });
            window[x.sel_array_name] = message;
            Shiny.onInputChange(varname, window[x.sel_array_name]);
          });

          Shiny.addCustomMessageHandler(el.id+'_tooltip_remove',function(message) {
            tooltip_remove(message);
          });


        } else{
          d3.selectAll(".ggiraph-toolbar-block").filter(".shinyonly").remove();
        }
        resize(el.id, width, height);
      },

      resize: function(width, height) {
        resize(el.id, width, height);
      }

    };
  }
});