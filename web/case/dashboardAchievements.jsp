<!DOCTYPE html>

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="achievementBox">
            	<div class="username">
            		<i class="material-icons" style="vertical-align: middle;">account_circle</i>
            		<c:out value="${sessionScope.security.firstName}"/> <c:out value="${sessionScope.security.lastName}"/>
            	</div>
            	<div class="achievementList">
           			<div class="achievementItem">
	            		<span class="badge achievement level2"><i class="material-icons achievementIcon">timeline</i>ECG Level 2</span>
	            	</div>
	            	<c:forEach var="achievement" items="${sessionScope.security.achievements}">
		            	<div class="achievementItem">
		            		<span class="badge achievement level${achievement.level}"><i class="material-icons achievementIcon">local_hospital</i>${achievement.achievementShort } Level ${achievement.level }</span>
		            	</div>
	            	</c:forEach>
            	</div>
            	<div class="getAchievementReportWrapper">
            		<btn class="btn btn-link btn-xs" onclick="openReport()" style="font-weight: bold;">Get Report</btn>
            	</div>
            	
     
     <div class="modal fade" id="reportModal">
		  <div class="modal-dialog modal-lg ">
		    <div class="modal-content">
		      <div class="modal-header" style="padding-bottom: 0px;">
		        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		        <div class="reportHeader"><span>To print this page click "Print" at the bottom</span></div>
		      </div>
		      <div class="modal-body" style="color: black; padding-top: 0;">
		        <iframe class="reportIframe printSection" name="reportIframe" 
		         id="reportIframe" src=""
		         style="height: 400px;"></iframe>
		      </div>
		      <div class="modal-footer" style="text-align: center;">
		        <button type="button" class="btn btn-default" data-dismiss="modal">CLOSE</button>
		        <button type="button" class="btn btn-primary" onclick="printReport()">PRINT</button>
		      </div>
		    </div>
		  </div>
	</div>
</div>

<script type="text/javascript">
function openReport() {
	iframe = $("#reportModal").find(".reportIframe");
	iframe.attr('src', './dashboard.do?method=report');
	$('#reportModal').modal('show');
	
}
function printReport() {
 	window.frames["reportIframe"].focus();
	window.frames["reportIframe"].print();
/* 	printElement($("#reportIfram"), false, false); */
}
/* function resizeIframe() {
	var obj = $('#reportIframe')[0];
    obj.style.height = obj.contentWindow.document.documentElement.scrollHeight + 'px';
} */
</script>