<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>ECG Master Quiz Setup</title>

<script src="../jslib/jquery-1.10.1.min.js"></script>
<script src="../jslib/jquery-ui-1.10.3/ui/jquery-ui.js"></script>
<script type="text/javascript" src="../jslib/tagit/tag-it.min.js"></script>
<script type="text/javascript" src="../jslib/setupwizard.js"></script>


<link rel="stylesheet" href="../jslib/jquery-ui-1.10.3/themes/base/jquery-ui.css">

<link rel="stylesheet" type="text/css" href="../css/quizsetup.css">
<link href="../jslib/tagit/jquery.tagit.css" rel="stylesheet" type="text/css">
<link href="../jslib/tagit/tagit.ui-zendesk.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" type="text/css" href="../css/case.css">

<script type="text/javascript" language="JavaScript">

	$(function(){
		var sampleTags = [];
		
	    $('#selectedCategories').tagit({
	        allowSpaces: true,
	        singleField: true,
	        readOnly: true,
            singleFieldNode: $('#selectedCategoriesVal'), 
            onTagClicked: function(evt, ui) {
            }
	    });
	    
	    $('#selectedDifficulties').tagit({
	        allowSpaces: true,
	        singleField: true,
	        readOnly: true,
            singleFieldNode: $('#selectedDifficultiesVal'), 
            onTagClicked: function(evt, ui) {
            }
	    });


	});
	function toDashboard() {
		document.location = "case.do?method=dashboard";
	}
	</script>
    </head>
    <body>
    	<jsp:include page="header.jsp" />

        	
        	
        

        
        
<!-- multistep form -->
<form id="msform" action="case.do">
    <input type="hidden" name="method" value="quizNavigation">
	<!-- progressbar -->
	<ul id="progressbar">
		<li class="active">Welcome</li>
		<li class="active">Difficulty Level</li>
		<li class="active">Categories</li>
		<li class="active">Question Number</li>
		<li class="active">Confirm</li>
	</ul>
	<!-- fieldsets -->
	
	<fieldset>
		<h2 class="fs-title">Quiz Created!</h2>

			<table class="quizIntroTable" style="margin-left: auto; margin-right: auto;">
	        	<tr><th>
	        		Found questions (based on search criteria)
	        		</td>
	        		<td>
	        			<c:out value="${requestScope.questionNumberFound }"/> questions
	        		</td>
	        	</tr>
	        	<tr><th>
	        		Selected for this quiz:
	        		</td>
	        		<td>
	        			<c:out value="${requestScope.questionNumberUsed }"/> questions
	        		</td>
	        	</tr>
	        	<tr>
	        		<th>ECGs will be displayed from the<br> following categories:</td>
	        		<td style="padding-top: 3px; padding-bottom: 3px;">
	        			<ul id="selectedCategories"></ul>
					    <input type="hidden" name="selectedCategoriesVal" id="selectedCategoriesVal" value="<c:out value="${requestScope.categories }"/>">
	        		</td>
	        	</tr>
	        	<tr>
	        		<th>Difficulty levels: </td>
	        		<td style="padding-top: 3px; padding-bottom: 3px;">
	        		   <ul id="selectedDifficulties"></ul>
					    <input type="hidden" name="selectedDifficultiesVal" id="selectedDifficultiesVal" value="<c:out value="${requestScope.difficulties}"/>">
	        		</td>
	        	</tr>
        	</table>


		<input type="button" name="todashboard" class="action-button" onclick="toDashboard()" value="Cancel" />
		<input type="submit" name="submit" class="submit action-button" value="Start Quiz!" />
	</fieldset>
</form>

        <div style="position: absolute; bottom: 10px; left: 0; right: 0; margin-left: auto; margin-right: auto; z-index: -1;">
        <jsp:include page="../footer.jsp" />
        </div>

    </body>
</html>
