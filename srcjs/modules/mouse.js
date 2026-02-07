export const EVENT_TYPES = [
  'pointerover',
  'pointerout',
  'pointermove',
  'pointerdown',
  'wheel',
  'click',
  'nearest'
];

export class MouseHandler {
  constructor(svgid, handlers, nearestHandler) {
    this.svgid = svgid;
    this.handlers = handlers;
    this.nearestHandler = nearestHandler;
  }

  init() {
    // get active event types
    this.event_types = EVENT_TYPES
      // filter out nearest
      .filter((key) => key !== 'nearest')
      // filter out empty
      .filter((key) => this.handlers.get(key) && this.handlers.get(key).length);

    if (!this.event_types.length) {
      return false;
    }

    // check if we need the nearest handler
    if (
      !(this.handlers.get('nearest') && this.handlers.get('nearest').length)
    ) {
      this.nearestHandler = null;
    }

    // add listeners
    const svgNode = document.getElementById(this.svgid);
    let use_capture;
    this.event_types.forEach(function (type) {
      use_capture = type !== 'pointermove';
      svgNode.addEventListener(type, this, use_capture);
    }, this);

    // allow pan scrolling but prevent pinch-zoom conflicts with D3 zoom
    svgNode.style.touchAction = 'pan-x pan-y';

    // return true to add to list of handLers
    return true;
  }

  destroy() {
    // remove event listeners
    try {
      const svgNode = document.getElementById(this.svgid);
      this.event_types.forEach(function (type) {
        svgNode.removeEventListener(type, this);
      }, this);
    } catch (e) {
      console.error(e);
    }
  }

  handleEvent(event) {
    try {
      const target = event.target;
      const isTouch = event.pointerType === 'touch';
      let handled = false,
        nearest = null;

      if (event.type === 'pointerout') {
        // mouse: clear immediately (same as before)
        // touch: ignore — clear happens on next pointerdown
        if (!isTouch) {
          this.handlers.get(event.type).forEach((h) => h.clear(event));
        }
      } else if (event.type === 'pointerover' && !event.buttons) {
        // mouse only — touch does not fire meaningful pointerover
        if (!isTouch) {
          this.handlers.get(event.type).forEach((h) => h.applyOn(target, event));
        }
      } else if (event.type === 'pointerdown') {
        if (isTouch) {
          // touch: pointerdown replaces mouseover
          // clear previous hover/tooltip first
          this.handlers.get('pointerout').forEach((h) => h.clear(event));
          // then apply on the new target
          if (this.svgid !== target.id) {
            this.handlers.get('pointerover').forEach((h) => h.applyOn(target, event));
          }
        } else {
          // mouse: clear tooltip (same as old mousedown)
          this.handlers.get(event.type).forEach((h) => h.clear(event));
        }
      } else if (event.type === 'pointermove' && !event.buttons) {
        if (this.svgid !== target.id) {
          handled = this.handlers
            .get(event.type)
            .map((h) => h.applyOn(target, event))
            .find((result) => !!result);
        }
        if (this.nearestHandler && !handled) {
          event.fromNearest = true;
          nearest = this.nearestHandler.applyOn(target, event);
          if (nearest) {
            this.handlers
              .get('nearest')
              .forEach((h) => h.applyOn(nearest, event));
          } else {
            this.handlers.get('nearest').forEach((h) => h.clear(event));
          }
        }
      } else if (event.type === 'wheel') {
        this.handlers.get(event.type).forEach((h) => h.clear(event));
      } else if (event.type === 'click') {
        if (this.svgid !== target.id) {
          this.handlers.get(event.type).map((h) => h.applyOn(target, event));
        }
      }
    } catch (e) {
      console.error(e);
    }
  }
}
