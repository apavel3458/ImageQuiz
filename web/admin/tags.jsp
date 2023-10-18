<%@ page language="java" contentType="text/html; charset=US-ASCII"
    pageEncoding="US-ASCII"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
<title>Insert title here</title>

	<link href="../jslib/tagit/jquery.tagit.css" rel="stylesheet" type="text/css">
    <link href="../jslib/tagit/tagit.ui-zendesk.css" rel="stylesheet" type="text/css">
    <link href="admin.css?v=1" rel="stylesheet" type="text/css">
    
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

	<script type="text/javascript" src="../jslib/jquery-1.10.1.min.js"></script>
	<script type="text/javascript" src="../jslib/jquery-ui-1.10.3/ui/jquery-ui.js"></script>
	<script type="text/javascript" src="../jslib/tagit/tag-it.min.js"></script>
	<script type="text/javascript" src="../jslib/imagequiz.js"></script>
	<script type="text/javascript" language="JavaScript">
	function openDeleteTagsView() {
		var url = "admin.do?method=viewTags&exerciseid=<c:out value="${requestScope.exerciseId}"/>";
		window.open(url, "_blank", "toolbar=no, scrollbars=yes, resizable=yes, top=50, left=50, width=400, height=300");
	}
	$(function(){
		var sampleTags = ['c++', 'java', 'php', 'coldfusion', 'javascript', 'asp', 'ruby', 'python', 'c', 'scala', 'groovy', 'haskell', 'perl', 'erlang', 'apl', 'cobol', 'go', 'lua'];
		
	    $('#mytags').tagit({
	        availableTags: sampleTags,
	        allowSpaces: true,
	        singleField: true,
	        readOnly: true,
            singleFieldNode: $('#myTagsVal'), 
            onTagClicked: function(evt, ui) {
            	$('#availableTags').tagit('createTag', $('#mytags').tagit('tagLabel', ui.tag));
            	$('#mytags').tagit('removeTagByLabel', $('#mytags').tagit('tagLabel', ui.tag));
            }
	    });
	    
	    $('#availableTags').tagit({
	    	readOnly: false,
	    	singleField: true,
	    	readOnly: true,
            singleFieldNode: $('#availableTagsVal'), 
            onTagClicked: function(evt, ui) {
            	$('#mytags').tagit('createTag', $('#availableTags').tagit('tagLabel', ui.tag));
            	$('#availableTags').tagit('removeTagByLabel', $('#availableTags').tagit('tagLabel', ui.tag));
            }
	    })
	    
	    function removeTag(inputField, tagName) {
	    	var mytagsArray = $(inputField).val().split(',');
	    	for (var i = 0; i < mytagsArray.length; i++) {
	    	    if (mytagsArray[i] == tagName) {
	    	    	mytagsArray.splice(mytagsArray.indexOf(i), 1);
	    	    }
	    	}
	    	$(inputField).val(mytagsArray.join(','));
	    }
	    function addTag() {
	    	$('#myTagsVal').val();
	    	$('#availableTagsVal').val();
	    }
	    
	    $("#newTag")
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
	    
	});
	</script>
	<style type="text/css">
	ul.tagit li {clear: none;}
	</style>
</head>
<body class="tagBody">
    <c:if test="${not empty requestScope.caseId }">
	<div class="frameHeader" style="text-align: center;">SKILL MANAGEMENT</div>
	<form action="admin.do">
		<input type="hidden" name="method" value="saveTags">
		<input type="hidden" name="caseid" value="<c:out value="${requestScope.caseId}"/>">
		<input type="hidden" name="exerciseid" value="<c:out value="${requestScope.exerciseId}"/>">
		<input type="hidden" name="returnToExerciseId" value="${requestScope.returnToExerciseId}">
		
		Please select skills for this case by clicking on the tags in the "Available Tags" window.
		<div class="boxGreen">Currently Assigned Tags:
	        <ul id="mytags">
	        </ul>
	        <input type="hidden" name="myTagsVal" id="myTagsVal" value="<c:forEach items="${requestScope.currentTags}" var="currentTag" varStatus="status">
         																	<c:out value="${currentTag.tagName}"/>
         																	<c:if test="${!status.last}">,</c:if>
                                                                        </c:forEach>">
	        <div style="border-top: 1px solid grey; padding-top: 5px;">
	        	New: <input type="text" id="newTag" value="--New Tag Name--" class="disabled" style="width: 100px;">
	       		<input type="button" onclick="$('#mytags').tagit('createTag', $('#newTag').val()); $('#newTag').val(''); return false;" value="Create Tag"/>
	            <input type="submit" value="Save">
	            <input type="button" value="Del Tags" onclick="openDeleteTagsView()">
	        </div>
        </div>
        
        <div class="boxOrange" style="margin-top: 10px;">
	        Available Tags:
	        <ul id="availableTags">
	        </ul>
	        <input type="hidden" name="availableTagsVal" id="availableTagsVal" value="<c:forEach items="${requestScope.availableTags}" var="availableTag" varStatus="status">
         																	<c:out value="${availableTag.tagName}"/>
         																	<c:if test="${!status.last}">,</c:if>
                                                                        </c:forEach>">
        </div>
        
    </form>
    <c:if test="${not empty requestScope.returnToExerciseId}">
    	<br>
    	Don't forget to click SAVE before clicking button below:
    	<input type="button" onclick="return closeAndRefresh();" value="Finished with tagging - Close Window">
    </c:if>
    </c:if>
    <c:if test="${empty requestScope.caseId }">
        <div class="boxgreen" style="text-align: center;">Please select a case</div>
    </c:if>
</body>
</html>