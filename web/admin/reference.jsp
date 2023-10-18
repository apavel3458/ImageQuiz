<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
        <link rel="stylesheet" href="admin.css">
        
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/imagequiz.js"></script>
        <script src="../jslib/jquery-placeholder.min.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>ECG Bootcamp: Reference Manager</title>
<script type="text/javascript" language="JavaScript">
$(function() { 
	$('.admintable tr').hover(function() {
		$(this).css("background-color", "#ECCEF5");
	}, function() {
		$(this).css("background-color", "");
	});
})

</script>
</head>

<body>
	<h2 style="margin-bottom: 5px;">Reference Management</h2>
	<span style="font-size: 10px;">This page allows you to link certain words in the answer text to external learning resources</span>
	<form action="admin.do">
	<input type="hidden" name="method" value="addReference">
	<table class="admintable" width="600px">
	<tr>
		<th>ID</th>
		<th>Text Search</th>
		<th>Replace Link</th>
		<th>Actions</th>
	</tr>
	<c:forEach var="reference" varStatus="loopStatus" items="${requestScope.references}">
		<tr class="<c:out value="${loopStatus.index % 2 == 0? 'even' : 'odd' }"/>">
		<td class="minimize" style="text-align: center;">${reference.referenceId }</td>
		<td class="maximize">${reference.searchText }</td>
		<td class="maximize">${reference.replaceLink }</td>
		<td class="minimize"><a href="admin.do?method=deleteReference&referenceid=${reference.referenceId}">Delete</a></td>
		</tr>
	</c:forEach>
	<tr>
		<td colspan="4"></td>
	</tr>
	<tr>
		<td class="inputRow">Add</td>
		<td class="inputRow"><input type="text" style="width: 300px;" name="searchtext" placeholder="Search Text"></td>
		<td class="inputRow"><input type="text" style="width: 300px;" name="replacelink" placeholder="Replace Link"></td>
		<td class="inputRow"><input type="submit" value="Add"></td>
	</tr>
	</table>
	</form>
	<input type="button" onclick="document.location='admin.do'" value="Back to Admin">
</body>

</html>