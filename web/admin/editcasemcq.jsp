<%@ page language="java" contentType="text/html; charset=US-ASCII"
    pageEncoding="US-ASCII"%>
    
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
    
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Edit Case</title>
        <link rel="stylesheet" href="admin.css?v=1">
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-ui.min.js"></script>
        <script src="../jslib/bootstrap.min.js"></script>
        <script src="../jslib/imagequiz.js"></script>
        <script src="../jslib/moment.min.js"></script>
        <script src="js/vue.js"></script>
        
        <link href="../css/fonts/font-awesome-512/css/all.min.css" rel="stylesheet">
        
		
	<!-- Include Editor style. -->
    <!-- Include external CSS. -->
<!-- 	<link rel="stylesheet" href="css/codemirror.min.css"> --> 
      <link rel="stylesheet" type="text/css" href="<c:url value="/css/case/comments.css"/>" >

 
    <!-- Include Editor style. -->
    
    

	 
	<!-- Include JS file. -->
    <!-- Include external JS libs. -->

 
    <!-- Include Editor JS files. -->
       <script src="js/tinymce/tinymce.min.js"></script>

<!--  <script src="https://cdn.tiny.cloud/1/15y4jajnbmu1ntqhgmn2qoa91cds6v2cgrl87x8o9q4b8zxv/tinymce/5/tinymce.min.js" referrerpolicy="origin"></script>
 -->
		<link rel="stylesheet" href="../css/lib/bootstrap.paper.min.css">
		<link rel="stylesheet" href="css/editcase.css">
		
		<!-- To make editor feel like the real thing -->
    	<link rel="stylesheet" href="../css/case/casedisplay.css">
		

		<script type="text/javascript">
		function previewCase(caseid) {
			//window.open("../case/case.do?method=testCase&mode=<%=org.imagequiz.model.IQExam.EXAM_MODE_TEST%>&caseid="+ caseid, "Case Preview", "toolbar=no, scrollbars=yes, resizable=yes, width=1000, height=800");
			let host = window.location.host;
			basehost = host.replaceAll(/admin\.|\:8080/ig, '')
			basehost = basehost+':8082'
			let win = window.open("http://"+basehost+"/#/admin/case/demo/"+ caseid, "Case Preview", "toolbar=no, scrollbars=yes, resizable=yes, width=1000, height=800");
		}
		</script>
</head>
<body>
<div id="pageContainer">

<div class="message"><c:out value="${requestScope.message }"/></div>
<div class="error"><c:out value="${requestScope.error }"/></div>

<c:if test="${not empty requestScope.icase }">

<form action="admin.do" method="POST">
<input type="hidden" name="method" value="updateCase">
<input type="hidden" name="caseTypeInterface" value="mcq">
<input type="hidden" name="caseid" id="caseid" value="<c:out value="${requestScope.icase.caseId }"/>">
<input type="hidden" name="exerciseid" id="exerciseid" value="<c:out value="${requestScope.exerciseId }"/>">
	

<div id="caseEditorApp">
<div class="contrainer-fluid">
	<div class="row">
		
		<div class="col-sm-3 row">
			&nbsp;
			<c:if test="${not empty requestScope.lastRevision }">
				<input type="button" class="btn no-shadow btn-default btn-xs" data-load-url="admin.do?method=showCaseHx&caseid=${requestScope.icase.caseId}&exerciseid=${exerciseId}" id="openHx" value="See History" 
						style="left: 100px; top: 5px; position: absolute; z-index: 1000; box-shadow: none; border: 1px solid #d6d6d6;">
				<div class="revisionDiv">
					<span class="heading">Initial Author: </span> ${requestScope.initialAuthor.author }<br/>
					<span class="heading">Last Revision:</span> ${requestScope.lastRevision.author} <br/>
					<span class="heading">Date: </span> <fmt:formatDate pattern = "MMM dd, yyyy hh:mm a" value = "${requestScope.lastRevision.datetime}" /><br/>
				</div>
				
			</c:if>
		</div>
		<div class="col-sm-6" style="text-align: right;">
			<div class="caseTitle" style="width: 80%; margin-left: auto; margin-right: auto;">
				<input type="text" class="caseTitleInput" name="casename" id="caseName" @change="isTitleChanged=true" v-model="icase.caseName">
				<div class="caseTitleCaption" style="width: 200px; margin-left:auto; margin-right: auto;">case title</div>
			</div>
		</div>
		<div class="col-sm-3">
			&nbsp;
		</div>
	
	</div>
</div>

<div id="caseContainer">

<div>
  	<div class="alert alert-warning alert-dismissable caseError" id="errorDiv" role="alert" style="display: none;">
  		<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
					Error: <span id="errorTitle"></span>
					<a href="#" class="btn btn-warning btn-xs" style="margin-left: 20px;" id="showDetails">Show Details?</a>
	</div>
	<div class="alert alert-warning alert-dismissable caseError errorDetails" id="errorDetails" hidden="hidden" role="errorDetails">
		<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
					Error: <%--((Exception) request.getAttribute("exception")).printStackTrace(response.getWriter()); --%>
<pre id="errorDetail"></pre>

	</div>
</div>



	<div class="editorSectionDiv" style="padding-top: 0px;">
		<H4 class="sectionHeader">Step 1: Question Text</H4>
		<div id="questionHtml" v-html="icase.caseText" ref="caseTextRef" class="caseText fr-view adminCaseText" name="questionHtml">
			<!-- c:out value="${requestScope.questionHtml }" escapeXml="false"/-->
		</div>
		<div class="autosaveText">Autosaved (q5 min): <span class="autosaveTimestamp"><i>Pending</i></span></div>
	</div>

	<div class="editorSectionDiv">
		<H4 class="sectionHeader">Step 2: Question Option</H4>
		<!-- THIS IS WHERE MCQ IS MADE -->
		<div id="mcqchoices" class="mcqDiv">
			<div v-for="(question, i) in icase.questionList" :key="'q'+i">
			
			
				<!--     MCQ HERE .........   -->
			  <table v-if="question.questionType == 'choice'" :key="'t'+i" class="mcq-choice-table">
			  <tr>
			  	<td class="text-center" style="font-size: 8px;">ID: {{question.questionTextId}} <br/> {{question.questionId}}</td>
			  	<th class="text-center">Correct</th>
			  	<th class="text-center">Score</td>
			  	<td colspan="2">
			  		<div style="white-space: nowrap;">
			  			<input type="text" class="form-control" v-model.lazy.trim="question.questionText" placeholder="Question Text (optional)" style="width: 400px; display: inline-block;">
			  		</div>
			  	</td>
			  	
			  </tr>
			  	<tr v-for="(choice, i2 in question.associatedChoices" :key="'c'+i2">
			  		<td class="mcq-choice-td-index" v-bind:class="{selected: choice.correct}">{{numberToLetter(i2)}}</td>
			  		<td class="mcq-choice-td-check"><input type="checkbox" v-model="choice.correct" @change="setCorrect(question, choice)"></td>
			  		<td class="mcq-choice-td-check" v-bind:class="{'selected': choice.correct}" style="border-left: 1px solid grey;">
			  			<input type="text" v-model.lazy.number="choice.selectScore" class="sgScoreInput" style="width: 40px; text-align: center;">
			  		</td>
			  		<td class="mcq-choice-td-input" v-bind:class="{'selected': choice.correct}">
			  			<input type="text" v-model.lazy.trim="choice.answerString" placeholder="Choice Text" class="choiceTextInput" style="width: 100%;">
			  		</td>
			  		<td class="mcq-choice-td-remove">
			    		<button v-on:click.prevent="removeChoice(question, choice)" class="btn btn-default btn-xs">X</button>
			    	</td>
			  	</tr>
			  	<tr>
			  		<td colspan="5">
			  			<button @click.prevent="addChoice(question)" class="btn btn-default btn-xs">Add Choice</button>
			  			<span style="margin-left: 20px;" class="advancedControl">Shuffle Choices?<input type="checkbox" v-model="question.shuffle" style="margin-left: 10px; transform: scale(0.8);"></span>
			  			<span style="margin-left: 20px;" class="advancedControl">Pass Score: <input type="text" v-model.number="question.passScore" class="text-center advancedControl" style="margin-left: 5px; width: 30px;"></span>
			  			<span style="margin-left: 20px;" class="advancedControl">Max Selections: <input type="text" v-model.number="question.maxUserSelections" class="text-center advancedControl" style="margin-left: 5px; width: 30px;"></span>
			  		</td>
			  		<td><button @click.prevent="if (confirm('Are you sure you want to remove this question?')) removeQuestion(question);" class="btn btn-default btn-xs" style="display: inline-block;">Remove Question</button></td>
			  	</tr>
			  </table>
			  
			  
			  <!--     SG HERE .........   -->
			  <div v-if="question.questionType == 'sg'">
			  		<div style="margin-left:100px">
			  			<div style="font-size: 10px;"><i>Users generate their own answers, grading is by specific answer</i></div>
			  			<div><input type="text" class="form-control" v-model.lazy.trim="question.questionText" placeholder="Question Text (optional)" style="width: 400px; display: inline-block;"></div>
			  		</div>
			  <table class="mcq-choice-table sg-choice-table">
			  	<tr>
			  		<th>ID: {{question.questionTextId}} <br/> {{question.questionId}}</th>
			  		<th>Score if selected<br/>(+ or -)</th>
			  		<th>Score if missed<br/>(+ or -)</th>
			  		<th>Primary<br/>Dx?</th>
			  		<th>Alternative Choice<br/>(to choice above it)</th>
			  		<th>Text</th>
			  	</tr>
			  	<template v-for="(line, lineIndex in question.associatedAnswerLines">
				  	<tr v-for="(wrapper, wrapperIndex in line.associatedAnswerWrappers">
				  		<td class="sg-choice-td-index"  style="text-align: center;"
				  			:class="[answerOptionCSS(line), 
				  						{'oneOrOther': false}, 
				  						{'oneOrOtherInitial':false}
				  					]"><span v-if="wrapperIndex > 0">or </span>{{numberToLetter(lineIndex)}}</td>
				  		<td class="mcq-choice-td-score"><input type="number" v-model="wrapper.scoreModifier" class="sgScoreInput" :class="answerOptionCSS(wrapper)"></td>
				  		<td class="mcq-choice-td-score"><input type="number" v-model="wrapper.scoreMissed" class="sgScoreInput" :class="answerOptionCSS(wrapper)"></td>
				  		<td class="sg-choice-td-check"><input type="checkbox" v-model="wrapper.primaryAnswer" 
				  											@click="editDefaultScore(wrapper, 1, 0.25)"
				  											:class="answerOptionCSS(wrapper)"></input></td>
				  		<td class="sg-choice-td-check"><input type="checkbox" :checked="wrapperIndex>0" @change="sgMakeOr(question, wrapper, wrapperIndex>0)" class="wrapper"></input></td>
				  		<td class="sg-choice-td-input">
				  			<input type="text" v-model.lazy.trim="wrapper.searchTerm.searchTermString" disabled placeholder="Choice Text" class="choiceTextInput" :class="answerOptionCSS(wrapper)" style="width: 100%;">
				  		</td>
				  		<td class="mcq-choice-td-remove nopadding">
				    		<button v-on:click.prevent="removeSGChoice(question, lineIndex, wrapperIndex)" class="btn btn-default btn-xs sgRemoveButton">X</button>
				    		<i class="glyphicon glyphicon-arrow-up upIcon clickable" 
				    			@click.prevent="moveUp(question, line, wrapper)" aria-hidden="true"
				    			v-if="(line.associatedAnswerWrappers.length === 1 && lineIndex!=0) || (line.associatedAnswerWrappers.length > 1 && wrapperIndex > 0)"></i>
				    		<i class="glyphicon glyphicon-arrow-down downIcon clickable" 
				    			@click.prevent="moveDown(question, line, wrapper)" aria-hidden="true"
				    			v-if="(line.associatedAnswerWrappers.length === 1 && lineIndex!=question.associatedAnswerLines.length-1) || (line.associatedAnswerWrappers.length > 1 && wrapperIndex !== line.associatedAnswerWrappers.length-1)"></i>
				    	</td>
				  	</tr>
			  	</template>
			  	<tr>
			  		<td colspan="4"><button @click.prevent="addSGChoice(question)" class="btn btn-default btn-xs">Add Choice</button></td>
			  		<!-- button class="btn btn-primary btn-xm" data-load-url="searchterm.do" id="searchTermDialogueButton" @click.prevent="addAnswer">Add Answer</button-->
			  	</tr>
			  	<tr class="extras">
					  	<td class="extra" colspan="6">
					  		<div style="display: inline-block">
					  			<span class="extraTitle">Group Choices: </span>
					  			<input type="text" v-model="question.availableGroupsText" style="width: 200px; padding-left:5px;">
					  		</div>
					  		<div style="display: inline-block">
					  		<span class="extraTitle">Pass Score: </span>
					  		<input type="number" v-model.number="question.passScore" class="sgScoreInput"> <button @click.prevent="sgCalculatePassScore(question)" class="btn btn-default btn-xs">Calculate</button>
					  		</div>
					  		<div style="display: inline-block">
					  			<span class="extraTitle offset">Wrong Choice Penalty:</span>
					  			<input type="number" v-model.number="question.scoreIncorrectChoice" class="sgScoreInput">
					  		</div>
					  	</td>
					  	<td><button @click.prevent="if (confirm('Are you sure you want to remove this question?')) removeQuestion(question);" class="btn btn-default btn-xs" style="display: inline-block;">Remove Question</button></td>
				</tr>
		  	</table>
		  	</div>
		  	
		  	<!--  QUESTION TYPE TEXT HERE -->
		  	<div v-if="question.questionType == 'text'" style="margin: 50px 0 0 80px;">
		  		<div style="font-size: 10px;"><i>This creates a free-text box.  No automatic grading will take place</i></div>
		  		<table>
		  			<tr>
			  			<th style="font-weight: bold; white-space: nowrap;">Question ID:</th>
			  			<td style="padding-left: 20px;">{{question.questionTextId}}</td>
		  			</tr>
		  			<tr>
		  				<th style="white-space: nowrap;">Question Text:</th>
		  				<td style="padding-left: 20px;"><input type="text" class="form-control" v-model.lazy.trim="question.questionText" placeholder="Question Text (optional)" style="width: 400px; display: inline-block;"></td>
		  			</tr>
		  			<tr>
		  				<th style="white-space: nowrap; vertical-align: top;">Max Length (# char):</th>
		  				<td style="padding-left: 20px;">
		  					<input type="number" class="form-control" v-model.lazy.number="question.options.maxLength" placeholder="Maximum Length" style="width: 400px; display: inline-block;">
		  				</td>
		  			</tr>
<!-- 		  			<tr>
		  				<th style="white-space: nowrap;">Box Height (1-5):</th>
		  				<td style="padding-left: 20px;">
		  					<input type="number" class="form-control" v-model.lazy.number="question.options.height" placeholder="Box Height" style="width: 400px; display: inline-block;">
		  				</td>
		  			</tr> -->
		  			<tr>
		  				<th style="white-space: nowrap; vertical-align: top;">Model Answer</th>
		  				<td style="padding-left: 20px;">
		  					<textarea class="form-control" v-model.lazy.trim="question.options.modelAnswer" placeholder="Model Answer" style="width: 400px; display: inline-block;"></textarea>
		  				</td>
		  			</tr>
		  			<tr>
					  		<th style="white-space: nowrap;">Score: </th>
					  		<td style="padding-left: 20px;">
					  				<input type="number" v-model.number="question.passScore" disabled class="sgScoreInput"> 
					  		</td>
					 </tr>
		  			<td colspan="2" style="text-align: right;"><button @click.prevent="if (confirm('Are you sure you want to remove this question?')) removeQuestion(question);" class="btn btn-default btn-xs" style="display: inline-block;">Remove Question</button></td>
			  	</table>
		  	</div>
		  	
		  	
		  	
		  	
		  	
		  	<!--     SGG HERE .........   -->
			  <div v-if="question.questionType == 'sgs'">
			  		<div style="margin-left:100px; margin-top: 50px;">
			  			<div style="font-size: 10px;"><i>Users generate their own answers, grading is by sets of answers</i></div>
			  			<div><input type="text" class="form-control" v-model.lazy.trim="question.questionText" placeholder="Question Text (optional)" style="width: 400px; display: inline-block;"></div>
			  		</div>
			  <table class="mcq-choice-table sg-choice-table" style="width: 1000px;">
			  	<tr>
			  		<th>ID: {{question.questionTextId}} <br/> {{question.questionId}}</th>
			  		<th>Score if selected<br/>(+ or -)</th>
			  		<!-- <th>Score if missed<br/>(+ or -)</th> -->
			  		<th>Preferred<br>Set?</th>
			  		<th>Required<br>/Optional</th>
			  		<th>Score if selected<br/>(+ or -)</th>
			  		<!-- <th>Score if missed<br/>(+ or -)</th> -->
			  		<th>Text</th>
			  	</tr>
			  	<template v-for="(line, lineIndex in question.associatedAnswerLines">
			  		<template v-if="line.associatedAnswerWrappers.length == 0">
				  		<tr>
				  			<td colspan="5" class="sgs-set-left-td">Empty Set, add choices</td>
				  		</tr>
			  		</template>
				  	<tr v-for="(wrapper, wrapperIndex in line.associatedAnswerWrappers">
				  		<td class="sg-choice-td-index sgs-set-left-td" :rowspan="line.associatedAnswerWrappers.length" v-if="wrapperIndex==0" style="text-align: center;"
				  			:class="[answerOptionCSS(line), 
				  						{'oneOrOther': false}, 
				  						{'oneOrOtherInitial':false}
				  					]">{{numberToLetter(lineIndex)}}</td>
				  		<td class="mcq-choice-td-score align-center-td sgScoreInput" v-if="wrapperIndex==0" :rowspan="line.associatedAnswerWrappers.length">
				  			<input type="number" v-model="line.scoreModifier" class="sgScoreInput" :class="answerOptionCSS(wrapper)">
				  		</td>
<!-- 				  	<td class="mcq-choice-td-score align-center-td" v-if="wrapperIndex==0" :rowspan="line.associatedAnswerWrappers.length">
				  			<input type="number" v-model="line.scoreMissed" class="sgScoreInput" :class="answerOptionCSS(wrapper)">
				  		</td> -->
				  		<td class="sg-choice-td-check" v-if="wrapperIndex==0" :rowspan="line.associatedAnswerWrappers.length">
				  											<input type="checkbox" v-model="line.primaryAnswer" 
				  											@click="editDefaultScore(line, 1, 0.25)"
				  											:class="answerOptionCSS(line)"></input>
				  		</td>
				  		<td class="sg-choice-td-check sgs-set-left-td"><input type="checkbox" v-model="wrapper.primaryAnswer" 
				  											@click="editDefaultScore(wrapper, 0, 0)"
				  											:class="answerOptionCSS(wrapper)"></input></td>
				  		<td class="mcq-choice-td-score align-center-td sgScoreInput">
				  			<input v-if="true" type="number" v-model="wrapper.scoreModifier" class="sgScoreInput" :class="answerOptionCSS(wrapper)">
				  		</td>
<!-- 				  		<td class="mcq-choice-td-score align-center-td sgScoreInput">
				  			<input v-if="true" type="number" v-model="wrapper.scoreMissed" class="sgScoreInput" :class="answerOptionCSS(wrapper)">
				  		</td> -->
				  		<td class="sg-choice-td-input" style="width: 50%;">
				  			<input type="text" v-model.lazy.trim="wrapper.searchTerm.searchTermString" disabled placeholder="Choice Text" class="choiceTextInput" :class="answerOptionCSS(wrapper)" style="width: 100%;">
				  		</td>
				  		<td class="mcq-choice-td-remove nopadding">
				    		<i class="glyphicon glyphicon-arrow-up upIcon clickable" 
				    			@click.prevent="moveUp(question, line, wrapper)" aria-hidden="true"
				    			v-if="(line.associatedAnswerWrappers.length === 1 && lineIndex!=0) || (line.associatedAnswerWrappers.length > 1 && wrapperIndex > 0)"></i>
				    		<i class="glyphicon glyphicon-arrow-down downIcon clickable" 
				    			@click.prevent="moveDown(question, line, wrapper)" aria-hidden="true"
				    			v-if="(line.associatedAnswerWrappers.length === 1 && lineIndex!=question.associatedAnswerLines.length-1) || (line.associatedAnswerWrappers.length > 1 && wrapperIndex !== line.associatedAnswerWrappers.length-1)"></i>
				    		<button v-on:click.prevent="removeSGChoice(question, lineIndex, wrapperIndex)" class="btn btn-default btn-xs sgRemoveButton" style="float:left;">X</button>
				    	</td>
				    	<td>
				    		
				    	</td>
				    </tr>
				    <tr>
				    	<td colspan="4" style="padding-bottom: 10px;">
				    		<button @click.prevent="addSGChoice(question, line)" class="btn btn-default btn-xs">Add Choice</button>
				    		<button @click.prevent="removeSGChoice(question, lineIndex, null)" class="btn btn-default btn-xs">Remove Set</button>
				    	</td>
				  	</tr>
			  	</template>
			  	<tr>
			  		<td colspan="4"><button @click.prevent="addSGLine(question)" class="btn btn-default btn-xs">Add Set</button></td>
			  		<!-- button class="btn btn-primary btn-xm" data-load-url="searchterm.do" id="searchTermDialogueButton" @click.prevent="addAnswer">Add Answer</button-->
			  	</tr>
			  	<tr class="extras">
					  	<td class="extra" colspan="6">
					  		<div style="display: inline-block">
					  			<span class="extraTitle">Group Choices: </span>
					  			<input type="text" v-model="question.availableGroupsText" style="width: 200px; padding-left:5px;">
					  		</div>
					  		<div style="display: inline-block">
					  		<span class="extraTitle">Pass Score: </span>
					  		<input type="number" v-model.number="question.passScore" class="sgScoreInput"> 
					  		<!-- <button @click.prevent="sgCalculatePassScore(question)" class="btn btn-default btn-xs">Calculate</button> -->
					  		</div><br/>
<!-- 					  		<div style="display: inline-block">
					  			<span class="extraTitle">Wrong Choice Penalty:</span>
					  			<input type="number" v-model.number="question.scoreIncorrectChoice" class="sgScoreInput">
					  		</div> -->
					  	</td>
					  	<td><button @click.prevent="if (confirm('Are you sure you want to remove this question?')) removeQuestion(question);" class="btn btn-default btn-xs" style="display: inline-block;">Remove Question</button></td>
				</tr>
		  	</table>
		  	</div>
		  	
		  	
		  </div>
		  <div class="btn-group" style="line-height: 30px; vertical-align: middle; margin-left: 10px;">
		  		<a href="#" class="btn btn-default btn-xs dropdown-toggle" style="float: none;" data-toggle="dropdown">Add Question <span class="caret"></span></a>
							  <ul class="dropdown-menu">
							    <li><a href="#" @click.prevent="addQuestion('mcq')" >MCQ Case</a></li>
							    <li><a href="#" @click.prevent="addQuestion('sg')">Self-Generated Items</a></li>
							    <li><a href="#" @click.prevent="addQuestion('sgs')">Self-Generated Sets</a></li>
							    <li><a href="#" @click.prevent="addQuestion('text')">Free Text</a></li>
							  </ul>
				
				<div class="caseControls">
		  			<input type="checkbox" v-model="icase.displayType" class="advancedControl" :true-value="0" :false-value="1"/><span class="advancedControl">Hide question when showing answer?</span>
		  		</div>
		  </div>
		  <br/>
		</div>
	</div>
	
	
	
	

<!-- THIS IS WHERE MCQ IS MADE -->

	<div class="editorSectionDiv">
		<H4 class="sectionHeader">Step 3: Answer Text</H4>
		<div id="answerHtml" name="answerHtml" ref="caseAnswerTextRef" class="caseText fr-view adminCaseText" v-html="icase.caseAnswerText"></div>
		<div class="autosaveText">Autosaved (q5 min): <span class="autosaveTimestamp"><i>Pending</i></span></div>
	</div>


	<div class="caseEditControls">
		<!-- Can uncomment the next line if need another button, but now that tinymce handles it, there is no need -->
		<input type="button" 
			class="btn btn-success btn-sm" 
			@click.prevent="save()" 
			id="saveCaseTextButton" 
			:class="{loaderBg: loading}" :disabled="loading"
			style="margin-left: 5px;" value="Save Case Text and MCQ">

		
		&nbsp;
		<input type="button" class="btn btn-info btn-sm" onclick="previewCase('<c:out value="${requestScope.icase.caseId }"/>');" value="Preview Saved Case">
		<button class="btn btn-info btn-sm" type="button" id="labTableButton" data-load-url="resources/RCReferenceValues.pdf"><i class="fas fa-flask"></i></button>
		<c:if test="${security.isManagerCases() }">
		<button class="btn btn-info btn-sm" type="button" id="reportButton" 
			data-load-url="results.do?method=caseStatistics&caseid=${icase.caseId}">
			<i class="fas fa-chart-bar"></i>
		</button>
		</c:if>
	</div>
	
	
	<div id="labSelect" class="modal fade bs-example-modal-sm" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel">
	  <div class="modal-dialog modal-lg" role="document">
	    <div class="modal-content text-center" style="padding: 10px;">
	    	<H4>Select Labs To Insert</H4>
	    	<div style="color: grey;">NOTE: Select labs in order you want them to appear</div>
	    	<div class="modal-body">
	    		<div v-for="ii in 2" :key="'t'+ii" style="display: inline-block;">
			      <table class="labTable"> 
			      	<tr v-for="(lab, i) in (ii===1)?labTable.slice(0, labTable.length/2):labTable.slice(labTable.length/2)" :key="'l'+i + ii">
			      		<td class="labCheckbox"><input type="checkbox" :id="'checkbox'+i+ii" v-model="labsSelected" :value="lab"></td>
			      		<td class="labLabel"><label :for="'checkbox'+i+ii" v-html="lab.name.replace(/ /g, '&nbsp;')"></label></td>
			      	</tr>
			      </table>
			    </div>
	      </div>
	      <div class="modal-footer" style="text-align: center;">
        	<button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
        	<button type="button" class="btn btn-default" @click="labsSelected = []">Clear</button>
        	<button type="button" class="btn btn-primary" @click="insertSelectedLabs">Insert Labs</button>
      	  </div>
	    </div>
	  </div>
	</div>
	
	<div id="videoSelect" class="modal fade bs-example-modal-sm" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel">
	  <div class="modal-dialog modal-lg" role="document">
	    <div class="modal-content text-center" style="padding: 10px;">
	    	<H4>Select Video To Insert</H4>
	    	<div class="modal-body">
	    		<div>Include caption? <input type="checkbox" v-model="videoIncludeCaption"></div>
	    		<table class="fileTable"> 
	    			<tr>
	    				<th>&nbsp;</th>
	    				<th>Name</th>
	    			</tr>
			      	<tr v-for="(file, i) in eligibleVideoFiles" :key="file.imageId" v-bind:class="[i%2==0?'even':'odd']">
			      		<td class="labLabel">{{file.description}}</label></td>
			      		<td class="labCheckbox"><button type="button" class="btn btn-link" @click="insertSelectedVideo(file)">Insert</button></td>
			      	</tr>
			    </table>
	      </div>
	      <div class="modal-footer" style="text-align: center;">
        	<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
      	  </div>
	    </div>
	  </div>
	</div>
	
	
</div>

</div> <!--  VueJS app -->
	
	
</form>

<div class="editorSectionDiv">
	<H4 class="sectionHeader">Step 4: Contributors</H4>
	<jsp:include page="editcaseAuthors.jsp"/>
</div>

<div class="editorSectionDiv">
	<H4 class="sectionHeader">Step 5: Assign Royal College Objectives of Training</H4>
	<jsp:include page="editcaseobjectives.jsp"/>
</div>

<div class="editorSectionDiv">
	<H4 class="sectionHeader" id="tagHeaderDiv" >Step 6: Assign Categories</H4>
	<jsp:include page="editcasetags.jsp"/>
</div>

<div class="editorSectionDiv">
	<H4 class="sectionHeader inactive" id="fileHeaderDiv" onclick="$('#fileList').toggle();$('#fileHeaderDiv').toggleClass('inactive');">Settings: Uploaded Files (Optional)</H4>
	<jsp:include page="editcasefiles.jsp"/>
</div>

<div class="editorSectionDiv">
	<H4 class="sectionHeader" id="commentHeaderDiv"  onclick="$('#commentsCont').toggle();$('#commentHeaderDiv').toggleClass('inactive');">Comments</H4>
	<div id="commentsCont" class="sectionContainer">
	<jsp:include page="../case/comment.jsp">
	        		<jsp:param name="showComment" value="true"/>
	        		<jsp:param name="newCommentsPrivate" value="true"/>
	</jsp:include>
	</div>
</div>

<br/><br/><br/>

</c:if>
<c:if test="${empty requestScope.icase }">
	<div style="margin-top: 60px; text-align: center; background-color: #E0F8F7;">
	Select case to edit on the left side.
	</div>
</c:if>


<!-- set up autocomplete and initiate the xml editor -->
   <script>
   
   var caseId = ${requestScope.icase.caseId }
   var exerciseId = ${requestScope.exerciseId }
   
   $(function() {
	   tinymce.init({ 
		   selector:'#questionHtml, #answerHtml',
		   inline: true,
		   plugins: "table link image lists advlist spellchecker fullscreen imagetools textcolor code save template",
		   insert_toolbar: 'quickimage quicktable',
		   //toolbar: 'undo redo | styleselect | bold italic | link image'
		   toolbar: [
    'save | undo redo | styleselect | bold underline italic forecolor removeformat | subscript superscript | alignleft aligncenter alignright',
    ' bullist numlist outdent indent  table addlabs addvideo | link image media fullscreen code spellchecker'
  				],
  		    table_toolbar: "tableprops tablecellprops tabledelete | tableinsertrowbefore tableinsertrowafter tabledeleterow tablerowprops | tableinsertcolbefore tableinsertcolafter tabledeletecol | tablemergecells tablesplitcells",
  		  	table_appearance_options: false,
  		  	table_class_list: [
  		    	{title: 'Default Lab Table', value: ''},
  		    	{title: 'Alternate Rows', value: 'alternateRows'}
  		  		],
  		  	table_cell_class_list: [
  		      {title: 'Default Cell', value: 'default'},
  		      {title: 'Abnormal Result', value: 'abnormalResult'}
  		    ],
  		    
  		    style_format: [
  		    	{title: 'Answer Header', selector: 'h3', styles: {color: 'red'} }
  		    ],
  		    
  		  	save_onsavecallback: function () { 
  		  		app.save();
  		  	},
  		  	
  		 	spellchecker_languages: 'English=en',
  		 	browser_spellcheck: true,
  		  	
  		 	table_default_styles: { //default table width
  		    	width: '400px'
  			},
  		  	
  		    apply_source_formatting: true,
			images_upload_url: 'images.do',
			automatic_uploads: true,
			image_caption: true,
			image_description: false,
			image_list: 'images.do?method=listTinyMce&caseid=' + $("#caseid").val(),
			//image upload function
			images_upload_handler: function (blobInfo, success, failure) {
		        var xhr, formData;
		      
		        xhr = new XMLHttpRequest();
		        xhr.withCredentials = false;
		        xhr.open('POST', 'images.do');
		      
		        xhr.onload = function() {
		            var json;
		        
		            if (xhr.status != 200) {
		                failure('HTTP Error: ' + xhr.status);
		                return;
		            }
		        
		            json = JSON.parse(xhr.responseText);
		        
		            if (!json || typeof json.location != 'string') {
		                failure('Invalid JSON: ' + xhr.responseText);
		                return;
		            }
		        
		            success(json.location);
		        };
		      
		        formData = new FormData();
		        formData.append('method', 'upload');
		        formData.append('caseid', $("#caseid").val());
		        formData.append('mode', 'tinymce');
		        formData.append('uploadFile', blobInfo.blob(), blobInfo.filename());
		      
		        xhr.send(formData);
		    },
		    media_live_embeds: true,
		    setup: function(editor) {
		    	editor.addButton('addlabs', {
				      icon: 'tablemergecells',
				      //image: 'http://p.yusukekamiyamane.com/icons/search/fugue/icons/calendar-blue.png',
				      tooltip: "Insert Lab Table",
				      onclick: insertLabTable
				});
		    	
	    	    function insertLabTable() {
	    	    	app.getLabTable(editor);
	    	      var html = tableHtml;
	    	      // editor.insertContent(html);
	    	    }
	    	    
	    	    
		    	editor.addButton('addvideo', {
				      icon: 'media',
				      //image: 'http://p.yusukekamiyamane.com/icons/search/fugue/icons/calendar-blue.png',
				      tooltip: "Insert Video",
				      onclick: insertVideo
				});
		    	function insertVideo() {
		    	    app.insertVideo(editor);
		    	    var html = tableHtml;
		    	      // editor.insertContent(html);
		    	}
		    }
  				
		   })
		   
   });
   
   var loginTimeoutWarn;
   var autosaveTimeout;
   
   function setLoginTimeout() {
   	loginTimeoutWarn = window.setTimeout(function () {
	   //Redirect with JavaScript
	   alert("Are you still there?  This session will expire in about 20min if you don't click ok");
   	}
	 , 1500000);
   	//, 7000); for testing
   }
   
   function setAutosaveTimeout() {
	   	setInterval(function () {
	 	   //Redirect with JavaScript
	 	   app.save();
	 	   $(".autosaveTimestamp").html(moment().format('MMMM Do YYYY, h:mm:ss a'));
	 	   //window.clearTimeout(autosaveTimeout);
	 	   //setAutosaveTimeout();
	 	   //alert("saved");
	    	}
	    	, 300000); // q5 min
   }
   
   
   /* function setAutosaveTimeout() {
	   	autosaveTimeout = window.setTimeout(function () {
	 	   //Redirect with JavaScript
	 	   app.save();
	 	   $(".autosaveTimestamp").html(moment().format('MMMM Do YYYY, h:mm:ss a'));
	 	   window.clearTimeout(autosaveTimeout);
	 	   setAutosaveTimeout();
	    	}
	    	, 30000);// 300000); // q5 min
  } */
   
   $(function()  {

	   	$("#openHx").click( function() {
	   		parent.$('#searchtextmodal').find('#filterSelectedBtn').hide();
	   	 	parent.$('#searchtextmodal').find('#insertSelectedBtn').hide();
	   	 	parent.$('#searchtextmodal').modal('show');
	   	 	parent.setModalHeight();
	   	 	//parent.$('#searchtextmodal').find('.modal-iframe').load($(this).data("load-url"));
	   	 	parent.$('#searchtextmodal').find('.modal-iframe').attr('src', $(this).data("load-url"));
	   	});
	   
	    $("#showDetails").on("click", function(){
	        $("#errorDetails").toggle();
	    });
	    
	   	$("#labTableButton").click( function() {
	   		//parent.$('#iframemodal').find('#modal-title').html("Lab Table");
	   	 	parent.$('#iframemodal').modal('show');
	   	 	parent.setModalHeight();
	   	 	//parent.$('#searchtextmodal').find('.modal-iframe').load($(this).data("load-url"));
	   	 	parent.$('#iframemodal').find('.modal-iframe').attr('src', $(this).data("load-url"));
	   	})
	   	
	   	$("#reportButton").click( function() {
	   		//parent.$('#iframemodal').find('#modal-title').html("Lab Table");
	   	 	parent.$('#iframemodal').modal('show');
	   	 	parent.setModalHeight();
	   	 	//parent.$('#searchtextmodal').find('.modal-iframe').load($(this).data("load-url"));
	   	 	parent.$('#iframemodal').find('.modal-iframe').attr('src', $(this).data("load-url"));
	   	})

	    setLoginTimeout();
		setAutosaveTimeout();
		
    });
   
   
	
	function showError(errorTitle, errorDetail) {
		$("#errorTitle").text(errorTitle);
		$("#errorDetail").text(errorDetail);
		$("#errorDiv").toggle();
	}
	
/*    function failSaveCaseText(reply, buttonElement) {
   		$(buttonElement).val("Failed!");
   		$(buttonElement).removeClass("loaderBg");
   		$(buttonElement).removeClass("btn-success");
   		$(buttonElement).addClass("btn-danger");
      	showError(reply['errorTitle'], reply['errorDetail']);
      	window.scrollTo(0, 0);
   } */
   
   

        
        //-- VUE STUFF
        
        var emailRE = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/


       tableHtml = "<table style=\"width: 370px; height: 597px;\" border=\"1\">\n<tbody>\n<tr style=\"height: 25px;\">\n<th style=\"height: 25px; width: 184px;\">Lab</th>\n<th style=\"height: 25px; width: 88px;\">Value</th>\n<th style=\"height: 25px; width: 98px;\">Unit</th>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"height: 26px; width: 184px;\">Hemoglobin</td>\n<td style=\"text-align: center; height: 26px; width: 88px;\">140</td>\n<td style=\"height: 26px; width: 98px;\">g/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">MCV</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">85</td>\n<td style=\"width: 98px; height: 26px;\">fL</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"height: 26px; width: 184px;\">WBC</td>\n<td style=\"height: 26px; width: 88px; text-align: center;\">14.5</td>\n<td style=\"height: 26px; width: 98px;\">x10<sup>9</sup>/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">&nbsp; Neutrophils</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">4.5</td>\n<td style=\"width: 98px; height: 26px;\">x10<span style=\"font-size: 10.5px; line-height: 0; position: relative; vertical-align: baseline; top: -0.5em; letter-spacing: 0.1px;\">9</span><span style=\"letter-spacing: 0.1px;\">/L</span></td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">&nbsp; Lymphocytes</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">2.1</td>\n<td style=\"width: 98px; height: 26px;\">x10<span style=\"font-size: 10.5px; line-height: 0; position: relative; vertical-align: baseline; top: -0.5em; letter-spacing: 0.1px;\">9</span><span style=\"letter-spacing: 0.1px;\">/L</span></td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Platelets</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">280</td>\n<td style=\"width: 98px; height: 26px;\">x10<span style=\"font-size: 10.5px; line-height: 0; position: relative; vertical-align: baseline; top: -0.5em; letter-spacing: 0.1px;\">9</span><span style=\"letter-spacing: 0.1px;\">/L</span></td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Na+</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">138</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Cl-</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">107</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">K+</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">4.1</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">HCO3</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">24</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Creatinine</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">68</td>\n<td style=\"width: 98px; height: 26px;\">umol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Mg++</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">0.81</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Ca++</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">2.3</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">PO4</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">1.2</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Albumin</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">38</td>\n<td style=\"width: 98px; height: 26px;\">g/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">AST</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">35</td>\n<td style=\"width: 98px; height: 26px;\">IU/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">ALT</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">28</td>\n<td style=\"width: 98px; height: 26px;\">IU/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">ALP</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">82</td>\n<td style=\"width: 98px; height: 26px;\">IU/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Total Bilirubin</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">8</td>\n<td style=\"width: 98px; height: 26px;\">umol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">&nbsp; Conjugated Bilirubin</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">3</td>\n<td style=\"width: 98px; height: 26px;\">umol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">INR</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">1.1</td>\n<td style=\"width: 98px; height: 26px;\">&nbsp;</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">TSH</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">2.1</td>\n<td style=\"width: 98px; height: 26px;\">mIU/L</td>\n</tr>\n</tbody>\n</table>";
       

        
    </script>
<script type="text/javascript" src="js/labtable.js"></script>
<script type="text/javascript" src="js/editcasemcq.js"></script>



</div>
</body>
</html>