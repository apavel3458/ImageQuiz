(function ($) {
'use strict';

  function loadedImage(img, settings) {
    /**
     * The main div overlaying the ECG image.
     */
    var $overlayDiv;

    var backgroundCanvas;
    var $backgroundCanvas;

    var loupe_magnification = settings.magnification;

    var fullSizeImage = new Image();
    fullSizeImage.src = img.src;


// amass-help.js

// We show different help levels. After each stage the user successfully
// performs, the next level is shown. Once the user managed all of them,
// we're fading into silency.
var HelpLevelEnum = {
    DONE_FILE_LOADING:  0,
    DONE_START_LINE:    1,
    DONE_FINISH_LINE:   2,
    DONE_ADD_ANGLE:     3,
    DONE_SET_LEN:       4,
};

// Constructor function.
function HelpSystem(helptext_span) {
    this.last_help_level_ = -1;

    // Initial text.
    printHelp("(Only your browser reads the image. It is not uploaded anywhere.)");

    this.achievementUnlocked = function(level) {
	if (level < this.last_help_level_)
	    return;
	this.last_help_level_ = level;
	printLevel(level);
    }

    function printLevel(requested_level) {
	switch (requested_level) {
	case HelpLevelEnum.DONE_FILE_LOADING:
	    printHelp("Click somewhere to start a line. (ensure legend is correct, if not click 'calibrate')");
	    break;
	case HelpLevelEnum.DONE_START_LINE:
	    printHelp("A second click finishes the line. Or Cancel with 'Esc'.");
	    break;
	case HelpLevelEnum.DONE_FINISH_LINE:
	    printHelp("TIP: starting a line where another ends measures their angles.");
	    break;
	case HelpLevelEnum.DONE_ADD_ANGLE:
	    printHelp("Double click on center of line to set relative size.");
	    break;
	case HelpLevelEnum.DONE_SET_LEN:
	    printHelp("Congratulations - you are an expert now!", true);
	    break;
	}
    }

    function printHelp(help_text, fade_away) {
	if (help_text == undefined) return;
	while (helptext_span.firstChild) {
	    helptext_span.removeChild(helptext_span.firstChild);
	}
	helptext_span.appendChild(document.createTextNode(help_text));

	if (fade_away != undefined && fade_away) {
	    helptext_span.style.transition = "opacity 10s";
	    helptext_span.style.opacity = 0;
	}
    }

    this.gridSizeHelp = function () {
	printHelp('Click to draw a box around the large box in the grid (200ms by 1mm)');
    };

    this.hideHelp = function () {
	printHelp('');
    }
}


// amass-elements.js

// Some useful function to have :)
function euklid_distance(x1, y1, x2, y2) {
    return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}

function Point(x, y) {
    this.update = function(x, y) {
	this.x = x;
	this.y = y;
    }

    // key to be used in hash tables.
    this.get_key = function() {
	return this.x + ":" + this.y;
    }

    this.update(x, y);
}

/**
Lines always have coordinates which end in ".5" - this is because mouse
coordinates are always between canvas coordinates.  For example, if the user
clicks on a point on the canvas with mouse coordinates (100, 100), this means
the click was actually somewhere between (100, 100) and (101, 101) on the
canvas.  So use (100.5, 100.5) as the best estimate.
*/
function Line(x1, y1, x2, y2) {
    // The canvas coordinate system numbers the space _between_ pixels
    // as full coordinage. Correct for that.
    this.p1 = new Point(x1 + 0.5, y1 + 0.5);
    this.p2 = new Point(x2 + 0.5, y2 + 0.5);

    // While editing: updating second end of the line.
    this.updatePos = function(x2, y2) {
	this.p2.update(x2 + 0.5, y2 + 0.5);
    }

    // Helper for determining selection: how far is the given position from the
    // center text.
    this.distanceToCenter = function(x, y) {
	var centerX = (this.p1.x + this.p2.x)/2;
	var centerY = (this.p1.y + this.p2.y)/2;
	return euklid_distance(centerX, centerY, x, y);
    }

    this.length = function() {
	return euklid_distance(this.p1.x, this.p1.y, this.p2.x, this.p2.y);
    }
}

// Represents the (CCW) angle of the line between "center_p" center point and
// point "remote_p" with respect to the horizontal line.
function Angle(center_p, remote_p, line) {
    this.center = center_p;
    this.p = remote_p;
    this.line = line;
    this.angle = undefined;
    this.is_valid = false;

    this.arm_length = function() {
	return euklid_distance(this.center.x, this.center.y,
			       this.p.x, this.p.y);
    }

    // Whenever points change, this needs to be called to re-calculate the
    // angle.
    this.notifyPointsChanged = function() {
	var len = euklid_distance(this.center.x, this.center.y,
				  this.p.x, this.p.y);
	if (len == 0.0) {
	    this.is_valid = false;
	    return;
	}
	var dx = this.p.x - this.center.x;
	var angle = Math.acos(dx/len);
	if (this.p.y > this.center.y) {
	    angle = 2 * Math.PI - angle;
	}
	this.angle = angle;
	this.is_valid = true;
    }

    this.notifyPointsChanged();
}

// Represents an arc with the given start and end-angle. Does not react
// on updates in the angle object.
function Arc(angle1, angle2) {
    this.center = angle1.center;
    this.start = angle1.angle;
    this.end = angle2.angle;
    if (this.end < this.start) {
	this.end += 2 * Math.PI;
    }

    // Hint for the drawing.
    // We want the drawn arc use at maximum half the lenght of the arm. That
    // way, two adjacent arcs on each endpoint of the arm are rendered
    // without overlap.
    this.max_radius = Math.min(angle1.arm_length(), angle2.arm_length()) / 2;

    // Printable value in the range [0..360)
    this.angleInDegrees = function() {
	var a = 180.0 * (this.end - this.start) / Math.PI;
	if (a < 0) a += 360;
	return a;
    }
}


// amass-model.js

// Conctructor function.
function AmassModel() {
    "use strict";
    this.lines_ = new Array();
    this.point_angle_map_ = {};  // points to lines originating from it.
    this.current_line_ = undefined;
    this.current_angle_ = undefined;
    this.hovered_line_index_ = undefined;

    /**
     * Canvas coordinates.
     */
    this.drag_start_point_ = undefined;

    /**
     * Image coordinates.
     */
    this.drag_line_x1_ = undefined;

    /**
     * Image coordinates.
     */
    this.drag_line_y1_ = undefined;

    /**
     * Image coordinates.
     */
    this.drag_line_x2_ = undefined;

    /**
     * Image coordinates.
     */
    this.drag_line_y2_ = undefined;

    this.really_dragging_ = false;

    // -- editing operation. We start a line and eventually commit or forget it.

    // Start a new line but does not add it to the model yet.
    this.startEditLine = function(x, y) {
	var imageX = Math.round(aug_view.canvasWidthToImageWidth(x));
	var imageY = Math.round(aug_view.canvasHeightToImageHeight(y));
	var line = new Line(imageX, imageY, imageX, imageY);
	this.current_line_ = line;
	this.current_angle_ = this.addAngle(line.p1, line.p2, line);
	if (this.hovered_line_index_ !== undefined) {
	    this.really_dragging_ = null;
	    this.drag_start_point_ = new Point(x, y);
	    var line = this.lines_[this.hovered_line_index_];
	    this.drag_line_x1_ = line.p1.x;
	    this.drag_line_y1_ = line.p1.y;
	    this.drag_line_x2_ = line.p2.x;
	    this.drag_line_y2_ = line.p2.y;
	}
    }
    this.hasEditLine = function() { return this.current_line_ != undefined; }
    this.getEditLine = function() { return this.current_line_; }

    /**
     * @param {number} x horizontal canvas position
     * @param {number} y vertical canvas position
     */
    this.updateEditLine = function(x, y) {
	if (this.drag_start_point_ !== undefined) {
	    // check whether the mouse has moved
	    var delta_x = x - this.drag_start_point_.x;
	    var delta_y = y - this.drag_start_point_.y;
	    if (-1 < delta_x && delta_x < 1 && -1 < delta_y && delta_y < 1) {
		// mouse has not moved
	    }
	    else {
		// mouse has moved - this is a drag
		this.forgetEditLine();

		this.really_dragging_ = true;

		// remove the angles for this line
		var line = this.lines_[this.hovered_line_index_];
		this.removeAngle(line.p1, line);
		this.removeAngle(line.p2, line);

		this.updateDrag(x, y);
	    }
	}
	if (this.current_line_ == undefined) return undefined;
	var imageX = Math.round(aug_view.canvasWidthToImageWidth(x));
	var imageY = Math.round(aug_view.canvasHeightToImageHeight(y));
	this.current_line_.updatePos(imageX, imageY);
	this.current_angle_.notifyPointsChanged();
	return this.current_line_;
    }

    this.commitEditLine = function() {
	var line = this.current_line_;
	this.lines_[this.lines_.length] = line;
	this.addAngle(line.p2, line.p1, line);
	this.current_line_ = undefined;
    }
    this.forgetEditLine = function() {
	if (this.current_line_ == undefined)
	    return;
	this.removeAngle(this.current_line_.p1, this.current_line_);
	this.current_line_ = undefined;
    }

    /**
     * @param {number} x horizontal canvas position
     * @param {number} y vertical canvas position
     */
    this.updateDrag = function (x, y) {
	if (! this.isDragging()) {
	    return;
	}

	var delta_x = x - this.drag_start_point_.x;
	var delta_y = y - this.drag_start_point_.y;

	// update the position of the dragged line
	var line = this.lines_[this.hovered_line_index_];

	var image_delta_x = Math.round(aug_view.canvasWidthToImageWidth(delta_x));
	var image_delta_y = Math.round(aug_view.canvasHeightToImageHeight(delta_y));

	line.p1.x = this.drag_line_x1_ + image_delta_x;
	line.p1.y = this.drag_line_y1_ + image_delta_y;
	line.p2.x = this.drag_line_x2_ + image_delta_x;
	line.p2.y = this.drag_line_y2_ + image_delta_y;
    }

    this.endDrag = function () {
	if (this.drag_start_point_ === undefined) {
	    return;
	}

	if (this.really_dragging_) {
	    var line = this.lines_[this.hovered_line_index_];
	    this.addAngle(line.p1, line.p2, line);
	    this.addAngle(line.p2, line.p1, line);
	}

	// finish dragging
	this.drag_start_point_ = undefined;
	this.drag_line_x1_ = undefined;
	this.drag_line_y1_ = undefined;
	this.drag_line_x2_ = undefined;
	this.drag_line_y2_ = undefined;
	this.really_dragging_ = false;
    };

    this.isDragging = function() {
	return this.drag_start_point_ !== undefined;
    }

    this.getHoveredLineIndex = function () {
	return this.hovered_line_index_;
    };

    function dist2(p1, p2) {
	return (p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y);
    }

    /**
     * Calculates the distance between a point and a line segment squared
     * http://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
     */
    function distance_between_point_and_line_squared(p, line) {
	var v = line.p1;
	var w = line.p2;
	var l2 = dist2(v, w);
	if (l2 == 0) return dist2(p, v);
	var t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
	t = Math.max(0, Math.min(1, t));
	return dist2(p, { x: v.x + t * (w.x - v.x),
			  y: v.y + t * (w.y - v.y) });
	}

    /**
     * Updates the current highlighted line.
     * @param {number} x horizontal canvas position
     * @param {number} y vertical canvas position
     * @returns {boolean} true if a redraw is needed, false otherwise
     */
    this.updateHoveredLine = function (x, y) {
	var imageX = aug_view.canvasWidthToImageWidth(x + 0.5);
	var imageY = aug_view.canvasWidthToImageWidth(y + 0.5);
	var point = new Point(imageX, imageY);

	var hovered_line_index;

	var length = this.lines_.length;
	for (var i = 0; i < length; ++i) {
	    var line = this.lines_[i];
	    var distance_squared = distance_between_point_and_line_squared(point, line);
	    distance_squared = aug_view.imageWidthToCanvasWidth(distance_squared);
	    if (distance_squared <= 4) {
		hovered_line_index = i;
	    }

	    // check whether hovering over the label
	    if (line.textBoundingBox) {
		var textBoundingBox = line.textBoundingBox;
		var canvasX = x + 0.5;
		var canvasY = y + 0.5;
		if (textBoundingBox.left < canvasX && canvasX <= textBoundingBox.right && textBoundingBox.top <= canvasY && canvasY <= textBoundingBox.bottom) {
		    hovered_line_index = i;
		}
	    }
	}

	if (this.hovered_line_index_ !== hovered_line_index) {
	    this.hovered_line_index_ = hovered_line_index;
	    return true;
	}
	else {
	    return false;
	}
    };

    this.addAngle = function(center, p2, line) {
	var key = center.get_key();
	var angle_list = this.point_angle_map_[key];
	if (angle_list === undefined) {
	    angle_list = new Array();
	    this.point_angle_map_[key] = angle_list;
	}
	var angle = new Angle(center, p2, line);
	angle_list[angle_list.length] = angle;
	return angle;
    }

    this.removeAngle = function(center_point, line) {
	var key = center_point.get_key();
	var angle_list = this.point_angle_map_[key];
	if (angle_list === undefined) return; // shrug.
	var pos = -1;
	for (var i = 0; i < angle_list.length; ++i) {
	    if (angle_list[i].line == line) {
		pos = i;
		break;
	    }
	}
	if (pos >= 0) {
	    angle_list.splice(pos, 1);
	}
    }

    // Remove a line
    this.removeLine = function(line) {
	var pos = this.lines_.indexOf(line);
	if (pos < 0) alert("Should not happen: Removed non-existent line");
	this.lines_.splice(pos, 1);
    }

    this.removeAllLines = function () {
	this.lines_ = new Array();
	this.point_angle_map_ = {};
	this.current_line_ = undefined;
	this.current_angle_ = undefined;
	this.hovered_line_index_ = undefined;
	this.drag_start_point_ = undefined;
	this.drag_line_x1_ = undefined;
	this.drag_line_y1_ = undefined;
	this.drag_line_x2_ = undefined;
	this.drag_line_y2_ = undefined;
	this.really_dragging_ = false;
    };

    // Find the closest line to the given coordinate or 'undefined', if they
    // are all too remote.
    this.findClosest = function(x, y) {
	var smallest_distance = undefined;
	var selected_line = undefined;
	this.forAllLines(function(line) {
	    var this_distance = line.distanceToCenter(x, y);
	    if (smallest_distance == undefined
		|| this_distance < smallest_distance) {
		smallest_distance = this_distance;
		selected_line = line;
	    }
	})
	if (selected_line && smallest_distance < 50) {
	    return selected_line;
	}
	return undefined;
    }

    // Iterate over all lines; Callback needs to accept a line.
    this.forAllLines = function(cb) {
	for (var i = 0; i < this.lines_.length; ++i) {
	    cb(this.lines_[i], i);
	}
    }

    this.forAllArcs = function(cb) {
	for (var key in this.point_angle_map_) {
	    if (!this.point_angle_map_.hasOwnProperty(key))
		continue;
	    var angle_list = this.point_angle_map_[key];
	    if (angle_list.length < 2)
		continue;
	    angle_list.sort(function(a, b) {
		return a.angle - b.angle;
	    });
	    for (var i = 0; i < angle_list.length; ++i) {
		var a = angle_list[i], b = angle_list[(i+1) % angle_list.length];
		if (!a.is_valid || !b.is_valid)
		    continue;
		var arc = new Arc(a, b);
		if (arc.angleInDegrees() >= 180.0)
		    continue;
		cb(arc)
	    }
	}
    }
}


// amass-view.js

// Constructor function.
function AmassView(canvas, naturalWidth, naturalHeight) {
    "use strict";
    this.measure_canvas_ = canvas;
    this.measure_ctx_ = this.measure_canvas_.getContext('2d');
    this.model_ = undefined;
    this.controller_ = undefined;
    this.print_factor_ = 1.0;  // Semantically, this one should probably be in the model.
    this.show_deltas_ = false;
    this.show_angles_ = true;
    this.mode_ = 'default';

    /**
     * Canvas coordinates.
     */
    var grid_start_x;

    /**
     * Canvas coordinates.
     */
    var grid_start_y;

    /**
     * Canvas coordinates.
     */
    var grid_end_x;

    /**
     * Canvas coordinates.
     */
    var grid_end_y;

    /*
    These values are with respect to the full-sized image (naturalWidth and
    naturalHeight).
    Default: 25px = 200ms; 25px = 0.5mV
    */
    /*
    var msPerPixel = 8.0;
    var mVPerPixel = 0.02;
    */
    var msPerPixel = null;
    var mVPerPixel = null;

    function imageWidthToCanvasWidth(value) {
	return value * canvas.width / naturalWidth;
    }

    function imageHeightToCanvasHeight(value) {
	return value * canvas.height / naturalHeight;
    }

    this.imageWidthToCanvasWidth = function (value) {
	return imageWidthToCanvasWidth(value);
    };

    this.imageHeightToCanvasHeight = function (value) {
	return imageHeightToCanvasHeight(value);
    };

    this.canvasWidthToImageWidth = function(value) {
	return value * naturalWidth / canvas.width;
    };

    this.canvasHeightToImageHeight = function(value) {
	return value * naturalHeight / canvas.height;
    };

    this.updateModeIndicators = function () {
	if (this.mode_ === 'grid_size') {
	    $overlayDiv.find('.measure').css('cursor', 'crosshair');
	    $overlayDiv.find('.specify-grid-size-manually').addClass('active');
	    $overlayDiv.find('.loupe').show();
	    help_system.gridSizeHelp();
	}
	else {
	    $overlayDiv.find('.specify-grid-size-manually').removeClass('active');
	    help_system.hideHelp();
	}

	if (this.mode_ === 'measuring') {
	    var dataUrl = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAD8AAAA/CAYAAABXXxDfAAAAsklEQVRoge3USQ6DMBQE0cp0LV+OgzsbllkZ5JbSVZLFCvMfE2Qb4etHE9+a+NbEtya+NfGtiW+tGm9tjTnnAXAeq15/8SBefHierYkH8eLD82xNPIgXH55nubGyfuBXVrY557GyztNfN+xxqdRdfwBv4HnDXhnDxaf2uWGPaL3f/GJ/87dfSTyIFx+eZ2viQbz48DxbEw/ixYfnMdtY9esuvjXxrYlvTXxr4lsT31oU/wX/Qa/XTVwxtAAAAABJRU5ErkJggg==';
	    $overlayDiv.find('.measure').css('cursor', 'url(' + dataUrl + ') 31 31, crosshair');
	    $overlayDiv.find('.loupe').show();
	    help_system.achievementUnlocked(HelpLevelEnum.DONE_FILE_LOADING);
	}
	else {
	}

	if (this.mode_ === 'default') {
	    $overlayDiv.find('.measure').css('cursor', 'default');
	    $overlayDiv.find('.ecg-measure-button').removeClass('active');
	    $overlayDiv.find('.ecg-controls-2').css('visibility', 'hidden');
	    help_system.hideHelp();
	}
	else {
	    $overlayDiv.find('.ecg-measure-button').addClass('active');
	    $overlayDiv.find('.ecg-controls-2').css('visibility', 'visible');
	}

	if ($overlayDiv.find('.ecg-zoom-button').hasClass('active') || this.mode_ !== 'default') {
	    $overlayDiv.find('.loupe').show();
	}
	else {
	    $overlayDiv.find('.loupe').hide();
	}
    };

    this.gridSizeMode = function () {
	this.mode_ = 'grid_size';
	if (this.model_) {
	    this.model_.forgetEditLine();
	}
	this.updateModeIndicators();
    };

    this.defaultMode = function () {
	this.mode_ = 'default';
	grid_start_x = undefined;
	grid_start_y = undefined;
	grid_end_x = undefined;
	grid_end_y = undefined;
	if (this.model_) {
	    this.model_.forgetEditLine();
	}
	this.updateModeIndicators();
    }

    this.measuringMode = function () {
	this.mode_ = 'measuring';
	grid_start_x = undefined;
	grid_start_y = undefined;
	grid_end_x = undefined;
	grid_end_y = undefined;
	this.updateModeIndicators();
    };

    this.getMode = function () {
	return this.mode_;
    };

    this.gridSizeStarted = function () {
	return grid_start_x !== undefined && grid_start_y !== undefined;
    }

    this.startGridSize = function (x, y) {
	grid_start_x = x;
	grid_start_y = y;
    };

    this.endGridSize = function (x, y) {
	grid_end_x = x;
	grid_end_y = y;
    };

    this.setGrid = function () {
	if (grid_start_x === grid_end_x) {
	    alert('Horizontal size must be greater than zero');
	    return;
	}
	if (grid_start_y === grid_end_y) {
	    alert('Vertical size must be greater than zero');
	    return;
	}

	msPerPixel = 200.0 / this.canvasWidthToImageWidth(Math.abs(grid_start_x - grid_end_x));
	mVPerPixel = 0.5 / this.canvasHeightToImageHeight(Math.abs(grid_start_y - grid_end_y));

	this.measuringMode();
    };

    this.setHorizontalGrid = function (value) {
	msPerPixel = 200.0 / Math.abs(value);
    };

    this.setVerticalGrid = function (value) {
	mVPerPixel = 0.5 / Math.abs(value);
    };

    // Create a fresh measure canvas of the given size.
    this.initModelAndController = function() {
	this.measure_ctx_.font = 'bold ' + length_font_pixels + 'px Sans Serif';

	// A fresh model.
	this.model_ = new AmassModel();
	if (this.controller_ == undefined) {
	    this.controller_ = new AmassController(canvas, this);
	}
    }

    this.getUnitsPerPixel = function() { return this.print_factor_; }
    this.setUnitsPerPixel = function(factor) { this.print_factor_ = factor; }
    this.setShowDeltas = function(b) { this.show_deltas_ = b; }
    this.setShowAngles = function(b) { this.show_angles_ = b; }

    this.getModel = function() { return this.model_; }
    this.getCanvas = function() { return this.measure_canvas_; }

    // Draw all the lines!
    this.drawAll = function() {
	this.measure_ctx_.clearRect(0, 0, this.measure_canvas_.width,
				    this.measure_canvas_.height);
	this.drawAllNoClear(this.measure_ctx_);
    }

    this.highlightLine = function(line) {
	drawMeasureLine(this.measure_ctx_, line, this.show_deltas_,
			true);
    }

    this.drawAllNoClear = function(ctx) {
	this.measure_ctx_.font = 'bold ' + length_font_pixels + 'px Sans Serif';
	var show_deltas = this.show_deltas_;
	var hovered_line_index = this.model_.getHoveredLineIndex();
	this.model_.forAllLines(function(line, index) {
	    var highlight = false;
	    if (index === hovered_line_index) {
		highlight = true;
	    }
	    drawMeasureLine(ctx, line, show_deltas, highlight);
	});
	if (this.model_.hasEditLine()) {
	    var line = this.model_.getEditLine();
	    drawEditline(ctx, line);
	    if (this.show_deltas_) {
		drawDeltaLine(ctx, line);
	    }
	}
	if (this.show_angles_) {
	    this.measure_ctx_.font = angle_font_pixels + "px Sans Serif";
	    // Radius_fudge makes the radius of the arc slighly different
	    // for all angles around one center so that they are easier
	    // to distinguish.
	    var radius_fudge = 0;
	    var current_point = undefined;
	    this.model_.forAllArcs(function(arc) {
		if (current_point == undefined
		    || current_point.x != arc.center.x
		    || current_point.y != arc.center.y) {
		    current_point = arc.center;
		    radius_fudge = 0;
		}
		drawArc(ctx, arc, (radius_fudge++ % 3) * 3);
	    });
	}

	if (this.mode_ === 'grid_size' && grid_start_x !== undefined && grid_start_y !== undefined && grid_end_x !== undefined && grid_end_y !== undefined) {
	    if (grid_start_x !== grid_end_x && grid_start_y !== grid_end_y) {
		ctx.beginPath();
		ctx.strokeStyle = '#f00';
		ctx.lineWidth = 1;
		ctx.lineCap = 'butt';
		ctx.moveTo(grid_start_x + 0.5, grid_start_y + 0.5);
		ctx.lineTo(grid_end_x + 0.5, grid_start_y + 0.5);
		ctx.lineTo(grid_end_x + 0.5, grid_end_y + 0.5);
		ctx.lineTo(grid_start_x + 0.5, grid_end_y + 0.5);
		ctx.closePath();
		ctx.stroke();
		var textOffset = 12;
		writeLabel(ctx, '200 ms', (grid_start_x + grid_end_x) / 2, Math.max(grid_start_y, grid_end_y) + textOffset, 'center');
		writeLabel(ctx, '0.5 mV', Math.max(grid_start_x, grid_end_x) + textOffset, (grid_start_y + grid_end_y) / 2, 'left');
	    }
	}

	// draw the scale in the top left corner
	drawScale(ctx);
    }

    function drawScale(ctx) {
	var offset = 20.5;
	var textOffset = 12;

	if (msPerPixel === null || mVPerPixel === null) {
	    writeLabel(ctx, 'Need calibration', offset, offset, 'left');
	    return;
	}

	var scale_x = 200.0 / msPerPixel;
	var scale_y = 0.5 / mVPerPixel;

	scale_x = imageWidthToCanvasWidth(scale_x);
	scale_y = imageHeightToCanvasHeight(scale_y);

	// draw background
	ctx.fillStyle = background_line_style;
	ctx.beginPath();
	ctx.moveTo(offset - 2, offset - 2);
	ctx.lineTo(offset + scale_x + 2, offset - 2);
	ctx.lineTo(offset + scale_x + 2, offset + scale_y + 2);
	ctx.lineTo(offset - 2, offset + scale_y + 2);
	ctx.fill();

	// draw scale
	ctx.strokeStyle = '#f00';
	ctx.lineWidth = 1;
	ctx.lineCap = 'butt';
	ctx.beginPath();
	ctx.moveTo(scale_x + offset, offset);
	ctx.lineTo(scale_x + offset, scale_y + offset);
	ctx.stroke();
	ctx.beginPath();
	ctx.moveTo(scale_x + offset, scale_y + offset);
	ctx.lineTo(offset, scale_y + offset);
	ctx.stroke();

	// draw text
	writeLabel(ctx, '200 ms', scale_x / 2 + offset, scale_y + offset + textOffset, 'center');
	writeLabel(ctx, '0.5 mV', scale_x + offset + textOffset, scale_y / 2 + offset, 'left');
    }

    // Write rotated text, aligned to the outside.
    function writeRotatedText(ctx, txt, x, y, radius, angle) {
	ctx.save();
	ctx.beginPath();
	ctx.translate(x, y);
	ctx.strokeStyle = background_line_style;
	ctx.lineWidth = angle_font_pixels;
	ctx.lineCap = 'butt';   // should end flush with the arc.
	ctx.moveTo(0, 0);
	if (angle <= Math.PI/2 || angle > 3 * Math.PI/2) {
	    ctx.rotate(-angle);   // JavaScript, Y U NO turn angles left.
	    ctx.textAlign = 'right';
	    ctx.textBaseline = 'middle';
	    ctx.lineTo(radius, 0);
	    ctx.stroke();
	    ctx.fillText(txt, radius, 0);
	} else {
	    // Humans don't like to read text upside down
	    ctx.rotate(-(angle + Math.PI));
	    ctx.textAlign = 'left';
	    ctx.textBaseline = 'middle';
	    ctx.lineTo(-radius, 0);
	    ctx.stroke();
	    ctx.fillText(txt, -radius, 0);
	}
	ctx.restore();
    }

    function drawArc(ctx, arc, radius_fiddle) {
	var arcCenterX = imageWidthToCanvasWidth(arc.center.x);
	var arcCenterY = imageHeightToCanvasHeight(arc.center.y);
	var arcMaxRadius = imageWidthToCanvasWidth(arc.max_radius);

	var text_len = ctx.measureText("333.3\u00B0").width;
	var radius = text_len + 2 * end_bracket_len + radius_fiddle;
	ctx.beginPath();
	ctx.lineWidth = background_line_width;
	ctx.strokeStyle = background_line_style;
	// Javascript turns angles right not left. Ugh.
	ctx.arc(arcCenterX, arcCenterY, Math.min(radius, arcMaxRadius),
		2 * Math.PI - arc.end, 2 * Math.PI - arc.start);
	ctx.stroke();

	ctx.beginPath();
	ctx.lineWidth = 1;
	ctx.strokeStyle = "#000";
	ctx.arc(arcCenterX, arcCenterY, Math.min(radius, arcMaxRadius),
		2 * Math.PI - arc.end, 2 * Math.PI - arc.start);
	ctx.stroke();

	var middle_angle = (arc.end - arc.start)/2 + arc.start;
	writeRotatedText(ctx, arc.angleInDegrees().toFixed(1) + "\u00B0",
			 arcCenterX, arcCenterY,
			 radius - 2, middle_angle);
    }


    // Draw a perpendicular (to the line) end-piece ("T") at position x, y.
    function drawT(ctx, x, y, remote_x, remote_y, t_len, optional_gap) {
	x = imageWidthToCanvasWidth(x);
	y = imageHeightToCanvasHeight(y);
	remote_x = imageWidthToCanvasWidth(remote_x);
	remote_y = imageHeightToCanvasHeight(remote_y);

	var len = euklid_distance(x, y, remote_x, remote_y);
	if (len < 1) return;
	var dx = remote_x - x;
	var dy = remote_y - y;
	if (optional_gap === undefined) {
	    ctx.moveTo(x - t_len * dy/len, y + t_len * dx/len);
	    ctx.lineTo(x + t_len * dy/len, y - t_len * dx/len);
	} else {
	    ctx.moveTo(x - t_len * dy/len, y + t_len * dx/len);
	    ctx.lineTo(x - optional_gap * dy/len, y + optional_gap * dx/len);
	    ctx.moveTo(x + t_len * dy/len, y - t_len * dx/len);
	    ctx.lineTo(x + optional_gap * dy/len, y - optional_gap * dx/len);
	}
    }

    function getLineText(line) {
	if (msPerPixel === null || mVPerPixel === null) {
	    return '? mV / ? mS';
	}
	else {
	    return ((line.p1.y - line.p2.y) * mVPerPixel).toPrecision(4) + ' mV / ' + ((line.p2.x - line.p1.x) * msPerPixel).toPrecision(4) + ' ms';
	}
    }

    // Drawing the line while editing.
    // We only show the t-anchor on the start-side. Also the line is
    // 1-2 pixels shorter where the mouse-cursor is, so that we don't cover
    // anything in the target crosshair.
    function drawEditline(ctx, line) {
	var pixel_len = line.length();

	// We want to draw the line a little bit shorter, so that the
	// open crosshair cursor has 'free sight'
	var dx = line.p2.x - line.p1.x;
	var dy = line.p2.y - line.p1.y;
	if (pixel_len > 2) {
	    dx = dx * (pixel_len - 2)/pixel_len;
	    dy = dy * (pixel_len - 2)/pixel_len;
	}

	// Background for t-line
	ctx.beginPath();
	ctx.strokeStyle = background_line_style;
	ctx.lineWidth = background_line_width;
	ctx.lineCap = 'round';
	drawT(ctx, line.p1.x, line.p1.y, line.p2.x, line.p2.y,
	     end_bracket_len);
	ctx.stroke();

	// White background for actual line
	ctx.beginPath();
	ctx.lineCap = 'butt';  // Flat to not bleed into crosshair.
	ctx.moveTo(imageWidthToCanvasWidth(line.p1.x), imageHeightToCanvasHeight(line.p1.y));
	ctx.lineTo(imageWidthToCanvasWidth(line.p1.x + dx), imageHeightToCanvasHeight(line.p1.y + dy));
	ctx.stroke();

	// t-line ...
	ctx.beginPath();
	ctx.strokeStyle = '#000';
	ctx.lineWidth = 0.5;
	ctx.lineCap = 'butt';
	drawT(ctx, line.p1.x, line.p1.y, line.p2.x, line.p2.y, 50);
	// Leave a little gap at the line where the cursor is to leave
	// free view to the surroundings.
	drawT(ctx, line.p2.x, line.p2.y, line.p1.x, line.p1.y, 50, 10);
	ctx.stroke();

	// ... and actual line.
	ctx.beginPath();
	ctx.strokeStyle = '#00F';
	ctx.lineWidth = 2;
	ctx.moveTo(imageWidthToCanvasWidth(line.p1.x), imageHeightToCanvasHeight(line.p1.y));
	ctx.lineTo(imageWidthToCanvasWidth(line.p1.x + dx), imageHeightToCanvasHeight(line.p1.y + dy));
	ctx.stroke();

	if (pixel_len >= 2) {
	    var print_text = getLineText(line);
	    var text_len = ctx.measureText(print_text).width + 2 * length_font_pixels;
	    // Print label.
	    // White background for text. We're using a short line, so that we
	    // have a nicely rounded box with our line-cap.
	    var text_dx = -text_len/2;
	    var text_dy = -(length_font_pixels + 10)/2;
	    if (pixel_len > 0) {
		text_dx = -dx * text_len/(2 * pixel_len);
		text_dy = -dy * (length_font_pixels + 10)/(2 * pixel_len);
	    }
	    writeLabel(ctx, print_text, imageWidthToCanvasWidth(line.p1.x) + text_dx, imageHeightToCanvasHeight(line.p1.y) + text_dy,
		       "center");
	}
    }

    // General draw of a measuring line.
    function drawMeasureLine(ctx, line, show_deltas, highlight) {
	var print_text = getLineText(line);
	ctx.beginPath();
	// Some contrast background.
	if (highlight) {
	    ctx.strokeStyle = background_highlight_line_style;
	} else {
	    ctx.strokeStyle = background_line_style;
	}
	ctx.lineWidth = background_line_width;
	ctx.lineCap = 'round';
	ctx.moveTo(imageWidthToCanvasWidth(line.p1.x), imageHeightToCanvasHeight(line.p1.y));
	ctx.lineTo(imageWidthToCanvasWidth(line.p2.x), imageHeightToCanvasHeight(line.p2.y));
	drawT(ctx, line.p1.x, line.p1.y, line.p2.x, line.p2.y,
	     end_bracket_len);
	drawT(ctx, line.p2.x, line.p2.y, line.p1.x, line.p1.y,
	     end_bracket_len);
	ctx.stroke();

	ctx.beginPath();
	// actual line
	if (highlight) {
	    ctx.strokeStyle = highlight_line_style;
	} else {
	    ctx.strokeStyle = line_style;
	}
	ctx.lineWidth = 2;
	ctx.moveTo(imageWidthToCanvasWidth(line.p1.x), imageHeightToCanvasHeight(line.p1.y));
	ctx.lineTo(imageWidthToCanvasWidth(line.p2.x), imageHeightToCanvasHeight(line.p2.y));
	drawT(ctx, line.p1.x, line.p1.y, line.p2.x, line.p2.y,
	     end_bracket_len);
	drawT(ctx, line.p2.x, line.p2.y, line.p1.x, line.p1.y,
	     end_bracket_len);
	ctx.stroke();

	// .. and text.
	var a = new Angle(line.p1, line.p2, line);
	var slope_upwards = ((a.angle > 0 && a.angle < Math.PI/2)
			     || (a.angle > Math.PI && a.angle < 3 * Math.PI/2));
	var flat_angle = Math.PI/10;
	var flat_slope = ((a.angle > 0 && a.angle < flat_angle)
			  || (a.angle > Math.PI/2 && a.angle < (Math.PI/2 + flat_angle)));
	var boundingBox = {};
	writeLabel(ctx, print_text,
		   imageWidthToCanvasWidth(line.p1.x + line.p2.x)/2, imageHeightToCanvasHeight(line.p1.y + line.p2.y)/2 - 25,
		   flat_slope ? "center" : (slope_upwards ? "right" : "left"), highlight, boundingBox);
	line.textBoundingBox = boundingBox;
    }

    // Write a label with a contrasty background.
    function writeLabel(ctx, txt, x, y, alignment, highlight, boundingBox) {
	ctx.font = 'bold ' + length_font_pixels + 'px Sans Serif';
	ctx.textBaseline = 'middle';
	ctx.textAlign = alignment;

	ctx.beginPath();
	var dx = ctx.measureText(txt).width;
	var lineWidth = length_font_pixels + 5;  // TODO: find from style.
	ctx.lineWidth = lineWidth;
	ctx.lineCap = 'round';

	if (highlight) {
	    ctx.strokeStyle = background_highlight_line_style;
	} else {
	    ctx.strokeStyle = background_line_style;
	}
	var line_x = x;
	if (alignment == 'center') {
	    line_x -= dx/2;
	}
	else if (alignment == 'right') {
	    line_x -= dx;
	}
	ctx.moveTo(line_x, y);
	ctx.lineTo(line_x + dx, y);
	ctx.stroke();
	ctx.fillStyle = '#000';
	ctx.fillText(txt, x, y);

	if (boundingBox) {
	    // fill in the bounding box
	    boundingBox.left = line_x - (lineWidth / 2);
	    boundingBox.right = line_x + dx + (lineWidth / 2);
	    boundingBox.top = y - lineWidth / 2;
	    boundingBox.bottom = y + lineWidth / 2;
	}
    }

    function drawDeltaLine(ctx, line, highlight) {
	if (line.p1.x == line.p2.x || line.p1.y == line.p2.y)
	    return;

	var non_overlap_target = 30;
	var dy = line.p2.y - line.p1.y;
	var dx = line.p2.x - line.p1.x;
	ctx.beginPath();
	ctx.lineWidth = 1;
	ctx.strokeStyle = "#000";
	ctx.moveTo(imageWidthToCanvasWidth(line.p1.x), imageHeightToCanvasHeight(line.p1.y));
	ctx.lineTo(imageWidthToCanvasWidth(line.p2.x), imageHeightToCanvasHeight(line.p1.y));
	if (Math.abs(dy) > non_overlap_target) {
	    var line_y = imageHeightToCanvasHeight(line.p1.y + dy) - ((dy < 0) ? -non_overlap_target : non_overlap_target);
	    ctx.lineTo(imageWidthToCanvasWidth(line.p2.x), line_y);
	}
	ctx.stroke();

	var hor_len = msPerPixel * dx;
	var hor_align = "center";
	if (dx <= 0 && dx > -80) hor_align = "right";
	else if (dx >= 0 && dx < 80) hor_align = "left";
	writeLabel(ctx, hor_len.toPrecision(4) + ' ms', imageWidthToCanvasWidth(line.p1.x + line.p2.x)/2,
		   imageHeightToCanvasHeight(line.p1.y) + ((dy > 0) ? -20 : 20), hor_align);
	var vert_len = mVPerPixel * (- dy);
	writeLabel(ctx, vert_len.toPrecision(4) + ' mV',
		   imageWidthToCanvasWidth(line.p2.x) + (dx > 0 ? 10 : -10),
		   imageHeightToCanvasHeight(line.p1.y + line.p2.y)/2,
		   line.p1.x < line.p2.x ? "left" : "right");
    }
}


// amass-loupe.js

// TODO: make this an object. Needs to have access to the
// background image as well.
var loupe_canvas;
var loupe_ctx;
var loupe_fading_timer;

// Helper to show the 'corner hooks' in the loupe display.
function showQuadBracket(loupe_ctx, loupe_size, bracket_len) {
    loupe_ctx.moveTo(0, bracket_len);                 // top left.
    loupe_ctx.lineTo(bracket_len, bracket_len);
    loupe_ctx.lineTo(bracket_len, 0);
    loupe_ctx.moveTo(0, loupe_size - bracket_len);   // bottom left.
    loupe_ctx.lineTo(bracket_len, loupe_size - bracket_len);
    loupe_ctx.lineTo(bracket_len, loupe_size);
    loupe_ctx.moveTo(loupe_size - bracket_len, 0);     // top right.
    loupe_ctx.lineTo(loupe_size - bracket_len, bracket_len);
    loupe_ctx.lineTo(loupe_size, bracket_len);         // bottom right.
    loupe_ctx.moveTo(loupe_size - bracket_len, loupe_size);
    loupe_ctx.lineTo(loupe_size - bracket_len, loupe_size - bracket_len);
    loupe_ctx.lineTo(loupe_size, loupe_size - bracket_len);
}

function drawLoupeLine(ctx, line, off_x, off_y, factor) {
    function toCanvasX(value) {
	value = aug_view.imageWidthToCanvasWidth(value);
	value = Math.round(value - 0.5) + 0.5;
	return value;
    }

    function toCanvasY(value) {
	value = aug_view.imageHeightToCanvasHeight(value);
	value = Math.round(value - 0.5) + 0.5;
	return value;
    }

    // these 0.5 offsets seem to look inconclusive on Chrome and Firefox.
    // Need to go deeper.
    ctx.beginPath();
    var x1pos = (toCanvasX(line.p1.x) - off_x), y1pos = (toCanvasY(line.p1.y) - off_y);
    var x2pos = (toCanvasX(line.p2.x) - off_x), y2pos = (toCanvasY(line.p2.y) - off_y);
    ctx.moveTo(x1pos * factor, y1pos * factor);
    ctx.lineTo(x2pos * factor, y2pos * factor);
    ctx.stroke();
    // We want circles that circumreference the pixel in question.
    ctx.beginPath();
    ctx.arc(x1pos * factor + 0.5, y1pos * factor + 0.5,
	    1.5 * factor/2, 0, 2*Math.PI);
    ctx.stroke();
    ctx.beginPath();
    ctx.arc(x2pos * factor + 0.5, y2pos * factor + 0.5,
	    1.5 * factor/2, 0, 2*Math.PI);
    ctx.stroke();
}

/**
 * @param {number} x canvas x-coordinate
 * @param {number} y canvas y-coordinate
 */
function showLoupe(x, y) {
    if (backgroundImage === undefined || loupe_ctx === undefined)
	return;

/*
    // if we can fit the loupe right of the image, let's do it. Otherwise
    // it is in the top left corner, with some volatility to escape the cursor.
    var cursor_in_frame_x = x - scrollLeft();
    var cursor_in_frame_y = y - scrollTop() + aug_view.getCanvas().offsetTop;

    // Let's see if we have any overlap with the loupe - if so, move it
    // out of the way.
    var top_default = 10;
    var left_loupe_edge = document.body.clientWidth - loupe_canvas.width - 10;
    if (backgroundImage.width + 40 < left_loupe_edge)
	left_loupe_edge = backgroundImage.width + 40;
    loupe_canvas.style.left = left_loupe_edge + 'px';

    // Little hysteresis while moving in and out
    if (cursor_in_frame_x > left_loupe_edge - 20
	&& cursor_in_frame_y < loupe_canvas.height + top_default + 20) {
	loupe_canvas.style.top = (loupe_canvas.height + top_default + 60) + 'px';
    } else if (cursor_in_frame_x < left_loupe_edge - 40
	       || cursor_in_frame_y > loupe_canvas.height + top_default + 40) {
	loupe_canvas.style.top = top_default + 'px';
    }
*/

    var loupe_size = loupe_ctx.canvas.width;

    // set position of loupe
    var offsetPercentage = 5;
    var loupeOffset = 50;
    var canvasWidth = backgroundCanvas.width;
    var loupeLeft = x + loupeOffset;
    if (loupeLeft + loupe_size < canvasWidth) {
	loupe_canvas.style.left = loupeLeft + 'px';
	loupe_canvas.style.right = 'auto';
    }
    else {
	loupe_canvas.style.left = 'auto';
	loupe_canvas.style.right = (canvasWidth - x + loupeOffset) + 'px';
    }
    var canvasHeight = backgroundCanvas.height;
    var loupeTop = y + loupeOffset;
    if (loupeTop + loupe_size < canvasHeight) {
	loupe_canvas.style.top = loupeTop + 'px';
	loupe_canvas.style.bottom = 'auto';
    }
    else {
	loupe_canvas.style.top = 'auto';
	loupe_canvas.style.bottom = (canvasHeight - y + loupeOffset) + 'px';
    }

    var img_max_x = backgroundImage.width - 1;
    var img_max_y = backgroundImage.height - 1;
    // The size of square we want to enlarge.
    var crop_size = loupe_size/loupe_magnification;
    var start_x = x - crop_size/2;
    var start_y = y - crop_size/2;
    var off_x = 0, off_y = 0;
    if (start_x < 0) { off_x = -start_x; start_x = 0; }
    if (start_y < 0) { off_y = -start_y; start_y = 0; }
    var end_x = x + crop_size/2;
    var end_y = y + crop_size/2;
    end_x = end_x < img_max_x ? end_x : img_max_x;
    end_y = end_y < img_max_y ? end_y : img_max_y;
    var crop_w = (end_x - start_x) + 1;
    var crop_h = (end_y - start_y) + 1;
    loupe_ctx.fillStyle = "#777";
    loupe_ctx.fillRect(0, 0, loupe_size, loupe_size);

    /*
    The variables start_x, start_y, end_x, and end_y represent whole pixels
    within the resized image.
    */
    var start_edge_x = start_x;
    var start_edge_y = start_y;
    var end_edge_x  = end_x + 1;
    var end_edge_y = end_y + 1;

    /*
    Translate the edge locations to locations in the original image.
    */
    start_edge_x = start_edge_x * backgroundImage.naturalWidth / backgroundImage.width;
    start_edge_y = start_edge_y * backgroundImage.naturalHeight / backgroundImage.height;
    end_edge_x = end_edge_x * backgroundImage.naturalWidth / backgroundImage.width;
    end_edge_y = end_edge_y * backgroundImage.naturalHeight / backgroundImage.height;

    off_x -= 0.5;
    off_y -= 0.5;
    loupe_ctx.drawImage(fullSizeImage,
			start_edge_x, start_edge_y, end_edge_x - start_edge_x, end_edge_y - start_edge_y,
			off_x * loupe_magnification, off_y * loupe_magnification,
			loupe_magnification * crop_w,
			loupe_magnification * crop_h);

    loupe_ctx.beginPath();
    loupe_ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
    loupe_ctx.lineWidth = 1;
    // draw four brackets enclosing the pixel in question.
    var bracket_len = (loupe_size - loupe_magnification)/2;
    showQuadBracket(loupe_ctx, loupe_size, bracket_len);
    loupe_ctx.stroke();
    loupe_ctx.beginPath();
    loupe_ctx.strokeStyle = 'rgba(0, 0, 0, 0.3)';
    showQuadBracket(loupe_ctx, loupe_size, bracket_len - 1);
    loupe_ctx.stroke();

    loupe_ctx.beginPath();
    loupe_ctx.fillStyle = "#000";
    loupe_ctx.fillText("(" + x + "," + y + ")", 10, 30);
    loupe_ctx.stroke();

    // TODO: we want the loupe-context be scaled anyway, and have this a
    // translation.
    var l_off_x = x - crop_size/2 + 0.5
    var l_off_y = y - crop_size/2 + 0.5;
    // Draw all the lines in the loupe; better 'high resolution' view.
    for (var style = 0; style < 2; ++style) {
	switch (style) {
	case 0:
	    loupe_ctx.strokeStyle = background_line_style;
	    loupe_ctx.lineWidth = loupe_magnification;
	    break;
	case 1:
	    loupe_ctx.strokeStyle = line_style;
	    loupe_ctx.lineWidth = 2;
	    break;
	}
	var model = aug_view.getModel();
	model.forAllLines(function(line) {
	    drawLoupeLine(loupe_ctx, line, l_off_x, l_off_y,
			  loupe_magnification);
	});
	if (model.hasEditLine()) {
	    drawLoupeLine(loupe_ctx, model.getEditLine(), l_off_x, l_off_y,
			  loupe_magnification);
	}
    }
}

function showFadingLoupe(x, y) {
    if (loupe_fading_timer != undefined)
	clearTimeout(loupe_fading_timer);   // stop scheduled fade-out.
    loupe_canvas.style.transition = "top 0.3s, opacity 0s";
    loupe_canvas.style.opacity = 1;
    showLoupe(x, y);
    // Stay a couple of seconds, then fade away.
    loupe_fading_timer = setTimeout(function() {
	loupe_canvas.style.transition = "top 0.3s, opacity 5s";
	loupe_canvas.style.opacity = 0;
    }, 8000);
}


// amass-main.js

/*
 * potential TODO
 * - clean up. This is mostly experimental code right now figuring out how
 *   JavaScript works and stuff :) Put things with their own state in objects.
 * - Endpoints should have the T, but angle-centers just a little circle.
 *   (so: points that have > 1 lines attached to a point)
 * - circle radius estimation (separate mode)
 *    o three dots circle, 4 ellipsis,  but allow multiple dots
 *      and minimize error.
 *    o axis where the center would be plus two dots.
 * - modes: draw single line, polyline, mark circle, select (for delete)
 * - select: left click selects a line (endpoints and center). Highlight;
 *   del deletes.
 * - shift + mouse movement: only allow for discrete 360/16 angles.
 * - alt + mouse movement: snap to point in the vicinity.
 * - provide a 'reference straight line' defining the 0 degree angle.
 * - 'collision detection' for labels. Labels should in general be drawn
 *   separately and optimized for non-collision with other labels, lines and
 *   arcs. Make them align with lines, unless too steep angle (+/- 60 degrees?).
 * - checkbox 'show angles', 'show labels'
 * - export as SVG that includes the original image.
 *   background, labels, support-lines (arcs and t-lines) and lines
 *   should be in separate layers to individually look at them.
 *   (exporting just an image with the lines on top crashes browsers; play
 *   with toObjectUrl for download).
 */

// Some constants.

// How lines usually look like (blue with yellow background should make
// it sufficiently distinct in many images).
var line_style = "#00f";
var background_line_style = 'rgba(255, 255, 0, 0.4)';
var background_line_width = 7;

// On highlight.
var highlight_line_style = "#f00";
var background_highlight_line_style = 'rgba(0, 255, 255, 0.4)';

var length_font_pixels = 15;
var angle_font_pixels = 10;
var end_bracket_len = 5;

// These variables need to be cut down and partially be private
// to the modules.
var help_system;
var aug_view;
var backgroundImage;  // if loaded. Also used by the loupe.
var canvasImage;

// Init function. Call once on page-load.
function amass_init(naturalWidth, naturalHeight) {
    var $helptext = $overlayDiv.find('.helptext');
    help_system = new HelpSystem($helptext[0]);
    var $measure = $overlayDiv.find('.measure');
    aug_view = new AmassView($measure[0], naturalWidth, naturalHeight);

    aug_view.defaultMode();

    /*
    var $show_angle_checkbox = $overlayDiv.find('.show-angles');
    var show_angle_checkbox = $show_angle_checkbox[0];
    show_angle_checkbox.addEventListener("change", function(e) {
	aug_view.setShowAngles(show_angle_checkbox.checked);
	aug_view.drawAll();
    });
    */

    var $loupe_canvas = $overlayDiv.find('.loupe');
    loupe_canvas = $loupe_canvas[0];

    // set the size of the loupe canvas to be a multiple of the magnification
    var loupe_canvas_width = loupe_canvas.width;
    var pixelsMagnified = Math.round(loupe_canvas_width / loupe_magnification);
    var loupe_size = pixelsMagnified * loupe_magnification;
    loupe_canvas.width = loupe_size;
    loupe_canvas.height = loupe_size;

    loupe_canvas.style.left = (document.body.clientWidth - loupe_canvas.width - 10) + 'px';
    loupe_ctx = loupe_canvas.getContext('2d');
    // We want to see the pixels:
    // loupe_ctx.imageSmoothingEnabled = false;
    // loupe_ctx.webkitImageSmoothingEnabled = false;

    aug_view.initModelAndController();

    /*
    var $download_link = $overlayDiv.find('.download-result');
    var download_link = $download_link[0];
    download_link.addEventListener('click', function() {
	download_result(download_link) },  false);
    download_link.style.opacity = 0;  // not visible at first.
    download_link.style.cursor = "default";
    */
}

function AmassController(canvas, view) {
    // This doesn't have any public methods.
    this.start_line_time_ = 0;

    var self = this;
    canvas.addEventListener("mousedown", function(e) {
	extract_event_pos(e, function(e,x,y) { self.onClick(e,x,y); });
    });
    canvas.addEventListener("mouseup", function(e) {
	extract_event_pos(e, function(e,x,y) { self.onMouseUp(e,x,y); });
    });
    canvas.addEventListener("contextmenu", function(e) {
	e.preventDefault();
    });
    canvas.addEventListener("mousemove", function(e) {
	extract_event_pos(e, onMove);
    });
    document.addEventListener("keydown", onKeyEvent);

    function extract_event_pos(e, callback) {
	var offset = canvas.getBoundingClientRect();
	var x = e.clientX - offset.left;
	var y = e.clientY - offset.top;
	callback(e, x, y);
    }

    function getModel() { return view.getModel(); }
    function getView() { return view; }

    function cancelCurrentLine() {
	if (getModel().hasEditLine()) {
	    getModel().forgetEditLine();
	    getView().drawAll();
	}
    }

    function onKeyEvent(e) {
	if (e.keyCode == 27) {  // ESC key.
	    var mode = view.getMode();
	    switch (mode) {
	    case 'grid_size':
		view.measuringMode();
		view.drawAll();
		break;
	    default:
		cancelCurrentLine();
		break;
	    }
	}
    }

    function onMove(e, x, y) {
	if (backgroundImage === undefined)
	    return;

	var mode = view.getMode();
	if (mode == 'grid_size') {
	    if (view.gridSizeStarted()) {
		view.endGridSize(x, y)
	    }
	    showLoupe(x, y);
	    if (view.gridSizeStarted()) {
		view.drawAll();
	    }
	    return;
	}

	var has_editline = getModel().hasEditLine();
	var is_dragging = getModel().isDragging();
	var need_redraw = false;
	if (has_editline) {
	    getModel().updateEditLine(x, y);
	    need_redraw = true;
	}
	else if (is_dragging) {
	    getModel().updateDrag(x, y);
	    need_redraw = true;
	}
	else {
	    need_redraw = getModel().updateHoveredLine(x, y);
	}
	showLoupe(x, y);
	if (! need_redraw) {
	    return;
	}
	getView().drawAll();
    }

    this.onClick = function(e, x, y) {
	var mode = view.getMode();
	if (mode == 'grid_size') {
	    if (e.which == 3) {
		view.measuringMode();
		view.drawAll();
		return;
	    }

	    if (view.gridSizeStarted()) {
		view.endGridSize(x, y);
		view.setGrid();
	    }
	    else {
		view.startGridSize(x, y);
	    }
	    view.drawAll();

	    return;
	}
	if (mode === 'default') {
	    return;
	}

	if (e.which != undefined && e.which == 3) {
	    // right mouse button.
	    cancelCurrentLine();
	    return;
	}
	var now = new Date().getTime();
	if (!getModel().hasEditLine()) {
	    getModel().startEditLine(x, y);
	    this.start_line_time_ = now;
	    help_system.achievementUnlocked(HelpLevelEnum.DONE_START_LINE);
	} else {
	    var line = getModel().updateEditLine(x, y);
	    // Make sure that this was not a double-click event.
	    // (are there better ways ?)
	    if (line.length() > 50
		|| (line.length() > 0 && (now - this.start_line_time_) > 500)) {
		getModel().commitEditLine();
		help_system.achievementUnlocked(HelpLevelEnum.DONE_FINISH_LINE);
	    } else {
		getModel().forgetEditLine();
	    }
	}
	getView().drawAll();
    }

    this.onMouseUp = function (e, x, y) {
	getModel().endDrag(x, y);
    };
}

function scrollTop() {
    return document.body.scrollTop + document.documentElement.scrollTop;
}

function scrollLeft() {
    return document.body.scrollLeft + document.documentElement.scrollLeft;
}
/*
function init_download(filename) {
    var pos = filename.lastIndexOf(".");
    if (pos > 0) {
	filename = filename.substr(0, pos);
    }
    var $download_link = $overlayDiv.find('.download-result');
    var download_link = $download_link[0];
    download_link.download = "amass-" + filename + ".png";
    download_link.style.cursor = "pointer";
    download_link.style.opacity = 1;
}
*/
function download_result(download_link) {
    if (backgroundImage === undefined)
	return;
    aug_view.drawAll();
    download_link.href = aug_view.getCanvas().toDataURL('image/png');
}


function getGridSpacing(bands) {
    var STATE_INIT = 0;
    var STATE_FIRST_DARK = 1;
    var STATE_FIRST_LIGHT = 2;
    var STATE_RLE_DARK = 3;
    var STATE_RLE_LIGHT = 4;
    var lengthsMap = Object.create(null);

    var numBands = bands.length;
    for (var b = 0; b < numBands; ++b) {
	var band = bands[b];
	var rle = [];
	var currentLength = 0;
	var state = STATE_INIT;
	var numPixels = band.length;
	for (var i = 0; i < numPixels; ++i) {
	    var isLight = band[i];

	    // start with first dark band
	    switch (state) {
	    case STATE_INIT:
		if (isLight) {
		    state = STATE_FIRST_LIGHT;
		}
		else {
		    state = STATE_FIRST_DARK;
		}
		break;
	    case STATE_FIRST_DARK:
		if (isLight) {
		    state = STATE_FIRST_LIGHT;
		}
		break;
	    case STATE_FIRST_LIGHT:
		if (! isLight) {
		    state = STATE_RLE_DARK;
		    currentLength = 1;
		}
		break;
	    case STATE_RLE_DARK:
		if (isLight) {
		    rle.push(currentLength);
		    state = STATE_RLE_LIGHT;
		    currentLength = 1;
		}
		else {
		    ++currentLength;
		}
		break;
	    case STATE_RLE_LIGHT:
		if (isLight) {
		    ++currentLength;
		}
		else {
		    rle.push(currentLength);
		    state = STATE_RLE_DARK;
		    currentLength = 1;
		}
		break;
	    default:
		throw new Error();
		break;
	    }
	}

	// if the last element of rle is dark, discard it
	if (rle.length % 2 === 1) {
	    rle.pop();
	}

	if (rle.length < 4) {
	    continue;
	}

	// analyze the rle
	var numGridSpaces = rle.length / 2 - 1;
	for (var i = 0; i < numGridSpaces; ++i) {
	    var numDark1 = rle[2 * i];
	    var numLight = rle[2 * i + 1];
	    var numDark2 = rle[2 * i + 2];
	    var length = numDark1 / 2 + numLight + numDark2 / 2;
	    length = '' + length;
	    if (length in lengthsMap) {
		++lengthsMap[length];
	    }
	    else {
		lengthsMap[length] = 1;
	    }
	}
    }

    // analyze the lengthsMap
    var lengthsArray = [];
    var totalGridCount = 0;
    for (var length in lengthsMap) {
	lengthsArray.push({
	    length: parseFloat(length),
	    count: lengthsMap[length]
	});
	totalGridCount += lengthsMap[length];
    }

    if (totalGridCount === 0) {
	throw new Error();
    }

    lengthsArray.sort(function (a, b) {
	var aLength = a.length;
	var bLength = b.length;
	if (aLength < bLength) {
	    return -1;
	}
	else if (aLength > bLength) {
	    return 1;
	}
	else {
	    return 0;
	}
    });

    // 0.25 to 0.45 seem to be about the same
    var cutoff = 0.38;
    var lowerCutoff = Math.round(totalGridCount * cutoff);
    var upperCutoff = Math.round(totalGridCount * (1 - cutoff));
    var numLengths = lengthsArray.length;
    var cumulativeCount = 0;
    var totalGridLength = 0;
    for (var i = 0; i < numLengths; ++i) {
	var gridLength = lengthsArray[i].length;
	var gridCount = lengthsArray[i].count;
	if (upperCutoff <= cumulativeCount) {
	    break;
	}
	else if (cumulativeCount + gridCount <= lowerCutoff) {
	    // do nothing - this is too low
	}
	else {
	    var tooLow = 0;
	    var tooHigh = 0;
	    if (cumulativeCount < lowerCutoff) {
		tooLow = lowerCutoff - cumulativeCount;
	    }
	    if (upperCutoff < cumulativeCount + gridCount) {
		tooHigh = cumulativeCount + gridCount - upperCutoff;
	    }
	    totalGridLength += (gridCount - tooLow - tooHigh) * gridLength;
	}
	cumulativeCount += gridCount;
    }

    var avg = totalGridLength / (upperCutoff - lowerCutoff);

    return avg;
}

function autodetectGrid(canvas, ctx) {
    // first, get the canvas pixels
    var imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);

    var width = imageData.width;
    var height = imageData.height;
    var data = imageData.data;
    var length = data.length;

    // now, analyze the data
    var startX = Math.round(width / 4);
    var endX = Math.round(3 * width / 4);
    var startY = Math.round(height / 4);
    var endY = Math.round(3 * height / 4);

    // convert to greyscale
    for (var y = startY; y <= endY; ++y) {
	for (var x = startX; x <= endX; ++x) {
	    var i = (y * width + x) * 4;
	    var red = data[i];
	    var green = data[i + 1];
	    var blue = data[i + 2];
	    var avg = Math.round(0.299 * red + 0.587 * green + 0.114 * blue);
	    data[i] = data[i + 1] = data[i + 2] = avg;
	}
    }

    /*
    importantImage.png - grey is #ededed
    importantImage3.png - grey is #f7f7f7
    incomplete-RBBB.png - grey is #dbdbdd
    BigeminyCompleteAVB.png - grey is #d8dbd9
    InfStemi.png - grey is #f3f3f3 - white is #f6f6f6
    LBBBpvcs.jpg - grey is #f0cad7 - white is #f3f4ef
    242.5 = between #f2f2f2 and f3f3f3
    */
    var threshold = 242.5;

    try {
	// convert to monochrome
	var numLightPixels = 0;
	var numDarkPixels = 0;
	for (var y = startY; y <= endY; ++y) {
	    for (var x = startX; x <= endX; ++x) {
		var i = (y * width + x) * 4;
		var red = data[i];
		var blackOrWhite;
		if (red < threshold) {
		    blackOrWhite = 0;
		    ++numDarkPixels;
		}
		else {
		    blackOrWhite = 255;
		    ++numLightPixels;
		}
		data[i] = data[i + 1] = data[i + 2] = blackOrWhite;
	    }
	}

	if (numLightPixels === 0 || numDarkPixels === 0) {
	    throw new Error();
	}

	var lightFraction = numLightPixels / (numLightPixels + numDarkPixels);
	if (lightFraction < 0.3 || lightFraction > 0.9) {
	    throw new Error();
	}

	// determine horizontal scale (ms)
	var horizontalBands = [];
	for (var y = startY; y <= endY; ++y) {
	    var horizontalBand = [];
	    for (var x = startX; x <= endX; ++x) {
		var i = (y * width + x) * 4;
		var red = data[i];
		var isLight;
		if (red === 0) {
		    isLight = false;
		}
		else {
		    isLight = true;
		}
		horizontalBand.push(isLight);
	    }
	    horizontalBands.push(horizontalBand);
	}
	var horizontalSpacing = getGridSpacing(horizontalBands);

	// determine vertical scale (mV)
	var verticalBands = [];
	for (var x = startX; x <= endX; ++x) {
	    var verticalBand = [];
	    for (var y = startY; y <= endY; ++y) {
		var i = (y * width + x) * 4;
		var red = data[i];
		var isLight;
		if (red === 0) {
		    isLight = false;
		}
		else {
		    isLight = true;
		}
		verticalBand.push(isLight);
	    }
	    verticalBands.push(verticalBand);
	}
	var verticalSpacing = getGridSpacing(verticalBands);

	aug_view.setHorizontalGrid(horizontalSpacing * 5);
	aug_view.setVerticalGrid(verticalSpacing * 5);

	// ctx.putImageData(imageData, 0, 0);
    }
    catch (e) {
	if ($.fn.measurements.alerted) {
	    return;
	}
	else {
	    //alert('Unable to detect ECG grid, please use "calibrate" button');
	    calibrateFail = true;
		$.fn.measurements.alerted = true;
	}
    }
}

var calibrateFail = false;


function updatePhotoHeight() {
	
	var hoffset = 40;
	var voffset = 50;
	var windowHeight = $(window).height();
	var windowWidth = $(window).width();
	var imageHeight = $(img).height();
	var imageWidth = $(img).width();
	
	//find which is more limiting, height or width:
	var heightD = imageHeight - windowHeight;
	var widthD = imageWidth - windowWidth;
	var imageRatio = imageWidth/imageHeight;
	//var windowRatio = windowWidth/windowHeight;
	
	if (heightD > widthD) {
		//scale to height
		$(img).parent().css('height', windowHeight-voffset);
		$(img).parent().css('width', (windowHeight-voffset)*imageRatio);
	} else {
		$(img).parent().css('width', windowWidth-hoffset);
		$(img).parent().css('height', (windowWidth-hoffset)/imageRatio);
	}
	
}


function setOverlayPosition() {
	updatePhotoHeight();
    var $img = $(backgroundImage);
    //alert($(backgroundImage).prop('nodeName'));
    var width = $(img).parent().width();
    var height = $(img).parent().height();
    var offset = $(img).parent().offset();
    //var left = offset.left;
    var left = 0;  //moved canvas and made it relative
    //var top = offset.top;
    var top = 0;
    

    $overlayDiv.css({
	left: left + 'px',
	top: top + 'px',
	width: width + 'px',
	height: height + 'px'
	//width: '100%',
	//height: '100%'
    });

    width = Math.round(width);
    height = Math.round(height);

    var $background_canvas = $overlayDiv.find('.background-img');
    var background_canvas = $background_canvas[0];
    background_canvas.width = width;
    background_canvas.height = height;
    var bg_context = background_canvas.getContext('2d');
    bg_context.drawImage(backgroundImage, 0, 0, backgroundImage.width, backgroundImage.height);

    canvasImage = new Image();
    canvasImage.src = background_canvas.toDataURL('image/png');

    var $measure_canvas = $overlayDiv.find('.measure');
    var measure_canvas = $measure_canvas[0];
    measure_canvas.width = width;
    measure_canvas.height = height;

    if (loupe_canvas) {
	loupe_canvas.style.left = (width + 10) + 'px';
    }

    aug_view.drawAll();
}

    backgroundImage = img;

    // create the canvas and other elements, and replace the image
    $overlayDiv = $('<div style="position: absolute; z-index: 100;"></div>');
    /*
    var html = '\
      <div class="ecg-controls" style="position: absolute; z-index: 30; left: 0; bottom: 100%; width: 100%;">\
      <form style="display: inline;">\
        <button type="button" class="btn ecg-zoom-button" style="outline: none;">Zoom</button>\
        <button type="button" class="btn ecg-measure-button" style="outline: none;">Measure</button>\
        <div class="ecg-controls-2" style="padding-top: 10px; padding-bottom: 10px; visibility: hidden;">\
        <button type="button" class="btn specify-grid-size-manually" style="outline: none;">Calibrate</button>\
        <button type="button" class="btn ecg-clear-button" style="outline: none;">Clear</button>\
        <a class="download-result" download="amass-result.png" style="font-size: larger; font-weight: bold; padding: 2px;">[Export transparent overlay]</a>\
        <span class="helptext" style="padding-left: 1em; font-weight: bold;"></span>\
        </div>\
      </form>\
      </div>\
      <canvas class="background-img" width="50" height="50" style="position: absolute; left: 0; top: 0; background: transparent; z-index: 10; visibility: hidden;"></canvas>\
      <canvas class="measure" width="50" height="50" style="position: absolute; left: 0; top: 0; background: transparent; z-index: 20;"></canvas>\
      <canvas class="loupe" width="280" height="280" style="position: absolute; left: 50%; top: 50%; background: transparent; z-index: 30; display: none; box-shadow: 3px 3px 15px; border-radius: 10px; color: #000;"></canvas>\
    ';*/
    
    var html = '\
        <div class="ecg-controls" style="">\
        <form style="display: inline;">\
          <button type="button" class="btn btn-xs ecg-zoom-button" style="outline: none;">Zoom</button>\
          <button type="button" class="btn btn-xs ecg-measure-button" style="outline: none;">Measure</button>\
          <div class="ecg-controls-2" style="visibility: hidden;">\
          <button type="button" class="btn btn-xs specify-grid-size-manually" style="outline: none;">Calibrate Distances</button>\
    	  <button type="button" class="btn btn-xs ecg-clear-button" style="outline: none;">Clear</button>\
    		<span class="helptext" style="padding-left: 1em; font-weight: bold;"></span>\
          </div>\
        </form>\
        </div>\
        <canvas class="background-img" width="50" height="50" style="position: absolute; left: 0; top: 0; background: transparent; z-index: 10; visibility: hidden;"></canvas>\
        <canvas class="measure" width="50" height="50" style="position: absolute; left: 0; top: 0; background: transparent; z-index: 20;"></canvas>\
        <canvas class="loupe" width="280" height="280" style="position: absolute; left: 50%; top: 50%; background: transparent; z-index: 30; display: none; box-shadow: 3px 3px 15px; border-radius: 10px; color: #000;"></canvas>\
      ';
    
    $overlayDiv.append(html);
    $(backgroundImage).parent().append($overlayDiv);

    $backgroundCanvas = $overlayDiv.find('.background-img');
    backgroundCanvas = $backgroundCanvas[0];

    $overlayDiv.find('.ecg-zoom-button').click(function () {
	var $button = $(this);
	if ($button.hasClass('active')) {
	    $button.removeClass('active');
	}
	else {
	    $button.addClass('active');
	}
	aug_view.updateModeIndicators();
	aug_view.drawAll();
    });

    $overlayDiv.find('.ecg-measure-button').click(function () {
	var mode = aug_view.getMode();
	switch (mode) {
	case 'measuring':
	    aug_view.defaultMode();
	    break;
	case 'grid_size':
	case 'default':
	    aug_view.measuringMode();
	    if (calibrateFail == true) alert ("Cannot detect ECG grid to calibrate measurements, use the 'Calibrate' button and draw a box around the large grid box (200ms by 0.5mV)");
	    break;
	}
	aug_view.drawAll();
    });

    $overlayDiv.find('.specify-grid-size-manually').click(function (e) {
	var mode = aug_view.getMode();
	switch (mode) {
	case 'grid_size':
	    aug_view.defaultMode();
	    break;
	case 'measuring':
	case 'default':
	    aug_view.gridSizeMode();
	    break;
	}
	aug_view.drawAll();
    });

    $overlayDiv.find('.ecg-clear-button').click(function () {
	aug_view.model_.removeAllLines();
	aug_view.measuringMode();
	aug_view.drawAll();
    });

    amass_init(img.naturalWidth, img.naturalHeight);

    var $img = $(backgroundImage);
    var $window = $(window);
    //var windowWidth = $(img).parent().width();
    //var windowHeight = $(img).parent().height();
    $window.resize(function () {
    	//var newWindowWidth = $(img).parent().width();
    	//var newWindowHeight = $(img).parent().height();
    	//if (windowWidth !== newWindowWidth || windowHeight !== newWindowHeight) {
	    //windowWidth = newWindowWidth;
	    //windowHeight = newWindowHeight;
	    setOverlayPosition();
	    //alert("test");
	    //}
    });
    var mutationObserver = new MutationObserver(function (mutations) {
	setOverlayPosition();
    });
    mutationObserver.observe(document, {childList: true});
    setOverlayPosition();

    var autodetectCanvas = document.createElement('canvas');
    autodetectCanvas.width = img.naturalWidth;
    autodetectCanvas.height = img.naturalHeight;
    var autodetectCanvasContext = autodetectCanvas.getContext('2d');
    autodetectCanvasContext.drawImage(img, 0, 0, img.naturalWidth, img.naturalHeight);
    autodetectGrid(autodetectCanvas, autodetectCanvasContext);
    // document.body.appendChild(document.createElement('hr'));
    // document.body.appendChild(autodetectCanvas);

    var url = img.src;
    var matches = /[^/]+$/.exec(url)
    if (matches) {
	var filename = matches[0];
	//init_download(filename);
    }

    aug_view.drawAll();
  }

  $.fn.measurements = function (options) {
    var settings = $.extend({
        magnification: 6
    }, options );

    this.each(function () {
      if (this.complete) {
        loadedImage(this, settings);
      }
      else {
        this.addEventListener('load', function () {
          loadedImage(this, settings);
        });
      }
    });
  };
})(jQuery);
