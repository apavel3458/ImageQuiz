<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:if test="${not empty requestScope.icase}">

<link href="../jslib/tagit/jquery.tagit.css" rel="stylesheet" type="text/css">
<link href="../jslib/tagit/tagit.ui-zendesk.css" rel="stylesheet" type="text/css">

    <style type="text/css">
		.tagsContainer ul li.tagit-choice {
			clear: none; !important
		}
	</style>


<div id="tagContainer" class="tagBody container-fluid">
	<form action="admin.do">
		<input type="hidden" name="method" value="saveTags">
		<input type="hidden" name="caseid" value="<c:out value="${requestScope.caseId}"/>">
		<input type="hidden" name="exerciseid" value="<c:out value="${requestScope.exerciseId}"/>">
		<input type="hidden" name="returnToExerciseId" value="${requestScope.returnToExerciseId}">
		
		<div class="text-center" style="font-weight:bold;">Click to move tags.  NOTE: Tags are unique to each folder.</div>
		<div class="row">
			<div class="col-xs-6">
				 <fieldset class="tagsContainer assignedTagsContainer">
		  			<legend>Assigned Tags:</legend>
		  			<ul id="mytags">
			        </ul>
			       	<input type="hidden" name="myTagsVal" id="myTagsVal" value="">
		 		</fieldset>
	 		</div>
	 		<div class="col-xs-6">
	 		<fieldset class="tagsContainer availableTagsContainer">
	 			<legend>Available Tags:</legend>
	 			<ul id="availableTags">
		        </ul>
	 		</fieldset>
	 		</div>
 		</div>
 
		<div class="row">
 			<div class="col-xs-12" style="margin-top: 5px;">
 				
<!--  				<input type="button" class="btn btn-primary btn-sm" id="saveTagButton" value="Save Case Tags" onclick="saveTags()">
 -->	            
 				
 				<input type="text" id="newTag" placeholder="New Tag Name" style="width: 200px; margin-left: 50px;">
 				<input type="button" class="btn btn-default btn-sm" onclick="$('#mytags').tagit('createTag', $('#newTag').val()); $('#newTag').val(''); return false;" value="Create Tag"/>
 				
 				<input type="button" class="btn btn-default btn-sm" value="Manage Tags" style="margin-left: 100px;" onclick="openManageTags()">
	            <br/>
	            
 			</div>
 		</div>
	        <input type="hidden" name="availableTagsVal" id="availableTagsVal" value="">
        
    </form>
</div>


<script type="text/javascript" src="../jslib/tagit/tag-it.min.js"></script>
<script type="text/javascript" language="JavaScript">


function openManageTags() {
	var url = "admin.do?method=viewTags&exerciseid=<c:out value="${requestScope.exerciseId}"/>&caseid=${requestScope.icase.caseId}";
	window.open(url, "_blank", "toolbar=no, scrollbars=yes, resizable=yes, top=50, left=50, width=1000, height=800");
}

function restoreSaveTagButton() {
	var buttonE = $("#saveTagButton");
	$(buttonE).removeClass("loaderBg");
	$(buttonE).disabled = false;
	$(buttonE).val("Save");
}

function saveTags() { //saveTags(e)
	var assignedTags = $("#myTagsVal").val();
	var caseid = ${requestScope.icase.caseId};
	var exerciseid = ${requestScope.exerciseId};
	//var buttonE = $("#saveTagButton");
	//$(buttonE).addClass("loaderBg");
	//$(buttonE).disabled = true;
	//$(buttonE).val("");
	$.ajax({
        url: "../admin/admin.do",
        data: {
            method: 'saveTags',
            caseid: caseid,
            exerciseid: exerciseid,
            myTagsVal: assignedTags
        },
        type: "GET",
        dataType: "html",
        success: function (data) {
        	//$(buttonE).val("Success!");
        	//alert(data);
        	parent.app.updateActiveCase();
        },
        error: function (xhr, status) {
        	$(buttonE).val("Failed!");
            alert("Unable to save tags: '" + xhr.responseText + "'");
            
        },
        complete: function (xhr, status) {
        	setTimeout(restoreSaveTagButton, 500);
        	//restoreSaveButton();
        }
    });
}

$(function(){
	var caseid = ${requestScope.icase.caseId};
	var exerciseid = ${requestScope.exerciseId};
	
	
	window.loadData = function() {
		$("#myTagsVal").unbind();
		clearAndDestroyTags();
		$.ajax({
	        url: "../admin/admin.do",
	        data: {
	            method: "tagListAjax",
	            caseid: caseid,
	            exerciseid: exerciseid
	        },
	        type: "GET", dataType: "html",
	        success: function (data) {
	        	console.log(data)
	        	var result = JSON.parse(data);
	        	assignTagVals(result);
	        	initTagit();
	        	$("#myTagsVal").change(function() {
	        		saveTags();
	        	})
	        },
	        error: function (xhr, status) {
	            alert("error: " + xhr);
	        },
	        complete: function (xhr, status) {
	        }
	    });
		$('#myTagsVal')
	};
	loadData();
	
	
	function assignTagVals(vals) {
		var currentTags = "";
		var currentTagsArray = new Array();
		var availableTags = "";
		var availableTagsArray = new Array();
		//alert(vals['currentTags'][0]['tagName']);
		for (var i=0; i<vals['currentTags'].length; i++) {
			currentTagsArray.push(vals['currentTags'][i]['tagName']);
		}
		for (var i=0; i<vals['availableTags'].length; i++) {
			availableTagsArray.push(vals['availableTags'][i]['tagName']);
		}
		$("#myTagsVal").val(currentTagsArray.join(","));
    	$("#availableTagsVal").val(availableTagsArray.join(","));
	}
	
	function clearAndDestroyTags() {
		try {
			$("#mytags").tagit("removeAll");
			$('#mytags').tagit('destroy');
			$("#availableTags").tagit("removeAll");
			$('#availableTags').tagit('destroy');
		} catch (err) {}
	}
	
	function initTagit() {
			    
		$('#mytags').tagit({
	        //availableTags: sampleTags,
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
	    
	}
    
    
    
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

</c:if>