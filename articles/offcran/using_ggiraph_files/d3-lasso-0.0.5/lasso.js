import * as selection from "d3-selection";
import * as drag from "d3-drag";
import classifyPoint from "robust-point-in-polygon";

export default function() {

    var items =[],
        closePathDistance = 75,
        closePathSelect = true,
        isPathClosed = false,
        hoverSelect = true,
        targetArea,
        on = {start:function(){}, draw: function(){}, end: function(){}};

    // Function to execute on call
    function lasso(_this) {

        // add a new group for the lasso
        var g = _this.append("g")
            .attr("class","lasso");
        
        // add the drawn path for the lasso
        var dyn_path = g.append("path")
            .attr("class","drawn");
        
        // add a closed path
        var close_path = g.append("path")
            .attr("class","loop_close");
        
        // add an origin node
        var origin_node = g.append("circle")
            .attr("class","origin");

        // The transformed lasso path for rendering
        var tpath;

        // The lasso origin for calculations
        var origin;

        // The transformed lasso origin for rendering
        var torigin;

        // Store off coordinates drawn
        var drawnCoords;

         // Apply drag behaviors
        var drag = d3.drag()
            .on("start",dragstart)
            .on("drag",dragmove)
            .on("end",dragend);

        // Call drag
        targetArea.call(drag);

        function dragstart() {
            // Init coordinates
            drawnCoords = [];

            // Initialize paths
            tpath = "";
            dyn_path.attr("d",null);
            close_path.attr("d",null);

            // Set every item to have a false selection and reset their center point and counters
            items.nodes().forEach(function(e) {            
                e.__lasso.possible = false;
                e.__lasso.selected = false;
                e.__lasso.hoverSelect = false;
                e.__lasso.loopSelect = false;
                
                var box = e.getBoundingClientRect();
                e.__lasso.lassoPoint = [Math.round(box.left + box.width/2),Math.round(box.top + box.height/2)];
            });

            // if hover is on, add hover function
            if(hoverSelect) {
                items.on("mouseover.lasso",function() {
                    // if hovered, change lasso selection attribute to true
                    this.__lasso.hoverSelect = true;
                });
            }

            // Run user defined start function
            on.start();
        }

        function dragmove() {
            // Get mouse position within body, used for calculations
            var x,y;
            if(d3.event.sourceEvent.type === "touchmove") {
                x = d3.event.sourceEvent.touches[0].clientX;
                y = d3.event.sourceEvent.touches[0].clientY;
            }
            else {
                x = d3.event.sourceEvent.clientX;
                y = d3.event.sourceEvent.clientY;
            }
            

            // Get mouse position within drawing area, used for rendering
            var tx = d3.mouse(this)[0];
            var ty = d3.mouse(this)[1];

            // Initialize the path or add the latest point to it
            if (tpath==="") {
                tpath = tpath + "M " + tx + " " + ty;
                origin = [x,y];
                torigin = [tx,ty];
                // Draw origin node
                origin_node
                    .attr("cx",tx)
                    .attr("cy",ty)
                    .attr("r",7)
                    .attr("display",null);
            }
            else {
                tpath = tpath + " L " + tx + " " + ty;
            }

            drawnCoords.push([x,y]);

            // Calculate the current distance from the lasso origin
            var distance = Math.sqrt(Math.pow(x-origin[0],2)+Math.pow(y-origin[1],2));

            // Set the closed path line
            var close_draw_path = "M " + tx + " " + ty + " L " + torigin[0] + " " + torigin[1];

            // Draw the lines
            dyn_path.attr("d",tpath);

            close_path.attr("d",close_draw_path);

            // Check if the path is closed
            isPathClosed = distance<=closePathDistance ? true : false;

            // If within the closed path distance parameter, show the closed path. otherwise, hide it
            if(isPathClosed && closePathSelect) {
                close_path.attr("display",null);
            }
            else {
                close_path.attr("display","none");
            }

            items.nodes().forEach(function(n) {
                n.__lasso.loopSelect = (isPathClosed && closePathSelect) ? (classifyPoint(drawnCoords,n.__lasso.lassoPoint) < 1) : false; 
                n.__lasso.possible = n.__lasso.hoverSelect || n.__lasso.loopSelect; 
            });

            on.draw();
        }

        function dragend() {
            // Remove mouseover tagging function
            items.on("mouseover.lasso",null);

            items.nodes().forEach(function(n) {
                n.__lasso.selected = n.__lasso.possible;
                n.__lasso.possible = false;
            });

            // Clear lasso
            dyn_path.attr("d",null);
            close_path.attr("d",null);
            origin_node.attr("display","none");

            // Run user defined end function
            on.end();
        }
    }

    // Set or get list of items for lasso to select
    lasso.items  = function(_) {
        if (!arguments.length) return items;
        items = _;
        var nodes = items.nodes();
        nodes.forEach(function(n) {
            n.__lasso = {
                "possible": false,
                "selected": false
            };
        });
        return lasso;
    };

    // Return possible items
    lasso.possibleItems = function() {
        return items.filter(function() {
            return this.__lasso.possible;
        });
    }

    // Return selected items
    lasso.selectedItems = function() {
        return items.filter(function() {
            return this.__lasso.selected;
        });
    }

    // Return not possible items
    lasso.notPossibleItems = function() {
        return items.filter(function() {
            return !this.__lasso.possible;
        });
    }

    // Return not selected items
    lasso.notSelectedItems = function() {
        return items.filter(function() {
            return !this.__lasso.selected;
        });
    }

    // Distance required before path auto closes loop
    lasso.closePathDistance  = function(_) {
        if (!arguments.length) return closePathDistance;
        closePathDistance = _;
        return lasso;
    };

    // Option to loop select or not
    lasso.closePathSelect = function(_) {
        if (!arguments.length) return closePathSelect;
        closePathSelect = _===true ? true : false;
        return lasso;
    };

    // Not sure what this is for
    lasso.isPathClosed = function(_) {
        if (!arguments.length) return isPathClosed;
        isPathClosed = _===true ? true : false;
        return lasso;
    };

    // Option to select on hover or not
    lasso.hoverSelect = function(_) {
        if (!arguments.length) return hoverSelect;
        hoverSelect = _===true ? true : false;
        return lasso;
    };

    // Events
    lasso.on = function(type,_) {
        if(!arguments.length) return on;
        if(arguments.length===1) return on[type];
        var types = ["start","draw","end"];
        if(types.indexOf(type)>-1) {
            on[type] = _;
        }
        return lasso;
    };

    // Area where lasso can be triggered from
    lasso.targetArea = function(_) {
        if(!arguments.length) return targetArea;
        targetArea = _;
        return lasso;
    }


    
    return lasso;
};
