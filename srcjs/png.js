export default class PngHandler {
  constructor(svgid, options) {
    this.svgid = svgid;
    this.pngname = options.pngname + '.png';
  }

  init() {
    return (
      typeof saveSvgAsPng === 'function' &&
      typeof Promise !== 'undefined' &&
      Promise.toString().indexOf('[native code]') !== -1
    );
  }

  destroy() {
    this.fonts = null;
  }

  getButtons() {
    const that = this;
    return [
      {
        key: 'saveaspng',
        block: 'misc',
        class: 'neutral',
        tooltip: 'download png',
        icon: "<svg xmlns='http://www.w3.org/2000/svg' role='img' viewBox='0 0 512 512'><g><polygon points='95 275 95 415 415 415 415 275 375 275 375 380 135 380 135 275'/><polygon points='220 30 220 250 150 175 150 245 250 345 350 245 350 175 280 250 280 30'/></g></svg>",
        onclick: function () {
          that.save_as_png();
        }
      }
    ];
  }

  save_as_png() {
    if (!this.fonts) {
      this.fonts = get_doc_fonts();
    }
    saveSvgAsPng(document.getElementById(this.svgid), this.pngname, {
      encoderOptions: 1,
      fonts: this.fonts
    });
  }
}

function get_doc_fonts() {
  const fontOrder = ['woff', 'ttf', 'otf', 'woff2', 'eot'];
  const fontFormats = {
    woff2: 'font/woff2',
    woff: 'font/woff',
    otf: 'application/x-font-opentype',
    ttf: 'application/x-font-ttf',
    eot: 'application/vnd.ms-fontobject'
  };
  const reCss = /(^.+src:\s*)(.+?)(;.*)$/;
  const reUrl = /url\(["']?(.+?)["']?\)(\s*format\(.+?\))?/g;
  const reUrlFmt = new RegExp(
    'url\\(["\\\']?(.+?\\.(' +
      Object.keys(fontFormats).join('|') +
      ')(\\?.*?)?)["\\\']?\\)'
  );

  function parseUrl(css, href) {
    const match = css.match(reUrlFmt);
    let url = (match && match[1]) || '';
    if (!url || url.match(/^data:/) || url === 'about:blank') return;
    if (url.startsWith('../')) {
      url = href + '/../' + url;
    } else if (url.startsWith('./')) {
      url = href + '/.' + url;
    }
    return {
      fmt: match[2],
      url: url,
      css: css
    };
  }

  function getFontRules() {
    return Array.from(document.styleSheets)
      .map(function (sheet) {
        // get stylesheet rules
        try {
          return {
            cssRules: sheet.cssRules,
            href: sheet.href
          };
        } catch (e) {
          console.warn('Stylesheet could not be loaded: ' + sheet.href, e);
        }
      })
      .map(function (sheet) {
        if (!sheet || !sheet.cssRules) return [];
        // get font rules
        return Array.from(sheet.cssRules)
          .filter(function (rule) {
            return rule.cssText.match(/^@font-face/);
          })
          .map(function (rule) {
            return {
              href: sheet.href,
              cssText: rule.cssText
            };
          });
      })
      .flat();
  }

  function getOptimalFont(rule) {
    const match = rule.cssText.match(reCss); // parse rule
    if (!match) return;
    const css_start = match[1]; // text up to the src
    const src = match[2]; // the src property
    const css_end = match[3]; // text after the src
    const urls = src.match(reUrl); // array of urls
    if (!Array.isArray(urls)) return;
    return urls
      .map(function (url) {
        // parse url
        return parseUrl(url, rule.href);
      })
      .filter(function (font) {
        // keep valid ones
        return !!font;
      })
      .map(function (font) {
        // set the order field
        font.order = fontOrder.indexOf(font.fmt);
        return font;
      })
      .sort(function (font1, font2) {
        // sort by order
        return font1.order - font2.order;
      })
      .slice(0, 1) // the first one is the optimal
      .map(function (font) {
        return {
          text: css_start + font.css + css_end,
          format: fontFormats[font.fmt],
          url: font.url
        };
      })
      .pop();
  }

  // get font rules
  return getFontRules()
    .map(function (rule) {
      // get the optimal font
      return getOptimalFont(rule);
    })
    .filter(function (font) {
      // keep valid ones
      return !!font;
    });
}
