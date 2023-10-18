/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.web;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;

import javax.persistence.TypedQuery;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionRedirect;
import org.apache.struts.actions.DispatchAction;
import org.hibernate.query.Query;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQCaseBaseClass;
import org.imagequiz.model.IQCaseComment;
import org.imagequiz.model.IQCaseDAO;
import org.imagequiz.model.IQCaseTag;
import org.imagequiz.model.IQExam;
import org.imagequiz.model.IQExercise;
import org.imagequiz.model.question.IQAnswerSearchTerm;
import org.imagequiz.model.question.IQAnswerSearchTermWrapper;
import org.imagequiz.model.question.IQQuestion;
import org.imagequiz.model.question.IQQuestionSearchTerm;
import org.imagequiz.model.question.IQSearchTermGroup;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.util.CaseHtmlUtil;
import org.imagequiz.util.CaseParseException;
import org.imagequiz.util.CaseUtil;
import org.imagequiz.util.CaseXMLParser;

import org.apache.struts.Globals;
import org.apache.struts.taglib.html.Constants;

/**
 *
 * @author apavel
 */
public class CaseAction extends DispatchAction {
	private static Logger _log = Logger.getLogger(CaseAction.class);

    
    protected IQDataSource dataSource;
    
    public void setIQDataSource(IQDataSource value) {
        dataSource = value;
      }
    
    @Override
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        return dashboard(mapping, form, request, response);
    }
    
        
    public CaseAction() {
    }
    
//    public ActionForward display(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
//        IQCaseDAO iqcasedao = (IQCaseDAO) dataSource.getLastIQCase();
//
//        //TODO: loads all cases each time (make more efficient)
//        CaseXMLParser caseXMLParser = new CaseXMLParser();
//        IQExercise iqCases = new IQExercise();
//        String action = request.getParameter("action");
//        Integer caseNumber = (Integer) request.getSession().getAttribute("caseNumber");
//        Integer pageNumber = (Integer) request.getSession().getAttribute("pageNumber");
//        
//        if (caseNumber == null) {
//            caseNumber = 0;
//        }
//        if (pageNumber == null) {
//            pageNumber = 0;
//        }
//        if (action != null && action.equals("next") && caseNumber < iqCases.getCases().size()) {
//            caseNumber++;
//        } else if (action != null && action.equals("previous") && caseNumber > 0) {
//            caseNumber--;
//        }
//        
//
//        
//        if (caseNumber < iqCases.getCases().size()) {
//            //IQCase currentCase = iqCases.getCases().get(caseNumber);
//            IQCase currentCase = new IQCase();
//            currentCase.setCaseXml("");
//            request.setAttribute("caseHtml", currentCase.getCaseQuestionHtml(dataSource, null, ));
//            //request.setAttribute("tagGroups", iqCases.getTagGroupList());
//            request.setAttribute("case", currentCase);
//        } else {
//            //question does not exist.. or end of case series
//            request.setAttribute("caseHtml", "<div style=\"text-align: center; height: 400px; vertical-align: middle;\">End of case list</div>");
//        }
//        
//        request.getSession().setAttribute("caseNumber", caseNumber);
//        request.getSession().setAttribute("caseNumberTotal", iqCases.getCases().size());
//        return mapping.findForward("display");
//    }
    
    public ActionForward testCase(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String caseId = request.getParameter("caseid");
    	IQCase icase = dataSource.getSession().load(IQCase.class, Long.parseLong(caseId));
    	
    	System.out.println("call is made------------");
    	
    	if (icase == null) {
    		request.setAttribute("message", "No case found");
    		return explore(mapping, form, request, response);
    	} else {
	    	//make the quiz object from results
			IQUserQuiz quiz = new IQUserQuiz();
			IQUser iuser = (IQUser) request.getSession().getAttribute("security");
			quiz.setUser(iuser);
			quiz.setQuizName("testCase");
			quiz.getIncompleteCases().add(icase);
			quiz.getHelper().getIncompleteIds().add(icase.getCaseId());
			quiz.setDateStarted(Calendar.getInstance().getTime());
			quiz.setFixedQuestions(true);  //take questions from IncompleteCases variable
			quiz.setDoSave(false); //don't save the quiz, only practice transiently
			quiz.setAdminTestMode(true);
	
			request.getSession().setAttribute("userPracticeQuiz", quiz);
			request.getSession().setAttribute("userPracticeQuizExitUrl", "/exam/examfinished.jsp");
			request.getSession().setAttribute("userPracticeQuizFinishUrl", "/exam/examfinished.jsp");
			System.out.println("transition to practice.do------------");
			ActionRedirect ar = new ActionRedirect("/case/practice.do");
	    	//resetToken(request);
	    	//ar.addParameter(org.apache.struts.taglib.html.Constants.TOKEN_KEY, request.getSession().getAttribute(org.apache.struts.Globals.TRANSACTION_TOKEN_KEY));
	    	ar.addParameter("ignoreRefreshToken", true);
	    	return ar;
    	}
    }
    
    
    public ActionForward dashboard(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	return new Dashboard().unspecified(mapping, form, request, response);
    }
    
    public ActionForward dashboardCardiology(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
  	  
  	  return new Dashboard().dashboardCardiology(mapping, form, request, response);
    }
    
    
    public ActionForward setupQuiz(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	List<IQCaseTag> tags = dataSource.getExerciseByName("Public").get(0).getAssociatedCaseTags();
    	List<IQCaseTag> categories = new ArrayList();
    	List<IQCaseTag> difficultyLevels = new ArrayList();
    	for (IQCaseTag tag: tags) {
    		if (tag.getTagName().startsWith("Level")) {
    			difficultyLevels.add(tag);
    		} else {
    			categories.add(tag);
    		}
    	}
    	
    	String errorMessage = (String) request.getSession().getAttribute("errorMessage");
    	if (errorMessage != null) {
    		request.setAttribute("errorMessage", errorMessage);
    		request.getSession().removeAttribute("errorMessage");
    	}
    	request.setAttribute("availableCategories", categories);
    	request.setAttribute("availableDifficulties", difficultyLevels);
    	return new ActionForward("/case/quizsetup.jsp");
    }
    
    public ActionForward startQuiz(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String categoriesStrs = request.getParameter("selectedCategoriesVal");
    	categoriesStrs = categoriesStrs.replaceAll("\\((.*?)\\)", "");  // remove all (##) numbers from tags
    	String difficultiesStrs = request.getParameter("selectedDifficultiesVal");
    	difficultiesStrs = difficultiesStrs.replaceAll("\\((.*?)\\)", "");
    	Integer questionNumber = null;
    	try {
    		questionNumber = Integer.parseInt(request.getParameter("questionnumber"));
    	} catch (NumberFormatException nfe) {
    		request.getSession().setAttribute("errorMessage", "Unable to read number of questions specified");
    		return new ActionRedirect("/case/case.do");
    	}
    	
    	String[] categoriesStrArray = StringUtils.split(categoriesStrs, ",");
    	String[] difficultiesStrArray = StringUtils.split(difficultiesStrs, ",");
    	//String[] tagsStrArray = (String[]) ArrayUtils.addAll(categoriesStrArray, difficultiesStrArray);
    	List<IQCaseTag> tags = new ArrayList<IQCaseTag>();
    	LinkedHashSet<IQCase> relevantCases = new LinkedHashSet<IQCase>();
    	//----------------preparing categories and difficulty levels ------
    	List<IQCaseTag> difficulties = new ArrayList();
    	List<IQCaseTag> categories = new ArrayList();
    	
    	for (String tagStr: difficultiesStrArray) {
    		IQCaseTag curTag = dataSource.getTagByName(tagStr, "Public");
    		if (curTag == null) {
    			request.getSession().setAttribute("errorMessage", "Unable to read category '" + tagStr + "'");
    			return new ActionRedirect("/case/case.do");
    		}
    		difficulties.add(curTag);
    	}
    	for (String tagStr: categoriesStrArray) {
    		IQCaseTag curTag = dataSource.getTagByName(tagStr, "Public");
    		if (curTag == null) {
    			request.getSession().setAttribute("errorMessage", "Unable to read category '" + tagStr + "'");
    			return new ActionRedirect("/case/case.do");
    		}
    		categories.add(curTag);
    	}
    	
    	List<IQCase> categoriesList = dataSource.getCasesByTags(categories);
    	
    	
    	
    	
    	//WARNING: IF YOU ARE USING THIS METHOD, ADD CASE != ACTIVE
    	
    	
    	
    	
    	
    	
    	
    	List<IQCase> difficultiesList = dataSource.getCasesByTags(difficulties);
    	_log.info("found categories: " + categoriesList.size() + " difficultiesList " + difficultiesList.size());
    	//unfortunately i could not make an SQL query with hibernate that would do this :(
    	relevantCases.addAll(CaseUtil.returnCommonToBothLists(categoriesList, difficultiesList));
    	//relevantCases.addAll(dataSource.getCasesByTags(difficulties, categories));
    	_log.info("Found cases: " + relevantCases.size());
    	//----------------------
    	
    	//-------Preparing a random bank of cases-------
    	IQUser user = (IQUser) request.getSession().getAttribute("security");
    	List<IQCaseCompleted> userCompletedCases = dataSource.getUserById(user.getUserId()).getCompletedCases();
    	//remove completed cases from all relevant cases
    	relevantCases.removeAll(userCompletedCases);
    	
    	_log.info("relevant cases: " + relevantCases.size());
    	Integer relevantCaseSize = relevantCases.size();
    	if (relevantCaseSize == 0) {
    		request.getSession().setAttribute("errorMessage", "No ECGs matching search criteria");
    		ActionRedirect ar = new ActionRedirect("/case/case.do");
    		ar.addParameter("method", "setupQuiz");
    		return ar;
    	}
    	
    	
    	
    	//randomly select 
    	List<IQCase> selectedCases = new ArrayList();
    	List<IQCase> relevantCasesArray = new ArrayList();
    	relevantCasesArray.addAll(relevantCases);
    	Collections.shuffle(relevantCasesArray);
    	
    	for (int i=0; i< ((questionNumber.intValue()<relevantCasesArray.size())?questionNumber.intValue():relevantCasesArray.size()); i++) {
    		selectedCases.add(relevantCasesArray.get(i));
    	}

    	
    	IQUserQuiz newQuiz = new IQUserQuiz();
    	newQuiz.setDateStarted(Calendar.getInstance().getTime());
    	newQuiz.setDateLastActive(Calendar.getInstance().getTime());
    	newQuiz.setIncompleteCases(selectedCases);
    	request.getSession().setAttribute("quiz", newQuiz);
    	
    	request.setAttribute("questionNumberRequested", questionNumber);
    	request.setAttribute("questionNumberFound", relevantCasesArray.size());
    	request.setAttribute("questionNumberUsed", newQuiz.getIncompleteCases().size() + newQuiz.getCompletedCases().size());
    	request.setAttribute("categories", StringUtils.join(categoriesStrArray, ", "));
    	request.setAttribute("difficulties", StringUtils.join(difficultiesStrArray, ", "));
    	return new ActionForward("/case/quizintro.jsp");
    }
    
    
    
    public ActionForward resumeQuiz(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	Long quizId = Long.parseLong(request.getParameter("quizid"));
    	
    	ActionRedirect ar = new ActionRedirect("/case/case.do");
    	ar.addParameter("method", "quizNavigation");
    	
    	IQUserQuiz quiz = (IQUserQuiz) dataSource.get(IQUserQuiz.class, quizId);
    	//dataSource.evict(quiz);
    	request.getSession().setAttribute("quiz", quiz);
    	if (quiz.isCompleted()) {
    		//if completed case
    		ar.addParameter("startIndex", "0");
    	}
    	

    	return ar;
    }
    
    public ActionForward prepareAssessment(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examName = request.getParameter("examName");
    	IQUser iuser = (IQUser) request.getSession().getAttribute("security");
    	String reviewLastStr = (String) request.getParameter("reviewLast");
    	boolean reviewLast = reviewLastStr != null && reviewLastStr.equals("true");
    	Boolean portal = (Boolean) request.getSession().getAttribute("portal");
    	if (portal == null) portal = false;
    	
    	_log.debug("exam is started ------------" + examName);
    	
    	Query<IQExam> query = dataSource.getSession().createQuery("SELECT e FROM IQExam e WHERE e.examName=:examName AND e.deleted=0 ORDER BY e.examId DESC", IQExam.class).setParameter("examName", examName);
		List<IQExam> exams = query.getResultList();
		if (exams.size() != 1) {
			request.getSession().setAttribute("errorMessage", "This exercise is under construction. Exercises: " + exams.size());
			Dashboard dashboard = new Dashboard(this.dataSource);
			if (portal) return new ActionRedirect("/portalcomm.jsp");
			return dashboard.dashboardCardiology(mapping, form, request, response);
		} else {
			IQExam exam = exams.get(0);
			if (!exam.isActive()) {
				request.getSession().setAttribute("errorMessage", "This exercise has been temporarily disabled.  Please try again later");
				if (portal) return new ActionRedirect("/portalcomm.jsp");
				return dashboard(mapping, form, request, response);
			}
			//List<IQUserQuiz> quizzes = exam.getIncompleteUserQuizes(dataSource, iuser.getUserId());
			//List<IQUserQuiz> qList = exam.getAllUserQuizes(dataSource, user.getUserId());
			
			IQUserQuiz quiz = null;
			List<IQUserQuiz> pastQuizes = exam.getLastUserQuizes(dataSource, iuser.getUserId(), 1);
			_log.debug("found past quizzes: " + pastQuizes.size());
			if (pastQuizes.size() > 0) {
				IQUserQuiz lastQuiz = pastQuizes.get(0);
				if (!lastQuiz.isCompleted() && lastQuiz.hasTimeLeft()) {
					_log.debug("last quiz not completed and has time left");
					quiz = lastQuiz;
				} else {
					Long waitTimeLeft = exam.getTimeToRetry(lastQuiz);
					_log.debug("waitTimeLeft " + waitTimeLeft);
					if (waitTimeLeft != null) {
							Long hrsLeft = waitTimeLeft / (1000*60*60);
							Long minsLeft = (waitTimeLeft / (1000*60))%60;
							request.getSession().setAttribute("errorMessage", "You must wait an additional " + hrsLeft + " hours and " + minsLeft +" minutes before attempting this quiz again");
							if (portal) return new ActionRedirect("/portalcomm.jsp");
							else return new ActionRedirect("/case/dashboard.do?method=dashboardCardiology");
					}
					
				}
			}
			
			if (quiz == null) {
				_log.debug("Starting new quiz...");
				quiz = new IQUserQuiz();
					//no quiz exists - start a new one
				quiz.setUser(iuser);
				quiz.setQuizName(exam.getExamName());
					
				quiz.setDateStarted(Calendar.getInstance().getTime());
				quiz.setDateLastActive(Calendar.getInstance().getTime());
				quiz.setFixedQuestions(true); // dynamic number of questions	    	
					
				quiz.setAssociatedExam(exam);
				exam.getUserQuizes().add(quiz);
				
				List<Long> randomizedCasesArray = exam.getExercise().getActiveCasesIds(dataSource);
				
		    	if (exam.isOptionRandomOrder())
		    		Collections.shuffle(randomizedCasesArray);
		    	
		    	if (exam.getOptionMaxQuestions() != null
		    			&& exam.getOptionMaxQuestions().compareTo(BigDecimal.ZERO) > 0
		    			&& new BigDecimal(randomizedCasesArray.size()).compareTo(exam.getOptionMaxQuestions()) > 0) {
		    			randomizedCasesArray = randomizedCasesArray.subList(0, exam.getOptionMaxQuestions().intValue());
		    	}
		    	_log.debug("Set incomplete IDS: " + randomizedCasesArray.size());
		    	
		    	quiz.getHelper().setIncompleteIds(randomizedCasesArray);
		    					
				dataSource.getSession().saveOrUpdate(quiz);
				_log.debug("saved id: " + quiz.getQuizId());
				dataSource.getSession().flush();
				_log.debug("saved id: " + quiz.getQuizId());
			}
		
			request.getSession().setAttribute("exam", exam);
			request.getSession().setAttribute("userQuiz", quiz);
			if (portal) {
				request.getSession().removeAttribute("errorMessage");
				request.getSession().setAttribute("examExitURL", "/portalcomm.jsp");
			} else {
				request.getSession().setAttribute("examExitURL", "/case/dashboard.do?method=dashboardCardiology");
			}
	    	ActionRedirect ar = new ActionRedirect("/exam/exam.do");
	    	ar.addParameter("ignoreRefreshToken", true);
	    	ar.addParameter("method", "quizNavigation");
	    	return ar;
		}
			    
    }
    
    public ActionForward practice(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examName = request.getParameter("level");
    	IQUser user = (IQUser) request.getSession().getAttribute("security");
    	
    	System.out.println("practice is started ------------");
    	
    	Query<IQExam> query = dataSource.getSession().createQuery("SELECT e FROM IQExam e WHERE e.examName=:examName AND e.deleted=0 ORDER BY e.examId DESC", IQExam.class).setParameter("examName", examName);
		List<IQExam> exams = query.getResultList();
		if (exams.size() != 1) {
			request.getSession().setAttribute("errorMessage", "This exercise is under construction. Exercises: " + exams.size());
			return dashboard(mapping, form, request, response);
		} else {
			IQExam exam = exams.get(0);
			if (!exam.isActive()) {
				request.getSession().setAttribute("errorMessage", "This exercise has been temporarily disabled.  Please try again later");
				return dashboard(mapping, form, request, response);
			}
			List<IQUserQuiz> quizzes = exam.getIncompleteUserQuizes(dataSource, user.getUserId());
			IQUserQuiz quiz;
			if (quizzes.size() == 0) {
				//no quiz exists - start a new one
				quiz = new IQUserQuiz();
				IQUser iuser = (IQUser) request.getSession().getAttribute("security");
				quiz.setUser(iuser);
				quiz.setQuizName(exam.getExamName());
				
				quiz.setDateStarted(Calendar.getInstance().getTime());
				quiz.setFixedQuestions(false); // dynamic number of questions
				
				quiz.setAssociatedExam(exam);
				exam.getUserQuizes().add(quiz);
				dataSource.getSession().save(quiz);
			} else {
				//quiz found, continue
				quiz = quizzes.get(0);
			}
		
			request.getSession().setAttribute("userPracticeExam", exam);
			request.getSession().setAttribute("userPracticeQuiz", quiz);
			request.getSession().setAttribute("userPracticeQuizExitUrl", "/case/case.do");
	    	ActionRedirect ar = new ActionRedirect("/case/practice.do");
	    	//resetToken(request);
	    	//ar.addParameter(org.apache.struts.taglib.html.Constants.TOKEN_KEY, request.getSession().getAttribute(org.apache.struts.Globals.TRANSACTION_TOKEN_KEY));
	    	ar.addParameter("ignoreRefreshToken", true);
	    	return ar;
		}
    }
    
    
    public static HashMap<String, IQUserQuiz> getLastQuizForUnitAssessment(IQUser iuser, IQDataSource dataSource) {
    	HashMap<String,IQUserQuiz> hs = new HashMap<String, IQUserQuiz>();
    	//null = no record of doing practice set
    	//ID = last quiz ID
    	Query<String> query = dataSource.getSession().createQuery("SELECT DISTINCT e.examName FROM IQExam e JOIN e.userQuizes q JOIN q.user u WHERE u.userId=:userId", String.class)
    			.setParameter("userId", iuser.getUserId());
		List<String> examNames = query.getResultList();
		for (String examName: examNames) {
			System.out.println("level: " + examName);
			if (examName!= null && !examName.equals("")) {
				Query<IQUserQuiz> query2 = dataSource.getSession().createQuery("SELECT q FROM IQUserQuiz q JOIN q.associatedExam e JOIN q.user u WHERE e.examName=:examName AND u.userId=:userId ORDER BY q.dateStarted DESC", IQUserQuiz.class)
						.setParameter("examName", examName)
						.setParameter("userId", iuser.getUserId());
				List<IQUserQuiz> quizzes = query2.getResultList();
				if (quizzes.size() > 0) 
					hs.put(examName, quizzes.get(0));
			}
		}
		return hs;
    }
    
//    
//    public ActionForward quizNavigation(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
//    	_log.info("Starting navigation-------------------");
//    	String modeStr = (String) request.getParameter("mode");
//    	String timeTaken = request.getParameter("timespent");
//    	Boolean testMode = false;
//    	if (modeStr != null && IQExam.EXAM_MODE_TEST.equals(modeStr)) testMode = true;
//    	if (testMode == null) testMode = false;
//    	Boolean reviewMode = (Boolean) Boolean.parseBoolean((String) request.getParameter("reviewmode"));
//    	if (reviewMode == null) reviewMode = false;
//    	
//    	String startIndex = request.getParameter("startIndex");  // only useful for reviewing prev quizes (already complete)
//    	
//    	IQUser iuser = (IQUser) request.getSession().getAttribute("security");
//    	String action = request.getParameter("action");
//    	String caseId = request.getParameter("caseid");
//    	IQCase caseToDisplay = null;
//    	IQCaseCompleted caseToDisplayCompleted = null; //if available, can save having to fetch answers
//    	_log.info("Action: " + action);
//    	_log.info("caseId: " + caseId);
//    	IQUserQuiz quiz;
//    	if (testMode == false) {
//    		quiz = (IQUserQuiz) request.getSession().getAttribute("quiz");
//    		if (quiz.getQuizId() != null) {  // bind quiz to database (so we can lazily retrieve records) if it has been saved before.
//    			dataSource.update(quiz); //this if statement doesn't execute if person just started first question
//    		} 
//    	} else {
//    		// in test mode from admin, set up a trial case (fresh quiz with test case)
//    		quiz = new IQUserQuiz();
//    		if (!reviewMode) {
//    			IQCase testcase = dataSource.getCase(Long.parseLong(caseId));
//    			quiz.getIncompleteCases().add(testcase);
//    		}
//    	}
//    	
//    	
//    	int prevCaseIndex = -1;
//    	if (caseId == null || caseId.equals("")) {
//    		//just starting case (or returning to previous case)
//    		if (startIndex != null) {
//    			action = "back";
//    			prevCaseIndex = Integer.parseInt(startIndex) + 1;
//    			
//    		}
//    	} else {  //if caseID defined, (just finished a question)
//    		prevCaseIndex = quiz.getCaseIndexByIdFromCompleted(Long.parseLong(caseId), dataSource);
//    		if (prevCaseIndex == -1) {  //if not found in completed, then put to the end
//    			//starting new case (finshed another one, just submitted answers, not marked completed yet)
//    			//this is done as a safeguard, if last caseId passed is invalid (or not in completed cases) then assign last one
//    			prevCaseIndex = quiz.getCompletedCases().size();
//    		}
//    	}
//    	
//    	//this part will find the next case.
//    	if (action == null || action.equalsIgnoreCase("") || ((caseId == null || caseId.equals("")) && action == null)) {
//    		if (quiz.getIncompleteCases().size() == 0) {  //quiz is finished or empty
//    			quiz.setCompleted(true);
//    			dataSource.update(quiz);
//    			//dataSource.evict(quiz);
//    			request.setAttribute("totalQuestions", quiz.getCompletedCases().size());
//    			return new ActionForward("/case/quizend.jsp"); 
//    		}
//    		caseToDisplay = quiz.getIncompleteCases().get(0);
//    	} else if (action.equalsIgnoreCase("next")) {
//    		//find out if next case is unfinished:
//    		
//    		IQCaseBaseClass prevCase = quiz.getCaseByIdCompletedAndIncompleted(Long.parseLong(caseId), dataSource);
//    		_log.info("Prev case index: " + prevCaseIndex + " completed? " + prevCase.isCompleted());
//    		if (prevCaseIndex == quiz.getCompletedCases().size() && !prevCase.isCompleted()) { //if reviewing prev cases, and hit "next", and next case is incomplete
//    			//if just submitting new answer, next case will be reviewing this case
//    			//if just completed a case (did not start next case)
//
//    			IQCase lastCase = quiz.getCaseByIdFromIncompleted(Long.parseLong(caseId), dataSource);
//
//    			//_log.info("IN CASE THIS QUESTION HAS: " + lastCase.getQuestionList().size());
//    			//parse answers
//    			HashMap<String, String[]> answers = CaseUtil.parseAnswersToHashMap(request);
//    			
//    			CaseUtil caseUtil = new CaseUtil();
//    			CaseXMLParser caseXMLParser = new CaseXMLParser();
//    			IQCase lastCaseParsed = lastCase;
//    			if (!lastCase.isParsed())
//    				lastCaseParsed = caseXMLParser.parseCase(lastCase.getCaseXml(), lastCase, dataSource);
//    			IQCaseCompleted lastCaseCompleted = caseUtil.convertCaseToCompleted(lastCaseParsed, quiz, answers);
//    			if (timeTaken != null && !timeTaken.equals(""))
//    				lastCaseCompleted.setSecondsTaken(Long.parseLong(timeTaken)/1000);
//    			//dataSource.saveObject(lastCaseCompleted); will cascade, no need
//    			quiz.getCompletedCases().add(lastCaseCompleted);
//    			quiz.getIncompleteCases().remove(lastCase);
//    		
//    			quiz.setDateLastActive(Calendar.getInstance().getTime());
//    			quiz.setUser(dataSource.getUserById(iuser.getUserId()));
//    			
//    			caseToDisplayCompleted = lastCaseCompleted;
//    			
//	            //write to DB!
//    			if (!testMode) {
//		            if (quiz.getQuizId() == null) {  //new quiz, not yet known
//		            	dataSource.saveOrUpdate(quiz);
//		            	//dataSource.evict(quiz);   // don't want quiz to be attached and managed by hibernate (b/c storing in session)
//		            } else {
//		            	if (quiz.getIncompleteCases().size() == 0) { //if finished quiz
//		            		quiz.setCompleted(true);
//		            	}
//		            	dataSource.merge(quiz);  //quiz remains evicted, (this operation returns a managed entity, but I don't want it right now).
//		            }
//    			}
//            
//	            reviewMode = true;
//	            caseToDisplay = lastCase;
//
//    		} else if (prevCaseIndex == quiz.getCompletedCases().size()-1 && prevCase.isCompleted()) {
//    			//if last case, and just finished reviewing answer - load next incomplete answer
//    			if (quiz.getIncompleteCases().size() == 0) {
//    				request.setAttribute("totalQuestions", quiz.getCompletedCases().size());
//    				return new ActionForward("/case/quizend.jsp");
//    			}
//    			caseToDisplay = quiz.getIncompleteCases().get(0);
//    			caseToDisplayCompleted = null;
//    			reviewMode = false;
//    		} else if (prevCaseIndex < quiz.getCompletedCases().size()-1) {
//    			//just browsing around
//    			reviewMode = true;
//    			caseToDisplayCompleted = quiz.getCompletedCases().get(prevCaseIndex+1);
//    			caseToDisplay = caseToDisplayCompleted.getAssociatedCase();
//    			
//    		}
//    	} else if (action.equalsIgnoreCase("back")) {
//    		_log.info("reviewing old case " + prevCaseIndex + action);
//
//    		reviewMode = true;
//    		if (prevCaseIndex == -1) {
//    			caseToDisplay = (IQCase) quiz.getCompletedCases().get(quiz.getCompletedCases().size()-1).getAssociatedCase();
//    		} else if (prevCaseIndex == 0) {
//    			caseToDisplay = (IQCase) quiz.getCompletedCases().get(prevCaseIndex).getAssociatedCase();
//    		} else {
//    			caseToDisplay = (IQCase) quiz.getCompletedCases().get(prevCaseIndex-1).getAssociatedCase();
//    		}
//    	}
//    	//--------nextcase is generated out of all above code-------------------------
//        
//    	int caseIndex = 0;
//    	if (action == null || caseToDisplay.getCaseId() == null) {
//    		caseIndex = quiz.getCompletedCases().size() + ((reviewMode) ? 0 : 1);
//    	} else if (action.equals("back")) {
//    		caseIndex = quiz.getCaseIndexByIdFromCompleted(caseToDisplay.getCaseId(), dataSource)+1;
//    	} else if (action.equals("next")) {
//    		caseIndex = quiz.getCaseIndexByIdFromCompleted(caseToDisplay.getCaseId(), dataSource)+1;
//    		if (caseIndex == 0) 
//    			caseIndex = quiz.getCompletedCases().size()+1;  //new case, not in completed cases yet
//    		
//    	}
//    	
//    	
//        int totalCaseNumber =  quiz.getCompletedCases().size() + quiz.getIncompleteCases().size();
//        caseToDisplay = dataSource.getCase(caseToDisplay.getCaseId());//It just doesn't re-bind case otherwise (prev had dataSource.getSession().refresh(caseToDisplay), it wrote comments to DB, but disappeared when i get back (doesn't re-read the DB)
//        caseToDisplay.getComments().size(); // ensures that comments are loaded otherwise get 'lazyInitializationException'
//        Collections.sort(caseToDisplay.getComments(), Collections.reverseOrder()); //order by date
//    	request.setAttribute("gotoaction", "case.do");
//    	String quitURL = "/case/case.do";
//    	request.setAttribute("caseNumber", caseIndex);
//        request.setAttribute("caseNumberTotal", totalCaseNumber);
//    	return  displayCase(request, caseToDisplay, caseToDisplayCompleted, quiz,
//    			false, reviewMode, false, IQExam.getModeClass(modeStr), quitURL);
//    }
    
    public ActionForward displaySummary(HttpServletRequest request, IQExam.ExamMode mode, String quitURL) {
    	request.setAttribute("quiturl", quitURL);
        request.setAttribute("mode", mode);
        return new ActionForward("/case/quizsummary.jsp");
    }
    
    public ActionForward displayCase(HttpServletRequest request, IQCase icase, IQCaseCompleted icaseCompleted,
    		IQUserQuiz userQuiz, 
    		boolean lockAnswers, boolean showSolution, boolean showSummaryLink,
    		IQExam.ExamMode mode) throws Exception {
    	
    	boolean showHiddenComments = false;
    	boolean timeUser = false;

    	if (icase.getCaseText() == null || icase.getCaseText().equals("")) {
    		//if for some reason not parsed, try to parse (temporary, remove later)
    		CaseXMLParser caseXMLParser = new CaseXMLParser();
    		try {
    			icase = caseXMLParser.parseCase(icase.getCaseXml(), icase, dataSource); //all Questions generated from xml
    		} catch (CaseParseException cpe) {
    			icase.setCaseText("Error: Sorry, but this case has a problem, please click next");
    		}
    	}
    	if (!showSolution) { //display case in question mode
    		
    		String caseQuestionHtml = icase.getCaseQuestionHtml(dataSource, icaseCompleted, userQuiz);
    		String caseHtml;
    		
    		if (mode != null && mode.equals(IQExam.EXAM_MODE_CASEREVIEW)) { //review cases (show question + answer)
    			//create fake IQCasecompleted Object with no answer
    			IQCaseCompleted fakeCaseCompleted = new IQCaseCompleted();
    			fakeCaseCompleted.setAssociatedCase(icase);
    			String caseAnswerHtml = icase.getCaseAnswerHtml(dataSource, fakeCaseCompleted , userQuiz);
    			
    			caseHtml = CaseHtmlUtil.placeSeparators(caseQuestionHtml, caseAnswerHtml);
    			//caseHtml = CaseHtmlUtil.addCommentBoxOnTop(caseHtml);
    		} else {
    			caseHtml = caseQuestionHtml;
    			timeUser = true;
    		}
    		request.setAttribute("caseHtml", caseHtml);
    		configureSearchTerms(request, icase);
    	} else { //if display answer mode
    		if (icaseCompleted == null) {
    			//icaseCompleted is sometimes passed to avoid re-querrying the database
    			IQUser user = (IQUser) request.getSession().getAttribute("security");
    			icaseCompleted = dataSource.getCaseCompleted(icase.getCaseId(), user.getUserId(), userQuiz.getQuizId());
    		}
    		String caseQuestionHtml = icase.getCaseAnswerHtml(dataSource, icaseCompleted, userQuiz);
    		request.setAttribute("caseHtml", caseQuestionHtml);
    	}
    	//add ability to comment on the case in certain instances
    	if (showSolution == true || 
    			(mode != null && (
    			mode.equals(IQExam.EXAM_MODE_CASEREVIEW) ||  //modes that will show comment box
    			mode.equals(IQExam.EXAM_MODE_TEST) ||
    			mode.equals(IQExam.EXAM_MODE_CASEREVIEW)))) {
    		
    		if (mode != null && mode.equals(IQExam.EXAM_MODE_CASEREVIEW)) {
    			//if reviewing cases for correct answers, put comment box at the top
    			request.setAttribute("showTopCommentBox", true);
    		} else {
    			request.setAttribute("showBottomCommentBox", true);
    		}
    		
        	//allow privilages to see hidden comments and make new comments hidden
        	// in the future maybe consolidate the paragraph above into the one below to pick out privileges per mode
        	if (mode != null && (mode.equals(IQExam.EXAM_MODE_CASEREVIEW))) {
        		request.setAttribute("newCommentsPrivate", "true");
    			showHiddenComments = true;
        	} else if (mode != null && (mode.equals(IQExam.EXAM_MODE_TEST))) {
        		request.setAttribute("newCommentsPrivate", "true");
    			showHiddenComments = true;
        	}
    		
    		List<IQCaseComment> comments = icase.getComments();
    		Collections.sort(comments, Collections.reverseOrder()); //order by date
    		if (showHiddenComments == false) {
    			comments = IQCaseComment.removeHiddenComments(comments);
    		}
    		request.setAttribute("comments", comments);
    	}
    	
    	//determine if there is a timer
    	Long timeLeft = userQuiz.getTimeLeft();
    	_log.debug("Timeleft: " + timeLeft);
    	
    	
    	String quitURL = (String) request.getSession().getAttribute("examExitURL");
        if (quitURL == null || quitURL.equals("")) {
        	request.setAttribute("quiturl", "/");
        } else {
        	request.setAttribute("quiturl", quitURL);
        }
        
        IQUser iuser = (IQUser) request.getSession().getAttribute("security");
        if (iuser.getSessionMode() != null && iuser.getSessionMode().equals(IQUser.SESSION_MODE_RESEARCH)) {
        	quitURL = "/study/registration.jsp";
        }
    	
    	
    	request.getSession().setAttribute("lastLoadedCaseId", icase.getCaseId());
        request.setAttribute("mode", mode);
    	request.setAttribute("icase", icase);
    	request.setAttribute("showsolution", showSolution);
    	request.setAttribute("showSummaryLink", showSummaryLink);
    	request.setAttribute("lockanswers", lockAnswers);
    	request.setAttribute("timeLeft", timeLeft);
    	request.setAttribute("timeUser", timeUser);
    	return new ActionForward("/case/casedisplay.jsp");
    }
    
    public void configureSearchTerms(HttpServletRequest request, IQCase nextCaseParsed) throws CaseParseException {
    	//configure searchterms for "searchterms" question
    	HashMap<String, HashSet<String>> searchTermsQuestion = new HashMap();
    	
    	//if (!nextCaseParsed.isParsed()) {
    		//throw new CaseParseException("Case in configureSearchTerms() is not parsed");
    	//	request.setAttribute("searchGroups", searchTermsQuestion);
    	//	return;
    	//}
    	

    	List<IQQuestion> searchtermQuestions = nextCaseParsed.getQuestionsByType(IQQuestion.QUESTION_TYPE_SEARCHTERM);
        for (IQQuestion searchtermQuestion : searchtermQuestions) {
    		IQQuestionSearchTerm questionST = (IQQuestionSearchTerm) searchtermQuestion;
    		List<IQSearchTermGroup> searchGroupsForQuestion = questionST.getAvailableGroups();
    		HashSet<String> searchTermsForQuestion = new HashSet();  // avoids duplicates
    		for (IQSearchTermGroup searchGroupForQuestion: searchGroupsForQuestion) {
    			//IQSearchGroup foundSearchGroup = dataSource.getSearchGroupByName(searchGroupForQuestion);
    			//if (foundSearchGroup == null) throw new CaseParseException("Unable to find search group '" + searchGroupForQuestion + "'");
    			searchTermsForQuestion.addAll(searchGroupForQuestion.getSearchTermStrings(dataSource));
    		}
        	searchTermsQuestion.put(searchtermQuestion.getQuestionTextId().toString(), searchTermsForQuestion);
        }
        //gathered a list of all the searchterm groups
        request.setAttribute("searchGroups", searchTermsQuestion);
    }
    
    public ActionForward deleteQuiz(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	Long quizId = Long.parseLong(request.getParameter("quizid"));
    	IQUserQuiz quiz = (IQUserQuiz) dataSource.get(IQUserQuiz.class, quizId);
    	dataSource.delete(quiz);
    	return dashboard(mapping, form, request, response);
    }
    
    public ActionForward setupExam(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	//need to make the quiz object.
    	return null;
    }
    
  public ActionForward explore(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	
    	Long activeGroupId = (Long) request.getSession().getAttribute("activegroupid");
    	if (activeGroupId!= null) {
    		IQSearchTermGroup g = dataSource.getSession().get(IQSearchTermGroup.class, activeGroupId);
            if (g != null) {
            	request.setAttribute("selectedGroup", g);
            }
    	} else {
    		TypedQuery<IQSearchTermGroup> queryST =dataSource.getSession().createQuery("SELECT c FROM IQSearchTermGroup c", IQSearchTermGroup.class);
            List<IQSearchTermGroup> allGroups = queryST.getResultList();
            if (allGroups.size() > 0) 
            	request.setAttribute("selectedGroup", allGroups.get(0));
    	}
    	
        //List<IQSearchTermGroup> groups = dataSource.getSession().getCriteriaBuilder().createQuery(IQSearchTermGroup.class).getResultList();
        TypedQuery<IQSearchTermGroup> query =dataSource.getSession().createQuery("SELECT c FROM IQSearchTermGroup c", IQSearchTermGroup.class);
        List<IQSearchTermGroup> results = query.getResultList();
        
        TypedQuery<IQAnswerSearchTerm> queryST =dataSource.getSession().createQuery("SELECT c FROM IQAnswerSearchTerm c", IQAnswerSearchTerm.class);
        List<IQAnswerSearchTerm> allSTs = queryST.getResultList();
        
        request.setAttribute("searchGroups", results);
        request.setAttribute("availableSearchTerms", allSTs);
        return new ActionForward("/case/explore.jsp");
    }
  

  public ActionForward showSearchTerms(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
  	
  	Long questionId = Long.parseLong(request.getParameter("questionid"));
  	
    TypedQuery<IQSearchTermGroup> query =dataSource.getSession().createQuery("SELECT g FROM IQSearchTermGroup g JOIN g.associatedQuestions q WHERE q.questionId=:questionId", IQSearchTermGroup.class)
    		.setParameter("questionId", questionId);
    List<IQSearchTermGroup> groups = query.getResultList();
      
    request.setAttribute("groups", groups);
    return new ActionForward("/case/casedisplaysearchterms.jsp");
  }
    
    public ActionForward showGroup(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String selectedGroupId = request.getParameter("viewgroupid");
    	if (selectedGroupId != null) { 
    		request.getSession().setAttribute("activegroupid", Long.parseLong(selectedGroupId)); 
    		request.getSession().removeAttribute("orphanedSTs");
    	}
    	return explore(mapping, form, request, response);
    }
    
    public ActionForward exploreFindEcgs(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String selectedSTs = request.getParameter("selectedItems").trim();
    	String operator = request.getParameter("operator").trim();
    	
    	String exerciseName = "Public"; // only pull ECGs from public set
    	
    	String[] sts = selectedSTs.split("\\|");
    	List<IQCase> results = new ArrayList();
    	if (operator.equalsIgnoreCase("OR")) {
        	String hql = "SELECT c FROM IQCase c JOIN c.parentExercises e JOIN c.questionList q JOIN q.associatedAnswerLines l JOIN l.associatedAnswerWrappers w JOIN w.searchTerm st WHERE c.active=1 AND e.exerciseName=:exerciseName AND (";

	    	for (int i = 0; i< sts.length; i++) {
	    		String st = sts[i];
	    		hql = hql + "st.searchTermString=:st" + i;
	    		if (i != sts.length-1) {
	    			hql = hql + " OR ";
	    		}
	    	}
	    	hql = hql + ")";
	    	TypedQuery<IQCase> query = dataSource.getSession().createQuery(hql, IQCase.class);
	    	query.setParameter("exerciseName", exerciseName);
	    	for (int i = 0; i< sts.length; i++) {
	    		query.setParameter("st" + i, sts[i]);
	    	}
	    	results = query.getResultList();
    	} else if (operator.equalsIgnoreCase("AND")) {
    		String hql ="select c from IQCase c JOIN c.parentExercises e JOIN c.questionList q JOIN q.associatedAnswerLines l JOIN l.associatedAnswerWrappers w JOIN w.searchTerm st WHERE c.active=1 AND e.exerciseName=:exerciseName AND st.searchTermString=:st";
    		TypedQuery<IQCase> query = dataSource.getSession().createQuery(hql, IQCase.class);
	    	query.setParameter("exerciseName", exerciseName);
	    	query.setParameter("st", sts[0]);
	    	results = query.getResultList();
	    	
	    	for (int i = 1; i< sts.length; i++) {
	    		hql ="select c from IQCase c JOIN c.parentExercises e JOIN c.questionList q JOIN q.associatedAnswerLines l JOIN l.associatedAnswerWrappers w JOIN w.searchTerm st WHERE c.active=1 AND e.exerciseName=:exerciseName AND st.searchTermString=:st";
	    		query = dataSource.getSession().createQuery(hql, IQCase.class);
		    	query.setParameter("exerciseName", exerciseName);
		    	query.setParameter("st", sts[i]);
		    	
		    	//pick results contained in both lists
		    	List<IQCase> both = new ArrayList();
		    	for (IQCase c: query.getResultList()) {
		    		if (results.contains(c)) {
		    			both.add(c);
		    		}
		    	}
		    	results = both;
	    	}
	    	
	    	
    	}
    	
    	if (results.size() == 0) {
    		request.setAttribute("message", "No cases meeting the search criteria were found");
    		return explore(mapping, form, request, response);
    	} else {
	    	//make the quiz object from results
			IQUserQuiz quiz = new IQUserQuiz();
			IQUser iuser = (IQUser) request.getSession().getAttribute("security");
			quiz.setUser(iuser);
			quiz.setQuizName("explore");
			quiz.setIncompleteCases(results);
			for (IQCase result: results) {
				quiz.getHelper().getIncompleteIds().add(result.getCaseId());
			}
			quiz.setDateStarted(Calendar.getInstance().getTime());
			quiz.setFixedQuestions(true);  //take questions from IncompleteCases variable
			quiz.setDoSave(false); //don't save the quiz, only practice transiently
	
			request.getSession().setAttribute("userPracticeQuiz", quiz);
			request.getSession().setAttribute("userPracticeQuizExitUrl", "/case/case.do?method=explore");
			request.getSession().setAttribute("userPracticeQuizFinishUrl", "/case/exploreend.jsp");
	    	ActionRedirect ar = new ActionRedirect("/case/explorestart.jsp");
	    	ar.addParameter("questionNumber", results.size());
	    	return ar;
    	}
    	
    	
    }
    
}
