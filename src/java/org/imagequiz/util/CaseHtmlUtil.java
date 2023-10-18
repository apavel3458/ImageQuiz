/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.util;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQImage;
import org.imagequiz.model.IQReference;
import org.imagequiz.model.question.IQAnswer;
import org.imagequiz.model.question.IQAnswerChoice;
import org.imagequiz.model.question.IQAnswerSearchTermLine;
import org.imagequiz.model.question.IQAnswerSearchTermWrapper;
import org.imagequiz.model.question.IQCaseAnswer;
import org.imagequiz.model.question.IQQuestion;
import org.imagequiz.model.question.IQQuestionChoice;
import org.imagequiz.model.question.IQQuestionSearchTerm;
import org.imagequiz.model.question.IQQuestionText;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQUserQuestionAnswered;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.web.AdminAction;

/**
 *
 * @author apavel
 */
public class CaseHtmlUtil {
	private static Logger _log = Logger.getLogger(CaseHtmlUtil.class);
	
	final DecimalFormat pointsFormatModifier = new DecimalFormat("+#.##;-#.##");
	final DecimalFormat pointsFormatFinal = new DecimalFormat("#.##");
	
    //supporting class for IQCase to convert text to html etc...
    public CaseHtmlUtil() {
        
    }
    
    public String convertToCaseHtml(String caseText, IQCase iqCase, IQCaseCompleted caseCompleted, IQUserQuiz quiz, IQDataSource dataSource, boolean answerPage) throws CaseParseException {
        //caseText = StringEscapeUtils.escapeHtml(caseText.trim());
    	
    	//--------PREP CASE TEXT--------
    	if (caseText == null) {
    		caseText = "<div class=\"blankCase\">There is no answer for this case</div>";
    		return caseText;
    	}
    	String caseTextBuffer = caseText;
    	
    	caseTextBuffer = caseTextBuffer.replaceAll("\n[\\s]*\\{", "{");
    	caseTextBuffer = caseTextBuffer.replaceAll("}[\\s?]\n", "}");
    	caseTextBuffer = caseTextBuffer.replaceAll("\n", "<br>\n");
    	caseTextBuffer = caseTextBuffer.replaceAll("  ", "&nbsp;&nbsp;");

    	List<IQReference> refs = (List<IQReference>) dataSource.getSession().createCriteria(IQReference.class).list();
    	caseTextBuffer = createReferenceLinks(caseTextBuffer, refs);

    	//System.out.println(caseTextBuffer);
    	
    	//----- the following finds all text between the {...:...} tags and if it's more than 3 characters of non
    	// white space, it puts <p class="caseText"></p> around it
    	String textToMatch = caseTextBuffer.toString();
    	Pattern p = Pattern.compile("\\{[^\\}]+\\}");  //matches everything in {...}
    	Pattern nonwhitespace = Pattern.compile("[\\S]{3,}");  //it will put <div> </div> before {...}, and after (but only if there is text after it "3 non-whitespace character"
    		
    	Matcher m = p.matcher(textToMatch);
    	int z = 0;
    	int z2 = 0;
    	int z3 = 0;
    	while (m.find(z)) {
    			//String matched = m.group();
    			z2 = m.start();
    			z3 = m.end();
    			
    			String preMatched = textToMatch.substring(z, z2);
    			// System.out.println("PREMATCHED: " + preMatched);
    			if (nonwhitespace.matcher(preMatched).find()) {//at least 3 non-whitespace characters
    				preMatched = "<div class=\"caseText\">" + preMatched + "</div>";
    			}
    			textToMatch = textToMatch.substring(0, z) + preMatched + textToMatch.substring(z2);
    			z = z + preMatched.length() + (z3-z2);
    			m = p.matcher(textToMatch);
    	}
    	if (z > 0) {  //match at the end
    		z = textToMatch.lastIndexOf("}")+1;
    		String preMatched = textToMatch.substring(z);
    		if (nonwhitespace.matcher(preMatched).find()) {//at least 3 non-whitespace characters
				preMatched = "<div class=\"caseText\">" + preMatched + "</div>";
			}
			textToMatch = textToMatch.substring(0, z) + preMatched;
    	}
    	//System.out.println("result: " + textToMatch);
    	caseTextBuffer = new String(textToMatch);
        
        //The following finds the "insert" areas within the text such as {question:myquestion} and replaces it with proper HTML
        int i;
        int i2;
        while ((i = caseTextBuffer.indexOf("{")) != -1) {
            i2 = caseTextBuffer.indexOf("}");
            if (i2 < i || i2 == -1) throw new CaseParseException("Please make sure all '{' are are followed by '}' in question text");
            String insideBrackets = caseTextBuffer.substring(i+1, i2);
            String replaceText = "";
            if (insideBrackets.startsWith("image:")) {
                String imageId = insideBrackets.split(":")[1];
                IQImage currentImage = dataSource.getImage(Long.parseLong(imageId));
                if (currentImage == null) {
                	replaceText = "<div class=\"imageDiv, error\">--IMAGE NOT FOUND--</div>";
                } else {
                	String imageFilename = dataSource.getImage(Long.parseLong(imageId)).getFilename();
                    replaceText = "<div class=\"imageDiv\"><img src=\"../image?getfile=" + imageFilename + "\" class='caseImage'></div>";
                }
                
            } else {
                //format {question:2}
                String itemAction = insideBrackets.substring(0, insideBrackets.indexOf(":"));
                String itemId = insideBrackets.substring(insideBrackets.indexOf(":") +1);
                //itemId = itemId.replaceAll("/[^A-Za-z0-9 ]/", "");  // strip everything, used as field name
                if (itemAction.equalsIgnoreCase("question")) {
                    IQQuestion question = iqCase.getQuestionById(itemId);
                    
                    //failsafe
                    //if (question == null) throw new CaseParseException("Question '{" + insideBrackets + "' + is not found in case settings.  Please make sure there is a corresponding <question id=\"..\"");
                    if (question == null) {
                    		replaceText = "<div class='row'><div class='col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1 errorInQuestion'>\n"
                    				+ "CANNOT FIND QUESTION"
                    				+ "</div>";
                    } else {
                    	
                    	
                    	
                    	
                    	
     //QUESTION - CHOICE
                        if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_CHOICE)) { //QUESTION
                        	IQQuestionChoice questionSC = (IQQuestionChoice) question;
                        	replaceText = "<div class='row'><div class='col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1'>\n"
                        			+ "<div class=\"panel panel-primary interactionPanel questionBox\">"
                        			//------<div tags covered -----
                    				+ "<div class=\"panel-heading\"><h3 class=\"panel-title\">" + questionSC.getQuestionText() + "</h3></div>"
                    				+ "<div class=\"panel-body\">";
                        	String maxSelectionsText = "";
                        	if (questionSC.getMaxUserSelections()==0) maxSelectionsText = "Select <b>ALL</b> that apply (Unlimited)";
                        	else if (questionSC.getMaxUserSelections()==1) maxSelectionsText = "Select only <b>ONE</b> item";
                        	else if (questionSC.getMaxUserSelections()>1) maxSelectionsText = "Select <b>ALL</b> that apply (Max " + questionSC.getMaxUserSelections() + " items)";
                        	replaceText = replaceText + "<div class='questionInstruction'>" + maxSelectionsText + "</div>";
                        	replaceText = replaceText + "<table class='choiceItemContainer' class='answerSearchtextTable' data-maxchoices='" + questionSC.getMaxUserSelections() + "'>";
                        	
                        	int ii = 0;
                        	List<IQAnswerChoice> choices = questionSC.getAssociatedChoices();
                        	if (questionSC.getShuffle()) {
                        		if (quiz != null && quiz.getQuizId() != null) Collections.shuffle(choices, new Random(quiz.getQuizId()));
                        		else Collections.shuffle(choices, new Random(Calendar.getInstance().get(Calendar.HOUR_OF_DAY) * 60 + Calendar.getInstance().get(Calendar.MINUTE)));
                        		
                        	}
                        	for (IQAnswerChoice choice: choices) {
                        		replaceText = replaceText + "<tr class=\"choiceItemLine\">";
                        		
                        		//try to get any available answers
                        		String checked = "";
                        		if (caseCompleted != null) { 
                        			//IQUserQuestionAnswered answeredQ = IQUserQuestionAnswered.getQuestionById(question.getQuestionTextId(), caseCompleted.getAnsweredQuestions());
                        			List<IQCaseAnswer> answers = caseCompleted.getAnswers();
                        			for (IQCaseAnswer answer: answers) {
                        				if (answer.getItemId() == choice.getChoiceId())
                        				checked = " checked";
                        			}
                        		}
                        		
                        		
                        		replaceText = replaceText + "<th><input type=\"checkbox\"" + checked +" id=\"q-" + question.getQuestionTextId() + ii + "\" class=\"choiceItem\" name=\"q-" + question.getQuestionTextId() + "\" value=\"" + choice.getAnswerString() + "\"></th>"
                        									+ "<td><label class=\"control-lavel choiceItemLabel\" for=\"q-" + question.getQuestionTextId() + ii + "\">" + choice.getAnswerString() + "</label></td>\n";		
                        		replaceText = replaceText + "</tr>";
                        		ii++;
                        	}
                        	replaceText = replaceText + "</table>\n";
                        	       //------<div tags covered
                        	
                        	replaceText = replaceText + "</div></div></div></div>\n";
                        	
                        	
                        	
                        
      //QUESTION SEARCH-TERM
                        	
                        } else if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_SEARCHTERM)) {
                        	IQQuestionSearchTerm questionST = (IQQuestionSearchTerm) question;
                        	replaceText = "<div class='row'><div class='col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1'>\n"
                        			+ "<div class=\"panel panel-primary interactionPanel questionBox\">"
                    				+ "<div class=\"panel-heading\"><h3 class=\"panel-title\">" + questionST.getQuestionText() + "</h3></div>"
                    				+ "<div class=\"panel-body\">";

                        	replaceText = replaceText + "<div class='questionInstruction'>Type diagnosis slowly and select from options</div>"
                        			+ "<div class='diagnosisContainer'>"
                        			+ "<input type=\"text\" class=\"questionInput\" id=\"q-" + question.getQuestionTextId() + "Select\" placeholder=' &lt; Enter diagnosis &gt; '><input type=\"hidden\" id=\"q-" + question.getQuestionTextId() + "\" name=\"q-" + question.getQuestionTextId() + "\">"
                        			+ "<button type=\"button\" class=\"btn btn-default btn-sm optionsButton\" id=\"showOptionsButton\" data-load-url=\"../exam/exam.do?method=showSearchTerms&questionid=" + question.getQuestionId() + "\">"
                        					+ "<span class='glyphicon glyphicon-th-list' aria-hidden='true'></span>"
                        					+ "</button>\n";
                            replaceText = replaceText + "<div class='questionSelectedItems'>"
                            		+ "<ul id=\"q-" + question.getQuestionTextId() + "UL\" class=\"answerListUL\"></ul></div>";
                        	replaceText = replaceText + "</div></div></div></div></div>\n";
                        	
                        	
                        	
                        	
 //QUESTION - TEXT                       	
                        } else if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_TEXT)) {
                        	IQQuestionText questionT = (IQQuestionText) question;
                        	replaceText = "<div class='row'><div class='col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1'>\n"
                        			+ "<div class=\"panel panel-primary interactionPanel questionBox\">"
                    				+ "<div class=\"panel-heading\"><h3 class=\"panel-title\">" + questionT.getQuestionText() + "</h3></div>"
                    				+ "<div class=\"panel-body\">";
                        	
                        	replaceText = replaceText + "<div class='questionInstruction'>Type answer in the box</div>";
                        	
                        	replaceText = replaceText
                        			+ "<textarea class=\"caseQuestionText\" rows=\"" + questionT.getHeight() + "\" id=\"q-" + question.getQuestionTextId() + "\" name=\"q-" + question.getQuestionTextId() + "\"></textarea>";
                        	
                        	replaceText = replaceText + "</div></div></div></div>\n";
                        	

                        }
                    }
                }
                else if (itemAction.equalsIgnoreCase("answer")) {
                	IQQuestion question = iqCase.getQuestionById(itemId);
                	
                	
                	
    //ANSWER - CHOICE
                	if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_CHOICE)) {
                		IQQuestionChoice questionSC = (IQQuestionChoice) question;
                		// List<IQUserQuestionAnswered> userAnsweredQuestions = caseCompleted.getAnsweredQuestions();
                		// IQUserQuestionAnswered userAnsweredQuestion = IQUserQuestionAnswered.getQuestionById(question.getQuestionTextId(), userAnsweredQuestions);
                		List<IQCaseAnswer> answers = caseCompleted.getAnswers();
                		
                    	replaceText = "<div class='row'><div class='col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1'>\n"
                    			+ "<div class=\"panel panel-primary interactionPanel answerBox\">"
                    			//------<div tags covered -----
                				+ "<div class=\"panel-heading\"><h3 class=\"panel-title\">" + questionSC.getQuestionText() + "</h3></div>"
                				+ "<div class=\"panel-body\">";
                    	
                    	String maxSelectionsText = "";
                    	if (questionSC.getMaxUserSelections()==0) maxSelectionsText = "Select <b>ALL</b> that apply (Unlimited)";
                    	else if (questionSC.getMaxUserSelections()==1) maxSelectionsText = "Select only <b>ONE</b> item";
                    	else if (questionSC.getMaxUserSelections()>1) maxSelectionsText = "Select <b>ALL</b> that apply (Max " + questionSC.getMaxUserSelections() + " items)";
                    	
                    	
                    	replaceText = replaceText + "<div class='questionInstruction'>" + maxSelectionsText + "</div>";
                    	//replaceText = replaceText + "<div class='choiceItemContainer'>";
                		replaceText = replaceText +"<table class=\"answerChoiceTable\">";
                    	
                    	int ii = 0;
                    	
                    	List<IQAnswerChoice> choices = questionSC.getAssociatedChoices();
                    	if (questionSC.getShuffle()) {
                    		if (quiz != null && quiz.getQuizId() != null) Collections.shuffle(choices, new Random(quiz.getQuizId()));
                    		else Collections.shuffle(choices, new Random(Calendar.getInstance().get(Calendar.HOUR_OF_DAY) * 60 + Calendar.getInstance().get(Calendar.MINUTE)));
                    		
                    	}
                    	for (IQAnswerChoice choice: choices) {
                    		String choiceStatus = "";
                    		String checked = "";
                    		String missed = "";
                    		
                    		if (choice.getCorrect()) {
                    			//correct answer whether or not the user picked it
                    			choiceStatus = "correct";
                    		}
                    		
                    		if (answers != null && answers.size() > 0) {
	                    		//get userChoice so we can know the final score (wrong-choice score and choice-select-score added) - two ways of penalize
	                    		IQCaseAnswer answer = null;
	                    		for (IQCaseAnswer a: answers) { if (a.getItemId() == choice.getChoiceId()) answer = a;  }
	                    		//IQAnswer userAnswer = null;
                    		
	                    		if (answer != null) {
	                    			checked = " checked";
	                    			// answer.setScore(choice.getSelectScore());
	                    			//either user picked the answer or missed the answer
	                    			
	                    			if (!choice.getCorrect()) {  
	                    				//if user picked incorrect answer
	                    				choiceStatus = "incorrect"; 
	                    				// answer.setScore(answer.getScore().add(question.getWrongChoiceScore()));
	                    			} else if (answer.getStatus().equals(IQCaseAnswer.STATUS_MISSED)) {
	                    				//used did not enter a value that has missed="" score
	                    				missed = " (missed: " + pointsFormatModifier.format(answer.getScore()) + ")";
	                    				checked = "";
	                    			}
	                    		}
                    		}
                    		
                    		String decimalCss = " decimal" + getNumberOfDecimalPlaces(choice.getSelectScore());

                    		replaceText = replaceText + "<tr class=\"" + choiceStatus + "\"><th class=\"choiceScore" + decimalCss + "\">" + pointsFormatModifier.format(choice.getSelectScore()) + "</th>";
                    		
                    		
                    		replaceText = replaceText + "<td class=\"choiceCheckbox\">";
                    		
                    		replaceText = replaceText + "<input type=\"checkbox\" id=\"q-" + question.getQuestionTextId() + ii + "\" class=\"choiceItem disabled\" disabled=\"disabled\" name=\"q-" + question.getQuestionTextId() + "\" "
                    										+ "value=\"" + choice.getAnswerString() + "\"" +  checked + ">"
                    										+ "</td>"
                    									+ "<td class='choiceText'><label class=\"control-label choiceItemLabel\" for=\"q-" + question.getQuestionTextId() + ii + "\">" + choice.getAnswerString() + missed + "</label></td>\n";		
                    		replaceText = replaceText + "</td></tr>";
                    		ii++;
                    	}
                    	replaceText = replaceText + "</table>";
                    	//replaceText = replaceText + "</div>\n";
                    	       //------<div tags covered
                    	
                    	
                    	String cssColor = "incorrect";
                		String userTotalScore = "0";
                		BigDecimal totalScore = new BigDecimal(0);
                		for (IQCaseAnswer a: answers) { 
                			_log.debug("anwer: " + a.getScore());
                			totalScore = totalScore.add(a.getScore()); 
                		}
                		_log.debug("total score: " + totalScore);
                		if (answers == null) {
                			userTotalScore = "N/A";
                		} else if (totalScore.compareTo(questionSC.getPassScore()) >= 0) {
                			cssColor = "correct";
                			userTotalScore = pointsFormatFinal.format(totalScore);
                		} else {
                			userTotalScore = pointsFormatFinal.format(totalScore);
                		}
                		replaceText = replaceText + "<div class=\"pointsTally " + cssColor + "\">Required: " + pointsFormatFinal.format(questionSC.getPassScore()) + " pts. | Earned: " + userTotalScore + " pts.</div>";
                    	
                    	
                    	replaceText = replaceText + "</div></div></div></div>\n";
                    	

                    	
                    	
                    	
                    	
                    	
       //ANSWER TEXT 
                	} else if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_TEXT)) {
                		IQQuestionText questionT = (IQQuestionText) question;
                		
                		replaceText = replaceText + "<div class='row'><div class='col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1'>\n"
                				+ "<div class=\"panel panel-primary interactionPanel answerBox\">"
                				+ "<div class=\"panel-heading\"><h3 class=\"panel-title\">" + questionT.getQuestionText() + "</h3></div>"
                				+ "<div class=\"panel-body\">";
                		
                		
                		replaceText = replaceText + "<div class='questionInstruction'>Your answer:</div>";
                    	
                		
                		
                		List<IQUserQuestionAnswered> userAnsweredQuestions = caseCompleted.getAnsweredQuestions();
                		IQUserQuestionAnswered userAnsweredQuestion = IQUserQuestionAnswered.getQuestionById(question.getQuestionTextId(), userAnsweredQuestions);

                		if (userAnsweredQuestion != null) {
	                		for (IQAnswer userAnswerElement: userAnsweredQuestion.getUserSelections()) {
	                			replaceText = replaceText + "<div class=\"answerText\">" + userAnswerElement.getAnswer() + "</div>";
	                		}
                		}


              
                		replaceText = replaceText + "</div></div></div></div>";
                		
                		
                		
                		
                		
                		
                		
      //ANSWER SEARCHTERM
                	} else if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_SEARCHTERM)) {
                		IQQuestionSearchTerm questionST = (IQQuestionSearchTerm) question;
                		
                		//IQUserQuestionAnswered userAnsweredQuestion = IQUserQuestionAnswered.getQuestionById(question.getQuestionTextId(), userAnsweredQuestions);
                		IQQuestion caseQuestion = caseCompleted.getAssociatedCase().getQuestionById(question.getQuestionTextId());
                		List<IQCaseAnswer> answers = new ArrayList();
                		for (IQCaseAnswer a : caseCompleted.getAnswers()) {
                			if (a.getAssociatedQuestion().getQuestionId().equals(caseQuestion.getQuestionId())) answers.add(a);
                		}
                		//display user answers
                		
                		replaceText = replaceText + "<div class='row'><div class='col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1'>\n"
                				+ "<div class=\"panel panel-primary interactionPanel answerBox\">"
                				+ "<div class=\"panel-heading\"><h3 class=\"panel-title\">" + questionST.getQuestionText() + "</h3></div>"
                				+ "<div class=\"panel-body\">";
                		if (caseQuestion != null) {
                			replaceText = replaceText + "<fieldset class='correctAnswers'><legend class='correctAnswersLegend'>User Answers</legend>";
	                		replaceText = replaceText + "<table class=\"answerSearchtextTable\">";
	                		
	                		for (IQCaseAnswer answer: answers) {
	                			if (answer != null) {
		                			String choiceStatus = "";
		                			if (answer.getStatus() != null) {
			                			if (answer.getStatus().equals(IQCaseAnswer.STATUS_CORRECT)) choiceStatus = "correct";
			                			else if (answer.getStatus().equals(IQCaseAnswer.STATUS_INCORRECT)) choiceStatus = "incorrect";
			                			else if (answer.getStatus().equals(IQCaseAnswer.STATUS_MISSED)) choiceStatus = "missed";
		                			}
		                			
		                			String decimalCss = " decimal" + getNumberOfDecimalPlaces(answer.getScore());
		                			
		                			replaceText = replaceText + "<tr class=\"" + choiceStatus + "\"><th class='STscore"+ decimalCss +"'>"+ pointsFormatModifier.format(answer.getScore()) +"</th><td>"+ answer.getText();
		                			if (answer.getStatus() != null && answer.getStatus().equals(IQCaseAnswer.STATUS_MISSED)) replaceText = replaceText + " (missed) ";
		                			replaceText = replaceText + "</td></tr>";
	                			}
	                		}
                		
	                		replaceText = replaceText + "</table></fieldset>";
                		}
                		//correct answers
                		replaceText = replaceText + "<fieldset class='correctAnswers'><legend class='correctAnswersLegend'>Answer Key</legend>"
                				+ "<table class=\"answerSearchtextTable\">";
                		
                		for (IQAnswerSearchTermLine line: questionST.getAssociatedAnswerLines()) {
                			int i3=0;	
                				
                				for (IQAnswerSearchTermWrapper answer: line.getAssociatedAnswerWrappers()) {
                					
                					//if dx is primary, make text darker
                					String postfix = "";
                					String prefix = "";
                					String dxCss = "secondaryDx";
                					if (answer.isPrimaryAnswer()) dxCss = "primaryDx";
                					if (!answer.isCorrectAnswer()) {
                						dxCss = "incorrectAnswerkeyDx";
                						postfix = " (wrong)";
                					}
                					
                					//if multiple possible answers for part marks (OR operator)
                					String subAnswerCss = "";
                					if (i3 > 0) {
                						subAnswerCss = " subAnswer";
                						prefix = "<span class=\"or\">or: </span>";
                					}
                					
                					//find number of decimal places (for formatting - make decimals smaller)
                					String decimalCss = " decimal" + getNumberOfDecimalPlaces(answer.getScoreModifier());
                					
                					String css = dxCss + subAnswerCss;
                					
                					replaceText = replaceText + "<tr><th class='STscore" + decimalCss + "'>" + pointsFormatModifier.format(answer.getScoreModifier()) + "</th>";
                					replaceText = replaceText + "<td class=\"STanswerText " + css + "\">" + prefix + answer.getSearchTerm().getSearchTermString()+ postfix + "</td></tr>";

                					i3++;
                				}
                			
            			}
              
                		replaceText = replaceText + "</table></fieldset>";
                		String cssColor = "incorrect";
                		String userTotalScore = "0";
                		BigDecimal totalScore = new BigDecimal(0);
                		for (IQCaseAnswer a : caseCompleted.getAnswers()) { totalScore = totalScore.add(a.getScore()); }
                		if (question == null) {
                			userTotalScore = "N/A";
                		} else if (totalScore.compareTo(questionST.getPassScore()) >= 0) {
                			cssColor = "correct";
                			userTotalScore = pointsFormatFinal.format(totalScore);
                		} else {
                			userTotalScore = pointsFormatFinal.format(totalScore);
                		}
                		replaceText = replaceText + "<div class=\"pointsTally " + cssColor + "\">Required: " + pointsFormatFinal.format(questionST.getPassScore()) + " pts. | Earned: " + userTotalScore + " pts.</div>";
                		replaceText = replaceText + "</div></div></div></div>";
                		

                	}
                }
            }
            StringBuffer newCaseTextBuffer = new StringBuffer("");
            newCaseTextBuffer.append(caseTextBuffer.substring(0, i));
            newCaseTextBuffer.append(replaceText);
            newCaseTextBuffer.append(caseTextBuffer.substring(i2+1));
            caseTextBuffer = newCaseTextBuffer.toString();
        }
        
        //insert comment box (if reviewing, it will be on top, during regular work, it will be on bottom)
        /*
        if (examMode.equals(IQExam.EXAM_MODE_CASEREVIEW)) {
        	String insertText = "<div class='questionDiv'>\n<table class=\"questionTable questionTableText\">\n";
        	insertText = insertText + "<tr><td class=\"questionText\">Case Reviewer Comments:</td></tr>";
        	insertText = insertText + "<tr><td class=\"choiceInput\"><div class=\"smallFont\">Type answer in the box</div>"
        			+ "<textarea class=\"caseQuestionText\" rows=\"4\" id=\"q-CaseReviewComments\" name=\"q-CaseReviewComments\"></textarea>"
        			+ "</td></tr>\n";
        	insertText = insertText + "</table></div>\n";
        }*/
        
    	//-- the following replaces all the terms with reference links (i.e. Bundle Branch Block with <a href="..>Bundle Branch Block</a>
    	
        caseTextBuffer = caseTextBuffer.replaceAll("<p></p>", "");
        caseTextBuffer = caseTextBuffer.replaceAll("<p></div>", "</div>"); // I am too tired to figure out why this happens... this will be obsolete soon anyway
        caseTextBuffer = caseTextBuffer.replaceAll("<div class=\"caseText\"></div>", "");
//        System.out.println("Case text buffer out:");
//        System.out.println(caseTextBuffer);
        return caseTextBuffer.toString();
    }
    
    private String createReferenceLinks(String source, List<IQReference> refs) {
    	
    	if (refs == null || refs.size() == 0) 
    		return source;
    	Map<String,String> tokens = new HashMap<String,String>();
    	for (IQReference ref: refs) {
    		tokens.put(ref.getSearchText().toLowerCase(), ref.getReplaceLink());
    	}

    	// Create pattern of the format "%(cat|beverage)%"
    	String patternString = "(" + StringUtils.join(tokens.keySet(), "|") + ")";
    	Pattern pattern = Pattern.compile(patternString, Pattern.CASE_INSENSITIVE);
    	Matcher matcher = pattern.matcher(source);

    	StringBuffer sb = new StringBuffer();
    	while(matcher.find()) {
    		String replaceText = "<span onclick=\"popupReference('" + tokens.get(matcher.group(1).toLowerCase()) + "')\" class=\"referenceLink\">" + matcher.group(1) + "</span>";
    		//String replaceText = "<a href=\"tokens.get(matcher.group(1).toLowerCase())\" target=\"_blank\" class=\"referenceLink\">" + matcher.group(1) + "</a>";
    	    matcher.appendReplacement(sb, replaceText);
    	}
    	matcher.appendTail(sb);

    	return sb.toString();
    }
    
    public static String placeSeparators(String part1, String part2) {
    	String result = 
    			"<div class=\"questionAnswerSeparator qaSeparatorOpen\">(Case Review Mode) - START CASE</div>" +
    			part1 +
				"<div class=\"questionAnswerSeparator qaSeparatorClose\">(Case Review Mode) - END CASE</div>" +
				"<div class=\"questionAnswerSeparator qaSeparatorOpen\">(Case Review Mode) - CASE SOLUTIONS</div>" +
				part2 +
				"<div class=\"questionAnswerSeparator qaSeparatorClose\">(Case Review Mode) END OF SOLUTIONS</div>";
    	return result;
    }
    
    int getNumberOfDecimalPlaces(BigDecimal bigDecimal) {
        String string = bigDecimal.stripTrailingZeros().toPlainString();
        int index = string.indexOf(".");
        return index < 0 ? 0 : string.length() - index - 1;
    }
   
    /*
    public static String addCommentBoxOnTop(String html) {
    	//adds a comment box at the top of the case
    	String insertText = "<div class='questionDiv'>\n<table class=\"questionTable questionTableText\">\n";
    	insertText = insertText + "<tr><td class=\"questionText\">Case Reviewer Comments/Answers:</td></tr>";
    	insertText = insertText + "<tr><td class=\"choiceInput\"><div class=\"smallFont\">Type answer in the box</div>"
    			+ "<textarea class=\"caseQuestionText\" rows=\"4\" id=\"q-CaseReviewComments\" name=\"q-CaseReviewComments\"></textarea>"
    			+ "</td></tr>\n";
    	insertText = insertText + "</table></div>\n";
    	html = insertText + html;
    	return html;
    }*/
    
}
