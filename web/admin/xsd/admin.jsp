<%-- 
    Document   : admin
    Created on : Jul 18, 2013, 12:12:01 PM
    Author     : apavel
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, org.imagequiz.model.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    List<IQExercise> exercises = (List<IQExercise>) request.getAttribute("exerciseList");
    %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Admin Page</title>
        <link rel="stylesheet" href="../css/case.css">
        <link rel="stylesheet" href="admin.css">
        <link rel="stylesheet" href="../jslib/jquery-ui-1.10.3/themes/base/jquery-ui.css">
        
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-ui.min.js"></script>
        <script src="../jslib/imagequiz.js"></script>
        <script src="../jslib/jquery-placeholder.min.js"></script>
        <script type="text/javascript" language="JavaScript">
        $(function() {
        	$("input").placeholder();
        	$("#exercisePropertiesDialogue").dialog({
        	    modal: true,
        	    draggable: false,
        	    resizable: false,
        	    position: ['center', 'center'],
        	    show: 'blind',
        	    hide: 'blind',
        	    autoOpen: false,
        	    width: 400,
        	    dialogClass: 'ui-dialog-osx',
        	    buttons: {
        	    	"Save": function() {
        	    		$("#exercisePropertiesForm").submit();
        	    		$(this).dialog("close");
        	        },
        	        "Cancel": function() {
        	            $(this).dialog("close");
        	        }
        	    }
        	});
        });
        function changeExerciseName(exerciseId, exerciseName) {
        	$("#exercisePropertiesDialogue" ).dialog("open");
        	$("#exerciseIdToChange").val(exerciseId);
        	$("#exerciseNameToChange").val(exerciseName);
        }
        </script>
    </head>
    <body class="admin">
        <div id="exercisePropertiesDialogue" style="display: none;" title="Edit Exercise Properties">
  			<form action="admin.do" method="POST" id="exercisePropertiesForm">
  				<input type="hidden" name="method" value="editExamProperties">
  				<input type="hidden" name="exerciseId" id="exerciseIdToChange" value="">
  				Type New Exercise Name: <input type="text" name="exerciseName" id="exerciseNameToChange">
  			</form>
		</div>
        <div class="boxContainer">
        	<div style=" width: 430px; margin-left: auto; margin-right: auto; float:left; margin-top: 20px; margin-left: 20px;">
        		<h3 style="margin-left: auto; margin-right: auto;">Administration Page</h3>
       			<div class="error"><c:out value="${sessionScope.error}"/></div>
       			<c:remove var="error" scope="session" />
        		<div class="success"><c:out value="${sessionScope.success}"/></div>
        		<c:remove var="success" scope="session" />
        		
        	</div>
	        	<div class="box1 box1Admindmin" style="width: 500px; margin-top: 15px; clear: left; float: left; margin-left: 20px;">
		    
		        <div class="box1heading box1headingAdmin">Case/Question Management</div>
		
				<div class="box1content" style="padding: 10px;">
				        <div class="boxBlue" style="width: 350px;">
					        <form action="admin.do?method=addExercise" method="POST" style="width: 100%;" onsubmit="return checkExerciseForm();">
					        	<input type="text" name="exercisename" class="disabled" id="exercisename" size="40" value="--Enter Case Set Name--">
					        	<input type="hidden" name="method" value="addExercise">
					        	<input type="submit" value="Add">
					        </form>
				        </div>
				        <table class="admintable" id="admintable" style="width: 450px; margin-top: 10px;">
				            <tr>
				            	<th>ID</th>
				                <th>Case Set Name</th>
				                <th>Case #</th>
				                <th colspan="3">Actions</th>
				            </tr>
				            <c:forEach var="exercise" varStatus="loopStatus" items="${requestScope.exerciseList}">
				                <tr class="<c:out value="${loopStatus.index % 2 == 0? 'even' : 'odd' }"/>">
				                    <td class="minimize" style="text-align: center;"><c:out value="${exercise.exerciseId}"/></td>
				                    <td class="maximize" style="text-align: left;"><c:out value="${exercise.exerciseName}"/> </td>
				                    <td class="minimize" style="text-align: center;"><c:out value="${fn:length(exercise.cases)}"/></td>
				                    <td class="minimize"><a href="admin.do?method=editExercise&exerciseid=<c:out value="${exercise.exerciseId}"/>">Cases</a></td>
				                    <td class="minimize">
				                    	<a href="#" onclick="changeExerciseName('${exercise.exerciseId}', '${exercise.exerciseName}')">Settings</a>
				                    </td>
				                    <td class="minimize">
				                    	<a href="admin.do?method=deleteExercise&id=<c:out value="${exercise.exerciseId}"/>" onclick="return confirm('Are you sure you want to archive <c:out value="${exercise.exerciseName}"/>.  It will be removed from the list.')">Archive</a>
				                    </td>
				                </tr>
				            </c:forEach>
				        </table>
	       			</div>
		        </div>
        
        <!-- ------------------------EXAMS management -->
        
		        <div class="box1 box1Admin" style="margin-top: 30px; clear: left; float: left; margin-left: 20px;">
				    <div class="box1heading box1headingAdmin">EXAM Management</div>
					<div class="box1content" style="padding: 10px;">        
		        
						<div class="boxBlue" style="width: 500px; text-align: left;">
					        <form action="exam.do?method=addExam" method="POST" style="width: 100%;" onsubmit="">
					        	<input type="text" name="examname" size="15" placeholder="--Exam Name--">
					        	<select name="exercise">
					        		<option value="">-- Case Set --</option>
					        		<c:forEach var="exercise" items="${requestScope.exerciseList }">
					        			<option value="<c:out value="${exercise.exerciseId }"/>"><c:out value="${exercise.exerciseName }"/></option>
					        		</c:forEach>
					        	</select>
					        	<select name="usergroup">
					        		<option value="">-- User Group --</option>
					        		<c:forEach var="group" items="${requestScope.userGroupList }">
					        			<option value="<c:out value="${group.groupId }"/>"><c:out value="${group.groupName }"/></option>
					        		</c:forEach>
					        	</select>
					        	<input type="hidden" name="method" value="addExam">
					        	<input type="submit" value="Add Exam">
					        </form>
				        </div>
		        
		        
				        <table class="admintable" id="admintable" style="width: 500px; margin-top: 10px;">
				            <tr>
				            	<th>ID</th>
				                <th>Exam Name</th>
				                <th>Case Set</th>
				                <th>User Group</th>
				                <th>#Started</th>
				                <th>#Complete</th>
				                <th colspan="4">Actions</th>
				            </tr>
				            <c:forEach var="exam" varStatus="loopStatus" items="${requestScope.examList}">
				                <tr class="<c:if test="${exam.active}">active</c:if><c:if test="${not exam.active}">inactive</c:if>">
				                    <td class="minimize" style="text-align: center;"><c:out value="${exam.examId}"/></td>
				                    <td class="maximize" style="text-align: left;" nowrap><c:out value="${exam.examName}"/> </td>
				                    <td class="minimize" style="text-align: center;"><c:out value="${exam.exercise.exerciseName}"/></td>
				                    <td class="minimize"><c:out value="${exam.userGroup.groupName}"/></td>
				                    
				                    <td class="minimize"><c:out value="${fn:length(exam.userQuizes)}"/></td>
				                    <c:set var="quizcounter" value="${0}"/>
				                    <c:forEach var="equiz" items="${exam.userQuizes}">
				                    	<c:if test="${equiz.completed}">
				                    		<c:set var="quizcounter" value="${quizcounter + 1 }"/>
				                    	</c:if>
				                    </c:forEach>
				                    <td class="minimize">${quizcounter}</td>
				                    <td class="hasMenuButtons">
				                    	<c:if test="${exam.active}">
				                    	 <div class="menu-button menu-button-wrapper" style="min-width: 100px;">(Open)<a href="exam.do?method=openCloseExam&id=<c:out value="${exam.examId}"/>&action=close">Close Exam</a></div>
				                    	</c:if>
				                    	<c:if test="${not exam.active }"> 
				                    	 <div class="menu-button menu-button-wrapper" style="min-width: 100px;">(Closed)<a href="exam.do?method=openCloseExam&id=<c:out value="${exam.examId}"/>&action=open">Open Exam</a></div>
				                    	</c:if>
				                    </td>
				                    <td>
				                    
				                    <ul id="nav11">
						                <li class="menu-button"><a href="#">Actions</a>
						                    <div class="subs">
						                    		<!--  commented out stuff is to have a more extensive menu (i.e. second column) -->
						                        <div><!-- class="wrp2"-->
						                            <ul>
						                                <li><h3>Exam Actions</h3>
						                                    <ul>
						                                        <li>			    
						                                        	<a href="#" onclick="popitup('exam.do?method=getLoginCodes&examid=<c:out value="${exam.examId}"/>', 700, 600);">Login Codes</a>
									    						</li>
						                                        <li>
						                                        	<a href="exam.do?method=deleteExam&id=<c:out value="${exam.examId}"/>" onclick="return confirm('Are you sure you want to archive <c:out value="${exam.examId}"/>.  It will no longer be accessible')">Archive</a>
																</li>
																<li>
						                                        	<a href="exam.do?method=clearAnswers&id=<c:out value="${exam.examId}"/>" onclick="return confirm('Are you sure you want to delete answers to this exam?')">Clear Answers</a>
																</li>
																<li>
																	<%--
																	<a href="exam.do?method=toggleShowAnswers&id=<c:out value="${exam.examId}"/>">
																	<c:if test="${exam.showAnswers == true}">
																		<span class="menuSelected">Show Answers</span> / Hide Answers
																	</c:if>
																	<c:if test="${exam.showAnswers == false}">
																		Show Answers / <span class="menuSelected">Hide Answers</span>
																	</c:if>
																	</a> --%>
																</li>
															</ul>
														</li>
														<li><h3>Exam Settings</h3>
																<ul>
																	<li>
																		Exam Mode: <select name="mode" onchange="changeMode(${exam.examId}, this)">
																			<option value="">--Select--</option>
																			<c:forEach var="mode" items="${exam.possible_exam_modes}">
																				<option <c:if test="${exam.examMode == mode}">selected </c:if>value="${mode}">${mode.visual}</option>
																			</c:forEach>
																		</select>
																	</li>
																</ul>
						                                </li>
						                           </ul>
						                        </div>
						                    </div>
						                </li>
						            </ul>

				                    </td>
				                    <td>
				                    
				                    				                    <ul id="nav11">
						                <li class="menu-button"><a href="#">Results</a>
						                    <div class="subs">
						                    		<!--  commented out stuff is to have a more extensive menu (i.e. second column) -->
						                        <div><!-- class="wrp2"-->
						                            <ul>
						                                <li><h3>Results</h3>
						                                    <ul>
							                                    <li>
						                                        		<a href="results.do?method=allAnswersColored&examid=${exam.examId}" style="float:left;">All Answers By User (Graded) [Excel]</a>
						                                    	</li>
						                                        <li>
						                                        		<a href="results.do?method=allAnswers&examid=${exam.examId}" style="float:left;">All Answers By User (Raw) [Excel]</a>
						                                        </li>
						                                        <li>
						                                        		<!-- a href="#" onclick="popitup('results.do?method=resultsByImageDiagnosis&examid=${exam.examId}', 800, 600)" style="float:left;">Results by Image & Diagnosis [HTML]</a-->
						                                        		<a href="results.do?method=resultsByImageDiagnosis&examid=${exam.examId}" style="float:left;">Results by Image & Diagnosis [HTML]</a>
						                                        </li>
						                                        <li>
						                                        		<!-- a href="#" onclick="popitup('results.do?method=resultsByImageDiagnosis&examid=${exam.examId}', 800, 600)" style="float:left;">Results by Image & Diagnosis [HTML]</a-->
						                                        		<a href="results.do?method=resultsByImageDiagnosis&examid=${exam.examId}&viewer=V2" style="float:left;">Results by Image & Diagnosis V2 [HTML]</a>
						                                        </li>
						                                        <li>
						                                        		<a href="results.do?method=answersByUser&examid=${exam.examId}&transposed=1" style="float:left;">Answers by User (test)</a>
						                                    	</li>
						                                    </ul>
						                                </li>
						                            </ul>
						                        </div>
						                    </div>
						                </li>
						            </ul>
				                    
				                    </td>

				                </tr>
				            </c:forEach>
				        </table>
		        
		        	</div>
		        </div>
        	
        
		        <div class="box1 box1Admin" style="width: 430px; margin-top: 30px; clear: left; float: left; margin-left: 20px; margin-bottom: 200px;">
						    <div class="box1heading box1headingAdmin">Navigation</div>
							<div class="box1content" style="padding: 10px;"> 
		        				<input type="button" onclick="document.location='images.do?method=list'" value="Manage All Images">
		        				<input type="button" onclick="document.location='admin.do?method=userAdmin'" value="Manage Users">
		        				<input type="button" onclick="document.location='admin.do?method=viewReferences'" value="Manage References">
		        				<input type="button" onclick="document.location='../user.do?method=logout'" value="Logout">
		        			</div>
		        			</div>
		        </div>
		        
        <!--  FANCY JAVASCRIPT -->
        <script type="text/javascript" language="JavaScript">
	        $("#exercisename")
	        .focus(function() {
	              if (this.value === this.defaultValue) {
	                  this.value = '';
	                  $(this).removeClass("disabled");
	              }
	        })
	        .blur(function() {
	              if (this.value === '') {
	                  this.value = this.defaultValue;
	                  $(this).addClass("disabled");
	              }
	      });
	        function checkExerciseForm() {
	        	if ($("#exercisename").val() == $("#exercisename").prop("defaultValue") || $("#exercisename").val() == "") {
	        		alert("Exercise name cannot be empty!");
	        		return false;
	        	}
	        	return true;
	        }
	        
	        function changeMode(examId, ele) {
            	document.location = 'exam.do?method=setExamMode&id=' + examId + '&exammode=' + $(ele).val();
            }
	        
	        //admin hover table
	        $('#admintable tr').hover(function() {
	        	$(this).css("background-color", "#ECCEF5");
	        }, function() {
	        	$(this).css("background-color", "");
	        });

		//MENUS --------
	        jQuery(window).load(function() {
	            $("#nav11 > li > a").click(function (e) { // binding onclick
	            	e.preventDefault();
	                if ($(this).parent().hasClass('selected')) {
	                    $("#nav11 .selected div div").slideUp(100); // hiding popups
	                    $("#nav11 .selected").removeClass("selected");
	                } else {
	                    $("#nav11 .selected div div").slideUp(100); // hiding popups
	                    $("#nav11 .selected").removeClass("selected");

	                    if ($(this).next(".subs").length) {
	                        $(this).parent().addClass("selected"); // display popup
	                        $(this).next(".subs").children().slideDown(200);
	                    }
	                }
	                e.stopPropagation();
	            }); 

	            $(".subs").mouseleave(function () { // binding onclick to body
	                $("#nav11 .selected div div").slideUp(100); // hiding popups
	                $("#nav11 .selected").removeClass("selected");
	            }); 
	            

	        });
	        //---MENUS above----
        </script>
    </body>
</html>
