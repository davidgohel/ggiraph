function zoom_on_ggiraph(svg_id, zoom_obj){

  svg_element = d3.select("#" + svg_id);
  var container_div = svg_element.select(function() { return this.parentNode; });
  container_div.call(zoom_obj
    .on("zoom", (function() {
                  d3.select('#' + svg_id + ' g').attr("transform", d3.event.transform);
                })));
}

function zoom_off_ggiraph(svg_id, zoom_obj){
  svg_element = d3.select("#" + svg_id);
  var container_div = svg_element.select(function() { return this.parentNode; });
  container_div.call(zoom_obj.on("zoom", null));
}

function zoom_identity_ggiraph(svg_id, zoom_obj){
  svg_element = d3.select("#" + svg_id);
  var container_div = svg_element.select(function() { return this.parentNode; });
  container_div.call(zoom_obj.transform, d3.zoomIdentity);
}
