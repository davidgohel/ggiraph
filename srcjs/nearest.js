import * as d3 from 'd3';
import Flatbush from 'flatbush';
import {
  distanceToCircle,
  distanceToSegments,
  rectIntersectsRect,
  rectIntersectsShape
} from './geom';

// TODO:
// tooltip should not cover the nearest element
// take stroke width into account if possible

export default class NearestHandler {
  constructor(svgid, attrNames, maximum_distance) {
    this.svgid = svgid;
    this.attrNames = attrNames;
    this.maximum_distance = maximum_distance;
    this.spatialIndex = null;
    this.nodeIds = null;
    this.debug = false;
  }

  init() {
    if (this.maximum_distance === 0) {
      // nothing to do here, return false to discard this
      return false;
    }
    if (!this.maximum_distance) {
      this.maximum_distance = Infinity;
    }
    const rootNode = document.getElementById(this.svgid + '_rootg');
    const selector = this.attrNames
      .map((x) => '*[nearest][' + x + ']')
      .join(', ');
    // select nodes
    const nodes = Array.from(rootNode.querySelectorAll(selector)).filter(
      function (node) {
        return (
          node instanceof SVGCircleElement ||
          node instanceof SVGImageElement ||
          node instanceof SVGLineElement ||
          node instanceof SVGPathElement ||
          node instanceof SVGPolygonElement ||
          node instanceof SVGPolylineElement ||
          node instanceof SVGRectElement ||
          node instanceof SVGTextElement
        );
      }
    );
    if (!nodes.length) {
      // nothing to do here, return false to discard this
      return false;
    }

    // construct spatial index
    this.spatialIndex = new Flatbush(nodes.length);
    const svgNode = rootNode.ownerSVGElement;
    const tosvg = svgNode.getCTM().inverse();
    let tonode, box, boxpoints, extent;
    let n = 0;
    this.nodeIds = Array(nodes.length);
    nodes.forEach(function (node) {
      this.nodeIds[n++] = node.id;
      tonode = node.getCTM();
      // get the bounding box of the node and apply transforms
      box = node.getBBox();
      boxpoints = this.extractPoints(box).map((p) =>
        p.matrixTransform(tonode).matrixTransform(tosvg)
      );
      // add the box extent to the spatial index
      extent = this.getExtent(boxpoints);
      this.spatialIndex.add(extent.minx, extent.miny, extent.maxx, extent.maxy);

      if (this.debug) {
        //this.drawObject(boxp, rootNode);
        this.drawObject(
          this.getExtentRect(extent, svgNode),
          svgNode,
          node.id + '_extent'
        );
      }

      // collect points to calculate distance
      if (
        node instanceof SVGRectElement ||
        node instanceof SVGImageElement ||
        node instanceof SVGTextElement
      ) {
        node.gpoints = boxpoints;
        node.gpoints.shape = 'polygon';
      } else {
        node.gpoints = this.extractPoints(node).map((p) =>
          p.matrixTransform(tonode).matrixTransform(tosvg)
        );
        if (node instanceof SVGCircleElement) {
          node.gpoints[0].r = node.r.baseVal.value;
          node.gpoints.shape = 'circle';
        } else if (
          node instanceof SVGLineElement ||
          node instanceof SVGPolylineElement
        ) {
          node.gpoints.shape = 'polyline';
        }
      }
      if (this.debug) {
        this.drawObject(node.gpoints, svgNode, node.id + '_points');
      }
      node.grect = this.getExtentRect(extent, svgNode);
    }, this);

    // build spatial index
    this.spatialIndex.finish();
    this.nodeIds = nodes.map((n) => n.id);

    // store rootNode box
    box = rootNode.getBBox();
    tonode = rootNode.getCTM();
    rootNode.gpoints = this.extractPoints(box).map((p) =>
      p.matrixTransform(tonode).matrixTransform(tosvg)
    );
    if (this.debug) {
      this.drawObject(
        rootNode.gpoints,
        svgNode,
        rootNode.id + '_rootpoints',
        'none',
        '#00ff00'
      );
    }

    // return true to add to list of handLers
    return true;
  }

  destroy() {
    this.spatialIndex = null;
    this.nodeIds = null;
  }

  isValidTarget(target) {
    return target instanceof SVGGraphicsElement;
  }

  applyOn(target, mousePos) {
    try {
      if (!this.isValidTarget(target)) {
        return null;
      }
      const svgNode = document.getElementById(this.svgid);
      const rootNode = document.getElementById(this.svgid + '_rootg');
      if (svgNode === target) {
        target = rootNode;
      }
      // get mouse position in svg coord space
      mousePos = mousePos.matrixTransform(target.getScreenCTM().inverse());
      if (this.debug)
        this.drawObject([mousePos], svgNode, svgNode.id + '_mouse');

      // get maximum 10 nearest elements from the index
      let neighbors = this.spatialIndex
        .neighbors(mousePos.x, mousePos.y, 10, this.maximum_distance)
        // unique values only
        .filter((value, index, self) => self.indexOf(value) === index)
        // map to node ids
        .map((index) => this.nodeIds[index])
        // sort them
        .sort()
        // map to nodes
        .map((id) => document.getElementById(id));

      // filter by current view
      let view, viewpoints;
      if (neighbors.length) {
        // calculate the current zoomed view
        let zm = d3.zoomTransform(rootNode);
        zm = new DOMMatrix([zm.k, 0, 0, zm.k, zm.x, zm.y]).inverse();
        viewpoints = rootNode.gpoints.map((p) => p.matrixTransform(zm));
        view = this.getRect(viewpoints, svgNode);

        if (this.debug)
          this.drawObject(
            view,
            svgNode,
            rootNode.id + '_view',
            'none',
            '#00aa00'
          );

        // keep the nodes with their bbox is inside the current view
        neighbors = neighbors.filter((node) =>
          rectIntersectsRect(view, node.grect)
        );
      }

      // further filtering with checkIntersection
      if (neighbors.length && svgNode.checkIntersection) {
        const toroot = rootNode.getCTM();
        viewpoints = viewpoints.map((p) => p.matrixTransform(toroot));
        view = this.getRect(viewpoints, svgNode);
        neighbors = neighbors.filter((node) =>
          svgNode.checkIntersection(node, view)
        );
      } else if (neighbors.length) {
        neighbors = neighbors.filter((node) =>
          rectIntersectsShape(view, node.gpoints)
        );
      }

      // calculate the nearest neighbor
      let nearest = null;
      if (neighbors.length === 1) {
        nearest = neighbors[0];
      } else if (neighbors.length) {
        let distance = Infinity,
          min_distance = Infinity;
        neighbors.forEach(function (node) {
          if (node instanceof SVGCircleElement) {
            distance = distanceToCircle(mousePos, node.gpoints[0]);
          } else {
            distance = distanceToSegments(mousePos, node.gpoints);
          }
          if (distance <= min_distance && distance <= this.maximum_distance) {
            min_distance = distance;
            nearest = node;
          }
        }, this);
      }
      return nearest;
    } catch (e) {
      console.error(e);
    }
    return null;
  }

  extractPoints(obj) {
    let points, p, plist, i, d, m;
    const rePathCoords = new RegExp('([\\d\\.]+) ([\\d\\.]+)', 'g');
    if (obj instanceof SVGRect || obj instanceof DOMRect) {
      return [
        new DOMPoint(obj.x, obj.y),
        new DOMPoint(obj.x + obj.width, obj.y),
        new DOMPoint(obj.x + obj.width, obj.y + obj.height),
        new DOMPoint(obj.x, obj.y + obj.height)
      ];
    } else if (
      obj instanceof SVGRectElement ||
      obj instanceof SVGImageElement
    ) {
      return [
        new DOMPoint(obj.x.baseVal.value, obj.y.baseVal.value),
        new DOMPoint(
          obj.x.baseVal.value + obj.width.baseVal.value,
          obj.y.baseVal.value
        ),
        new DOMPoint(
          obj.x.baseVal.value + obj.width.baseVal.value,
          obj.y.baseVal.value + obj.height.baseVal.value
        ),
        new DOMPoint(
          obj.x.baseVal.value,
          obj.y.baseVal.value + obj.height.baseVal.value
        )
      ];
    } else if (obj instanceof SVGCircleElement) {
      p = new DOMPoint(obj.cx.baseVal.value, obj.cy.baseVal.value);
      p.r = obj.r.baseVal.value;
      return [p];
    } else if (obj instanceof SVGLineElement) {
      points = [
        new DOMPoint(obj.x1.baseVal.value, obj.y1.baseVal.value),
        new DOMPoint(obj.x2.baseVal.value, obj.y2.baseVal.value)
      ];
      points.shape = 'polyline';
    } else if (
      obj instanceof SVGPolylineElement ||
      obj instanceof SVGPolygonElement
    ) {
      points = [];
      plist = obj.points;
      for (i = 0; i < plist.length; i++) {
        p = plist.getItem(i);
        if (!(p instanceof DOMPoint)) {
          p = new DOMPoint(p.x, p.y);
        }
        points.push(p);
      }
      points.shape = obj instanceof SVGPolylineElement ? 'polyline' : 'polygon';
      return points;
    } else if (obj instanceof SVGPathElement) {
      points = [];
      d = obj.getAttribute('d');
      while ((m = rePathCoords.exec(d)) !== null) {
        points.push(new DOMPoint(parseFloat(m[1]), parseFloat(m[2])));
      }
      return points;
    } else {
      throw (
        'Error in extractPoints: unimplemented object type: ' +
        Object.prototype.toString.call(obj)
      );
    }
  }

  getExtent(points) {
    const xx = points.map((p) => p.x);
    const yy = points.map((p) => p.y);
    return {
      minx: Math.min.apply(null, xx),
      maxx: Math.max.apply(null, xx),
      miny: Math.min.apply(null, yy),
      maxy: Math.max.apply(null, yy)
    };
  }

  getExtentRect(extent, svgNode) {
    const rect = svgNode.createSVGRect();
    rect.x = extent.minx;
    rect.y = extent.miny;
    rect.width = extent.maxx - extent.minx;
    rect.height = extent.maxy - extent.miny;
    return rect;
  }

  getRect(points, svgNode) {
    return this.getExtentRect(this.getExtent(points), svgNode);
  }

  buffer(rect, buffer) {
    rect.x -= buffer;
    rect.y -= buffer;
    rect.width += buffer * 2;
    rect.height += buffer * 2;
    return rect;
  }

  drawObject(obj, parent, id, fill = '#ff000033', stroke = '#ff0000') {
    const svgns = 'http://www.w3.org/2000/svg';
    let el = document.getElementById(id);
    let name;
    if (Array.isArray(obj) && obj.length === 1) {
      obj = obj[0];
    }
    if (!el) {
      name = obj.shape || 'polygon';
      if (obj instanceof SVGPoint || obj instanceof DOMPoint) {
        name = 'circle';
      } else if (obj instanceof SVGRect || obj instanceof DOMRect) {
        name = 'rect';
      }
      el = document.createElementNS(svgns, name);
      el.setAttribute('id', id);
      if (name !== 'polyline') el.setAttribute('fill', fill);
      el.setAttribute('stroke', stroke);
      el.setAttribute('style', 'pointer-events: none;');
      parent.appendChild(el);
    } else {
      name = el.localName;
    }
    if (name === 'circle') {
      el.setAttribute('cx', obj.x);
      el.setAttribute('cy', obj.y);
      el.setAttribute('r', obj.r || '3pt');
    } else if (name === 'rect') {
      el.setAttribute('x', obj.x);
      el.setAttribute('y', obj.y);
      el.setAttribute('width', obj.width);
      el.setAttribute('height', obj.height);
    } else if (name === 'polygon' || name === 'polyline') {
      let str = '';
      obj.forEach(function (p) {
        str += p.x + ' ' + p.y + ' ';
      });
      el.setAttribute('points', str);
    }
    return el;
  }
}
