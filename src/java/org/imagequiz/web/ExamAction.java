package org.imagequiz.web;

import java.io.Reader;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.List;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.hibernate.query.Query;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQCaseBaseClass;
import org.imagequiz.model.IQCaseComment;
import org.imagequiz.model.IQExam;
import org.imagequiz.model.IQSetting;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserAchievement;
import org.imagequiz.model.user.IQUserQuestionAnswered;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.model.user.IQUserQuizHelper;
import org.imagequiz.model.user.IQUserQuizHelper.TwoIds;
import org.imagequiz.util.CaseUtil;
import org.imagequiz.util.CaseXMLParser;

public class ExamAction extends DispatchAction {
    protected static Log _log = LogFactory.getLog(CaseAction.class);
    
    protected IQDataSource dataSource;
    
    public void setIQDataSource(IQDataSource value) {
        dataSource = value;
      }
    
    @Override
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        return null;
    }
    
        
    public ExamAction() {
    }

    public ActionForward prepareExam(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	IQUser user = (IQUser) request.getSession().getAttribute("security");
    	//System.out.println("PREPARE EXAM: " + user.getEmail());
    	IQExam exam = (IQExam) request.getSession().getAttribute("exam");
    	exam = dataSource.getExamById(exam.getExamId());
    	
    	IQUserQuiz userQuiz = null;
    	//has user already started exam?
    	//dataSource.getUserById(user.getUserId());
    	//dataSource.getSession().refresh(user);
    	
    	ActionForward finishURL = new ActionForward("/");
    	
        if (user.getSessionMode() != null && user.getSessionMode().equals(IQUser.SESSION_MODE_RESEARCH)) {
        	Boolean researchPart2 = (Boolean) request.getSession().getAttribute("researchPart2");
        	if (researchPart2 != null && researchPart2) //part 2 is done
        		finishURL = new ActionForward("/exam/examresearchfinished.jsp");
        	else ///part 1 is done
        		finishURL = new ActionForward("/exam/examfinishedresearch.jsp");
        } else {
        	finishURL = new ActionForward("/exam/examfinished.jsp");
        }
    	
    	
    	List<IQUserQuiz> qList = exam.getAllUserQuizes(dataSource, user.getUserId());

    	if (qList.size() > 0) {
    		userQuiz = qList.get(0);
    		request.setAttribute("questionNumber", userQuiz.getHelper().getCompletedIds().size() + userQuiz.getHelper().getIncompleteIds().size());
    		request.setAttribute("completedQuestions", userQuiz.getHelper().getCompletedIds().size());
    		request.getSession().setAttribute("userQuiz", userQuiz);
    		if (userQuiz.isCompleted()) {
    			return new PracticeAction(dataSource).quizSummary(request, response, userQuiz, "/");
    		} else {
	    		//resume
	    		request.setAttribute("resumeQuiz", true);
	        	request.setAttribute("completedQuestions", userQuiz.getHelper().getCompletedIds().size());
    		}
    	} else {
    	//make new quiz and randomize 
	    	List<Long> randomizedCasesArray = exam.getExercise().getActiveCasesIds(dataSource);
	    	if (exam.isOptionRandomOrder())
	    		Collections.shuffle(randomizedCasesArray);
	    	
	    	userQuiz = new IQUserQuiz();
	    	userQuiz.setDateStarted(Calendar.getInstance().getTime());
	    	userQuiz.setDateLastActive(Calendar.getInstance().getTime());
	    	userQuiz.getHelper().setIncompleteIds(randomizedCasesArray);
	    	
	    	//userQuiz.getIncompleteCases().addAll(randomizedCasesArray);
	    	//userQuiz.setIncompleteCases(randomizedCasesArray); -intersetingly this will cause "multiple references to same instance" exception
	    	userQuiz.setAssociatedExam(exam);
	    	exam.getUserQuizes().add(userQuiz);
	    	userQuiz.setUser(user);
	    	dataSource.saveObject(userQuiz);
	    	request.getSession().setAttribute("userQuiz", userQuiz);
    	}
    	
    	saveToken(request);
    	request.setAttribute("questionNumber", userQuiz.getHelper().getCompletedIds().size() + userQuiz.getHelper().getIncompleteIds().size());
		request.setAttribute("completedQuestions", userQuiz.getHelper().getCompletedIds().size());
    	if (exam.getExamModeClass().equals(exam.EXAM_MODE_CASEREVIEW)) 
    		request.setAttribute("caseReview", true);
    	else 
    		request.setAttribute("caseReview", false);
    	if (user.getSessionMode() != null && user.getSessionMode().equals(IQUser.SESSION_MODE_RESEARCH))
    		return new ActionForward("/exam/examintroresearch.jsp");
    	return new ActionForward("/exam/examintro.jsp");	
    }
    
    
    public ActionForward quizNavigation(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String action = request.getParameter("action");
    	String caseIdStr = request.getParameter("caseid");
    	String reviewCaseIdString = request.getParameter("reviewcaseid"); //if jumping to case (after quiz is done and reviewing)
    	
    	Long reviewCaseId = null;
    	if (reviewCaseIdString != null) reviewCaseId = Long.parseLong(reviewCaseIdString);
    	
    	Long caseId = null;
    	if (caseIdStr != null) {
        	caseId = Long.parseLong(caseIdStr);
    	}
    	
    	String commentStr = request.getParameter("q-CaseReviewComments");
    	
    	_log.debug("ACTION IS: " + action);
    	
    	IQUserQuiz userQuizSession = (IQUserQuiz) request.getSession().getAttribute("userQuiz");
    	IQUserQuiz userQuiz = dataSource.getUserQuizById(userQuizSession.getQuizId());
    	IQUserQuizHelper helper = userQuiz.getHelper();
    	
    	IQUser iuser = (IQUser) request.getSession().getAttribute("security");
    	//System.out.println("quizNavigation ENTRACE: " + iuser.getEmail());
    	IQExam exam = (IQExam) request.getSession().getAttribute("exam");
    	
    	
    	if (!userQuiz.hasTimeLeft() && !userQuiz.isCompleted()) { //will skip if timeLeft not set or still has time
    		if (caseId != null) {
	    		IQCase icase = dataSource.getCase(caseId);
	    		this.saveAnswers(request, userQuiz, icase, iuser);
    		}
    		return markAndFinishExam(request, response, userQuiz, iuser);
    	}
    	
    	if (userQuiz.isCompleted() && !exam.isAllowReviewForQuiz(userQuiz.getPass())) { //will skip if timeLeft not set or still has time
    		return finishExam(request, response, userQuiz, iuser);
    	}
    	
    	
    	
    	IQCaseCompleted nextCaseCompleted = null; //if reviewing case
    	IQCase nextCase = null;
		IQCase lastCase = null;
		
		if (caseId != null && !caseId.equals("")) {
			lastCase = dataSource.getCase(caseId);
		}
    	boolean doNotProcess = false;
    	boolean ignoreRefreshToken = (request.getParameter("ignoreRefreshToken") != null && request.getParameter("ignoreRefreshToken").equalsIgnoreCase("true"))?true:false;
    	
    	if (isTokenValid(request) || ignoreRefreshToken) {
    		//for some jumping into reviewing a case triggers refresh, so added reviewCaseId part
    		//NOT resubmission of form
    		resetToken(request);
    	} else {
    		//form resubmitted i.e. user hit refresh()
    		System.out.println("Page Resubmit");
    		doNotProcess = true; 
    	}
    	
    	//determine which question to load next:  (by the end of this IF-else tree, there should 
    	//be either nextcasecompleted or casecompleted
    	if (doNotProcess) {
    		//if refresh is hit
    		_log.debug("REFRESH IS HIT - doNotProcess");
    		Long lastLoadedCaseId = (Long) request.getSession().getAttribute("lastLoadedCaseId");
    		if (lastLoadedCaseId == null) {
    			//go to summary page
    			return finishExam(request, response, userQuiz, iuser);
    		}
    		
			TwoIds completedId = helper.getCompletedIdByCaseId(lastLoadedCaseId);
					
			if (completedId == null) {
				nextCase = dataSource.getCase(lastLoadedCaseId);
				_log.debug("NEXT CASE INCOMPLETE");
			} else {
				nextCaseCompleted = dataSource.getCompeletedCaseById(completedId.completedCaseId);
				_log.debug("NEXT CASE COMPLETED");
			}
    		

			
    	} else if (action == null) {
    		_log.debug("ACTION IS NULL ---- getting nextCase");
    		if (userQuiz.isCompleted() && userQuiz.getAssociatedExam().isAllowReviewForQuiz(userQuiz.getPass())) {
    			//jumping into reviewing case
    	    	//if completed and reviewing cases (assuming it's allowed)
    			if (reviewCaseId == null)
    				reviewCaseId = helper.getCompletedIds().get(0).completedCaseId;
    			nextCaseCompleted = dataSource.getCompeletedCaseById(reviewCaseId);
    		} else {
    			//not reviewing cases (just usual diving into quiz)
    			nextCase = getNextCase(userQuiz);
    		}
    	} else if (action.equalsIgnoreCase("summary")) {
    		return new PracticeAction(dataSource).quizSummary(request, response, userQuiz, "/");
    	} else if (action.equalsIgnoreCase("next")) {
    		//Find index of question in array
    		//int caseCompletedIndex = userQuiz.getCaseIndexByIdFromCompleted(caseId, dataSource);
    		int caseCompletedIndex = helper.getCompletedIndexByCaseId(caseId);
    		System.out.println("CaseCompletdIndex: " + caseCompletedIndex);
    		//if last case in completed (save answers)
    		if (caseCompletedIndex == -1) {
    			//save case, and load new question

    			lastCase = dataSource.getCase(caseId);
    			userQuiz.getCompletedCases().size(); // I don't know why it has to be here, but somehow if you don't do this, it adds the first case into caseCompleted twice!
    			
    			IQCaseCompleted lastCaseCompleted = this.saveAnswers(request, userQuiz, lastCase, iuser);
    			
    			_log.debug("Cases Completed so far: " + userQuiz.getCompletedCases().size());
    			
    			//save to DB
//	            if (userQuiz.getQuizId() == null) {  //new quiz, not yet known
//	            	dataSource.saveOrUpdate(userQuiz);
//	            	dataSource.evict(userQuiz);   // don't want quiz to be attached and managed by hibernate (b/c storing in session)
//	            } else {
//	            	dataSource.merge(userQuiz);  //quiz remains evicted, (this operation returns a managed entity, but I don't want it right now).
//	            }
    			
            	if (exam.getExamModeClass().equals(exam.EXAM_MODE_PRACTICE)) {
            		nextCaseCompleted = lastCaseCompleted;
            	} else {
            		nextCase = getNextCase(userQuiz);
        			if (nextCase == null) return markAndFinishExam(request, response, userQuiz, iuser);
            	}
    		} else if (caseCompletedIndex == (helper.getCompletedIds().size()-1)) {
    			_log.debug("NEXT: last completed case");
    			//navitaging to first new question
    			//if it's the last question then current question needs to be saved (see block of code above)
    			if (exam.getExamModeClass().equals(IQExam.EXAM_MODE_EXAM) && !userQuiz.isCompleted()) {
    				this.saveAnswers(request, userQuiz, lastCase, iuser);
    			}
    			
    			
            		nextCase = getNextCase(userQuiz);
        			if (nextCase == null) return markAndFinishExam(request, response, userQuiz, iuser);
    		} else {
    			//just navigating deep in prevous questions
    			//load old case
    			//int questionIndex = userQuiz.getCaseIndexByIdFromCompleted(Long.parseLong(caseId) ,dataSource);
    			_log.debug("NEXT: deep completed case");
    			if (exam.getExamModeClass().equals(IQExam.EXAM_MODE_EXAM) && !userQuiz.isCompleted()) {
    				this.saveAnswers(request, userQuiz, lastCase, iuser);
    			}
    			
    			int questionIndex = helper.getCompletedIndexByCaseId(caseId);
    			int nextIndex = questionIndex+1;
    			TwoIds nextIndexIds = helper.getCompletedIds().get(nextIndex);
    			nextCaseCompleted = userQuiz.getCompletedCases().get(nextIndex);
    			nextCaseCompleted = dataSource.getCompeletedCaseById(nextIndexIds.completedCaseId);
    		}
    	} else if (action.equalsIgnoreCase("back")) {
			if (exam.getExamModeClass().equals(IQExam.EXAM_MODE_EXAM) && !userQuiz.isCompleted()) {
				this.saveAnswers(request, userQuiz, lastCase, iuser);
			}
    		//int currentIndex = userQuiz.getCaseIndexByIdFromCompleted(Long.parseLong(caseId), dataSource);
    		int currentIndex = helper.getCompletedIndexByCaseId(caseId);
    		if (currentIndex == -1) currentIndex = helper.getCompletedIds().size();
    		int requestIndex = currentIndex;
    		
    		if (currentIndex != 0) requestIndex = requestIndex - 1;
    		if (requestIndex < 0) requestIndex = 0;
    		TwoIds nextIndexIds = helper.getCompletedIds().get(requestIndex);
    		nextCaseCompleted = dataSource.getCompeletedCaseById(nextIndexIds.completedCaseId);
    	}
    	
    	int displayTotalCaseNumber = helper.getCompletedIds().size() + helper.getIncompleteIds().size();
    	int displayCaseIndex = helper.getCompletedIds().size()+1;
    	
    	//process any submitted comments
    	
    	//System.out.println("PROCESSING COMMENT: " + commentStr);
    	if (commentStr != null && !commentStr.equals("") && lastCase != null) {
    		CaseUtil.saveSubmittedComment(dataSource, iuser, lastCase, commentStr);
    	}
    	
    	boolean lockAnswers = false;
    	boolean displaySolution = false;
    	if (nextCaseCompleted != null) {
    		nextCase = nextCaseCompleted.getAssociatedCase();
    		lockAnswers = true;
    		if (exam.getExamModeClass() != null && exam.getExamModeClass().equals(IQExam.EXAM_MODE_PRACTICE) || 
    				(userQuiz.isCompleted() && userQuiz.getAssociatedExam().isAllowReviewForQuiz(userQuiz.getPass())))
    			displaySolution = true;
    		//displayCaseIndex = userQuiz.getCaseIndexByIdFromCompleted(nextCaseCompleted.getCaseId(), dataSource)+1;
    		displayCaseIndex = helper.getCompletedIndexByCaseId(nextCaseCompleted.getCaseId())+1;
    		//set answers in case viewing a completed case
    		request.setAttribute("caseCompleted", nextCaseCompleted);
    	}
    	//dataSource.evict(userQuiz);
    	
    	
    	saveToken(request);
    	request.setAttribute("gotoaction", "exam.do");
    	request.setAttribute("examservlet", true);

    	CaseAction ca = new CaseAction();
    	ca.setIQDataSource(dataSource);
    	System.out.println("quizNavigation EXIT: " + iuser.getEmail());
    	request.setAttribute("caseNumber", displayCaseIndex);
        request.setAttribute("caseNumberTotal", displayTotalCaseNumber);
        
        boolean showSummaryLink = false;
        if (userQuiz.isCompleted() 
        		&& userQuiz.getAssociatedExam().isAllowReviewForQuiz(userQuiz.getPass())) {
        	showSummaryLink = true;
        }
        
        
        _log.debug("Cases Completed so far in the end: " + userQuiz.getCompletedCases().size());
    	return  ca.displayCase(request, nextCase, nextCaseCompleted, userQuiz,
    			lockAnswers, displaySolution, showSummaryLink, IQExam.getModeClass(exam.getExamMode()));
    }
    
    private IQCaseCompleted saveAnswers(HttpServletRequest request, IQUserQuiz userQuiz, IQCase icase, IQUser iuser) {
    	String timeTakenStr = request.getParameter("timespent");
    	Long timeTaken = null;
    	try { timeTaken = Long.parseLong(timeTakenStr); } catch (NumberFormatException nfe) { }
    	
    	_log.debug("Saving Answers.  Time spent: " + timeTaken);
    	
		HashMap<String, String[]> answers = CaseUtil.parseAnswersToHashMap(request);
//		for (Entry entry: answers.entrySet()) {
//			_log.debug(entry.getKey() + "| " + StringUtils.join((String[]) entry.getValue(), ","));
//		}
		CaseUtil caseUtil = new CaseUtil();
		
		int caseCompletedIndex = userQuiz.getHelper().getCompletedIndexByCaseId(icase.getCaseId());
		IQCaseCompleted caseCompleted = null;
		if (caseCompletedIndex != -1) {
			caseCompleted = userQuiz.getCompletedCases().get(caseCompletedIndex);
		}
		caseCompleted = caseUtil.convertCaseToCompleted(icase, userQuiz, answers, dataSource, caseCompleted);
		Long timeTakenOld = caseCompleted.getSecondsTaken();
		
		_log.debug("old time taken: " + timeTakenOld);
			//dataSource.saveObject(lastCaseCompleted); will cascade, no need
		if (timeTaken != null) {
			timeTaken = timeTaken / 1000;
			if (timeTakenOld != null) timeTaken = timeTaken + timeTakenOld;
			_log.debug("final time taken: " + timeTaken);
			caseCompleted.setSecondsTaken(timeTaken);
		}
		userQuiz.setDateLastActive(Calendar.getInstance().getTime());
		if (userQuiz.getUser() == null || userQuiz.getUser().getUserId() != iuser.getUserId()) 
			userQuiz.setUser(dataSource.getUserById(iuser.getUserId()));
		
		dataSource.getSession().saveOrUpdate(caseCompleted); //must be done so that helper can have the ID
		
		IQUserQuizHelper helper = userQuiz.getHelper();
		if (!helper.hasCompletedIdByCaseId(icase.getCaseId())) {
			helper.getCompletedIds().add(
        		helper.new TwoIds(icase.getCaseId(), caseCompleted.getCompletedCaseId())
        		);
			userQuiz.getCompletedCases().add(caseCompleted);
		}
		if (helper.hasIncompleteIdByCaseId(icase.getCaseId())) {
			helper.getIncompleteIds().remove(icase.getCaseId());
		}
		
		
		dataSource.getSession().saveOrUpdate(helper);
		
		_log.debug("case ID is: " + caseCompleted.getCaseId());
		_log.debug("completed ID is: " + caseCompleted.getCompletedCaseId());
		//_log.debug("Answer is: " + caseCompleted.getAnsweredQuestions().get(0).getUserSelections().get(0).getAnswer());
		
		return caseCompleted;
    }
    
    private IQCase getNextCase(IQUserQuiz userQuiz) throws Exception{
    	//if finishined exam
    	IQUserQuizHelper helper = userQuiz.getHelper();
    	if (helper.getIncompleteIds().size() == 0) { //generally should never happen, caught in quizNavigagion earlier (left for safety)
        	//finished exam
        	//userQuiz = markAndCloseQuiz(dataSource, userQuiz, ); // DON'T HAVE IUSER, IF NEEDED. 
        	dataSource.saveObject(userQuiz);
        	return null;
        } else {
        	//not finished
        	Long nextId = helper.getIncompleteIds().get(0);
        	return dataSource.getCase(nextId);
        }
    }
    
    protected IQUserQuiz markAndCloseQuiz(HttpServletRequest request, IQDataSource dataSource, IQUserQuiz quiz, IQUser user) throws Exception {
    	_log.debug("FINISHED QUIZ... MARKING....");
    	if (!quiz.isCompleted()) {
    		_log.debug("MARKING....");
    		quiz.calcMarkQuiz(dataSource);
    		_log.debug("MARKED...." + quiz.getScore());
    		quiz.setCompleted(true);
    		if (quiz.getHelper().getIncompleteIds().size() <= 0)
    			quiz.setCompletedAllQuestions(true);
    		if (quiz.getPass()) {
    			_log.debug("PASSED!!!! associating achievement...");
    			IQUserAchievement a = quiz.getAssociatedExam().getAchievements();
    			IQUser iuser = dataSource.getUserById(user.getUserId());
    			if (!iuser.getAchievements().contains(a)) {
    				iuser.getAchievements().add(a);
    				a.getAssociatedUsers().add(iuser);
    				dataSource.getSession().update(iuser);
    				dataSource.getSession().update(a);
    				UserAction ua = new UserAction();
    				ua.setIQDataSource(dataSource);
    				ua.acceptUser(request, iuser);
    			}
    		}	
    	}
    	return quiz;
    }
    
    public ActionForward markAndFinishExam(HttpServletRequest request, HttpServletResponse response, IQUserQuiz userQuiz, IQUser iuser) throws Exception {
    	userQuiz = this.markAndCloseQuiz(request, dataSource, userQuiz, iuser);
    	userQuiz.setCompleted(true);
    	dataSource.getSession().saveOrUpdate(userQuiz);
    	return finishExam(request, response, userQuiz, iuser);
    }
    
    public ActionForward finishExam(HttpServletRequest request, HttpServletResponse response, IQUserQuiz userQuiz, IQUser iuser) throws Exception {
    	request.setAttribute("questionNumber", userQuiz.getHelper().getCompletedIds().size());
    	String finishURL = "/";
    	_log.debug("finishExam called");
    	request.getSession().removeAttribute("lastLoadedCaseId");
        if (iuser.getSessionMode() != null && iuser.getSessionMode().equals(IQUser.SESSION_MODE_RESEARCH)) {
        	Boolean researchPart2 = (Boolean) request.getSession().getAttribute("researchPart2");
        	if (researchPart2 != null && researchPart2) //part 2 is done
        		finishURL = "/exam/examresearchfinished.jsp";
        	else ///part 1 is done
        		finishURL = "/exam/examfinishedresearch.jsp";
        	return new ActionForward(finishURL);
        }
        return new PracticeAction(dataSource).quizSummary(request, response, userQuiz, "/");
        
    }
    
    public ActionForward addComment(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String caseId = request.getParameter("caseId");
    	String commentStr = request.getParameter("comment");
    	String privateComment = request.getParameter("privateComment");
    	IQCase icase = dataSource.getCase(Long.parseLong(caseId));
    	IQUser user = (IQUser) request.getSession().getAttribute("security");
    	
    	IQCaseComment comment = new IQCaseComment();
    	comment.setText(commentStr);
    	comment.setAssociatedCase(icase);
    	comment.setUser(user);
    	if (privateComment != null && privateComment.equals("true"))
    		comment.setHidden(true);
    	dataSource.saveObject(comment);
    	
    	List<IQCaseComment> comments = icase.getComments();
    	SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd yyyy, HH:mm");
    	
    	/* if I ever want to return all comments to update the entire list, for now they have to refresh
    	for (IQCaseComment icomment: comments) {
    		response.getWriter().println(icomment.getUser().getFirstName() + "|"+ icomment.getUser().getFirstName() + 
    				"|" + dateFormat.format(icomment.getCreatedDateTime()) + 
    				"|" + icomment.getText());
    	}*/
    	response.getWriter().println(comment.getUser().getFirstName() + "|"+ comment.getUser().getLastName() + 
				"|" + dateFormat.format(comment.getCreatedDateTime()) + 
				"|" + comment.getText());
    	
    	response.getWriter().flush();
    	response.getWriter().close();
    	return null;
    }
    
    //proxy this b/c /case.do is off limits
    public ActionForward showSearchTerms(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
	    CaseAction caseAction = new CaseAction();
	    caseAction.setIQDataSource(dataSource);
	    return caseAction.showSearchTerms(mapping, form, request, response);
    }
    
}
