<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
    
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Consent Form</title>

    <!-- Bootstrap core CSS -->
    <link href="../css/lib/bootstrap.min.css" rel="stylesheet">

    <!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
    <link href="../css/lib/ie10-viewport-bug-workaround.css" rel="stylesheet">

    <!-- Custom styles for this template -->    
    <link href="../css/login.css" rel="stylesheet">

<style type="text/css">
	body {
		font-family: Verdana, Arial;
		font-size: 11px;
	}
	H3, H4 {
	text-align: center;
	}
	.consentBody {
		line-height: 20px;
		/*width: 800px;*/
		margin-left: auto;
		margin-right: auto;
	}
	.heading {
		font-weight: bold;
		margin-top: 10px;
	}
	.inputButtons {
		text-align: center;
		padding-top: 10px;
	}
	.inputButtons input {
	font-size: 20px;
	font-weight: bold;
	}
</style>
</head>
<body>

<div class="container-fluid">
<div style="float:left; margin-top: 70px; font-size: 16px;">June 8, 2017</div>
<!-- div style="float:right; margin-right: 40px;"><img style="width: 100%" src="../share/UWOlogo.png"></div-->
<div style="float:right; clear:right; margin-right: 20px; margin-top: 10px; text-align: right;"><img style="width: 60%" src="../share/UWOlogo2.gif"></div>
<div style="float:right; clear:right; margin-right: 0px; width: 200px; margin-top: 10px;">
<b>DEPARTMENT OF MEDICINE</b><br/>

London Health Sciences Centre<br/>
Rm. C6-004<br/>
University Hospital<br/>
London, Ontario, Canada<br/>

</div>


<div style="clear:both; margin-top: 120px;">
<H3>Informed Consent Form</H3>

<H4>Dose self-generation of diagnoses improve ECG interpretation skills in medical students and residents rotating through Cardiology</H4>

<div class="heading">Principal Investigator:</div>
Dr. Lorne Gula<br/>
London Health Sciences Centre, <br/>
University Hospital, London, Ontario, Canada<br/>
lorne.gula@lhsc.on.ca<br/>


<div class="heading">(A) Background Information:</div>
You are being invited to participate in a research study because you are a resident or medical student on the Cardiology rotation.  This study is on the topic of electrocardiogram (ECG) interpretation in medical education.  Various web-based methods of teaching ECG interpretation are currently used, and it is uncertain whether some methods of learning this skill are more effective than others.  Many online tools and traditional textbooks employ multiple-choice questions to create learner-content interaction.  However, current education literature suggests that self-generation may be superior to multiple choice in long-term retention tests.  Self-generation of answers involves free-text typing a list of ECG diagnoses aided by an autocomplete function, which is compared with selecting an answer from a list of pre-defined possibilities in a traditional multiple-choice format.
<div class="heading">(B) Aim of the Study:</div>
The purpose of the study is to determine whether practice using self-generation of diagnoses improves ECG interpretation skills when compared to traditional multiple choice.
<div class="heading">(C) Description of involvement:</div>
You are asked to consent for this study.  We will gather baseline information for this study, which includes gender, training program, level of training, career interest, amount of training in Cardiology to date, and your self-perceived skill in ECG interpretation.  You will also be asked to create a non-identifying unique ID, which can include letters, numbers, words, and phrases.  This login ID will be used to access a set of 30 practice questions.  You can complete these questions at your own pace over a 2-week period, and can re-access them using your study ID.  Immediately after completing the practice set you will be given a 12-question short-answer practice quiz, and a similar 12-question short-answer practice uiz 2-4 weeks after completing the practice questions.  We expect the training module to take 30-45 minutes to complete, and each of the two post-tests will take approximately 15 minutes.
<div class="heading">(D) Risks/Side-Effects: </div>
There are no risks associated with this study.  Participation or declining to participate will have no bearing on academic or employment standing.  
<br>
<div class="heading">(E) Benefits: </div>
You will receive training and practice in ECG interpretation.  Each practice question contains an answer and a description, which may be used to improve your skills.  However, you may not receive any benefit if our interventions are ineffective.
<div class="heading">(F) Exclusions: </div>
You must be a medical student or a resident to participate in this study.
<br>
<div class="heading">(G) Confidentiality: </div>
The answers provided during this module will be stored anonymously. We will gather baseline information for this study, which includes gender, training program, level of training, career interest, amount of training in Cardiology to date, and your self-perceived skill in ECG interpretation. Results form study will be analyzed, may be published in journals and presented at meetings to the medical/scientific community.  However, you will not be identified in any publication or report. Anonymous data will be stored on the ECGBootcamp.ca server, which is owned and operated by one of the study investigators (P. Antiperovitch) in London, Ontario, Canada.  Data will be stored for a period of 15 years as per Lawson data retention policy.  
<div class="heading">(H) Voluntary nature of study/Freedom to withdraw or participate: </div>
Your participation in this study is completely voluntary. You may withdraw from this study at any time and your withdrawal will not affect your training performance evaluations in any way.  We have no way of identifying who has participated. 
<div class="heading">(I) Withdrawal of participant by principal investigator: </div>
There are no specific withdrawal criteria. Because the data is anonymous, once submitted, data cannot be withdrawn.  However, participants can skip any questions they choose and exit the module or tests at any time without completing them.
<br>
<div class="heading">(J) Compensation: </div>
There is no compensation associated with this study.
<br>
<div class="heading">(K) Legal Rights</div>
Participants do not waive any legal rights by choosing to participate.
<br>
<div class="heading">(K) STATEMENT OF RESEARCH PARTICIPANT: </div>
I have been given sufficient time to consider the above information and to seek advice if I chose to do so. I have had the opportunity to ask questions which have been answered to my satisfaction. 
<br>
If at any time I have further questions, problems or adverse events, I can contact:<br>
<b>Dr. Pavel Antiperovitch 343-363-2710 (pavel.antiperovitch@lhsc.on.ca)</b><br><br>

By clicking "I Agree" I am indicating that I consent to the use of the data collected for analysis and publication.



<div class="inputButtons">
<button class="btn btn-danger" onclick="decline()">I Decline</button>   
<button style="margin-left: 10px;" class="btn btn-success" onclick="agree()">I Agree</button>
</div>
<br/>
If you have any questions about your rights as a research participant or the conduct of this study, you may contact The Office of Research Ethics (519) 661-3036, email: ethics@uwo.ca. 
<br/>
<br/>
<br/>
</div>
</div>

</body>
    <script src="<c:url value="/jslib/jquery-1.12.4.min.js"/>"></script>
	<script src="<c:url value="/jslib/jquery-ui-1.12.1.min.js"/>"></script>
    <script src="<c:url value="/jslib/bootstrap.min.js"/>"></script>
    <script type="text/javascript" language="JavaScript">
    	function agree() {
    		parent.agreeConsent();
    	}
    	function decline() {
    		parent.declineConsent();
    	}
    </script>
</html>