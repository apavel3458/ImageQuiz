/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.web;

import java.lang.reflect.InvocationTargetException;
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
import org.imagequiz.model.question.IQAnswerSearchTermLine;
import org.imagequiz.model.question.IQAnswerSearchTermWrapper;
import org.imagequiz.model.question.IQQuestion;
import org.imagequiz.model.question.IQQuestionChoice;
import org.imagequiz.model.question.IQQuestionSearchTerm;
import org.imagequiz.model.question.IQSearchTermGroup;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.util.ActionSecurity;
import org.imagequiz.util.CaseHtmlUtil;
import org.imagequiz.util.CaseParseException;
import org.imagequiz.util.CaseUtil;
import org.imagequiz.util.CaseXMLParser;
import org.imagequiz.util.JsonUtil;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import org.apache.struts.Globals;
import org.apache.struts.taglib.html.Constants;

/**
 *
 * @author apavel
 */
public class AdminCaseAction extends DispatchAction {
	private static Logger _log = Logger.getLogger(AdminCaseAction.class);

    
    protected IQDataSource dataSource;
    
    public void setIQDataSource(IQDataSource value) {
        dataSource = value;
      }
    
    private Gson getCaseGson() {
    	GsonBuilder builder = new GsonBuilder();
    	builder.registerTypeAdapter(IQQuestion.class, new JsonUtil.IQQuestionDeserializer());
    	builder.registerTypeAdapter(IQQuestion.class, new JsonUtil.IQQuestionSerializer());
    	// builder.registerTypeAdapter(IQQuestionSearchTerm.class, new JsonUtil.IQQuestionChoiceDeserializer());
        Gson gson = builder.excludeFieldsWithoutExposeAnnotation()
        	       .serializeNulls()
        	       .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
        	       .create();
        return gson;
    }
    
    @Override
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        return null;
    }
    
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException {
    	ActionSecurity actionSecurity = new ActionSecurity();
    	return actionSecurity.filter(mapping, form, request, response, this);
    }
    
        
    public AdminCaseAction() {
    }
    
    
    public ActionForward viewCaseAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String caseId = request.getParameter("caseid");
    	String exerciseId = request.getParameter("exerciseid");
    	String editor = request.getParameter("editor");
    	String returnJson = "{\"error\": \"Unable to get case\"}";
    	_log.debug("editing case");
    	
    	IQCase icase = dataSource.getCase(Long.parseLong(caseId));
    	
    	if (editor.equals("mcq")) {
    		for (IQQuestion question: icase.getQuestionList()) { 
    			if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_CHOICE)) {
	    			IQQuestionChoice questionChoice = (IQQuestionChoice) question;
	    			questionChoice.getAssociatedChoices().size(); 
    			} else if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_SEARCHTERM) || question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_SEARCHTERM_SETS)) {
    				_log.debug("Debug loeading searchterm");
    				IQQuestionSearchTerm q = (IQQuestionSearchTerm) question;
//	    			if (q.getAssociatedAnswerLines().size() > 0) {
//	    				for (IQAnswerSearchTermLine l: q.getAssociatedAnswerLines()) {
//	    					for (IQAnswerSearchTermWrapper w: l.getAssociatedAnswerWrappers()) {
//	    						w.getSearchTerm().getSearchTermString();
//	    					}
//	    				}
//	    			}
    			}
    		}
    		returnJson = this.getCaseGson().toJson(icase);
    	}
    	response.setCharacterEncoding("UTF-8");
    	response.getWriter().print(returnJson);
    	response.getWriter().flush();
    	return null;
    }
    
    public ActionForward saveCaseAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String caseId = request.getParameter("caseid");
    	String exerciseId = request.getParameter("exerciseid");
    	String editor = request.getParameter("editor");
    	String returnJson = "{\"error\": \"Unable to get case\"}";
    	String payload = request.getParameter("payload");
//    	_log.debug("editing case");
    	    	
    	IQCase icase = dataSource.getCase(Long.parseLong(caseId));
    	IQCase ncase = this.getCaseGson().fromJson(payload, IQCase.class);
//    	_log.debug("editing case2");
    	
    	// _log.debug("DESERIALIZED: " + ncase.getQuestionList().size());
    	
    	CaseUtil caseUtil = new CaseUtil();
    	caseUtil.updateRevisionHistory(request, dataSource, icase, 
    			icase.getCaseText() + icase.getCaseAnswerText(), 
    			ncase.getCaseText() + ncase.getCaseAnswerText());  //update revision hx before new caseXml is set
    	
    	dataSource.getSession().evict(icase);
		dataSource.getSession().clear();
		
		icase.setCaseName(ncase.getCaseName());
		
    	if (editor.equals("mcq")) {
    		icase.addJsonProps(ncase, dataSource);
    	}
    	
		dataSource.getSession().merge(icase);  // cannot get this to update IDs
		dataSource.getSession().clear();
		
		IQCase updatedIcase = dataSource.getSession().find(IQCase.class, icase.getCaseId());  // just reload the whole thing
		
		returnJson = this.getCaseGson().toJson(updatedIcase);
//		_log.debug(returnJson);
		dataSource.getSession().close();
		
    	response.setCharacterEncoding("UTF-8");
    	response.getWriter().print(returnJson);
    	response.getWriter().flush();
    	return null;
    }
    
    public ActionForward reviewCommentAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String commentIdStr = request.getParameter("commentid");
    	IQUser iuser = (IQUser) request.getSession().getAttribute("security");
    	Long commentId = Long.parseLong(commentIdStr);
    	IQCaseComment comment = dataSource.getSession().find(IQCaseComment.class, commentId);
    	comment.setReviewed(!comment.isReviewed());
    	if (comment.isReviewed()) {
    		comment.setReviewedAt(new Date());
    		comment.setReviewedBy(iuser);
    	}
    	dataSource.getSession().save(comment);
    	response.setCharacterEncoding("UTF-8");
    	response.getWriter().print(this.getCaseGson().toJson(comment));
    	response.getWriter().flush();
    	return null;
    }
    
}
