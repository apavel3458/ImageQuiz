<%-- 
    Document   : case
    Created on : Jul 11, 2013, 6:34:31 PM
    Author     : apavel
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="org.imagequiz.model.IQTagGroup, java.util.List, org.imagequiz.model.*,org.imagequiz.model.question.IQQuestion"%>
<%
    List<IQTagGroup> tagGroups = (List<IQTagGroup>) request.getAttribute("tagGroups");
    IQCase iqcase = (IQCase) request.getAttribute("case");
    
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ImageQuiz</title>
        <link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.10.3/themes/base/jquery-ui.css">
        <link rel="stylesheet" type="text/css" href="../main.css">
        <link rel="stylesheet" type="text/css" href="case.css">
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-ui-1.10.3/ui/jquery-ui.js"></script>
        <script type="text/javascript" language="JavaScript">
            //add highlight autocomplete partial matches
            $.ui.autocomplete.prototype._renderItem = function( ul, item){
            var term = this.term.split(' ').join('|');
            var re = new RegExp("(" + term + ")", "gi") ;
            var t = item.label.replace(re,"<b>$1</b>");
            return $( "<li></li>" )
               .data( "item.autocomplete", item )
               .append( "<a>" + t + "</a>" )
               .appendTo( ul );
            };
            
            var tagGroups = {};
            <%if (tagGroups != null && iqcase != null) {
                for (IQTagGroup tagGroup: tagGroups) {%>
                tagGroups["<%=tagGroup.getListName()%>"] = [
                <%for (IQTag tag: tagGroup) {%>
                  "<%=tag.getTagName()%>",
              <%}%> ""];
        <%}}%>
            
            
            $(function() {
                //ON LOAD...
                $(".caseQuestion").each(function() {
                    $(this).addClass("gray");
                    $(this).val("<Enter Answer>");
                    $(this).focus(function() {
                        $(this).removeClass("gray");
                        $(this).removeClass("answered");
                        $(this).val("");
                    });
                    $(this).keydown( function() {
                        $(this).removeClass("answered");
                    })
                })
            
        <%if (tagGroups != null && iqcase != null) {
            for (IQQuestion question: iqcase.getQuestionList()) {
            if (question.getTagGroup() != null) { %>
                 setAutocomplete($("#q-<%=question.getQuestionId()%>"), tagGroups["<%=question.getTagGroup()%>"])
           <%}%>
        <%}
        }%>
            });
            function setAutocomplete(field, tags) {
                $(field).autocomplete({
                     source: tags,
                     minLength: 1,
                     select: function(event, ui) { updateAnswerFromAutofill(event, ui); },
                     response: function(event, ui) {
                                    if (ui.content.length === 0) {
                                        ui.content.push({ label: "No search results - try fewer letters", value: "null" });
                                    }
                               }
                 });
            }
            
            function updateAnswerFromAutofill(event, ui) {
                if (ui.item.value == "null") {
                    ui.item.value = "";
                    return false;
                }
                var inputField = event.target;
                
                //add row to table
                var liE = $(inputField).parent();
                var containerDivE = $(liE).parent();
                var newLiE = $(liE).clone();
                $(containerDivE).append($(newLiE));
                var deleteIconHtml = " <img src='../share/icons/delete.png' style='vertical-align: middle;' onclick='removeAnswer(this)'>";
                //add delete answer option if this is the first answer we are adding.
                if ($(containerDivE).children("li").length == 2) {
                    $(newLiE).append(deleteIconHtml);
                    $(liE).append(deleteIconHtml);
                }
                
                newInputField = $(newLiE).children("input");
                $(newInputField).attr("id", $(inputField).attr("id") + "1");
                $(newInputField).val("");
                $(newInputField).focus();
                setAutocomplete($(newInputField), $(inputField).autocomplete("option", "source"));
                //$(newLiE).autocomplete($(inputField).autocomplete());
                //mark old field as "answered"
                $(inputField).addClass("answered");
            }
            function refreshForm() {
                document.location.href = 'case.do';
            }
            function submitForm(direction) {
                $("#action").val(direction);
                $("#caseForm").submit();
            }
            function removeAnswer(field) {
                //remove the X (delete answer) option if, last option left.
                var parentDiv = $(field).parents("div");
                $(field).parents("li").remove();
                if ($(parentDiv).children("li").length == 1) {
                    $(parentDiv).children("li").children("img").remove();
                }
                
            }
        </script>
    </head>
    <body>
        <div style="text-align: center;">
        <form name="caseForm" id="caseForm" method="POST" action="case.do">
        <div class="topBar">
            Case 1 - Testcase.  Question: <%=Integer.toString((Integer) request.getSession().getAttribute("caseNumber")+1)%> out of <%=request.getSession().getAttribute("caseNumberTotal")%>
        </div>
        <div class="caseBody">
            <%=request.getAttribute("caseHtml")%>
        </div>
        </div>
        
        <div class="controlButtons" style="text-align: center;">
            <input type="hidden" name="action" id="action" value="refresh">
            
            <input type="button" value="Quit" onclick="document.location.href = '../'">
            <input type="button" value="Refresh" onclick="refreshForm()">
            <input type="button" value="Previous Question" onclick="submitForm('previous')">
            <input type="button" value="Next Question" onclick="submitForm('next')">
        </div>
        </form>
    </body>
</html>
