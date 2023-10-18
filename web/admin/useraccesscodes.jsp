<%-- 
    Document   : admin
    Created on : Jul 18, 2013, 12:12:01 PM
    Author     : apavel
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="req" value="${pageContext.request}" />
<c:set var="url">${req.requestURL}</c:set>
<c:set var="uri" value="${req.requestURI}" />
<c:set var="fullURL" value="${fn:substring(url, 0, fn:length(url) - fn:length(uri))}${req.contextPath}"/>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>User Access Codes</title>
        <link rel="stylesheet" href="admin.css">
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-placeholder.min.js"></script>
        <script src="../jslib/iq.js"></script>
        <script type="text/javascript">
        	function confirmAndGenerateNew() {
        		if (confirm("Are you sure you want to clear all access codes and generate new ones?"))
        			document.location='exam.do?method=generateAccessCodes&examid=<c:out value="${requestScope.exam.examId }"/>'
        	}
        	$(function() {
    	        //admin hover table
    	        $('#admintable tr').hover(function() {
    	        	$(this).css("background-color", "#ECCEF5");
    	        }, function() {
    	        	$(this).css("background-color", "");
    	        });
        	});
        	function copy(containerid) {
        			if (document.selection) { 
        			    var range = document.body.createTextRange();
        			    range.moveToElementText(document.getElementById(containerid));
        			    range.select().createTextRange();
        			    document.execCommand("copy"); 

        			} else if (window.getSelection) {
        			    var range = document.createRange();
        			     range.selectNode(document.getElementById(containerid));
        			     window.getSelection().addRange(range);
        			     document.execCommand("copy");
        			}
        	}

        </script>
    </head>
    <body>
        <h3>User Admin Page</h3>
        <c:if test="${not empty message}">
				<div class="error"><c:out value="${message}"/></div>
				<c:remove var="message" scope="session"/>
		</c:if>
		
        <div class="success"><c:out value="${requestScope.success}"/></div>
<%-- 		<div style="margin: 5px; float:left;">
			<div style="display: inline; padding: 2px; border: 1px solid #AFAFFF;">General Survey Access Code: <span class="code" ><c:out value="${requestScope.genericExamAccessCode}"/></span></div>
			
      	    
        </div> --%>
        <input type="button" class="no-print" onclick="confirmAndGenerateNew()" value="Generate New Access Codes" style="float: left; margin-left: 5px;">
        	<input type="button" class="no-print" value="E-mail Login Links">
        <div style="margin: 5px; clear:left;">
			<div>General Survey Access Link: 
				<div class="code" id="generalURL" style="background-color: #dadada; width: 500px; font-size: 15px;">${fullURL}/user.do?method=login&logincode=${requestScope.genericExamAccessCode}</div></div>
				<button style="margin: 10px 20px 0px 200px;" onclick="copy('generalURL');">Copy Access Link!</button>
        </div>

        <div style="clear: left; float:left;">
        	<table class="admintable" id="admintable" style="width: 350px; margin-top: 5px;">
	            <tr>
	            	<th>Last Name</th>
	            	<th>First Name</th>
	            	<th>E-mail</th>
	            	<th>Access Code</th>
	            	<th>Private URL</th>
	            </tr>
	            <c:forEach var="entry" varStatus="loopStatus" items="${requestScope.userAccessCodeMap}">
	            	
		                <tr class="<c:out value="${loopStatus.index % 2 == 0? 'even' : 'odd' }"/>">
		                    <td class="minimize" style="text-align: left;"><c:out value="${entry.key.lastName}"/></td>
		                    <td class="minimize"><c:out value="${entry.key.firstName}"/></td>
		                    <td class="minimize"><c:out value="${entry.key.email}"/></td>
		                    <td class="minimize code" style="text-align: center;"><c:out value="${entry.value}"/></td>
		                	<td class="minimize smallFont" style="text-align: center;">${fullURL}/user.do?method=login&logincode=${entry.value}</td>
		                </tr>
	                
	            </c:forEach>
	        	</table>
	    </div>

    </body>
</html>
