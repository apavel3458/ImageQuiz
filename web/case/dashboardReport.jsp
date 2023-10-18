<!DOCTYPE html>

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    <%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="dashboardHeader.jsp"/>
<style lang="css">
@import url(../share/fonts/Fonts.css?family=Montserrat);

.reportContainer {
	font-family: Montserrat, Arial, Helvetica;
}
.reportTitle {
	border-bottom: 1px solid #d4d4d4;
	padding-bottom: 5px;
}
.reportUser {
	font-size: 20px;
	font-family: inherit;
}
.reportTable {
	margin: 40px auto 10px auto;
}
.reportTable td.leftBorder {
	border-right: 8px solid #89c3ff;
}
.reportTable td {
	padding: 5px;
}
.reportTable th {
	padding: 0 30px 0 30px;
}
.reportSummary {
	margin: 30px 0 30px 0;
}
.reportSignature {
	font-size: 16px;
	margin-top: 60px;
}
.reportSignatureLine {
	display: inline-block;
	width: 180px;
	border-bottom: 1px solid black;
	margin: 0 20px 0 20px;
}
</style>

<div class="reportContainer text-center">
	<h3 class="text-center reportTitle">Achievement Report</h3>
            	<div class="reportUser">
            		<i class="material-icons" style="vertical-align: middle;">account_circle</i>
            		<c:out value="${sessionScope.security.firstName}"/> <c:out value="${sessionScope.security.lastName}"/> (PGY 1)
            	</div>
            	<div class="reportDate" id="reportDate">
            		<jsp:useBean id="now" class="java.util.Date" />
					<fmt:formatDate var="nowDate" value="${now}" pattern="MMM DD, YYYY" />
					${ nowDate }
            	</div>
            	<table class="reportTable">
            		<tr>
            			<th>Requirements Met</th>
            			<th>Requirements Outstanding</th>
            		</tr>
            		<tr>
            			<td class="leftBorder">
	            			<div class="achievementItem" style="width: 100%;">
			            		<span class="badge achievement level2"><i class="material-icons achievementIcon">timeline</i>ECG Level 2</span>
			            	</div>
	            			<c:forEach var="achievement" items="${sessionScope.security.achievements}">
				            	<div class="achievementItem">
				            		<span class="badge achievement level${achievement.level}"><i class="material-icons achievementIcon">local_hospital</i>${achievement.achievementShort } Level ${achievement.level }</span>
				            	</div>
		            		</c:forEach>
            			</td>
            			<td></td>
            		</tr>
            	</table>
      <h5 class="reportSummary">${sessionScope.security.firstName} ${sessionScope.security.lastName } has successfully completed PGY1 requirements!</h5>

	  <h5 class="reportSignature">
	  	Supervisor signature: <div class="reportSignatureLine">&nbsp;</div> 
	  	Date: <div class="reportSignatureLine">&nbsp;</div>
	  </h5>

</div>

<jsp:include page="dashboardFooter.jsp"/>
<script type="text/javascript">
$(function() {
})
</script>
</body>
</html>
