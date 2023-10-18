/**
 * 
 *//**
 * 
 */

/**
 * 
 */

var x;
var endTime = 0;
// Set the date we're counting down to
function startTimer(buttonEle, timerEle, timeLeft) {
	
	if (timeLeft) {
		  endTime = new Date().getTime() + timeLeft;
		
		// Update the count down every 1 second
		  x = setInterval(function() {
		
		  // Get today's date and time
		  var now = new Date().getTime();
		  //console.log(new Date().getTime() + " | " + timeLeft);
		  
		  
		  // Find the distance between now and the count down date
		  var distance = endTime - now;
	
		
		  // Time calculations for days, hours, minutes and seconds
		  //var days = Math.floor(distance / (1000 * 60 * 60 * 24));
		  var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
		  var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
		  var seconds = Math.floor((distance % (1000 * 60)) / 1000);
		
		  //console.log("seconds: " + distance);
		  // Display the result in the element with id="demo"
		  var finalText = "";
		  if (hours > 0)
			  finalText += hours + ":"
		  if (minutes > 0)
				  finalText += minutes + ":"
		  finalText += seconds
		  timerEle.text(finalText);
		  
		  // If the count down is finished, write some text
		  if (distance < 0) {
		    clearInterval(x);
		    timerEle.text("");
		    buttonEle.text("Retry Now!")
		    buttonEle.removeClass("disabled");
		    buttonEle.removeAttr("disabled")
		  }
		}, 1000);
	}
}

function printElement(elem, append, delimiter) {
    var domClone = elem.cloneNode(true);

    var $printSection = document.getElementById("printSection");

    if (!$printSection) {
        $printSection = document.createElement("div");
        $printSection.id = "printSection";
        document.body.appendChild($printSection);
    }

    if (append !== true) {
        $printSection.innerHTML = "";
    }

    else if (append === true) {
        if (typeof (delimiter) === "string") {
            $printSection.innerHTML += delimiter;
        }
        else if (typeof (delimiter) === "object") {
            $printSection.appendChild(delimiter);
        }
    }

    $printSection.appendChild(domClone);
}


