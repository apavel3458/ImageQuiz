<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
    
    <%
    	String p = request.getParameter("newCommentsPrivate");
    	if (p != null) getServletContext().setAttribute("newCommentsPrivate", p);
    %>
    
    <script type="text/javascript" language="JavaScript">
    	$(function() {
    		
    		<%if (request.getParameter("showComment") != null && request.getParameter("showComment").equalsIgnoreCase("true")) { %>
    		showCommentBox();
    		<%}%>
    		formatAllComments();
    	});
    	function showCommentBox() {
    		$("#commentDiv").show();
    		$("#commentDivShowHide").hide();
    		
    	}
    	
    	function hideUnhideComment(obj, commentId) {
    		var hiding = false;
    		if ($(obj).html() == "Hide")
    			hiding = true;
    		$(obj).html("Changing...");
    		$(obj).attr('disabled','disabled');

		    $.ajax({
		        url: "../admin/admin.do",
		        data: {
		            method: "toggleHideComment",
		            commentId: commentId
		        },
		        type: "GET",
		        dataType: "html",
		        success: function (data) {
		        	if (data !== 'success') return null;
		        	$(obj).removeAttr('disabled');
		        	if (hiding) {
		        		$(obj).siblings(".commentStatus").html("(Hidden)");
		        		$(obj).html("Make Public");
		        	} else { 
		        		$(obj).siblings(".commentStatus").html("(Public)");
		        		$(obj).html("Hide");
		        	}
		        },
		        error: function (xhr, status) {
		            alert("Could not delete comment.  Connection problem.");
		            $(obj).html("Try Again");
		            $(obj).prop('onclick',null).on('click');
		        },
		        complete: function (xhr, status) {
		        }
		    });
    	}
    	
    	function deleteComment(obj, commentId) {
    		$(obj).html("Deleting...");
    		$(obj).attr('disabled','disabled');

		    $.ajax({
		        url: "../admin/admin.do",
		        data: {
		            method: "deleteComment",
		            commentId: commentId
		        },
		        type: "GET",
		        dataType: "html",
		        success: function (data) {
		        	if (data.trim() != 'success') return null;
		        	
		        	$(obj).closest('.commentParent').remove();
		        },
		        error: function (xhr, status) {
		            alert("Could not delete comment.  Connection problem.");
		            $(obj).html("Try Again");
		            $(obj).prop('onclick',null).on('click');
		        },
		        complete: function (xhr, status) {
		        }
		    });
    	}
    	
    	function reviewComment(obj, commentId) {
    		const reviewedInitially = !($(obj).html().trim() === 'Mark Reviewed')
    		$(obj).html("Reviewing...");
    		$(obj).attr('disabled','disabled');

		    $.ajax({
		        url: "../admin/case.do",
		        data: {
		            method: "reviewCommentAjax",
		            commentid: commentId
		        },
		        type: "GET",
		        dataType: "html",
		        success: function (data) {
		        	const replyComment = JSON.parse(data)
		        	if (replyComment.reviewed)
		        		$(obj).html("Remove Reviewed")
		        	else
		        		$(obj).html("Mark Unreviewed")
		        	const changeBy = replyComment.reviewed?-1:1
		        	parent.app.changeActiveComments(${icase.caseId}, changeBy)
		        },
		        error: function (xhr, status) {
		            alert("Could not review comment.  Connection problem.");
		            $(obj).html("Try Again");
		            $(obj).prop('onclick',null).on('click');
		        },
		        complete: function (xhr, status) {
		        }
		    });
    	}
    	
    	function addComment(caseId) {
    		$("#addCommentButton").val("Submitting...");
    		$("#addCommentButton").attr("Disabled", true);

		    $.ajax({
		        url: "../exam/exam.do",
		        data: {
		            method: "addComment",
		            caseId: caseId,
		            privateComment: '${newCommentsPrivate}',
		            comment: $("#q-CaseReviewComments").val()
		        },
		        type: "GET",
		        dataType: "html",
		        success: function (data) {
		        	var response = data.split("|");
		    		var clonedTemplate = $("#commentTemplate").clone();
		    		$(clonedTemplate).show();
		        	$(clonedTemplate).find(".commentHead").text("by " + response[0] + " " + response[1] + " on " + response[2]);
		        	var clonedTemplateComment = $(clonedTemplate).find(".commentBody");
		        	$(clonedTemplateComment).text(response[3]);
		        	$(clonedTemplateComment).html(formatCommentBody($(clonedTemplateComment).text()));
		        	$("#commentsTd").prepend(clonedTemplate);
		            //var result = $('<div />').append(data).find('#showresults').html();
		            //$('#showresults').html(result);
		        	$("#q-CaseReviewComments").val("");
		        },
		        error: function (xhr, status) {
		            alert("Could not add comment.  Connection problem.");
		        },
		        complete: function (xhr, status) {
		            //$('#showresults').slideDown('slow')
		    		$("#addCommentButton").val("Add Comment");
		    		$("#addCommentButton").attr("Disabled", false);
		        }
		    });
		}
    	
    	function formatAllComments() {
    		$(".commentBody").each(function(){
    			$(this).html(formatCommentBody($(this).html()));
    		})
    	}
    	function formatCommentBody(str) {
    		var re = new RegExp('\n', 'g');
    		return str.replace(re, '<br>');
    	}
    </script>
    
    <div class="row">
    <div class="col-sm-8 col-sm-offset-2 col-xs-10 col-xs-offset-1">
	    <div id="commentDivShowHide" class="commentDivShowHide" onclick="showCommentBox()" style="cursor: pointer;">Click to comment on the case (corrections/errors/comments)</div>
	  	<div id="commentDiv" class="commentDiv" style="display: none;">
	  		<div class="panel panel-success commentBox">
			    <div class="panel-heading"><h3 class="panel-title">Case Reviewer Comments</h3></div>
			    <div class="panel-body">
			    	<textarea class="caseQuestionText" rows="4" id="q-CaseReviewComments" name="q-CaseReviewComments"  placeholder=" &#010; &lt; Enter Comment Text Here &gt;"></textarea>
			    	<br><button type="button" id="addCommentButton" class="btn btn-success btn-xs addCommentButton" onclick="addComment('${icase.caseId}')">Add Comment</button>
	
			    	<table class="questionTable questionTableText">
			    	<tr>
			    		<td class="commentsTd" id="commentsTd">
			    				<div class="commentParent" id="commentTemplate" style="display: none;">
					    			<div class="commentHead"></div>
					    			<div class="commentBody"></div>
				    			</div>
				    			<c:forEach var="comment" items="${requestScope.comments}">
				    			<div class="commentParent">
					    			<div class="commentHead">by ${comment.user.firstName} ${comment.user.lastName} on <fmt:formatDate pattern="MMM dd yyyy, HH:mm" value="${comment.createdDateTime }"/>
					    				<c:if test="${comment.hidden}"><span class="commentStatus">(Hidden)</span></c:if>
					    				<c:if test="${not comment.hidden}"><span class="commentStatus">(Public)</span></c:if>
					    				<c:if test="${sessionScope.security.admin}">
					    					<c:if test="${security.isManagerCases()}">
					    					<a onclick="hideUnhideComment(this, ${comment.commentId})" class="commentAdminLink"><c:if test="${comment.hidden}">Make Public</c:if><c:if test="${not comment.hidden}">Hide</c:if></a> | 
					    					</c:if>
					    					<c:if test="${security.isManagerCases() || comment.user.userId.equals(security.userId)}">
					    					<a onclick="deleteComment(this, ${comment.commentId})" class="commentAdminLink">Delete</a> | 
					    					</c:if>
					    					<a onclick="reviewComment(this, ${comment.commentId})" class="commentAdminLink">
						    					<c:if test="${comment.reviewed}">
						    						Unacknowledge
						    					</c:if>
						    					<c:if test="${!comment.reviewed }">
						    						Acknowledge
						    					</c:if>
					    					</a>
					    					<c:if test="${comment.reviewed }">
					    						<br/>Reviewed at <fmt:formatDate pattern="yyyy-MM-dd" value="${comment.reviewedAt }"/> by ${comment.reviewedBy.firstName} ${comment.reviewedBy.lastName }
					    					</c:if>
					    				</c:if>
					    			</div>
					    			<div class="commentBody">${comment.text }</div>
				    			</div>
			    				</c:forEach>
			    		</td>
			    	</tr>
		    		</table>
		    		</div>
	    		</div>
	   		</div>
   		</div></div>