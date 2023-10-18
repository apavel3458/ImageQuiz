<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="dashboardHeader.jsp"/>
  <body class="background">
  
	<jsp:include page="header2.jsp">
		<jsp:param name="dashboardSubspecialty" value="active"/>
	</jsp:include>
	
    <div class="container">

      <div class="row row-offcanvas row-offcanvas-right">

        <div class="col-xs-12 col-sm-9">
          <p class="pull-right visible-xs">
            <button type="button" class="btn btn-primary btn-xs" data-toggle="offcanvas">Toggle nav</button>
          </p>
          <c:if test="${not empty errorMessage}">
          <div class="alert alert-dismissible alert-warning text-center">
  				<button type="button" class="close" data-dismiss="alert">&times;</button>
  				<p><strong>${errorMessage}</strong></p>
  				<c:remove var="errorMessage"/>
		  </div>
		  </c:if>
          <div class="jumbotron jumbotronInstructions">
            <h1>Cardiology Dashboard!</h1>
            <p>Below are the Cardiology learning units designed in accordance with the Royal College Objectives of Training (Cardiology Section).  For each rotation in Cardiology you must complete 3 units of your choice.
               </p>
             <p>Please review the learning objectives and study the learning materials for each unit.  To demonstrate your understanding and competence, you must complete a 20-question online assessment quiz, which consists of 20 multiple choice questions (formatted similar to the Royal College exam). </p> 
             <p>Once you complete the assessment, please e-mail the certificate of completion to Charlene Grass.  If you are not successful, you may review learning materials and and re-attempt 24 hours later. </p>
          </div>
        </div>
        <div class="col-xs-6 col-sm-3 sidebar-offcanvas" id="sidebar">
          <jsp:include page="dashboardAchievements.jsp">
          		<jsp:param name="dashboardCardiology" value="active"/>
		  </jsp:include>
        </div><!--/.sidebar-offcanvas-->
     </div>
          
          
          
          <c:set var="examName" value="Level1CAD"/>
          <c:set var="quizDash" value="${requestScope.quizzes.get(examName)}"/>
          <div class="row levelRow">
          	
            
            
            
            
            <div class="col-md-4 text-center">
            	<div class="panel panel-success levelBox">
  					<div class="panel-heading levelB1">
    					<h3 class="panel-title">Level 3: Hemodynamics</h3>
  					</div>
  					<div class="panel-body">
						<p>Shunts <br/> Right Heart Catheterization <br/> Echo Calculations </p>
						
  						<a class="btn btn-sm  btn-default levelButton" role="button">Learning Plan</a>
  						<a class="btn btn-sm  btn-primary levelButton" href="case.do?method=prepareAssessment&examName=Level3Hemodynamics" role="button">Begin Assessment&raquo;</a>
					</div>
				</div>
            </div>
            
            <div class="col-md-4 text-center">
	            <div class="panel panel-success levelBox">
	  					<div class="panel-heading levelD1">
	    					<h3 class="panel-title">Level 3: Graphics</h3>
	  					</div>
	  					<div class="panel-body">
							<p>Pathognomonic Echos<br/>Cardiac Catheterization<br/>Loops/Holters</p>
	  						<a class="btn btn-sm  btn-default levelButton" role="button">Learning Plan</a>
	  						<a class="btn btn-sm  btn-primary levelButton" href="case.do?method=prepareAssessment&examName=Level3Graphics" role="button">Begin Assessment&raquo;</a>
						</div>
				</div>
			</div>
          </div>
          
          
          
          
          
          
          
	        
	        <div class="modal fade" tabindex="-1" id="UnitAdialog">
			  <div class="modal-dialog" role="document">
			    <div class="modal-content">
			      <div class="modal-header">
			        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
			        <h4 class="modal-title">Learning Outcomes - Coronary Artery Disease</h4>
			      </div>
			      <div class="modal-body LOBody">

			      	<div class=LOHeading>
			      		Non-ST Elevation MI / Unstable Angina
			      	</div>
			        <ul class="LOBullets">
			        	<li>Diagnose ACS and risk stratify clinical presentations of ACS</li>
			        	<li>Initiate guideline-directed medical management of ACS</li>
			        	<li>Understand indications and evidence for various reperfusion strategies</li>
			        	<a class="btn btn-xs btn-info text-center">Open Content!</a>
			        </ul>
			        <div class=LOHeading>
			      		Stable CAD
			      	</div>
			        <ul class="LOBullets">
			        	<li>Diagnose stable CAD</li>
			        	<li>Risk stratify stable CAD</li>
			        	<li>Initiate guideline-directed medical management for stable CAD</li>
			        	<li>Apply indications for non-invasive risk stratification of stable CAD</li>
			        	<li>Understand indications and evidence for revascularization of stable CAD</li>
			        </ul>
			        <div class=LOHeading>
			      		CAD Driving Guidelines
			      	</div>
			        <ul class="LOBullets">
			        	<li>List non-invasive risk stratification modalities and their sensitivity/specificity</li>
			        	<li>Counsel patients on each non-invasive risk stratification modality</li>
			        	<li>Apply the results of non-invasive risk stratification tests</li>
			        </ul>
			        
			      </div>
			      <div class="modal-footer">
			        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
<!-- 			        <button type="button" class="btn btn-primary">Save changes</button> -->
			      </div>
			    </div><!-- /.modal-content -->
			  </div><!-- /.modal-dialog -->
			</div><!-- /.modal -->
	       
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
    <script src="<c:url value="/jslib/imagequiz/dashboard.js"/>"></script>

    <script type="text/javascript">
    $(document).ready(function () {
    	  $('[data-toggle="offcanvas"]').click(function () {
    	    $('.row-offcanvas').toggleClass('active')
    	  });
    	  
    	  
    	$('[data-toggle="tooltip"]').tooltip(); 
    	//$('[data-toggle=popover]').popover();
    	<c:forEach var="item" items="${requestScope.quizzes.entrySet()}">
    		<c:if test="${not empty item.value.delayMilis}">
    		startTimer($("#${item.key}Button"), $("#${item.key}Timer"), ${item.value.delayMilis});
    		</c:if>
    	</c:forEach>
   	});
	

	</script>
  </body>
</html>