<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
    
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="">
    <meta name="author" content="">
    <link rel="icon" href="favicon.ico">

    <title>Signin Template for Bootstrap</title>

    <!-- Bootstrap core CSS -->
    <link href="css/lib/bootstrap.min.css" rel="stylesheet">

    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <link href="css/lib/ie10-viewport-bug-workaround.css" rel="stylesheet">

    <!-- Custom styles for this template -->    
    <link href="css/login.css" rel="stylesheet">
    

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>

  <body class="backgroundLogin">

    <div class="container loginBox" style="width: 300px;">

      <form class="form-signin" action="user.do" method="POST">
		<input type="hidden" name="method" value="login">
		<input type="hidden" name="requestPath" value="${sessionScope.requestPath}">
		<input type="hidden" name="origin" value="login">	
			
        <h2 class="form-signin-heading">Please sign in</h2>
        
        <c:if test="${not empty message}">
	       		<div class="alert alert-warning alertShorter" role="alert">
					<c:out value="${message }"/>
					<c:remove var="message" scope="session"/>
				</div>
			</c:if>
			<c:if test="${not empty error}">
				<div class="alert alert-warning alertShorter" role="alert">
					<c:out value="${error }"/>
					<c:remove var="error" scope="session"/>
				</div>
		</c:if>
        
        <label for="inputEmail" class="sr-only">Username/E-mail address</label>
        <input type="text" id="inputEmail" class="form-control" placeholder="Username/Email" name="username" required autofocus>
        <label for="inputPassword" class="sr-only">Password</label>
        <input type="password" id="inputPassword" class="form-control" name="password" placeholder="Password" required>
        <div class="checkbox">
          <label>
            <input type="checkbox" value="remember-me"> Remember me
          </label>
        </div>
        <button class="btn btn-lg btn-primary btn-block" type="submit">Sign in</button>
      </form>

    </div> <!-- /container -->


    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="jslib/bootstrap/ie10-viewport-bug-workaround.js"></script>
  </body>
</html>
