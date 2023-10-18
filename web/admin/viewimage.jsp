<%@ page language="java" contentType="text/html; charset=US-ASCII"
    pageEncoding="US-ASCII"%>
    
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
<title>Insert title here</title>
 		 <script src="../jslib/jquery-1.10.1.min.js"></script>
  		 <script src="../jslib/imagezoomer/jquery.zoom.js"></script>
  		  <script type="text/javascript">
  			$(document).ready(function(){
  			  $('#previewimage')
  			    .wrap('<span style="display:inline-block"></span>')
  			    .css('display', 'block')
  			    .parent()
  			    .zoom({
  			    	on: 'grab'
  			    });
  			});
        </script>
</head>
<body>
        <img id="previewimage" style="max-width: 900px;" src="images.do?method=getImage&amp;imageid=<c:out value="${param.id}"/>">
</body>
</html>