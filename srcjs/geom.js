// returns a rect with the active window viewport
export function getWindowViewport(node) {
  const doc = node.ownerDocument;
  const docElem = doc.documentElement;
  const win = doc.defaultView;
  return new window.DOMRect(
    win.pageXOffset || docElem.scrollLeft,
    win.pageYOffset || docElem.scrollTop,
    docElem.clientWidth,
    docElem.clientHeight
  );
}

// returns a transformation matrix for an html element
// it can be used to transform the element coords to document coords
export function getHTMLElementMatrix(node) {
  const identityMatrix = new window.DOMMatrix();
  let matrix = identityMatrix;
  let x = node;
  const win = node.ownerDocument.defaultView || window;
  const viewport = getWindowViewport(node);

  while (x != undefined && x !== x.ownerDocument.documentElement) {
    const computedStyle = win.getComputedStyle(x, undefined);
    const transform = computedStyle.transform || 'none';
    const c =
      transform === 'none' ? identityMatrix : new window.DOMMatrix(transform);
    matrix = c.multiply(matrix);
    x = x.parentNode;
  }

  const w = node.offsetWidth;
  const h = node.offsetHeight;
  const p0 = new window.DOMPoint(0, 0).matrixTransform(matrix);
  const p1 = new window.DOMPoint(w, 0).matrixTransform(matrix);
  const p2 = new window.DOMPoint(w, h).matrixTransform(matrix);
  const p3 = new window.DOMPoint(0, h).matrixTransform(matrix);
  const left = Math.min(p0.x, p1.x, p2.x, p3.x);
  const top = Math.min(p0.y, p1.y, p2.y, p3.y);

  const rect = node.getBoundingClientRect();
  matrix = identityMatrix
    .translate(viewport.x + rect.left - left, viewport.y + rect.top - top, 0)
    .multiply(matrix);

  return matrix;
}

// Geometry polyfills adapted from:
// https://github.com/jarek-foksa/geometry-polyfill/blob/master/geometry-polyfill.js
// Only the necessary methods for this project are kept

// minimal polyfill for DOMPoint
// https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/geometry/dom_point_read_only.cc
window.DOMPoint =
  window.DOMPoint ||
  class DOMPoint {
    constructor(x = 0, y = 0, z = 0, w = 1) {
      this.x = x;
      this.y = y;
      this.z = z;
      this.w = w;
    }
  };

window.DOMPoint.prototype.matrixTransform =
  window.DOMPoint.prototype.matrixTransform ||
  function matrixTransform(matrix) {
    if (
      (matrix.is2D || matrix instanceof SVGMatrix) &&
      this.z === 0 &&
      this.w === 1
    ) {
      return new DOMPoint(
        this.x * matrix.a + this.y * matrix.c + matrix.e,
        this.x * matrix.b + this.y * matrix.d + matrix.f,
        0,
        1
      );
    } else {
      return new DOMPoint(
        this.x * matrix.m11 +
          this.y * matrix.m21 +
          this.z * matrix.m31 +
          this.w * matrix.m41,
        this.x * matrix.m12 +
          this.y * matrix.m22 +
          this.z * matrix.m32 +
          this.w * matrix.m42,
        this.x * matrix.m13 +
          this.y * matrix.m23 +
          this.z * matrix.m33 +
          this.w * matrix.m43,
        this.x * matrix.m14 +
          this.y * matrix.m24 +
          this.z * matrix.m34 +
          this.w * matrix.m44
      );
    }
  };

// minimal polyfill for DOMRect
// https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/geometry/dom_rect_read_only.cc
{
  class DOMRect {
    constructor(x = 0, y = 0, width = 0, height = 0) {
      this.x = x;
      this.y = y;
      this.width = width;
      this.height = height;
    }

    get top() {
      return this.y;
    }

    get left() {
      return this.x;
    }

    get right() {
      return this.x + this.width;
    }

    get bottom() {
      return this.y + this.height;
    }
  }

  for (const propertyName of ['top', 'right', 'bottom', 'left']) {
    const propertyDescriptor = Object.getOwnPropertyDescriptor(
      DOMRect.prototype,
      propertyName
    );
    propertyDescriptor.enumerable = true;
    Object.defineProperty(DOMRect.prototype, propertyName, propertyDescriptor);
  }

  window.DOMRect = window.DOMRect || DOMRect;
}

// minimal polyfill for DOMMatrix
// https://github.com/chromium/chromium/blob/master/third_party/blink/renderer/core/geometry/dom_matrix_read_only.cc
// https://github.com/tocharomera/generativecanvas/blob/master/node-canvas/lib/DOMMatrix.js
{
  const M11 = 0,
    M12 = 1,
    M13 = 2,
    M14 = 3;
  const M21 = 4,
    M22 = 5,
    M23 = 6,
    M24 = 7;
  const M31 = 8,
    M32 = 9,
    M33 = 10,
    M34 = 11;
  const M41 = 12,
    M42 = 13,
    M43 = 14,
    M44 = 15;

  const A = M11,
    B = M12;
  const C = M21,
    D = M22;
  const E = M41,
    F = M42;

  const $values = Symbol();
  const $is2D = Symbol();

  const parseMatrix = (init) => {
    let parsed = init.replace(/matrix\(/, '');
    parsed = parsed.split(/,/, 7);

    if (parsed.length !== 6) {
      throw new Error(`Failed to parse ${init}`);
    }

    parsed = parsed.map(parseFloat);

    return [
      parsed[0],
      parsed[1],
      0,
      0,
      parsed[2],
      parsed[3],
      0,
      0,
      0,
      0,
      1,
      0,
      parsed[4],
      parsed[5],
      0,
      1
    ];
  };

  const parseMatrix3d = (init) => {
    let parsed = init.replace(/matrix3d\(/, '');
    parsed = parsed.split(/,/, 17);

    if (parsed.length !== 16) {
      throw new Error(`Failed to parse ${init}`);
    }

    return parsed.map(parseFloat);
  };

  const parseTransform = (tform) => {
    const type = tform.split(/\(/, 1)[0];

    if (type === 'matrix') {
      return parseMatrix(tform);
    } else if (type === 'matrix3d') {
      return parseMatrix3d(tform);
    } else {
      throw new Error(`${type} parsing not implemented`);
    }
  };

  const setNumber2D = (receiver, index, value) => {
    if (typeof value !== 'number') {
      throw new TypeError('Expected number');
    }

    receiver[$values][index] = value;
  };

  const setNumber3D = (receiver, index, value) => {
    if (typeof value !== 'number') {
      throw new TypeError('Expected number');
    }

    if (index === M33 || index === M44) {
      if (value !== 1) {
        receiver[$is2D] = false;
      }
    } else if (value !== 0) {
      receiver[$is2D] = false;
    }

    receiver[$values][index] = value;
  };

  const newInstance = (values) => {
    const instance = Object.create(DOMMatrix.prototype);
    instance.constructor = DOMMatrix;
    instance[$is2D] = true;
    instance[$values] = values;

    return instance;
  };

  const multiply = (first, second) => {
    const dest = new Float64Array(16);

    for (let i = 0; i < 4; i++) {
      for (let j = 0; j < 4; j++) {
        let sum = 0;

        for (let k = 0; k < 4; k++) {
          sum += first[i * 4 + k] * second[k * 4 + j];
        }

        dest[i * 4 + j] = sum;
      }
    }

    return dest;
  };

  class DOMMatrix {
    get m11() {
      return this[$values][M11];
    }
    set m11(value) {
      setNumber2D(this, M11, value);
    }
    get m12() {
      return this[$values][M12];
    }
    set m12(value) {
      setNumber2D(this, M12, value);
    }
    get m13() {
      return this[$values][M13];
    }
    set m13(value) {
      setNumber3D(this, M13, value);
    }
    get m14() {
      return this[$values][M14];
    }
    set m14(value) {
      setNumber3D(this, M14, value);
    }
    get m21() {
      return this[$values][M21];
    }
    set m21(value) {
      setNumber2D(this, M21, value);
    }
    get m22() {
      return this[$values][M22];
    }
    set m22(value) {
      setNumber2D(this, M22, value);
    }
    get m23() {
      return this[$values][M23];
    }
    set m23(value) {
      setNumber3D(this, M23, value);
    }
    get m24() {
      return this[$values][M24];
    }
    set m24(value) {
      setNumber3D(this, M24, value);
    }
    get m31() {
      return this[$values][M31];
    }
    set m31(value) {
      setNumber3D(this, M31, value);
    }
    get m32() {
      return this[$values][M32];
    }
    set m32(value) {
      setNumber3D(this, M32, value);
    }
    get m33() {
      return this[$values][M33];
    }
    set m33(value) {
      setNumber3D(this, M33, value);
    }
    get m34() {
      return this[$values][M34];
    }
    set m34(value) {
      setNumber3D(this, M34, value);
    }
    get m41() {
      return this[$values][M41];
    }
    set m41(value) {
      setNumber2D(this, M41, value);
    }
    get m42() {
      return this[$values][M42];
    }
    set m42(value) {
      setNumber2D(this, M42, value);
    }
    get m43() {
      return this[$values][M43];
    }
    set m43(value) {
      setNumber3D(this, M43, value);
    }
    get m44() {
      return this[$values][M44];
    }
    set m44(value) {
      setNumber3D(this, M44, value);
    }

    get a() {
      return this[$values][A];
    }
    set a(value) {
      setNumber2D(this, A, value);
    }
    get b() {
      return this[$values][B];
    }
    set b(value) {
      setNumber2D(this, B, value);
    }
    get c() {
      return this[$values][C];
    }
    set c(value) {
      setNumber2D(this, C, value);
    }
    get d() {
      return this[$values][D];
    }
    set d(value) {
      setNumber2D(this, D, value);
    }
    get e() {
      return this[$values][E];
    }
    set e(value) {
      setNumber2D(this, E, value);
    }
    get f() {
      return this[$values][F];
    }
    set f(value) {
      setNumber2D(this, F, value);
    }

    get is2D() {
      return this[$is2D];
    }

    get isIdentity() {
      const values = this[$values];

      return (
        values[M11] === 1 &&
        values[M12] === 0 &&
        values[M13] === 0 &&
        values[M14] === 0 &&
        values[M21] === 0 &&
        values[M22] === 1 &&
        values[M23] === 0 &&
        values[M24] === 0 &&
        values[M31] === 0 &&
        values[M32] === 0 &&
        values[M33] === 1 &&
        values[M34] === 0 &&
        values[M41] === 0 &&
        values[M42] === 0 &&
        values[M43] === 0 &&
        values[M44] === 1
      );
    }

    constructor(init) {
      this[$is2D] = true;

      this[$values] = new Float64Array([
        1,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        1
      ]);

      // Parse CSS transformList
      if (typeof init === 'string') {
        if (init === '') {
          return;
        } else {
          const tforms = init.split(/\)\s+/, 20).map(parseTransform);

          if (tforms.length === 0) {
            return;
          }

          init = tforms[0];

          for (let i = 1; i < tforms.length; i++) {
            init = multiply(tforms[i], init);
          }
        }
      }

      let i = 0;

      if (init && init.length === 6) {
        setNumber2D(this, A, init[i++]);
        setNumber2D(this, B, init[i++]);
        setNumber2D(this, C, init[i++]);
        setNumber2D(this, D, init[i++]);
        setNumber2D(this, E, init[i++]);
        setNumber2D(this, F, init[i++]);
      } else if (init && init.length === 16) {
        setNumber2D(this, M11, init[i++]);
        setNumber2D(this, M12, init[i++]);
        setNumber3D(this, M13, init[i++]);
        setNumber3D(this, M14, init[i++]);
        setNumber2D(this, M21, init[i++]);
        setNumber2D(this, M22, init[i++]);
        setNumber3D(this, M23, init[i++]);
        setNumber3D(this, M24, init[i++]);
        setNumber3D(this, M31, init[i++]);
        setNumber3D(this, M32, init[i++]);
        setNumber3D(this, M33, init[i++]);
        setNumber3D(this, M34, init[i++]);
        setNumber2D(this, M41, init[i++]);
        setNumber2D(this, M42, init[i++]);
        setNumber3D(this, M43, init[i++]);
        setNumber3D(this, M44, init[i]);
      } else if (init !== undefined) {
        throw new TypeError('Expected string or array.');
      }
    }

    multiply(other) {
      return newInstance(this[$values]).multiplySelf(other);
    }

    multiplySelf(other) {
      this[$values] = multiply(other[$values], this[$values]);

      if (!other.is2D) {
        this[$is2D] = false;
      }

      return this;
    }

    translate(tx, ty, tz) {
      return newInstance(this[$values]).translateSelf(tx, ty, tz);
    }

    translateSelf(tx = 0, ty = 0, tz = 0) {
      this[$values] = multiply(
        [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, tx, ty, tz, 1],
        this[$values]
      );

      if (tz !== 0) {
        this[$is2D] = false;
      }

      return this;
    }

    scale(scaleX, scaleY, scaleZ, originX, originY, originZ) {
      return newInstance(this[$values]).scaleSelf(
        scaleX,
        scaleY,
        scaleZ,
        originX,
        originY,
        originZ
      );
    }

    scale3d(scale, originX, originY, originZ) {
      return newInstance(this[$values]).scale3dSelf(
        scale,
        originX,
        originY,
        originZ
      );
    }

    scale3dSelf(scale, originX, originY, originZ) {
      return this.scaleSelf(scale, scale, scale, originX, originY, originZ);
    }

    scaleSelf(scaleX, scaleY, scaleZ, originX, originY, originZ) {
      // Not redundant with translate's checks because we need to negate the values later.
      if (typeof originX !== 'number') originX = 0;
      if (typeof originY !== 'number') originY = 0;
      if (typeof originZ !== 'number') originZ = 0;

      this.translateSelf(originX, originY, originZ);

      if (typeof scaleX !== 'number') scaleX = 1;
      if (typeof scaleY !== 'number') scaleY = scaleX;
      if (typeof scaleZ !== 'number') scaleZ = 1;

      this[$values] = multiply(
        [scaleX, 0, 0, 0, 0, scaleY, 0, 0, 0, 0, scaleZ, 0, 0, 0, 0, 1],
        this[$values]
      );

      this.translateSelf(-originX, -originY, -originZ);

      if (scaleZ !== 1 || originZ !== 0) {
        this[$is2D] = false;
      }

      return this;
    }

    inverse() {
      return newInstance(this[$values]).invertSelf();
    }

    invertSelf() {
      if (this[$is2D]) {
        const det =
          this[$values][A] * this[$values][D] -
          this[$values][B] * this[$values][C];

        // Invertable
        if (det !== 0) {
          const result = new DOMMatrix();

          result.a = this[$values][D] / det;
          result.b = -this[$values][B] / det;
          result.c = -this[$values][C] / det;
          result.d = this[$values][A] / det;
          result.e =
            (this[$values][C] * this[$values][F] -
              this[$values][D] * this[$values][E]) /
            det;
          result.f =
            (this[$values][B] * this[$values][E] -
              this[$values][A] * this[$values][F]) /
            det;

          return result;
        }

        // Not invertable
        else {
          this[$is2D] = false;

          this[$values] = [
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN,
            NaN
          ];
        }
      } else {
        throw new Error('3D matrix inversion is not implemented.');
      }
    }
  }

  for (const propertyName of [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'm11',
    'm12',
    'm13',
    'm14',
    'm21',
    'm22',
    'm23',
    'm24',
    'm31',
    'm32',
    'm33',
    'm34',
    'm41',
    'm42',
    'm43',
    'm44',
    'is2D',
    'isIdentity'
  ]) {
    const propertyDescriptor = Object.getOwnPropertyDescriptor(
      DOMMatrix.prototype,
      propertyName
    );
    propertyDescriptor.enumerable = true;
    Object.defineProperty(
      DOMMatrix.prototype,
      propertyName,
      propertyDescriptor
    );
  }

  window.DOMMatrix = window.DOMMatrix || DOMMatrix;
}
