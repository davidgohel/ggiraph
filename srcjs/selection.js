import * as d3 from 'd3';
import * as utils from './utils';

export default class SelectionHandler {
  constructor(
    svgid,
    classPrefix,
    attrName,
    shinyInputId,
    shinyMessageId,
    type,
    initialSelection
  ) {
    this.svgid = svgid;
    this.clsName = classPrefix + '_' + svgid;
    this.attrName = attrName;
    this.shinyInputId = shinyInputId;
    this.shinyMessageId = shinyMessageId;
    this.type = type;
    this.initialSelection = initialSelection;
    this.dataSelected = [];
  }

  init() {
    // select elements
    const elements = d3
      .select('#' + this.svgid)
      .selectAll('*[' + this.attrName + ']');
    // check selection type
    if (
      elements.empty() ||
      !(this.type == 'single' || this.type == 'multiple')
    ) {
      // nothing to do here, return false to discard this
      return false;
    }
    const that = this;

    // add event listeners
    elements.each(function () {
      this.addEventListener('click', that);
    });

    // add shiny listener
    if (this.shinyMessageId) {
      Shiny.addCustomMessageHandler(this.shinyMessageId, function (message) {
        if (typeof message === 'string') {
          that.setSelected([message]);
        } else if (utils.isArray(message)) {
          that.setSelected(message);
        }
      });
    }

    // set selections
    if (typeof this.initialSelection === 'string') {
      this.setSelected([this.initialSelection]);
    } else if (
      utils.isArray(this.initialSelection) &&
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
    const that = this;
    // remove event listeners
    try {
      d3.select('#' + this.svgid)
        .selectAll('*[' + this.attrName + ']')
        .each(function () {
          this.removeEventListener('click', that);
        });
    } catch (e) {
      console.error(e);
    }
    // remove shiny listener
    if (this.shinyMessageId) {
      try {
        // For Shiny the only way to really remove it
        // is to replace it with a void one
        Shiny.addCustomMessageHandler(this.shinyMessageId, function (
          message
        ) {});
      } catch (e) {
        console.error(e);
      }
    }
    //
    this.dataSelected = [];
  }

  handleEvent(event) {
    try {
      let dataSel = this.dataSelected;
      const dataId = event.target.getAttribute(this.attrName);
      const index = dataSel.indexOf(dataId);
      if (this.type == 'multiple') {
        if (index < 0) {
          dataSel.push(dataId);
        } else {
          dataSel.splice(index, 1);
        }
      } else {
        if (index < 0) {
          dataSel = [dataId];
        } else {
          dataSel = [];
        }
      }
      this.setSelected(dataSel);
    } catch (e) {
      console.error(e);
    }
  }

  setSelected(sel) {
    this.dataSelected = sel;
    this.refreshSelected();
    if (this.shinyInputId) {
      Shiny.onInputChange(this.shinyInputId, this.dataSelected);
    }
  }

  refreshSelected() {
    const svgEl = d3.select('#' + this.svgid);
    svgEl
      .selectAll('*[' + this.attrName + '].' + this.clsName)
      .classed(this.clsName, false);
    const that = this;
    for (let i = 0; i < that.dataSelected.length; i++) {
      svgEl
        .selectAll('*[' + that.attrName + '="' + that.dataSelected[i] + '"]')
        .classed(that.clsName, true);
    }
  }

  lasso(add) {
    const svgEl = d3.select('#' + this.svgid);
    const that = this;
    let lasso_ = d3.lasso();
    const lasso_start = function () {};
    const lasso_draw = function () {};
    const lasso_end = function () {
      try {
        const dataSel = that.dataSelected;
        lasso_.selectedItems().each(function (d, i) {
          const dataId = this.getAttribute(that.attrName);
          const index = dataSel.indexOf(dataId);
          if (index < 0 && add) {
            dataSel.push(dataId);
          } else if (index >= 0 && !add) {
            dataSel.splice(index, 1);
          }
        });

        svgEl.on('.dragstart', null).on('.drag', null).on('.dragend', null);

        that.setSelected(dataSel);
      } catch (e) {
        console.error(e);
      }
    };

    try {
      lasso_ = lasso_
        .closePathSelect(true)
        .closePathDistance(100)
        .items(svgEl.selectAll('*[' + this.attrName + ']'))
        .targetArea(svgEl.select('g'))
        .on('start', lasso_start)
        .on('draw', lasso_draw)
        .on('end', lasso_end);

      svgEl.call(lasso_);
    } catch (e) {
      console.error(e);
    }
  }
}
