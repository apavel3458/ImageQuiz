<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ page import="org.apache.struts.Globals" %>
<%@ page import="org.apache.struts.taglib.html.Constants" %>
    
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Study Registration</title>

    <!-- Bootstrap -->
    <link href="<c:url value="/css/lib/bootstrap.paper.min.css"/>" rel="stylesheet">
	<link href="<c:url value="/research/css/register.css"/>" rel="stylesheet">
	<link href="<c:url value="/css/quizsetup2.css"/>" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="register">
  	<div class="panel panel-primary centerPositionNonAbsolute">
  		<div class="panel-heading text-center">
    		<h2 class="panel-title regTitle">Quiz Setup</h2>
  		</div>
	  	<div class="panel-body">
	    	<form action="exam.do" id="myForm">
    			<input type="hidden" name="method" value="quizNavigation">
    			<input type="hidden" name="<%= Constants.TOKEN_KEY %>" value="<%= session.getAttribute(Globals.TRANSACTION_TOKEN_KEY) %>">
	    		    	    	<c:choose>
	    		    	    		<c:when test="${!requestScope.resumeQuiz && requestScope.caseReview}">
										<div class="boxTitle">Welcome to Case Review Mode</div>
									</c:when>
									<c:when test="${requestScope.resumeQuiz && requestScope.caseReview}">
										<div class="boxTitle">Welcome back to Case Review Mode</div>
									</c:when>
		    		    	    	<c:when test="${requestScope.resumeQuiz}">
										<div class="boxTitle">Welcome back, you can resume your test</div>
									</c:when>
									<c:when test="${!requestScope.resumeQuiz}">
										<div class="boxTitle">You are ready to start the quiz!</div>
									</c:when>
	    		    			</c:choose>
	    		    			<table class="quizIntroTable" style="margin-left: auto; margin-right: auto;">
						        	<tr><th>
						        		Number of Cases:
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
						        	<tr class="spacing"><th>
						        		User:
						        		</td>
						        		<td>
						        			<c:out value="${sessionScope.security.firstName } ${sessionScope.security.lastName }"/>
						        		</td>
						        	</tr>
						        	<c:if test="${!requestScope.caseReview}">
						        	<tr class="line">
						        		
						        			<th> INSTRUCTIONS</th>
						        			<td><button type="button" class="btn btn-default btn-xs" data-toggle="modal" data-target="#instructionsVideo">1-minute Video</button>
						        			<br> OR <br>
						        				<button type="button" class="btn btn-default btn-xs" data-toggle="modal" data-target="#instructionsText">30-second Read</button>
					        				</td>
						        	</tr>
						        	</c:if>
					        	</table>
	    		    
	    		   
				    
				        <div class="form-group">
					      <div class="text-center">
					        <button type="button" name="quit" class="btn btn-danger quitButton" onclick="document.location='<c:url value="/"/>'">Quit to Login</button>
							<button type="submit" name="submit" class="btn btn-primary">
							<c:if test="${requestScope.resumeQuiz}">
								<c:if test="${requestScope.caseReview }">
									Resume Case Review!
								</c:if>
								<c:if test="${!requestScope.caseReview }">
									Resume Quiz!
								</c:if>
							</c:if>
							<c:if test="${!requestScope.resumeQuiz}">
								<c:if test="${requestScope.caseReview }">
									Start Case Review!
								</c:if>
								<c:if test="${!requestScope.caseReview }">
									Start Quiz!
								</c:if>
							</c:if>
							</button>
					      </div>
					    </div>
				    
	    	</form>
	  	</div>
	</div>
    
    
    <div id="instructionsVideo" class="modal fade instructionModal" role="dialog">
    	<div class="modal-dialog" style="width: 750px;">
    	<div class="modal-content">
      		<div class="modal-header">
        		<button type="button" class="close" data-dismiss="modal">&times;</button>
        		<h4 class="modal-title">Instructions Video</h4>
       		</div>
	       <div class="modal-body" style="width: 100%; text-align: center; padding: 0px;">
	  			<!-- iframe width="700" height="500" class="youtube_player_iframe" src="https://www.youtube.com/embed/AVoLMZd3PeY?enablejsapi=1" frameborder="0" allowfullscreen></iframe-->
			    <iframe width="700" height="394" class="youtube_player_iframe"  src="https://www.youtube.com/embed/BMe8zllGfOc?enablejsapi=1" frameborder="0" allowfullscreen></iframe>
			</div>
		   <div class="modal-footer">
		        <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
		   </div>
		</div>
		</div>
	</div>
	
	
	<div id="instructionsText" class="modal fade instructionModal" role="dialog">
    	<div class="modal-dialog" style="width: 700px;">
    	<div class="modal-content">
      		<div class="modal-header">
        		<button type="button" class="close" data-dismiss="modal">&times;</button>
        		<h4 class="modal-title">Instructions Text</h4>
       		</div>
	       <div class="modal-body" style="width: 100%; text-align: left;">
  			<ul class="instructionUL">
  			<li>This program will present you with a series of ECGs</li>
  			<li>You can use the buttons on the top-left of the ECG to "Zoom" and "Measure" intervals</li>
  			<li>Go through the entire approach to ECGs (rate, rhythm, axis, intervals, ischemia, etc..)</li>
  			<li>Enter all findings in the text box at the top ("Search Text" question)
  				<ul class="instructionUL">
	  				<li>Enter a few letters, and let the program present you options from a list of possibilities</li>
	  				<li>(This is different from multiple choice... you must know what you are looking for)</li>
	  				<li>It is recommended to use as few letters as possible to broaden choices</li>
	  				<li>Clicking the white list button lets you see all available choices</li>
	  				<li>Click on the choice to add it to the list (you can click on X to remove)</li>
	  				<li>Once you have a list of findings, you can click next to review the results</li>
	  				<li style="color: grey;">Comments/issues with the ECG can be entered at the bottom of the answer page</li>
  				</ul>
  			</li>
  			</ul><br>
  			<div style="text-align: center;">
	  			<img src="screenshot1b.png" style="width: 49%; height: auto;">
	  			<img src="screenshot2b.png" style="width: 49%; height: auto; ">
  			</div>
			</div>
		   <div class="modal-footer">
		        <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
		   </div>
		</div>
		</div>
	</div>
	
	<div class="absoluteFooter">
		<jsp:include page="/case/footer2.jsp" />
	</div>
    
    
    

    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="<c:url value="/jslib/jquery-1.12.4.min.js"/>"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="<c:url value="/jslib/bootstrap.min.js"/>"></script>
    
    <script type="text/javascript" language="JavaScript">

    $(function() {
    	
        $('#instructionsVideo').on('hidden.bs.modal', function () {
        	$('.youtube_player_iframe').each(function(){
      		  this.contentWindow.postMessage('{"event":"command","func":"' + 'stopVideo' + '","args":""}', '*');
      		});
        })
        
    		
    	$('form').submit(function(){
	    	$(this).children('input[type=submit]').prop('disabled', true);
    	});
	});
    </script>
  </body>
</html>