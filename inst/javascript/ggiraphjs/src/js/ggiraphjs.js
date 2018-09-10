import * as d3 from 'd3'
import * as utils from './utils'
import * as svgtopng from 'save-svg-as-png'

export default class ggiraphjs {

    constructor(containerid) {
        this.containerid = containerid;
        this.dataSelected = [];
        this.typeSelection = null;
        this.svgid = null;
        this.csswidth = null;
        this.inputId = null;
        this.zoomer = null;
    }

    setSvgId(id) {
        this.svgid = id;
    }
    setSvgWidth(width) {
        this.csswidth = Math.round(width * 100) + "%";
    }
    setZoomer(min, max) {
        this.zoomer = d3.zoom().scaleExtent([min, max]);
    }


    tooltipClassname() {
        return 'tooltip_' + this.svgid;
    }

    selectedClassname() {
        return 'clicked_' + this.svgid;
    }

    setZoomer(min, max) {
        this.zoomer = d3.zoom().scaleExtent([min, max]);
    }

    hoverClassname() {
        return 'hover_' + this.svgid;
    }

    addStyle(css) {
        d3.select("head").append("style").text(css);
    }

    setInputId(id) {
        this.inputId = id;
    }

    addUI(addLasso, addZoom) {
        const divToolbar = d3.select("#" + this.containerid + " .girafe_container_std").append("div").classed('ggiraph-toolbar', true);
        const that = this;
        if (addLasso) {
            const divToolbarSelect = divToolbar.append("div")
                .classed('ggiraph-toolbar-block', true)
                .classed('shinyonly', true);
            const linkLassoOn = divToolbarSelect.append("a")
                .classed('ggiraph-toolbar-icon', true)
                .classed('neutral', true)
                .attr('title', 'lasso selection')
                .on('click', function () {
                    that.lasso_on(true);
                })
                .html("<svg width='15pt' height='15pt' viewBox='0 0 230 230'><g><ellipse ry='65.5' rx='86.5' cy='94' cx='115.5' stroke-width='20' fill='transparent'/><ellipse ry='11.500001' rx='10.5' cy='153' cx='91.5' stroke-width='20' fill='transparent'/><line y2='210.5' x2='105' y1='164.5' x1='96' stroke-width='20'/></g></svg>");
            const linkLassoOff = divToolbarSelect.append("a")
                .classed('ggiraph-toolbar-icon', true)
                .classed('drop', true)
                .attr('title', 'lasso selection')
                .on('click', function () {
                    that.lasso_on(false);
                })
                .html("<svg width='15pt' height='15pt' viewBox='0 0 230 230'><g><ellipse ry='65.5' rx='86.5' cy='94' cx='115.5' stroke-width='20' fill='transparent'/><ellipse ry='11.500001' rx='10.5' cy='153' cx='91.5' stroke-width='20' fill='transparent'/><line y2='210.5' x2='105' y1='164.5' x1='96' stroke-width='20'/></g></svg>");
        }

        if (addZoom) {
            const divToolbarZoom = divToolbar.append("div")
                .classed('ggiraph-toolbar-block', true);

            divToolbarZoom.append("a")
                .classed('ggiraph-toolbar-icon', true)
                .classed('neutral', true)
                .attr('title', 'pan-zoom reset')
                .on('click', function () {
                    that.zoomIdentity();
                })
                .html("<svg width='15pt' height='15pt' viewBox='0 0 512 512'><g><polygon points='274,209.7 337.9,145.9 288,96 416,96 416,224 366.1,174.1 302.3,238 '/><polygon points='274,302.3 337.9,366.1 288,416 416,416 416,288 366.1,337.9 302.3,274'/><polygon points='238,302.3 174.1,366.1 224,416 96,416 96,288 145.9,337.9 209.7,274'/><polygon points='238,209.7 174.1,145.9 224,96 96,96 96,224 145.9,174.1 209.7,238'/></g><svg>");
            divToolbarZoom.append("a")
                .classed('ggiraph-toolbar-icon', true)
                .classed('neutral', true)
                .attr('title', 'activate pan-zoom')
                .on('click', function () {
                    that.zoomOn();
                })
                .html("<svg width='15pt' height='15pt' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/></g></svg>");
            divToolbarZoom.append("a")
                .classed('ggiraph-toolbar-icon', true)
                .classed('drop', true)
                .attr('title', 'deactivate pan-zoom')
                .on('click', function () {
                    that.zoomOff();
                })
                .html("<svg width='15pt' height='15pt' viewBox='0 0 512 512'><g><ellipse ry='150' rx='150' cy='213' cx='203.5' stroke-width='50' fill='transparent'/><line y2='455.5' x2='416' y1='331.5' x1='301' stroke-width='50'/><line y2='455' x2='0' y1='0' x1='416' stroke-width='30'/></g></svg>");
        }

        const divToolbarMisc = divToolbar.append("div")
            .classed('ggiraph-toolbar-block', true);
        divToolbarMisc.append("a")
            .classed('ggiraph-toolbar-icon', true)
            .classed('neutral', true)
            .attr('title', 'download png')
            .on('click', function () {
                svgtopng.saveSvgAsPng(document.getElementById(that.svgid), "diagram.png");
            })
            .html("<svg width='15pt' height='15pt' viewBox='0 0 512 512' xmlns='http://www.w3.org/2000/svg'><g><polygon points='95 275 95 415 415 415 415 275 375 275 375 380 135 380 135 275'/><polygon points='220 30 220 250 150 175 150 245 250 345 350 245 350 175 280 250 280 30'/></g></svg>");
    }

    addSvg(svg, jsstr) {
        d3.select("#" + this.containerid)
            .append("div").attr("class", "girafe_container_std")
            .html(svg);

        d3.select("body")
            .append("div").attr("class", this.tooltipClassname())
            .style("position", "absolute").style("opacity", 0);

        var fun_ = utils.parseFunction(jsstr);
        fun_();
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

    adjustSize(width, height) {
        const containerid = this.containerid;
        const svgid = this.svgid;

        d3.select("#" + svgid).attr("preserveAspectRatio", "xMidYMin");
        d3.select("#" + containerid + " .girafe_container_std")
            .style("width", this.csswidth);
        d3.select("#" + svgid).attr("width", null).attr("height", null);


        if (HTMLWidgets.shinyMode) {
            d3.select("#" + svgid)
                .style("width", "100%")
                .style("height", height)
                .style("margin-left", "auto")
                .style("margin-right", "auto");
        } else {
            d3.select("#" + containerid)
                .style("width", null)
                .style("height", null);
        }
    }

    setSize(width, height) {
        const svgid = this.svgid;

        if (HTMLWidgets.shinyMode) {
            d3.select("#" + svgid)
                .style("height", height);
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

    animateGElements(opacity, offx, offy, delayover, delayout) {
        const selected_class = this.hoverClassname();
        const sel_both = d3.selectAll('#' + this.svgid + ' *');
        const tooltipstr = "." + this.tooltipClassname();
        const svgid = this.svgid;
        sel_both.on("mouseover", function (d) {
            if (this.getAttribute("data-id") !== null) {
                var curr_sel = d3.selectAll('#' + svgid +
                    ' *[data-id="' + this.getAttribute("data-id") + '"]');
                curr_sel.classed(selected_class, true);
            }
            if (this.getAttribute("title") !== null) {
                d3.select(tooltipstr).transition()
                    .duration(delayover)
                    .style("opacity", opacity);
                d3.select(tooltipstr).html(this.getAttribute("title"))
                    .style("left", (d3.event.pageX + offx) + "px")
                    .style("top", (d3.event.pageY + offy) + "px");
            }
        })
            .on("mouseout", function (d) {
                if (this.getAttribute("data-id") !== null) {
                    var curr_sel = d3.selectAll('#' + svgid +
                        ' *[data-id="' + d3.select(d3.event.currentTarget).attr("data-id") + '"]');
                    curr_sel.classed(selected_class, false);
                }
                if (this.getAttribute("title") !== null) {
                    d3.select(tooltipstr).transition()
                        .duration(delayout)
                        .style("opacity", 0);
                }
            });

    }

    selectizeMultiple() {
        const sel_data_id = d3.selectAll('#' + this.svgid + ' *[data-id]');
        let dataSel = this.dataSelected;
        const that = this;
        sel_data_id.on("click", function (d, i) {

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
        let dataSel = this.dataSelected;
        const that = this;
        sel_data_id.on("click", function (d, i) {

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
        let dataSel = this.dataSelected;
        const that = this;
        sel_data_id.on("click", null);
    }

    refreshSelected() {
        const selected_class = this.selectedClassname();
        const svgid = this.svgid;
        var svg = d3.select('#' + svgid);
        svg.selectAll('*[data-id]').classed(selected_class, false);
        const that = this;
        d3.selectAll(that.dataSelected).each(function (d, i) {
            svg.selectAll('*[data-id=\"' + that.dataSelected[i] + '\"]').classed(selected_class, true);
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
        return (svg.selectAll('*[data-id]').size() > 0);
    }

    lasso_on(add) {
        const svgid = this.svgid;
        const that = this;
        let lasso_ = d3.lasso();
        var lasso_start = function () { };
        var lasso_draw = function () { };
        var lasso_end = function () {
            lasso_.selectedItems().each(function (d, i) {
                d3.select(this).classed(that.selectedClassname, true);
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
