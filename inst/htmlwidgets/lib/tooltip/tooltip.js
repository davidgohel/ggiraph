var tooltipOVER = false;

$(document).mousemove(function(e) {
	if (tooltipOVER) {
		$('#gtooltip').css('left', e.pageX + 20).css('top', e.pageY + 20);
		$('#gtooltip').attr("class","gtt1");
	} else {
		$('#gtooltip').html("");
		$('#gtooltip').attr("class","gtt0");
	}
		
});


function addTip(node, txt) {
	$(node).mouseenter(function() {
		$('#gtooltip').html(txt);
		$('#gtooltip').show();
		tooltipOVER = true;
	}).mouseleave(function() {
		var tooltipOVER = false;
		$('#gtooltip').html("");
		$('#gtooltip').hide();
		tooltipOVER = false;
	});
};
