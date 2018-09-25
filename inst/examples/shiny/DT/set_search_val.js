// https://plainjs.com/javascript/events/trigger-an-event-11/
function triggerEvent(el, type){
   if ('createEvent' in document) {
        // modern browsers, IE9+
        var e = document.createEvent('HTMLEvents');
        e.initEvent(type, false, true);
        el.dispatchEvent(e);
    } else {
        // IE 8
        var e = document.createEventObject();
        e.eventType = type;
        el.fireEvent('on'+e.eventType, e);
    }
}

function set_search_val( value ) {
  var el = document.querySelector('#DataTables_Table_0_filter > label > input[type="search"]');
  el.value = value;
  triggerEvent(el, 'keyup');
}
