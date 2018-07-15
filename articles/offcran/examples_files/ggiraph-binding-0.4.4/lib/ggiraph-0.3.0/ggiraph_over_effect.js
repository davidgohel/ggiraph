function set_over_effect(svg_id){

  var id = get_htmlwidget_id(svg_id);

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

