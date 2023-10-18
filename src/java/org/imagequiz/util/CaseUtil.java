package org.imagequiz.util;

import java.io.IOException;
import java.io.Serializable;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.persistence.TypedQuery;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQCaseComment;
import org.imagequiz.model.IQCaseTag;
import org.imagequiz.model.IQExercise;
import org.imagequiz.model.caseutil.IQCaseRevision;
import org.imagequiz.model.question.IQAnswer;
import org.imagequiz.model.question.IQAnswerChoice;
import org.imagequiz.model.question.IQAnswerSearchTermLine;
import org.imagequiz.model.question.IQAnswerSearchTermWrapper;
import org.imagequiz.model.question.IQCaseAnswer;
import org.imagequiz.model.question.IQQuestion;
import org.imagequiz.model.question.IQQuestionChoice;
import org.imagequiz.model.question.IQQuestionSearchTerm;
import org.imagequiz.model.question.IQQuestionText;
import org.imagequiz.model.question.IQSearchTermGroup;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserQuestionAnswered;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.model.user.IQUserQuizPerformance;
import org.nustaq.serialization.FSTConfiguration;

import com.github.difflib.algorithm.DiffException;
import com.github.difflib.text.DiffRow;
import com.github.difflib.text.DiffRow.Tag;
import com.github.difflib.text.DiffRowGenerator;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import jdk.internal.jline.internal.Log;

public class CaseUtil {
	Logger _log = Logger.getLogger(CaseUtil.class);
	public CaseUtil() {
		
	}
	
	static FSTConfiguration singletonConf = runOnce();
	
	public static FSTConfiguration runOnce() {
		FSTConfiguration sc = FSTConfiguration.createDefaultConfiguration();
		//Pre-register to make it faster
		sc.registerClass(IQUserQuestionAnswered.class, ArrayList.class, IQAnswer.class, String.class);
		return sc;
	}
    public static FSTConfiguration getInstance() {
        return singletonConf;
    }
    
    public static void saveSubmittedComment(IQDataSource dataSource, IQUser user, IQCase iqCase, String commentStr) {
		if (commentStr != null) {
			IQCaseComment comment = new IQCaseComment();
			comment.setText(commentStr);
			comment.setUser(user);
			comment.setAssociatedCase(iqCase);
			dataSource.saveObject(comment);
		}
    }
    
    public IQCaseCompleted convertCaseToCompleted(IQCase iqCase, IQUserQuiz quiz, HashMap<String, String[]> answers, IQDataSource dataSource) {
    	return convertCaseToCompleted(iqCase, quiz, answers, dataSource, null);
    }
	
	public IQCaseCompleted convertCaseToCompleted(IQCase iqCase, IQUserQuiz quiz, HashMap<String, String[]> answers, IQDataSource dataSource, IQCaseCompleted completedCase) {
		//will serialize answers to XML to store.
		if (completedCase == null) {
			completedCase = new IQCaseCompleted();
			completedCase.setAssociatedCase(iqCase);
			completedCase.setScore(new BigDecimal(0));
			completedCase.setPassScore(new BigDecimal(0));
		} else {
			// completedCase.setAnsweredQuestions(new ArrayList());
			completedCase.setAnswers(new ArrayList());
		}
		// BigDecimal casePassScore = new BigDecimal(0);
		// BigDecimal caseScore = new BigDecimal(0);
		//pull out case comment from answers list
		answers.remove("q-CaseReviewComment");// don't process comment in same way as questions.
		
		for (IQQuestion question: iqCase.getQuestionList()) {
			completedCase.setPassScore(completedCase.getPassScore().add(question.getPassScore()));
			// casePassScore = casePassScore.add(question.getPassScore());
			String[] userAnswerListStr = answers.get(question.getQuestionTextId());
			String[] userAnswerList;
			if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_SEARCHTERM)) {
				userAnswerList = StringUtils.split(userAnswerListStr[0], ",");
			} else if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_CHOICE)) {
				userAnswerList = userAnswerListStr;
			} else {
				userAnswerList = new String[1];
				userAnswerList[0] = userAnswerListStr[0];
			}
			if (userAnswerList == null) userAnswerList = new String[0];
			//IQUserQuestionAnswered userQuestionAnswered = new IQUserQuestionAnswered();
			//userQuestionAnswered.setQuestionId(question.getQuestionTextId());
			//ArrayList<IQAnswer> correctAnswers = question.getAnswerObjList();
			if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_SEARCHTERM)) {
						IQQuestionSearchTerm questionST = (IQQuestionSearchTerm) question;
						List<String> notFoundAnswers = new LinkedList<String>(Arrays.asList(userAnswerList));
						
						for (IQAnswerSearchTermLine cAnswerLine: questionST.getAssociatedAnswerLines()) {
							boolean foundAnswerFromSet = false;
							for (IQAnswerSearchTermWrapper cAnswerWrapper: cAnswerLine.getAssociatedAnswerWrappers()) {
								for (String userAnswer: userAnswerList) {
									if (cAnswerWrapper.getSearchTerm().getSearchTermString().trim().equalsIgnoreCase(userAnswer.trim())) {
										//correct answer
										//IQAnswer userAnswerChoice = new IQAnswer();
										IQCaseAnswer answer = new IQCaseAnswer(quiz, completedCase, question);
										answer.setText(userAnswer);
										answer.setItemId(cAnswerWrapper.getSearchTerm().getSearchTermId());
										if (!foundAnswerFromSet) { // prevents double-grading in one set
											// userAnswerChoice.setScore(cAnswerWrapper.getScoreModifier());
											answer.setScore(cAnswerWrapper.getScoreModifier());
											// DecimalFormat pointsFormat = new DecimalFormat("+#.##;-#.##");
											if (cAnswerWrapper.isCorrectAnswer()) answer.setStatus(IQCaseAnswer.STATUS_CORRECT);
											else answer.setStatus(IQCaseAnswer.STATUS_INCORRECT);
											foundAnswerFromSet = true;
										} else {
											// if multiple selections of the right answer (or using the "or" operator in answer key)
											answer.setScore(new BigDecimal(0));
											// userAnswerChoice.setScore(new BigDecimal(0));
										}
										//userQuestionAnswered.getUserSelections().add(userAnswerChoice);
										completedCase.setScore(completedCase.getScore().add(answer.getScore()));
										completedCase.getAnswers().add(answer);
										notFoundAnswers.remove(userAnswer);
									}
								}
							}
						}
						
						//loop to grade answers that were not int he answer key
						
						for (String userAnswer: notFoundAnswers) {
//							IQAnswer userAnswerChoice = new IQAnswer();
//							userAnswerChoice.setAnswer(userAnswer);
//							userAnswerChoice.setScore(question.getWrongChoiceScore());
//							userAnswerChoice.setStatus(IQAnswer.STATUS_INCORRECT);
							IQCaseAnswer answer = new IQCaseAnswer(quiz, completedCase, question);
							answer.setText(userAnswer);
							answer.setStatus(IQCaseAnswer.STATUS_INCORRECT);
							answer.setScore(question.getScoreIncorrectChoice());
							// userQuestionAnswered.getUserSelections().add(userAnswerChoice);
							completedCase.setScore(completedCase.getScore().add(answer.getScore()));
							completedCase.getAnswers().add(answer);
							quiz.getAnswers().add(answer);
						}
						
						//fill specific answers that are missed
						for (IQAnswerSearchTermLine cAnswerLine: questionST.getAssociatedAnswerLines()) {
							for (IQAnswerSearchTermWrapper cAnswerWrapper: cAnswerLine.getAssociatedAnswerWrappers()) {
								if (cAnswerWrapper.getScoreMissed().compareTo(BigDecimal.ZERO) != 0) {  //if score missed='' is defined in xml
									boolean found = false;
									for (String userAnswer: userAnswerList) {
										if (userAnswer.trim().equalsIgnoreCase(cAnswerWrapper.getSearchTerm().getSearchTermString().trim())) {
											found = true;
											break;
										}
									}
									if (!found) {
										//leave them out of IQCase for now, may have to put it back later (May 13, 2020)
//										IQAnswer userAnswerChoice = new IQAnswer();
//										userAnswerChoice.setAnswer(cAnswerWrapper.getSearchTerm().getSearchTermString());
//										userAnswerChoice.setScore(cAnswerWrapper.getScoreMissed());
//										userAnswerChoice.setStatus(IQAnswer.STATUS_MISSED);
//										userQuestionAnswered.getUserSelections().add(userAnswerChoice);
									}
								}
							}
						}
						
			} else if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_CHOICE)) {
				IQQuestionChoice questionC = (IQQuestionChoice) question;
				//remove more than allowed choices:
				if (questionC.getMaxUserSelections() != 0 && userAnswerList.length > questionC.getMaxUserSelections()) {
					//clip extra answers (if someone sneaky) or javascript breaks
					userAnswerList = Arrays.copyOf(userAnswerList, questionC.getMaxUserSelections()); 
				}
				for (IQAnswerChoice choice: questionC.getAssociatedChoices()) {
					boolean foundInUserAnswers = false;
					for (String userAnswer: userAnswerList) {
						if (userAnswer.equals(choice.getAnswerString())) {
							// found --> answer is correct
							// QAnswer userAnswerChoice = new IQAnswer();
							IQCaseAnswer answer = new IQCaseAnswer(quiz, completedCase, question);
							// userAnswerChoice.setAnswer(choice.getAnswerString());
							// userAnswerChoice.setScore(choice.getSelectScore());
							answer.setText(choice.getAnswerString());
							answer.setScore(choice.getSelectScore());
							answer.setItemId(choice.getChoiceId());
							if (choice.getCorrect().booleanValue())
								answer.setStatus(IQCaseAnswer.STATUS_CORRECT);
							else {
								answer.setStatus(IQCaseAnswer.STATUS_INCORRECT);
								answer.setScore(choice.getSelectScore().add(question.getScoreIncorrectChoice()));
							}
							//userQuestionAnswered.getUserSelections().add(userAnswerChoice);
							completedCase.setScore(completedCase.getScore().add(answer.getScore()));
							completedCase.getAnswers().add(answer);
							quiz.getAnswers().add(answer);
							foundInUserAnswers = true;
						}
					}
					if (!foundInUserAnswers) {
						System.out.println();
						if (choice.getMissScore().compareTo(BigDecimal.ZERO) != 0) {
							// I don't think we need to do the miss score for now (redundant) May 13, 2020
//							IQAnswer userAnswerChoice = new IQAnswer();
//							userAnswerChoice.setAnswer(choice.getAnswerString());
//							userAnswerChoice.setScore(choice.getMissScore());
//							userAnswerChoice.setStatus(IQAnswer.STATUS_MISSED);
//							userQuestionAnswered.getUserSelections().add(userAnswerChoice);
//							IQCaseAnswer answer = new IQCaseAnswer(quiz, completedCase);
//							answer.setText(choice.getAnswerString());
//							answer.setScore(choice.getMissScore());
						}
					}
				}
			} else if (question.getQuestionType().equalsIgnoreCase(question.QUESTION_TYPE_TEXT)) {
				String answerS = userAnswerList[0];
				IQQuestionText questionT = (IQQuestionText) question;
				if (answerS != null) {
					//clip answer at 1000 characters
					int MAX_CHAR = 500;
					int maxLength = (answerS.length() < MAX_CHAR)?answerS.length():MAX_CHAR;
					answerS = answerS.substring(0, maxLength);
					
//					IQAnswer userAnswerText = new IQAnswer();
//					userAnswerText.setAnswer(answer);
					IQCaseAnswer answer = new IQCaseAnswer(quiz, completedCase, question);
					answer.setText(answerS);
					quiz.getAnswers().add(answer);
					
					completedCase.getAnswers().add(answer);
					quiz.getAnswers().add(answer);
					// userQuestionAnswered.getUserSelections().add(userAnswerText);
				}
			}
			// userQuestionAnswered.setCorrectAnswers(question.getAnswerObjList()); //i am not sure why we need this, maybe for proof of what answers were at the time
			// userQuestionAnswered.setQuestionType(question.getQuestionType());
			//prevent negative points is in UserQuestionAnswered object getTotalScore();
			// caseScore = caseScore.add(userQuestionAnswered.getTotalScore());
			// completedCase.getAnsweredQuestions().add(userQuestionAnswered);
		}
		
		//set performance for tagid
		BigDecimal caseScore = completedCase.getScore();
		BigDecimal casePassScore = completedCase.getPassScore();
		updateQuizPerformance(quiz, iqCase, caseScore, casePassScore, dataSource);
		
		_log.debug("CASE SCORE: " + caseScore);
		_log.debug("CASE PASS SCORE: " + casePassScore);
		completedCase.setPass((caseScore.compareTo(casePassScore) >= 0));
		completedCase.setUserQuiz(quiz);
		return completedCase;
	}
	
	public static IQUserQuiz updateQuizPerformance(IQUserQuiz quiz, IQCase icase, BigDecimal score, BigDecimal passScore, 
							IQDataSource dataSource) {
//		List<IQUserQuizPerformance> existingPerformanceList = dataSource.getSession().createQuery("SELECT p FROM IQUserQuizPerformance p JOIN p.associatedTag t JOIN p.associatedUserQuiz q "
//				+ " WHERE q.quizId=:quizId", IQUserQuizPerformance.class)
//				.setParameter("quizId", quiz.getQuizId())
//				.list();
		
		List<IQUserQuizPerformance> performanceList = quiz.getPerformance();
		for (IQCaseTag tag: dataSource.getCaseTagsForQuiz(icase.getCaseId(), quiz.getQuizId())) {
			boolean existing = false;
			//check if exists
			for (IQUserQuizPerformance existingPerformance: performanceList) {
				if (existingPerformance.getAssociatedTag().getTagId().equals(tag.getTagId())) {
					existing = true;
					existingPerformance.setTotalScore(existingPerformance.getTotalScore().add(score));
					existingPerformance.setTotalPassScore(existingPerformance.getTotalPassScore().add(passScore));
				}
			}
			if (!existing) { //add new
				IQUserQuizPerformance performance = new IQUserQuizPerformance();
				performance.setAssociatedTag(tag);
				performance.setAssociatedUserQuiz(quiz);
				
				performance.setTotalScore(performance.getTotalScore().add(score));
				performance.setTotalPassScore(performance.getTotalPassScore().add(passScore));
				performanceList.add(performance);
			}
		}
		quiz.setPerformance(performanceList);
		return quiz;
	}
	
	public static HashMap<String, String[]> parseAnswersToHashMap(HttpServletRequest request) {
		HashMap<String, String[]> answers = new HashMap<String, String[]>();
		Enumeration<String> answerEnum = request.getParameterNames();
		while (answerEnum.hasMoreElements()) {
			String parameterName = (String) answerEnum.nextElement();
			//System.out.println("Looking at: " + parameterName);
			if (parameterName.startsWith("q-")) {
				String questionName = parameterName.substring(2);
				//System.out.println("question name: " + questionName + " attribute val: " + StringUtils.join(request.getParameterValues(parameterName), ' '));
				answers.put(questionName, request.getParameterValues(parameterName));
			}
		}
		return answers;
	}
	
	public static List<IQCase> returnCommonToBothLists(List<IQCase> one, List<IQCase> two) {
		List<IQCase> communal = new ArrayList();
		for (IQCase o1: one) {
			for (IQCase o2: two) {
				if (o1.equals(o2)) {
					communal.add(o1);
				}
			}
		}
		return communal;
	}
	
	public static Object fromString(byte[] s ) throws IOException, ClassNotFoundException {
		final FSTConfiguration conf = FSTConfiguration.createDefaultConfiguration();
		return conf.asObject(s);
		
		/*
		byte [] data = DatatypeConverter.parseBase64Binary(s);
		ObjectInputStream ois = new ObjectInputStream( 
		new ByteArrayInputStream(  data ) );
		Object o  = ois.readObject();
		ois.close();
		return o;*/
	}

/** Write the object to a Base64 string. */
	public static byte[] toString(Serializable o ) throws IOException {
		final FSTConfiguration conf = FSTConfiguration.createDefaultConfiguration();
		
		byte barray[] = conf.asByteArray(o);
		
		/*ByteArrayOutputStream baos = new ByteArrayOutputStream();
		ObjectOutputStream oos = new ObjectOutputStream( baos );
		oos.writeObject( o );
		oos.close();
		return DatatypeConverter.printBase64Binary(baos.toByteArray());*/
		return barray;
	}
	
	public static String getMCQuestionListJSON(IQCase icase) {
		
		List<Map<String, Object>> answerList = new ArrayList();
		if (icase.getQuestionList().size() > 0) {
			IQQuestionChoice questionChoice = (IQQuestionChoice) icase.getQuestionList().get(0);
			for (IQAnswerChoice choice: questionChoice.getAssociatedChoices()) {
				Map<String, Object> answerMap = new HashMap<String, Object>();
				//String choiceString = "{\"text\": \"" + choice.getAnswerString() + "\", \"correct\": " 
				//					+ choice.getCorrect().toString() + "}";
				answerMap.put("text", choice.getAnswerString());
				answerMap.put("correct", choice.getCorrect());
				answerList.add(answerMap);
			}
		}
		return new Gson().toJson(answerList);
	}
	
	public static String getSGQuestionListJSON(IQCase icase) {
//		[ { "score":1, "primary":true,"or":false,"text":"Pericarditis"}]
		
		List<Map<String, Object>> answerList = new ArrayList();
		if (icase.getQuestionList().size() > 0) {
			IQQuestionSearchTerm question = (IQQuestionSearchTerm) icase.getQuestionList().get(0);
			for (IQAnswerSearchTermLine line: question.getAssociatedAnswerLines()) {
				int i=0;
				for (IQAnswerSearchTermWrapper wrapper: line.getAssociatedAnswerWrappers()) {
					Map<String, Object> answerMap = new HashMap<String, Object>();
					answerMap.put("score", wrapper.getScoreModifier());
					answerMap.put("missed", wrapper.getScoreMissed());
					answerMap.put("primary", wrapper.isPrimaryAnswer());
					answerMap.put("text", wrapper.getSearchTerm().getSearchTermString());
					if (i>0)
						answerMap.put("or", true);
					else
						answerMap.put("or", false);
					answerList.add(answerMap);
					i++;
				}
			}
		}
		return new Gson().toJson(answerList);
	}
	
	public static String getQuestionOptionsJSON(IQCase icase) {
		Map<String, Object> options = new HashMap();
		if (icase.getQuestionList().size() > 0) {
			IQQuestionSearchTerm question = (IQQuestionSearchTerm) icase.getQuestionList().get(0);
			if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_SEARCHTERM)) {
				options.put("passScore", question.getPassScore());
				options.put("wrongChoiceScore", question.getWrongChoiceScore());
				ArrayList<String> groupsA = new ArrayList();
				for (IQSearchTermGroup group: question.getAvailableGroups()) {
					groupsA.add(group.getGroupName());
				}
				options.put("groups", StringUtils.join(groupsA, ", "));
			}
		}
		return new Gson().toJson(options);
	}
	
	//basically removes {question} and {answer:} markup if its at the end and start of the case
	public QuestionAnswerText removeQuestionAnswerMarkupSpecial(IQCase icase) { //only removes {question:..} markup
		// if there is a markup at the end of the case (question) or start of the case (answer) it removes it
		
		
		String caseText = icase.getCaseText();
		String answerText = removeLastQuestionMarkup(icase.getCaseAnswerText());
		if (caseText == null) caseText = "";
		if (answerText == null) answerText = "";
		
		//check last occurence in caseText
		Pattern markup = Pattern.compile("\\{(question|answer):.{0,5}\\}");
		Matcher matcher = markup.matcher(caseText);
		Integer cutIndex = null;
		while (matcher.find()) {
			cutIndex = matcher.start();
		}
		if (cutIndex != null) {
			caseText = caseText.substring(0, cutIndex);
			
			//if found at the end of the question, then remove at the beginning of the answer
			Matcher answerMatcher = markup.matcher(answerText);
			cutIndex = null;
			if (answerMatcher.find()) {
				cutIndex = answerMatcher.end();
			}
			if (cutIndex != null) {
				answerText = answerText.substring(cutIndex);
			}
		}
								
		QuestionAnswerText qat = new QuestionAnswerText();
		qat.caseText = caseText;
		qat.answerText = answerText;
		return qat;
	}
	private String removeLastQuestionMarkup(String text) {
		//must match {question:mcq0} {answer:q0} and all variations
		Pattern markup = Pattern.compile("\\{(question|answer):.{0,5}\\}$");
		Matcher matcher = markup.matcher(text);
		Integer cutIndex = null;
		while (matcher.find()) {
			cutIndex = matcher.start();
		}
		if (cutIndex != null) {
			text = text.substring(0, cutIndex);
		}
		return text;
	}
	
	
	public class QuestionAnswerText {
		public String caseText;
		public String answerText;
	}
	
	public String removeAllQuestionMarkup(String text) { // removes all {question: .. } elements
		return text.replaceAll("\\{question\\:.*\\}", "");
	}
	
	public String createXml(String questionHtml, String answerHtml, String qData, String interfaceType, String optionsRaw) {
		//try to find {question:mcq0} in text, if it does not exist, we will add it (in case one wants to put question somewhere else
		String questionMarkup = "{question:q0}";
		String answerMarkup = "{answer:q0}";
		if (questionHtml.indexOf("{question:q0") != -1) { //allow custom question location
			questionMarkup = "";
		}
		String caseXml =
				"<case>\n<case-text>\n" + questionHtml + "\n" + questionMarkup + "\n</case-text>\n";
		caseXml = caseXml +
				"\n<answer-text>\n" + answerMarkup+ "\n" + answerHtml + "\n</answer-text>\n";
		
		
		//CREATE QUESTION TYPES
		Gson gson = new Gson();
		List<HashMap<String, String>> qMap = gson.fromJson(qData, new TypeToken<List<HashMap<String, String>>>(){}.getType());
		_log.debug("FOUND CHOICES: " + qMap.size());
		HashMap<String, String> qOptions = gson.fromJson(optionsRaw, new TypeToken<HashMap<String, String>>(){}.getType());
		_log.debug("FOUND OPTIONS: " + qMap.size());
		if (interfaceType.equals("mcq")) {
			caseXml = caseXml +
				"\n<settings editor=\"mcq\" display=\"1\">\n"
				+ "\t<question id=\"q0\" type=\"choice\" selections=\"1\" pass-score=\"1\" wrong-choice-score=\"0\">\n";
			for (HashMap<String, String> choice: qMap) {
				if (choice.get("text") != null && !choice.get("text").equals("")) {
					String correct = "0";
					String score = "+0";
					String correctText = choice.get("correct");
					if (correctText != null && correctText.equals("true")) {
						correct = "1";
						score = "+1";
					}
					caseXml = caseXml + 
							"\t\t<choice score=\"" + score + "\" correct=\"" + correct + "\">" + choice.get("text") + "</choice>\n";
				}
						
			}
		} else if (interfaceType.equals("sg")) {
			if (qOptions == null) qOptions = new HashMap();
			if (qOptions.get("groups") == null) qOptions.put("groups", "");
			if (qOptions.get("passScore") == null) qOptions.put("passScore", "1");
			if (qOptions.get("wrongChoiceScore") == null) qOptions.put("wrongChoiceScore", "0");
			caseXml = caseXml +
					"\n<settings editor=\"sg\" display=\"1\">\n"
					+ "\t<question id=\"q0\" type=\"search_term\" "
					+ "searchgroups=\""+ qOptions.get("groups") + "\" "
					+ "selections=\"1\" "
					+ "pass-score=\"" + qOptions.get("passScore") + "\" "
					+ "wrong-choice-score=\"" + qOptions.get("wrongChoiceScore") + "\">\n"
					+ generateSGchoices(qMap);
			
		}


		caseXml = caseXml + "\t</question>\n</settings>\n</case>";
		return caseXml;
	}
	
	private String generateSGchoices(List<HashMap<String, String>>qMap) {
//		[{"score":1,"primary":true,"missed":0,"or":false,"text":"Pericarditis"}]
		
		/*<question id="abnormalities" type="search_term" searchgroups="level1" pass-score="1" wrong-choice-score="0">
        <question-text>Identify Abnormalities</question-text>
		<answer score="+1" primary="1">Monomorphic Ventricular Tachycardia</answer>
    </question>*/
		
		String product = "";
		int i=0;
		for (HashMap<String, String> choice: qMap) {
			_log.debug("Processing choice: " + choice.get("text"));
			if (choice.get("text") != null && !choice.get("text").equals("")) {
				if (i < qMap.size()-1 && qMap.get(i+1).get("or").equals("true")) {
					product += "\t\t<answer>\n";
				}
				product += "\t\t<answer score=\"" + choice.get("score") + "\""
						+ " missed=\"" + choice.get("missed") + "\""
						+ " primary=\"" + choice.get("primary") + "\""
						+ ">" + choice.get("text") + "</answer>\n";
				if (choice.get("or").equals("true") && 
							(i == qMap.size()-1 ||  //last entry
							 i < qMap.size()-1 && qMap.get(i+1).get("or").equals("false"))) {
					product += "\t\t</answer>\n";
				}
			}
			i++;
		}
		return product;
	}
	
	public String escapeHTMLforXML(String html) {
		html = html.replaceAll("&", "&amp;"); 
		html = html.replaceAll("<", "&lt;");
		html = html.replaceAll(">", "&gt;");
		return html;
	}
	public String unescapeHTMLforXML(String xml) {
		xml = xml.replaceAll("&lt;", "<");
		xml = xml.replaceAll("&gt;", ">");
		xml = xml.replaceAll("&amp;", "&"); 
		return xml;
	}
	
	public String fixExternalLinks(String text) {
		String addition = "target=\"_blank\"";
		Pattern p = Pattern.compile("<a.+?>", Pattern.DOTALL);
    	Matcher m = p.matcher(text);
    	int x = 0;
        while (m.find(x))
        {
        	String betweenTags = text.substring(m.start(), m.end());
        	//System.out.println("BETWEEN TAGS" + betweenTags);
        	if (betweenTags.indexOf(addition) == -1)
        		betweenTags = betweenTags.substring(0, betweenTags.length()-1) + addition + betweenTags.substring(betweenTags.length()-1);
        	text = text.substring(0, m.start()) + betweenTags + text.substring(m.end());
        	
        	x= m.start() + betweenTags.length();
        }
		return text;
	}
	
	public String escapeHTMLinXMLtagsSpecial(String xml) {
		return escapeHTMLinXMLtagsSpecial(xml, true);
	}
	public String unescapeHTMLinXMLtagsSpecial(String xml) {
		return escapeHTMLinXMLtagsSpecial(xml, false);
	}
	
	//this code escapes everything in <case-text></case-text> and <answer-text></answer-text> tags
	public String escapeHTMLinXMLtagsSpecial(String xml, boolean escape) {
		
    	Pattern regexCaseText = Pattern.compile("(?i)(?<=<case-text>)([\\d\\D])+?(?=</case-text>)", Pattern.MULTILINE);  //matches everything in {...}
    	Pattern regexAnswerText = Pattern.compile("(?i)(?<=<answer-text>)([\\d\\D])+?(?=</answer-text>)", Pattern.MULTILINE);  //it will put <div> </div> before {...}, and after (but only if there is text after it "3 non-whitespace character"
    		
    	Matcher m = regexCaseText.matcher(xml);
    	int x = 0;
        while (m.find(x))
        {
        	String betweenTags = xml.substring(m.start(), m.end());
        	if (escape)
        		betweenTags = escapeHTMLforXML(betweenTags);
        	else
        		betweenTags = unescapeHTMLforXML(betweenTags);
        	xml = xml.substring(0, m.start()) + betweenTags + xml.substring(m.end());
        	
        	x= m.start() + betweenTags.length();
        }
    	
    	m = regexAnswerText.matcher(xml);
    	x = 0;
        while (m.find(x))
        {
        	String betweenTags = xml.substring(m.start(), m.end());
        	if (escape)
        		betweenTags = escapeHTMLforXML(betweenTags);
        	else
        		betweenTags = unescapeHTMLforXML(betweenTags);
        	xml = xml.substring(0, m.start()) + betweenTags + xml.substring(m.end());
        	
        	x= m.start() + betweenTags.length();
        }
        
    	return xml;
	}
	
	public String deletedStart = escapeHTMLforXML("<span class=\"deleted\">");
	public String deletedEnd = escapeHTMLforXML("</span>");
	public String newStart = escapeHTMLforXML("<span class=\"new\">");
	public String newEnd = escapeHTMLforXML("</span>");
	
    public void updateRevisionHistory(HttpServletRequest request, IQDataSource dataSource, IQCase icase, String oldXml, String newXml) throws Exception {

    	//constants
    	
    	oldXml = oldXml.replaceAll("&lt;(.+?)&gt;", " ");  //remove html tags (easier that way, b/c for some reason DiffGenerator goes in between <p> tags and produces very messed up HTML when I try to insert <span class="deleted
    	newXml = newXml.replaceAll("&lt;(.+?)&gt;", " ");
    	IQUser security = (IQUser) request.getSession().getAttribute("security");
    	IQUser iuser = dataSource.getUserById(security.getUserId());
    	List<String> oldSource = Arrays.asList(oldXml.split("\n"));
    	List<String> newSource = Arrays.asList(newXml.split("\n"));
    	for (int i=0; i< oldSource.size(); i++) {
    		oldSource.set(i, oldSource.get(i).trim());
    	}
    	for (int i=0; i< newSource.size(); i++) {
    		newSource.set(i, newSource.get(i).trim());
    	}
    	
    	// System.out.println("Diff lines: " + oldSource.size() + " " + newSource.size());
    	//create a configured DiffRowGenerator
    	DiffRowGenerator generator = DiffRowGenerator.create()
    	                .showInlineDiffs(true)
    	                .mergeOriginalRevised(true)
    	                .inlineDiffByWord(true)
    	                .oldTag(new Function<Boolean, String>() {
    	                	   public String apply(Boolean bool) {
    	                		   CaseUtil util = new CaseUtil();
    	                		   if (bool) {
    	                			   return util.deletedStart;
    	                		   } else {
    	                			   return util.deletedEnd;
    	                		   }
    	                	   }
    	                	   })      //introduce markdown style for strikethrough
    	                .newTag(
    	                		new Function<Boolean, String>() {
    	    	                	   public String apply(Boolean bool) {
    	    	                		   CaseUtil util = new CaseUtil();
    	    	                		   if (bool)
    	    	                			   return util.newStart;
    	    	                		   else
    	    	                			   return util.newEnd;
    	    	                	   }
    	    	                	   })     //introduce markdown style for bold
    	                .build();

    	//compute the differences for two test texts.
    	List<DiffRow> rows = generator.generateDiffRows(oldSource, newSource);

    	
    	Long contributionCounter = new Long(0);
    	String changes = "";
    	for (DiffRow row : rows) {
    		if (row.getTag() == Tag.EQUAL) {
    			//ignore
    		} else if (row.getTag() == Tag.DELETE) {
    			//System.out.println("|DELETE: " + row.getOldLine() + "|" + row.getNewLine() + "|");
    			changes = changes + this.deletedStart + row.getOldLine() + this.deletedEnd + "\n";
    		} else if (row.getTag() == Tag.CHANGE) {
    			//System.out.println("|CHANGE: " + row.getOldLine() + "|" + row.getNewLine() + "|");
    			String oldLine = row.getOldLine();
    			changes = changes + oldLine + "\n";
    			//count added characters
    			contributionCounter += computeContribution(oldLine);	
    		} else if (row.getTag() == Tag.INSERT) {
    			//System.out.println("|INSERT: " + row.getOldLine() + "|" + row.getNewLine() + "|");
    			changes = changes + this.newStart + row.getOldLine() + this.newEnd + "\n";
    			contributionCounter += computeContribution(row.getOldLine());
    		}
    	}
    	        
    	//System.out.println("FINAL CHANGE LOG: " + unescapeHTMLforXML(changes));
    	
    	
    	Gson gson = new Gson();
    	
    	
    	//determine role
    	String role = IQCaseRevision.ROLE_EDITOR;
    	if (icase.getRevisionHistory().size() == 0) {
    		role = IQCaseRevision.ROLE_AUTHOR;
    	}
    	
    	IQCaseRevision caseHistory = new IQCaseRevision();
    	caseHistory.setAuthor(iuser);
    	caseHistory.setParentCase(icase);
    	//caseHistory.setCaseXml(newXml);
    	
    	
    	caseHistory.setCaseXmlDiff(gson.toJson(changes));
    	caseHistory.setContributionWeight(contributionCounter);
    	caseHistory.setDatetime(new Date());
    	caseHistory.setRole(IQCaseRevision.ROLE_EDITOR);
    	
    	if (contributionCounter != 0)
    		dataSource.saveObject(caseHistory);
        
    }
    
    public IQCaseRevision getLastRevision(IQCase icase, IQDataSource dataSource) {
    	String hql ="select r from IQCaseRevision r JOIN r.parentCase c WHERE c.caseId=:caseId order by r.datetime DESC";
		TypedQuery<IQCaseRevision> query = dataSource.getSession().createQuery(hql, IQCaseRevision.class);
    	query.setParameter("caseId", icase.getCaseId());
    	query.setMaxResults(1);
    	List<IQCaseRevision> revisionList = query.getResultList();
    	if (revisionList.size() == 0) return null;
    	else return revisionList.get(0);
    }
    
    public IQCaseRevision getFirstVersion(IQCase icase, IQDataSource dataSource) {
    	String hql ="select r from IQCaseRevision r JOIN r.parentCase c WHERE c.caseId=:caseId order by r.datetime ASC";
		TypedQuery<IQCaseRevision> query = dataSource.getSession().createQuery(hql, IQCaseRevision.class);
    	query.setParameter("caseId", icase.getCaseId());
    	query.setMaxResults(1);
    	List<IQCaseRevision> revisionList = query.getResultList();
    	if (revisionList.size() == 0) return null;
    	else return revisionList.get(0);
    }
    
    //counts all the new characters
    private int computeContribution(String oldLine) {
    	/*
    	String modOldLine = oldLine;
    	String modNewLine = oldLine;
    	modOldLine = modOldLine.replaceAll(this.deletedStart + "(.+?)" + this.deletedEnd, ""); //get rid of deleted content (don't count it)
    	modOldLine = modOldLine.replaceAll(this.newStart + "(.+?)" + this.newEnd, "");  //get rid of added content (becase it's old Line)
    	modOldLine = modOldLine.replaceAll("&lt;(.+?)&gt;", "");//get rid of all remainting tags
    	modNewLine = modNewLine.replaceAll(this.deletedStart + "(.+?)" + this.deletedEnd, ""); //get rid of all deleted content (keeping only new content)
		modNewLine = modNewLine.replaceAll("&lt;(.+?)&gt;", "");//get rid of all remainting tags
		int difference = modNewLine.length() - modOldLine.length();*/
    	oldLine = oldLine.replaceAll("&nbsp;" , " ");
    	Pattern p = Pattern.compile(this.newStart + "(.+?)" + this.newEnd);
    	Matcher m = p.matcher(oldLine);
    	int lastMatchPos = 0;
    	int counter = 0;
    	while (m.find()) {
    	   String matchedString = oldLine.substring(m.start()+this.newStart.length(), m.end() - this.newEnd.length());
    	   System.out.println("MATCHED STRING: " + matchedString);
    	   counter += matchedString.length();
    	   lastMatchPos = m.end();
    	}
    	return counter;
    }
    
    

    public List<IQCase> filterByECGDx(IQExercise exercise, String[] sts, IQDataSource dataSource) {
		//COPIED FROM CASEACTION FINDEXPLORE
    	String operator = "OR";
    	List<IQCase> caseList = new ArrayList();
		
    	if (operator != null && operator.equalsIgnoreCase("AND")) {
    		String hql ="select DISTINCT c from IQCase c JOIN c.parentExercises e JOIN c.questionList q JOIN q.associatedAnswerLines l JOIN l.associatedAnswerWrappers w JOIN w.searchTerm st WHERE c.active=1 AND e.exerciseName=:exerciseName AND st.searchTermString=:st";
    		TypedQuery<IQCase> query = dataSource.getSession().createQuery(hql, IQCase.class);
	    	query.setParameter("exerciseName", exercise.getExerciseName());
	    	query.setParameter("st", sts[0]);
	    	caseList = query.getResultList();
	    	
	    	for (int i = 1; i< sts.length; i++) {
	    		hql ="select DISTINCT c from IQCase c JOIN c.parentExercises e JOIN c.questionList q JOIN q.associatedAnswerLines l JOIN l.associatedAnswerWrappers w JOIN w.searchTerm st WHERE c.active=1 AND e.exerciseName=:exerciseName AND st.searchTermString=:st";
	    		query = dataSource.getSession().createQuery(hql, IQCase.class);
		    	query.setParameter("exerciseName", exercise.getExerciseName());
		    	query.setParameter("st", sts[i]);
		    	
		    	//pick results contained in both lists
		    	List<IQCase> both = new ArrayList();
		    	for (IQCase c: query.getResultList()) {
		    		if (caseList.contains(c)) {
		    			both.add(c);
		    		}
		    	}
		    	caseList = both;
	    	}
    		
    	} else {
        	String hql = "SELECT DISTINCT c FROM IQCase c JOIN c.parentExercises e JOIN c.questionList q JOIN q.associatedAnswerLines l JOIN l.associatedAnswerWrappers w JOIN w.searchTerm st WHERE c.active=1 AND e.exerciseName=:exerciseName AND (";
			
	    	for (int i = 0; i< sts.length; i++) {
	    		String st = sts[i];
	    		hql = hql + "st.searchTermString=:st" + i;
	    		if (i != sts.length-1) {
	    			hql = hql + " OR ";
	    		}
	    	}
	    	hql = hql + ")";
	    	TypedQuery<IQCase> query = dataSource.getSession().createQuery(hql, IQCase.class);
	    	query.setParameter("exerciseName", exercise.getExerciseName());
	    	for (int i = 0; i< sts.length; i++) {
	    		query.setParameter("st" + i, sts[i]);
	    	}
	    	caseList = query.getResultList();
    	}
    	return caseList;
    }
    

     
	
}

