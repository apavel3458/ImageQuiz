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
         <link rel="stylesheet" href="admin.css?v=1">
         <link rel="stylesheet" href="../jslib/jquery-ui-1.10.3/themes/base/jquery-ui.css">
 		 <script src="../jslib/jquery-1.10.1.min.js"></script>
  		 <script src="../jslib/jquery-ui-1.10.3/ui/jquery-ui.js"></script>
  		 <script src="../jslib/jqueryplugins/jquery.popupWindow.js"></script>
  		 <script src="../jslib/imagezoomer/jquery.zoom.js"></script>
  		 <script src="../jslib/imagequiz.js"></script>
		  <script>
		/*
		  $(window).resize(function() {
			  parent.$("#preview").dialog("option", "position", "center");
			});
		*/
		  function openPreview(id) {
			  var preview = parent.$("#preview");
			  $(preview).html("<img id='previewimage' style='max-width: 900px;' src='images.do?method=getImage&imageid=" + id + "'>");
			  parent.$("#loading").dialog("open");
			  parent.$("#previewimage").load(function() {
				  parent.$("#loading").dialog("close");
				  parent.$("#preview").dialog("open");
				  parent.$('#previewimage')
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
		  function insertImageCode(imageid) {
        		if (typeof parent.frames['editcase'].insertTextAtCursor == 'function') { 
        			parent.frames['editcase'].insertTextAtCursor("{image:" + imageid + "}");
        		} else {
        			alert("Select case to edit first.");
        		}
          }
		  </script>
  		 
    </head>
    <body>
        <div class="frameHeader" style="text-align: center;">IMAGE MANAGEMENT</div>
        <c:if test="${not empty requestScope.caseid}">
        <div class="box" style="margin-top: 5px; display: inline-block; padding: 5px; width: 390px; background-color: #F5F5FF;">
        	<div class="error"><c:out value="${requestScope.errorMessage}"/></div>
	        <form action="images.do?method=upload" method="post" enctype="multipart/form-data" onsubmit="return checkImageForm();">
	            <input type="text" name="description" id="imagedescription" class="disabled" style="width: 120px;" value="-- Enter Description --"/>
	            <c:if test="${not empty requestScope.caseid}">
	            <input type="hidden" name="caseid" value="<c:out value="${param.caseid}"/>">
	            </c:if>
	            <input type="file" name="uploadFile"/>
	            <input type="submit" value="Upload">
	            <div style="display: inline; font-size: 10px; color: grey;">(Description is optional)</div>
	            
	            
	        </form>
        </div>
        </c:if>
        <c:if test="${empty requestScope.caseid }">
        	<div style="margin-top: 10px; text-align: center; background-color: #E0F8F7;">
			Select a case to upload images.
			</div>
        </c:if>
        <div id="preview" title="Preview Image" style="margin-left: auto; margin-right: auto;">
  			
		</div>
		<!-- >div id="loading" title="Basic dialog" style="margin-left: auto; margin-right: auto;">
  			Loading Image...
		</div-->
        <table class="admintable imageTable" style="margin-top: 5px; width: 400px;">
        	<tr>
        		<th style="white-space: nowrap;">Image ID</th>
        		<th>Image Description</th>
        		<th colspan="4">Actions</th>
        	</tr>
            <c:forEach var="image" varStatus="loopStatus" items="${requestScope.images}">
                <tr class="<c:out value="${loopStatus.index % 2 == 0? 'even' : 'odd' }"/>">
                    <td style="text-align: center;"><c:out value="${image.imageId}"/></td>
                    <td width="90%"><c:out value="${image.description}"/></td>
                    <td style="white-space: nowrap;"><a href="#" onclick="insertImageCode('<c:out value="${image.imageId}"/>')"/>Insert Img</a></td>
                    <td style="white-space: nowrap;"><a href="#" onclick="openPreview('<c:out value="${image.imageId}"/>')">View</a> 
                        <a onclick="javascript: popitup('viewimage3.jsp?id=<c:out value="${image.imageId}"/>', 900, 500)" id="popupDetailed">(NW)</a></td>
                    <td><a href="images.do?method=deleteImage&imageid=<c:out value="${image.imageId}"/>&caseid=<c:out value="${param.caseid}"/>">Delete</a></td>
                </tr>
            </c:forEach>
        </table>

        <input type="button" onclick="document.location='admin.do'" value="&lt;&lt; Back to Admin Page">
        
        <script type="text/javascript">
	        $("#imagedescription")
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
	        function checkImageForm() {
	        	if ($("#imagedescription").val() == $("#imagedescription").prop("defaultValue")) {
	        		$("#imagedescription").val("");
	        	}
	        	return true;
	        }
        </script>
    </body>
</html>
