<!DOCTYPE html>

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Bootstrap 101 Template</title>

    <!-- Bootstrap -->
    <link href="<c:url value="/css/lib/bootstrap.paper.min.css"/>" rel="stylesheet">

    <!-- link rel="stylesheet" type="text/css" href="jslib/jquery-ui-1.12.1/jquery-ui.min.css">
    <link rel="stylesheet" type="text/css" href="jslib/jquery-ui-1.12.1/jquery-ui.theme.min.css"-->
    
	<link rel="stylesheet" href="<c:url value="/css/register.css"/>">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>
  
<div class="container" style="padding-left: 0px;">
		 <form id="registerForm" action="user.do" method="POST">
		 <input type="hidden" name="method" value="registerUser">
		 
		 
		 
		<c:if test="${not empty message}">
	       		<div class="alert alert-warning alertShorter" role="alert">
					<c:out value="${message }"/>
					<c:remove var="message" scope="session"/>
				</div>
		</c:if>
		
		
		
		  <div class="input-group">
		    <span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
		    <input id="email" type="email" class="form-control" name="email" placeholder="Email" required value="<c:out value="${requestScope.email}"/>">
		  </div>
		  <div class="input-group">
		    <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
		    <input id="password" type="password" class="form-control" name="password" placeholder="Password" required>
		  </div>
		  <div class="input-group">
		    <span class="input-group-addon"><i class="glyphicon glyphicon-lock" style="color: white;"></i></span>
		    <input id="password" type="password" class="form-control" name="password2" placeholder="Confirm Password" required>
		  </div>
		  <div class="input-group">
		    <span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
		    <input id="msg" type="text" class="form-control" name="firstname" placeholder="First Name (optional)" style="width: 49%;"  value="<c:out value="${requestScope.firstname}"/>">
		    <input id="msg" type="text" class="form-control" name="lastname" placeholder="Last Name (optional)" style="width: 49%; margin-left: 2%;"  value="<c:out value="${requestScope.lastname}"/>">
		  </div>
		  <div class="input-group">
		  <span class="input-group-addon"><i class="glyphicon glyphicon-check"></i></span>
		  		<input type="text" class="form-control" name="nobots" placeholder="What organ does ECG measure? (one word)" required>
		  </div>
		  <div class="input-group text-center" style="width: 100%; margin-top: 30px;">
		  		  <button class="btn btn-lg btn-primary hidden" type="submit" id="registerButtonT">Sign in</button>
		  </div>
		</form>
</div>
 
	
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="<c:url value="/jslib/bootstrap/bootstrap.min.js"/>"></script>
    <script src='https://www.google.com/recaptcha/api.js'></script>
    
    <script type="text/javascript" language="JavaScript">
    $(function () {
    	
        

    	
    })
    
        function submitForm() {
        }

    </script>
 
  </body>
</html>