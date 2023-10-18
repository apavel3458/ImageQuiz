<%@ page language="java" contentType="text/html; charset=US-ASCII"
    pageEncoding="US-ASCII"%>
<!DOCTYPE html>
<html lang="en">

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
<head>	
	<meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    
	<title>Case Design</title>
	
	<!-- Bootstrap -->
    <link href="<c:url value="/css/lib/bootstrap.paper.min.css"/>" rel="stylesheet"></link>
    

    
	<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
	

        
	
	
    <!-- link rel="stylesheet" href="../jslib/jquery-ui-1.10.3/themes/base/jquery-ui.css"-->
   	<link rel="stylesheet" href="../jslib/jquery-ui-1.12.1/jquery-ui.css">
  	<link rel="stylesheet" href="admin.css?v=3">
  	<link rel="stylesheet" href="css/editexercise.css?v=1">
	
	
	
	<script type="text/javascript" language="JavaScript">
	//global variables
	var exerciseId = ${exerciseId};
	</script>
	
	<style type="text/css">
      html, body {height: 100%;}
    </style>

</head>
<body style="margin: 0">


<style type="text/css">
ibody { margin: 0 }
  .irow, .icol { overflow: hidden; position: absolute; }
  .irow { left: 0; right: 0; }
  .icol { top: 0; bottom: 0; }
  .iscroll-x { overflow-x: auto; }
  .iscroll-y { overflow-y: auto; }

  .ibody.irow { top: 0px; bottom: 0px; }
  /*.ifooter.irow { height: 200px; bottom: 0; }*/
</style>


<div class="ibody irow iscroll-y" style="width: 280px;" id="editExerciseContainer">
   	<div class="editExerciseTitle" style="margin-left: auto; margin-right: auto; text-align: center;">Editing Exercise: ${requestScope.exercise.exerciseName}</div>
		<div class="btn-group btn-group-justified">
 			 <a href="admin.do" class="btn btn-default btn-xs">Back to Admin</a>
  			 <a href="../user.do?method=logout" class="btn btn-default btn-xs">Logout</a>
		</div>
		<div class="btn-group btn-group-justified">
			<div class="btn-group">
				<a href="#" class="btn btn-default btn-xs dropdown-toggle" data-toggle="dropdown">Filter/Sort <span class="caret"></span></a>
					<ul class="dropdown-menu dropdown-menu-left">
						<li class=""><a href="#" v-on:click.prevent="filterBy('ecgDx')">by ECG Diagonsis</a></li>
						<li class=""><a href="#" v-on:click.prevent="filterBy('category')">by Category</a></li>
						<li class=""><a href="#" v-on:click.prevent="sortBy('date')">Sort by Date</a></li>
						<li class=""><a href="#" v-on:click.prevent="sortBy('tag')">Sort by Tag</a></li>
						<li class=""><a href="#" v-on:click.prevent="sortBy(null)">Clear Sort</a></li>
					</ul>
			</div>
	      <a href="admin.do?method=editExercise&exerciseid=${requestScope.exercise.exerciseId}" v-on:click.prevent="filterType='';getData();" class="btn btn-default btn-xs" id="clearFiltersBtn" aria-expanded="false">
	        Clear Filters
	      </a>
	      <form action="admin.do" id="filterForm" style="display: none;">
	     	 <input type="hidden" name="method" value="editExercise">
	     	 <input type="hidden" name="exerciseid" value="${requestScope.exercise.exerciseId }">
	      	 <input type="hidden" id="selectedSTs" name="filters" value="">
	      </form>
	    </div>
	<div class="exerciseListDiv" style="height: 95vh;">
<table class="admintable" style="width: 280px;">
	<tr>
		<td colspan="4" style="padding: 3px;">
			<form action="admin.do">
			    <div class="form-group" style="padding: 0px; margin: 0px;">
			    	<input type="hidden" name="method" value="addCase">
			    	<input type="hidden" name="template" id="template" value="">
			    	<input type="hidden" name="exerciseid" value="<c:out value="${requestScope.exercise.exerciseId }"/>">
			    	<div class="col-xs-8" style="padding-left: 10px; padding-right: 3px;">
			    	    <input type="text" class="form-control input-sm" id="newcasename" name="casename" width="10" placeholder="Enter New Case Name">
			    	</div>
			    	<div class="col-xs-4" style="padding-left: 0px; padding-right: 0px;">
        				<div class="btn-group">
							  <a href="#" class="btn btn-default btn-xs dropdown-toggle" data-toggle="dropdown">Add New <span class="caret"></span></a>
							  <ul class="dropdown-menu dropdown-menu-right">
							    <li><a href="#" v-on:click.prevent="addCase('mcq')">MCQ Case</a></li>
							    <li><a href="#" v-on:click.prevent="addCase('sg')">Self-Generated Case</a></li>
							    <li class="divider"></li>
							    <li><a href="#" v-on:click.prevent="addCase('')">Blank Case</a></li>
							  </ul>
						</div>
        				
        			</div>
        			
        		</div>
        		
			</form>
		</td>
	</tr>
	<tr>
		<th>ID</th>
		<th>Case Name</th>
		<th colspan="3">Actions</th>
	</tr>
		<tr 
			v-for="icase, index in sortedCases" 
			:key="icase.caseId" 
			class="caseRow" 
			:class="[index%2==0?'odd':'even', icase==activeCase?'selectedCase':'']"
			v-on:click.stop="editCase(icase)"
			style="cursor: pointer">
			<td class="minimize caseid" style="text-align: center;">{{icase.caseId}}</td>
			<td class="maximize">
				<span class="prefix" :class="{'active':icase==activeCase}">
					<template v-if="icase.prefix && icase.prefix != ''">{{icase.prefix}} - </template>
				</span>
				<span :class="{flagComments:icase.activeComments}">
						{{icase.caseName}} 
						<span v-if="icase.activeComments">({{icase.activeComments}})</span>
				</span>
			</td>
			<td class="nopadding">
				<template v-if="filterType == ''">
				<span class="glyphicon glyphicon-arrow-up upIcon clickable" v-if="icase.caseId != ''" aria-hidden="true" v-on:click.stop="reorderCase(index, 'up')"></span>
				<span class="glyphicon glyphicon-arrow-down downIcon clickable" v-if="icase.caseId != ''" aria-hidden="true" v-on:click.stop="reorderCase(index, 'down')"></span>
				</template>
				<template v-if="filterType != ''">|</template>
			</td>
			<td class="nopadding">
                <div class="menu-button menu-button-wrapper btn-group">
                	<c:if test="${security.isManagerCases() }">
                		<a href="#" class="dropdown-toggle clickable" data-toggle="modal" v-if="icase.caseId != ''" v-on:click.stop="loadExerciseSettings(index)">Settings</a>
                	</c:if>
                	<c:if test="${!security.isManagerCases() }">
                		----
                	</c:if>
                </div>
			</td>
		</tr>

 </table>

 </div>
 
 
<div class="modal fade" role="dialog" id="filtermodal" >
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header" style="padding-bottom: 5px;">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="myModalLabel">Filters</h4>
      </div>
      <div class="modal-body caseActionsModalBody">
	      <template v-if="filterType == 'category'">
	      	<div class="instruction">Click the categories to filter by</div>
			<div class="row">
				<div v-for="n in 3" class="col-md-4">
					<div v-for="category, index in categories" 
						v-if="(index < (categories.length*n/3)) && (index >= (categories.length*(n-1))/3)" 
						:key="category.tagId">
						<button class="btn btn-default btn-xs" 
						v-bind:class="{folderSelected: category.selected}"
						v-on:click.prevent="filterSelectCategory(index)">{{category.tagName}} ({{category.preparedCaseCount}})</button>
					</div>
				</div>
			</div>
      	</template>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal" v-on:click="getData()">Apply Filter</button>
      </div>
    </div>
  </div>
</div>


 
 <!-- Modal -->
<div id="caseActions" class="modal fade" role="dialog">
  <div class="modal-dialog">

    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header" style="padding-bottom: 5px;">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Case Actions for: '{{actionsCase.caseName}}'</h4>
      </div>
      <div class="modal-body caseActionsModalBody">
      
      
        
		<div class="instruction">Click the folder names you want this case to be part of</div>
		<div class="row">
			<div v-for="n in 4" class="col-md-3">
				<div v-for="iexercise, index in actionsCase.parentExercises" 
					v-if="(index < (actionsCase.parentExercises.length*n/4)) && (index >= (actionsCase.parentExercises.length*(n-1))/4)" 
					:key="iexercise.exerciseId">
					
					<button class="btn btn-default btn-xs" 
					v-bind:class="{folderSelected: iexercise['contained']}"
					v-on:click.prevent="toggleContainedExercise(index)">{{iexercise.exerciseName}}</button>
				</div>
			</div>
		</div>
		<br/>
		<hr><hr><div class="instruction">Actions:</div>
		<button class="btn btn-default btn-xs settingsButton" v-bind:class="{active:clearTagsOnMove}" v-on:click="clearTagsOnMove = !clearTagsOnMove">
			<input type="checkbox" v-model="clearTagsOnMove">
			Clear Categories on Move
		</button><br/>
		<button href="" class="btn btn-warning btn-xs" v-on:click.prevent="deleteCase(actionsCase.index)"
				   							onclick="return confirm('WARNING: \n Deleting this case will delete it from all exercises. (case will marked as deleted)')">
				   							Delete Case (from all exercises)
		</button>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
      </div>
    </div>

  </div>
</div>
 
 
 
 </div> <!--  container div for vue app -->

<div class="ibody irow iscroll-y" style="margin-left: 280px">
		<iframe src="editcasexml.jsp" name="editcase" id="editcaseiframe" style="width: 100%; height: 100%"></iframe>
</div>





<div id="preview" title="Preview Image" style="margin-left: auto; margin-right: auto;"></div>
		<div id="loading" title="Basic dialog" style="margin-left: auto; margin-right: auto;">
  			Loading, please wait...
		</div>
		


<div class="modal fade" tabindex="-1" role="dialog" id="searchtextmodal" aria-labelledby="searchtextmodal">
  <div class="modal-dialog modal-lg searchterm" role="document">
    <div class="modal-content">
      <div class="modal-header" style="padding-bottom: 5px;">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="myModalLabel">Edit Search Terms</h4>
      </div>
      <div class="modal-body maxHeight loaderBg">
      	<iframe class="modal-iframe"></iframe>
      </div>
      <div class="modal-footer">
      	<button type="button" class="btn btn-primary" id="filterSelectedBtn" onclick="filterSelected()">Filter Selected Answers</button>
      	<button type="button" class="btn btn-primary" id="insertSelectedBtn" onclick="insertSelected()">Insert Selected Answers</button>
        <button type="button" class="btn btn-primary" data-dismiss="modal">Close Window</button>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" tabindex="-1" role="dialog" id="objectivesmodal" aria-labelledby="searchtextmodal">
  <div class="modal-dialog modal-lg searchterm" role="document">
    <div class="modal-content">
      <div class="modal-header" style="padding-bottom: 5px;">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="myModalLabel">Insert/Edit Objectives</h4>
      </div>
      <div class="modal-body maxHeight loaderBg">
      	<iframe class="modal-iframe" id="objectivesiframe"></iframe>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal">Save &amp; Close Window</button>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" tabindex="-1" role="dialog" id="iframemodal" aria-labelledby="iframemodal">
  <div class="modal-dialog modal-lg searchterm" role="document">
    <div class="modal-content">
      <div class="modal-header" style="padding-bottom: 5px;">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="myModalLabel"></h4>
      </div>
      <div class="modal-body maxHeight loaderBg">
      	<iframe class="modal-iframe"></iframe>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-primary" data-dismiss="modal">Close Window</button>
      </div>
    </div>
  </div>
</div>






    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="../jslib/jquery-1.12.4.min.js"></script>
	<script src="../jslib/jquery-ui-1.12.1.min.js"></script>
	<script src="js/vue.js"></script>
	<!-- script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script-->
	<!-- script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script-->
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="../jslib/bootstrap.min.js"></script>
    <script src="js/editexercise.js"></script>
    
    
    <script src="../jslib/imagequiz.js"></script>
    <script src="../jslib/imagezoomer/jquery.zoom.js"></script>

    <script type="text/javascript" language="JavaScript">
    
    
    	
    	//below are functions for the images iframe, so that they can load popups in the window
		$(function() {
			<c:if test="${not empty param.caseid }">
				app.editCaseById(${param.caseid});
			</c:if>
		    $( "#preview" ).dialog({
		    	autoOpen: false,
		    	position: ['center', 'center'],
		    	width: 'auto',
		        modal: true
		    });
		    $("#loading" ).dialog({
		    	autoOpen: false,
		    	position: ['center', 'center'],
		    	width: 'auto',
		        modal: true
		    });
		   	$("#searchTermManagementWindow").dialog({
		   	    autoOpen: false,
		   	    position: 'center' ,
		   	    title: 'Search Term Management',
		   	    position: ['center', 'center'],
		   	    width: $(window).width()*0.8,
		   	    height: $(window).height()*0.8,
		   	    draggable: true,
		   	    resizable : true,
		   	    modal : true,
		   	});
		   	
	});
    	
  //make editCase iframe fill 100% of height 
    $(function() {
    	$(window).on('load resize', function(){
    		//alert("test");
    		setModalHeight();
    		
    	});
    	
    	
    	$("#objectivesmodal").on("hidden.bs.modal", function () {
    		//$("#editcaseiframe").contentWindow.objectivesModalClose();
    		$("#editcaseiframe").get(0).contentWindow.objectivesModalClose();  //works
    		app.updateActiveCase(); //update title and prefix for this case
			//$f.get(0).contentWindow.MyFunction(); //works
    	});
    	
    });
    </script>

<script type="text/javascript">
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


var selectedCase = '-1';


function insertSelected() {
	//$('#searchtextmodal').find('.modal-iframe')[0].contentWindow.insertSelectedSTs();
	var selectedItems = $('#searchtextmodal').find('.modal-iframe')[0].contentWindow.getSelectedItems();
	var selectedGroups = $('#searchtextmodal').find('.modal-iframe')[0].contentWindow.getSelectedGroups();

	if (selectedItems.length == 0) {
		alert("You must select items to insert");
		return;
	} else {
		$("#searchtextmodal").modal('toggle');
		parent.$("#editcaseiframe")[0].contentWindow.insertAnswerChoices(selectedItems, selectedGroups);
	}

}

function filterSelected() {
	$('#searchtextmodal').find('.modal-iframe')[0].contentWindow.filterSelectedSTs();
}

function launchSearchTextModal(forWhat) {
	if (forWhat == 'sgInsertAnswer') {
		$('#filterSelectedBtn').hide();
   	 	$('#insertSelectedBtn').show();
   	 	$('#searchtextmodal').modal('show');
   	 	setModalHeight();
   		$('.modal-iframe').attr('src', 'searchterm.do');
	}
}

var currentExerciseId = ${requestScope.exercise.exerciseId };

function addRemoveExercise(ele, caseid, exerciseid) {
	var iconElement = $(ele).find(".glyphicon");
	var method = "addCaseToExercise";
	if (!$(iconElement).hasClass("glyphicon-plus")) {
		method = "removeCaseFromExercise";
	}
	$.ajax({
        url: "../admin/admin.do",
        data: {
            method: method,
            caseid: caseid,
            exerciseid: exerciseid
        },
        type: "GET",
        dataType: "html",
        success: function (data) {
        	$(iconElement).toggleClass("glyphicon-plus");
        	$(iconElement).toggleClass("glyphicon-minus");
        	$(ele).find(".exerciseName").toggleClass("exerciseContains");
        	//alert(data);
        	if (exerciseid == currentExerciseId) {
        		$(ele).closest(".caseRow").remove();
        	}
        },
        error: function (xhr, status) {
            alert("Could not make change: '" + xhr.responseText + "'");
            
        },
        complete: function (xhr, status) {
            //$('#showresults').slideDown('slow')
        }
    });
}

function movePhysicalRows(child, direction) {
	var row = $(child).parents("tr:first");
	if (direction == "up") {
		row.insertBefore(row.prev());
	} else if (direction == "down") {
		row.insertAfter(row.next());
	}
	
}

function setModalHeight(){
		//ensure modal takes up a certain height based on window height
    $('.modal-body.maxHeight').css('height', $(window).height() - 150);
}

$(document).ready(function(){
    $(".upIcon,.downIcon").click(function(){
        var row = $(this).parents("tr:first");
        var caseid = $(this).data("caseid");
        var exerciseid = $(this).data("exerciseid");
        if ($(this).is(".upIcon")) {
        	moveCaseUpDown(this, caseid, exerciseid, "up");
        } else if ($(this).is(".downIcon")) {
        	moveCaseUpDown(this, caseid, exerciseid, "down");
        }
    });

	var message = "<c:out value="${sessionScope.message}"/>";
	<%request.getSession().removeAttribute("message");%>
	if (message != "" && message != null) {
		alert(message);
	}
	
   	$("#filtersBtn").click( function() {
   	 	$('#searchtextmodal').modal('show');
   	 	$('#searchtextmodal').find('#filterSelectedBtn').show();
   	 	$('#searchtextmodal').find('#insertSelectedBtn').hide();
   	 	//rescale();
   	 	//parent.$('#searchtextmodal').find('.modal-iframe').load($(this).data("load-url"));
   	 	$('#searchtextmodal').find('.modal-iframe').attr('src', $(this).data("load-url"));
   	})
});
</script>


    
</body>
</html>