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

    <title>ECG Bootcamp - Practice and Learn ECG Interpretation Online</title>

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
  <body class="background">
  <div class="container">
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
              <a class="navbar-brand" href="#">ECG Bootcamp</a>
            </div>
            <div id="navbar" class="navbar-collapse collapse">
              <ul class="nav navbar-nav">
                <li><a href="<c:url value="/"/>">Home</a></li>
                <li class="active"><a href="#about">About</a></li>
                <li><a href="<c:url value="/about.jsp"/>">Contact</a></li>
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
                </li-->
              </ul>
            </div>
          </div>
        </nav>

      </div>
    </div>

		<div class="panel panel-primary" style="margin-top: 100px;">
		  <div class="panel-heading">
		    <h3 class="panel-title">About</h3>
		  </div>
		  <div class="panel-body aboutDescription">
		  <p>
		    ECG Bootcamp is an ECG practice software created for medical professionals that provides repetitive practice to master ECG interpretation. 
		  </p>
		  <p>
		  	Medical education literature reveals strikingly poor ECG interpretation skills among medical trainees and attending physicians, which can lead to adverse patient outcomes.
		  </p>
		  <p>ECG Bootcamp has the following benefits over other online tools: (which we consider important for high-yield learning)
			</p>
			  <ul>
			  	<li>Ongoing self-assessment</li>
			  	<li>A dynamic practice bank (detects user weaknesses, and provides ECGs for close gaps in learning)</li>
			  	<li>Realistic user interaction (we use search-text answers instead of traditional multiple choice)</li>
			  	<li>A rapidly growing peer-reviewed ECG bank (all answers are peer reviewed by an EP specialist and a trainee)</li>
			  </ul>
		  
		  <p>
		    This software was created and programmed by Dr. Pavel Antiperovitch (Cardiology clinical fellow at the University of Western Ontario), who worked in partnership with Dr. Adrian Baranchuk (attending electrophysiologist at Queen's University) to create content. 
		  </p>

		  </div>
		</div>
		
		<div class="row">
			<div class="col-sm-6">
				<div class="panel panel-danger" style="margin-top: 10px;">
		  			<div class="panel-heading">
		    			<h3 class="panel-title">Biography - Dr. Pavel Antiperovitch</h3>
		  			</div>
		  			<div class="panel-body" style="text-align: center;">
		  				<img src="share/Pavel_photo.jpg" style="width:300px;">
		  				<p class="person_title">
		  					<b>Dr. Pavel Antiperovitch, MD BSc</b><br>
		  					Department of Medicine (PGY4)<br>
		  					Division of Cardiology <br>
		  					University of Western Ontario (Canada)<br>
		  					University Hospital</br>
		  					apavel @ gmail.com
		  				</p>
		  			</div>
				</div>
			</div>
			<div class="col-sm-6">
				<div class="panel panel-danger" style="margin-top: 10px;">
		  			<div class="panel-heading">
		    			<h3 class="panel-title">Biography - Dr. Adrian Baranchuk</h3>
		  			</div>
			  		<div class="panel-body" style="text-align: center;">
			  				<img src="share/Baranchuk_photo.jpeg" style="width:180px;">
			  				<p class="person_title">
			  					<b>Adrian Baranchuk, MD FACC FRCPC FCCS</b><br>
									Professor of Medicine and Physiology<br/>
									Cardiac Electrophysiology and Pacing<br/>
									Kingston General Hospital<br/>
									Queen's University (Canada)
			  				</p>
			  		</div>
				</div>
			</div>
		</div>


      <hr class="featurette-divider">

      <!-- /END THE FEATURETTES -->


      <!-- FOOTER -->
      <footer>
        <p class="pull-right"><a href="#">Back to top</a></p>
        <p>&copy; 2016 Bootcamp, Inc. - Part of the <img src="share/KECGTGrey.png" style="display:inine; object-fit: cover; height: 30px; margin-right: 20px;"> 
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
    	
    	
	   	$("#registerButton").click( function() {
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
