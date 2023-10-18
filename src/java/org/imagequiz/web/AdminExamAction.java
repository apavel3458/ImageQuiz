/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.web;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.InvocationTargetException;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionRedirect;
import org.apache.struts.actions.DispatchAction;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQExam;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserAchievement;
import org.imagequiz.model.user.IQUserGroup;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.util.ActionSecurity;
import org.imagequiz.util.ExamUtil;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;

/**
 *
 * @author apavel
 */
public class AdminExamAction extends DispatchAction {
    protected static Log _log = LogFactory.getLog(AdminAction.class);
        
    protected IQDataSource dataSource;
    
    public void setIQDataSource(IQDataSource value) {
        dataSource = value;
      }
    
    private Gson getGson() {
    	return new GsonBuilder()
    			   .excludeFieldsWithoutExposeAnnotation()
    		       .serializeNulls()
    		       .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
    		       .create();
    }
    
    public AdminExamAction() {
    }
    
    @Override
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
	
        return null;
    }
    
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException {
    	ActionSecurity actionSecurity = new ActionSecurity();
    	return actionSecurity.filter(mapping, form, request, response, this);
    }
    
    public ActionForward addExam(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examName = request.getParameter("examname");
    	String exerciseId = request.getParameter("exercise");
    	String userGroupId = request.getParameter("usergroup");
    	
    	if (exerciseId.equals(""))
    		throw new Exception("Exercise ID is Not selected!!!");
    	
    	IQExam iexam = new IQExam();
    	iexam.setExamName(examName);
    	iexam.setUniqueCode(ExamUtil.generateExamCode());
    	iexam.setExercise(dataSource.getExercise(Long.parseLong(exerciseId)));
    	if (userGroupId != null && !userGroupId.equals(""))
    		iexam.setUserGroup(dataSource.getUserGroupById(Long.parseLong(userGroupId)));
    	
    	dataSource.saveObject(iexam);
    	
    	ActionRedirect redirect = new ActionRedirect("admin.do");
    	return redirect;
    }
    
    public ActionForward deleteExam(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examId = request.getParameter("id");
    	
    
    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
    	iexam.setDeleted(true);
    	dataSource.saveObject(iexam);

    	
    	ActionRedirect redirect = new ActionRedirect("admin.do");
    	return redirect;
    }
    
    public ActionForward openCloseExam(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examId = request.getParameter("id");
    	String action = request.getParameter("action");
    
    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
    	if (action.equals("open")) {
    		iexam.setActive(true);
    	} else if (action.equals("close")) {
    		iexam.setActive(false);
    	}
    	dataSource.saveObject(iexam);

    	
    	ActionRedirect redirect = new ActionRedirect("admin.do");
    	return redirect;
    }
    
    
    public ActionForward setExamMode(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examId = request.getParameter("id");
    	String examMode = request.getParameter("exammode");
    
    	if (examMode != null && !examMode.equals("")) {
	    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
	    	iexam.setExamMode(examMode);
	    	dataSource.saveObject(iexam);
    	}

    	
    	ActionRedirect redirect = new ActionRedirect("admin.do");
    	return redirect;
    }
//    
//    public ActionForward setExamOrder(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
//    	String examId = request.getParameter("id");
//    	String randomorder = request.getParameter("randomorder");
//    
//    	if (randomorder != null && !randomorder.equals("")) {
//	    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
//	    	if (randomorder.equals("true")) {
//	    		iexam.setRandomOrder(true);
//	    	} else if (randomorder.equals("false")) {
//	    		iexam.setRandomOrder(false);
//	    	}
//	    	dataSource.saveObject(iexam);
//    	}
//
//    	
//    	ActionRedirect redirect = new ActionRedirect("admin.do");
//    	return redirect;
//    }
    
    
//    public ActionForward setExamAllowReview(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
//    	String examId = request.getParameter("id");
//    	String allowreview = request.getParameter("allowReview");
//    
//    	if (allowreview != null && !allowreview.equals("")) {
//	    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
//	    	if (allowreview.equals("true")) {
//	    		iexam.setAllowReview(true);
//	    	} else if (allowreview.equals("false")) {
//	    		iexam.setAllowReview(false);
//	    	}
//	    	dataSource.saveObject(iexam);
//    	}
//
//    	
//    	ActionRedirect redirect = new ActionRedirect("admin.do");
//    	return redirect;
//    }
//    
//    public ActionForward setExamShowGrade(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
//    	String examId = request.getParameter("id");
//    	String showgrade = request.getParameter("showGrade");
//    
//    	if (showgrade != null && !showgrade.equals("")) {
//	    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
//	    	if (showgrade.equals("true")) {
//	    		iexam.setShowGrade(true);
//	    	} else if (showgrade.equals("false")) {
//	    		iexam.setShowGrade(false);
//	    	}
//	    	dataSource.saveObject(iexam);
//    	}
//
//    	
//    	ActionRedirect redirect = new ActionRedirect("admin.do");
//    	return redirect;
//    }
    
//    public String displayExamOption(String key, IQExam iexam) {
//    	String result = "";
//    	if (key != null && !key.equals("")) {
//    		result = iexam.getOptionsMap(key);
//    		//if (result == null)
//    	}
//    	return result;
//    }
    
    public ActionForward getExamOptionsAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	JsonObject jsonObject = new JsonObject();
    	try {
    	String examId = (String) request.getParameter("examid");
    	    	
    	
    	List<IQUserAchievement> achievements = dataSource.getAllAchievements();
    	
    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
    	
    	HashMap<String, Object> reply = new HashMap();
    	reply.put("options", iexam.getOptionsJson());
    	reply.put("achievements", achievements);
    	
    	response.getWriter().print(this.getGson().toJson(reply));
    	response.getWriter().flush();
    	
    	} catch (Exception e) {
    		e.printStackTrace();
    		jsonObject.addProperty("success", false);
    		jsonObject.addProperty("errorMessage", e.getMessage());
    	}
    
    	response.getWriter().flush();
    	return null;
    }
    
    public ActionForward setExamOptionsAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	JsonObject jsonObject = new JsonObject();
    	try {
    	String examId = (String) request.getParameter("examid");
    	String examName = (String) request.getParameter("examname");
    	String optionsJson = (String) request.getParameter("options");
    	
    	_log.debug("Options sent: " + optionsJson);
    	
    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
    	
    	iexam.setExamName(examName);
    	iexam.setOptionsJson(optionsJson);
    	iexam.setExamMode(iexam.getOptionsMap().get("mode").toString());
    	
    	//find and set achievement.
    	Object achievementIdStr = (String) iexam.getOptionsMap().get("achievement");
    	_log.debug("FOUND STR: " + achievementIdStr);
    	_log.debug("FOUND LEN: " + iexam.getOptionsMap().size());
    	if (achievementIdStr != null && !achievementIdStr.toString().equals("")) {
    		IQUserAchievement a = dataSource.getSession().load(IQUserAchievement.class, achievementIdStr.toString());
    		if (a == null) throw new Exception("Unable to find achievement");
    		_log.debug("Setting achievement: " + a.getAchievementId());
    		iexam.setAchievements(a);
    	}
    		
    	    	
    	jsonObject.addProperty("success", true);
    	dataSource.saveOrUpdate(iexam);
    	} catch (Exception e) {
    		e.printStackTrace();
    		jsonObject.addProperty("success", false);
    		jsonObject.addProperty("errorMessage", e.getMessage());
    	}
    	
    	    	
    	String json = new Gson().toJson(jsonObject);
    	response.getWriter().print(json);
		response.getWriter().flush();
    
    	return null;
    }
    
    public ActionForward clearAnswers(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examId = request.getParameter("id");
    
    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
    	for (IQUserQuiz uq: iexam.getUserQuizes()) {
    		dataSource.delete(uq);
    	}
    	dataSource.saveObject(iexam);

    	
    	ActionRedirect redirect = new ActionRedirect("admin.do");
    	return redirect;
    }
    
    
    public ActionForward getLoginCodes(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examId = request.getParameter("examid");
    	ExamUtil.checkUserIdEncoder(); //checks encoder to make sure keys are good (can only do it once at some point)
    	
    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
    	if (iexam.getUniqueCode() == null || iexam.getUniqueCode().equals(""))
    		iexam.setUniqueCode(ExamUtil.generateExamCode());
    	dataSource.flush();
    	
    	IQUserGroup igroup = iexam.getUserGroup();
    	List<IQUser> iusers = igroup.getUsers();
    	Collections.sort(iusers, IQUser.byLastName);
    	
    	//will send back this hash map with keys
    	LinkedHashMap<IQUser, String> userAccessCodeMap = new LinkedHashMap();
    	
    	for (IQUser iuser: iusers) {
    		String key = ExamUtil.generateUserAccessKey(iuser.getUserId(), iexam.getUniqueCode());
    		userAccessCodeMap.put(iuser, key);
    	}
    	
    	request.setAttribute("userAccessCodeMap", userAccessCodeMap);
    	request.setAttribute("genericExamAccessCode", iexam.getUniqueCode());
    	request.setAttribute("exam", iexam);
    	return new ActionForward("/admin/useraccesscodes.jsp");
    }
    
    public ActionForward generateAccessCodes(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String examId = request.getParameter("examid");
    	IQExam iexam = dataSource.getExamById(Long.parseLong(examId));
    	iexam.setUniqueCode(ExamUtil.generateExamCode());
    	dataSource.saveOrUpdate(iexam);
    	ActionRedirect redirect = new ActionRedirect("/admin/exam.do");
    	redirect.addParameter("examid", examId);
    	redirect.addParameter("method", "getLoginCodes");
    	return redirect;
    }
    
    //--------Below are methods to generate unique exam ID
  
    
    //--------Below are methods to generate unique character representation of person's ID

    //--------ABOVE are classes to generate unique character representation of person's ID

}
