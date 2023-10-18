<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        <div class="loginBox">
            <img src="../share/ECGbootcampLogo2.png" class="loginBoxLogo"></img>
            <div class="loginBoxRight">
            Logged-in as: 
            <b><c:out value="${sessionScope.security.firstName}"/> <c:out value="${sessionScope.security.lastName}"/> (<c:out value="${sessionScope.security.username}"/>)</b> 
            &nbsp;&nbsp;&nbsp;&nbsp;
            | <a href="case.do?method=dashboard">Dashboard</a> 
            | <a href="../user.do?method=logout">Logout</a> |
            </div>
        </div>