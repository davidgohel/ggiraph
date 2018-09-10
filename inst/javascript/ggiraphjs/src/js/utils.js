import * as svgtopng from 'save-svg-as-png'

export function parseFunction (str) {
    var fn_body_idx = str.indexOf('{'),
        fn_body = str.substring(fn_body_idx+1, str.lastIndexOf('}')),
        fn_declare = str.substring(0, fn_body_idx),
        fn_params = fn_declare.substring(fn_declare.indexOf('(')+1, fn_declare.lastIndexOf(')')),
        args = fn_params.split(',');
  
    args.push(fn_body);
  
    function Fn () {
      return Function.apply(this, args);
    }
    Fn.prototype = Function.prototype;
      
    return new Fn();
  }


// from https://stackoverflow.com/questions/5916900/how-can-you-detect-the-version-of-a-browser
export function navigator_id(){
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

export function add_ui(that, addLasso, addZoom, saveaspng, classpos) {
    const divToolbar = d3.select("#" + that.containerid + " .girafe_container_std").append("div").classed('ggiraph-toolbar', true);
    divToolbar.classed(classpos, true);
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

    if (saveaspng) {
        const divToolbarMisc = divToolbar.append("div")
            .classed('ggiraph-toolbar-block', true);
        divToolbarMisc.append("a")
            .classed('ggiraph-toolbar-icon', true)
            .classed('neutral', true)
            .attr('title', 'download png')
            .on('click', function () {
                if(typeof Promise !== "undefined" && Promise.toString().indexOf("[native code]") !== -1){
                    svgtopng.saveSvgAsPng(document.getElementById(that.svgid), "diagram.png");
                } else {
                    console.error("This navigator does not support Promises");
                }
                
            })
            .html("<svg width='15pt' height='15pt' viewBox='0 0 512 512' xmlns='http://www.w3.org/2000/svg'><g><polygon points='95 275 95 415 415 415 415 275 375 275 375 380 135 380 135 275'/><polygon points='220 30 220 250 150 175 150 245 250 345 350 245 350 175 280 250 280 30'/></g></svg>");
    }
}
