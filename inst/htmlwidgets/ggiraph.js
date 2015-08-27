HTMLWidgets.widget({

  name: 'ggiraph',

  type: 'output',

  initialize: function(el, width, height) {

    return {
    	
    }

  },

  renderValue: function(el, x, instance) {
	  
      for (var i = 0; i < x.length; i++) {
    	  el.innerHTML += x.html[i];
      }
      eval(x.code);
	  
  },

  resize: function(el, width, height, instance) {

  }

});

