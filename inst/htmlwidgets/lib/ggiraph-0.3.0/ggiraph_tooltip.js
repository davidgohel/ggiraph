function tooltip_remove(id){
    var svg_id = window[id];
    d3.selectAll(".tooltip_" + svg_id ).remove();
}

function add_tooltip(svg_id, tooltip_opacity, tooltip_offx, tooltip_offy) {

  var div = d3.select("body").append("div")
      .attr("class", 'tooltip_' + svg_id).style("position", "absolute")
      .style("opacity", 0);

  var sel_tooltiped = d3.selectAll('#' + svg_id + ' *[title]');

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

function mouseover_behavior(svg_id, tooltip_opacity, tooltip_offx, tooltip_offy, selected_class) {

  var div = d3.select("body").append("div")
      .attr("class", 'tooltip_' + svg_id).style("position", "absolute")
      .style("opacity", 0);

  var sel_both = d3.selectAll('#' + svg_id + ' *');
  sel_both.on("mouseover", function(d) {
        if( d3.select(this).attr("data-id") !== null ){
          var curr_sel = d3.selectAll('#' + svg_id +
                ' *[data-id="' + d3.select(this).attr("data-id") + '"]');
          curr_sel.classed(selected_class, true);
        }
        if( d3.select(this).attr("title") !== null ){
          div.transition()
              .duration(200)
              .style("opacity", tooltip_opacity);
          div.html(d3.select(this).attr("title"))
              .style("left", (d3.event.pageX + tooltip_offx ) + "px")
              .style("top", (d3.event.pageY + tooltip_offy ) + "px");
          }
        })
      .on("mouseout", function(d) {
        if( d3.select(this).attr("data-id") !== null ){
          var curr_sel = d3.selectAll('#' + svg_id +
                ' *[data-id="' + d3.select(this).attr("data-id") + '"]');
          curr_sel.classed(selected_class, false);
        }
        if( d3.select(this).attr("title") !== null ){
          div.transition()
            .duration(500)
            .style("opacity", 0);
        }
      });




}


