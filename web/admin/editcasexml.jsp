<%@ page language="java" contentType="text/html; charset=US-ASCII"
    pageEncoding="US-ASCII"%>
    
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Edit Case</title>
        <link rel="stylesheet" href="admin.css?v=1">
        
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-ui.min.js"></script>
        <script src="../jslib/bootstrap.min.js"></script>
        <script src="../jslib/imagequiz.js"></script>
        <script src="../jslib/moment.min.js"></script>
        
        <!--  Code Mirror includes -->
		<link rel="stylesheet" href="../jslib/codemirror/lib/codemirror.css">
		<link rel="stylesheet" href="../jslib/codemirror/addon/hint/show-hint.css">
		<link rel="stylesheet" href="../css/lib/bootstrap.paper.min.css">
		<link rel="stylesheet" href="css/editcase.css">
		<!-- To make editor feel like the real thing -->
    	<link rel="stylesheet" href="../css/case/casedisplay.css">
		<link rel="stylesheet" type="text/css" href="<c:url value="/css/case/comments.css"/>" >
		
		
		<script src="../jslib/codemirror/lib/codemirror.js"></script>
		<script src="../jslib/codemirror/addon/hint/show-hint.js"></script>
		<script src="../jslib/codemirror/addon/hint/xml-hint.js"></script>
		<script src="../jslib/codemirror/mode/xml/xml.js"></script>
		<script src="js/vue.js"></script>
		
		

		
		<style type="text/css">
			.CodeMirror { 
				border: 1px solid #eee;
				height: 100%;
				width: 100%;
			}
			.CodeMirror-scroll {height: 100%; overflow-y: auto; overflow-x: auto;} 
			html, body { height: 100%; }
		</style>
		<script type="text/javascript">
		function previewCase(caseid) {
			window.open("../case/case.do?method=testCase&mode=<%=org.imagequiz.model.IQExam.EXAM_MODE_TEST%>&caseid="+ caseid, "Case Preview", "toolbar=no, scrollbars=yes, resizable=yes, width=800, height=800");
		}
		</script>
</head>
<body>

<div class="message"><c:out value="${requestScope.message }"/></div>
<div class="error"><c:out value="${requestScope.error }"/></div>

<c:if test="${not empty requestScope.icase }">

<form action="admin.do" method="POST">
<input type="hidden" name="method" value="updateCase">
<input type="hidden" name="caseid" value="<c:out value="${requestScope.icase.caseId }"/>">
<input type="hidden" name="exerciseid" id="exerciseid" value="<c:out value="${requestScope.exerciseId }"/>">
<input type="hidden" name="caseTypeInterface" value="xml">
Name: <input type="text" size="30" name="casename" value="<c:out value="${requestScope.icase.caseName }"/>">

  <c:if test="${not empty sessionScope.exception}">
  	<div class="alert alert-warning alert-dismissable caseError" role="alert">
  		<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
					Error: <%=((Exception) session.getAttribute("exception")).getMessage() %> 
					<a href="#" class="btn btn-warning btn-xs" style="margin-left: 20px;" id="showDetails">Show Details?</a>
	</div>
	<div class="alert alert-warning alert-dismissable caseError errorDetails" id="errorDetails" hidden="hidden" rule="alert">
		<a href="#" class="close" data-hide="errorDetails" aria-label="close">&times;</a>
					Error: <%--((Exception) request.getAttribute("exception")).printStackTrace(response.getWriter()); --%>
<pre>
<jsp:scriptlet>
((Exception) session.getAttribute("exception")).printStackTrace(new java.io.PrintWriter(out));
session.removeAttribute("exception");
</jsp:scriptlet>
</pre>

	</div>
  </c:if>

<textarea id="casexml" name="casexml" style="width: 50%;"><c:out value="${requestScope.xml }"/></textarea>

<div class="caseEditControls">
	<input type="Submit" class="btn btn-success btn-sm" style="margin-left: 5px;" value="Save">
	<input type="button" class="btn btn-info btn-sm" onclick="previewCase('<c:out value="${requestScope.icase.caseId }"/>');" value="Preview Saved Case">
	&nbsp; &nbsp;
	<div class="btn-group dropup">
		<a href="#" class="btn btn-primary btn-sm dropdown-toggle" data-toggle="dropdown">Change Interface<span class="caret"></span></a>
		<ul class="dropdown-menu">
				<li><a href="#" onclick="document.location='admin.do?method=viewCase&caseid=${requestScope.icase.caseId }&exerciseid=${requestScope.exerciseId }&editor=mcq'">MCQ Editor</a></li>
				<li><a href="#" onclick="document.location='admin.do?method=viewCase&caseid=${requestScope.icase.caseId }&exerciseid=${requestScope.exerciseId }&editor=sg'">SG Editor</a></li>
				<li class="disabled"><a href="#" onclick="">ECG Editor</a></li>
				<li class="active"><a href="#" onclick="">XML Editor</a></li>
		</ul>
	</div>
	
	<input type="button" class="btn btn-primary btn-sm" data-load-url="searchterm.do" id="searchTermDialogueButton" value="Insert Answer Options">
	<button type="button" class="btn btn-primary btn-sm" data-toggle="modal" data-target="#insertQuestionModal">Insert Question</button>
</div>
</form>



<!-- Modal FOR INSERTING QUESTION -->
<div id="insertQuestionModal" class="modal fade" role="dialog">
  <div class="modal-dialog">
    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Insert Question</h4>
      </div>
      <div class="modal-body">
		    <div class="btn-group">
		      <a href="#" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
		        Select question type
		        <span class="caret"></span>
		      </a>
		      <ul class="dropdown-menu">
		        <li><a href="#" onclick="insertQuestion('searchtext')">Search-Text Question</a></li>
		        <li><a href="#" onclick="insertQuestion('mcq')">Multiple Choice Question</a></li>
		        <li><a href="#" onclick="insertQuestion('text')">Text Question</a></li>
		       </ul>
		    </div>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
      </div>
    </div>

  </div>
</div>

<div class="editorSectionDiv">
	<H4 class="sectionHeader inactive" id="tagHeaderDiv" onclick="$('#tagContainer').toggle();$('#tagHeaderDiv').toggleClass('inactive');">Step 5: Assign Categories</H4>
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
	</jsp:include>
	</div>
</div>


<br/>
<br/>
<br/>
<br/>
</c:if>
<c:if test="${empty requestScope.icase }">
	<div style="margin-top: 60px; text-align: center; background-color: #E0F8F7;">
	Select case to edit on the left side.
	</div>
</c:if>


<!-- set up autocomplete and initiate the xml editor -->
   <script>
   
   $(function()  {
	   
	   
	   	$("#searchTermDialogueButton").click( function() {
	   		parent.$('#searchtextmodal').find('#filterSelectedBtn').hide();
	   	 	parent.$('#searchtextmodal').find('#insertSelectedBtn').show();
	   	 	parent.$('#searchtextmodal').modal('show');
	   	 	parent.setModalHeight();
	   	 	//parent.$('#searchtextmodal').find('.modal-iframe').load($(this).data("load-url"));
	   	 	parent.$('#searchtextmodal').find('.modal-iframe').attr('src', $(this).data("load-url"));
	   	})
	   	
	   	
	   	
		 
		parent.$('#searchtextmodal').on('hidden.bs.modal',function(){  
		   	  	$(this).find('iframe').attr('src','');
		})
		

		function rescale(){
	   		//ensure modal takes up a certain height based on window height
		    parent.$('.modal-body.maxHeight').css('height', $(window).height() - 20);
		}
		$(window).bind("resize", rescale);
		
		$(function(){
		    $("[data-hide]").on("click", function(){
		        $(this).closest("#" + $(this).attr("data-hide")).hide();
		    });
		});
		
		$(function(){
		    $("#showDetails").on("click", function(){
		        $("#errorDetails").toggle();
		    });
		});
		
    });
   
   
      var dummy = {
        attrs: {
          color: ["red", "green", "blue", "purple", "white", "black", "yellow"],
          size: ["large", "medium", "small"],
          description: null
        },
        children: []
      };

      var tags = {};
      /*
      var tags = {
        answer: {
          attrs: {
            primary: ["true", "false"],
        	correct: ["1", "0"],
            incorrect: ["0", "-1"],
            missed: ["0", "-1"],
      		item: [
      			<c:forEach var="item" items="${availableSearchTerms}" varStatus="loop">
      			"${item.searchTermString}" <c:if test="${!loop.last}">,</c:if>
      			</c:forEach>
      		]
          },
          children: ["answer"]
          }
        //wings: dummy, feet: dummy, body: dummy, head: dummy, tail: dummy,
        //leaves: dummy, stem: dummy, flowers: dummy
      };
      */
      
      var items = 
    		  ["test", "tests"];
      


      
      function completeAfter(cm, pred) {
        var cur = cm.getCursor();
        if (!pred || pred()) setTimeout(function() {
          if (!cm.state.completionActive)
            CodeMirror.showHint(cm, CodeMirror.hint.xml, {schemaInfo: tags, completeSingle: false});
        }, 100);
        return CodeMirror.Pass;
      }

      function completeIfAfterLt(cm) {
        return completeAfter(cm, function() {
          var cur = cm.getCursor();
          return cm.getRange(CodeMirror.Pos(cur.line, cur.ch - 1), cur) == "<";
        });
      }

      function completeIfInTag(cm) {
        return completeAfter(cm, function() {
          var tok = cm.getTokenAt(cm.getCursor());
          if (tok.type == "string" && (!/['"]/.test(tok.string.charAt(tok.string.length - 1)) || tok.string.length == 1)) return false;
          var inner = CodeMirror.innerMode(cm.getMode(), tok.state).state;
          return inner.tagName;
        });
      }
      
      function insertQuestion(insert) {
    	  $('#insertQuestionModal').modal('toggle');
    	  if (insert == "searchtext") {
    		  var text = "    <question id=\"abnormalities\" type=\"search_term\" searchgroups=\"level1,devices1\" pass-score=\"1\" wrong-choice-score=\"0\">\n"
    		  			+"        <question-text>Identify Abnormalities:</question-text>\n"
    		   			+"        <answer score=\"+1\" primary=\"1\">3rd Degree AV Block (Narrow Complex Escape)</answer>\n"
    		  			+"    </question>\n";
    		  insertTextAtCursor(text);
    	  } else if (insert == "mcq") {
    		  var text = "     <question id=\"mcq\" selections=\"1\" type=\"choice\" wrong-choice-score=\"0\" pass-score=\"1\">\n"
		  			+"        <question-text>Identify Abnormalities:</question-text>\n"
    		    +"        <choice score=\"+1\" correct=\"1\">3rd Degree AV Block (Narrow Complex Escape)</choice>\n"
		  			+"    </question>";
    		  insertTextAtCursor(text);
    	  } else if (insert == "text") {
    		  var text = "    <question id=\"txt\" type=\"text\" lines=\"3\">\n"
  		  			+"        <question-text>Write text:</question-text>\n"
  		  			+"    </question>";
    		  insertTextAtCursor(text);
    	  }
    	  
      }
      
      if (document.getElementById("casexml") != null) {
	      var editor = CodeMirror.fromTextArea(document.getElementById("casexml"), {
	        mode: "xml",
	        lineNumbers: true,
	        lineWrapping: true,
	        extraKeys: {
	          "'<'": completeAfter,
	          "'/'": completeIfAfterLt,
	          "' '": completeIfInTag,
	          "'='": completeIfInTag,
	          "Ctrl-Space": function(cm) {
	            CodeMirror.showHint(cm, CodeMirror.hint.xml, {schemaInfo: tags});
	          }
	        }
	      });
      }
      
      var heightOffset = 60;
      <c:if test="${not empty requestScope.exception}">
      		heightOffset = 100;
      </c:if>
      
      if (editor) {
      var browserHeight = 
    	  document.documentElement.clientHeight; 
    	        editor.getWrapperElement().style.height = (browserHeight-heightOffset)  //60 is flush
    	  + 'px'; 
    	  editor.refresh(); 
    	// store it
    	$('#casexml').data('CodeMirrorInstance', editor);
      }
    	
		function refreshEditorHeight() {
			var newHeight = document.documentElement.clientHeight - heightOffset;  //60 is flush
			if ($("#casexml").length != 0) {
				//$("#casexml").height(height-200);
				var cm = $('#casexml').data('CodeMirrorInstance');
				cm.getWrapperElement().style.height = newHeight + 'px';
		    	//cm.refresh(); 
		    	$('#casexml').data('CodeMirrorInstance', editor);
			}
		}
		
		function insertAnswerChoices(selectedItems) {
			var output = '';
			for (var i=0; i<selectedItems.length; i++) {
				st = selectedItems[i];
				output = output + "\t\t<answer score=\"+1\" primary=\"1\">" + st + "</answer>\n"
			}
			insertTextAtCursor(output);
		}
    	
    	
        function insertTextAtCursor(text) {
          if ($("#casexml").length != 0) {
      	  	  var cm = $('#casexml').data('CodeMirrorInstance');
      	  	  cm.replaceSelection(text);
          } else {
        	  alert("Please select a case.");
          }
        }
        
        
        function viewSearchGroup() {
        	var selectedGroupId = $("#searchGroupSelect").val();
        	var url = "";
        	if (selectedGroupId == "") {
        		alert("Please select a search group to view/edit");
        		return;
        	}
        	if (selectedGroupId == "new") {
        		url = "admin.do?method=viewSearchGroup";
        	} else {
        		url = "admin.do?method=viewSearchGroup&groupid=" + selectedGroupId;
        	}
        	
        	window.open(url, "_blank", "toolbar=no, scrollbars=yes, resizable=yes, top=50, left=50, width=600, height=500");
        	
        }
        


    </script>



</body>
</html>