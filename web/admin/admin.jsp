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
        <link rel="stylesheet" href="css/admin.css?v=1">
        <link rel="stylesheet" href="../jslib/jquery-ui-1.10.3/themes/base/jquery-ui.css">
        <link rel="stylesheet" href="../css/lib/bootstrap.paper.min.css">
        
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        
        
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-ui.min.js"></script>
        <script src="../jslib/bootstrap.min.js"></script>
        <script src="../jslib/imagequiz.js"></script>
        <script src="../jslib/moment.min.js"></script>		

		<script src="js/vue.js"></script>
		
		
		
        <script src="../jslib/imagequiz.js"></script>

        <script type="text/javascript" language="JavaScript">
        $(function() {
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
        </script>
    </head>
<body class="admin">
	<div class="pageTitle">Case Builder / Administration Page</div>
  	<div class="container" id="app">
    	
    	
    	
	    <div class="error"><c:out value="${sessionScope.error}"/></div>
	       			<c:remove var="error" scope="session" />
	    <div class="success"><c:out value="${sessionScope.success}"/></div>
	        		<c:remove var="success" scope="session" />
	    	
	    <div class="panel panel-primary adminBox" id="folderDiv" style="width: 600px;">
		  	<div class="panel-heading text-center">
		    		<h2 class="panel-title">Case Folders</h2>
		  	</div>
		  	<div class="panel-body">
		  		<c:if test="${security.isManagerUsers()}">
		  		<div>
  					<form action="admin.do?method=addExercise" method="POST" style="width: 100%;" onsubmit="return checkExerciseForm();">
			        	<input type="text" name="exercisename" id="exercisename" size="40" placeholder="--Enter Folder Name--" style="text-align: center;">
			        	<input type="hidden" name="method" value="addExercise">
			        	<input type="submit" class="btn btn-default btn-sm" style="margin-left: 10px;" value="Add Folder">
			        </form>
				</div>
				</c:if>
		  		
		  		<table class="adminTable hoverHighlight" id="admintable" style="width: auto;">
				            <tr>
				            	<th>ID</th>
				                <th>Folder Name</th>
				                <th>Case #</th>
				                <th colspan="3">Actions</th>
				            </tr>
				            <c:forEach var="exercise" varStatus="loopStatus" items="${requestScope.exerciseList}">
				                <tr class="<c:out value="${loopStatus.index % 2 == 0? 'even' : 'odd' }"/> pointer" @click="document.location='admin.do?method=editExercise&exerciseid=<c:out value="${exercise.exerciseId}"/>'">
				                    <td class="number" style="color: #bfbfbf;"><c:out value="${exercise.exerciseId}"/></td>
				                    <td class="maximize" style="text-align: left; maxwidth: 300px;"><c:out value="${exercise.exerciseName}"/> </td>
				                    <td class="number"><c:out value="${fn:length(exercise.activeCases)}"/></td>
				                    <td class="actions">
				                    	<a href="admin.do?method=editExercise&exerciseid=<c:out value="${exercise.exerciseId}"/>" class="btn btn-default btn-xs actionButton">Open</a></td>
				                    
				                    <td class="actions">
				                    <c:if test="${security.isManagerUsers()}">
				                    	<a href="#" class="btn btn-default btn-xs actionButton" @click.stop="exerciseSettings(${exercise.exerciseId}, '${exercise.exerciseName}')">Settings</a>
				                    </c:if>
				                    </td>
				                    <td class="actions" style="padding-right: 0px;">
				                    <c:if test="${security.isManagerUsers()}">
				                    	<button @click.stop="archiveExercise(<c:out value="${exercise.exerciseId}"/>, '<c:out value="${exercise.exerciseName}"/>')" class="btn btn-default btn-xs actionButton">Archive</a>
				                    </c:if>
				                    </td>
				                    
				                </tr>
				            </c:forEach>
				</table>
	  		
	  		
	  	</div>
  	</div>
    	
    	
        
       
        	
        	

        <!-- ------------------------EXAMS management -->
    <c:if test="${security.isManagerExams()}">
    <div class="panel panel-primary adminBox" id="folderDiv" style="width: 1100px;">
		<div class="panel-heading text-center">
			<h2 class="panel-title">Assessment Management</h2>
		</div>
		<div class="panel-body">
			<form action="exam.do?method=addExam" method="POST" style="width: 100%;" onsubmit="">
					<input type="text" name="examname" size="20" placeholder="-- Exam Name --">
					<select name="exercise" style="margin-left: 10px;">
						<option value="">-- Folder --</option>
						<c:forEach var="exercise" items="${requestScope.exerciseList }">
						        <option value="<c:out value="${exercise.exerciseId }"/>"><c:out value="${exercise.exerciseName }"/></option>
						</c:forEach>
					</select>
					<select name="usergroup" style="margin-left: 10px;">
						<option value="">-- User Group --</option>
						<c:forEach var="group" items="${requestScope.userGroupList }">
						<option value="<c:out value="${group.groupId }"/>"><c:out value="${group.groupName }"/></option>
						</c:forEach>
					</select>
					<input type="hidden" name="method" value="addExam">
					<input type="submit" class="btn btn-default btn-sm btn-align" value="Add Assessment" style="margin-left: 10px;">
			</form>
		</div>
		        
		        
				        <table class="adminTable" id="admintable2" style="width: 100%;">
				            <tr>
				            	<th>ID</th>
				                <th>Exam Name</th>
				                <th>Folder</th>
				                <th>User Group</th>
				                <th>#Started</th>
				                <th>#Complete</th>
				                <th colspan="4">Actions</th>
				            </tr>
				            <c:forEach var="exam" varStatus="loopStatus" items="${requestScope.examList}">
				                <tr class="<c:if test="${exam.active}">active</c:if><c:if test="${not exam.active}">inactive</c:if>">
				                    <td class="number" style="text-align: center;"><c:out value="${exam.examId}"/></td>
				                    <td class="maximize" style="text-align: left;" nowrap><c:out value="${exam.examName}"/> </td>
				                    <td class="number" style="text-align: center;"><c:out value="${exam.exercise.exerciseName}"/></td>
				                    <td class="number"><c:out value="${exam.userGroup.groupName}"/></td>
				                    
				                    <c:set var="counter" value="${requestScope.examCounts.get(exam.getExamId().toString())}"/>
				                    <td class="number"><c:out value="${counter[1]}" default="0"/></td>
				                    <td class="number"><c:out value="${counter[2]}" default="0"/></td>

				                    <td class="actions">
				                    	<c:if test="${exam.active}">
				                    	 <div class="menu-button menu-button-wrapper" style="min-width: 100px;">(Open) <a href="exam.do?method=openCloseExam&id=<c:out value="${exam.examId}"/>&action=close" class="btn btn-default btn-xs actionButton">Close Exam</a></div>
				                    	</c:if>
				                    	<c:if test="${not exam.active }"> 
				                    	 <div class="menu-button menu-button-wrapper" style="min-width: 100px;">(Closed) <a href="exam.do?method=openCloseExam&id=<c:out value="${exam.examId}"/>&action=open" class="btn btn-default btn-xs actionButton">Open Exam</a></div>
				                    	</c:if>
				                    </td>
				                    <td class="actions">
				                    	<div class="btn-group">
							  				<a href="#" class="btn btn-default btn-xs dropdown-toggle actionButton" data-toggle="dropdown">Actions <span class="caret"></span></a>
							  				<ul class="dropdown-menu dropdown-menu-center">
							    				<li>
							    					<a href="#" onclick="popitup('exam.do?method=getLoginCodes&examid=<c:out value="${exam.examId}"/>', 700, 600);">Login Codes</a>
							    				</li>
							    				<li>
							    					<a href="exam.do?method=deleteExam&id=<c:out value="${exam.examId}"/>" onclick="return confirm('Are you sure you want to archive <c:out value="${exam.examId}"/>.  It will no longer be accessible')">Archive</a>
							    				</li>
							    				<li>
							    					<a href="exam.do?method=clearAnswers&id=<c:out value="${exam.examId}"/>" onclick="return confirm('Are you sure you want to delete answers to this exam?')">Clear Answers</a>
							    				</li>
							    				<li class="divider"></li>
							    				<li>
							    					<a class="btn btn-link" style="text-align:left;" onclick="app.editExam(${exam.examId }, '${exam.examName }')">Edit Options</a>
							    				</li>
							    				
							  				</ul>
										</div>
										
				                    </td>
				                    <td>
				                    	<div class="btn-group">
							  				<a href="#" class="btn btn-default btn-xs dropdown-toggle actionButton" data-toggle="dropdown">Reports <span class="caret"></span></a>
							  				<ul class="dropdown-menu dropdown-menu-center" >
							  					<li>
							  						<div style="text-align: center; color: #e27b7b; font-size: 10px;">WARNING: these reports may take a while</div>
							  					</li>
							  					<li>
						                        	<a href="results.do?method=questionStatistics&examid=${exam.examId}" target="_blank" style="float:left; width: 100%;">MCQ Question Statistics [HTML]</a>
						                    	</li>
						                    	<li>
						                        	<!-- a href="#" onclick="popitup('results.do?method=resultsByImageDiagnosis&examid=${exam.examId}', 800, 600)" style="float:left;">Results by Image & Diagnosis [HTML]</a-->
						                        	<a href="results.do?method=resultsByImageDiagnosis&examid=${exam.examId}&viewer=V2" target="_blank" style="float:left; width: 100%;">SG Question Statistics [HTML]</a>
						                        </li>
<%-- 							  					<li>
						                        	<a href="results.do?method=allAnswersColored2&examid=${exam.examId}" style="float:left; width: 100%;">Answers By User [Excel]</a>
						                    	</li> --%>

<%-- 						                        <li>
						                        	<!-- a href="#" onclick="popitup('results.do?method=resultsByImageDiagnosis&examid=${exam.examId}', 800, 600)" style="float:left;">Results by Image & Diagnosis [HTML]</a-->
						                        	<a href="results.do?method=resultsByImageDiagnosis&examid=${exam.examId}" style="float:left; color: lightgrey; width: 100%;">Results by Image & Diagnosis [HTML] (deprecated)</a>
						                        </li> --%>
<%-- 						                        <li>
						                        	<a href="results.do?method=answersByUser&examid=${exam.examId}&transposed=1" style="float:left; color: lightgrey width: 100%;" >Answers by User (deprecated)</a>
						                        </li> --%>
							    			</ul>
							    		</div>
							    	</td>
				                </tr>
				            </c:forEach>
				        </table>
		        
		        </div>
		        
		</c:if>
		        
		        <!--  SETTINGS---------------------- -->
		        
		<c:if test="${security.isManagerSite()}">
		<div class="panel panel-primary adminBox" id="folderDiv" style="width: 900px;">
			<div class="panel-heading text-center">
				<h2 class="panel-title">Settings</h2>
			</div>
			
			<div class="panel-body">
				<form action="admin.do?method=addSetting" method="POST">
				<table>
				<c:forEach var="setting" items="${requestScope.settings }" varStatus="loop">
					<tr>
						<td><input type="text" id="settingName${loop.index }" name="settingName" readonly value="${setting.name}"></td>
						<td><input type="text" id="settingValue${loop.index }" name="${setting.name}" value="${setting.value}"></td>
						<td><input type="button" class="btn btn-default btn-xs actionButton" 
									onclick="document.location='admin.do?method=updateSetting&newName=' + $('#settingName${loop.index}').val() + '&newValue=' + $('#settingValue${loop.index}').val()" value="Update">
							<input type="button" class="btn btn-default btn-xs actionButton" 
									onclick="document.location='admin.do?method=deleteSetting&newName=' + $('#settingName${loop.index}').val()" value="Delete">
						</td>
					</tr>
				</c:forEach>
				
					<tr>
						<td><input type="text" name="newName" placeholder="name" size="20"></td>
						<td><input type="text" name="newValue" placeholder="value" size="20"></td>
						<td><input type="submit" class="btn btn-default btn-xs actionButton" value="Add Setting"></td>
					</tr>
				
				</table>
				</form>
			</div>
		</div>
		</c:if>
        	
        <div class="panel panel-primary adminBox" id="folderDiv" style="display: inline-block;">
			<div class="panel-heading text-center">
				<h2 class="panel-title">Tools</h2>
			</div>
			<div class="panel-body text-center">
				<c:if test="${security.isManagerUsers()}">
								<input type="button" class="btn btn-primary" onclick="document.location='admin.do?method=userAdmin'" value="Manage Users">
				</c:if>
				<c:if test="${security.isManagerSite()}">
		        				<input type="button" class="btn btn-default" onclick="document.location='images.do?method=list'" value="See All Images">
		        				<input type="button" class="btn btn-default"  onclick="document.location='admin.do?method=viewReferences'" value="Manage References">
		        				<input type="button" class="btn btn-default"  onclick="document.location='admin.do?method=sessions'" value="View Sessions">
		        </c:if>
		        				<input type="button" class="btn btnGrey"  onclick="document.location='../user.do?method=logout'" value="Logout">

		    </div>
		</div>
		
		
		
		<div class="modal fade" tabindex="-1" id="editExamModal" role="dialog">
		  <div class="modal-dialog modal-lg" role="document">
		    <div class="modal-content">
		      <div class="modal-header">
		        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
		        <h4 class="modal-title">Exam Options for: <span class="text-danger">{{exam.examName}}</span></h4>
		      </div>
		      <div class="modal-body">
		        <table class="simpletable">
		        	<tr class="importantRow">
			        	<th>Exam Name</th>
			        	<td>
					        <input class="form-control" v-model="exam.examName"/>
					    </td>
					    <td class="examOptionInstructions">If you change this, refresh admin screen to see updated name</td>
			        </tr>
			        <tr>
			        	<th>Exam Mode</th>
			        	<td>
					        <select class="form-control" v-model="exam.options.mode">
								  	<option value="">--Select--</option>
								  	<c:forEach var="mode" items="${IQExam.possible_exam_modes}">
										<option value="${mode}">${mode.visual}</option>
									</c:forEach>
					        </select>
					    </td>
					    <td class="examOptionInstructions">Exam - Questions only<br/>Practice Test - Question-Answer</td>
			        </tr>
			        <tr>
			        	<th>Exam Order</th>
			        	<td>
					        <select class="form-control" v-model="exam.options.randomOrder">
					        	<option value="true">Random</option>
					        	<option value="false">Ordered</option>
					        </select>
					    </td>
					    <td width="180px"> </td>
			        </tr>
			        <tr>
			        	<th>Show final grade at end?</th>
			        	<td>
					        <select class="form-control" v-model="exam.options.showGrade">
					        	<option value="true">Show Grades</option>
					        	<option value="false">Hide Grades</option>
					        </select>
					    </td>
					    <td> </td>
			        </tr>
			        <tr>
			        	<th>Show question answers?</th>
			        	<td>
					        <select class="form-control" v-model="exam.options.allowReview">
					        	<option value="show">Show Answers</option>
					        	<option value="showIfPass">Show if Pass</option>
					        	<option value="hide">Hide Answers</option>
					        </select>
					    </td>
					    <td> </td>
			        </tr>
			        <tr>
			        	<th>Achievement?</th>
			        	<td>
					        <select class="form-control" v-model="exam.options.achievement" style="text-align: center; text-align-last: center; width: 200px;">
					        	<option value="">N/A</option>
					        	<option v-for="o in achievementOptions" :value="o.achievementId">{{o.achievementShort}} Level {{o.level}}</option>
					        </select>
					    </td>
					    <td> </td>
			        </tr>
			        <tr>
			        	<th>Pass grade %</th>
			        	<td>
					        <input type="number" v-model.number="exam.options.passGrade">
					    </td>
					    <td> </td>
			        </tr>
			        <tr>
			        	<th>Max Questions</th>
			        	<td>
					        <input type="number" v-model.number="exam.options.maxQuestions"><br/>
					        <sup class="text-muted">(Leave blank or 0 for unlimited)</sup>
					    </td>
					    <td> </td>
			        </tr>
			        <tr>
			        	<th>Max Time (min)</th>
			        	<td>
					        <input type="number" v-model.number="exam.options.maxTimeMins"><br/>
					        <sup class="text-muted">(Leave blank for unlimited)</sup>
					    </td>
					    <td> </td>
			        </tr>
			        <tr>
			        	<th>Delay if Fail (hrs)</th>
			        	<td>
					        <input type="number" v-model.number="exam.options.delayIfFailHrs"><br/>
					        <sup class="text-muted">(Leave blank or 0 for no delay)</sup>
					    </td>
					    <td> </td>
			        </tr>
			        <tr>
			        	<th>Post-Exam Success Message</th>
			        	<td colspan="2">
					        <textarea class="form-control" v-model="exam.options.messagePostSuccess" rows="3" id="textArea" style="width: 100%;"></textarea>
					    </td>
			        </tr>
			        <tr>
			        	<th>Post-Exam Fail Message</th>
			        	<td colspan="2">
					        <textarea class="form-control" v-model="exam.options.messagePostFail" rows="3" id="textArea" style="width: 100%;"></textarea>
					    </td>
			        </tr>
		        </table>

		        
		        
		      </div>
		      <div class="modal-footer">
		        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		        <button type="button" class="btn btn-primary" @click="saveExamOptions()">Save changes</button>
		      </div>
		    </div><!-- /.modal-content -->
		  </div><!-- /.modal-dialog -->
		</div><!-- /.modal -->
		
		
		<div class="modal fade" tabindex="-1" id="editExerciseModal" role="dialog">
		  <div class="modal-dialog modal-lg" role="document">
		    <div class="modal-content">
		      <div class="modal-header">
		        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
		        <h4 class="modal-title">Folder Options: <span class="text-danger">{{exam.examName}}</span></h4>
		      </div>
		      <div class="modal-body row">
		      	<div class="col-xs-12 row text-center">
		        		<input class="col-centered col-xs-6" type="text" size="20" v-model="exerciseEdit.exerciseName">
		        		<button @click="exerciseChangeName()" class="btn btn-xs btn-default">Rename</button>
		       	</div>
		       	
		        <div class="col-centered col-xs-10" style="margin-top: 50px; border-top: 0px solid blue">
		        	<div class="form-group">
  						<label>Add Permissions for specific users</label>
				        <button v-if="addUser" class="btn no-shadow btn-default btn-xs" style="background-color: aliceblue;">
									({{addUser.userId}}) {{addUser.firstName}} {{addUser.lastName}} [{{addUser.email}}]
						</button>
						<input v-model="userSearch" v-if="!addUser" class="form-control" placeholder="Start Typing to Search User..." size="40">
						<div class="authorSearchWindow" v-if="!addUser && userSearchResult">
						<div v-for="option in userSearchResult" :key="option.userid" @click="addUser = option">
							({{option.userId}}) {{option.firstName}} {{option.lastName}} {{"[" + option.username + "]"}} ({{option.email}})
						</div>
						<div v-if="userSearchResult.length == 0"><i>No Search Results</i></div>
						</div>
						<input type="button" v-if="addUser" class="btn btn-xs btn-default" @click="addPermission()" value="Add">
						<div style="background-color: #e7f5ff; padding: 5px; border-radius: 5px; margin-top: 10px;">
							<table style="margin: 0 auto; border-spacing: 15px 0;">
								<tr v-for="permission in exercisePermissions" :key="permission.permissionId">
									<td>{{permission.user.firstName}} {{permission.user.lastName}} &lt;{{permission.user.email}}&gt;</td>
									<td><button @click="deletePermission(permission.permissionId)" class="btn btn-xs btn-default">Delete</button>
								</tr>
							</table>
							<div v-if="!exercisePermissions || exercisePermissions.length === 0" style="font-style: italic; color: grey; text-align: center;">No Permissions Set</div>
						</div>
					</div>
				</div>
				
		      </div>
		      <div class="modal-footer">
		        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		      </div>
		    </div><!-- /.modal-content -->
		  </div><!-- /.modal-dialog -->
		</div><!-- /.modal -->
	</div>
	
	</body>
	
	
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
	        function changeOrder(examId, ele) {
            	document.location = 'exam.do?method=setExamOrder&id=' + examId + '&randomorder=' + $(ele).val();
            }
	        function changeAllowReview(examId, ele) {
            	document.location = 'exam.do?method=setExamAllowReview&id=' + examId + '&allowReview=' + $(ele).val();
            }
	        function changeShowGrade(examId, ele) {
            	document.location = 'exam.do?method=setExamShowGrade&id=' + examId + '&showGrade=' + $(ele).val();
            }
	        $(function() {
	        	$('.dropdown-menu select').click(function (e) {
	        	    e.stopPropagation();
	        	  });

	        })
	        
	        var app = new Vue({
				el: '#app',
				data: {
					exerciseEdit: {},
					exercisePermissions: [],
					userSearchResult: null,
					userSearch: null,
					addUser: null,
			    	exam: {
			    		examId: null,
			    		examName: '',
			    		options: {
					    	mode: '',
					    	randomOrder: true,
					    	showGrade: true,
					    	allowReview: true,
					    	achievement: '',
					    	passGrade: 80,
					    	maxQuestions: 0,
					    	maxTimeMins: 0,
					    	messagePostSuccess: 'You have successfully completed this quiz! Click \'quit\' at the bottom of this page to continue.',
					    	messagePostFail: 'You were not successful in passing this assessment.  You must wait 24 hrs before retrying.  In the meantime, please review the content.  Press \'quit\' at the bottom of this page to continue.'
				    		}
			    		},
			    	status: "LOADING...",
			    	achievementOptions: [	
			    			
			    		]
			    	},
			    	watch: {
			    		userSearch: function(val) {
			    			if (val && val.length > 2) this.updateUserSearch()
			    		}
			    	},
	         	methods: {
	        	  editExam: function(examId, examName) {
	        		  		// console.log(this.exam);
	     					this.exam.examId = examId;  
	     					this.exam.examName = examName;
	     					var self = this;
	     					$.get(
		        		        "../admin/exam.do",
		        		        {
		        		            method: 'getExamOptionsAjax',
		        		            examid: self.exam.examId
		        		        }

		        		    ).fail(function(xhr, status) {
		        		    	alert("Could not make change: '" + xhr.responseText + "'");
		        		    }).done(function(data) {
		        		    	console.log(data);
		        		    	data = JSON.parse(data);
		        		    	if (data.options && data.options != '')
		        		    		Object.assign(self.exam.options, JSON.parse(data.options));
		        		    	if (data.achievements && data.achievements != '')
		        		    		self.achievementOptions = data.achievements;
		        		    	console.log(self.achievementOptions);
		        		    	$('#editExamModal').modal('show');
		        		    })
	        	  },
	        	  archiveExercise(exerciseId, exerciseName) {
	        		  if (confirm('Are you sure you want to archive \'' + exerciseName + '\'?')) 
	        		  	document.location='admin.do?method=archiveExercise&id='+exerciseId
	        	  },
	        	  saveExamOptions() {
	        		  if (!this.exam.examId) {
	        			  alert("No exam selected");
	        			  return;
	        		  }
	        		  var self = this;
	        			$.post(
	        		        "../admin/exam.do",
	        		        {
	        		            method: 'setExamOptionsAjax',
	        		            examid: this.exam.examId,
	        		            examname: this.exam.examName,
	        		            options: JSON.stringify(this.exam.options)
	        		        }

	        		    ).fail(function(xhr, status) {
	        		    	alert("Could not make change: '" + xhr.responseText + "'");
	        		    }).done(function(data) {
	        		    	//if (confirm("Exam updated! Do you want to reload the page to see changes?")) {
	        		    	//	location.reload();
	        		    	//}
	        		    	alert("Exam Updated!");
	        		    	console.log(self.exam.options);
	        		    	$('#editExamModal').modal('hide');
	        		    })
	        	  },
	        	  getExerciseData(exerciseid) {
	        		  const self = this
	        			$.get(
		        		        "../admin/admin.do",
		        		        {
		        		            method: 'exerciseAjax',
		        		            action: 'get',
		        		            exerciseid
		        		        }

		        		    ).fail(function(xhr, status) {
		        		    	alert("Could not make change: '" + xhr.responseText + "'");
		        		    }).done(function(data) {
		        		    	const r = JSON.parse(data)
		        		    	self.exerciseEdit = r.exercise
		        		    	self.exercisePermissions = r.permissions
		        		    	console.log(self.exerciseEdit.exerciseName)
		        		    })
	        	  },
	        	  exerciseSettings (exerciseid, exercisename) {
	        		  this.$set(this.exerciseEdit, 'exercisename', exercisename)
	        		  this.$set(this.exerciseEdit, 'exerciseid', exerciseid)
	        		  $('#editExerciseModal').modal('show');
	        		  this.getExerciseData(exerciseid)
	        		  console.log(this.exerciseEdit)
	        	  },
	        	  exerciseChangeName() {
	        		  $.post(
		        		        "../admin/admin.do",
		        		        {
		        		            method: 'exerciseAjax',
		        		            action: 'rename',
		        		            exerciseid: this.exerciseEdit.exerciseId,
		        		            exercisename: this.exerciseEdit.exerciseName
		        		        }

		        		    ).fail(function(xhr, status) {
		        		    	alert("Could not make change: '" + xhr.responseText + "'");
		        		    }).done(function(data) {
		        		    	const r = JSON.parse(data)
		        		    	if (r) location.reload();
		        		    })
	        	  },
	        	  debounce(func, delay) {
	    		      let debounceTimer;
	    		      return function() {
	    		        const context = this;
	    		        const args = arguments;
	    		        clearTimeout(debounceTimer);
	    		        debounceTimer = setTimeout(() => func.apply(context, args), delay);
	    		      };
	    		  },
	    		  updateUserSearch: function () {
	    				$.ajax({
	    					url: "../admin/admin.do",
	    			        data: {
	    			            method: "authorsAjax",
	    			            action: "search",
	    			            calltype: "ajax",
	    			            query: this.userSearch
	    			        },
	    			        type: "POST",
	    			        dataType: "html"
	    				}).done(data => {
	    					this.userSearchResult = JSON.parse(data);
	    					// console.log(this.userSearchResult);
	    				}).fail(function (xhr) {
	    					alert("ERROR: " + xhr.responseText);
	    				});
	    			},
	    			addPermission() {
	    				const self = this
	    				$.ajax({
	    					url: "../admin/admin.do",
	    			        data: {
	    			            method: "permissionAjax",
	    			            action: "add",
	    			            calltype: "ajax",
	    			            userid: this.addUser.userId,
	    			            exerciseid: this.exerciseEdit.exerciseId
	    			        },
	    			        type: "POST",
	    			        dataType: "html"
	    				}).done(data => {
	    					this.exercisePermissions.push(JSON.parse(data))
	    					this.addUser = null
	    					this.userSearch = null
	    					this.userSearchResult = null
	    				}).fail(function (xhr) {
	    					alert("ERROR: " + xhr.responseText);
	    				});
	    			},
	    			deletePermission(permissionid) {
	    				const self = this
	    				$.ajax({
	    					url: "../admin/admin.do",
	    			        data: {
	    			            method: "permissionAjax",
	    			            action: "delete",
	    			            calltype: "ajax",
	    			            permissionid
	    			        },
	    			        type: "POST",
	    			        dataType: "html"
	    				}).done(data => {
	    					if (JSON.parse(data).success) {
	    						self.exercisePermissions.splice(self.exercisePermissions.findIndex(p=>p.permissionId===permissionid), 1)
	    					}
	    				}).fail(function (xhr) {
	    					alert("ERROR: " + xhr.responseText);
	    				});
	    			}
	          	},
	          	mounted() {
	        		this.updateUserSearch = this.debounce(this.updateUserSearch, 500);
	        	}
			})
	        


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
        <style lang="text/css">
        .form-group{
		  padding:5px;
		  border-top:2px solid lightgray;
		  margin:10px;
		}
		.form-group>label{
		  position:absolute;
		  top:-12px;
		  left: 50%;
		  background-color:white;
		  padding: 0 10px;
		  transform: translate(-50%, 0%);
		  font-size: 12px;
		  font-family: Montserrat;
		  text-transform: uppercase;
		}
		
		.form-group>input{
		  border:none;
		}
        </style>
</html>
