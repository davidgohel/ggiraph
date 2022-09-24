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
    saveSvgAsPng(document.getElementById(this.svgid), this.pngname, {
      encoderOptions: 1
    });
  }
}
