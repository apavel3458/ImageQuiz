<!DOCTYPE html>

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
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
    
    <link href="<c:url value="/css/admin/searchterm.css"/>" rel="stylesheet">
	<link href="<c:url value="/css/case/dashboard.css"/>" rel="stylesheet">
	<link href="<c:url value="/css/case/explore.css"/>" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="background">
  
	<jsp:include page="header2.jsp">
		<jsp:param name="explore" value="active"/>
	</jsp:include>


<!-- 
      <div class="row row-offcanvas row-offcanvas-right">

        <div class="col-xs-12 col-sm-9">
          <p class="pull-right visible-xs">
            <button type="button" class="btn btn-primary btn-xs" data-toggle="offcanvas">Toggle nav</button>
          </p>
          <div class="jumbotron">
            <h1>Explore ECGs!</h1>
            <p>This tool allows you to see certain ECG, or combination of diagnoses.  Have fun!</p>
          </div>
        </div>
     </div>-->
     
<div class="container">
  <nav class="navbar navbar-default">
  <div class="container-fluid">
    

    <div class="navbar-header">
    	      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar2" aria-expanded="false" aria-controls="navbar">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
              </button>
      <div class="navbar-brand">Group Select:</div>


		<div class="btn-group">
	      <a href="#" style="margin-top: 14px; margin-left: 20px;" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
	        		<c:if test="${not empty requestScope.selectedGroup}">
          				<c:out value="${requestScope.selectedGroup.groupName }"/>
          			</c:if>
          			<c:if test="${empty requestScope.selectedGroup}">
          				Select Group
          			</c:if>
	       			<span class="caret"></span>
	      </a>
	      <ul class="dropdown-menu">
	        	<c:forEach var="searchGroup" items="${requestScope.searchGroups}">
	            	<li><a href="case.do?method=showGroup&viewgroupid=<c:out value="${searchGroup.groupId}"/>"><c:out value="${searchGroup.groupName }"/></a></li>
	          	</c:forEach>
	       </ul>
	    </div>




          
    </div>

	

	<div id="navbar2" class="navbar-collapse collapse">
          <ul class="nav navbar-nav">
               
                <li>
                	<div class="navbar-brand" style="margin-left: 10px; margin-right: 10px;">OR</div>
                </li>
                <li>
                	
           			<input type="text" style="width: 200px;" name="groupName" class="form-control navbar-brand" placeholder="Type Diagnoses">
        		</li>
        		<li>
        			<button type="submit" class="btn btn-default" style="margin-top: 12px; margin-left: 20px;">Search</button>
                </li>
              </ul>
            </div>

  </div>
</nav>
  
  <!-- END NAVBAR CONTENT -->
  
  
  <c:if test="${not empty requestScope.message}">
  	<div class="alert alert-warning alert-dismissable alertShorter" role="alert">
  		<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
					<c:out value="${requestScope.message }"/>
	</div>
  </c:if>
  
  
  
  
  <!--  BEGIN GROUP MANAGEMENT -->
  
  	<c:if test="${not empty requestScope.selectedGroup }">
	  	<div class="row masonry-container">
		    <c:forEach var="section" items="${requestScope.selectedGroup.associatedSections}">
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
				    					class="btn btn-primary btn-xs searchTermItem"
				    					onclick="selectItem(this, '<c:out value="${searchterm.searchTermString }"/>')">
				    					
				    					<c:out value="${searchterm.searchTermString }"/>
			    					</button>
		 						(${fn:length(searchterm.associatedWrappers)})
		 							<br/>
			    			</c:forEach>

			  			</div>
					</div>
				</div>
		    </c:forEach>

	    </div>
	    
	    <div class="navbar navbar-default text-center row">
	    		<form action="case.do" id="exploreForm">
	    			<div class="navbar-label" style="line-height: 80px; margin-right: 20px;">Select:</div>
	    			<input type="hidden" name="method" value="exploreFindEcgs">
	    			<input type="hidden" name="selectedItems" id="selectedItems">
	    			
	    			<div style="display: inline-block; text-align: left; vertical-align: middle;">
		    			New Window? <input type="checkbox" id="newwindow" id="newwindow" name="newwindow" value="yes" style="margin-left: 5px;"><br/>
		    			Containing: <select name="operator" class="form-control" style="display: inline-block; text-align: center; margin-left: 10px; width: 140px;">
		    				<option value="OR">ANY selected dx</option>
		    				<option value="AND">ALL selected dx</option>
		    			</select>
	    			</div>
	    			<a class="btn btn-info" onclick="findECGs(this)" style="margin-left: 20px;">Find ECGs!</a>

	    		</form>
	    </div>





	    
    </c:if>





          
          

	<jsp:include page="footer2.jsp" />


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
    var selectedItems = [];
    function selectItem(ele, itemName) {
		  $(ele).toggleClass("selected");
		  var i = selectedItems.indexOf(itemName);
		  if (i == -1) {
		  	selectedItems.push(itemName);
		  } else {
			selectedItems.splice(i, 1);
		  }
		  $("#selectedItems").val(selectedItems.join("|"));
	}
    
    function findECGs(ele) {
    	var selectedItems = $("#selectedItems").val();
    	if (selectedItems == "") {
    		alert("You must select some items");
    	} else {
    		var form = $("#exploreForm");
    		if ($("#newwindow").is(':checked')) {
    			$(form).on('submit', function(){
    				//$(this).attr('target', '_self');
    				window.open('about:blank','Explore2','toolbar=no,scrollbars=yes,resizable=yes,width=800,height=800');
    			    this.target = 'Explore2';
    			});
    			
    		} else {
    			$(form).off('submit');
    			
    		}
    		$(form).submit();
    	}
    }
    
   
    
    $(document).ready(function () {
    	$('[data-toggle="offcanvas"]').click(function () {
    	    $('.row-offcanvas').toggleClass('active');
    	  });
    	  
    	
    	  
    	$('[data-toggle="tooltip"]').tooltip(); 
    	//$('[data-toggle=popover]').popover();
    	
    	$("#selectedItems").val("");
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