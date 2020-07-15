export function parseFunction(str) {
  const fn_body_idx = str.indexOf('{'),
    fn_body = str.substring(fn_body_idx + 1, str.lastIndexOf('}')),
    fn_declare = str.substring(0, fn_body_idx),
    fn_params = fn_declare.substring(
      fn_declare.indexOf('(') + 1,
      fn_declare.lastIndexOf(')')
    ),
    args = fn_params.split(',');

  args.push(fn_body);

  function Fn() {
    return Function.apply(this, args);
  }
  Fn.prototype = Function.prototype;

  return new Fn();
}

// from https://stackoverflow.com/questions/5916900/how-can-you-detect-the-version-of-a-browser
export function navigator_id() {
  const ua = navigator.userAgent;
  let tem,
    M =
      ua.match(
        /(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i
      ) || [];
  if (/trident/i.test(M[1])) {
    tem = /\brv[ :]+(\d+)/g.exec(ua) || [];
    return 'IE ' + (tem[1] || '');
  }
  if (M[1] === 'Chrome') {
    tem = ua.match(/\b(OPR|Edge)\/(\d+)/);
    if (tem !== null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
  }
  M = M[2] ? [M[1], M[2]] : [navigator.appName, navigator.appVersion, '-?'];
  if ((tem = ua.match(/version\/(\d+)/i)) !== null) M.splice(1, 1, tem[1]);
  return M.join(' ');
}

// Calculates the local coordinates of a mouse/touch event
// Adapted from d3 clientPoint
// node: an svg element
// event: a d3 event
export function svgClientPoint(node, event) {
  const svg = node.ownerSVGElement || node;
  const rect = node.getBoundingClientRect();

  if (svg.createSVGPoint) {
    let point = svg.createSVGPoint();
    point.x = event.clientX;
    point.y = event.clientY;
    const transform = node.getScreenCTM();
    if (transform.e === 0) {
      // firefox omits this
      transform.e = rect.left;
    }
    point = point.matrixTransform(transform.inverse());
    return [point.x, point.y];
  }

  return [
    event.clientX - rect.left - node.clientLeft,
    event.clientY - rect.top - node.clientTop
  ];
}
