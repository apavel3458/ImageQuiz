<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Search Group Config</title>
<script src="../jslib/jquery-xmledit/lib/jquery.min.js"></script>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<link rel="stylesheet" href="admin.css">
<script type="text/javascript">
function deleteSearchGroup() {
	var groupId = $("#groupid").val();
	window.location = "admin.do?method=deleteSearchGroup&closewindow=true&groupid=" + groupId;
}
function validate() {
	if ("#groupname" == "") {
		alert("Group name cannot be blank!");
		return false;
	}
	return true;
}
</script>
<style type="text/css">
body {
	padding: 3px;
	margin: 0px;
}
.titleDiv {
	width: 100%; 
	background-color: #E0F8F7; 
	text-transform: uppercase; 
	font-size: 10px;
	padding: 0px;
	margin: 0px;
	text-align: center;
	font-weight: 600;
}

.success {
	width: 100%;
	text-align: center;
	margin: 5px;
}
</style>
</head>
<body>
<div class="titleDiv">Configuration of search terms for "search" type questions</div>
<div class="success"><c:out value="${requestScope.message }"/></div>
<div class="error"><c:out value="${requestScope.error }"/></div>
<form name="searchGroupForm" action="admin.do" method="POST" onsubmit="validate()">
	<input type="hidden" name="groupid" id="groupid" value="<c:out value="${requestScope.searchGroup.groupId }" default=""/>">
	<input type="hidden" name="method" value="saveSearchGroup">
	Group Name: <input type="text" name="groupname" value="<c:out value="${requestScope.searchGroup.groupName }" default=""/>"><br>
	<textarea name="groupterms" style="width: 100%; height: 300px; margin-top: 10px;"><c:out value="${requestScope.searchGroup.searchTermsText}" default=""/></textarea>
	<input type="submit" value="Save">
	<c:if test="${not empty requestScope.searchGroup.groupId}">
		<input type="button" value="Delete Group" onclick="deleteSearchGroup()">
	</c:if>
	<input type="button" value="Close" onclick="window.close()">
</form>
</body>
</html>