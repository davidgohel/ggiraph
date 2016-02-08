HTMLWidgets.widget({

  name: 'ggiraph',
  type: 'output',

  initialize: function(el, width, height) {

    return {
    }
  },

  renderValue: function(el, x, instance) {
    // add svg
	  el.innerHTML = x.html;
	  // eval javascript
	  eval(x.code);

    var tooltip_class = "tooltip" + x.data_id_class;

    // generate css elements
	  var data_id_css = "." + x.data_id_class +  ":{}." +
	    x.data_id_class +  ":hover{" + x.hover_css + "}";

	  var tooltip_css = "div." + tooltip_class +
	    " {position: absolute;pointer-events: none;";
	  tooltip_css += x.tooltip_extra_css;


    // add css to page
	  var sheet = document.createElement('style');
    sheet.innerHTML = data_id_css + tooltip_css;
    document.body.appendChild(sheet);

    function d3_set_attr(selection, name, value) {
      selection.attr(name, value);
    }

    var div = d3.select("body").append("div")
      .attr("class", tooltip_class)
      .style("opacity", 0);

    var sel_data_id = d3.selectAll('#svg_' + x.canvas_id + ' *[data-id]');
    console.log(sel_data_id.size());
    sel_data_id.call(d3_set_attr, "class", x.data_id_class);

    var sel_tooltiped = d3.selectAll('#svg_' + x.canvas_id + ' *[title]');
    sel_tooltiped.on("mouseover", function(d) {
            div.transition()
                .duration(200)
                .style("opacity", 0.9);
            div.html(d3.select(this).attr("title"))
                .style("left", (d3.event.pageX + 5) + "px")
                .style("top", (d3.event.pageY - 28) + "px");
            })
        .on("mouseout", function(d) {
            div.transition()
                .duration(500)
                .style("opacity", 0);
        });
  },

  resize: function(el, width, height, instance) {
  }

});
