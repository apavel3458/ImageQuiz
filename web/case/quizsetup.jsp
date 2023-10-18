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
            	var height = $('#availableCategories').height();
        	    $('#availableCategories').height(height);
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
            	var height = $('#availableDifficulties').height();
        	    $('#availableDifficulties').height(height);
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
	    
	    $(function() {
			$( "#radio" ).buttonset();
		});
	});
	</script>
	
</head>
<body>
<jsp:include page="header.jsp" />

<!-- multistep form -->
<form id="msform" action="case.do">
    <input type="hidden" name="method" value="startQuiz">
    <input type="hidden" name="caseid" value="<c:out value="${requestScope.caseId}"/>">
	<!-- progressbar -->
	<ul id="progressbar">
		<li class="active">Welcome</li>
		<li>Difficulty Level</li>
		<li>Categories</li>
		<li>Question Number</li>
		<li>Confirm</li>
	</ul>
	<!-- fieldsets -->
	<fieldset>
		<c:if test="${not empty requestScope.errorMessage }">
			<div class="error"><c:out value="${requestScope.errorMessage}"/>;  Please try again.</div>
		</c:if>
		<h2 class="fs-title">Custom Quiz Creation</h2>
		<h3 class="fs-subtitle">Welcome! </br></br>  These steps will help you generate a custom ECG quiz to maximize your learning</h3>
		
		<input type="button" name="next" class="next action-button" value="Next" />
	</fieldset>
	<fieldset>
		<h2 class="fs-title">Difficulty Level</h2>
		<h3 class="fs-subtitle">Select ECG Difficulties</h3>
		   <div class="supplementaryTextBright" style="margin-top: 4px;">(Can select multiple; Leave blank to select ALL)</div>
		
		
		
			
						<table class="choiceTable" style="width: 100%; text-align: center; margin-left: auto; margin-right: auto; margin-top: 8px;">
						   <tr>
						   	  <th class="availableBox heading" style="padding: 1px;">Available Difficulties</th>
						   	  <th class="selectedBox heading" style="padding: 1px;">Selected Difficulties</th>
						   </tr>
						   <tr>
						      <td width="50%" class="availableBox"><ul id="availableDifficulties"></ul>
					                <input type="hidden" name="availableDifficultiesVal" id="availableDifficultiesVal" value="<c:forEach items="${requestScope.availableDifficulties}" var="currentTag" varStatus="status">
				         																	<c:out value="${currentTag.tagName}"/> (<c:out value="${fn:length(currentTag.associatedCases) }"/>)
				         																	<c:if test="${!status.last}">,</c:if>
				                                                                        </c:forEach>">
						      </td>
						      <td width="50%" class="selectedBox">
						      		<ul id="selectedDifficulties"></ul>
					                <input type="hidden" name="selectedDifficultiesVal" id="selectedDifficultiesVal"/>
						      </td>
						   </tr>
						</table>
		<input type="button" name="previous" class="previous action-button" value="Previous" />
		<input type="button" name="next" class="next action-button" value="Next" />
	</fieldset>
	<fieldset>
		<h2 class="fs-title">Categories</h2>
		<h3 class="fs-subtitle">Are there specific categories you'd like to practice?</h3>
		<div class="supplementaryTextBright" style="margin-top: 4px;">(Can select multiple; Leave blank to select ALL)</div>
		
		

						<table class="choiceTable" style="width: 100%; text-align: center; margin-left: auto; margin-right: auto; margin-top: 8px;">
						   <tr>
						   	  <th class="availableBox heading" style="padding: 1px;">Available Categories</th>
						   	  <th class="selectedBox heading" style="padding: 1px;">Selected Categories</th>
						   </tr>
						   <tr>
						   	  <td width="50%" class="availableBox">
					                <ul id="availableCategories"></ul>
					                <input type="hidden" name="availableCategoriesVal" id="availableCategoriesVal" value="<c:forEach items="${requestScope.availableCategories}" var="currentTag" varStatus="status">
				         																	<c:out value="${currentTag.tagName}"/> (<c:out value="${fn:length(currentTag.associatedCases) }"/>)
				         																	<c:if test="${!status.last}">,</c:if>
				                                                                        </c:forEach>">
						   	  </td>
						   	  <td width="50%" class="selectedBox">
					                 <ul id="selectedCategories"></ul>
					                 <input type="hidden" name="selectedCategoriesVal" id="selectedCategoriesVal" value="">
						   	  </td>
						   </tr>
						</table>

		<input type="button" name="previous" class="previous action-button" value="Previous" />
		<input type="button" name="next" class="next action-button" value="Next" />
	</fieldset>
	<fieldset>
		<h2 class="fs-title">Question Number</h2>

						<table class="choiceTable" style="width: 100%; text-align: center; margin-left: auto; margin-right: auto; margin-top: 8px;">
						   <tr>
						   	  <th class="fs-subtitle">Do you want to include normal ECGs?<br><sup class="supplementaryText">More realistic exercise</sup></th>
						   	  <td>
						   	  	<div id="radio">
									<input type="radio" id="radio1" name="radio" checked="checked"><label for="radio1">Yes</label>
									<input type="radio" id="radio2" name="radio"><label for="radio2">No</label>
								</div>
						   	  </td>
						   	  </tr><tr></tr>
						   <tr>
						   	  <th class="fs-subtitle">Select maximum number of questions</th>
						   	  <td><input type="text" size="3" style="text-align: center;" name="questionnumber" value="10"></td>
						   </tr>
						   
						</table>


		<input type="button" name="previous" class="previous action-button" value="Previous" />
		<input type="submit" name="submit" class="submit action-button" value="Create Quiz!" />
	</fieldset>
</form>

        <div style="position: absolute; bottom: 10px; left: 0; right: 0; margin-left: auto; margin-right: auto; z-index: -1;">
        <jsp:include page="../footer.jsp" />
        </div>


</body>
</html>