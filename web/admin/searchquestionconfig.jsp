<%-- 
    Document   : admin
    Created on : Jul 18, 2013, 12:12:01 PM
    Author     : apavel
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, org.imagequiz.model.*, org.imagequiz.model.question.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Admin Page</title>
        <link rel="stylesheet" href="admin.css">
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <script src="../jslib/jquery-xmledit/lib/jquery.min.js"></script>
        <script src="../jslib/iq.js"></script>
    </head>
    <body>
        <h3>Exercise Administration Page - for testing only</h3>
        <div class="error"><c:out value="${requestScope.error}"/></div>
        <div class="success"><c:out value="${requestScope.success}"/></div>
        <div class="boxBlue" style="width: 350px;">
	        <form action="admin.do" method="POST" style="width: 100%;" onsubmit="return checkExerciseForm();">
	        	<input type="text" name="groupname" class="disabled" id="exercisename" size="40" value="--Enter Group Name--">
	        	<input type="hidden" name="method" value="addSearchGroup">
	        	<input type="submit" value="Add Group">
	        </form>
        </div>
        <table class="admintable" id="admintable" style="width: 350px; margin-top: 10px;">
            <tr>
            	<th>ID</th>
                <th>Group Name</th>
                <th>Tag #</th>
                <th colspan="2">Actions</th>
            </tr>
            <c:forEach var="searchgroup" varStatus="loopStatus" items="${requestScope.searchGroupList}">
                <tr class="<c:out value="${loopStatus.index % 2 == 0? 'even' : 'odd' }"/>">
                    <td class="minimize" style="text-align: center;"><c:out value="${searchgroup.groupId}"/></td>
                    <td class="maximize"><c:out value="${searchgroup.groupName}"/> </td>
                    <td class="minimize" style="text-align: center;"><c:out value="${fn:length(searchgroup.searchTerms)}"/></td>
                    <td class="minimize"><a href="#" onclick="viewSearchGroup('<c:out value="${searchgroup.groupId}"/>')">Edit</a></td>
                    <td class="minimize">
                    	<a href="admin.do?method=deleteSearchGroup&groupid=<c:out value="${searchgroup.groupId}"/>" onclick="return confirm('Are you sure you want to delete <c:out value="${exercise.exerciseName}"/>')">Delete</a>
                    </td>
                </tr>
            </c:forEach>
        </table>
        <br>
        <a href="admin.do">Back To Admin Page</a>
        
        <!--  FANCY JAVASCRIPT -->
        <script type="text/javascript" language="JavaScript">
	        $("#exercisename")
	        .focus(function() {
	              if (this.value === this.defaultValue) {
	                  this.value = '';
	                  $(this).removeClass("disabled");
	              }
	        })
	        .blur(function() {
	              if (this.value === '') {
	                  this.value = this.defaultValue;
	                  $(this).addClass("disabled");
	              }
	      });
	        function checkExerciseForm() {
	        	if ($("#exercisename").val() == $("#exercisename").prop("defaultValue") || $("#exercisename").val() == "") {
	        		alert("Exercise name cannot be empty!");
	        		return false;
	        	}
	        	return true;
	        }
	        //admin hover table
	        $('#admintable tr').hover(function() {
	        	$(this).css("background-color", "#ECCEF5");
	        }, function() {
	        	$(this).css("background-color", "");
	        });
	        
	        
	        function viewSearchGroup(groupid) {

	        	url = "admin.do?method=viewSearchGroup&groupid=" + groupid

	        	window.open(url, "_blank", "toolbar=no, scrollbars=yes, resizable=yes, top=50, left=50, width=600, height=500");
	        	
	        }

        </script>
    </body>
</html>