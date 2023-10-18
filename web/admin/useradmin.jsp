<%-- 
    Document   : admin
    Created on : Jul 18, 2013, 12:12:01 PM
    Author     : apavel
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, org.imagequiz.model.*, org.imagequiz.model.user.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
	List<IQUser> userslist = (List<IQUser>) request.getAttribute("users");

/*     Collections.sort(userslist, new Comparator<IQUser>() {
    	
        public int compare (IQUser u1, IQUser u2) {
        	if (u1.getUserGroups().size() == 0 || u2.getUserGroups().size() == 0) return u1.getUserId().compareTo(u2.getUserId());
        	IQUserGroup ug1 = u1.getUserGroups().get(0);
        	IQUserGroup ug2 = u2.getUserGroups().get(0);
            int compared = ug1.getGroupName().compareTo(ug2.getGroupName());
            if (compared < 0) return 1;
            else if (compared == 0) return u1.getUserId().compareTo(u2.getUserId());
            else return -1;
        }
    }); */
    request.setAttribute("users", userslist);
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Admin Page</title>
        <link rel="stylesheet" href="admin.css">
        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-placeholder.min.js"></script>
    </head>
    <body>
        <h3>User Admin Page</h3>
        <c:if test="${not empty message}">
				<div class="error"><c:out value="${message}"/></div>
				<c:remove var="message" scope="session"/>
			</c:if>
        <div class="success"><c:out value="${requestScope.success}"/></div>
        <div class="boxBlue" style="width:800px;">
	        <form action="admin.do?method=addUser" method="POST" style="width: 100%;">
	        	<input type="text" name="username" class="" id="username" size="20" placeholder="Username (optional)">
	        	<input type="text" name="password" id="password" size="20" placeholder="- Password -">
	        	<input type="text" name="email" class="required" onblur="fillUserPass()" id="email" size="20" placeholder="- Email -">
	        	<input type="text" name="lastname" id="lastname" size="20" placeholder="- Last Name -">
	        	<input type="text" name="firstname" id="firstname" size="20" placeholder="- First Name -">
	        	<select name="usergroup">
	        		<option default value="1">-- User Group --</option>
	        		<c:forEach var="iusergroup" varStatus="loopStatus" items="${requestScope.userGroups}">
	        		<option value="<c:out value="${iusergroup.groupId}"/>"><c:out value="${iusergroup.groupName }"/></option>
	        		</c:forEach>
	       		</select>
	        	<input type="hidden" name="method" value="addUser">
	        	<input type="submit" value="Add New User">
	        </form>
        </div>
        <form name="updateUser" action="admin.do">
            <input type="hidden" name="method" value="updateUser">
            <input type="hidden" name="userid" id="updateuserid">
	        <table class="admintable" id="admintable" style="width: 450px; margin-top: 10px;">
	            <tr>
	            	<th>ID</th>
	                <th>Username</th>
	                <th>First - Last Name</th>
	                <th>Email</th>
<!-- 	                <th>Groups</th> -->
	                <th>Last Logged-In</th>
	                <th>Login #</th>
	                <th colspan="3">Actions</th>
	            </tr>
	            <c:forEach var="iuser" varStatus="loopStatus" items="${requestScope.users}">
	            	
		                <tr class="<c:out value="${loopStatus.index % 2 == 0? 'even' : 'odd' }"/>">
		                    <td class="minimize" style="text-align: center;"><c:out value="${iuser.userId}"/></td>
		                    <td class="maximize" onclick="convertToField(this, <c:out value="${iuser.userId}"/>, 'username')"><c:out value="${iuser.username}"/> </td>
		                    <td class="minimize" onclick="convertToField(this, <c:out value="${iuser.userId}"/>, 'firstnamelastname')"><c:out value="${iuser.firstName}"/> - <c:out value="${iuser.lastName}"/></td>
		                    <td class="minimize" onclick="convertToField(this, <c:out value="${iuser.userId}"/>, 'email')"><c:out value="${iuser.email}"/></td>
<%-- 		                    <td class="minimize">
		                    	<select name="groupInactive" class="selectGroups" onclick="convertToField(this, <c:out value="${iuser.userId}"/>, 'group')">
		        					<option default value=""> </option>
		        					<c:forEach var="genericGroup" varStatus="loopStatus" items="${requestScope.userGroups}">
		        						<option 
		        						<c:forEach var="userGroup" varStatus="loopStatus" items="${iuser.userGroups}">
		                    				<c:if test="${userGroup.groupId == genericGroup.groupId}"> selected </c:if>
		                    			</c:forEach>
		        						value="<c:out value="${genericGroup.groupId}"/>"><c:out value="${genericGroup.groupName }"/></option>
		        					</c:forEach>
		       					</select>
	
		                    </td> --%>
		                    <td class="minimize"><fmt:formatDate value="${iuser.lastLogin}" pattern="dd/MMM/yyyy HH:mm" /></td>
		                    <td class="maximize"><c:out value="${iuser.loginCount}"/></td>
		                    <td class="minimize"><input type="submit" value="Update"></td>
		                    <td class="minimize"><input type="password" id="newpassword<c:out value="${iuser.userId}"/>" size="6"><input type="button" value="Change PW" onclick="changeThisPassword('<c:out value="${iuser.userId}"/>')"></td>
		                    <td class="minimize">
		                    	<a href="admin.do?method=deleteUser&userid=<c:out value="${iuser.userId}"/>" onclick="return confirm('Are you sure you want to delete <c:out value="${iuser.username}"/>')">Delete</a>
		                    </td>
		                </tr>
	                
	            </c:forEach>
	        </table>
	    </form>
        <br>
        <input type="button" onclick="document.location='admin.do'" value="Back to Admin">
        <input type="button" onclick="document.location='../user.do?method=logout'" value="Logout">
        
        <!--  FANCY JAVASCRIPT -->
        <script type="text/javascript" language="JavaScript">
        	$("#username, #password, #email, #realname").each(function () {
	        $(this)
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
        	});
        	$(function() {
        		$("input").placeholder();
        	})
        	
        	function convertToField(ele, userId, fieldName) {
        		if ($("#updateuserid").val() != "") {
        			return null;
        		}
        		$(ele).prop('onclick',null).off('click');
        		var v = $(ele).html();
        		$(ele).removeClass("selectGroups");
        		$(".selectGroups").attr("disabled", "true");
        		if (fieldName == 'group') {
        			$(ele).attr("name", "group");
        		} else if (fieldName == 'firstnamelastname') {
        			$(ele).empty();
        			var fname = v.split(' - ')[0];
        			var lname = v.split(' - ')[1];
        			$(ele).append("<input type='text' size='10' name='firstname' value='" + fname + "'>");
        			$(ele).append("<input type='text' size='10' name='lastname' value='" + lname + "'>");
        		} else {
        			$(ele).empty();
        			$(ele).append("<input type='text' size='10' name='" + fieldName + "' value='" + v + "'>");
        		}
        		$("#updateuserid").val(userId);
        	}
        	
	        //admin hover table
	        $('#admintable tr').hover(function() {
	        	$(this).css("background-color", "#ECCEF5");
	        }, function() {
	        	$(this).css("background-color", "");
	        });
	        
	        function fillUserPass() {
	        	if ($("#username").val() == '') {
	        		$("#username").val($("#email").val());
	        	}
	        	if ($("#password").val() == '') {
	        		$("#password").val($("#email").val());
	        	}
	        }
	        
	        function changeThisPassword(userId) {
	        	var newPassword = $('#newpassword' + userId).val();
	        	
	        	//create a POST reauest
	        	var form = $('<form></form>');

	            form.attr("method", "POST");
	            form.attr("action", "admin.do");

	            var parameters = {};
	            parameters['userid'] = userId;
	            parameters['newpassword'] = newPassword;
	            parameters['method'] = "setPassword";
	            
	            $.each(parameters, function(key, value) {
	                var field = $('<input></input>');
	                field.attr("type", "hidden");
	                field.attr("name", key);
	                field.attr("value", value);
	                form.append(field);
	            });

	            // The form needs to be a part of the document in
	            // order for us to be able to submit it.
	            $(document.body).append(form);
	            form.submit();
	        	//alert('admin.do?method=setPassword&userid=' + userId + '&newpassword='+newPassword);
	        }

        </script>
    </body>
</html>
