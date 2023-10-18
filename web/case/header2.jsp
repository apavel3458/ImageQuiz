<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
    <nav class="navbar navbar-static-top navbar-inverse">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="<c:url value="${param.exitUrl}"/>">CardioBootcamp</a>
        </div>
        <div id="navbar" class="collapse navbar-collapse">
          <c:if test="${not sessionScope.security.examOnly}">
	          <ul class="nav navbar-nav">
	          	<li class="${param.home}"><a href="<c:url value="/case/dashboard.do"/>">HOME</a></li>
	            <li class="${param.dashboard}"><a href="dashboard.do?method=dashboardEcg">ECGs</a></li>
	            <li class="${param.dashboardCardiology}"><a href="dashboard.do?method=dashboardCardiology">IM</a></li>
	            <li class="${param.dashboardSubspecialty}"><a href="dashboard.do?method=dashboardSubspecialty">Subspec</a></li>
	            <li class="${param.explore}"><a href="case.do?method=explore">Explore ECGs</a></li>
	            <!-- li><a href="#contact">Contact</a></li-->
	          </ul>
		  </c:if>
          <ul class="nav navbar-nav navbar-right">
          	<li>
          		<a class="navtext">
          		<c:out value="${sessionScope.security.firstName}"/> <c:out value="${sessionScope.security.lastName}"/> 
            	<c:if test="${!requestScope.examservlet}">
            		(<c:out value="${sessionScope.security.username}"/>)
           		</c:if>
           		</a>
           	</li>
            <li>
            	<a href="#" data-toggle="tooltip" data-placement="bottom" title="" data-original-title="Sorry, under construction">Settings</a>
			</li>
            <li><a href="../user.do?method=logout">Logout</a></li>
          </ul>
        </div><!-- /.nav-collapse -->
      </div><!-- /.container -->
    </nav><!-- /.navbar -->
    