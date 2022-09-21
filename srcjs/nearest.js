import * as d3 from 'd3';
import Flatbush from 'flatbush';
import {
  distanceToCircle,
  distanceToSegments,
  rectIntersectsRect,
  rectIntersectsShape,
  extractPoints,
  getExtent,
  getExtentRect,
  getRect,
  drawObject
} from './geom';

// TODO:
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
    const tosvg = rootNode.getCTM().inverse();
    let tonode, box, boxpoints, extent;
    const clipIds = new Set();
    let clip;
    let n = 0;
    this.nodeIds = Array(nodes.length);
    nodes.forEach(function (node) {
      this.nodeIds[n++] = node.id;
      tonode = node.getCTM();
      // get the bounding box of the node and apply transforms
      box = node.getBBox();
      boxpoints = extractPoints(box).map((p) =>
        p.matrixTransform(tonode).matrixTransform(tosvg)
      );
      // add the box extent to the spatial index
      extent = getExtent(boxpoints);
      this.spatialIndex.add(extent.minx, extent.miny, extent.maxx, extent.maxy);

      if (this.debug) {
        //drawObject(boxp, rootNode);
        drawObject(
          getExtentRect(extent, svgNode),
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
        node.gpoints = extractPoints(node).map((p) =>
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
        drawObject(node.gpoints, svgNode, node.id + '_points');
      }
      node.grect = getExtentRect(extent, svgNode);

      clip = node.parentElement.getAttribute('clip-path');
      if (clip) {
        clipIds.add(clip.replace(/url\(#|\)/g, ''));
      } else {
        clipIds.add(rootNode.id);
      }
    }, this);

    // build spatial index
    this.spatialIndex.finish();
    this.nodeIds = nodes.map((n) => n.id);

    // store rootNode box
    box = rootNode.getBBox();
    tonode = rootNode.getCTM();
    rootNode.gpoints = extractPoints(box).map((p) =>
      p.matrixTransform(tonode).matrixTransform(tosvg)
    );
    if (this.debug) {
      drawObject(
        rootNode.gpoints,
        svgNode,
        rootNode.id + '_rootpoints',
        'none',
        '#00ff00'
      );
    }

    // store clips: areas where we should act
    if (clipIds.size == 0) {
      clipIds.add(rootNode.id);
    }
    // we create the clips only if the whole plot area has not been added
    if (!clipIds.has(rootNode.id)) {
      this.clips = Array.from(clipIds.values())
        .map((id) => document.getElementById(id))
        .map(function (clip) {
          return (
            Array
              // loop clip children
              .from(clip.childNodes)
              .filter((node) => node instanceof SVGGraphicsElement)
              .map(function (node) {
                tonode = node.getCTM();
                box = node.getBBox();
                // firefox returns empty box
                if (box.width === 0 || box.height === 0) {
                  if (node instanceof SVGRectElement) {
                    box.x = node.x.baseVal.value;
                    box.y = node.y.baseVal.value;
                    box.width = node.width.baseVal.value;
                    box.height = node.height.baseVal.value;
                  } else {
                    return null;
                  }
                }
                boxpoints = extractPoints(box).map((p) =>
                  p.matrixTransform(tonode).matrixTransform(tosvg)
                );
                return getExtentRect(getExtent(boxpoints), svgNode);
              })
              .flat()
              .filter((o) => !!o)
          );
        })
        .flat();
      if (!this.clips.length) this.clips = null;
    } else {
      this.clips = null;
    }

    // return true to add to list of handLers
    return true;
  }

  destroy() {
    this.spatialIndex = null;
    this.nodeIds = null;
    this.clips = null;
  }

  isValidTarget(target) {
    return target instanceof SVGGraphicsElement;
  }

  applyOn(target, event) {
    try {
      if (!this.isValidTarget(target)) {
        return null;
      }
      let mousePos = new DOMPoint(event.clientX, event.clientY);
      const svgNode = document.getElementById(this.svgid);
      const rootNode = document.getElementById(this.svgid + '_rootg');
      if (svgNode === target) {
        target = rootNode;
      }
      // get mouse position in svg coord space
      mousePos = mousePos.matrixTransform(target.getScreenCTM().inverse());
      if (this.debug) drawObject([mousePos], svgNode, svgNode.id + '_mouse');

      // check that we are inside an active clip area
      if (
        this.clips &&
        !this.clips.find((r) => rectIntersectsShape(r, [mousePos]))
      )
        return null;

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
        view = getRect(viewpoints, svgNode);

        if (this.debug)
          drawObject(view, svgNode, rootNode.id + '_view', 'none', '#00aa00');

        // keep the nodes with their bbox is inside the current view
        neighbors = neighbors.filter((node) =>
          rectIntersectsRect(view, node.grect)
        );
      }

      // further filtering with checkIntersection
      if (neighbors.length && svgNode.checkIntersection) {
        const toroot = rootNode.getCTM();
        viewpoints = viewpoints.map((p) => p.matrixTransform(toroot));
        view = getRect(viewpoints, svgNode);
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
}
