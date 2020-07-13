/* Javascript template for standalone svg */
window.addEventListener('DOMContentLoaded', function (event) {
  var data = {
    /*DATA HERE*/
  };
  var factory = ggiraphjs.factory(false, true);
  var instance = factory({ id: data.uid });
  instance.renderValue(data);
});
