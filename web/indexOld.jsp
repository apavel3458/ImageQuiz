<!DOCTYPE HTML>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.*, java.text.*"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<html>
    <head>
        <title>Image Quiz</title>
        <link rel="stylesheet" type="text/css" href="main.css"/>
        <script src="jslib/jquery-1.10.1.min.js"></script>
        <script src="jslib/jquery-placeholder.min.js"></script>
        <script type="text/javascript" language="JavaScript">
        $(function() {
        	$("#logincode").placeholder();
        });
        
        function showhideLoginCode() {
        	$("#logincodeDiv").toggle();
        	$('#usertable').toggle();
        	$('.logincodetextDiv').toggle();
        }
        
		function loginGuest() {
			if ("Welcome to ECG Bootcamp! \n Please remember to register (FREE!) to use this tool so it can personalize your learning experience and provide you your performance reports.");
				document.location='user.do?method=loginGuest';
		}
        </script>
    </head>
    <body class="index">
        <div class="main" style="padding-top: 100px;">
        <div class="box1" style="width: 500px; text-align: center; margin-left: auto; margin-right: auto;">
        <h2 style="margin-bottom: 2px; margin-top: 5px;">Learn ECGs with</h2><img src="share/ECGbootcampLogoDark2.png" style="height: 30px; padding-left: 30px; width: auto; display:inline;"/>

		<form action="user.do" method="POST">
		<input type="hidden" name="method" value="login">
		<input type="hidden" name="requestPath" value="${sessionScope.requestPath}">
		<table style="width: 80%; margin-left: auto; margin-right: auto; font-size: 16px;" id="usertable">
			<tr><td colspan="2" class="message" style="text-align: center;">
			<c:if test="${not empty message}">
				<c:out value="${message }"/>
				<c:remove var="message" scope="session"/>
			</c:if>
			<c:if test="${not empty error}">
				<c:out value="${error }"/>
				<c:remove var="error" scope="session"/>
			</c:if>
			   </td></tr>
			<tr><td>Username or E-mail: </td><td><input type="text" name="username" class="login"></td></tr>
			<tr><td>Enter Password: </td><td><input type="password" name="password" class="login"></td></tr>
       	</table>
       	<div class="logincodetextDiv">Click <span class="customLink" onclick="showhideLoginCode();">HERE</span> if you have a login code</div>
       	
       	<fieldset class="logincodeDiv" id="logincodeDiv" style="display: none;">
       		<legend>Enter Login Code</legend>
       		<input type="text" name="logincode" id="logincode" class="login logincodeInput" style="text-align: center;" placeholder="---Login Code---" autocomplete="off">
       	</fieldset>
       	
       	<div class="logincodetextDiv" style="display: none;">Click <span class="customLink" onclick="showhideLoginCode();">HERE</span> to return to login screen</div>
       	<input type="submit" class="action-button" style="width: 80px;" value="Login">
       	<!-- input type="button" class="action-button action-button-grey" onclick="loginGuest()" style="width: 140px;" value="Try As Guest"-->
    
       	<input type="button" class="action-button" style="width: 100px;" value="Register" onclick="document.location='register.jsp'">
        </form>
        <p style="font-size: 10px; margin-top: 0px;"> 
        Build+Source update: Jan 1, 2016: 15:51.
		<c:out value="${sessionScope.security.lastName}"/>
        </div>
        
<%
Calendar calendar = Calendar.getInstance();
SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss dd/MM/yyyy");
String sDate = dateFormat.format(calendar.getTime());
System.out.println("System access log: " + sDate + " on " + request.getRemoteAddr());
request.getSession().removeAttribute("requestPath");
%>
    </div>
    <script type="text/javascript" src="jslib/mobilewarning.js"></script>
    <%@include file="footer.jsp" %>
    </body>
</html>