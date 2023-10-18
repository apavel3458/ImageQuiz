<%@ page language="java" contentType="text/html; charset=US-ASCII"
    pageEncoding="US-ASCII"%>
    
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
<title>Insert title here</title>
 		 <script src="../jslib/jquery-1.10.1.min.js"></script>
 		 <script src="../jslib/jquery-migrate-1.2.1.min.js"></script>
  		 <script src="../jslib/jqueryplugins/jquery.mousewheel.js"></script>
  		 <script src="../jslib/imagezoomer/jquery.snipe.js"></script>
  		  <script type="text/javascript">
  		 $(document).ready(function() {
        	$('#previewimage').snipe({
        	size: '300'
            });
         });
        </script>
</head>
<body>
        <img id="previewimage" style="max-width: 100%;" src="images.do?method=getImage&amp;imageid=<c:out value="${param.id}"/>">
</body>
</html>