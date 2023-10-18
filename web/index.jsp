<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@page import="java.util.*, org.imagequiz.properties.ImageQuizProperties"%>

<%
ImageQuizProperties properties = ImageQuizProperties.getInstance();
pageContext.setAttribute("index", "index" + properties.getSitePostfix() + ".jsp");
%>

<jsp:forward page="${index}" />