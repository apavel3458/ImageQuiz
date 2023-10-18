<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
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
	<H5 style="float:left; margin-left: 50px; font-weight: bold;">Results By MCQ Case | (${exam.examId}) ${exam.examName }</H5>
	<input type="button" onclick="document.location='../admin/admin.do'" value="Back to Admin" style="float:left; margin-top: 15px; margin-left: 18px;">

	<table class="resultTable resultTableData" style="clear:left;">
		<tr>
			<th>Total Attempts</th>
			<td>${resultsExam.totalCount }</td>
			<td colspan="2"><sup>Includes incomplete/timedOut attempts</sup>
		</tr>
		<tr>
			<th>Completed:</th>
			<td>${resultsExam.completedCount }</td>
			<th>Mean Grade:</th>
			<fmt:formatNumber var="meanTotalGradeFormat"
								  value="${resultsExam.meanTotalGrade*100}"
								  maxFractionDigits="0" />
			<td>${meanTotalGradeFormat}%</td>
		</tr>
		<tr>
			<th>Incomplete:</th>
			<td>${resultsExam.totalCount - resultsExam.completedCount }</td>
		</tr>
		<tr class="pass">
			<th>Passed:</th>
			<td>${resultsExam.passCount }</td>
			<th>Mean Pass Grade:</th>
			<fmt:formatNumber var="meanPassGradeFormat"
								  value="${resultsExam.meanPassGrade*100}"
								  maxFractionDigits="0" />
			<td>${meanPassGradeFormat }%</td>
		</tr>
		<tr class="fail">
			<th>Failed:</th>
			<td>${resultsExam.failCount }</td>
			<th>Mean Fail Grade:</th>
			<fmt:formatNumber var="meanFailGradeFormat"
								  value="${resultsExam.meanFailGrade*100}"
								  maxFractionDigits="0" />
			<td>${meanFailGradeFormat }%</td>
		</tr>
		<tr>
			<td>Mean Time Taken</td>
			<fmt:formatNumber var="meanTimeTakenFormat"
								  value="${resultsExam.meanTimeTaken/(1000*60)}"
								  maxFractionDigits="2" />
			<td>${meanTimeTakenFormat } min</td>
		</tr>
		<tr>
			<td colspan="4">
					<div class="instructions">
						* Note: Above stats include quizzes where user has seen ALL questions.</br>
						The only exception is "Total Attempts", which includes everything.
					</div>
			</td>
		</tr>

	</table>
	
	<table class="resultTable" style="clear:left;" id="data">
		<tr>
			<th>Case/Question</th>
			<th colspan="3">Answer Key (score)</th>
			<th>Comments</th>
		</tr>
		<c:forEach var="question" items="${requestScope.results}">
			<c:if test="${question.type.equals('mcq')}">
				<c:forEach var="choiceSummary" items="${question.choices }" varStatus="status">
				<tr class="${status.index==0?'first':'' } ${status.index==question.choices.size()-1?'last':'' }">
					<c:if test="${status.index==0}">
						<td class="question" rowspan="${question.choices.size() }">
							<div style="font-weight: bold;">${question.associatedCase.caseName} (ID: ${question.associatedCase.caseId})</div>
							<div style="font-size: 10px;">Avg Time: ${question.meanSecondsTaken} s</div>
							<!-- div>Question ID: ${question.question.questionTextId}</div-->
							<c:if test="${not empty exam}">
								<div style="text-align: center;"><a href="admin.do?method=editExercise&exerciseid=${exam.exercise.exerciseId }&caseid=${question.associatedCase.caseId }" target="editCase" class="btn btn-xs btn-default">Edit Case</a></div>
							</c:if>
							<div style="text-align: center;"><a href="#" target="editCase" onclick="previewCase(${question.associatedCase.caseId})" class="btn btn-xs btn-default">Preview Case</a></div>
						</td>
					</c:if>
					
						<td valign="middle">
								<div class="barContainer">
									<div class="progress progress-striped" style="width: 100%;"><div class="progress-bar ${choiceSummary.choice.correct?'progress-bar-success':''}" style="width: ${(choiceSummary.count/question.totalCount)*100}%;"></div></div>
								</div>
						</td>
						<td align="left">
							<fmt:formatNumber var="percent"
								  value="${(choiceSummary.count/question.totalCount)*100}"
								  maxFractionDigits="0" />
							${percent}%  (${choiceSummary.count }/${question.totalCount})
						</td>
						<td align="left">
							
									<div class="choiceLine <c:if test="${choiceSummary.choice.correct }">correctChoice</c:if>">
											${choiceSummary.choice.answerString }
									</div>
							
						</td>
						<c:if test="${status.index==0}">
							<td valign="top" class="comments" rowspan="${question.choices.size() }">
								<c:forEach var="comment" items="${question.comments }">
								<div class="commentsDiv">
									<span class="user">${comment.user.firstName} ${ comment.user.lastName }:</span> ${comment.text }
								</div>
								</c:forEach>
								&nbsp;
							</td>
						</c:if>
					
				</tr>
				</c:forEach>
			</c:if>
			<c:if test="${question.type.equals('sg')}">
				<c:forEach var="answer" items="${question.answers }" varStatus="status">
				<tr class="${status.index==0?'first':'' } ${status.index==question.answers.size()-1?'last':'' }">
					<c:if test="${status.index==0}">
						<td class="question" rowspan="${question.answers.size() }">
							<div style="font-weight: bold;">${question.associatedCase.caseName} (ID: ${question.associatedCase.caseId})</div>
							<div style="font-size: 10px;">Avg Time: ${question.meanSecondsTaken} s</div>
							<!-- div>Question ID: ${question.question.questionTextId}</div-->
							<div style="text-align: center;"><a href="admin.do?method=editExercise&exerciseid=${exam.exercise.exerciseId }&caseid=${question.associatedCase.caseId }" target="editCase" class="btn btn-xs btn-default">Edit Case</a></div>
							<div style="text-align: center;"><a href="#" target="editCase" onclick="previewCase(${question.associatedCase.caseId})" class="btn btn-xs btn-default">Preview Case</a></div>
						</td>
					</c:if>
					
						<td valign="middle">
								<div class="barContainer">
									<div class="progress progress-striped" style="width: 100%;"><div class="progress-bar ${answer.correct?'progress-bar-success':''}" style="width: ${(answer.count/question.totalCount)*100}%;"></div></div>
								</div>
						</td>
						<td align="left">
							<fmt:formatNumber var="percent"
								  value="${(answer.count/question.totalCount)*100}"
								  maxFractionDigits="0" />
							${percent}%  (${answer.count }/${question.totalCount})
						</td>
						<td align="left">
							
									<div class="choiceLine <c:if test="${answer.correct }">correctChoice</c:if>">
											${answer.text }
									</div>
							
						</td>
						<c:if test="${status.index==0}">
							<td valign="top" class="comments" rowspan="${question.answers.size() }">
								<c:forEach var="comment" items="${question.comments }">
								<div class="commentsDiv">
									<span class="user">${comment.user.firstName} ${ comment.user.lastName }:</span> ${comment.text }
								</div>
								</c:forEach>
								&nbsp;
							</td>
						</c:if>
					</tr>
				</c:forEach>
			</c:if>
			<c:if test="${question.type.equals('text')}">
				<tr class="first last">
						<td class="question" rowspan="1">
							<div style="font-weight: bold;">${question.associatedCase.caseName} (ID: ${question.associatedCase.caseId})</div>
							<div style="font-size: 10px;">Avg Time: ${question.meanSecondsTaken} s</div>
							<!-- div>Question ID: ${question.question.questionTextId}</div-->
							<c:if test="${not empty exam}">
								<div style="text-align: center;"><a href="admin.do?method=editExercise&exerciseid=${exam.exercise.exerciseId }&caseid=${question.associatedCase.caseId }" target="editCase" class="btn btn-xs btn-default">Edit Case</a></div>
							</c:if>
							<div style="text-align: center;"><a href="#" target="editCase" onclick="previewCase(${question.associatedCase.caseId})" class="btn btn-xs btn-default">Preview Case</a></div>
						</td>
					<td colspan="3">
						TEXT QUESTION  (Not yet supported)
					</td>

				</tr>
			</c:if>
		</c:forEach>
		
	
	</table>
	
</body>
<style lang="css">
	.resultTable {
		margin-left: 10px;
		margin-right: 10px;
	}
	table.resultTable th {
		text-align: center;
	}
	table.resultTable tr td.question {
		background: none;
	}
	.resultTable tr.first {
		border-top: 1px solid grey;
		padding-top: 5px;
		text-align: center;
	}
	.resultTable tr.first > td { padding-top: 5px; }
	.resultTable tr.last {
		border-bottom: 1px solid grey;
	}
	.resultTable tr.last > td { padding-bottom: 5px; }
	
	.resultTable tr td {
		padding-left: 5px;
		padding-right: 5px;
		vertical-align: middle;
		white-space: nowrap;
	}
	.resultTable tr:nth-child(even) td { background: #cccccc47 }
	
	.correctChoice {
		color: green;
		font-weight: bold;
	}
	table.resultContainer {
		
	}
	.choiceLine {
	}
	.barContainer {
		width: 	150px;
	    padding:5% 0;
	}
	.progress {
		margin:0 auto;
    }
	.bar {
		display: inline;
	}
	
	.resultTable.resultTableData {
		margin: 15px 15px;
		background-color: #ffffff99;
	}
	.resultTable.resultTableData td, .resultTable.resultTableData th {
		padding-left: 20px;
		padding-right: 20px;
	}
	.pass td, .pass th {
		color: #449e50;
	}
	.fail td, .fail th {
		color: #d63434;
	}
	.instructions {
		font-size: 10px;
		line-height: 14px;
		padding-top: 5px;
		white-space: normal;
	}
	.resultTable td.comments {
		text-align: left;
		white-space: normal;
		vertical-align: top;
		font-size: 10px;
	}
	.commentsDiv {
		margin-top: 3px;
		margin-bottom; 3px;
		margin-left: 20px;
		line-height: 12px;
	}
	.comments .user {
		font-weight: bold;
		margin-left: -20px;
	}
</style>
<script type="text/javascript" language="JavaScript">
function previewCase(caseid) {
	window.open("../case/case.do?method=testCase&mode=<%=org.imagequiz.model.IQExam.EXAM_MODE_TEST%>&caseid="+ caseid, "Case Preview", "toolbar=no, scrollbars=yes, resizable=yes, width=800, height=800");
}
</script>
</html>