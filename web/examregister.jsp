<!DOCTYPE HTML>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.*, java.text.*"%>
<% 
    request.getSession().removeAttribute("caseNumber");
    request.getSession().removeAttribute("caseNumberTotal");
%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
    <head>
        <title>IQ - Exam Register</title>
        <script src="jslib/jquery-1.10.1.min.js"></script>
        <script type="text/javascript" src="jslib/setupwizard.js"></script>
        <link rel="stylesheet" type="text/css" href="css/exam.css">
        
        <link rel="stylesheet" type="text/css" href="css/quizsetup.css">
        <link rel="stylesheet" type="text/css" href="css/case.css">
        <link rel="stylesheet" type="text/css" href="css/exam.css">
        
        
    </head>
    <body>
    	<form action="user.do" id="msform" method="POST" style="margin: 20px auto;">
		<input type="hidden" name="method" value="loginForExam">
		<input type="hidden" name="logincode" value="<c:out value="${requestScope.loginCode}"/>">
			<!-- progressbar -->
			<ul id="progressbar" style="margion">
				<li style="width: 50%;" class="active">Confirm User</li>
				<li style="width: 50%;">Start Test</li>
			</ul>
	<!-- fieldsets -->
	
	<fieldset>
		<h2 class="fs-title">Please confirm information below</h2>

        <div style="color: #F31C1C;">Please ensure information below is correct <br> (red box = required)</div>

		<table class="quizIntroTable" style="margin-left: auto; margin-right: auto; font-size: 16px;">
			<tr><td colspan="2" class="message" style="text-align: center;">
				<c:if test="${not empty message}">
					<c:out value="${message}"/>
					<c:remove var="message" scope="session"/>
				</c:if>
			</td></tr>
				<c:if test="${not empty sessionScope.security}">
					<tr><td>Last Name: </td><td><input type="text" disabled="true" class="login disabled" style="width: 150px;" value="<c:out value="${sessionScope.security.lastName }"/>"></td></tr>
					<tr><td>First Name: </td><td><input type="text" disabled="true" class="login disabled" style="width: 150px;" value="<c:out value="${sessionScope.security.firstName }"/>"></td></tr>
				</c:if>
				<c:if test="${empty sessionScope.security }">
					<tr>
						<td>Last Name: </td><td><input type="text" name="lastname" style="width: 150px;" placeholder="Last Name" class="login"></td>
					</tr>
					<tr>
						<td>First Name: </td><td><input type="text" name="firstname" style="width: 150px;" placeholder="First Name" class="login"></td>
					</tr>
				</c:if>
			<tr><td>E-mail: </td><td><input type="text" name="email" style="width: 200px; border-color: #FF8A8A;" class="login" placeholder="E-mail" value="<c:out value="${sessionScope.security.email}"/>"></td></tr>
			
       	</table>
       	<input type="submit" class="action-button" value="Continue">
       	
       	</fieldset>
        </form>
        <script type="text/javascript" src="jslib/mobilewarning.js"></script>
        <div style="position: absolute; bottom: 50px; left: 0; right: 0; margin-left: auto; margin-right: auto; z-index: -1;">
        	<jsp:include page="footer.jsp" />
        </div>
    </body>
</html>