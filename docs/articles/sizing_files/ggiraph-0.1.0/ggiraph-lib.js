class ggiraph {
  constructor(id) {
    this.id = id;

    this.sel_type = "none";
    this.sel_array_name = id + "_selected";

    this.flexdashboard = false;

    this.tooltip_class = "tooltip_" + id;
    this.selected_class = "clicked_" + id;
    this.objlasso = d3.lasso();
  }

  set_width(width){
    this.width = width;
  }

  set_sel_type(sel_type){
    this.sel_type = sel_type;
  }

  set_ratio(ratio){
    this.ratio = ratio;
  }

  set_flexdashboard(flexdashboard){
    this.flexdashboard = flexdashboard;
  }

  set_zoom(zoom_min, zoom_max){
    this.zoom_min = zoom_min;
    this.zoom_max = zoom_max;
    this.zoomable = (this.zoom_max > 1);
    this.zoom = d3.zoom().scaleExtent([this.zoom_min, this.zoom_max]);
  }

  set_content_str( svg_str ){


    d3.select("#" + this.id ).html("<div class=\"container\">" +
      svg_str + ui_div(this.id, this.zoomable, HTMLWidgets.shinyMode && this.sel_type==="multiple") + "</div>")
        .style("width", null).style("height", null);

    var scale_ = Math.round(this.width * 100);
    var ct_obj = d3.select("#" + this.id + " div.container" );
    ct_obj.style("width", scale_ + "%").style("height", "0")
      .style("position", "relative")
      .style("margin", "auto")
      .style("padding-top", Math.round(1 / this.ratio * scale_) + "%" );

    this.svg = d3.select('#' + this.id +' svg');

    d3.select("#" + this.id ).on("mouseover", function(d) {
            d3.select('#' + this.id +' div.ggiraph-toolbar').transition()
              .duration(200)
              .style("opacity", 0.8);
            })
            .on("mouseout", function(d) {
              d3.select('#' + this.id +' div.ggiraph-toolbar').transition()
               .duration(500)
               .style("opacity", 0);
              });

    this.svg.classed("svg-inline-container", true);

  }

  set_tooltip(tooltip_opacity, tooltip_offx, tooltip_offy, tooltip_extra_css) {

    var tooltip_css = "div." + this.tooltip_class +
      " {position:absolute;pointer-events:none;z-index:999;";
    tooltip_css += tooltip_extra_css;
    tooltip_css += "}";
    var sheet = document.createElement('style');
    sheet.innerHTML = tooltip_css;
    document.body.appendChild(sheet);


    var div = d3.select("body").append("div")
      .attr("class", this.tooltip_class)
      .style("opacity", 0);

    var sel_tooltiped = this.svg.selectAll('*[title]');
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


  set_highlight(hover_css) {
    var css_ = ".cl_data_id_" + this.id +  ":{}.cl_data_id_" + this.id +  ":hover{" + hover_css + "}";
    var sheet = document.createElement('style');
    sheet.innerHTML = css_;
    document.body.appendChild(sheet);
    var sel_data_id = this.svg.selectAll('*[data-id]');
    sel_data_id.call(d3_set_attr, "class", "cl_data_id_" + this.id);
  }

  refresh_selected(){
      this.svg.selectAll('*[data-id]').classed(this.selected_class, false);

      var selid = window[this.sel_array_name];
      d3.selectAll(selid).each(function(d, i) {
        d3.svg.selectAll('*[data-id=\"'+ selid[i] + '\"]').classed(this.selected_class, true);
      });

  }

  set_selector(selected_css) {
    this.set_css_selected(selected_css);

    if( !( this.sel_array_name in window ) ){
      window[this.sel_array_name] = [];
    }
    var sel_data_id = this.svg.selectAll('*[data-id]');

    if( this.sel_type == "single" ){
      sel_data_id.call(select_data_id_single, this.sel_array_name, this.selected_class, this.id);
    } else if( this.sel_type == "multiple" ){
      sel_data_id.call(select_data_id_multiple, this.sel_array_name, this.selected_class, this.id);
    } else {
      sel_data_id.call(function(selection) {selection.on("click", null);});
    }
  }

  zoom_on(){
    d3.select('#' + this.id ).call(this.zoom
      .on("zoom", (function() {
                    d3.select('#' + this.id + ' svg g').attr("transform", d3.event.transform);
                  })));
  }

  zoom_off(){
    var elt = d3.select('#' + this.id );
    elt.call(this.zoom.on("zoom", null));
  }

  zoom_identity(){
    var elt = d3.select('#' + this.id );
    elt.call(this.zoom.transform, d3.zoomIdentity);
  }


  set_css_selected(selected_css) {
    var css_ = "." + this.selected_class + "{" + selected_css + "}";
    var sheet = document.createElement('style');
    sheet.innerHTML = css_;
    document.body.appendChild(sheet);
  }

  resize(width, height) {

    if( this.flexdashboard ) {

      var h_max = width / this.ratio;
      if( h_max > height ){
        var width_ = width * (height / h_max );
        this.svg.style("width", width_ ).style("height", height );
      } else {
        this.svg.style("width", width ).style("height", height );
      }
    } else {

      var scale_ = Math.round(this.width * 100);

      var ct_obj = d3.select("#" + this.id + " div" );
      ct_obj.style("width", scale_+"%").style("height", "0")
        .style("position", "relative")
        .style("margin", "auto")
        .style("padding-top", Math.round(1 / this.ratio * scale_) + "%" );

    }

  }

}
