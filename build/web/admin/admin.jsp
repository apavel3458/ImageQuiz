<%-- 
    Document   : admin
    Created on : Jul 18, 2013, 12:12:01 PM
    Author     : apavel
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, org.imagequiz.model.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    List<IQCaseList> exercises = (List<IQCaseList>) request.getAttribute("exerciselist");
    %>

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
	        <form action="admin.do?method=addExercise" method="POST" style="width: 100%;" onsubmit="return checkExerciseForm();">
	        	<input type="text" name="exercisename" class="disabled" id="exercisename" size="40" value="--Enter Exercise Name--">
	        	<input type="hidden" name="method" value="addExercise">
	        	<input type="submit" value="Add">
	        </form>
        </div>
        <table class="admintable" id="admintable" style="width: 350px; margin-top: 10px;">
            <tr>
            	<th>ID</th>
                <th>Exercise Name</th>
                <th>Question #</th>
                <th colspan="2">Actions</th>
            </tr>
            <c:forEach var="exercise" varStatus="loopStatus" items="${requestScope.exerciselist}">
                <tr class="<c:out value="${loopStatus.index % 2 == 0? 'even' : 'odd' }"/>">
                    <td class="minimize" style="text-align: center;"><c:out value="${exercise.exerciseId}"/></td>
                    <td class="maximize"><c:out value="${exercise.exerciseName}"/> </td>
                    <td class="minimize" style="text-align: center;"><c:out value="${fn:length(exercise.cases)}"/></td>
                    <td class="minimize"><a href="admin.do?method=editExercise&id=<c:out value="${exercise.exerciseId}"/>">Edit</a></td>
                    <td class="minimize">
                    	<a href="admin.do?method=deleteExercise&id=<c:out value="${exercise.exerciseId}"/>" onclick="return confirm('Are you sure you want to delete <c:out value="${exercise.exerciseName}"/>')">Delete</a>
                    </td>
                </tr>
            </c:forEach>
            <tr>
            	<td style="text-align: center;">0</td>
                <td>Test Exercise 2 (Disabled)</td>
                <td style="text-align: center;">5</td>
                <td>Edit</td>
                <td>Delete</td>
            </tr>
        </table>
        <br>
        <a href="images.do?method=list">Manage Images</a>
        <a href="../">Back To Main Page</a>
        
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

        </script>
    </body>
</html>
