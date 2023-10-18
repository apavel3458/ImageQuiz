<%@ page language="java" contentType="text/html; charset=US-ASCII"
    pageEncoding="US-ASCII"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=US-ASCII">
	<title>Insert title here</title>
	
	
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
        
    <link rel="stylesheet" href="admin.css">
	<link rel="stylesheet" href="../jslib/codemirror/lib/codemirror.css">
	<link rel="stylesheet" href="../jslib/codemirror/addon/hint/show-hint.css">
	<script src="../jslib/jquery-xmledit/lib/jquery.min.js"></script>
    <script src="../jslib/iq.js"></script>
	<script src="../jslib/jquery-xmledit/lib/jquery.min.js"></script>
	<script src="../jslib/codemirror/lib/codemirror.js"></script>
	<script src="../jslib/codemirror/addon/hint/show-hint.js"></script>
	<script src="../jslib/codemirror/addon/hint/xml-hint.js"></script>
	<script src="../jslib/codemirror/mode/xml/xml.js"></script>
	<style type="text/css">
      .CodeMirror { border: 1px solid #eee; }
    </style>
</head>
<body>

Title: <input type="text" name="exerciseName" value="<c:out value="${requestScope.caseList.exerciseName}"/>">

Questions:
<table class="admintable" width="300px">
	<tr style="background-color: #F8E0F1;">
		<td></td>
		<td>
			<form action="admin.do">
				<input type="text" name="caseName">
				<input type="hidden" name="method" value="addCase">
				<input type="submit" value="Add">
			</form>
		</td>
	</tr>
	<tr>
		<th>ID</th>
		<th>Case Name</th>
	</tr>
	<c:forEach var="caseElement" varStatus="loopStatus" items="${requestScope.caseList.cases}">
		<tr>
			<td class="minimize" style="text-align: center;"><c:out value="${caseElement.caseId }"/></td>
			<td class="maximize"><c:out value="${caseElement.caseName }"/></td>
		</tr>
	</c:forEach>

</table>

<!-- 
<textarea id="xmlcode" name="xmlcode" style="width: 700px; height: 300px;">
</textarea>
-->

<!-- set up autocomplete and initiate the xml editor -->
   <script>
      var dummy = {
        attrs: {
          color: ["red", "green", "blue", "purple", "white", "black", "yellow"],
          size: ["large", "medium", "small"],
          description: null
        },
        children: []
      };

      var tags = {
        "!top": ["top"],
        top: {
          attrs: {
            lang: ["en", "de", "fr", "nl"],
            freeform: null
          },
          children: ["animal", "plant"]
        },
        animal: {
          attrs: {
            name: null,
            isduck: ["yes", "no"]
          },
          children: ["wings", "feet", "body", "head", "tail"]
        },
        plant: {
          attrs: {name: null},
          children: ["leaves", "stem", "flowers"]
        },
        wings: dummy, feet: dummy, body: dummy, head: dummy, tail: dummy,
        leaves: dummy, stem: dummy, flowers: dummy
      };

      function completeAfter(cm, pred) {
        var cur = cm.getCursor();
        if (!pred || pred()) setTimeout(function() {
          if (!cm.state.completionActive)
            CodeMirror.showHint(cm, CodeMirror.hint.xml, {schemaInfo: tags, completeSingle: false});
        }, 100);
        return CodeMirror.Pass;
      }

      function completeIfAfterLt(cm) {
        return completeAfter(cm, function() {
          var cur = cm.getCursor();
          return cm.getRange(CodeMirror.Pos(cur.line, cur.ch - 1), cur) == "<";
        });
      }

      function completeIfInTag(cm) {
        return completeAfter(cm, function() {
          var tok = cm.getTokenAt(cm.getCursor());
          if (tok.type == "string" && (!/['"]/.test(tok.string.charAt(tok.string.length - 1)) || tok.string.length == 1)) return false;
          var inner = CodeMirror.innerMode(cm.getMode(), tok.state).state;
          return inner.tagName;
        });
      }

      var editor = CodeMirror.fromTextArea(document.getElementById("xmlcode"), {
        mode: "xml",
        lineNumbers: true//,
       /* extraKeys: {
          "'<'": completeAfter,
          "'/'": completeIfAfterLt,
          "' '": completeIfInTag,
          "'='": completeIfInTag,
          "Ctrl-Space": function(cm) {
            CodeMirror.showHint(cm, CodeMirror.hint.xml, {schemaInfo: tags});
          }
        }*/
      });
    </script>

</body>
</html>