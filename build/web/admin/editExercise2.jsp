<%-- 
    Document   : editExercise
    Created on : Jul 18, 2013, 12:22:28 PM
    Author     : apavel
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<% 
    String message = (String) request.getAttribute("message");
    if (message == null) request.setAttribute("message", "");
%>


<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Edit Case</title>
        <link rel="stylesheet" href="../jslib/jquery-xmledit/demo/stylesheets/reset.css" type="text/css" />
        <link rel="stylesheet" href="../jslib/jquery-xmledit/demo/stylesheets/demo.css" type="text/css" />
        <link rel="stylesheet" href="../jslib/jquery-xmledit/css/jquery.xmleditor.css" type="text/css" />
        <script src="../jslib/jquery-xmledit/lib/ace/src-min/ace.js"></script>
        <script src="../jslib/jquery-xmledit/lib/jquery.min.js"></script>
        <script src="../jslib/jquery-xmledit/lib/jquery-ui.min.js"></script>

        <script src="../jslib/jquery-xmledit/lib/json2.js"></script>
        <script src="../jslib/jquery-xmledit/lib/cycle.js"></script>
        <script src="../jslib/jquery-xmledit/lib/jquery.autosize-min.js"></script>
        <script src="../jslib/jquery-xmledit/lib/vkbeautify.js"></script>
        <script src="../jslib/jquery-xmledit/xsd/xsd2json.js"></script>
        <script src="../jslib/jquery-xmledit/jquery.xmleditor.js"></script>
        <style>
        </style>
    </head>
    <body>
        <form action="admin.do" method="POST">
            <h1>Title: <input type="text" name="exercisename" id="exercisename" value="<c:out value="${requestScope.exercise.exerciseName}"/>"></h1>
            <p style="color: lightcoral;"><%=request.getAttribute("message")%></p>
            <div id="xmleditor">
                <textarea name="casexml" id="casexml" style="width: 100%; height: 400px;">
                    <c:choose>
                        <c:when test = "${fn:length(requestScope.exercise.cases) gt 0}">
<c:out value="${requestScope.exercise.casesXml}"/>
                        </c:when>
                        <c:otherwise>
                        	<c:out value="${requestScope.presetxml}"/>
                        </c:otherwise>
                    </c:choose>
                </textarea>
            </div>

            <input type="hidden" name="method" value="updateExercise">
            <input type="hidden" name="exerciseid" id="exerciseid" value="<c:out value="${requestScope.exercise.exerciseId}"/>">
            <input type="button" value="Go Back" onclick="document.location='admin.do'">
            <input type="submit" id="casesubmit" value="Save">
        </form>
            <script>
	$(function() {
		var extractor = new Xsd2Json("case.xsd", {"schemaURI":"xsd/"});
		$("#xmleditor").xmlEditor({
						schema: extractor.getSchema(),
						localXMLContentSelector : '#xmleditor > textarea',
                                                ajaxOptions: {
                                                    xmlUploadPath: 'admin.do?method=updateExercise&exerciseid=<c:out value="${requestScope.exercise.exerciseId}"/>'

                                                },
                                                
				});
                 //if Loaded hide submit button
                 if ($(".xml_editor_container").length) {
                	 $("#xmleditor").append("<")
                    $("#casesubmit").hide();
                 }
                            
	});

            </script>
            
            <iframe src="images.do?caseid=<c:out value="${requestScope.exercise.exerciseId}"/>" style="width: 100%; height: 700px;"></iframe>
    </body>
</html>
