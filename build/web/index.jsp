<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>
<%@page import="java.util.*, java.text.*"%>
<% 
    request.getSession().removeAttribute("caseNumber");
    request.getSession().removeAttribute("caseNumberTotal");
%>
<html>
    <head>
        <title>Image Quiz</title>
        <link rel="stylesheet" type="text/css" href="main.css"/>
    </head>
    <body>
        <center>
        <div class="box1" style="width: 500px; text-align: center;">
        <h2>X-Ray Practice Center</h2>

        Click <a href="case/case.do">HERE</a> to begin exercise<br><br>

        Click <a href="admin/admin.do">HERE</a> to manage images <br>
        <p style="font-size: 10px;">Demo application created by Pavel Antiperovitch.  Build+Source udpate: Jul 18, 2013: 15:51.

        </div>
        </center>
<%
Calendar calendar = Calendar.getInstance();
SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss dd/MM/yyyy");
String sDate = dateFormat.format(calendar.getTime());
System.out.println("System access log: " + sDate + " on " + request.getRemoteAddr());
%>
    </body>
</html>