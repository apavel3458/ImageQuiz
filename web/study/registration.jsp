<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Study Registration</title>

    <!-- Bootstrap -->
    <link href="../css/lib/bootstrap.paper.min.css" rel="stylesheet">
	<link href="register.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="register">
  
  	<c:if test="${not empty sessionScope.error }">
  	  <div style="position: absolute; left: 50%;">
  		<div class="alert alert-dismissible alert-danger alertStyle" style="width: 600px; position: relative; left: -50%; top: -60px;">
  			<button type="button" class="close" data-dismiss="alert" style="right: 0px;">&times;</button>
  			<strong>Could not log in: </strong> <a href="#" class="alert-link"><c:out value="${sessionScope.error }"/></a>
		</div>
	</div>
  	</c:if>
  
  	<div class="panel panel-primary centerPosition welcomeChoice" id="welcomeDiv" style="<c:if test="${sessionScope.openLogin == 'true'}">display: none; </c:if>width: 600px;">
	  	<div class="panel-heading text-center">
	    		<h2 class="panel-title" style="font-weight: bold; font-size: 20px;">ECG Learning Research Study</h2>
	  	</div>
	  	<div class="panel-body">
	  		<h5 class="text-center">Please select one of the following:</h5>
	  		<div class="form-group">
			      <div class="text-center" style="padding-top: 10px;">
			        <button type="submit" class="btn btn-default" data-toggle="modal" data-target="#consentModal">New Participant</button> &nbsp;&nbsp;
			        <button type="submit" class="btn btn-primary" onclick="returningParticipant()">Returning Participant</button>
			      </div>
			</div>
	  	</div>
  	</div>
  	
  	
  	
  	
  	<div class="panel panel-primary centerPosition register" id="registrationDiv" style="display: none; width: 600px;">
  		<div class="panel-heading text-center">
    		<h2 class="panel-title" style="font-weight: bold; font-size: 20px;">Registration Form</h2>
  		</div>
	  	<div class="panel-body">
	  		<H5>Please enter the following registration details:</H5>
	    	<form action="/ImageQuiz/user.do" id="registrationForm" class="" rule="form" data-toggle="validator">
	    		<input type="hidden" name="method" value="registerForStudy">
	    		    <div class="registerGroup form-group">
				      <label for="inputUsername" class="control-label"><b>User ID</b></label>
				      	<div class="note">
				        Please create a <u><B>non-identifying</B></u> 
				        Unique ID.  You will use it to resume the study if you want to take a pause.<br/><br/>
				        It must be &gt;4 characters long, and can be a word or a phrase with spaces) <br>
				        Please ensure this ID does not identify you in any way to maintain anonymity of your results.
				        <br>This ID is stored encrypted, and we can never recover it if you forget it.
				        </div>
				      <div class="inputDiv">
				        <input type="text" class="registerInput" id="userid" name="userid" placeholder="User ID" style="width: 200px;">
				        <button type="button" class="btn btn-default btn-xs" onclick="" style="margin-left: 10px;">check availability</button>
				      	<label for="inputUsername" class="inputMessage control-label" style="display:none;"></label>
				      </div>
				    </div>
				    
				    <!-- div class="registerGroup form-group">
				      <label for="age" class="control-label">What is your age?</label>
				      <div class="inputDiv">
				        <input type="number" class="registerInput" min="12" max="100" id="age" name="age" placeholder="Age" style="width: 100px;">
				        <label for="inputUsername" class="inputMessage control-label" style="display:none;"></label>
				      </div>
				    </div-->
				    
				    <div class="registerGroup">
				      <label for="inputUsername" class="control-label">Gender</label>
				      <div class="inputDiv">
				                <select class="registerInput" id="select" style="width: 100px;">
						          <option value="">- Select - </option>
						          <option value="male">Male</option>
						          <option value="female">Female</option>
						        </select>
				      </div>
				    </div>
				    
				    <div class="registerGroup">
				      <label for="selectProgram" class="control-label">Training Program?</label>
				      <div class="inputDiv">
				                <select class="registerInput" name="program" id="selectProgram">
						          <option value="">- - Please Select - - </option>
						          <option value="cc">Medical School</option>
						          <option value="im">Internal Medicine</option>
						          <option value="im">Cardiology</option>
						          <option value="anesthesia">Anesthesia</option>
						          <option value="er">Emergency Medicine</option>
						          <option value="fm">Family Medicine</option>
						        </select>
				      </div>
				    </div>
				    
				    
				    <div class="registerGroup">
				      <label for="selectLevel" class="control-label">Level of training?</label>
				      <div class="inputDiv">
				                <select class="registerInput" name="level" id="selectLevel">
				                  <option value="">- - Please Select - - </option>
						          <option value="cc1">Medical Student (Year 1)</option>
						          <option value="cc2">Medical Student (Year 2)</option>
						          <option value="cc3">Medical Student (Year 3)</option>
						          <option value="cc4">Medical Student (Year 4)</option>
						          <option value="pgy1">Resident Year 1</option>
						          <option value="pgy2">Resident Year 2</option>
						          <option value="pgy3">Resident Year 3</option>
						          <option value="pgy4">Resident Year 4</option>
						          <option value="pgy5">Resident Year 5</option>
						          <option value="pgy6">Resident Year 6</option>
						        </select>
				      </div>
				    </div>
				    
				    
				    <div class="registerGroup">
				      <label for="selectCareer" class="control-label">Career interest?</label>
				      <div class="inputDiv">
				                <select class="registerInput" name="career" id="selectCareer">
				                  <option value="">- - Please Select - - </option>
						          <option value="cardiology">Cardiology</option>
						          <option value="er">Emergency Medicine</option>
						          <option value="anesthesia">Anesthesia</option>
						          <option value="other">Other</option>
						        </select>
				      </div>
				    </div>
				    
				    
				    <div class="registerGroup form-group">
				      <label for="inputBlocks" class="control-label">How many blocks of Cardiology have you had in your training? (Include residency and medical school)</label>
				      <div class="inputDiv">
				        <input type="number" name="blocks" class="registerInput" id="inputBlocks" placeholder="# of blocks">
				      </div>
				    </div>
				    
				    <div class="registerGroup form-group">
				      <label for="inputBlocks" class="control-label">Email to send reminder for a 2-week post-test (remains secret from investigators, deleted once reminder e-mail is sent)</label>
				      <div class="inputDiv">
				        <input type="text" name="email" class="registerInput" id="inputEmail" placeholder="Reminder Email">
				      </div>
				    </div>
				    
				    <div class="registerGroup">
				      <label for="inputSkill" class="control-label">Rate your self-perceived skill in interpreting ECGs</label>
				      <div class="inputDiv text-center">
				      	<table class="radioButtonTable">
				      		<tr>
				      			<td class="tableLabel" colspan="2" style="text-align: left;">Beginner</td>
				      			<td></td>
				      			<td class="tableLabel" colspan="2" style="text-align: right;">Expert</td>
				      		</tr>
				            <tr>
				            	<th>1</th>
				            	<th>2</th>
				            	<th>3</th>
				            	<th>4</th>
				            	<th>5</th>
				            </tr>
				            <tr>
				            	<td><input type="radio" name="skill" value="1"></td>
				            	<td><input type="radio" name="skill" value="2"></td>
				            	<td><input type="radio" name="skill" value="3"></td>
				            	<td><input type="radio" name="skill" value="4"></td>
				            	<td><input type="radio" name="skill" value="5"></td>
				            </tr>
				         </table>
				      </div>
				    </div>
				    
				        <div class="registerGroup">
					      <div class="text-center controlButtons">
					        <button type="button" class="btn btn-default" onclick="registrationToWelcome()">Back</button>
					        <button type="submit" class="btn btn-primary">Register</button>
					      </div>
					    </div>
	    	</form>
	  	</div>
	</div>
	
	 <div class="panel panel-primary centerPosition welcomeChoice" id="returnDiv" style="<c:if test="${sessionScope.openLogin != 'true'}">display: none;</c:if> width: 600px;">
	  	<div class="panel-heading text-center">
	    		<h2 class="panel-title" style="font-weight: bold; font-size: 20px;">Resume Practice/Test</h2>
	  	</div>
	  	<div class="panel-body">
	  		<form action="/ImageQuiz/user.do" id="loginForm">
	  			<input type="hidden" name="method" value="loginForStudy">
		    	<div class="form-group">
		    	  <h5 style="text-align: center;">Please enter the User ID you created during registration:</h5>
			      <div class="inputDiv"  style="width: 80%; margin-left:auto; margin-right:auto;">
			        <input type="text" class="form-control" id="userid" name="userid" placeholder="User ID">
			      </div>
			    </div>
			    
		  		<div class="form-group text-center">
				      <div class="text-center" style="padding-top: 10px;">
				        <button type="button" class="btn btn-default" onclick="returningToWelcome()">Back</button> &nbsp;&nbsp;
				        <button type="submit" class="btn btn-primary">Continue</button>
				      </div>
				</div>
			</form>
	  	</div>
  	</div>
  	
  	
  	<!-- Modal -->
	<div id="consentModal" class="modal fade" role="dialog">
	  <div class="modal-dialog" style="width: 80%;">
	
	    <!-- Modal content-->
	    <div class="modal-content">
	      <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal">&times;</button>
	        <h4 class="modal-title">Consent Information</h4>
	      </div>
	      <div class="modal-body">
	        <iframe id="consentIframe" src="consentUWO.jsp" style="width: 100%;"></iframe>
	      </div>
	      <!-- div class="modal-footer">
	        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
	      </div-->
	    </div>
	
	  </div>
	</div>
	
    

    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="../jslib/jquery-1.12.4.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="../jslib/bootstrap.min.js"></script>
    
    <script type="text/javascript" language="JavaScript">
    
    	$(function() {

    		
    		$('#registrationForm').submit(function() {
    		    validateUsername();
    		    //validateAge();
    		    validateInputBlocks();
    		    if (blocksValidation && userValidation) {
    		    	return true;
    		    }
    		    return false; //you can just return c because it will be true or false
    		});
    		
    		$("#userid").blur(function () {
    			validateUsername();
    		})
    		
    		
    		/*$("#age").blur(function () {
    			validateAge();
    		})*/
    		
    		$("#inputBlocks").blur(function () {
    			validateInputBlocks();
    		})

    	})
    	
    	var useridchecked = "";
    	var userValidation = false;
    	//var ageValidation = false;
    	var blocksValidation = false;
    	function validateUsername() {
    		field = $("#userid");
			var userid = $(field).val();
			if (userid == "") {
				validateError(field, "Username is required");
			} else if (userid.length <= 4) {
				validateError(field, "Must be &gt; 4 characters");
				return;
			} else if (userid.length > 20) {
				validateError(field, "Must be &lt; 20 characters");
			} else if (!/^[a-zA-Z\s0-9]*$/.test(userid)) {
				validateError(field, "Illegal characters used - please use only letters, numbers, spaces");
			} else {
				if (useridchecked != userid) {
					checkIfAvailable(userid);
					useridchecked = userid;
				}
			}
			
			
			
    	}
    	
    	function checkIfAvailable(useridStr) {
    		$.ajax({
    	        url: "../user.do",
    	        data: {
    	            method: "checkUsername",
    	            userid: useridStr
    	        },
    	        type: "GET",
    	        dataType: "html",
    	        success: function (data) {
    	        	//alert(data + " available " + (data == 'available'));
    	        	if (data.trim() == 'available') {
    	        		//alert("valid");
    	        		validateSuccess($("#userid"), "User ID valid and available");
    	        		userValidation = true;
    				} else {
    					validateError($("#userid"), "User ID '" + useridStr + "' is taken, pick a different one");
    					userValidation = false;
    	        	}
    	        },
    	        error: function (xhr, status) {
    	            alert("Could not check, error: '" + xhr.responseText + "'. Please try again later");
    	            userValidation = false;
    	        },
    	        complete: function (xhr, status) {
    	            //$('#showresults').slideDown('slow')
    	        }
    	    });
    	}
    	/*
    	function validateAge() {
    		field = $("#age");
			var ageVal = $(field).val();
			if (ageVal == "") {
				validateError(field, "Cannot be empty");
				ageValidation = false;
			} else if (!/^([1-9]|[1-9][0-9]|[1][0-2][0-9])$/.test(ageVal)) {
				validateError(field, "Invalid Age");
				ageValidation = false;
			} else {
				validateNormal(field);
				ageValidation = true;
			}
    	}*/
    	
    	function validateInputBlocks() {
    		field = $("#inputBlocks");
			var ageVal = $(field).val();
			if (ageVal == "") {
				validateError(field, "Cannot be empty");
				blocksValidation = false;
			} else if (!/^([0-9]|[1-9][0-9])$/.test(ageVal)) {
				validateError(field, "Invalid number of blocks");
				blocksValidation = false;
			} else {
				validateNormal(field);
				blocksValidation = true;
			}
    	}
    	
    	function validateError(field, message) {
    		$(field).parents(".form-group").addClass("has-error");
			$(field).parents(".form-group").removeClass("has-success");
			$(field).siblings(".inputMessage").show();
			$(field).siblings(".inputMessage").html(message);
			$(field).siblings(".inputMessage").addClass("inputMessageError");
			$(field).siblings(".inputMessage").removeClass("inputMessageSuccess");
    	}
    	function validateSuccess(field, message) {
    		$(field).parents(".form-group").addClass("has-success");
			$(field).parents(".form-group").removeClass("has-error");
			$(field).siblings(".inputMessage").show();
			$(field).siblings(".inputMessage").html(message);
    	}
    	function validateNormal(field) {
    		$(field).parents(".form-group").removeClass("has-success");
			$(field).parents(".form-group").removeClass("has-error");
			$(field).siblings(".inputMessage").hide();
    	}
    	//$('#registrationForm').validator();
    	function exitAlert() {
    		alert("Please close this browser window/tab to exit this site");
    	}
    	function agreeConsent() {
    		$('#consentModal').modal('toggle');
    		$('#welcomeDiv').toggle();
    		$('#registrationDiv').toggle();
    	}
    	function declineConsent() {
    		$('#consentModal').modal('toggle');
    		alert("Please close this browser window or tab to exit the study");
    	}
    	
    	function returningParticipant() {
    		$('#welcomeDiv').fadeToggle('fast', function() {
    			$('#returnDiv').fadeToggle();
    		});
    	}
    	function returningToWelcome() {
    		$('#returnDiv').fadeToggle('fast', function() {
    			$('#welcomeDiv').fadeToggle();
    		});
    	}
    	function registrationToWelcome() {
    		$('#registrationDiv').fadeToggle('fast', function() {
    			$('#welcomeDiv').fadeToggle();
    		});
    	}
    	
    	
        $(document).ready(function(){
            $("#consentContent").attr("src","consentUWO.jsp");

        })
        
        $(window).on('load resize', function(){
        	//alert($('#consentModal').find(".modal-content").prop("tagName"));
    	    $window = $(window);
    	    var height = $window.height()-180;
    	    //$('#consentModal').find(".modal-content").height(height);   
    	    $('#consentIframe').height(height);
    	    //document.getElementById("editcase").height = height;
    	    //document.getElementById('editcase').contentWindow.refreshEditorHeight();
    	});
    
    </script>
    
    <%
    request.getSession().removeAttribute("security");
    request.getSession().removeAttribute("error");
    request.getSession().removeAttribute("openLogin");
    request.getSession().removeAttribute("researchPart2");
    %>
  </body>
</html>