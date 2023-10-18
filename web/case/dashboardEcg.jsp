<!DOCTYPE html>

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
    <%@page import="java.util.*, org.imagequiz.model.user.IQUserQuiz" %>
    <%
    java.util.HashMap<String, IQUserQuiz> practiceLevels = new java.util.HashMap();
    if (request.getAttribute("practiceLevels") != null) {
    	practiceLevels = (HashMap<String, IQUserQuiz>) request.getAttribute("practiceLevels"); 
    }
    %>
    
<html lang="en" class="background">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Dashboard</title>

    <!-- Bootstrap -->
    <link href="<c:url value="/css/lib/bootstrap.paper.min.css"/>" rel="stylesheet">

    <link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.min.css">
    <link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.theme.min.css">
    
    <link href="<c:url value="/css/admin/searchterm.css?v=1"/>" rel="stylesheet">
	<link href="<c:url value="/css/case/dashboard.css?v=1"/>" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="background">
  
	<jsp:include page="header2.jsp">
		<jsp:param name="dashboard" value="active"/>
	</jsp:include>
	
    <div class="container">

      <div class="row row-offcanvas row-offcanvas-right">

        <div class="col-xs-12 col-sm-9">
          <p class="pull-right visible-xs">
            <button type="button" class="btn btn-primary btn-xs" data-toggle="offcanvas">Toggle nav</button>
          </p>
          <c:if test="${not empty requestScope.errorMessage}">
          <div class="alert alert-dismissible alert-warning text-center">
  				<button type="button" class="close" data-dismiss="alert">&times;</button>
  				<p><strong>${requestScope.errorMessage}</strong></p>
		  </div>
		  </c:if>
          <div class="jumbotron">
            <h1>Welcome!</h1>
            <p>To start advancing your ECG interpretation skills, click "start".  This software will tailor ECG practice sets to strengthen your weaknesses, and will automatically detect when you achieved a level.</p>
          </div>
        </div>
        <div class="col-xs-6 col-sm-3 sidebar-offcanvas" id="sidebar">
          <div class="list-group">
            <a href="#" class="list-group-item active">
            	Level 0 (Beginner)
            </a>
          </div>
        </div><!--/.sidebar-offcanvas-->
     </div>
          
          
          
          
          
          <div class="row levelRow">
            <div class="col-md-12 text-center">
            	<div class="panel panel-success levelBox">
  					<div class="panel-heading">
    					<h3 class="panel-title">Level 1: Common Emergency Patterns</h3>
  					</div>
  					<div class="panel-body">
    					This ECG practice set will teach you the ECG bootcamp interface and will cover basic emergency rhythms
  					</div>
  					<%
  					IQUserQuiz quiz = practiceLevels.get("level1");
  					if (quiz == null) { %>
  					<a class="btn btn-default levelButton" href="case.do?method=practice&level=level1" role="button">Begin &raquo;</a>
					<%} else if (quiz != null && !quiz.isCompleted()) { %>
					<a class="btn btn-default levelButton" href="case.do?method=practice&level=level1" role="button">Continue &raquo;</a>
					<%} else if (quiz != null && quiz.isCompleted()) { %>
					<button class="btn btn-default levelButton" disabled="true" role="button">Completed!</button>
					<a class="btn btn-default levelButton" href="case.do?method=practice&level=level1" role="button">Restart?</a>
					<%} %>
				</div>
            </div>
          </div>
          
          
          <div class="row text-center">	
         		<div class="col-md-4">
	            	<div class="panel panel-success panel-level2 levelBox disabled">
	  					<div class="panel-heading">
	    					<h3 class="panel-title">Level 2: Common Non-Emergency</h3>
	  					</div>
	  					<div class="panel-body">
	    					<p>This practice set will teach multiple diagnoses that are essential for day-to-day practice.</p>
	  					</div>
	  					<button class="btn btn-default levelButton" disabled="true" href="#" role="button">Begin &raquo;</button>
					</div>
	            </div>
							            
	            <div class="col-md-4">
	            	<div class="panel panel-success panel-level2 levelBox disabled">
	  					<div class="panel-heading">
	    					<h3 class="panel-title">Level 2B. Basic Devices</h3>
	  					</div>
	  					<div class="panel-body">
	    					<p>This ECG practice set will teach you the ECG bootcamp interface and will cover basic emergency rhythms</p>
	              			
	  					</div>
	  					<button class="btn btn-default levelButton" disabled="true" href="#" role="button">Begin &raquo;</button>
					</div>
	            </div>
	            		            
	              			<!-- a class="btn btn-default" href="#" role="button">Begin &raquo;</a-->
	        </div>
	        
	       
	        <div class="row text-center">
         
	            <div class="col-md-4">
	            	<div class="panel panel-success panel-level3 levelBox disabled">
	  					<div class="panel-heading">
	    					<h3 class="panel-title">Level 3. Rare Emergencies</h3>
	  					</div>
	  					<div class="panel-body">
	    					<p>Advanced ECG set for refining skills</p>
	  					</div>
	  					<button class="btn btn-default levelButton" disabled="true" href="#" role="button">Begin &raquo;</button>
					</div>
	            </div>
	           	<div class="col-md-4">
	            	<div class="panel panel-success panel-level3 levelBox disabled">
	  					<div class="panel-heading disabled">
	    					<h3 class="panel-title">Level 3B. Lead Misplacement</h3>
	  					</div>
	  					<div class="panel-body">
	    					<p>This set will teach identification of lead misplacement</p>
	  					</div>
	  					<button class="btn btn-default levelButton" disabled="true" href="#" role="button">Begin &raquo;</button>
					</div>
	            </div>
			   <div class="col-md-4">
	            	<div class="panel panel-success panel-level3 levelBox disabled">
	  					<div class="panel-heading">
	    					<h3 class="panel-title">Level 3C. Stress Tests</h3>
	  					</div>
	  					<div class="panel-body">
	    					<p>ECG practice set for enhancing ECG stress test interpretation skills</p>
	  					</div>
	  					<button class="btn btn-default levelButton" disabled="true" href="#" role="button">Begin &raquo;</button>
					</div>
	            </div>
          </div>
          
          <div class="row text-center levelRow">
	            <div class="col-md-4">
	            	<div class="panel panel-success panel-level4 levelBox disabled">
	  					<div class="panel-heading">
	    					<h3 class="panel-title">Level 4. Advanced ECGs</h3>
	  					</div>
	  					<div class="panel-body">
	    					<p>An advanced practice set containing cardiology and electrophysiology fellow level recordings</p>
	  					</div>
	  					<button class="btn btn-default levelButton" disabled="true" href="#" role="button">Begin &raquo;</button>
					</div>
	            </div>
	            <div class="col-md-4">
	            	<div class="panel panel-success panel-level4 levelBox disabled">
	  					<div class="panel-heading">
	    					<h3 class="panel-title">Level 4A. Intracardiac Tracings</h3>
	  					</div>
	  					<div class="panel-body">
	    					<p>This section is meant for electrophysioloy trainees</p>
	  					</div>
	  					<button class="btn btn-default levelButton" disabled="true" href="#" role="button">Begin &raquo;</button>
					</div>
	            </div>
           </div>
	        



	<jsp:include page="footer2.jsp" />


    </div><!--/.container-->
  
    

    
    
    <!-- 
   -->
	
	
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>
	<script type="text/javascript" src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/123941/masonry.js"></script>
	<script type="text/javascript" src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/123941/imagesLoaded.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="<c:url value="/jslib/bootstrap.min.js"/>"></script>

    <script type="text/javascript">
    $(document).ready(function () {
    	  $('[data-toggle="offcanvas"]').click(function () {
    	    $('.row-offcanvas').toggleClass('active')
    	  });
    	  
    	  
    	$('[data-toggle="tooltip"]').tooltip(); 
    	//$('[data-toggle=popover]').popover();
    	  
   	});


	</script>
  </body>
</html>