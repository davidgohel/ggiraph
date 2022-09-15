export default class MouseHandler {
  constructor(svgid, tooltipHandler, hoverHandlers, selectionHandlers) {
    this.svgid = svgid;
    this.tooltipHandler = tooltipHandler;
    this.hoverHandlers = hoverHandlers;
    this.selectionHandlers = selectionHandlers;
  }

  init() {
    if (
      !this.tooltipHandler &&
      !this.hoverHandlers.length &&
      !this.selectionHandlers.length
    ) {
      // nothing to do here, return false to discard this
      return false;
    }

    // an array with the handlers that should act on mouseover/mouseout
    this.mouseOnHandlers = [];
    if (this.tooltipHandler) {
      this.mouseOnHandlers.push(this.tooltipHandler);
    }
    this.mouseOnHandlers = this.mouseOnHandlers.concat(this.hoverHandlers);

    // add listeners
    const svgNode = document.getElementById(this.svgid);
    svgNode.addEventListener('mouseover', this, true);
    svgNode.addEventListener('mousemove', this, true);
    svgNode.addEventListener('mouseout', this, true);
    svgNode.addEventListener('click', this, true);

    // return true to add to list of handLers
    return true;
  }

  destroy() {
    // remove event listeners
    try {
      const svgNode = document.getElementById(this.svgid);
      svgNode.removeEventListener('mouseover', this);
      svgNode.removeEventListener('mousemove', this);
      svgNode.removeEventListener('mouseout', this);
      svgNode.removeEventListener('click', this);
    } catch (e) {
      console.error(e);
    }
  }

  handleEvent(event) {
    try {
      const target = event.target;
      const mousePos = new DOMPoint(event.pageX, event.pageY);
      if (event.type === 'mouseout') {
        if (this.svgid !== target.id) {
          this.mouseOnHandlers.forEach(function (h) {
            h.clear();
          });
        }
      } else if (event.type === 'mouseover') {
        if (this.svgid !== target.id) {
          this.mouseOnHandlers.forEach(function (h) {
            h.applyOn(target, mousePos);
          });
        }
      } else if (event.type === 'mousemove') {
        if (this.svgid !== target.id) {
          if (this.tooltipHandler) {
            this.tooltipHandler.applyOn(target, mousePos);
          }
        }
      } else if (event.type === 'click') {
        if (this.svgid !== target.id) {
          this.selectionHandlers.forEach(function (h) {
            h.applyOn(target);
          });
        }
      }
    } catch (e) {
      console.error(e);
    }
  }
}
