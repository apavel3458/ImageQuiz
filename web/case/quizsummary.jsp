<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ page import="org.apache.struts.Globals" %>
<%@ page import="org.apache.struts.taglib.html.Constants" %>
<%@ page import="java.math.*" %>



<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta charset="utf-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1">    
	<title>Quiz Summary</title>
	
	<link href="<c:url value="/css/lib/bootstrap.paper.min.css"/>" rel="stylesheet">
	
	<link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.min.css">
	<link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.theme.min.css">
	
	

    <link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.min.css">
    <link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.theme.min.css">
    	            <!-- script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
		<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>-->
	<script src="<c:url value="/jslib/jquery-1.12.4.min.js"/>"></script>
	<script src="<c:url value="/jslib/jquery-ui-1.12.1.min.js"/>"></script>
	<script src="../jslib/bootstrap.min.js"></script>
	<script src="../jslib/vue/vue.min.js"></script>
		
	<link rel="stylesheet" type="text/css" href="<c:url value="/css/case/casedisplay.css?v=2"/>">
    <link rel="stylesheet" type="text/css" href="<c:url value="/css/case/navbar.css?v=1"/>" >
    <link rel="stylesheet" type="text/css" href="<c:url value="/css/case/quizsummary.css"/>" >


    <body class="case quizsummary">
		<div class="container-fluid" style="margin: 0px; padding: 0px;" id="app">

	<c:if test="${ empty sessionScope.portal }">
	<jsp:include page="header2.jsp">
		<jsp:param name="exitUrl" value="${requestScope.quiturl}"/>
	</jsp:include>
	</c:if>

    	<div class="row">
	    	<div class="col-md-offset-2 col-md-8 col-xs-12">
	    		<c:set var="cssClass" scope="page" value="info"/>  
	    		<c:if test="${iexam.optionShowGrade }">
	    			<c:set var="cssClass" scope="page" value="${requestScope.totalPass.booleanValue()?'success':'danger'}"/>  
	    		</c:if>
			    <div class="panel mainpanel panel-<c:out value="${cssClass}"/>">
				  <div class="panel-heading">
				    <h3 class="panel-title text-center">FINAL RESULTS</h3>
				  </div>
				  <div class="panel-body">
				  	<c:if test="${iexam.optionShowGrade }">
					  	<c:if test="${requestScope.totalPass}">
					  		<H4 class="text-center">You have successfully completed this quiz</H4>
					  	</c:if>
					  	<c:if test="${!requestScope.totalPass }">
					  		<H4 class="text-center">You were not successful in this quiz</H4>
					  	</c:if>
					  	<H4 class="text-center">Final Score: <c:out value="${(requestScope.totalGrade.setScale(2, RoundingMode.HALF_UP)*100).stripTrailingZeros().toPlainString()}"/>% 
					  			(<c:out value="${requestScope.totalScore.setScale(2, RoundingMode.HALF_UP).stripTrailingZeros().toPlainString()}"/>/<c:out value="${requestScope.totalPassScore.setScale(2, RoundingMode.HALF_UP).stripTrailingZeros().toPlainString()}"/>)</H4>
					  	<div class="text-center text-muted">Required score for pass: > <c:out value="${(requestScope.passGrade.setScale(2, RoundingMode.HALF_UP)).stripTrailingZeros().toPlainString() }"/>%</div>
					</c:if>
					<c:if test="${!iexam.optionShowGrade }">
						<H4 class="text-center">You have completed this quiz</H4>
					</c:if>
				  	<hr/>
				  	<c:if test="${not empty iexam.optionMessagePostSuccess && !iexam.optionMessagePostSuccess.equals('') && requestScope.totalPass.booleanValue()}">
					  	<div class="jumbotron customJumbotron">
						  <p>${iexam.optionMessagePostSuccess }</p>
						</div>
				  		<hr/>
				  	</c:if>
				  	<c:if test="${not empty iexam.optionMessagePostFail && !iexam.optionMessagePostFail.equals('') && requestScope.totalPass.booleanValue() == false}">
					  	<div class="jumbotron customJumbotron">
						  <p>${iexam.optionMessagePostFail }</p>
						</div>
				  		<hr/>
				  	</c:if>
				  	<c:if test="${iexam.isAllowReviewForQuiz(requestScope.totalPass)}">
					    <c:forEach items="${requestScope.quiz.completedCases }" var="icase" varStatus="index">
					    	<!-- div class="question<c:out value="${(icase.score >= icase.passScore)?' correct':' incorrect'}"/>">
					    			Question ${index.index} Score: ${icase.scoreDisplay} / ${icase.passScoreDisplay}</div-->
					    	<a href="<c:url value="/exam/exam.do?method=quizNavigation"/>&ignoreRefreshToken=true&reviewcaseid=${icase.completedCaseId}"
					    	class="btn btn-default btn-<c:out value="${icase.isPass()?'default':'incorrect' }"/> btn-xs">
					    		Question ${index.index+1} <br/> Score: ${icase.scoreDisplay} / ${icase.passScoreDisplay}
					    	</a>
					    </c:forEach>
				    </c:if>
				    <c:if test="${not empty requestScope.categories && requestScope.categories.size() > 0}">
				    <div class="performance">
				    	<h5>Performance Breakdown:</h5>
				    	<table class="breakdown">
				    		<c:forEach var="category" items="${requestScope.categories}">
				    		<tr>
				    			<th class="breakdownTitle">${category.associatedTag.tagName }</th>
				    			<td class="breakdownProgress">
							    	<div class="progress breakdownProgress">
									  <div class="progress-bar progress-bar-info" style="width: ${category.grade}%"></div>
									</div>
								</td>
								<td class="breakdownNumber">${category.grade.setScale(0, RoundingMode.HALF_UP)} %</td>
								<td class="breakdownInfo">
									<a :disabled="!resourceExists(${category.associatedTag.tagId })" @click="openResource(${category.associatedTag.tagId })" href="#" class="btn btn-default btn-xs actionButton">Study Resources</a>
								</td>
							</tr>
							</c:forEach>
						</table>
				    </div>
				    </c:if>
				  </div>
				</div>
			</div>
		</div>
		
		
		<!-- Modal -->
		<div class="modal fade" id="resourcesDialog" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
		  <div class="modal-dialog" role="document">
		    <div class="modal-content">
		      <div class="modal-header">
		        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
		        <h4 class="modal-title" id="myModalLabel">Resources for {{tag.tagName}}</h4>
		      </div>
		      <div class="modal-body">
		      	<div class="container-fluid">
			      	<div class="cols-xs-12 resourceLinks">
			        	<p>{{tag.resources.text}}</p>
			        	<div class="heading" v-if="tag.resources.urls && tag.resources.urls.length > 0" style="width: 50%;">Resources: </div>
			        	<ul>
			        		<li v-for="url in tag.resources.urls">
			        			<a :href="url.urlUrl" target="new">{{url.urlName}}</a>
			        		</li>
			        	</ul>
			        </div>
		        </div>
		      </div>
		      <div class="modal-footer">
		        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		        <!-- button type="button" class="btn btn-primary">Save changes</button-->
		      </div>
		    </div>
		  </div>
		</div>
		
    
    	<form>
    	 	<div class="controlButtons" style="text-align: center;">
	            <input type="hidden" name="action" id="action" value="refresh">
	
	            <input type="hidden" name="method" id="testMode" value="quizNavigation">
	            <input type="hidden" name="caseid" value="<c:out value="${requestScope.icase.caseId }"/>">
	            <input type="hidden" name="reviewmode" value="<c:out value="${requestScope.reviewmode }"/>">
	            <input type="hidden" name="timespent" id="timespent" value="">
	            <input type="hidden" name="mode" value="<c:out value="${requestScope.mode }" default=""/>">
	            <input type="hidden" name="<%= Constants.TOKEN_KEY %>" value="<%= session.getAttribute(Globals.TRANSACTION_TOKEN_KEY) %>">
	            
	            
	           	<a class="btn btn-danger quitQuizButton controlBtn" onclick="document.location.href = '<c:url value="${requestScope.quiturl}"/>'">Exit Quiz</a>
	            <!-- a class="btn btn-default controlBtn" onclick="refreshForm()">Clear</a-->
	            <c:if test="${iexam.optionAllowReview}">
	            	<a class="btn btn-primary controlBtn" 
	            		href="<c:url value="/exam/exam.do?method=quizNavigation"/>">Review Questions &gt;</a>
	            </c:if>
        	</div>
        </form>
		<jsp:include page="footer2.jsp" />
	<script type="text/javascript" language="JavaScript">
	
	var app = new Vue({
		el: "#app",
		data: {
			tags: [],
			tag: {
				resources: {}
			}
		},
		methods: {
			getData: function() {
				var tagsRaw = ${requestScope.categoriesJson};
				try {
					this.tags = tagsRaw;
					this.tags = this.unpackResources(this.tags);
					if (tags.length > 0)
						this.tag = this.tags[0];
				} catch (error) {
					console.log(error);
				}
			},
			unpackResources: function(tags) {
				for (var i=0; i<this.tags.length; i++) {
					this.tags[i].resources = JSON.parse(this.tags[i].resourcesJson);
					if (!this.tags[i].resources) this.tags[i].resources = {};
					console.log(this.tags[i]);
				}
				return tags;
			},
			resourceExists: function(tagId) {
				for (var i=0; i< this.tags.length; i++) {
					var tag = this.tags[i]
					if (tag.tagId == tagId && tag.resources && tag.resources.enabled) return true
				}
				return false;
			},
			openResource: function(tagId) {
				for (var i=0; i< this.tags.length; i++) {
					var tag = this.tags[i]
					if (tag.tagId == tagId && tag.resources.enabled) {
						this.tag = tag;
						$("#resourcesDialog").modal("show");
					}
				}
				
			}
		},
		mounted() {
			this.getData();
		}
	})
	</script>
    </body>
</html>
