<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="dashboardHeader.jsp"/>
  <body class="background">
  
	<jsp:include page="header2.jsp">
		<jsp:param name="dashboardCardiology" value="active"/>
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
  				<c:remove var="errorMessage" scope="session"/>
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
          
          
          
          
          <c:set var="quizDash" value="${requestScope.quizzes.get('UnitA-CAD')}"/>
          <div class="row levelRow">
          	<c:set var="quizName" value="UnitA-CAD"/>
            <div class="col-md-4 text-center">
            	<div class="panel panel-success levelBox">
  					<div class="panel-heading">
    					<h3 class="panel-title">Unit A: Coronary Artery Disease</h3>
  					</div>
  					<c:if test="${quizDash.quiz.pass}">
  					<div class="successOverlay">
  						<i class="material-icons successIcon">check</i><br/>
  						<span class="badge achievement"><i class="material-icons achievementIcon">local_hospital</i>CAD Level 1</span>
  					</div>
  					</c:if>
  					<div class="panel-body">
    					ACS diagnosis, management, complications, risk stratification.  Diagnosis, prognostication, and management of stable CAD.
  					</div>
  					<a class="btn btn-default levelButton" role="button" data-toggle="modal" data-target="#UnitAdialog">Objectives & Study Materials</a>
  					<c:if test="${not empty quizDash}">
  						
						<c:choose>
						  <c:when test="${quizDash.quiz.pass }">
						    <a class="btn btn-primary levelButton" href="" role="button">Competency Acquired</a>
						  </c:when>
						  <c:when test="${quizDash.quiz.completed }">
						    <div>
						    	<c:if test="${not empty quizDash.delayMilis}">
						    		<a class="btn btn-primary levelButton disabled" id="UnitA-CADButton" href="case.do?method=prepareAssessment&examName=${quizDash.quiz.quizName}" role="button">Retry in <span class="timerFunction" id="UnitA-CADTimer">...</span></a>
						    	</c:if>
						    	<c:if test="${empty quizDash.delayMilis}">
						    		<a class="btn btn-primary levelButton" id="UnitA-CADButton" href="case.do?method=prepareAssessment&examName=${quizDash.quiz.quizName}" role="button">Retry Assessment NOW!</a>
						    	</c:if>
						    </div>
						    <div>
						    	<span class="label label-warning">INCOMPLETE</span><br/>
						    </div>
						  </c:when>
						  <c:otherwise>
						    <a class="btn btn-success levelButton" href="case.do?method=prepareAssessment&examName=${quizDash.quiz.quizName}" role="button">Success!</a>
						  </c:otherwise>
						</c:choose>
						
					</c:if>
  					<c:if test="${empty requestScope.quizzes.get('UnitA-CAD')}">
  						<a class="btn btn-primary levelButton" href="case.do?method=prepareAssessment&examName=UnitA-CAD" role="button">Begin Assessment &raquo;</a>
					</c:if>
				</div>
				
            </div>
            <c:remove var="quizName"/>
            
            <div class="col-md-4 text-center">
            	<div class="panel panel-success levelBox">
  					<div class="panel-heading">
    					<h3 class="panel-title">Unit B: Heart Failure & Cardiomyopathy</h3>
  					</div>
  					<div class="panel-body">
    					Develop an approach to guideline-based acute and chronic management of heart failure.  Recognize and manage patients with cardiogenic shock.  Distinguish hemodynamic effects of various inotropes/vasopressors.
  					</div>
  					<a class="btn btn-default levelButton" role="button">Objectives & Study Materials</a>
  					
  					<a class="btn btn-primary levelButton" href="case.do?method=prepareAssessment&examName=UnitB-HF" role="button">Begin Assessment &raquo;</a>

				</div>
            </div>
            
            <div class="col-md-4 text-center">
            	<div class="panel panel-success levelBox">
  					<div class="panel-heading">
    					<h3 class="panel-title">Unit C: Syncope & Arrhythmia</h3>
  					</div>
  					<div class="panel-body">
    					Diagnosis, risk-stratification, and management of syncope and cardiac tachy/brady-arrhythmias.
  					</div>
  					<a class="btn btn-default levelButton" role="button">Objectives & Study Materials</a>
  					<a class="btn btn-primary levelButton" href="case.do?method=prepareAssessment&examName=UnitC-Rhythm" role="button">Begin Assessment&raquo;</a>

				</div>
            </div>
          </div>
          
          
          <div class="row text-center">	
         		<div class="col-md-4">
	            	<div class="panel panel-success panel-level3 levelBox">
	  					<div class="panel-heading">
	    					<h3 class="panel-title">Unit D: Valvular Heart Disease</h3>
	  					</div>
	  					<div class="panel-body">
	    					<p>Understand acute and chronic management of valvular heart disease and endocarditis as well as indications for surgery. </p>
	  					</div>
	  					<button class="btn btn-default levelButton" disabled="true" href="#" role="button">Under Construction &raquo;</button>
					</div>
	            </div>
							            
	            <div class="col-md-4">
	            	<div class="panel panel-success panel-level3 levelBox">
	  					<div class="panel-heading">
	    					<h3 class="panel-title">Unit E: Pericardial Dz & Fitness to Drive</h3>
	  					</div>
	  					<div class="panel-body">
	    					<p>Management of acute & recurrent pericarditis.  Distinguish constrictive pericarditis, restrictive cardiomyopathy, and pericardial effusion/tamponade.  Apply fitness to drive guidelines to practice.</p>
	              			
	  					</div>
	  					<button class="btn btn-default levelButton" disabled="true" href="#" role="button">Under Construction &raquo;</button>
					</div>
	            </div>
	            		            
	            <div class="col-md-4">
	            	<div class="panel panel-success panel-level3 levelBox">
	  					<div class="panel-heading">
	    					<h3 class="panel-title">Unit F: Vascular Disease</h3>
	  					</div>
	  					<div class="panel-body">
	    					<p>Learn classification, diagnostic criteria and initial management of pulmonary hypertension.  Management of aortic emergencies and apply indications for prophylactic interventions. </p>
	              			
	  					</div>
	  					<button class="btn btn-default levelButton" disabled="true" href="#" role="button">Under Construction &raquo;</button>
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
			      		Acute Coronary Syndromes (ACS)
			      	</div>
			        <ul class="LOBullets">
			        	<li>Diagnose ACS and risk stratify clinical presentations</li>
			        	<li>Develop an approach to ACS</li>
			        	<li>Initiate guideline-directed medical management of ACS</li>
			        	<li>Identify and manage complications of ACS</li>
			        	<li>Understand indications and evidence for various reperfusion strategies</li>
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
			      		Non-Invasive Risk Stratification
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