import * as d3 from 'd3';

export default class ToolbarHandler {
  constructor(containerid, svgid, options) {
    this.containerid = containerid;
    this.svgid = svgid;
    this.clsName = options.clsName;
    this.position = options.position;
    this.delay_over = options.delay_over;
    this.delay_out = options.delay_out;
    this.tooltips = options.tooltips ? options.tooltips : {};
    this.hidden = Array.isArray(options.hidden)
      ? options.hidden
      : [options.hidden];
    this.on = false;
  }

  init(providers) {
    // we need at least one button provider
    if (!providers.length) {
      // nothing to do here, return false to discard this
      return false;
    }

    const toolbarEl = d3
      .select('#' + this.containerid + ' .girafe_container_std')
      .append('div')
      .attr('id', this.svgid + '_toolbar')
      .classed(this.clsName, true)
      .classed(this.clsName + '-' + this.position, true)
      .attr('data-forsvg', this.svgid);

    // add blocks
    const that = this;
    const block_keys = providers
      // get block keys
      .map((p) => p.getButtons().map((b) => b.block))
      // flatten into one array
      .flat()
      // unique vlues
      .filter((value, index, self) => self.indexOf(value) === index)
      // check key not in hidden
      .filter((key) => !that.hidden.includes(key));

    // check if we have any blocks
    if (!block_keys.length) {
      toolbarEl.remove();
      return false;
    }

    const blocks = {};
    block_keys.forEach(function (key) {
      blocks[key] = toolbarEl
        .append('xhtml:div')
        .classed(that.clsName + '-block', true)
        .classed(that.clsName + '-block-' + key, true)
        .attr('data-forsvg', that.svgid);
    });

    // add buttons
    providers.forEach(function (provider) {
      provider.getButtons().forEach(function (btn) {
        if (
          !that.hidden.includes(btn.key) &&
          !that.hidden.includes(btn.block)
        ) {
          const states = btn.states;
          let key = btn.key,
            state = btn;
          if (btn.states) {
            key = btn.current_state;
            state = states[key];
          }
          if (that.tooltips[key]) {
            state.tooltip = that.tooltips[key];
          }
          blocks[btn.block]
            .append('xhtml:a')
            .classed(that.clsName + '-icon', true)
            .classed(that.clsName + '-icon-' + btn.key, true)
            .classed(state.class, true)
            .classed(state.unclass, false)
            .attr('title', state.tooltip)
            .attr('data-forsvg', that.svgid)
            .html(state.icon)
            .datum(states)
            .on('click', btn.onclick);
        }
      });
    });

    // check if we have any buttons
    if (!toolbarEl.selectAll('.' + this.clsName + '-icon').size()) {
      toolbarEl.remove();
      return false;
    }

    // return true to add to list of handlers
    return true;
  }

  destroy() {
    const toolbarEl = d3.select('#' + this.svgid + '_toolbar');

    // remove button listeners
    try {
      toolbarEl.selectAll('.' + this.clsName + '-icon').on('click', null);
    } catch (e) {
      console.error(e);
    }

    // remove element
    toolbarEl.remove();
  }

  clear(event) {
    if (this.on && !this.isValidTarget(event.relatedTarget)) {
      this.on = false;
      d3.select('#' + this.containerid)
        .select('.' + this.clsName)
        .transition()
        .duration(this.delay_out)
        .style('opacity', 0);
    }
  }

  isValidTarget(target) {
    return target && target.getAttribute('data-forsvg') === this.svgid;
  }

  applyOn() {
    if (!this.on) {
      this.on = true;
      d3.select('#' + this.svgid + '_toolbar')
        .transition()
        .duration(this.delay_over)
        .style('opacity', 0.8);
    }
  }
}
