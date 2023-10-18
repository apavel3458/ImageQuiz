<%@page import="java.util.List"%>
<%@page import="org.imagequiz.model.result.IQCaseSummary"%>
<%@page import="java.util.HashSet"%>
<%@page import="org.imagequiz.model.question.IQAnswer"%>
<%@page import="java.util.Set"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" type="text/css" href="../results/results.css">
<script src="../jslib/jquery-1.10.1.min.js"></script>
<script src="../jslib/imagequiz.js"></script>


<title>Results by Case</title>
<script type="text/javascript" language="JavaScript"> 
function previewCase(caseid) {
	window.open("../case/case.do?method=testCase&mode=<%=org.imagequiz.model.IQExam.EXAM_MODE_TEST%>&caseid="+ caseid, "Case Preview", "toolbar=no, scrollbars=yes, resizable=yes, width=800, height=800");
}

var lastClass = '';
$(function() {
	$("#data tr").click(function() {
	    //var selected = $(this).hasClass("selectedRow");
	    $("#data tr.selectedRow").attr('class', lastClass);
	    lastClass = $(this).attr('class');
	    $(this).attr('class', 'selectedRow');
	    //$(this).addClass("selectedRow");
	});
});
</script>
</head>
<body>
	<H2 style="float:left; margin-left: 50px;">Results By Case | </H2>
	<input type="button" onclick="document.location='../admin/admin.do'" value="Back to Admin" style="float:left; margin-top: 15px; margin-left: 18px;">
	<table class="resultTable" style="clear:left;" id="data">
		<tr>
			<th>ECG</th>
			<th>Answer Key (score)</th>
			<th>[%] True Positives <div class="truePositives">(Correct Dx)</div></th>
			<th>[%] False Positives <div class="falsePositives">(Wrong Dx)</div></th>
			<th>[%] False Negatives <div class="falseNegatives">(Missed Dx)</div></th>
		</tr>
		
		<c:forEach var="caseSummary" items="${requestScope.results}" varStatus="loopStatus">
		<tr class="${loopStatus.index % 2 == 0 ? 'even' : 'odd'}">
			<td>
				<a onclick="previewCase(${caseSummary.icase.caseId})" style="cursor:pointer;">
					<img src="../share/ecgPic.png">
					<div style="text-align: left; vertical-align: center;">
						(ID:${caseSummary.icase.caseId}) ${caseSummary.icase.caseName}
						<a onclick="popitup('admin.do?method=viewCase&caseid=${caseSummary.icase.caseId}', 'editCase', 1000, 500)" class="resultsLink" style="font-size:0.6em; float:right; padding-right: 4px; margin-bottom: 2px;">Edit</a>
					</div>
				</a>
			</td>
			<td>
				<c:forEach var="questions" items="${caseSummary.icase.questionList}">
					<table class="innerTable">
						<c:forEach var="answer" items="${questions.answers}">
							<tr>
								<td class="text"><div class="answerKey">${answer}</div></td>
								<td class="number">(<fmt:formatNumber value="${answer.score}" minFractionDigits="0"/>)</td>
							</tr>
						</c:forEach>
					</table>
				</c:forEach>
				<br/>
				<div class="resultsGrey"><b>Total Answers:</b> ${caseSummary.answerCount}</div>
				<div class="resultsGrey"><b>Average Time:</b> <fmt:formatNumber type="number" maxFractionDigits="0" value="${(caseSummary.averageSecondsTaken/60)-0.49 }"/>m<fmt:formatNumber type="number" maxFractionDigits="0" value="${caseSummary.averageSecondsTaken%60 }"/>s</div>
			</td>
			<td>
				<%List<IQCaseSummary.Item> tps = ((IQCaseSummary) pageContext.getAttribute("caseSummary")).getTruePositivesSorted();
			    pageContext.setAttribute("tps", tps);%>
				
				<table class="innerTable">
				<c:forEach var="tp" items="${tps}" varStatus="status">
					<tr>
						<td class="number">[<fmt:formatNumber type="number" maxFractionDigits="0" value="${(tp.occurences/caseSummary.answerCount)*100}"/>]</td>
						<td class="text">
						   <div class="barGraph barGraphTP" style="width: <fmt:formatNumber type="number" maxFractionDigits="0" value="${(tp.occurences/caseSummary.answerCount)*100}"/>%">&nbsp;</div>
						   <div class="truePositives${status.first ? ' bold' : ''}"> ${tp.result}</div>
						 </td>
					</tr>
				</c:forEach>
				</table>
			</td>
			<td>
				<%List<IQCaseSummary.Item> fps = ((IQCaseSummary) pageContext.getAttribute("caseSummary")).getFalsePositivesSorted();
			    pageContext.setAttribute("fps", fps);%>
				
				<table class="innerTable">
				<c:forEach var="fp" items="${fps}" varStatus="status">
					<c:if test="${status.index < 6 }">
						<tr>
						<td class="number">[<fmt:formatNumber type="number" maxFractionDigits="0" value="${(fp.occurences/caseSummary.answerCount)*100}"/>]</td>
						<td class="text">
							<div class="barGraph barGraphFP" style="width: <fmt:formatNumber type="number" maxFractionDigits="0" value="${(fp.occurences/caseSummary.answerCount)*100}"/>%">&nbsp;</div>
							<div class="falsePositives${status.first ? ' bold' : ''}">${fp.result}</div>
						</td>
						</tr>
					</c:if>
				</c:forEach>
				</table>
			</td>
			<td>
				<%List<IQCaseSummary.Item> fns = ((IQCaseSummary) pageContext.getAttribute("caseSummary")).getFalseNegativesSorted();
			    pageContext.setAttribute("fns", fns);%>
				
				<table class="innerTable">
				<c:forEach var="fn" items="${fns}" varStatus="status">
					<tr>
					<td class="number">[<fmt:formatNumber type="number" maxFractionDigits="0" value="${(fn.occurences/caseSummary.answerCount)*100}"/>]</td>
					<td class="text">
						<div class="barGraph barGraphFN" style="width: <fmt:formatNumber type="number" maxFractionDigits="0" value="${(fn.occurences/caseSummary.answerCount)*100}"/>%">&nbsp;</div>
						<div class="falseNegatives${status.first ? ' bold' : ''}">${fn.result}</div>
					</td>
					</tr>
				</c:forEach>
				</table>
			</td>
		</tr>
		</c:forEach>
	</table>
	
</body>
</html>