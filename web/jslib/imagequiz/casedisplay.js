/**
 * 
 */

var x;
var endTime = 0;
// Set the date we're counting down to
function startTimer(timeLeft) {
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
		  
		  $("#timerDigits").text(hours + "h "
		  + minutes + "m " + seconds + "s ");
		  		  
		  if (minutes < 3) {
			  $("#timer").addClass("danger");
		  }
		
		  // If the count down is finished, write some text
		  if (distance < 0) {
		    clearInterval(x);
		    $("#timerDigits").html("OUT OF TIME");
		    $("#timer").addClass("danger");
		    alert("Time has expired!");
		    submitForm('next');
		  }
		}, 1000);
	}
}