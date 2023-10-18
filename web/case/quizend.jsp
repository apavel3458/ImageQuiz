<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>ECG Master Quiz Setup</title>

<script src="../jslib/jquery-1.10.1.min.js"></script>
<script src="../jslib/jquery-ui-1.10.3/ui/jquery-ui.js"></script>
<script type="text/javascript" src="../jslib/tagit/tag-it.min.js"></script>
<script type="text/javascript" src="../jslib/setupwizard.js"></script>


<link rel="stylesheet" href="../jslib/jquery-ui-1.10.3/themes/base/jquery-ui.css">

<link rel="stylesheet" type="text/css" href="../css/quizsetup.css">
<link href="../jslib/tagit/jquery.tagit.css" rel="stylesheet" type="text/css">
<link href="../jslib/tagit/tagit.ui-zendesk.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" type="text/css" href="../css/case.css">
</head>
<body>
    	<jsp:include page="header.jsp" />
    
    
<!-- multistep form -->
<form id="msform" action="case.do">
    <input type="hidden" name="method" value="dashboard">

	<!-- fieldsets -->
	
	<fieldset>
		<h2 class="fs-title">Congratulations, Quiz Completed!</h2>

			<table class="quizIntroTable" style="margin-left: auto; margin-right: auto;">
	        	<tr><th>
	        		Total Questions:
	        		</td>
	        		<td>
	        			<c:out value="${requestScope.totalQuestions }"/> questions
	        		</td>
	        	</tr>
        	</table>

		<input type="submit" name="submit" class="submit action-button" style="width: 150px;" value="Back to Dashboard" />
	</fieldset>
</form>

        <div style="position: absolute; bottom: 10px; left: 0; right: 0; margin-left: auto; margin-right: auto; z-index: -1;">
        <jsp:include page="../footer.jsp" />
        </div>

    </body>
</html>
