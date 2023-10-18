package org.imagequiz.web;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import javax.persistence.TypedQuery;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionRedirect;
import org.apache.struts.actions.DispatchAction;

import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQCaseTag;
import org.imagequiz.model.IQExam;
import org.imagequiz.model.IQExercise;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.model.user.IQUserQuizHelper;
import org.imagequiz.model.user.IQUserQuizHelper.TwoIds;
import org.imagequiz.util.CaseUtil;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

public class PracticeAction extends DispatchAction {
	private static Logger _log = Logger.getLogger(CaseAction.class);

    
    protected IQDataSource dataSource;
    
    public void setIQDataSource(IQDataSource value) {
        dataSource = value;
      }
    
    private Gson getGson() {
        Gson gson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation()
        	       .serializeNulls()
        	       .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
        	       .create();
        return gson;
    }
    
    @Override
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        return quizNavigation(mapping, form, request, response);
    }
    
        
    public PracticeAction() {
    }
    public PracticeAction(IQDataSource dataSource) {
    	this.setIQDataSource(dataSource);
    }
    
    public ActionForward quizNavigation(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	
    	//TODO GET RID OF getCaseIndexByIdFromCompleted, PASS ID INTO QUESTION
    	String action = request.getParameter("action");
    	String caseId = request.getParameter("caseid");
    	String timeTaken = request.getParameter("timespent");
    	String commentStr = request.getParameter("q-CaseReviewComments");
    	
    	if (request.getAttribute("userPracticeQuizFinishUrl") == null) {
    		
    	}
    	
    	//are "incomplete cases" loaded?  if not, should acquire them in a fancy way
    	
    	_log.debug("ACTION: " + action);
    	
    	IQUserQuiz userQuizSession = (IQUserQuiz) request.getSession().getAttribute("userPracticeQuiz");
    	//IQExam examSession = (IQExam) request.getSession().getAttribute("userPracticeExam");  // IF NEEDED!!
    	IQUserQuizHelper helper;// = new IQUserQuizHelper(userQuizSession); //for now, we will fill later
    	if (userQuizSession == null) return new ActionRedirect("/case/case.do"); // if for whatever reason there is no userQuiz in session (such as if you log out)
    	IQUserQuiz userQuiz;
    	if (userQuizSession.isDoSave()) {
    		userQuiz = dataSource.getUserQuizById(userQuizSession.getQuizId());
    		helper = userQuiz.getHelper();
    	} else {
    		userQuiz = userQuizSession;
    		helper = userQuiz.getHelper();
    	}

    	Integer completedCaseCount = helper.getCompletedIds().size();

    	Integer lastCaseIndex;
    	Integer displayCaseIndex;
    	
    	IQUser iuser = (IQUser) request.getSession().getAttribute("security");

    	IQCaseCompleted nextCaseCompleted = null; //if reviewing case
    	IQCase nextCase = null;
		IQCase lastCase = null;
		//find case that just got submitted
		if (caseId != null && !caseId.equals("")) {
			TwoIds lastCaseCompletedId = helper.getCompletedIdByCaseId(Long.parseLong(caseId));
			if (lastCaseCompletedId != null) { //TODO: THIS CAN BE SIMPLIFIED
				lastCase = dataSource.getCase(lastCaseCompletedId.caseId);
			} else {
				lastCase = dataSource.getCase(Long.parseLong(caseId));
			}
			//set index of case that was just submitted
			lastCaseIndex = helper.getCompletedIndexByCaseId(Long.parseLong(caseId));
			if (lastCaseIndex == -1) { //when click next to see solutions (hasn't saved it yet)
				lastCaseIndex = helper.getCompletedIds().size();
			}
		} else {
			lastCaseIndex = helper.getCompletedIds().size();
		}
		displayCaseIndex = lastCaseIndex;
		
    	boolean doNotProcess = false;
    	//avoid refresh reprocessing
    	//ignoreRefreshToken = set at beginning of the quiz
    	boolean ignoreRefreshToken = (request.getParameter("ignoreRefreshToken") != null && request.getParameter("ignoreRefreshToken").equalsIgnoreCase("true"))?true:false;
    	if (isTokenValid(request) || ignoreRefreshToken) {
    		//NOT resumission of form
    		resetToken(request);
    	} else {
    		//form resubmitted i.e. user hit refresh()
    		System.out.println("Page Resubmit");
    		doNotProcess = true; 
    	}
    	
    	//determine which question to load next:  (by the end of this IF-else tree, there should 
    	//be either nextcasecompleted or nextcase
    	if (doNotProcess) {
    		//page resubmit
    		Long lastLoadedCaseId = (Long) request.getSession().getAttribute("lastLoadedCaseId");
			TwoIds completedId = helper.getCompletedIdByCaseId(lastLoadedCaseId);
					
			if (completedId == null) {
				nextCase = getNextCase(request, userQuiz, lastLoadedCaseId, helper);
			} else {
				nextCaseCompleted = dataSource.getCompeletedCaseById(completedId.completedCaseId);
			}
    	} else if (action == null) {
    		nextCase = getNextCase(request, userQuiz, null, helper);
    	} else if (action.equalsIgnoreCase("next")) {
    		//Find index of question in array
    		boolean caseAlreadyCompleted = helper.hasCompletedIdByCaseId(Long.parseLong(caseId));
    		//if last case in completed (save answers)
    		if (!caseAlreadyCompleted) { //completing now
    			//save case, and load new case
    			lastCase = dataSource.getCase(Long.parseLong(caseId));

				HashMap<String, String[]> answers = CaseUtil.parseAnswersToHashMap(request);
    			CaseUtil caseUtil = new CaseUtil();

    			IQCaseCompleted lastCaseCompleted = caseUtil.convertCaseToCompleted(lastCase, userQuiz, answers, dataSource);
    				//dataSource.saveObject(lastCaseCompleted); will cascade, no need
    			if (timeTaken != null && !timeTaken.equals("")) {
    				lastCaseCompleted.setSecondsTaken(Long.parseLong(timeTaken)/1000);
    			}
    			userQuiz.getCompletedCases().add(lastCaseCompleted);
    			//put helper below datasource execution
    			if (userQuiz.isFixedQuestions())
    				helper.getIncompleteIds().remove(lastCase.getCaseId());
    		
    			userQuiz.setDateLastActive(Calendar.getInstance().getTime());
    			
    			//save to DB
    			if (userQuiz.isDoSave()) {
    				userQuiz.setUser(dataSource.getUserById(iuser.getUserId()));
		            if (userQuiz.getQuizId() == null) {  //new quiz, not yet known
		            	dataSource.saveOrUpdate(userQuiz);
		            	dataSource.evict(userQuiz);   // don't want quiz to be attached and managed by hibernate (b/c storing in session)
		            } else {
		            	dataSource.merge(userQuiz);  //quiz remains evicted, (this operation returns a managed entity, but I don't want it right now).
		            }
    			}
    			helper.getCompletedIds().add(helper.new TwoIds(lastCaseCompleted.getCaseId(), lastCaseCompleted.getCompletedCaseId()));
    			
    			
	            nextCaseCompleted = lastCaseCompleted; //practice mode only

    		} else if (lastCaseIndex == (completedCaseCount-1)) {
    			//navitaging to first new question
    			//if it's the last question then current question needs to be saved (see block of code above)
    			_log.debug("Getting next question");
    			nextCase = getNextCase(request, userQuiz, null, helper);
    			if (nextCase == null) {
	            	userQuiz.setCompleted(true);
	            	if (userQuiz.isDoSave())
	            		dataSource.merge(userQuiz);
	            	return completedPractice(request, response, helper);
    			}
    			displayCaseIndex++;
    		} else {
    			//just navigating deep in prevous questions
    			//load old case
    			int nextIndex = lastCaseIndex+1;
    			nextCaseCompleted = dataSource.getCompeletedCaseById(helper.getCompletedIds().get(nextIndex).completedCaseId);
    			displayCaseIndex++;
    		}
    	} else if (action.equalsIgnoreCase("back")) {
    		int requestIndex = lastCaseIndex - 1;
    		
    		if (requestIndex < 0) requestIndex = 0;
    		nextCaseCompleted = userQuiz.getCompletedCases().get(requestIndex);
    		displayCaseIndex = requestIndex;
    	}
    	
    	
    	//process any submitted comments
    	if (commentStr != null && !commentStr.equals("") && lastCase != null) {
    		CaseUtil.saveSubmittedComment(dataSource, iuser, lastCase, commentStr);
    	}
    	
    	boolean lockAnswers = false;
    	boolean displaySolution = false;
    	if (nextCaseCompleted != null) {
    		nextCase = nextCaseCompleted.getAssociatedCase();
    		lockAnswers = true;
    		displaySolution = true;
    		//set answers in case viewing a completed case
    		request.setAttribute("caseCompleted", nextCaseCompleted);
    	}
    	if (userQuiz.isDoSave()) {
    		dataSource.saveOrUpdate(helper);
    		dataSource.evict(userQuiz);
    	}
    	
    	_log.debug("CASE INDEX: " + displayCaseIndex);
    	saveToken(request);
    	request.setAttribute("gotoaction", "practice.do");
    	request.setAttribute("examservlet", true);
    	request.setAttribute("caseNumber", displayCaseIndex+1);
    	if (request.getAttribute("caseNumberPossible") == null) getNextCase(request, userQuiz, null, helper);

    	CaseAction ca = new CaseAction();
    	ca.setIQDataSource(dataSource);
    	System.out.println("quizNavigation EXIT: " + iuser.getEmail());
    	if (nextCase == null) {
    		//no more questions (usually quiz finishes above, but if quiz finished on start, it comes here)
            userQuiz.setCompleted(true);
            if (userQuiz.isDoSave())
            	dataSource.merge(userQuiz);    		
            return completedPractice(request, response, helper);
    	}
    	String quitURL = (String) request.getSession().getAttribute("userPracticeQuizExitUrl");
    	request.getSession().setAttribute("userPracticeQuiz", userQuiz);
        
    	IQExam.ExamMode mode;
    	if (userQuiz.isAdminTestMode())   mode = IQExam.EXAM_MODE_TEST;
    	else                          mode = IQExam.EXAM_MODE_PRACTICE;
    		
    	
    	return  ca.displayCase(request, nextCase, nextCaseCompleted, userQuiz,
    			lockAnswers, displaySolution, false, mode);
    }
    
    private ActionForward completedPractice(HttpServletRequest request, HttpServletResponse response, IQUserQuizHelper helper) throws Exception {
    	request.setAttribute("totalQuestions", helper.getCompletedIds().size());
    	String finishUrl = (String) request.getSession().getAttribute("userPracticeQuizFinishUrl");
    	IQUserQuiz userQuizSession = (IQUserQuiz) request.getSession().getAttribute("userPracticeQuiz");
    	if (finishUrl != null) {
    		return new ActionForward(finishUrl);
    	} else {
    		if (userQuizSession.getAssociatedExam().isOptionShowGrade() || userQuizSession.getAssociatedExam().isAllowReviewForQuiz(userQuizSession.getPass())) {
    			return quizSummary(request, response, userQuizSession, "/");
    		} else {
    			return new ActionForward("/case/practiceend.jsp");
    		}
    	}
    }
    
    public ActionForward quizSummary(HttpServletRequest request, HttpServletResponse response, IQUserQuiz userQuiz, String quitURL) throws Exception {
        _log.debug("Exiting Exam, case mode: " + userQuiz.getAssociatedExam().getExamMode());
        _log.debug("Exam Pass?: " + userQuiz.getPass());
        if (userQuiz.getAssociatedExam().getExamModeClass().equals(IQExam.EXAM_MODE_CASEREVIEW)) {
        	request.setAttribute("questionNumber", userQuiz.getHelper().getCompletedIds().size());
        	return new ActionForward("/exam/examfinishedcasereview.jsp");
        }
        
    	request.setAttribute("quiz", userQuiz);
    	//userQuizSession.getCompletedCases().get(1).
    	_log.debug("SIZE: " + userQuiz.getCompletedCases().size());
    	if (userQuiz.getAssociatedExam().isOptionShowGrade()) {
        	request.setAttribute("totalPass", userQuiz.getPass());
        	request.setAttribute("totalScore", userQuiz.getScore());
        	request.setAttribute("totalPassScore", userQuiz.getPassScore());
        	request.setAttribute("totalGrade", userQuiz.calcTotalGrade());
        	request.setAttribute("passGrade", userQuiz.getAssociatedExam().getOptionPassGrade());
//        	_log.debug("Total PASS: " + userQuiz.getPass());
//        	_log.debug("Total SCORE: " + userQuiz.getScore());
//        	_log.debug("Total PASSSCORE: " + userQuiz.getPassScore());
//        	_log.debug("Total TOTAL GRADE: " + userQuiz.calcTotalGrade());
        	
        	//---set categories (tags)
        	request.setAttribute("categories", userQuiz.getPerformance());
        	
        	//List<IQCaseTag> tags = userQuiz.getTagsOfCompletedQuestions(dataSource);
        	List<IQCaseTag> tags = userQuiz.getPerformanceTags(dataSource);
     	    for (IQCaseTag t: tags) {
			   t.prepareForGson(dataSource, true, true);
     	    }
        	request.setAttribute("categoriesJson", getGson().toJson(tags));
    	}
    	
    	String exitURL = (String) request.getSession().getAttribute("examExitURL");
        if (exitURL == null) {
        	request.setAttribute("quiturl", "/");
        } else {
        	request.setAttribute("quiturl", exitURL);
        }

    	request.setAttribute("iexam", userQuiz.getAssociatedExam());
    	_log.debug("IS ALLOW REVIEW TEST: " + userQuiz.getAssociatedExam().isAllowReviewForQuiz(userQuiz.getPass()));
    	return new ActionForward("/case/quizsummary.jsp");
    }
    
    private IQCase getNextCase(HttpServletRequest request, IQUserQuiz userQuiz, Long caseIdpreferred, IQUserQuizHelper helper) {
    	
    	//first, are there incompletecases to load from?
    	if (!userQuiz.isFixedQuestions()) {
	    	IQExercise exercise = dataSource.getExerciseByName(userQuiz.getQuizName()).get(0);
	    	
            TypedQuery<IQCase> query2 =dataSource.getSession().createQuery("SELECT c FROM IQCase c JOIN c.parentExercises e WHERE c.active=1 AND e.exerciseName=:eid AND c.caseId NOT IN "
            		+ "(SELECT ccc.caseId FROM IQUserQuiz q JOIN q.completedCases cc JOIN cc.associatedCase ccc WHERE q.quizId=:quizid)", IQCase.class)
	    			.setParameter("eid", userQuiz.getQuizName())
	    			.setParameter("quizid", userQuiz.getQuizId());
            
            List<IQCase> newCases = query2.getResultList();

            request.setAttribute("caseNumberPossible", newCases.size() + helper.getCompletedIds().size());
            
            _log.debug("FOUND RESULTS: " +  newCases.size());

	    	if (newCases.size() == 0) {
	    		//completed all
	    		return null;
	    	} else {
	    		if (caseIdpreferred != null) {
	    			for (IQCase c: newCases) {
	    				if (c.getCaseId().equals(caseIdpreferred))
	    					return c;
	    			}
	    			return null;
	    		} else {
	    			
	    			Collections.shuffle(newCases);
	    			return newCases.get(0);
	    			
	    		}
	    	}
    	} else {
    		//THERE EXISTS INCOMPLETE CASES, SO JUST LOAD FROM THEM
    		IQCase nextCase;
    		if (helper.getIncompleteIds().size() == 0) {
    			request.setAttribute("caseNumberTotal", helper.getCompletedIds().size());
    			return null;
    		} else {
    			if (caseIdpreferred != null) {
    				nextCase = dataSource.getCase(caseIdpreferred);
    						//userQuiz.getCaseByIdFromIncompleted(caseIdpreferred, dataSource);
    			} else {
    				System.out.println("returning proper case");
    				Long nextCaseId = helper.getIncompleteIds().get(0);
    				nextCase = dataSource.getCase(nextCaseId);
    			}
    			request.setAttribute("caseNumberTotal", helper.getIncompleteIds().size()+helper.getCompletedIds().size());
    		}
    		//reattach the object to the session without updating database;
    		//dataSource.getSession().buildLockRequest(LockOptions.NONE).lock(nextCase);
    		return nextCase;
    	}
    }

}
