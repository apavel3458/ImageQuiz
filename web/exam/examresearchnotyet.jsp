<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>ECG Master Quiz Setup</title>

<script src="../jslib/jquery-1.10.1.min.js"></script>
<script type="text/javascript" src="../jslib/setupwizard.js"></script>
<c:set var="req" value="${pageContext.request}" />
<c:set var="baseURL" value="${req.scheme}://${req.serverName}:${req.serverPort}${req.contextPath}" />

<link rel="stylesheet" type="text/css" href="css/quizsetup.css">
<link rel="stylesheet" type="text/css" href="css/case.css">
<link rel="stylesheet" type="text/css" href="css/exam.css">

</head>
<body>
	<jsp:include page="header.jsp" />

<!-- multistep form -->
<form id="msform" action="exam.do">
    <input type="hidden" name="method" value="quizNavigation">
	<!-- progressbar -->
	<ul id="progressbar">
		<li style="width: 33%;">Module</li>
		<li style="width: 33%;" class="active">End Module</li>
		<li style="width: 33%;">Delayed Post-Test</li>
	</ul>
	<!-- fieldsets -->
	
	<fieldset>
			<h2 class="fs-title finished">We appreciate your interest to proceed, but you still need to wait ${requestScope.daysLeft } days before proceeding.</h2>
			
			
			<br/>

		<input type="button" name="quit" class="action-button" onclick="document.location='${baseURL}/study/registration.jsp'" value="Exit">
	</fieldset>
</form>

        <div style="position: absolute; bottom: 50px; left: 0; right: 0; margin-left: auto; margin-right: auto; z-index: -1;">
        </div>

    </body>
</html>
