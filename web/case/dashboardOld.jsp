<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.*, java.text.*"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
    <head>
        <title>ECG Quiz</title>
        <link rel="stylesheet" type="text/css" href="main.css"/>
       	<link href="../jslib/tagit/jquery.tagit.css" rel="stylesheet" type="text/css">
    	<link href="../jslib/tagit/tagit.ui-zendesk.css" rel="stylesheet" type="text/css">
    	<link href="../css/case.css" rel="stylesheet" type="text/css">

		<script type="text/javascript" src="../jslib/jquery-1.10.1.min.js"></script>
		<script type="text/javascript" src="../jslib/jquery-ui-1.10.3/ui/jquery-ui.js"></script>
		<script type="text/javascript" src="../jslib/tagit/tag-it.min.js"></script>
		<script type="text/javascript" language="JavaScript">

	$(function(){
		var sampleTags = [];
		
	    $('#selectedCategories').tagit({
	        availableTags: sampleTags,
	        allowSpaces: true,
	        singleField: true,
	        readOnly: true,
            singleFieldNode: $('#selectedCategoriesVal'), 
            onTagClicked: function(evt, ui) {
            	$('#availableCategories').tagit('createTag', $('#selectedCategories').tagit('tagLabel', ui.tag));
            	$('#selectedCategories').tagit('removeTagByLabel', $('#selectedCategories').tagit('tagLabel', ui.tag));
            	
            }
	    });
	    
	    $('#availableCategories').tagit({
	    	readOnly: false,
	    	singleField: true,
	    	readOnly: true,
            singleFieldNode: $('#availableCategoriesVal'), 
            onTagClicked: function(evt, ui) {
            	$('#selectedCategories').tagit('createTag', $('#availableCategories').tagit('tagLabel', ui.tag));
            	$('#availableCategories').tagit('removeTagByLabel', $('#availableCategories').tagit('tagLabel', ui.tag));
            }
	    })
	    
	   $('#availableDifficulties').tagit({
	    	readOnly: false,
	    	singleField: true,
	    	readOnly: true,
            singleFieldNode: $('#availableDifficultiesVal'), 
            onTagClicked: function(evt, ui) {
            	$('#selectedDifficulties').tagit('createTag', $('#availableDifficulties').tagit('tagLabel', ui.tag));
            	$('#availableDifficulties').tagit('removeTagByLabel', $('#availableDifficulties').tagit('tagLabel', ui.tag));
            }
	    })
	    
	    $('#selectedDifficulties').tagit({
	    	readOnly: false,
	    	singleField: true,
	    	readOnly: true,
            singleFieldNode: $('#selectedDifficultiesVal'), 
            onTagClicked: function(evt, ui) {
            	$('#availableDifficulties').tagit('createTag', $('#selectedDifficulties').tagit('tagLabel', ui.tag));
            	$('#selectedDifficulties').tagit('removeTagByLabel', $('#selectedDifficulties').tagit('tagLabel', ui.tag));
            }
	    })
	    

	    var height = $('#availableCategories').height();
	    $('#availableCategories').height(height);
	    var height = $('#availableDifficulties').height();
	    $('#availableDifficulties').height(height);
	});
	</script>
    </head>
    <body class="main">

		<jsp:include page="header.jsp" />
		
		<c:if test="${not empty sessionScope.error }">
			<div class="error" style="text-align: center;"><c:out value="${sessionScope.error }"/></div>
			<c:remove var="error" scope="session"/>
		</c:if>

        <div class="pageTitle" style="width: 600px;">
        	WELCOME TO THE USER DASHBOARD
        </div>
        <div class="boxContainer">
	        <div class="box1" style="width: 430px; margin-top: 30px; float: left;">
	        <div class="box1heading">CREATE A NEW QUIZ</div>
	
			<div class="box1content">
					<form action="case.do">
					    <input type="hidden" name="method" value="setupQuiz">
				    	<input type="submit" name="submit" class="action-button" value="Start New Practice Quiz" />
				    </form>
		    </div>
	        </div>
	        
	        
	        <div class="box1" style="margin-top: 30px; width: 400px; float:right;">
	        	<div class="box1heading">CURRENT ACCOMPLISHMENTS</div>
	        	<div class="box1content" style="text-align: center;">
	        	<p style="margin: 1px;">The following table illustrates current progress with practice sets</p>
	        		<table class="accTable" style="margin-left: auto; margin-right: auto;">
	        			<tr>
	        				<th>Category</th>
	        				<th>Progress</th>
	        			</tr>
	        			<tr><td colspan="2" style="height: 2px;"></td></tr>
	        			<tr>
	        				<td>Conduction Disorders</td>
	        				<td><div class="accBackground"><div class="accForeground" style="width: 30%;"><div class="accLabel">30%</div></div></div></td>
	        			</tr>
	        			<tr>
	        				<td>Ischemia/Pericardial</td>
	        				<td><div class="accBackground"><div class="accForeground" style="width: 60%;"><div class="accLabel">60%</div></div></div></td>
	        			</tr>
	        			<tr>
	        				<td>Narrow Tachycardias</td>
	        				<td><div class="accBackground"><div class="accForeground" style="width: 40%;"><div class="accLabel">40%</div></div></div></td>
	        			</tr>
	        			<tr>
	        				<td>Wide Tachycardias</td>
	        				<td><div class="accBackground"><div class="accForeground" style="width: 40%;"><div class="accLabel">40%</div></div></div></td>
	        			</tr>
	        			<tr>
	        				<td>Devices</td>
	        				<td><div class="accBackground"><div class="accForeground" style="width: 40%;"><div class="accLabel">40%</div></div></div></td>
	        			</tr>
	        			<tr>
	        				<td>Level 1</td>
	        				<td><div class="accBackground"><div class="accForeground" style="width: 96%;"><div class="accLabel">96%</div></div></div></td>
	        			</tr>
	        			<tr>
	        				<td>Level 2</td>
	        				<td><div class="accBackground"><div class="accForeground" style="width: 70%;"><div class="accLabel">70%</div></div></div></td>
	        			</tr>
	        			<tr>
	        				<td>Level 3</td>
	        				<td><div class="accBackground"><div class="accForeground accEmpty" style="width: 100%;"><div class="accLabel">Locked</div></div></div></td>
	        			</tr>
	        		</table>
	        	</div>
	        </div>	        
	        	        
	        <div class="box1" style="width: 430px; margin-top: 30px; clear: left; float:left;">
	        <div class="box1heading">UNFINISHED QUIZES</div>
	
			<div class="box1content">
					<table class="accTable" style="margin-left: auto; margin-right: auto; text-align: center;">
					<tr>
						<th>ID</th>
						<th>Started</th>
						<th>Accessed</th>
						<th>Compl.</th>
						<th>Finished?</th>
						<th colspan="2"></th>
					</tr>
					<c:forEach var="iquiz" varStatus="loopStatus" items="${requestScope.userQuizes }">
					<tr <c:if test="${not iquiz.completed }">class="incomlete"</c:if>>
						<td><c:out value="${iquiz.quizId }"/></td>
						<td><fmt:formatDate pattern="yyyy/MM/dd" value="${iquiz.dateStarted }"/></td>
						<td><fmt:formatDate pattern="yyyy/MM/dd" value="${iquiz.dateLastActive }"/></td>
						<td><c:out value="${fn:length(iquiz.completedCases)}"/>/<c:out value="${fn:length(iquiz.completedCases)+fn:length(iquiz.incompleteCases)}"/></td>
						<td><c:out value="${iquiz.completed ? 'Yes' : 'No'}"/></td>
						<td>
						    <c:if test="${not iquiz.completed }">
						        <input type="button" class="action-button-generic" onclick="document.location='case.do?method=resumeQuiz&quizid=${iquiz.quizId}'" value="Continue"/>
							</c:if>
							<c:if test="${iquiz.completed }">
								<input type="button" class="action-button-generic" onclick="document.location='case.do?method=resumeQuiz&quizid=${iquiz.quizId}'" value="Review"/>
							</c:if>
						</td>
						<td><input type="button" class="action-button-generic" onclick="if (confirm('Are you sure you want to delete this quiz?  All questions will be marked as incomplete and returned to the bank.')) document.location='case.do?method=deleteQuiz&quizid=${iquiz.quizId}'" value="Del"/></td>
					</tr>
					</c:forEach>
					<c:if test="${empty requestScope.userQuizes}">
					<tr>
						<td style="text-align: center;" colspan="7">No previous quizes</td>
					</tr>
					</c:if>
					</table>
		    </div>
	        </div>
	        
	    </div>
        <div style="clear:both; padding-top: 20px;">
        <jsp:include page="../footer.jsp" />
        </div>
    </body>
</html>