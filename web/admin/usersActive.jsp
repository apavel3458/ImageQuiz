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
	<H5 style="float:left; margin-left: 50px; font-weight: bold;">Active Users: ${requestScope.sessions.size() }</H5>
	<input type="button" onclick="document.location='../admin/admin.do'" value="Back to Admin" style="float:left; margin-top: 15px; margin-left: 18px;">

	<table class="resultTable resultTableData" style="clear:left;">
		<tr>
		</tr>
		<c:forEach var="session" items="${requestScope.sessions }">
			<c:set var="user" value="${session.getAttribute('security')}"/>
			<tr>
				<td>
					${user.userId } - ${user.firstName} ${user.lastName} [${user.email}]<br/>
					<span class="label">Session ID:</span> ${session.id } <br/>
					<jsp:useBean id="dateValue" class="java.util.Date"/>
					<jsp:useBean id="nowDate" class="java.util.Date"/>
					<jsp:setProperty name="dateValue" property="time" value="${session.lastAccessedTime}"/>
					<span class="label">Last Accessed:</span> <fmt:formatDate pattern = "yyyy-MM-dd HH:mm:ss" value = "${dateValue}" /> <br/>
					<jsp:setProperty name="dateValue" property="time" value="${session.creationTime}"/>
					<span class="label">Session Created:</span> <fmt:formatDate pattern = "yyyy-MM-dd HH:mm:ss" value = "${dateValue}" /> <br/>
					<c:set var="expiresInMilis" value="${session.maxInactiveInterval*1000 - (nowDate.time - session.lastAccessedTime)}"/>
					<span class="label">Expires in (m):</span> 
					<fmt:formatNumber var="expiresInMin" value="${expiresInMilis/(1000*60)}" maxFractionDigits="1" /> ${expiresInMin }
					(<span class="label">Expire Interval: </span>${session.maxInactiveInterval/60 }) <br/>
					
				</td>
				<td><button class="btn btn-danger" onclick="if (confirm('Log off this person?')) document.location='admin.do?method=sessionsTerminate&sessionId=${session.id}'">Terminate</button></td>
			</tr>
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
	
	.label {
		color: grey;
	}
</style>
<script type="text/javascript" language="JavaScript">

</script>
</html>