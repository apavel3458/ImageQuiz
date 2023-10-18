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
          <a class="navbar-brand" href="#">ECG Bootcamp</a>
        </div>
        <div id="navbar" class="collapse navbar-collapse">
          <ul class="nav navbar-nav">
          	<c:if test="${not sessionScope.security.examOnly}">
          	
            <li class="${param.dashboard}"><a href="">Dashboard</a></li>
            <li class="${param.explore}"><a href="case.do?method=explore">Explore ECGs</a></li>
            
            </c:if>
            <!-- li><a href="#contact">Contact</a></li-->
          </ul>
          <ul class="nav navbar-nav navbar-right">
          	<c:if test="${sessionScope.security.sessionMode != 'research'}">
          	<li>
          		<a class="navtext userText" data-toggle="tooltip" data-placement="bottom" title="" data-original-title="${sessionScope.security.firstName} ${sessionScope.security.lastName} (${sessionScope.security.username})">
          		User: <c:out value="${sessionScope.security.firstName}"/> <c:out value="${sessionScope.security.lastName}"/> 
            	<c:if test="${!requestScope.examservlet}">
            		(<c:out value="${sessionScope.security.username}"/>)
           		</c:if>
           		</a>
           	</li>
            <li>
            	<a href="#" data-toggle="tooltip" data-placement="bottom" title="" data-original-title="Sorry, under construction">Settings</a>
			</li>
			</c:if>
			<c:if test="${sessionScope.security.sessionMode == 'research'}">
				<li><a href="../research/registration.jsp">Logout</a></li>
			</c:if>
			<c:if test="${sessionScope.security.sessionMode != 'research'}">
            <li><a href="../user.do?method=logout"">Logout</a></li>
            </c:if>
          </ul>
        </div><!-- /.nav-collapse -->
      </div><!-- /.container -->
    </nav><!-- /.navbar -->
    