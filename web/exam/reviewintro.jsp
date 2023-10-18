<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ page import="org.apache.struts.Globals" %>
<%@ page import="org.apache.struts.taglib.html.Constants" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>ECG Master Quiz Setup</title>

<script src="../jslib/jquery-1.10.1.min.js"></script>
<script src="../jslib/jquery-ui.min.js"></script>
<script type="text/javascript" src="../jslib/setupwizard.js"></script>
<c:set var="req" value="${pageContext.request}" />
<c:set var="baseURL" value="${req.scheme}://${req.serverName}:${req.serverPort}${req.contextPath}" />

<link rel="stylesheet" type="text/css" href="../css/quizsetup.css?v=1">
<link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.10.3/themes/base/jquery-ui.css">
<link rel="stylesheet" type="text/css" href="../css/case.css">
<link rel="stylesheet" type="text/css" href="../css/exam.css">

<script type="text/javascript">
	function openInstructionsVideo() {
		$( "#instructionsVideo" ).dialog( "open" );
	}
	
	function openInstructionsText() {
		$( "#instructionsText" ).dialog( "open");
	}
	
	$(function() {
	    $( "#instructionsVideo" ).dialog({
	    	position: ['center', 'center'],
	    	height: 600,
	    	width: 700,
	    	autoOpen: false,
	    	buttons: {
	            "Finished - Close": function() {
	            	$('.youtube_player_iframe').each(function(){
	            		  this.contentWindow.postMessage('{"event":"command","func":"' + 'stopVideo' + '","args":""}', '*')
	            		});
	                $(this).dialog("close");
	            }
	        },
	        close: function(event, ui) { 
	        	$('.youtube_player_iframe').each(function(){
          		  this.contentWindow.postMessage('{"event":"command","func":"' + 'stopVideo' + '","args":""}', '*')
          		});
	        }
	    });
	    
	    $( "#instructionsText" ).dialog({
	    	position: ['center', 'center'],
	    	height: 500,
	    	width: 700,
	    	autoOpen: false,
	    	buttons: {
	            "Finished - Close": function() {
	                $(this).dialog("close");
	            }
	        }
	    });
	});
</script>

</head>
<body>
	<jsp:include page="header.jsp" />

<!-- multistep form -->
<form id="msform" action="exam.do">
    <input type="hidden" name="method" value="quizNavigation">
    <input type="hidden" name="<%= Constants.TOKEN_KEY %>" value="<%= session.getAttribute(Globals.TRANSACTION_TOKEN_KEY) %>">
    
	<!-- progressbar -->
	<ul id="progressbar">
		<li style="width: 50%;">Confirm User</li>
		<li style="width: 50%;" class="active">Start Test</li>
	</ul>
	<!-- fieldsets -->
	
	<fieldset>
		<c:if test="${requestScope.resumeQuiz}">
			<h2 class="fs-title">Welcome back, you can resume your test</h2>
		</c:if>
		<c:if test="${!requestScope.resumeQuiz}">
			<h2 class="fs-title">You are ready to start the quiz!</h2>
		</c:if>

			<table class="quizIntroTable" style="margin-left: auto; margin-right: auto;">
	        	<tr><th>
	        		Number of Questions:
	        		</td>
	        		<td>
	        			<c:out value="${requestScope.questionNumber }"/> questions
	        		</td>
	        	</tr>
	        	<c:if test="${requestScope.resumeQuiz}">
	        	<tr><th>
	        		Number Completed:
	        		</th>
	        		<td>
	        		<c:out value="${requestScope.completedQuestions }"/>
	        		</td>
        		</tr>
	        	</c:if>
	        	<tr><th>
	        		User:
	        		</td>
	        		<td>
	        			<c:out value="${sessionScope.security.firstName } ${sessionScope.security.lastName }"/>
	        		</td>
	        	</tr>
	        	<tr>
	        		
	        			<th> INSTRUCTIONS</th>
	        			<td><a href="#" onclick="openInstructionsVideo();">Option 1: 2-minute VIDEO</a><br><br>
	        				<a href="#" onclick="openInstructionsText();">Option 2: Text</a>
        				</td>
	        	</tr>
        	</table>

		<div id="instructionsVideo" title="Instructions Video">
  			<iframe width="700" height="500" class="youtube_player_iframe" src="https://www.youtube.com/embed/AVoLMZd3PeY?enablejsapi=1" frameborder="0" allowfullscreen></iframe>
		</div>
		<div id="instructionsText" title="Instructions Text">
  			Simply Put:
  			<ul class="instructionUL">
  			<li>This program will present you with a series of ECGs</li>
  			<li>Click and drag the ECGs to display the Zoom Lens</li>
  			<li>Go through the entire approach to ECGs (rate, rhythm, axis, intervals, ischemia, etc..)</li>
  			<li>Enter all findings in the text box at the top
  				<ul class="instructionUL">
	  				<li>The text box at the top is a "Search Text" type question.</li>
	  				<li>Enter a few letters, and let the program present you options from a list of possiblities</li>
	  				<li>(This is different from multiple choice... you must know what you are looking for)</li>
	  				<li>It is recommended to use as few letters as possible to broaden choices</li>
	  				<li>Click on the choice to add it to the list (you can click on X to remove)</li>
	  				<li>Once you have a list of findings, you can click next to review the results</li>
	  				<li>Click on (i) letter next to the question to display all possible choices</li>
  				</ul>
  			</li>
  			</ul>
  			<table><tr><td>
  			<img src="Screenshot2.png" style="width: 100%; height: auto;">
  			</td><td>
  			<img src="Screenshot1.png" style="width: 100%; height: auto; ">
  			</td></tr>
  			</table>
		</div>

		<input type="button" name="quit" class="action-button" onclick="document.location='${baseURL}/index.jsp'" value="Quit to Login">
		<c:if test="${requestScope.resumeQuiz}">
			<input type="submit" name="submit" class="submit action-button" value="Resume Quiz!" />
		</c:if>
		<c:if test="${!requestScope.resumeQuiz}">
			<input type="submit" name="submit" class="submit action-button" value="Start Quiz!" />
		</c:if>
		
	</fieldset>
</form>

        <div style="position: absolute; bottom: 50px; left: 0; right: 0; margin-left: auto; margin-right: auto; z-index: -1;">
        <jsp:include page="../footer.jsp" />
        </div>

    </body>
</html>
