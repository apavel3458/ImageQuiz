<%-- 
    Document   : admin
    Created on : Jun 21, 2013, 7:39:25 AM
    Author     : apavel
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.io.File, org.imagequiz.properties.ImageQuizProperties"%>
<%@page import="java.util.*, org.imagequiz.model.*"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- %@taglib uri="http://struts.apache.org/tags-bean" prefix="bean"%
%@taglib uri="http://struts.apache.org/tags-html" prefix="html"%-->
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ImageQuiz Admin Page</title>
         <link rel="stylesheet" href="admin.css">
         <link rel="stylesheet" href="../jslib/jquery-ui-1.10.3/themes/base/jquery-ui.css">
 		 <script src="../jslib/jquery-1.10.1.min.js"></script>
  		 <script src="../jslib/jquery-ui-1.10.3/ui/jquery-ui.js"></script>
  		 <script src="../jslib/jqueryplugins/jquery.popupWindow.js"></script>
  		 <script src="../jslib/imagezoomer/jquery.zoom.js"></script>
		  <script>
		  $(function() {
		    $( "#preview" ).dialog({
		    	autoOpen: false,
		    	position: ['center', 'center'],
		    	width: 'auto',
		        modal: true
		    });
		  });
		  $(function() {
			    $( "#loading" ).dialog({
			    	autoOpen: false,
			    	position: ['center', 'center'],
			    	width: 'auto',
			        modal: true
			    });
			  });
		  $(window).resize(function() {
			    $("#preview").dialog("option", "position", "center");
			});
		  function openPreview(id) {
			  var preview = $("#preview");
			  $(preview).html("<img id='previewimage' style='max-width: 900px;' src='images.do?method=getImage&imageid=" + id + "'>");
			  $("#loading").dialog("open");
			  $("#previewimage").load(function() {
				  $("#loading").dialog("close");
				  $("#preview").dialog("open");
				  $('#previewimage')
	  			    .wrap('<span style="display:inline-block"></span>')
	  			    .css('display', 'block')
	  			    .parent()
	  			    .zoom({
	  			    	on: 'grab'
	  			    });
			  });
		  }
		  $(document).ready(function() {
			  $('#popupDetailed').popupWindow({
				  height: 600,
				  width: 910
			  })
		  })
		  </script>
  		 
    </head>
    <body>
        <h1>Image Management</h1>
        <div class="box" style="display: inline-block; padding: 5px; background-color: #F5F5FF;">
        	<div class="error"><c:out value="${requestScope.errorMessage}"/></div>
	        <form action="images.do?method=upload" method="post" enctype="multipart/form-data">
	            <input type="text" name="description"/>
	            <c:if test="${not empty param.caseid}">
	            <input type="caseid" name="caseid"/>
	            </c:if>
	            <input type="file" name="uploadFile"/>
	            <input type="submit">
	        </form>
        </div>
        <div id="preview" title="Preview Image" style="margin-left: auto; margin-right: auto;">
  			
		</div>
		<div id="loading" title="Basic dialog" style="margin-left: auto; margin-right: auto;">
  			Loading Image...
		</div>
        <table class="admintable" style="margin-top: 5px; width: 400px;">
        	<tr>
        		<th style="white-space: nowrap;">Image ID</th>
        		<th>Image Description</th>
        		<th colspan="3">Actions</th>
        	</tr>
            <c:forEach var="image" varStatus="loopStatus" items="${requestScope.images}">
                <tr class="<c:out value="${loopStatus.index % 2 == 0? 'even' : 'odd' }"/>">
                    <td style="text-align: center;"><c:out value="${image.imageid}"/></td>
                    <td width="90%"><c:out value="${image.description}"/></td>
                    <td><a href="#" onclick="openPreview('<c:out value="${image.imageid}"/>')">View</a></td>
                    <td style="white-space: nowrap;"><a href="viewimage3.jsp?id=<c:out value="${image.imageid}"/>" id="popupDetailed">View Detailed</a></td>
                    <td><a href="images.do?method=deleteImage&id=<c:out value="${image.imageid}"/>">Delete</a></td>
                </tr>
            </c:forEach>
        </table>
        <input type="button" onclick="document.location='admin.do'" value="&lt;&lt; Back to Admin Page">
    </body>
</html>
