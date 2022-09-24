import * as d3 from 'd3';

export default class SelectionHandler {
  constructor(svgid, options) {
    this.svgid = svgid;
    this.clsName = options.classPrefix + '_' + svgid;
    this.invClsName = options.invClassPrefix
      ? options.invClassPrefix + '_' + svgid
      : null;
    this.attrName = options.attrName;
    this.shinyInputId = options.shinyInputId;
    this.shinyMessageId = options.shinyMessageId;
    this.type = options.type;
    this.initialSelection = options.selected;
    this.nodeIds = [];
    this.dataSelected = [];
  }

  init() {
    if (this.type !== 'single' && this.type !== 'multiple') {
      // invalid type, return false to discard this
      return false;
    }
    const rootNode = document.getElementById(this.svgid + '_rootg');
    // select elements
    const nodes = rootNode.querySelectorAll('*[' + this.attrName + ']');
    if (!nodes.length) {
      // nothing to do here, return false to discard this
      return false;
    }
    const that = this;

    // store ids
    this.nodeIds = Array(nodes.length);
    let n = 0;
    nodes.forEach(function (node) {
      this.nodeIds[n++] = node.id;
    }, this);

    // add shiny listener
    if (this.shinyMessageId) {
      Shiny.addCustomMessageHandler(this.shinyMessageId, function (message) {
        if (typeof message === 'string') {
          that.setSelected([message]);
        } else if (Array.isArray(message)) {
          that.setSelected(message);
        }
      });
    }

    // set selections
    if (typeof this.initialSelection === 'string') {
      this.setSelected([this.initialSelection]);
    } else if (
      Array.isArray(this.initialSelection) &&
      this.type == 'multiple'
    ) {
      this.setSelected(this.initialSelection);
    }
    // clear mem
    this.initialSelection = null;
    // return true to add to list of handLers
    return true;
  }

  destroy() {
    this.nodeIds = [];
    this.dataSelected = [];

    // remove shiny listener
    if (this.shinyMessageId) {
      try {
        // For Shiny the only way to really remove it
        // is to replace it with a void one
        Shiny.addCustomMessageHandler(
          this.shinyMessageId,
          function (message) {}
        );
      } catch (e) {
        console.error(e);
      }
    }
  }

  clear() {
    this.setSelected([]);
  }

  isValidTarget(target) {
    return (
      target instanceof SVGGraphicsElement &&
      !(target instanceof SVGSVGElement) &&
      target.hasAttribute(this.attrName)
    );
  }

  applyOn(target, event) {
    try {
      if (this.isValidTarget(target)) {
        const dataId = target.getAttribute(this.attrName);
        let selected = Array.from(this.dataSelected);
        const index = selected.indexOf(dataId);
        if (this.type == 'multiple') {
          if (index < 0) {
            selected.push(dataId);
          } else {
            selected.splice(index, 1);
          }
        } else {
          if (index < 0) {
            selected = [dataId];
          } else {
            selected = [];
          }
        }
        this.setSelected(selected);
        return true;
      }
    } catch (e) {
      console.error(e);
    }
    return false;
  }

  setSelected(selected) {
    if (
      this.dataSelected.length !== selected.length ||
      !this.dataSelected.every((item) => selected.includes(item))
    ) {
      this.dataSelected = selected;
      this.refreshSelected();
      if (this.shinyInputId) {
        Shiny.onInputChange(this.shinyInputId, this.dataSelected);
      }
    }
  }

  refreshSelected() {
    let node, selected, element;
    this.nodeIds.forEach(function (id) {
      node = document.getElementById(id);
      if (node) {
        selected = this.dataSelected.includes(node.getAttribute(this.attrName));
        element = d3.select(node);
        element.classed(this.clsName, selected);
        if (this.invClsName) {
          if (this.dataSelected.length) {
            element.classed(this.invClsName, !selected);
          } else {
            element.classed(this.invClsName, false);
          }
        }
      }
    }, this);
  }

  lasso(add) {
    const targetEl = d3.select('#' + this.svgid + '_rootg');
    const that = this;
    let lasso_ = d3.lasso();
    const lasso_start = function () {
      targetEl.style('cursor', 'crosshair');
    };
    const lasso_draw = function () {};
    const lasso_end = function () {
      try {
        targetEl.style('cursor', 'auto');
        targetEl.on('.dragstart', null).on('.drag', null).on('.dragend', null);
        targetEl.selectAll('g.lasso').remove();

        const selected = Array.from(that.dataSelected);
        lasso_.selectedItems().each(function (d, i) {
          const dataId = this.getAttribute(that.attrName);
          const index = selected.indexOf(dataId);
          if (index < 0 && add) {
            selected.push(dataId);
          } else if (index >= 0 && !add) {
            selected.splice(index, 1);
          }
        });

        that.setSelected(selected);
      } catch (e) {
        console.error(e);
      }
    };

    try {
      lasso_ = lasso_
        .closePathSelect(true)
        .closePathDistance(100)
        .items(targetEl.selectAll('*[' + this.attrName + ']'))
        .targetArea(targetEl)
        .on('start', lasso_start)
        .on('draw', lasso_draw)
        .on('end', lasso_end);

      targetEl.call(lasso_);
    } catch (e) {
      console.error(e);
    }
  }
}
