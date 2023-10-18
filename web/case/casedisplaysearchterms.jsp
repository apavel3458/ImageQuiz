<!DOCTYPE html>

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>SearchTerms</title>

    <!-- Bootstrap -->
    <link href="<c:url value="/css/lib/bootstrap.paper.min.css"/>" rel="stylesheet">

    <link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.min.css">
    <link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.theme.min.css">
    
    <link href="<c:url value="/css/case/searchterm.css"/>" rel="stylesheet">
	<link href="<c:url value="/css/case/dashboard.css"/>" rel="stylesheet">
	<link href="<c:url value="/css/case/explore.css"/>" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body style="padding-top: 0px;">

<div class="container-fluid">

  <!-- END NAVBAR CONTENT -->
  
  
  <c:if test="${not empty requestScope.message}">
  	<div class="alert alert-warning alert-dismissable alertShorter" role="alert">
  		<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
					<c:out value="${requestScope.message }"/>
	</div>
  </c:if>
  
  
  
  
  <!--  BEGIN GROUP MANAGEMENT -->
  
	  	<div class="row masonry-container">
	  		<c:forEach var="group" items="${requestScope.groups }">
		    <c:forEach var="section" items="${group.associatedSections}">
		    	<div class="item sectionItem">
			    	<div class="panel panel-success">
			  			<div class="panel-heading">
			    			<h3 class="panel-title">
			    				<c:out value="${section.sectionName }"/>
			    				<div class="pull-right">
								</div>
			    			</h3>
			  			</div>
			  			<div class="panel-body" style="white-space: nowrap;">
			    			<c:forEach var="searchterm" items="${section.associatedSearchTerms }">
				    				<button 
				    					class="btn btn-primary btn-xs searchTermItem searchTermItemBlue"
				    					onclick="">
				    					<c:out value="${searchterm.searchTermString }"/>
			    					</button>
		 						(${fn:length(searchterm.associatedWrappers)})
		 							<br/>
			    			</c:forEach>

			  			</div>
					</div>
				</div>
		    </c:forEach>
		    </c:forEach>

	    </div>




    </div><!--/.container-->
  
    

    
    
    <!-- 
   -->
	
	
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="../jslib/jquery-1.12.4.js"></script>
	<script src="../jslib/jquery-ui-1.12.1/jquery-ui.min.js"></script>
	<script type="text/javascript" src="../jslib/aux/imagesLoaded.js"></script>
	<script type="text/javascript" src="../jslib/aux/masonry.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="<c:url value="/jslib/bootstrap.min.js"/>"></script>
    
    <!-- script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.6.4/angular.min.js"></script-->

    <script type="text/javascript">
    
    $(document).ready(function () {
    	$('[data-toggle="offcanvas"]').click(function () {
    	    $('.row-offcanvas').toggleClass('active');
    	  });
    	  
    	  
    	$('[data-toggle="tooltip"]').tooltip(); 
    	
   });
    
    (function( $ ) {

    	  var $container = $('.masonry-container');
    	  $container.imagesLoaded( function () {
    	    $container.masonry({
    	      columnWidth: '.item',
    	      itemSelector: '.item'
    	    });
    	  });

    })(jQuery);


	</script>
  </body>
</html>