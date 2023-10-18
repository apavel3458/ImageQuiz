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
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-ui.min.js"></script>
        <script src="../jslib/bootstrap.min.js"></script>
        <script src="../jslib/imagequiz.js"></script>
        <script src="../jslib/moment.min.js"></script>
        <script src="js/vue.js"></script>

        <link href="../css/fonts/font-awesome-512/css/all.min.css" rel="stylesheet">

        
	<!-- Include Editor style. -->
    <!-- Include external CSS. -->

    <link rel="stylesheet" type="text/css" href="<c:url value="/css/case/comments.css"/>" >

 
    <!-- Include Editor style. -->
    
    

	 
	<!-- Include JS file. -->
    <!-- Include external JS libs. -->

 
    <!-- Include Editor JS files. -->
    <script src="js/tinymce/tinymce.min.js"></script>
	

		<link rel="stylesheet" href="../css/lib/bootstrap.paper.min.css">
		<link rel="stylesheet" href="admin.css?v=1">
		<link rel="stylesheet" href="css/editcase.css">
		
		<!-- To make editor feel like the real thing -->
    	<link rel="stylesheet" href="../css/case/casedisplay.css">
		

		<script type="text/javascript">
		function previewCase(caseid) {
			window.open("../case/case.do?method=testCase&mode=<%=org.imagequiz.model.IQExam.EXAM_MODE_TEST%>&caseid="+ caseid, "Case Preview", "toolbar=no, scrollbars=yes, resizable=yes, width=1000, height=800");
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
<input type="hidden" name="caseTypeInterface" value="sg">
<input type="hidden" name="caseid" id="caseid" value="<c:out value="${requestScope.icase.caseId }"/>">
<input type="hidden" name="exerciseid" id="exerciseid" value="<c:out value="${requestScope.exerciseId }"/>">
<input type="button" class="btn btn-default btn-xs" data-load-url="admin.do?method=showCaseHx&caseid=${requestScope.icase.caseId}" id="openHx" value="Hx" 
	style="color: white; border: none; box-shadow: none; z-index:10; position: absolute;">
	
<div class="contrainer-fluid">
	<div class="row">
		
		<div class="col-sm-3">
			&nbsp;
			<c:if test="${not empty requestScope.lastRevision }">
				<div class="revisionDiv">
				<span class="heading">Initial Author: </span> ${requestScope.initialAuthor.author }<br/>
				<span class="heading">Last Revision:</span> ${requestScope.lastRevision.author} <br/>
				<span class="heading">Date: </span> <fmt:formatDate pattern = "MMM dd, yyyy hh:mm a" value = "${requestScope.lastRevision.datetime}" />
				</div>
			</c:if>
		</div>
		<div class="col-sm-6">
			<div class="caseTitle">
				<input type="text" class="caseTitleInput" name="casename" id="caseName" value="<c:out value="${requestScope.icase.caseName }"/>">
				<div class="caseTitleCaption">case title</div>
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



	<div class="editorSectionDiv">
		<H4 class="sectionHeader">Step 1: Question Text</H4>
		<div id="questionHtml" class="caseText fr-view adminCaseText" name="questionHtml"><c:out value="${requestScope.questionHtml }" escapeXml="false"/></div>
	</div>

	<div class="editorSectionDiv">
		<H4 class="sectionHeader">Step 2: SG Options</H4>
		<!-- THIS IS WHERE SGQ IS MADE -->
		<div id="mcqchoices" class="mcqDiv">
		  <table class="mcq-choice-table sg-choice-table">
		  	<tr>
		  		<th colspan="2">Question Text:</th>
		  		<td><input type="text" class="form-control" placeholder="Question Text (optional)" style="width: 400px; display: inline-block;"></td>
		  	</tr>
		  	<tr>
		  		<th></th>
		  		<th>Scores if selected<br/>(+ or -)</th>
		  		<th>Score if missed<br/>(+ or -)</th>
		  		<th>Primary<br/>Dx?</th>
		  		<th>Alternative Choice<br/>(to choice above it)</th>
		  		<th>Text</th>
		  	</tr>
		  	<tr v-for="(choice, index) in sg">
		  		<td class="sg-choice-td-index" 
		  			:class="[answerOptionCSS(choice), 
		  						{'oneOrOther':choice.or}, 
		  						{'oneOrOtherInitial':(sg[index+1] && sg[index+1].or)}
		  					]"><span v-if="choice.or">or </span>{{numberToLetter(index)}}</td>
		  		<td class="mcq-choice-td-score"><input type="number" v-model="choice.score" class="sgScoreInput" :class="answerOptionCSS(choice)"></td>
		  		<td class="mcq-choice-td-score"><input type="number" v-model="choice.missed" class="sgScoreInput" :class="answerOptionCSS(choice)"></td>
		  		<td class="sg-choice-td-check"><input type="checkbox" v-model="choice.primary" 
		  											@click="editDefaultScore(choice)"
		  											:class="answerOptionCSS(choice)"></input></td>
		  		<td class="sg-choice-td-check"><input type="checkbox" v-model="choice.or" :class="answerOptionCSS(choice)"></input></td>
		  		<td class="sg-choice-td-input" v-bind:class="{'has-success': choice.correct}">
		  			<input type="text" v-model.lazy.trim="choice.text" disabled placeholder="Choice Text" class="choiceTextInput" :class="answerOptionCSS(choice)" style="width: 100%;">
		  		</td>
		  		<td class="mcq-choice-td-remove nopadding">
		    		<button v-on:click.prevent="removeChoice(index)" class="btn btn-default btn-xs sgRemoveButton">X</button>
		    		<i class="glyphicon glyphicon-arrow-up upIcon clickable" 
		    			@click.prevent="moveUp(choice)" aria-hidden="true"
		    			v-if="index!=0"></i>
		    		<i class="glyphicon glyphicon-arrow-down downIcon clickable" 
		    			@click.prevent="moveDown(choice)" aria-hidden="true"
		    			v-if="index!=sg.length-1"></i>
		    	</td>
		  	</tr>
		  	<tr>
		  		<td colspan="4"><button @click.prevent="addAnswer" class="btn btn-default btn-xs">Add Choice</button></td>
		  		<!-- button class="btn btn-primary btn-xm" data-load-url="searchterm.do" id="searchTermDialogueButton" @click.prevent="addAnswer">Add Answer</button-->
		  	</tr>
		  	</table>
		  	
		  	<div class="extras">
			  	<div class="extra">
			  		<span class="extraTitle">Group Choices: </span>
			  		<input type="text" v-model="qOptions.groups" style="width: 200px; padding-left:5px;">
			  	</div>
			  	<div class="extra">
			  		<span class="extraTitle">Pass Score: </span>
			  		<input type="number" v-model="qOptions.passScore" class="sgScoreInput"> <button @click.prevent="automatePassScore()" class="btn btn-default btn-xs">Calculate</button>
			  		<span class="extraTitle offset">Wrong Choice Penalty:</span>
			  		<input type="number" v-model="qOptions.wrongChoiceScore" class="sgScoreInput">
			  	</div>
			</div>
		  <input type="hidden" name="sgData" id='sgData' v-model="sgData" style="width: 100%">
		  
		</div>
	</div>

<!-- THIS IS WHERE MCQ IS MADE -->

	<div class="editorSectionDiv">
		<H4 class="sectionHeader">Step 3: Answer Text</H4>
		<div id="answerHtml" name="answerHtml" class="caseText fr-view adminCaseText"><c:out value="${requestScope.answerHtml }" escapeXml="false"/></div>
	</div>

	<div class="caseEditControls">
		<!-- Can uncomment the next line if need another button, but now that tinymce handles it, there is no need -->
		<input type="button" class="btn btn-success btn-sm" id="saveCaseTextButton" style="margin-left: 5px;" value="Save Case Text and MCQ">
		&nbsp;
		<input type="button" class="btn btn-info btn-sm" onclick="previewCase('<c:out value="${requestScope.icase.caseId }"/>');" value="Preview Saved Case">
		<button class="btn btn-info btn-sm" type="button" id="labTableButton" data-load-url="resources/RCReferenceValues.pdf"><i class="fa fa-flask"></i></button>
		<div class="btn-group dropup">
			<a href="#" class="btn btn-primary btn-sm dropdown-toggle" data-toggle="dropdown">Change Interface<span class="caret"></span></a>
			<ul class="dropdown-menu">
					<li class="active"><a href="#">MCQ Editor</a></li>
					<li class="disabled"><a href="#" onclick="">ECG Editor</a></li>
					<li><a href="#" onclick="document.location='admin.do?method=viewCase&caseid=${requestScope.icase.caseId }&exerciseid=${requestScope.exerciseId }&editor=xml'">XML Editor</a></li>
			</ul>
		</div>
	</div>
	
</div>
	
	
</form>

<div class="editorSectionDiv">
	<H4 class="sectionHeader">Step 4: Assign Royal College Objectives of Training</H4>
	<jsp:include page="editcaseobjectives.jsp"/>
</div>

<div class="editorSectionDiv">
	<H4 class="sectionHeader" id="tagHeaderDiv" >Step 5: Assign Categories</H4>
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
   $(function() {
	   tinymce.init({ 
		   selector:'#questionHtml, #answerHtml',
		   inline: true,
		   plugins: "table link image lists advlist spellchecker fullscreen imagetools textcolor code save template",
		   insert_toolbar: 'quickimage quicktable',
		   //toolbar: 'undo redo | styleselect | bold italic | link image'
		   toolbar: [
    'save | undo redo | styleselect | bold underline italic forecolor removeformat | subscript superscript | alignleft aligncenter alignright',
    ' bullist numlist outdent indent  table addlabs | link image fullscreen code spellchecker'
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
  		  		saveCaseText($("#saveCaseTextButton"));
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
		    setup: function(editor) {
		    	editor.addButton('addlabs', {
				      icon: 'tablemergecells',
				      //image: 'http://p.yusukekamiyamane.com/icons/search/fugue/icons/calendar-blue.png',
				      tooltip: "Insert Lab Table",
				      onclick: insertLabTable
				    });
		    	    
		    	    function insertLabTable() {
		    	      var html = tableHtml;
		    	      editor.insertContent(html);
		    	    }
		    }
  				
		   })
		   
   });
   
   var loginTimeoutWarn;
   
   function setLoginTimeout() {
   	loginTimeoutWarn = window.setTimeout(function () {
	   //Redirect with JavaScript
	   alert("You have 5 minutes to save your data.  You will be logged out after 30 minutes of inactivity");
   	}
	 , 1500000);
   	//, 7000); for testing
   }
   
   $(function()  {

	   	$("#openHx").click( function() {
	   		parent.$('#searchtextmodal').find('#filterSelectedBtn').hide();
	   	 	parent.$('#searchtextmodal').find('#insertSelectedBtn').hide();
	   	 	parent.$('#searchtextmodal').modal('show');
	   	 	parent.setModalHeight();
	   	 	//parent.$('#searchtextmodal').find('.modal-iframe').load($(this).data("load-url"));
	   	 	parent.$('#searchtextmodal').find('.modal-iframe').attr('src', $(this).data("load-url"));
	   	});
	   	
	    $("#saveCaseTextButton").click(function( event ) {
		    saveCaseText(event.target);
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


	    setLoginTimeout();

		
    });
   
   
	
	function showError(errorTitle, errorDetail) {
		$("#errorTitle").text(errorTitle);
		$("#errorDetail").text(errorDetail);
		$("#errorDiv").toggle();
	}
	
   function failSaveCaseText(reply, buttonElement) {
   		$(buttonElement).val("Failed!");
   		$(buttonElement).removeClass("loaderBg");
   		$(buttonElement).removeClass("btn-success");
   		$(buttonElement).addClass("btn-danger");
      	showError(reply['errorTitle'], reply['errorDetail']);
      	window.scrollTo(0, 0);
   }
   
   

        
        //-- VUE STUFF
        
        var emailRE = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
		
        var initialSGData = ${requestScope.sgData}
        var initialQOptions = ${requestScope.qOptions}
        
		// Setup Firebase

		// create Vue app
		var app = new Vue({
  				// element to mount to
  				el: '#mcqchoices',
  				// initial data
  				data: {
					//sg: ${requestScope.sgData},
					sg: [
						//{score: 1, missed: 0, primary: false, or: false, text:'Left Bundle Branch Block (LBBB)', group:'level1'}
						],
					qOptions: {
						passScore: 1,
						wrongChoiceScore: 0,
						groups: ''
					},
					
					errorTitleV: '',
					errorDetailsV: ''
  				},
  				created: function() {
  				},
  				
  				// firebase binding
  				// https://github.com/vuejs/vuefire
  			
  			// computed property for form validation state
  			computed: {},
  		// methods
	  		methods: {
	    		addAnswer: function () {
	    	   		parent.launchSearchTextModal('sgInsertAnswer');  	   	 	
	    		},
	    		removeChoice: function (i) {
	      			this.sg.splice(i, 1);
	    		},
	    		numberToLetter: function (number) {
	  				return String.fromCharCode(65 + number);
	  			},
	  			insertAnswerChoices: function (selectedItems, itemGroup) {
	  				var optimalPassScoreBefore = this.calculateOptimalPassScore();
	  				//alert(optimalPassScoreBefore);
	  				var automatePassScore = false; //automate unless user changed it manually
	  				if (optimalPassScoreBefore == this.qOptions.passScore) {
						automatePassScore = true;
	  				}
		
	  				for (var i=0; i<selectedItems.length; i++) {
	  					//default settings
	  					this.sg.push({
	  						'score': 1, 
	  						'primary': true, 
	  						'missed': 0, or: false, 
	  						'text': selectedItems[i], 
	  						'group': itemGroup
	  						});
	  				}
	  				this.addGroupIfNotExist(itemGroup);
	  				
	  				if (automatePassScore) {
	  					var optimalPassScoreAfter = this.calculateOptimalPassScore();
	  					this.qOptions.passScore = optimalPassScoreAfter;
	  				}
	  			},
	  			calculateOptimalPassScore: function () {
	  				var primaryScoreSum = 0;
	  				for (var i=0; i< this.sg.length; i++) {
	  					if (this.sg[i].primary && !this.sg[i].or) {
	  						primaryScoreSum += this.sg[i].score;
	  					}
	  				}
	  				return primaryScoreSum;
	  			},
	  			automatePassScore: function () {
	  				this.qOptions.passScore = this.calculateOptimalPassScore();
	  			},
	  			addGroupIfNotExist: function (group) {
	  				var groupsA = this.qOptions.groups.split(",");
	  				var found = false;
	  				for (var i=0; i<groupsA.length; i++) {
	  					if (groupsA[i].trim() == group) found = true;
	  				}
	  				if (!found) {
	  					if (this.qOptions.groups.trim().length != 0) this.qOptions.groups += ", ";
	  					this.qOptions.groups += group;
	  				}
	  			},
	  			answerOptionCSS: function(choice) {
	  				if (choice.score<0) return 'incorrect';
	  				if (choice.primary) return 'primary';
	  				if (!choice.primary) return 'secondary';
	  				//if (choice.or) return 'optional';
	  			},
	  			editDefaultScore: function(choice) {
	  				if (!choice.primary) choice.score=1;
	  				else choice.score=0.25;
	  			},
	  			moveUp: function(choice) {
	  				var i = this.sg.indexOf(choice)
	  				this.sg.splice(i, 1)
	  				this.sg.splice(i-1, 0, choice)
	  			},
	  			moveDown: function(choice) {
	  				var i = this.sg.indexOf(choice)
	  				this.sg.splice(i, 1)
	  				this.sg.splice(i+1, 0, choice)
	  			},
	  			getSGData: function() {
	  				return this.sg
	  			},
	  			getqOptions: function() {
	  				return this.qOptions
	  			}
	  			//v-bind:class="[{primary: choice.primary},{incorrect: choice.score<0},{optional: choice.or}]"
	  		},
	  		computed: {
	  			choiceData: function () {
	  				return JSON.stringify(this.sg);
	  			}
	  		},
	  		mounted() {
	  			if (initialSGData && initialSGData.length > 0)
	  				this.sg = initialSGData;
	  			if (initialQOptions && Object.keys(initialQOptions).length > 0)
	  				this.qOptions = initialQOptions;
	  		}
		})
        
        

        
        
        
       function restoreSaveButton() {
        	$("#saveCaseTextButton").removeClass("loaderBg");
        	$("#saveCaseTextButton").removeClass("btn-danger");
       		$("#saveCaseTextButton").addClass("btn-success");
        	$("#saveCaseTextButton").disabled = false;
        	$("#saveCaseTextButton").val("Save Case Content");
        }
        
       function insertAnswerChoices(selectedItems, group) { //called by editExercise.jsp, just ports the call to Vue
    	   app.insertAnswerChoices(selectedItems, group)
       }
        
       function saveCaseText(button) { 
        	$(button).addClass("loaderBg");
        	$(button).disabled = true;
        	console.log(JSON.stringify(app.getSGData()));
        	
	    	$.ajax({
	            url: "../admin/admin.do",
	            data: {
	                method: 'updateCaseAjax',
	                caseTypeInterface: 'sg',
	                caseid: $("#caseid").val(),
	                exerciseid: $("#exerciseid").val(),
	                casename: $("#caseName").val(),
	                questionHtml: $("#questionHtml").html(),
	                qData: JSON.stringify(app.getSGData()),
	                qOptions: JSON.stringify(app.getqOptions()),
	                answerHtml: $("#answerHtml").html()
	            },
	            type: "POST",
	            dataType: "html",
	            success: function (data) {
	            	reply = JSON.parse(data);
	            	
	            	if (reply['success'] == true) { 
	            		//$(e.target).val("Saved!")
	            		parent.app.updateActiveCase();
	            	}
	            	else {
	            		//alert(reply['errorTitle']);
	            		failSaveCaseText(reply, button);
	            	}
	            },
	            error: function (xhr, status) {
	            	failSaveCaseText(JSON.parse(xhr.responseText), button);	                
	            },
	            complete: function (xhr, status) {
	            	setTimeout(restoreSaveButton, 750);
	            	window.clearTimeout(loginTimeoutWarn);
	            	setLoginTimeout();
	            	//restoreSaveButton();
	            }
	        });
        }
       
       tableHtml = "<table style=\"width: 370px; height: 597px;\" border=\"1\">\n<tbody>\n<tr style=\"height: 25px;\">\n<th style=\"height: 25px; width: 184px;\">Lab</th>\n<th style=\"height: 25px; width: 88px;\">Value</th>\n<th style=\"height: 25px; width: 98px;\">Unit</th>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"height: 26px; width: 184px;\">Hemoglobin</td>\n<td style=\"text-align: center; height: 26px; width: 88px;\">140</td>\n<td style=\"height: 26px; width: 98px;\">g/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">MCV</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">85</td>\n<td style=\"width: 98px; height: 26px;\">fL</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"height: 26px; width: 184px;\">WBC</td>\n<td style=\"height: 26px; width: 88px; text-align: center;\">14.5</td>\n<td style=\"height: 26px; width: 98px;\">x10<sup>9</sup>/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">&nbsp; Neutrophils</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">4.5</td>\n<td style=\"width: 98px; height: 26px;\">x10<span style=\"font-size: 10.5px; line-height: 0; position: relative; vertical-align: baseline; top: -0.5em; letter-spacing: 0.1px;\">9</span><span style=\"letter-spacing: 0.1px;\">/L</span></td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">&nbsp; Lymphocytes</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">2.1</td>\n<td style=\"width: 98px; height: 26px;\">x10<span style=\"font-size: 10.5px; line-height: 0; position: relative; vertical-align: baseline; top: -0.5em; letter-spacing: 0.1px;\">9</span><span style=\"letter-spacing: 0.1px;\">/L</span></td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Platelets</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">280</td>\n<td style=\"width: 98px; height: 26px;\">x10<span style=\"font-size: 10.5px; line-height: 0; position: relative; vertical-align: baseline; top: -0.5em; letter-spacing: 0.1px;\">9</span><span style=\"letter-spacing: 0.1px;\">/L</span></td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Na+</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">138</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Cl-</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">107</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">K+</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">4.1</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">HCO3</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">24</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Creatinine</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">68</td>\n<td style=\"width: 98px; height: 26px;\">umol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Mg++</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">0.81</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Ca++</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">2.3</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">PO4</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">1.2</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Albumin</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">38</td>\n<td style=\"width: 98px; height: 26px;\">g/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">AST</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">35</td>\n<td style=\"width: 98px; height: 26px;\">IU/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">ALT</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">28</td>\n<td style=\"width: 98px; height: 26px;\">IU/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">ALP</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">82</td>\n<td style=\"width: 98px; height: 26px;\">IU/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Total Bilirubin</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">8</td>\n<td style=\"width: 98px; height: 26px;\">umol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">&nbsp; Conjugated Bilirubin</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">3</td>\n<td style=\"width: 98px; height: 26px;\">umol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">INR</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">1.1</td>\n<td style=\"width: 98px; height: 26px;\">&nbsp;</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">TSH</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">2.1</td>\n<td style=\"width: 98px; height: 26px;\">mIU/L</td>\n</tr>\n</tbody>\n</table>";
       

        
    </script>



</div>
</body>
</html>