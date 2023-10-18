<%-- 
    Document   : case
    Created on : Jul 11, 2013, 6:34:31 PM
    Author     : apavel
--%>

<!DOCTYPE html>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="org.imagequiz.model.question.*, java.util.List, java.util.HashMap, java.util.Map, java.util.HashSet, org.imagequiz.model.*,org.imagequiz.model.question.IQQuestion"%>
<%@ page import="org.apache.struts.Globals" %>
<%@ page import="org.apache.struts.taglib.html.Constants" %>
<%
    HashMap<String, HashSet<String>> questionIdSearchTermsHasmap = (HashMap<String, HashSet<String>>) request.getAttribute("searchGroups");
    IQCase iqcase = (IQCase) request.getAttribute("icase");
%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>



<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ImageQuiz</title>
        <meta charset="utf-8">
    	<meta http-equiv="X-UA-Compatible" content="IE=edge">
    	<meta name="viewport" content="width=device-width, initial-scale=1">       
    	<link href="css/fro/gray.min.css" rel="stylesheet" type="text/css" /> 
    	<!-- link href="css/fro/froala_style.min.css" rel="stylesheet" type="text/css" /-->
    	
        <link href="<c:url value="/css/lib/bootstrap.paper.min.css"/>" rel="stylesheet">
        
        <link href="../jslib/tagit/jquery.tagit.css" rel="stylesheet" type="text/css">
    	<link href="../jslib/tagit/tagit.ui-zendesk.css" rel="stylesheet" type="text/css">
    	
    	
    	<link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.min.css">
    	<link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.theme.min.css">
    	
        
            <!-- script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
			<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>-->
			<script src="<c:url value="/jslib/jquery-1.12.4.min.js"/>"></script>
			<script src="<c:url value="/jslib/jquery-ui-1.12.1.min.js"/>"></script>
			
			<%--
		<!-- Include Editor style. -->
	    <!-- Include Editor style. -->
	    <link href="css/fro/froala_editor.pkgd.css" rel="stylesheet" type="text/css" />
	    <link href="css/fro/froala_style.min.css" rel="stylesheet" type="text/css" />
	    <link href="css/fro/gray.min.css" rel="stylesheet" type="text/css" />
    --%>
    

    	<link rel="stylesheet" type="text/css" href="../css/case.css?v=2">
        <!-- script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-ui-1.10.3/ui/jquery-ui.js"></script-->
        <script src="../jslib/jquery-photo-resize.js?v=1"></script>
        <script type="text/javascript" src="../jslib/tagit/tag-it.min.js"></script>
        <script src="../jslib/ecg/ecg-measurements-1.3-min.js"></script>
        <script src="../jslib/imagequiz/casedisplay.js"></script>
        <script src="../jslib/autocomplete.js?v=1"></script>
        <script src="../jslib/bootstrap.min.js"></script>
        
        <link rel="stylesheet" type="text/css" href="<c:url value="/css/case/casedisplay.css?v=2"/>">
        <link rel="stylesheet" type="text/css" href="<c:url value="/css/case/navbar.css?v=1"/>" >
        <link rel="stylesheet" type="text/css" href="<c:url value="/css/case/comments.css"/>" >
        
        <script type="text/javascript" language="JavaScript">
            //add highlight autocomplete partial matches
            
            $.ui.autocomplete.prototype._renderItem = function( ul, item){
            var term = this.term.split(' ').join('|');
            var re = new RegExp("(" + term + ")", "gi");
            var t = item.label.replace(re,"<b>$1</b>");
            t = t.replace(/\s*\[.*\]\s*/, '');
            return $( "<li></li>" )
               .data( "item.autocomplete", item )
               .append( "<a>" + t + "</a>" )
               .appendTo( ul );
            };
            
            var tagGroups = {};
            <%if (questionIdSearchTermsHasmap != null && iqcase != null) {
            	for (Map.Entry<String, HashSet<String>> searchTerms: questionIdSearchTermsHasmap.entrySet()) {%>
            		tagGroups["<%=searchTerms.getKey()%>"] = [
                <%for (String searchTerm: searchTerms.getValue()) {%>
                  "<%=searchTerm.trim()%>",
              <%}%> ""];
        <%}}%>
            
        function setAutocomplete(field, tags) {
            $(field).autocomplete({
                 source: tags,
                 minLength: 1,
                 select: function(event, ui) { return addSearchedAnswer(event, ui); },
                 response: function(event, ui) {
                                if (ui.content.length === 0) {
                                    ui.content.push({ label: "No search results - try fewer letters", value: "null" });
                                }
                           }
             });
        }
        	var startTime
            $(function() {
                //ON LOAD...
                
                startTime = new Date();
                

            
        <%if (questionIdSearchTermsHasmap != null && iqcase != null) {
            for (Map.Entry<String, HashSet<String>> searchTerms: questionIdSearchTermsHasmap.entrySet()) {
            %>
            $('#q-<%=searchTerms.getKey()%>UL').tagit({
    	    	readOnly: <c:if test="${requestScope.lockanswers}">true</c:if><c:if test="${!requestScope.lockanswers}">false</c:if>,
    	    	singleField: true,
                singleFieldNode: $('#q-<%=searchTerms.getKey()%>'), 
                allowSpaces: true,
                onTagClicked: function(evt, ui) {
                	//$('#availableDifficulties').tagit('createTag', $('#selectedDifficulties').tagit('tagLabel', ui.tag));
                	//$('#selectedDifficulties').tagit('removeTagByLabel', $('#selectedDifficulties').tagit('tagLabel', ui.tag));
                }
    	    })
    	    setAutocomplete($("#q-<%=searchTerms.getKey()%>Select")[0], tagGroups["<%=searchTerms.getKey()%>"]);
    	    
           
        <%}
        }%>
        
        <c:if test="${requestScope.lockanswers}">
        $("input[type=text]").prop('disabled', true);
        $("input[type=text]").addClass('disabled');
        $("input[type=text]").val('<Question Already Answered>');
        $("div.questionDiv").addClass('questionDisabled')
        $("div.questionDiv").removeClass('questionDiv')
        </c:if>
        
            });
			
            function submitForm(direction) {
            	$(".controlBtn").addClass('disabled');
            	$(".caseLoader").toggle();
            	$("#loadonce").val("true");
                $("#action").val(direction);
                $("#timespent").val(new Date() - startTime);
                $("#caseForm").submit();
            }

            function addSearchedAnswer(event, ui) {
            	if (ui.item.value == "null") {
                    ui.item.value = "";
                    return false;
                }
                var inputField = event.target;
                var selectedChoice = ui.item.value;
                var selectedChoice = selectedChoice.replace(/\s*\[.*\]\s*/, '');
                var parentElement = $(inputField).parent();
                var inputFieldId = $(inputField).attr('id');
                var ulFieldId = inputFieldId.substring(0, inputFieldId.length - "Select".length);
                //remove "Select" from the end of the field, and add UL to the end to find the UL list of selected answers
                $('#' + ulFieldId + 'UL').tagit('createTag', selectedChoice);
                $(inputField).val('');
                return false;
            }
            
            function showSearchTerms(questionId) {
            	var tagArray = tagGroups[questionId];
            	tagArray.sort();
            	var display = ""
            	for (var i=0; i< tagArray.length; i++) {
            		var tag = tagArray[i];
            		tag = tag.replace(/\s*\[.*\]\s*/, '');
            		display = display + tag + "<br>";
            	}
            	$('#infoSearchDisplayDialog').html(display);
            	$('#infoSearchDisplayDialog').dialog('open');
            }
            
            $(function() {
                $('#infoSearchDisplayDialog').dialog({
                    autoOpen: false,
                    maxWidth: 500,
                    maxHeight: 500,
                    overflow: 'auto'
                });
                
                $("img").mousedown(function(e){
                    e.preventDefault(); //prevent dragging in IE
                });
                
                
                <c:if test="${not empty requestScope.caseCompleted}">
                	<c:forEach var="question" items="${requestScope.caseCompleted.answeredQuestions}">
                		<c:if test="${question.questionType == 'search_term'}">
                			<c:forEach var="choice" items="${question.userSelections}">
                			$('#q-${question.questionId}UL').tagit('createTag', '${choice.answer}');
                			</c:forEach>
                		</c:if>
                		<c:if test="${question.questionType == 'single_choice'}">
                			var $radios = $('#q-${question.questionId}');
                			<c:forEach var="text" items="${question.userSelections}">
                	        $radios.filter("[value='${text.answer}']").prop('checked', true);
                	        </c:forEach>
                			$('input[name=q-${question.questionId}]').attr("disabled",true);

                		</c:if>
<c:set var="newLine" value="
" />
                		
                		<c:if test="${question.questionType == 'text'}">
                			<c:forEach var="text" items="${question.userSelections}">
                			<%pageContext.setAttribute("printText", ((org.imagequiz.model.question.IQAnswer) pageContext.getAttribute("text")).getAnswer().replaceAll("\n", "").replaceAll("\r", "\\\\n"));%>
                			$('#q-${question.questionId}').val($('#q-${question.questionId}').val() + '<c:out value="${printText}"/>');
                			$('#q-${question.questionId}').addClass('textareaDisabled');
                			$('#q-${question.questionId}').attr('disabled', 'true');
                			</c:forEach>
                		</c:if>
                	</c:forEach>
                </c:if>
            });
        </script>
    </head>
    <body class="case">
	<div class="container-fluid" style="margin: 0px; padding: 0px;">
	
	<c:if test="${ empty sessionScope.portal }">
	<jsp:include page="header2.jsp">
		<jsp:param name="exitUrl" value="${requestScope.quiturl}"/>
	</jsp:include>
	</c:if>


        <form name="caseForm" id="caseForm" method="POST" class="form-control caseForm" action="${requestScope.gotoaction}">
        <c:if test="${not empty requestScope.caseNumber }">
        
        <div class="row text-center">
        	<div class="col-md-8 center-block" style="float:none;">
		        <div class="progress progress-striped">
		        	<c:if test="${not empty requestScope.caseNumberTotal}">
			  			<div class="progress-bar progress-bar-info" style="width: ${100*(requestScope.caseNumber/requestScope.caseNumberTotal)}%">
			  					<div class="progress-text">Progress: Question ${requestScope.caseNumber} out of ${requestScope.caseNumberTotal }</div>		  					
			  			</div>
		  			</c:if>
		  			<c:if test="${not empty requestScope.caseNumberPossible}">
			  			<div class="progress-bar progress-bar-info" style="width: ${100*(requestScope.caseNumber/requestScope.caseNumberPossible)}%">
			  					<div class="progress-text">Progress: Question ${requestScope.caseNumber} out of possible ${requestScope.caseNumberPossible }</div>		  					
			  			</div>
		  			</c:if>
				</div>
			</div>
		</div>
	
        </c:if>
        <div class="caseBody">
        	<%if (request.getAttribute("showTopCommentBox") != null && (Boolean)request.getAttribute("showTopCommentBox") == true) { %>
	        	<jsp:include page="comment.jsp">
	        		<jsp:param name="showComment" value="true"/>
	        	</jsp:include>
        	<%} %>
        	
            <%=request.getAttribute("caseHtml")%>
            
            <%if (request.getAttribute("showBottomCommentBox") != null && (Boolean)request.getAttribute("showBottomCommentBox") == true) { %>
	            <jsp:include page="comment.jsp">
	        		<jsp:param name="showComment" value="false"/>
	        	</jsp:include>
	        <%} %>

        </div>

        <div class="controlButtons" style="text-align: center;">
            <input type="hidden" name="action" id="action" value="refresh">

            <input type="hidden" name="method" id="testMode" value="quizNavigation">
            <input type="hidden" name="caseid" value="<c:out value="${requestScope.icase.caseId }"/>">
            <input type="hidden" name="reviewmode" value="<c:out value="${requestScope.reviewmode }"/>">
            <input type="hidden" name="timespent" id="timespent" value="">
            <input type="hidden" name="mode" value="<c:out value="${requestScope.mode }" default=""/>">
            <input type="hidden" name="<%= Constants.TOKEN_KEY %>" value="<%= session.getAttribute(Globals.TRANSACTION_TOKEN_KEY) %>">
            
            
           	<a class="btn btn-danger quitQuizButton controlBtn" onclick="document.location.href = '<c:url value="${requestScope.quiturl}"/>'">Save & Quit</a>
            <!-- <a class="btn btn-default controlBtn" onclick="refreshForm()">Clear</a> -->
            <c:if test="${showSummaryLink}">
            	<a class="btn btn-info controlBtn" onclick="submitForm('summary')">Review Quiz</a>
            </c:if>
            <c:if test="${(not empty requestScope.timeLeft) && (requestScope.timeUser)}">
            	<span class="timer" id="timer">Time Left: <span id="timerDigits" class="timerDigits">Loading..</span></span>
            </c:if>
            <a class="btn btn-primary controlBtn" onclick="submitForm('back')">&lt; Back</a>
            <a class="btn btn-primary controlBtn" onclick="submitForm('next')">Next &gt;</a>
        </div>
        </form>
        
        <div class="modal fade" tabindex="-1" role="dialog" id="searchtextmodal" aria-labelledby="searchtextmodal">
		  <div class="modal-dialog modal-lg searchterm" role="document">
		    <div class="modal-content">
		      <div class="modal-header">
		        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
		        <h4 class="modal-title" id="myModalLabel">Edit Search Terms</h4>
		      </div>
		      <div class="modal-body maxHeight loaderBg">
		      	<iframe class="modal-iframe"></iframe>
		      </div>
		      <div class="modal-footer customFooter">
		        <button type="button" class="btn btn-primary" data-dismiss="modal">Close</button>
		      </div>
		    </div>
		  </div>
		</div>
		
		<div class="caseLoader" style="display: none;"> 
			<img class="caseLoaderImage" src="<c:url value="/css/loader.gif"/>">
		</div>
        
        
        
        <script>
        $(function() {
        	/*$("img.caseImage").photoResize({
				hoffset: 20,
            	voffset: 20
			});*/
				
			$('.caseImage').measurements({
				magnification: 3
			});
			
		   	$("#showOptionsButton").click( function() {
		   	 	$('#searchtextmodal').modal('show');
		   	 	rescale();
		   	 	//parent.$('#searchtextmodal').find('.modal-iframe').load($(this).data("load-url"));
		   	 	$('#searchtextmodal').find('.modal-iframe').attr('src', $(this).data("load-url"));
		   	})
			 
			$('#searchtextmodal').on('hidden.bs.modal',function(){  
			   	  	$(this).find('iframe').attr('src','');
			})
			
			function rescale(){
		   		//ensure modal takes up a certain height based on window height
			    $('.modal-body.maxHeight').css('height', $(window).height() - 250);
			}
			$(window).bind("resize", rescale);
			
			$('.choiceItemContainer input.choiceItem').on('change', function(e) {
				var limit = $(this).closest('.choiceItemContainer').data('maxchoices');
				//alert($(this).closest(".choiceItemContainer").find('.choiceItem').length);
				if (limit != 0) {
				   if($(this).closest(".choiceItemContainer").find('.choiceItem:checked').length > limit) {
				       this.checked = false;
				       alert("You can only check maximum " + limit + " items");
				   }
				}
			});
			
        })
        
	    $(document).ready(function () {
	    	  $('[data-toggle="offcanvas"]').click(function () {
	    	    $('.row-offcanvas').toggleClass('active')
	    	  });
	    	 <c:if test="${(not empty requestScope.timeUser) && (requestScope.timeUser)}">
	    	 startTimer(${requestScope.timeLeft});
	    	 </c:if>
	    	  
	    	  
	    	$('[data-toggle="tooltip"]').tooltip(); 
	    	//$('[data-toggle=popover]').popover();
	    	
	    	$('.caseText').addClass('fr-view'); //applies editor styles
	    	  
	   	});
		</script>
        
    </body>
</html>
