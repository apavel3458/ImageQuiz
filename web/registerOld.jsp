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
        <title>Image Quiz</title>
        <link rel="stylesheet" type="text/css" href="main.css"/>
    </head>
    <body class="index">
        <div class="main" style="padding-top: 100px;">
        <div class="box1" style="width: 500px; text-align: center; margin-left: auto; margin-right: auto;">
        <h2 style="margin-bottom: 3px;">ECG MASTER Tool</h2>

		<form action="user.do" method="POST">
		<input type="hidden" name="method" value="registerUser">
		<table class="table1" style="width: 80%; margin-left: auto; margin-right: auto; font-size: 16px;">
			<tr><td colspan="2" class="message" style="text-align: center;">
				<c:if test="${not empty message}">
					<c:out value="${message }"/>
					<c:remove var="message" scope="session"/>
				</c:if>
			</td></tr>
			<tr><td>Username: </td><td><input type="text" name="username" placeholder="Username" class="login" value="<c:out value="${username}"/>"></td></tr>
			<tr><td>Password: </td><td><input type="password" name="password" placeholder="Password" class="login"></td></tr>
			<tr><td>Repeat Password: </td><td><input type="password" name="password2" placeholder="Password Repeat" class="login"></td></tr>
			<tr><td>E-mail: </td><td><input type="text" name="email" class="login" placeholder="E-mail" value="<c:out value="${email}"/>"></td></tr>
			<tr><td style="color: gray;">First Name (Optional): </td><td><input type="text" name="firstname" placeholder="First Name (Optional)" class="login" value="<c:out value="${firstname}"/>"></td></tr>
			<tr><td style="color: gray;">Last Name (Optional): </td><td><input type="text" name="lastname" placeholder="Last Name (Optional)" class="login" value="<c:out value="${lastname}"/>"></td></tr>
			
			<tr><td style="font-size: 11px;">Which organ do ECGs record?<br><sup>(To filter robots)</su></td><td><input type="text" name="nobots" class="login" value="<c:out value="${nobots}"/>"></td></tr>
       	</table>
       	<input type="button" class="action-button" value="Back to Login" onclick="document.location='index.jsp'">
       	<input type="submit" class="action-button" value="Register">
       	
        </form>

        </div>
        
<%
Calendar calendar = Calendar.getInstance();
SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss dd/MM/yyyy");
String sDate = dateFormat.format(calendar.getTime());
System.out.println("System access log: " + sDate + " on " + request.getRemoteAddr());
%>
    </div>
    <%@include file="footer.jsp" %>
    </body>
</html>