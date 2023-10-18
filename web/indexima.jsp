<!DOCTYPE HTML>
<%@page contentType="text/html"%>
<%@page pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@page import="java.util.*, java.text.*"%>


<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <meta name="description" content="ECG Bootcamp is an online resource made for medical professionals to learn and practice ECG interpretation">
    <meta name="author" content="Pavel Antiperovitch">
    <link rel="icon" href="favicon.ico?v=2">
    <link rel="icon" type="image/png" sizes="32x32" href="favicon-32x32.png">

    <title>IM Academy - Learn Internal Medicine Online</title>

    <!-- Bootstrap core CSS -->
    <link href="css/lib/bootstrap.min.css" rel="stylesheet">

    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <link href="css/lib/ie10-viewport-bug-workaround.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->

    <!-- Custom styles for this template -->
    <link href="css/lib/carousel.css" rel="stylesheet">
    <link href="css/login.css" rel="stylesheet">
    <link href="css/iframemodal.css" rel="stylesheet">
  </head>
<!-- NAVBAR
================================================== -->
<!--[if IE 8]>
<script type="text/javascript">
alert("You are using a browser that is more than 8 years old.  Please update or download Google Chrome (recommended).");
</script>
<![endif]-->
<!--[if IE 9]>
<script type="text/javascript">
alert("You are using a browser that is more than 6 years old.  Please update or download Google Chrome (recommended).");
</script>
<![endif]-->
  <body>
    <div class="navbar-wrapper">
      <div class="container">
	
	

	
        <nav class="navbar navbar-inverse navbar-static-top">
          <div class="container">
            <div class="navbar-header">
              <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
              </button>
              <a class="navbar-brand" href="#">IM Academy</a>
            </div>
            <div id="navbar" class="navbar-collapse collapse">
              <ul class="nav navbar-nav">
                <li class="active"><a href="#">Home</a></li>
                <li><a href="aboutima.jsp">About</a></li>
                <li><a href="<c:url value="/aboutima.jsp"/>">Contact</a></li>
                <!-- li class="dropdown">
                  <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Dropdown <span class="caret"></span></a>
                  <ul class="dropdown-menu">
                    <li><a href="#">Action</a></li>
                    <li><a href="#">Another action</a></li>
                    <li><a href="#">Something else here</a></li>
                    <li role="separator" class="divider"></li>
                    <li class="dropdown-header">Nav header</li>
                    <li><a href="#">Separated link</a></li>
                    <li><a href="#">One more separated link</a></li>
                  </ul>
                </li>
              </ul-->
            </div>
          </div>
        </nav>

      </div>
    </div>


    <!-- Carousel
    ================================================== -->
    <div id="myCarousel" class="carousel slide" data-ride="carousel">
      <!-- Indicators -->
      <ol class="carousel-indicators">
        <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
        <li data-target="#myCarousel" data-slide-to="1"></li>
        <li data-target="#myCarousel" data-slide-to="2"></li>
      </ol>
      <div class="carousel-inner" role="listbox">
        <div class="item active">
          <img class="first-slide" src="share/carousel1ima.jpg" alt="First slide">
          <div class="container">
            <div class="carousel-caption carousel-caption1">
              <h1>Canadian Internal Medicine   Academy</h1>
              <p>The Canadian Internal Medicine knowledge and self-assessment tool</p>
              <p><a class="btn btn-lg btn-primary registerLink" data-load-url="register.jsp" href="#" role="button">Sign up FREE</a></p>
            </div>
          </div>
        </div>
        <div class="item">
          <img class="second-slide" src="share/carousel2ima.jpg" alt="Second slide">
          <div class="container">
            <div class="carousel-caption carousel-caption2">
              <h1>Canadian Internal Medicine Online Academy</h1>
              <p>The Canadian Internal Medicine knowledge and self-assessment tool</p>
              <p><a class="btn btn-lg btn-primary registerLink" data-load-url="register.jsp" href="#" role="button">Sign up FREE</a></p>
            </div>
          </div>
        </div>
        <div class="item">
          <img class="third-slide" src="share/carousel3ima.jpg" alt="Third slide">
          <div class="container">
            <div class="carousel-caption carousel-caption3">
              <h1>Canadian Internal Medicine Online Academy</h1>
              <p>The Canadian Internal Medicine knowledge and self-assessment tool</p>
              <p><a class="btn btn-lg btn-primary registerLink" data-load-url="register.jsp" href="#" role="button">Sign up FREE</a></p>
            </div>
          </div>
        </div>
      </div>
      <a class="left carousel-control" href="#myCarousel" role="button" data-slide="prev">
        <span class="glyphicon glyphicon-chevron-left" aria-hidden="true"></span>
        <span class="sr-only">Previous</span>
      </a>
      <a class="right carousel-control" href="#myCarousel" role="button" data-slide="next">
        <span class="glyphicon glyphicon-chevron-right" aria-hidden="true"></span>
        <span class="sr-only">Next</span>
      </a>
    </div><!-- /.carousel -->


    <!-- Marketing messaging and featurettes
    ================================================== -->
    <!-- Wrap the rest of the page in another container to center all the content. -->

    <div class="container marketing">

      <!-- Three columns of text below the carousel -->
      <div class="row">
      
      	<div class="loginDiv">
			<form class="form-signin" action="<c:url value="/user.do"/>" method="POST">
			<input type="hidden" name="method" value="login">
			<input type="hidden" name="requestPath" value="${sessionScope.requestPath}">
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
	        
	        <label for="inputEmail" class="sr-only">Username or Email address</label>
	        <input type="text" id="inputEmail" class="form-control" name="username" placeholder="Username or Email" required autofocus>
	        <label for="inputPassword" class="sr-only">Password</label>
	        <input type="password" id="inputPassword" class="form-control" name="password" placeholder="Password" required>
	        <div class="checkbox">
	          <label>
	            <input type="checkbox" value="remember-me"> Remember me
	          </label>
	        </div>
	        <div class="row" style="padding-left: 40px; padding-right: 40px;">
	        	<div class="col-sm-6 signInButtonContainer">
	        	<button class="btn btn-lg btn-primary lighter signInButton" type="submit">Sign in</button>
	        	</div>
	        	<div class="col-sm-6 signInButtonContainer">
	        	<button class="btn btn-lg btn-warning signInButton" type="button" data-load-url="register.jsp" id="registerButton">Register</button>
	        	</div>
	        </div>
	      </form>
		</div>
      
      
      
        <div class="col-sm-4 text-center">
          <img class="img-circle" src="share/circle1.jpg" alt="Generic placeholder image" width="140" height="140">
          <h2>Detailed Explanations</h2>
          <p>Practice questions are explained with references to clinical practice guidelines that are appropriate to Canadian physicians</p>
          <%--<p><a class="btn btn-default btn-info" href="#" role="button">View details &raquo;</a></p>--%>
        </div><!-- /.col-lg-4 -->
        <div class="col-sm-4 text-center">
          <img class="img-circle" src="share/circle2.jpg" alt="Generic placeholder image" width="140" height="140">
          <h2>Diverse Question Bank</h2>
          <p>Question bank is created to cover the Canadian Royal College Objectives of Training and allows practice for the IM licensing exam</p>
          <%--<p><a class="btn btn-default btn-info" href="#" role="button">View details &raquo;</a></p>--%>
        </div><!-- /.col-lg-4 -->
        <div class="col-sm-4 text-center">
          <img class="img-circle" src="share/circle3.jpg" alt="Generic placeholder image" width="140" height="140">
          <h2>Self-assess Performance</h2>
          <p>Learners receive detailed reports on their performance, which clearly outlines areas of weakness</p>
          <%--<p><a class="btn btn-default btn-info" href="#" role="button">View details &raquo;</a></p>--%>
          
        </div><!-- /.col-lg-4 -->
      </div><!-- /.row -->


      <!-- START THE FEATURETTES -->
      <!-- 
      <hr class="featurette-divider">

      <div class="row featurette">
        <div class="col-md-7">
          <h2 class="featurette-heading">First featurette heading. <span class="text-muted">It'll blow your mind.</span></h2>
          <p class="lead">Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo.</p>
        </div>
        <div class="col-md-5">
          <img class="featurette-image img-responsive center-block" data-src="holder.js/500x500/auto" alt="Generic placeholder image">
        </div>
      </div>

      <hr class="featurette-divider">

      <div class="row featurette">
        <div class="col-md-7 col-md-push-5">
          <h2 class="featurette-heading">Oh yeah, it's that good. <span class="text-muted">See for yourself.</span></h2>
          <p class="lead">Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo.</p>
        </div>
        <div class="col-md-5 col-md-pull-7">
          <img class="featurette-image img-responsive center-block" data-src="holder.js/500x500/auto" alt="Generic placeholder image">
        </div>
      </div>

      <hr class="featurette-divider">

      <div class="row featurette">
        <div class="col-md-7">
          <h2 class="featurette-heading">And lastly, this one. <span class="text-muted">Checkmate.</span></h2>
          <p class="lead">Donec ullamcorper nulla non metus auctor fringilla. Vestibulum id ligula porta felis euismod semper. Praesent commodo cursus magna, vel scelerisque nisl consectetur. Fusce dapibus, tellus ac cursus commodo.</p>
        </div>
        <div class="col-md-5">
          <img class="featurette-image img-responsive center-block" data-src="holder.js/500x500/auto" alt="Generic placeholder image">
        </div>
      </div>
	-->
      <hr class="featurette-divider">

      <!-- /END THE FEATURETTES -->


      <!-- FOOTER -->
      <footer>
        <p class="pull-right"><a href="#">Back to top</a></p>
        <p>&copy; 2018 IM Academy Inc.
        &middot; <a href="#">Privacy</a> &middot; <a href="#">Terms</a></p>
      </footer>
      
      
      
		<div class="modal fade" tabindex="-1" role="dialog" id="iframeModal" aria-labelledby="registermodal">
		  <div class="modal-dialog modal-lg customModal" role="document">
		    <div class="modal-content">
		      <div class="modal-header">
		        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
		        <h4 class="modal-title" id="myModalLabel">Registration</h4>
		      </div>
		      <div class="modal-body maxHeight loaderBg">
		      	<iframe class="modal-iframe" id="register-iframe"></iframe>
		      </div>
		      <div class="modal-footer">
		      	<button type="button" class="btn btn-primary" id="submitRegisterButton">Register</button>
		        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
		      </div>
		    </div>
		  </div>
		</div>
      
      
      
      

    </div><!-- /.container -->

	<%
	Calendar calendar = Calendar.getInstance();
	SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss dd/MM/yyyy");
	String sDate = dateFormat.format(calendar.getTime());
	System.out.println("System access log: " + sDate + " on " + request.getRemoteAddr());
	request.getSession().removeAttribute("requestPath");
	%>

    <!-- Bootstrap core JavaScript
    ================================================== -->
    <!-- Placed at the end of the document so the pages load faster -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
    <script>window.jQuery || document.write('<script src="../../assets/js/vendor/jquery.min.js"><\/script>')</script>
    <script src="jslib/bootstrap/bootstrap.min.js"></script>

    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <script src="jslib/bootstrap/ie10-viewport-bug-workaround.js"></script>
    
    <script type="text/javascript" language="JavaScript">
    $(function() {
    	$("#submitRegisterButton").click(function(e) {
    		$("#register-iframe")[0].contentWindow.$("#registerButtonT").click();
    	})
    	
    	
	   	$(".registerLink").click( function() {
	   	 	$('#iframeModal').modal('show');
	   	 	//rescale();
	   	 	$('#iframeModal').find('.modal-iframe').attr('src', $(this).data("load-url"));
	   	})
	   	
		 
		$('#iframeModal').on('hidden.bs.modal',function(){  
		   	  	$(this).find('iframe').attr('src','');
		})
		

		function rescale(){
	   		//ensure modal takes up a certain height based on window height
		    $('.modal-body.maxHeight').css('height', $(window).height() - 200);
		}
		//$(window).bind("resize", rescale);
		
    })
    </script>
    
    <script>
    //Google Analytics
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-101330153-1', 'auto');
  ga('send', 'pageview');

</script>
    

  </body>
</html>
