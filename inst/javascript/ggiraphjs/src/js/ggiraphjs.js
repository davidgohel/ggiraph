import * as d3 from 'd3'
import * as utils from './utils'

export default class ggiraphjs {

    constructor(containerid) {
        this.containerid = containerid;
        this.dataSelected = [];
        this.dataKeySelected = [];
        this.dataThemeSelected = [];
        this.typeSelection = null;
        this.svgid = null;
        this.inputId = null;
        this.inputKeyId = null;
        this.inputThemeId = null;
        this.zoomer = null;
    }

    setSvgId(id) {
        this.svgid = id;
    }

    setZoomer(min, max) {
        this.zoomer = d3.zoom().scaleExtent([min, max]);
    }


    tooltipClassname() {
        return 'tooltip_' + this.svgid;
    }

    selectedDataClassname() {
        return 'selected_' + this.svgid;
    }
    selectedKeyClassname() {
        return 'selected_key_' + this.svgid;
    }
    selectedThemeClassname() {
        return 'selected_theme_' + this.svgid;
    }

    hoverClassname() {
        return 'hover_' + this.svgid;
    }
    hoverKeyClassname() {
        return 'hover_key_' + this.svgid;
    }
    hoverThemeClassname() {
        return 'hover_theme_' + this.svgid;
    }

    addStyle(tooltipCss, hoverCss, hoverKeyCss, hoverThemeCss, selectedCss, selectedKeyCss, selectedThemeCss) {
        const oldstyle = d3.select("#" + this.containerid + " style");
        if (oldstyle.size() > 0) {
            oldstyle.remove();
        }
        const css =
            tooltipCss.replace(/SVGID_/g, this.svgid) + "\n" +
            hoverCss.replace(/SVGID_/g, this.svgid) + "\n" +
            hoverKeyCss.replace(/SVGID_/g, this.svgid) + "\n" +
            hoverThemeCss.replace(/SVGID_/g, this.svgid) + "\n" +
            selectedCss.replace(/SVGID_/g, this.svgid) + "\n" +
            selectedKeyCss.replace(/SVGID_/g, this.svgid) + "\n" +
            selectedThemeCss.replace(/SVGID_/g, this.svgid) + "\n";
        d3.select("#" + this.containerid).append("style").text(css);
    }

    setInputId(id) {
        this.inputId = id;
    }

    setInputKeyId(id) {
        this.inputKeyId = id;
    }

    setInputThemeId(id) {
        this.inputThemeId = id;
    }

    addUI(addLasso, addZoom, saveaspng, classpos) {

        utils.add_ui(this, addLasso, addZoom, saveaspng, classpos);
    }

    removeContent() {
        const oldsvg = d3.select("#" + this.containerid + " .girafe_container_std svg");
        if (oldsvg.size() > 0) {
            const old_tooltip = d3.select("." + "tooltip_" + oldsvg.attr("id"));
            old_tooltip.remove();
        }
        const oldcontainer = d3.select("#" + this.containerid + " div.girafe_container_std");
        if (oldcontainer.size() > 0) {
            oldcontainer.remove();
        }

        const tooltipstr = "." + this.tooltipClassname();
        const tt = d3.select(tooltipstr);
        if (tt.size() > 0) {
            tt.remove();
        }

    }

    addSvg(svg, jsstr) {

        this.removeContent();

        d3.select("#" + this.containerid)
            .append("div").attr("class", "girafe_container_std")
            .html(svg);

        d3.select("body")
            .append("div").attr("class", this.tooltipClassname())
            .style("position", "absolute").style("opacity", 0);

        if (jsstr) {
            var fun_ = utils.parseFunction(jsstr);
            fun_();
        }
    }

    IEFixResize(width, ratio) {

        if (utils.navigator_id() == "IE 11" ||
            utils.navigator_id().substring(0, 4) === "MSIE") {
            const containerid = this.containerid;
            const svgid = this.svgid;

            d3.select("#" + svgid).classed("girafe_svg_ie", true);
            d3.select("#" + containerid + " div").classed("girafe_container_ie", true)
                .style("width", Math.round(width * 100) + "%")
                .style("padding-bottom", Math.round(width * ratio * 100) + "%");
        }

    }

    autoScale(csswidth) {
        const svgid = this.svgid;

        d3.select("#" + svgid)
            .style("width", csswidth)
            .style("height", "100%")
            .style("margin-left", "auto")
            .style("margin-right", "auto");
    }

    fixSize(width, height) {
        const containerid = this.containerid;
        const svgid = this.svgid;

        d3.select("#" + svgid).attr("preserveAspectRatio", "xMidYMin meet");
        d3.select("#" + containerid + " .girafe_container_std")
            .style("width", "100%");
        d3.select("#" + svgid).attr("width", width).attr("height", height);
        d3.select("#" + svgid).style("width", width).style("height", height);
    }

    setSizeLimits(width_max, width_min, height_max, height_min) {

        const svgid = this.svgid;

        d3.select("#" + svgid)
            .style("max-width", width_max)
            .style("max-height", height_max)
            .style("min-width", width_min)
            .style("min-height", height_min);
    }
    removeContainerLimits() {
        if (utils.navigator_id() == "IE 11" ||
        utils.navigator_id().substring(0, 4) === "MSIE") {

        } else {
            const containerid = this.containerid;
            d3.select("#" + containerid)
                .style("width", null)
                .style("height", null);
        }
    }


    animateToolbar() {
        const id = this.containerid;
        d3.select("#" + id).on("mouseover", function (d) {
            d3.select('#' + id + ' div.ggiraph-toolbar').transition()
                .duration(200)
                .style("opacity", 0.8);
        })
            .on("mouseout", function (d) {
                d3.select('#' + id + ' div.ggiraph-toolbar').transition()
                    .duration(500)
                    .style("opacity", 0);
            });
    }

    animateGElements(opacity, offx, offy, usecursor, delayover, delayout, usefill, usestroke) {
        const selected_class = this.hoverClassname();
        const selectedkey_class = this.hoverKeyClassname();
        const selectedtheme_class = this.hoverThemeClassname();
        const sel_all = d3.selectAll('#' + this.svgid + ' *[title]' +
                                      ', #' + this.svgid + ' *[data-id]' +
                                      ', #' + this.svgid + ' *[key-id]' +
                                      ', #' + this.svgid + ' *[theme-id]');
        const tooltipstr = "." + this.tooltipClassname();
        const svgid = this.svgid;
        const containerid = this.containerid;
        sel_all
            .on("mouseover", function (d) {
                if (this.getAttribute("theme-id") !== null) {
                    let curr_sel = d3.selectAll('#' + svgid +
                        ' *[theme-id="' + this.getAttribute("theme-id") + '"]');
                    curr_sel.classed(selectedtheme_class, true);
                }
                if (this.getAttribute("key-id") !== null) {
                    let curr_sel = d3.selectAll('#' + svgid +
                        ' *[key-id="' + this.getAttribute("key-id") + '"]');
                    curr_sel.classed(selectedkey_class, true);
                }
                if (this.getAttribute("data-id") !== null) {
                    let curr_sel = d3.selectAll('#' + svgid +
                        ' *[data-id="' + this.getAttribute("data-id") + '"]');
                    curr_sel.classed(selected_class, true);
                }
                if (this.getAttribute("title") !== null) {
                    const tooltipEl = d3.select(tooltipstr);
                    tooltipEl.transition()
                        .duration(delayover)
                        .style("opacity", opacity);
                    if (usefill) {
                        const fill = this.getAttribute("fill");
                        tooltipEl.style("background-color", fill);
                    }
                    if (usestroke) {
                        const stroke = this.getAttribute("stroke");
                        tooltipEl.style("border-color", stroke);
                    }
                    tooltipEl.html(this.getAttribute("title"));
                    // set the tooltip again so that html entities are properly decoded
                    tooltipEl.html(tooltipEl.text());
                    const tooltipRect = tooltipEl.node().getBoundingClientRect();
                    const clientRect = d3.select("#" + containerid).node().getBoundingClientRect();
                    if (usecursor) {
                      let xpos = (d3.event.pageX + offx);
                      const xdiff = (xpos + tooltipRect.width) - (clientRect.x + clientRect.width);
                      if (xdiff > 0) {
                          xpos -= xdiff;
                      }
                      let ypos = (d3.event.pageY + offy);
                      const ydiff = (ypos + tooltipRect.height) - (clientRect.y + clientRect.height + window.pageYOffset);
                      if (ydiff > 0) {
                          ypos -= ydiff;
                      }
                      tooltipEl
                            .style("left", xpos + "px")
                            .style("top", ypos + "px");
                    } else {
                        tooltipEl
                            .style("left", (offx + clientRect.left) + "px")
                            .style("top", (document.documentElement.scrollTop + clientRect.y + offy) + "px");
                    }
                }
            })
            .on("mousemove", function (d) {
                if (this.getAttribute("title") !== null) {
                    const tooltipEl = d3.select(tooltipstr);
                    const tooltipRect = tooltipEl.node().getBoundingClientRect();
                    const clientRect = d3.select("#" + containerid).node().getBoundingClientRect();
                    if (usecursor) {
                        let xpos = (d3.event.pageX + offx);
                        const xdiff = (xpos + tooltipRect.width) - (clientRect.x + clientRect.width);
                        if (xdiff > 0) {
                            xpos -= xdiff;
                        }
                        let ypos = (d3.event.pageY + offy);
                        const ydiff = (ypos + tooltipRect.height) - (clientRect.y + clientRect.height + window.pageYOffset);
                        if (ydiff > 0) {
                            ypos -= ydiff;
                        }
                        tooltipEl
                              .style("left", xpos + "px")
                              .style("top", ypos + "px");
                    } else {
                        tooltipEl
                            .style("left", (offx + clientRect.left) + "px")
                            .style("top", (document.documentElement.scrollTop + clientRect.y + offy) + "px");
                    }
                }
            })
            .on("mouseout", function (d) {
                if (this.getAttribute("theme-id") !== null) {
                    let curr_sel = d3.selectAll('#' + svgid +
                        ' *[theme-id="' + this.getAttribute("theme-id") + '"]');
                    curr_sel.classed(selectedtheme_class, false);
                }
                if (this.getAttribute("key-id") !== null) {
                    let curr_sel = d3.selectAll('#' + svgid +
                        ' *[key-id="' + this.getAttribute("key-id") + '"]');
                    curr_sel.classed(selectedkey_class, false);
                }
                if (this.getAttribute("data-id") !== null) {
                    let curr_sel = d3.selectAll('#' + svgid +
                        ' *[data-id="' + this.getAttribute("data-id") + '"]');
                    curr_sel.classed(selected_class, false);
                }
                if (this.getAttribute("title") !== null) {
                    d3.select(tooltipstr).transition()
                        .duration(delayout)
                        .style("opacity", 0);
                }
            });

    }

    setSelected(sel) {
        this.dataSelected = sel;
        this.refreshSelected();
        if (this.inputId) {
            Shiny.onInputChange(this.inputId, this.dataSelected);
        }
    }
    setKeySelected(sel) {
        this.dataKeySelected = sel;
        this.refreshKeySelected();
        if (this.inputKeyId) {
            Shiny.onInputChange(this.inputKeyId, this.dataKeySelected);
        }
    }
    setThemeSelected(sel) {
        this.dataThemeSelected = sel;
        this.refreshThemeSelected();
        if (this.inputThemeId) {
            Shiny.onInputChange(this.inputThemeId, this.dataThemeSelected);
        }
    }

    selectizeMultiple() {
        const sel_data_id = d3.selectAll('#' + this.svgid + ' *[data-id]');

        const that = this;
        sel_data_id.on("click", function (d, i) {
            let dataSel = that.dataSelected;
            var dataid = d3.select(this).attr("data-id");
            var index = dataSel.indexOf(dataid);
            if (index < 0) {
                dataSel.push(dataid);
            } else {
                dataSel.splice(index, 1);
            }
            that.dataSelected = dataSel;
            that.refreshSelected();
            if (that.inputId) {
                Shiny.onInputChange(that.inputId, that.dataSelected);
            }

        });
    }

    selectizeSingle() {
        const sel_data_id = d3.selectAll('#' + this.svgid + ' *[data-id]');
        const that = this;
        sel_data_id.on("click", function (d, i) {
            let dataSel = that.dataSelected;

            var dataid = d3.select(this).attr("data-id");
            var index = dataSel.indexOf(dataid);
            if (index < 0) {
                dataSel = [dataid];
            } else {
                dataSel = [];
            }
            that.dataSelected = dataSel;
            that.refreshSelected();
            if (that.inputId) {
                Shiny.onInputChange(that.inputId, that.dataSelected);
            }
        });
    }

    selectizeNone() {
        const sel_data_id = d3.selectAll('#' + this.svgid + ' *[data-id]');
        sel_data_id.on("click", null);
    }

    selectizeKeyMultiple() {
        const sel_data_id = d3.selectAll('#' + this.svgid + ' *[key-id]');

        const that = this;
        sel_data_id.on("click", function (d, i) {
            let dataSel = that.dataKeySelected;
            var dataid = d3.select(this).attr("key-id");
            var index = dataSel.indexOf(dataid);
            if (index < 0) {
                dataSel.push(dataid);
            } else {
                dataSel.splice(index, 1);
            }
            that.dataKeySelected = dataSel;
            that.refreshKeySelected();
            if (that.inputKeyId) {
                Shiny.onInputChange(that.inputKeyId, that.dataKeySelected);
            }

        });
    }

    selectizeKeySingle() {
        const sel_data_id = d3.selectAll('#' + this.svgid + ' *[key-id]');
        const that = this;
        sel_data_id.on("click", function (d, i) {
            let dataSel = that.dataKeySelected;

            var dataid = d3.select(this).attr("key-id");
            var index = dataSel.indexOf(dataid);
            if (index < 0) {
                dataSel = [dataid];
            } else {
                dataSel = [];
            }
            that.dataKeySelected = dataSel;
            that.refreshKeySelected();
            if (that.inputKeyId) {
                Shiny.onInputChange(that.inputKeyId, that.dataKeySelected);
            }
        });
    }

    selectizeKeyNone() {
        const sel_key_id = d3.selectAll('#' + this.svgid + ' *[key-id]');
        sel_key_id.on("click", null);
    }

    selectizeThemeMultiple() {
        const sel_data_id = d3.selectAll('#' + this.svgid + ' *[theme-id]');

        const that = this;
        sel_data_id.on("click", function (d, i) {
            let dataSel = that.dataThemeSelected;
            var dataid = d3.select(this).attr("theme-id");
            var index = dataSel.indexOf(dataid);
            if (index < 0) {
                dataSel.push(dataid);
            } else {
                dataSel.splice(index, 1);
            }
            that.dataThemeSelected = dataSel;
            that.refreshThemeSelected();
            if (that.inputThemeId) {
                Shiny.onInputChange(that.inputThemeId, that.dataThemeSelected);
            }

        });
    }

    selectizeThemeSingle() {
        const sel_data_id = d3.selectAll('#' + this.svgid + ' *[theme-id]');
        const that = this;
        sel_data_id.on("click", function (d, i) {
            let dataSel = that.dataThemeSelected;

            var dataid = d3.select(this).attr("theme-id");
            var index = dataSel.indexOf(dataid);
            if (index < 0) {
                dataSel = [dataid];
            } else {
                dataSel = [];
            }
            that.dataThemeSelected = dataSel;
            that.refreshThemeSelected();
            if (that.inputThemeId) {
                Shiny.onInputChange(that.inputThemeId, that.dataThemeSelected);
            }
        });
    }

    selectizeThemeNone() {
        const sel_data_id = d3.selectAll('#' + this.svgid + ' *[theme-id]');
        sel_data_id.on("click", null);
    }

    refreshSelected() {
        const selected_class = this.selectedDataClassname();
        const svgid = this.svgid;
        var svg = d3.select('#' + svgid);
        svg.selectAll('*[data-id]').classed(selected_class, false);
        const that = this;
        d3.selectAll(that.dataSelected).each(function (d, i) {
            svg.selectAll('*[data-id=\"' + that.dataSelected[i] + '\"]').classed(selected_class, true);
        });
    }
    refreshKeySelected() {
        const selected_class = this.selectedKeyClassname();
        const svgid = this.svgid;
        var svg = d3.select('#' + svgid);
        svg.selectAll('*[key-id]').classed(selected_class, false);
        const that = this;
        d3.selectAll(that.dataKeySelected).each(function (d, i) {
            svg.selectAll('*[key-id=\"' + that.dataKeySelected[i] + '\"]').classed(selected_class, true);
        });
    }
    refreshThemeSelected() {
        const selected_class = this.selectedThemeClassname();
        const svgid = this.svgid;
        var svg = d3.select('#' + svgid);
        svg.selectAll('*[theme-id]').classed(selected_class, false);
        const that = this;
        d3.selectAll(that.dataThemeSelected).each(function (d, i) {
            svg.selectAll('*[theme-id=\"' + that.dataThemeSelected[i] + '\"]').classed(selected_class, true);
        });
    }
    zoomOn() {
        const svgid = this.svgid;
        d3.select("#" + this.containerid).call(this.zoomer
            .on("zoom", (function () {
                d3.select('#' + svgid + ' g').attr("transform", d3.event.transform);
            }))
        );
    }

    zoomIdentity() {
        d3.select("#" + this.containerid).call(this.zoomer.transform, d3.zoomIdentity);
    }

    zoomOff() {
        d3.select("#" + this.containerid).call(this.zoomer.on("zoom", null));
    }

    isSelectable() {
        const svgid = this.svgid;
        var svg = d3.select('#' + svgid);
        return (svg.selectAll('*[data-id]').size() > 0 ||
                svg.selectAll('*[key-id]').size() > 0 ||
                svg.selectAll('*[theme-id]').size() > 0);
    }

    lasso_on(add) {
        const svgid = this.svgid;
        const that = this;
        let lasso_ = d3.lasso();
        var lasso_start = function () { };
        var lasso_draw = function () { };
        var lasso_end = function () {
            lasso_.selectedItems().each(function (d, i) {
                d3.select(this).classed(that.selectedDataClassname(), true);
                var dataid = d3.select(this).attr("data-id");
                var index = that.dataSelected.indexOf(dataid);
                if (index < 0 && add) {
                    that.dataSelected.push(dataid);
                } else if (index >= 0 && !add) {
                    that.dataSelected.splice(index, 1);
                }

            });
            that.refreshSelected();

            d3.select("#" + svgid).on(".dragstart", null)
                .on(".drag", null)
                .on(".dragend", null);
            if (that.inputId) {
                Shiny.onInputChange(that.inputId, that.dataSelected);
            }
        };

        lasso_ = lasso_
            .closePathSelect(true)
            .closePathDistance(100)
            .items(d3.select("#" + svgid).selectAll('*[data-id]'))
            .targetArea(d3.select("#" + svgid))
            .on("start", lasso_start)
            .on("draw", lasso_draw)
            .on("end", lasso_end);

        d3.select("#" + svgid).call(lasso_);
    }
}
