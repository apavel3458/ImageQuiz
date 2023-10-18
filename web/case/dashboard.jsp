<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="dashboardHeader.jsp"/>
  <body class="background">
  
	<jsp:include page="header2.jsp">
		<jsp:param name="home" value="active"/>
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
            <p>To start, select the category below...</p>
          </div>
        </div>
        <div class="col-xs-6 col-sm-3 sidebar-offcanvas" id="sidebar">
          <jsp:include page="dashboardAchievements.jsp">
          		<jsp:param name="dashboardCardiology" value="active"/>
		  </jsp:include>
        </div><!--/.sidebar-offcanvas-->
     </div>
          
          
          
          
          
          

	        
	       
	        <div class="row text-center categoryContainer">
	        
				  <div class="col-sm-4 categoryBox" onclick="document.location='dashboard.do?method=dashboardEcg'">
				    <div class="thumbnail">
				      <img src="../share/carousel1.jpg" alt="...">
				      <div class="caption categoryBoxCaption">
				        <h3>ECG Interpretation</h3>
				        <p>...</p>
				      </div>
				    </div>
				  </div>
				  
				  <div class="col-sm-4 categoryBox" onclick="document.location='dashboard.do?method=dashboardCardiology'">
				    <div class="thumbnail">
				      <img src="../share/carousel1ima.jpg" alt="...">
				      <div class="caption categoryBoxCaption">
				        <h3>Internal Medicine Residents</h3>
				        <p>...</p>
				      </div>
				    </div>
				  </div>
				  
				  <div class="col-sm-4 categoryBox" onclick="document.location='dashboard.do?method=dashboardSubspecialty'">
				  	<div class="thumbnail">
				      <img src="../share/carousel3ima.jpg" alt="...">
				      <div class="caption categoryBoxCaption">
				        <h3>Cardiology Fellows</h3>
				      </div>
<!-- 				      <div class="caption categoryBoxNotice">
				        Under construction ...
				      </div> -->
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