<html><head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>ImageQuiz</title>
        <link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.10.3/themes/base/jquery-ui.css">
        <link href="../jslib/tagit/jquery.tagit.css" rel="stylesheet" type="text/css">
    	<link href="../jslib/tagit/tagit.ui-zendesk.css" rel="stylesheet" type="text/css">
    	<link rel="stylesheet" type="text/css" href="../css/case.css">
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-ui-1.10.3/ui/jquery-ui.js"></script>
        <script src="../jslib/jquery-photo-resize.js"></script>
        <script type="text/javascript" src="../jslib/tagit/tag-it.min.js"></script>
        <script src="../jslib/zoom/okzoom.js"></script>
        <script type="text/javascript" language="JavaScript">
            //add highlight autocomplete partial matches
            
            $.ui.autocomplete.prototype._renderItem = function( ul, item){
            var term = this.term.split(' ').join('|');
            var re = new RegExp("(" + term + ")", "gi");
            var t = item.label.replace(re,"<b>$1</b>");
            t = t.replace(/\s*\[.*\]\s*/, '');
            return $( "<li></li>" )
               .data( "item.autocomplete", item )
               .append( "<a>" + t + "</a>" )
               .appendTo( ul );
            };
            
            var tagGroups = {};
            
            		tagGroups["findings"] = [
                
                  "Sinus Tachycardia",
              
                  "Ventricular Fibrillation [VFib]",
              
                  "U-waves [Uwaves U waves]",
              
                  "Old Anterior MI (Q-waves) [Q-wave Qwave infarction]",
              
                  "Old Inferior MI (Q-waves) [Q-wave Qwave infarction]",
              
                  "T-Wave Inversions (TWI)",
              
                  "Left Anterior Fascicular Block (LAFB) [Hemiblock]",
              
                  "Early Repolarization Pattern [Variant]",
              
                  "Right Atrial Abnormality (RAA) [Enlargement RAE]",
              
                  "3rd Degree AV Block (Wide Complex Escape) [Third Complete]",
              
                  "Non-specific ST abnormality [ST depression changes ischemia]",
              
                  "Atrial Fibrillation [Afib]",
              
                  "1st Degree AV Block [First]",
              
                  "2nd Degree AV Block (Wenckebach) [Second Mobitz I Wenkebach 2:1 3:2 4:3 5:4 6:5]",
              
                  "Multifocal Atrial Tachycardia",
              
                  "Right Bundle Branch Block (RBBB)",
              
                  "Left Atrial Abnormality (LAA) [Enlargement LAE]",
              
                  "S1Q3T3",
              
                  "3rd Degree AV Block (Narrow Complex Escape) [Third Complete]",
              
                  "ST Elevation MI (STEMI) - Lateral",
              
                  "PR Depressions",
              
                  "Incomplete Left Bundle Branch Block (LBBB)",
              
                  "AVNRT - Typical (Slow-Fast Type) [AV Nodal Re-Entry Tachycardia]",
              
                  "Left Axis Deviation (LAD)",
              
                  "Right Ventricular Hypertrophy (RVH) [Enlargement]",
              
                  "Right Axis Deviation (RAD)",
              
                  "Polymorphic Ventricular Tachycardia [VT]",
              
                  "Ventriculo-atrial conduction [inverted p-wave ventricular retroconduction retrograde]",
              
                  "2nd Degree AV Block (Mobitz II) [Second two 2:1 3:1 4:1 5:1]",
              
                  "Torsades de Pointes",
              
                  "Incomplete Right Bundle Branch Block (RBBB)",
              
                  "Lower Atrial Tachycardia",
              
                  "Old Posterior MI (Q-waves) [Q-wave Qwave infarction]",
              
                  "Premature Ventricular Contraction (PVC)",
              
                  "Left Ventricular Hypertrophy (LVH) [Enlargement]",
              
                  "Pseudo R'",
              
                  "2nd Degree AV Block (Mobitz I or II) [Second 2:1 two]",
              
                  "Poor R-Wave Progression",
              
                  "PR Elevations",
              
                  "Atrial Tachycardia",
              
                  "ST Elevation MI (STEMI) - Inferior",
              
                  "Left Ventricular Hypertrophy (LVH) with Strain [Enlargement]",
              
                  "Atrial Flutter",
              
                  "Left Bundle Branch Block (LBBB)",
              
                  "Left Posterior Fascicular Block (LPFB) [Hemiblock]",
              
                  "Junctional Rhythm",
              
                  "2:1 AVNRT  [AV Nodal Re-Entry Tachycardia]",
              
                  "Long QT",
              
                  "Old Lateral MI (Q-waves) [Q-wave Qwave infarction]",
              
                  "Atrial Flutter With Variable Conduction [2:1 3:1 4:1]",
              
                  "Right Ventricular Hypertrophy (RVH) with Strain [Enlargement]",
              
                  "Monomorphic Ventricular Tachycardia [VT]",
              
                  "Low Voltage Criteria",
              
                  "Ectopic Atrial Rhythm (Wandering Pacemaker)",
              
                  "ST Elevation MI (STEMI) - Anterior",
              
                  "Preexcitation (Delta Waves) [WPW Wolf Parkinson White Delta Accessory Pathway]",
              
                  "ST Elevation MI (STEMI) - RV involvement",
              
                  "Non-specific T wave abnormality [TWI depression inversion ischemia]",
              
                  "ST Elevations - Diffuse",
              
                  "Fragmented QRS (fQRS)",
              
                  "Sinus Bradycardia",
              
                  "Normal ECG [nsr]",
              
                  "AVNRT - Atypical (Fast-Slow Type) [AV Nodal Re-Entry Tachycardia]",
              
                  "Bigeminy or Trigeminy Pattern",
              
                  "Short QT",
              
                  "Premature Atrial Contraction (PAC)",
              
                  "Short PR",
               ""];
        
            
        function setAutocomplete(field, tags) {
            $(field).autocomplete({
                 source: tags,
                 minLength: 1,
                 select: function(event, ui) { return addSearchedAnswer(event, ui); },
                 response: function(event, ui) {
                                if (ui.content.length === 0) {
                                    ui.content.push({ label: "No search results - try fewer letters", value: "null" });
                                }
                           }
             });
        }
        	var startTime
            $(function() {
                //ON LOAD...
                
                startTime = new Date();
                
                $("img.caseImage").photoResize({
					bottomSpacing: 150
				});
                $('img.caseImage').okzoom({
                    width: 350,
                    height: 350,
                    scaleWidth: '150%',
                    border: "1px solid black",
                    shadow: "0 0 20px #000"
                  });
                
                $(".caseQuestionSearchTerm").each(function() {
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
            
        
            $('#q-findingsUL').tagit({
    	    	readOnly: false,
    	    	singleField: true,
                singleFieldNode: $('#q-findings'), 
                allowSpaces: true,
                onTagClicked: function(evt, ui) {
                	//$('#availableDifficulties').tagit('createTag', $('#selectedDifficulties').tagit('tagLabel', ui.tag));
                	//$('#selectedDifficulties').tagit('removeTagByLabel', $('#selectedDifficulties').tagit('tagLabel', ui.tag));
                }
    	    })
    	    setAutocomplete($("#q-findingsSelect")[0], tagGroups["findings"]);
    	    
           
        
        
        
        
            });

            function submitForm(direction) {
            	$("#loadonce").val("true");
                $("#action").val(direction);
                $("#timespent").val(new Date() - startTime);
                $("#caseForm").submit();
            }
            
            function refreshForm() {
            	location.reload();
            }

            function addSearchedAnswer(event, ui) {
            	if (ui.item.value == "null") {
                    ui.item.value = "";
                    return false;
                }
                var inputField = event.target;
                var selectedChoice = ui.item.value;
                var selectedChoice = selectedChoice.replace(/\s*\[.*\]\s*/, '');
                var parentElement = $(inputField).parent();
                var inputFieldId = $(inputField).attr('id');
                var ulFieldId = inputFieldId.substring(0, inputFieldId.length - "Select".length);
                //remove "Select" from the end of the field, and add UL to the end to find the UL list of selected answers
                $('#' + ulFieldId + 'UL').tagit('createTag', selectedChoice);
                $(inputField).val('');
                return false;
            }
            
            function showSearchTerms(questionId) {
            	var tagArray = tagGroups[questionId];
            	tagArray.sort();
            	var display = ""
            	for (var i=0; i< tagArray.length; i++) {
            		var tag = tagArray[i];
            		tag = tag.replace(/\s*\[.*\]\s*/, '');
            		display = display + tag + "<br>";
            	}
            	$('#infoSearchDisplayDialog').html(display);
            	$('#infoSearchDisplayDialog').dialog('open');
            }
            
            $(function() {
                $('#infoSearchDisplayDialog').dialog({
                    autoOpen: false,
                    maxWidth: 500,
                    maxHeight: 500,
                    overflow: 'auto'
                });
                
                $("img").mousedown(function(e){
                    e.preventDefault(); //prevent dragging in IE
                });
                
                
                
            });
        </script>
    </head>
    <body class="case">
    

        <div class="loginBox">
            <img src="../share/ECGbootcampLogo2.png" class="loginBoxLogo">
            <div class="loginBoxRight">
            Logged-in as: 
            <b>Pavel Antiperovitch 
            
            
            	(apavel@gmail.com)</b> 
           	
            &nbsp;&nbsp;&nbsp;&nbsp;
            
	            | <a href="case.do?method=dashboard">Dashboard</a> 
	            | <a href="#">User Settings</a> 
            
            | <a href="../user.do?method=logout">Logout</a> |
            </div>
        </div>
        <div>
        <form name="caseForm" id="caseForm" method="POST" action="exam.do">
        <div class="topBar">
            Case 1 - Testcase.  Question: 1 out of 6
        </div>
        <div class="caseBody">
        	
        	
            <div class="questionDiv">
<table class="questionTable">
<tbody><tr><td class="questionText">Identify Abnormalities</td></tr><tr><td class="choiceInput"><div class="smallFont">Use textbox to search, and select answers</div><input type="text" class="caseQuestionSearchTerm" id="q-findingsSelect"><input type="hidden" id="q-findings" name="q-findings"><div class="infoIcon"><img src="../share/icons/info.png" class="infoIcon" onclick="showSearchTerms('findings')"></div></td></tr>
<tr><td class="choiceList"><div class="smallFont">Selected answers: (click x to remove)</div><ul id="q-findingsUL" class="answerListUL"></ul></td></tr></tbody></table></div>

<div class="imageDiv"><img src="../image?getfile=file_20151206_214906-802.png" class="caseImage" style="height: 395px; width: auto;"></div>
            
            
        </div>
        
        </form></div>

        <div class="controlButtons" style="text-align: center;">
            <input type="hidden" name="action" id="action" value="refresh">

            <input type="hidden" name="method" id="testMode" value="quizNavigation">
            <input type="hidden" name="caseid" value="3">
            <input type="hidden" name="reviewmode" value="">
            <input type="hidden" name="timespent" id="timespent" value="">
            <input type="hidden" name="mode" value="practice">
            <input type="hidden" name="org.apache.struts.taglib.html.TOKEN" value="a654911bbe2de5d7ee5f29a7512c5863">
            
           	
           		<input type="button" value="Save Exam &amp; Quit" onclick="document.location.href = '/ImageQuiz'">
           	
            <input type="button" value="Clear Answers" onclick="refreshForm()">
            <input type="button" value="<<Previous" onclick="submitForm('back')">
            <input type="button" value="Next>>" onclick="submitForm('next')">
        </div>
        
        <div id="infoSearchDisplayDialog" class="dialog"></div>
    

</body></html>