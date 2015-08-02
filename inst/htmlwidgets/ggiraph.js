HTMLWidgets.widget({

  name: 'ggiraph',

  type: 'output',

  initialize: function(el, width, height) {
	  if($("#gtooltip").length == 0) {
		  el.innerHTML = '<div id=\"gtooltip\"></div>'; 
		}
		
    return {
    	
    }

  },

  renderValue: function(el, x, instance) {

	  el.innerHTML += x.html; 
	  eval(x.js);	  
	  
  },

  resize: function(el, width, height, instance) {

  }

});

