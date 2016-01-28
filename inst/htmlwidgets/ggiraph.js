HTMLWidgets.widget({

  name: 'ggiraph',
  type: 'output',

  initialize: function(el, width, height) {

    return {
    }
  },

  renderValue: function(el, x, instance) {
	  el.innerHTML = x.html;
	  eval(x.code);

	  var sheet = document.createElement('style');
	  var css = "." + x.data_id_class +  ":{}." + x.data_id_class +  ":hover " + x.hover_css;
    sheet.innerHTML = css;
    document.body.appendChild(sheet);

    var sel = '#svg_' + x.canvas_id + ' *[data-id]';
    $(sel).each(function(index) {$(this).attr("class", x.data_id_class);});
  },

  resize: function(el, width, height, instance) {
  }

});
