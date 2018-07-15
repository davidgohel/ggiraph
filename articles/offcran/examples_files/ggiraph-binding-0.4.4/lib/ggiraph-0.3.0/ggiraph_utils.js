function set_highlight(svg_id) {
  var sel_data_id = d3.selectAll('#' + svg_id + ' *[data-id]');
  sel_data_id.classed("cl_data_id_" + svg_id, true);
}

function get_htmlwidget_id(svg_id){
  var svg = d3.select("#" + svg_id);
  var container_div = svg.select(function() { return this.parentNode.parentNode; });
  var id = container_div.attr("id");
  return id;
}

// from https://stackoverflow.com/questions/5916900/how-can-you-detect-the-version-of-a-browser
function navigator_id(){
    var ua= navigator.userAgent, tem,
    M= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
    if(/trident/i.test(M[1])){
        tem=  /\brv[ :]+(\d+)/g.exec(ua) || [];
        return 'IE '+(tem[1] || '');
    }
    if(M[1]=== 'Chrome'){
        tem= ua.match(/\b(OPR|Edge)\/(\d+)/);
        if(tem!== null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
    }
    M= M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
    if((tem= ua.match(/version\/(\d+)/i))!== null) M.splice(1, 1, tem[1]);
    return M.join(' ');
}
