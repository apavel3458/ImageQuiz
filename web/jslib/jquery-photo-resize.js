/// <reference path="jquery-1.5.1.min.js" />

/*
* Adjust photo on browser window resize
* 
* @example: $('selector').photoResize();
* 
* @example:
	$('selector').photoResize({
		bottomSpacing:"Bottom Spacing adjustment"
	});
*/
var maxHeightTemp = 0;

(function ($) {

	$.fn.photoResize = function (options) {
		var element	= $(this), 
			defaults = {
	            hoffset: 10,
	            voffset: 50
			};
		
		//alert($(element).prop("tagName"));
		$(document).ready(function() {
			updatePhotoHeight();

			$(window).bind('resize', function () {
				updatePhotoHeight();
			});
		});

		options = $.extend(defaults, options);

		function updatePhotoHeight() {
			
			var o = options;
			var hoffset = 10;
			var voffset = 50;
			var windowHeight = $(window).height();
			var windowWidth = $(window).width();
			var imageHeight = $(element).height();
			var imageWidth = $(element).width();
			
			//find which is more limiting, height or width:
			var heightD = imageHeight - windowHeight;
			var widthD = imageWidth - windowWidth;
			var imageRatio = imageWidth/imageHeight;
			//var windowRatio = windowWidth/windowHeight;
			
			if (heightD > widthD) {
				//scale to height
				$(element).parent().css('height', windowHeight-voffset);
				$(element).parent().css('width', (windowHeight-voffset)*imageRatio);
			} else {
				$(element).parent().css('width', windowWidth-hoffset);
				$(element).parent().css('height', (windowWidth-hoffset)/imageRatio);
			}
			
		}
	};

}(jQuery));