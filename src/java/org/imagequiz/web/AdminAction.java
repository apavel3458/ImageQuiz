/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.web;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionRedirect;
import org.apache.struts.actions.DispatchAction;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.dao.IQDataSourceJDBC;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQCaseComment;
import org.imagequiz.model.IQCaseTag;
import org.imagequiz.model.IQExercise;
import org.imagequiz.model.IQReference;
import org.imagequiz.model.IQSetting;
import org.imagequiz.model.caseutil.IQAuthor;
import org.imagequiz.model.caseutil.IQCaseObjective;
import org.imagequiz.model.caseutil.IQCaseRevision;
import org.imagequiz.model.question.IQAnswer;
import org.imagequiz.model.question.IQAnswerChoice;
import org.imagequiz.model.question.IQAnswerSearchTerm;
import org.imagequiz.model.question.IQAnswerSearchTermWrapper;
import org.imagequiz.model.question.IQCaseAnswer;
import org.imagequiz.model.question.IQQuestion;
import org.imagequiz.model.question.IQQuestionChoice;
import org.imagequiz.model.question.IQSearchTermGroup;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQPermission;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserGroup;
import org.imagequiz.model.user.IQUserQuestionAnswered;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.model.user.IQUserQuizHelper;
import org.imagequiz.properties.ImageQuizProperties;
import org.imagequiz.util.ActionSecurity;
import org.imagequiz.util.CaseUtil;
import org.imagequiz.util.CaseXMLParser;
import org.imagequiz.util.SessionCounterListener;
import org.imagequiz.util.JsonUtil;
import org.json.JSONObject;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;



/**
 *
 * @author apavel
 */
public class AdminAction extends DispatchAction {
	private static Logger _log = Logger.getLogger(AdminAction.class);
	
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
    
    public AdminAction() {
    }
    
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        return list(mapping, form, request, response);
    }
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException {
    	ActionSecurity actionSecurity = new ActionSecurity();
    	return actionSecurity.filter(mapping, form, request, response, this);
    	//    	String methodName = request.getParameter("method");
//    	if (methodName == null) methodName = "unspecified";
//    	
//    	String exerciseid = request.getParameter("exerciseid");
//    	String[] allowedMethods = new String[] {
//				  "unspecified"
//				  };
//    	if (exerciseid == null) exerciseid = request.getParameter("exerciseId");
//    	
//    	
//    	
//    	_log.debug("access method is: " + methodName);
//    	IQUser iuser = (IQUser) request.getSession().getAttribute("security");
//    	boolean permitted = false;
//    	if (iuser.isManagerCases()) permitted = true;
//    	else {
//    		if (exerciseid != null) {
//	    		Long exerciseId = Long.parseLong(exerciseid);
//	    		permitted = iuser.hasPermission("exercise", exerciseId);
//    		} else {
//    			for (String allowedMethod: allowedMethods) {
//    				if (allowedMethod.equals(methodName)) permitted = true;
//    			}
//    		}
//    	}
//    	if (!permitted) {
//    		request.getSession().setAttribute("message", "You lack permissions to access this page");
//			return new ActionRedirect("../login.jsp");
//    	}
//    	
//    	try {
//    		Method foundMethod = AdminAction.class.getMethod(methodName, ActionMapping.class, ActionForm.class, HttpServletRequest.class, HttpServletResponse.class);
//    		return (ActionForward) foundMethod.invoke(this, mapping, form, request, response);
//    	} catch (NoSuchMethodException e) {
//    		return (ActionForward) AdminAction.class.getMethod("unspecified", ActionMapping.class, ActionForm.class, HttpServletRequest.class, HttpServletResponse.class)
//    				.invoke(this,  mapping, form, request, response); }
    }
    
    public ActionForward list(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	IQUser user = (IQUser) request.getSession().getAttribute("security");
    	
//    	List<IQExercise> exerciseList = dataSource.getActiveExerciseList();
//        _log.info("found exercises: " + exerciseList.size());
    	String exerciseQuery = "FROM IQExercise e WHERE e.active=true ";
    	if (!user.isManagerSite()) exerciseQuery = exerciseQuery + "AND e.exerciseId IN (SELECT p.itemId FROM IQPermission p JOIN p.user u WHERE u.userId = :userId AND p.item='exercise')";
    	
    	Query q = dataSource.getSession().createQuery(exerciseQuery + " ORDER BY exerciseName");
    	if (!user.isManagerSite()) q.setParameter("userId", user.getUserId());
    	
    	request.setAttribute("exerciseList", q.getResultList());
        
        request.setAttribute("userGroupList", dataSource.getUserAllGroups());
        // request.setAttribute("examList", dataSource.getExamsAll());
        request.setAttribute("examList", dataSource.getSession().createQuery("FROM IQExam WHERE deleted=false ORDER BY examName").list());
                
        //create optimized query for exam quiz counts (total and completed)
        
		List<Object[]> results = dataSource.getSession().createQuery("SELECT e.examId, count(q), sum(case when q.completed = 1 then 1 else 0 end) AS ExecCount FROM IQExam e JOIN e.userQuizes q "
				+ "WHERE e.deleted=0 "
				+ "GROUP BY e.examId ORDER BY e.examName", Object[].class).list();
		Map<String, Object[]> counts = new HashMap();
		for (Object[] result : results) {
			counts.put(result[0]+"", result);
		}
        request.setAttribute("examCounts", counts);
        
        request.setAttribute("settings", dataSource.getSession().createQuery("from IQSetting").list());
        return new ActionForward("/admin/admin.jsp");
    }
    
    private List<IQExercise> removeInactive(List<IQExercise> exerciseList) {
    	List<IQExercise> newList = new ArrayList();
    	for (IQExercise e: exerciseList) {
    		if (e != null && e.isActive()) {
    			newList.add(e);
    		}
    	}
    	return newList;
    }
    
    public ActionForward removeCaseFromExercise(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception{
    	String caseIdStr = request.getParameter("caseid");
    	String exerciseIdStr = request.getParameter("exerciseid");
    	IQCase iqCase = dataSource.getCase(Long.parseLong(caseIdStr));
    	List<IQExercise> iqexercises = iqCase.getParentExercises();
    	iqexercises = removeInactive(iqexercises);
    	if (iqexercises.size() <= 1) {
    		response.getWriter().println("Cannot remove case: This is the last exercise associated with it.  To remove select 'DELETE'");
    		response.setStatus(400);
    	} else {
    		//present in other exercises
    		IQExercise iqexercise = dataSource.getExercise(Long.parseLong(exerciseIdStr));
    		boolean success = iqCase.getParentExercises().remove(iqexercise);
    		iqexercise.getCases().remove(iqCase);
    		for (IQCaseTag tag: dataSource.getCaseTags(iqCase.getCaseId(), Long.parseLong(exerciseIdStr))) {
    			tag.getAssociatedCases().remove(iqCase);
    			iqCase.getCaseTags().remove(tag);
    			dataSource.getSession().save(tag);
    		}
    		dataSource.saveCase(iqCase); //will flush
    		if (success) {
    			response.getWriter().println("Success: Removed case '" + iqCase.getCaseName() + "' from exercise '" + iqexercise.getExerciseName() + "'");
    		} else {
    			response.getWriter().println("Could not find case, something went wrong.");
    			response.setStatus(400);
    		}
    	}
    	
    	response.getWriter().flush();
    	response.getWriter().close();
    	
    	return null;
    }
    
    public ActionForward addCaseToExercise(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception{
    	String caseIdStr = request.getParameter("caseid");
    	String exerciseIdStr = request.getParameter("exerciseid");
    	//String returnToExerciseId = request.getParameter("returntoexerciseid");
    	IQCase iqCase = dataSource.getCase(Long.parseLong(caseIdStr));
    	IQExercise iexercise = dataSource.getExercise(Long.parseLong(exerciseIdStr));
    	iqCase.getParentExercises().add(iexercise);
    	iexercise.getCases().add(iqCase);
    	dataSource.saveObject(iqCase);
    	dataSource.saveObject(iexercise);
    	
    	response.getWriter().println("Success: Added case '" + iqCase.getCaseName() + "' to exercise '" + iexercise.getExerciseName() + "'");
    	
    	response.getWriter().flush();
    	response.getWriter().close();
    	return null;
    }
    
    public ActionForward deleteCase(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String caseIdStr = request.getParameter("caseid");
    	String exerciseIdStr = request.getParameter("exerciseid");
    	IQCase iqCase = dataSource.getCase(Long.parseLong(caseIdStr));
    	
    	dataSource.softDeleteCase(iqCase);
    	
    	ActionRedirect ar = new ActionRedirect("/admin/admin.do");
    	ar.addParameter("method", "editExercise");
    	ar.addParameter("exerciseid", exerciseIdStr);
    	return ar;
    }
    
    public ActionForward addExercise(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	IQExercise exercise = new IQExercise();
    	String exerciseName = (String) request.getParameter("exercisename");
    	if (exerciseName == null || exerciseName.equals("")) {
    		request.setAttribute("error", "Exercise name cannot be empty");
    		return new ActionForward(list(mapping, form, request, response));
    	}
    	if (dataSource.getExerciseByName(exerciseName).size() > 0) {
    		request.setAttribute("error", "Exercise name already used");
    		return new ActionForward(list(mapping, form, request, response));
    	}
		dataSource.saveExercise(new IQExercise(exerciseName));
		request.setAttribute("message", "Created a new exercise titled '" + exerciseName + "'");
    	return new ActionForward(list(mapping, form, request, response));
    }
    
    
    public ActionForward editExerciseAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String exerciseIdStr = request.getParameter("exerciseid");
    	Long exerciseId = Long.parseLong(exerciseIdStr);
    	String filterType = request.getParameter("filterType");
    	String filterSelected = request.getParameter("filterSelected");
    	
    	List<IQCase> returnCases = new ArrayList();
    	
    	//System.out.println("FILTER TYPE: " + filterType);
    	//System.out.println("FILTER Sent: " + filterSelected);
    	if (filterType != null && !filterType.equals("")) {
    		//filter is selected
    		if (filterType.equals("category")) {
    			Session session = dataSource.getSession();
    			Gson gson = new Gson();
    			List<Double> tagIds = gson.fromJson(filterSelected, List.class);
    			//System.out.println("size opened: " + tagIds.size());
    			for (Double tagIdDouble: tagIds) {
    				Long tagId = Math.round(tagIdDouble);
    				System.out.println(tagId);
    				List<IQCase> result = session.createQuery("SELECT DISTINCT c FROM IQCase c JOIN c.caseTags t JOIN t.associatedExercise et "
    						+ "WHERE t.tagId=:tagId AND c.active = true ORDER BY c.caseId")
    				.setParameter("tagId", tagId).list();
    				returnCases.addAll(result);
    			}
    		} else if (filterType.equals("ecgDx")) {
    			//System.out.println(filterSelected);
    			CaseUtil caseUtil = new CaseUtil();
    			IQExercise iexercise = dataSource.getExercise(Long.parseLong(exerciseIdStr));
    			Gson gson = new Gson();
    			String[] dxs = (String[]) gson.fromJson(filterSelected, List.class).toArray(new String[0]);
    			returnCases.addAll(caseUtil.filterByECGDx(iexercise, dxs, dataSource));
    		}
    	} else {
    		//no filter
    		IQExercise iexercise = dataSource.getExercise(Long.parseLong(exerciseIdStr));
    		returnCases = iexercise.getActiveCases();
    		
//    		returnCases = dataSource.getSession()
//    				.createQuery("SELECT DISTINCT c FROM IQCase c JOIN c.exerciseCaseLink cl JOIN cl.parentExercise e "
//					+ "WHERE e.exerciseId=:exerciseId AND c.active = true ORDER BY cl.caseOrder", IQCase.class)
//			.setParameter("exerciseId", Long.parseLong(exerciseIdStr)).list();
    	}
    	
    	returnCases = new JsonUtil().prepareCasesForJson(returnCases, dataSource, exerciseId);
    	
    	JsonUtil jsonUtil = new JsonUtil();
    	String output = jsonUtil.getIQCaseGson().toJson(returnCases);
    	response.getWriter().print(output);
    	response.getWriter().flush();
    	return null;
    }
    
    public ActionForward exerciseAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String exerciseid = (String) request.getParameter("exerciseid");
    	String action = (String) request.getParameter("action");
    	Long exerciseId = Long.parseLong(exerciseid);
    	IQExercise exercise = dataSource.getExercise(exerciseId);
    	if (action.equals("get")) {
        	List<IQPermission> permissions = dataSource.getSession().createQuery("FROM IQPermission p WHERE p.item='exercise' AND p.itemId = :exerciseid", IQPermission.class)
        			.setParameter("exerciseid", exerciseId)
        			.list();
        	HashMap<String, Object> result = new HashMap();
        	Gson gson = JsonUtil.getIQExerciseGson();
        	result.put("exercise", exercise);
        	result.put("permissions", permissions);
        	response.getWriter().print(gson.toJson(result));
    	} else if (action.equals("rename")) {
    		IQExercise e = dataSource.getSession().load(IQExercise.class, exerciseId);
    		e.setExerciseName(request.getParameter("exercisename"));
    		dataSource.getSession().save(e);
    		response.getWriter().print("{\"success\": true}");
    	}
    	response.getWriter().flush();
    	return null;
    }
    
    public ActionForward permissionAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String action = (String) request.getParameter("action");
    	IQUser creator = (IQUser) request.getSession().getAttribute("security");
    	IQPermission result = null;
    	if (action.equals("add")) {
    		String userid = request.getParameter("userid");
    		String exerciseid = request.getParameter("exerciseid");
    		IQUser u = dataSource.getUserById(Long.parseLong(userid));
    		IQPermission p = new IQPermission();
    		p.setUser(u);
    		p.setItem("exercise");
    		p.setItemId(Long.parseLong(exerciseid));
    		p.setCreatedBy(creator);
    		dataSource.getSession().save(p);
    		result = p;
//    		System.out.println(JsonUtil.getIQExerciseGson().toJson(result));
        	Gson gson = JsonUtil.getIQExerciseGson();
        	response.getWriter().print(gson.toJson(result));
    	} else if (action.equals("delete")) {
    		String permissionid = request.getParameter("permissionid");
    		IQPermission p = dataSource.getSession().load(IQPermission.class, Long.parseLong(permissionid));
    		dataSource.getSession().delete(p);
    		response.getWriter().print("{\"success\": true}");
    	}
    	dataSource.getSession().close();
    	response.getWriter().flush();
    	return null;
    }
    
    
    public ActionForward getCaseAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String caseId = request.getParameter("caseId");
    	String exerciseId = request.getParameter("exerciseId");
    	IQCase returnCase = (IQCase) dataSource.getSession().createQuery("SELECT c FROM IQCase c WHERE c.caseId=:caseId")
    		.setParameter("caseId", Long.parseLong(caseId))
    		.uniqueResult();
    	
    	JsonUtil jsonUtil = new JsonUtil();
    	List<IQCase> returnCases = new ArrayList<IQCase>();
    	returnCases.add(returnCase);
    	returnCases = new JsonUtil().prepareCasesForJson(returnCases, dataSource, Long.parseLong(exerciseId));
    	
    	String output = jsonUtil.getIQCaseGson().toJson(returnCases.get(0));
    	response.getWriter().print(output);
    	response.getWriter().flush();
    	return null;
    }
    
    public ActionForward editExercise(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String exerciseIdStr = request.getParameter("exerciseid");
    	String filterSTs = request.getParameter("filters");
    	String operator = request.getParameter("operator");
    	
    	//String[] filterGroups = filterGroups
    	
    	request.setAttribute("exerciseid", exerciseIdStr);
    	
    	IQExercise exercise = dataSource.getExercise(Long.parseLong(exerciseIdStr));
    	
    	List<IQCase> caseList;
    	if (filterSTs != null && !filterSTs.equals("")) {
    		String[] sts = StringUtils.split(filterSTs, "|");
    		System.out.println(filterSTs);
    		//COPIED FROM CASEACTION FINDEXPLORE
    		
			        	if (operator != null && operator.equalsIgnoreCase("AND")) {
			        		String hql ="select c from IQCase c JOIN c.parentExercises e JOIN c.questionList q JOIN q.associatedAnswerLines l JOIN l.associatedAnswerWrappers w JOIN w.searchTerm st WHERE c.active=1 AND e.exerciseName=:exerciseName AND st.searchTermString=:st";
			        		TypedQuery<IQCase> query = dataSource.getSession().createQuery(hql, IQCase.class);
			    	    	query.setParameter("exerciseName", exercise.getExerciseName());
			    	    	query.setParameter("st", sts[0]);
			    	    	caseList = query.getResultList();
			    	    	
			    	    	
			    	    	for (int i = 1; i< sts.length; i++) {
			    	    		hql ="select c from IQCase c JOIN c.parentExercises e JOIN c.questionList q JOIN q.associatedAnswerLines l JOIN l.associatedAnswerWrappers w JOIN w.searchTerm st WHERE c.active=1 AND e.exerciseName=:exerciseName AND st.searchTermString=:st";
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
			    	    	query.setParameter("exerciseName", exercise.getExerciseName());
			    	    	for (int i = 0; i< sts.length; i++) {
			    	    		query.setParameter("st" + i, sts[i]);
			    	    	}
			    	    	caseList = query.getResultList();
			        	}
			    	    	
			    	    	
    	} else {
    		caseList = exercise.getActiveCases();
    	}
    	
    	List<IQExercise> exercises = dataSource.getActiveExerciseList();
    	
    	
    	request.setAttribute("exerciseId", exercise.getExerciseId());
    	request.setAttribute("exercise", exercise);
    	request.setAttribute("caseList", caseList);
    	request.setAttribute("exerciseList", exercises);
    	return new ActionForward("/admin/editexercise.jsp");
    }
    
    public ActionForward toggleParentExercisesAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String caseIdStr = request.getParameter("caseid");
    	Long parentExerciseId = Long.parseLong(request.getParameter("exerciseid"));
    	String addOrRemove = request.getParameter("addorremove");
    	Long selectedExerciseId = Long.parseLong(request.getParameter("selectedexerciseid"));
    	Boolean clearTagsOnMove = Boolean.parseBoolean(request.getParameter("clearTagsOnMove"));
    	
    	IQCase icase = dataSource.getCase(Long.parseLong(caseIdStr));
    	IQExercise iexercise = dataSource.getExercise(selectedExerciseId);
    	Boolean add = Boolean.parseBoolean(addOrRemove);
    	List<IQExercise> parentExercises = icase.getParentActiveExercises(dataSource);
    	
    	//response.getWriter().println("Could not find case, something went wrong.");
		//response.setStatus(400);
    	    	
    	if (add) { //if add
    		if (icase.getParentExercises().contains(iexercise)) return null;
    		else {
    			icase.getParentExercises().add(iexercise);
    			iexercise.getCases().add(icase);
    			//System.out.println("Clear Tags: " + clearTagsOnMove);
    			//transfer tags over
    			if (!clearTagsOnMove) {
    				IQExercise selectedExercise = dataSource.getExercise(selectedExerciseId);
    				List<IQCaseTag> selectedExerciseTags = dataSource.getAllTags(selectedExerciseId);
    				for (IQCaseTag tag: dataSource.getCaseTags(icase.getCaseId(), parentExerciseId)) {
    					//System.out.println("Looping through tag: " + tag.getTagName());
    					boolean found = false;
    					for (IQCaseTag t: selectedExerciseTags) {
    						if (tag.getTagName().equals(t.getTagName())) {
    							icase.getCaseTags().add(t);
    							t.getAssociatedCases().add(icase);
    							dataSource.saveOrUpdate(t);
    							//System.out.println("Found old tag");
    							found = true;
    						}
    					}
    					if (!found) {
    						//create a new one
    						//System.out.println("Creating new tag");
    						IQCaseTag newTag = new IQCaseTag();
    						newTag.setAssociatedExercise(selectedExercise);
    						newTag.setTagName(tag.getTagName());
    						newTag.getAssociatedCases().add(icase);
    						icase.getCaseTags().add(newTag);
    						dataSource.saveObject(newTag);
    					}
    				}
    			}
    			dataSource.getSession().save(icase);
    			dataSource.getSession().save(iexercise);
    		}
    		
    	} else { //if remove
    		if (parentExercises.size() <= 1) {
    			response.getWriter().println("Last case");
        		response.setStatus(400);
    		} else {
        		icase.getParentExercises().remove(iexercise);
        		iexercise.getCases().remove(icase);
        		for (IQCaseTag tag: dataSource.getCaseTags(icase.getCaseId(), selectedExerciseId)) {
        			tag.getAssociatedCases().remove(icase);
        			icase.getCaseTags().remove(tag);
        			dataSource.getSession().save(tag);
        		}
        		dataSource.saveCase(icase); //will flush
        		response.getWriter().println("Success");
    		}
    	}
    	
    	response.getWriter().flush();
    	response.getWriter().close();
    	
    	return null;
    }
    
    public ActionForward getParentExercisesAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception{
    	String caseId = request.getParameter("caseid");
    	String exerciseId = request.getParameter("exerciseid");
    	
    	IQCase icase = dataSource.getCase(Long.parseLong(caseId));
    	List<IQExercise> activeExercises = dataSource.getActiveExerciseList();
    	List<IQExercise> contaiendExercises = icase.getParentExercises();
    	
    	List <ReturnParentExercises> reply = new ArrayList();
    	for (IQExercise e: activeExercises) {
    		Boolean contained = false;
    		if (contaiendExercises.contains(e)) {
    			contained = true;
    		}
    		//System.out.println("FINDING: " + e.getExerciseName() + " " + contained);
    		ReturnParentExercises newReply = new ReturnParentExercises();
    		newReply.exerciseId = e.getExerciseId();
    		newReply.exerciseName = e.getExerciseName();
    		newReply.contained = contained;
    		reply.add(newReply);
    	}
    	//System.out.println("FINDING: " + reply.size() + " " + reply.get(0).exerciseId);
    	Gson gson = new Gson();
    	String replyJson = gson.toJson(reply);
    	response.getWriter().print(replyJson);
    	response.getWriter().flush();
    	return null;
    	
    }
	class ReturnParentExercises {
		Long exerciseId;
		String exerciseName;
		Boolean contained;
	}
	
	
    
    
    public ActionForward viewCase(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception{
    	String caseId = request.getParameter("caseid");
    	String exerciseId = request.getParameter("exerciseid");
    	String editor = request.getParameter("editor");
    	if (editor != null && editor.equals("")) editor = null;
    	String returnUrl = "/admin/editcase.jsp"; //default
    	
    	
    	Exception exceptionFromOtherMethod = (Exception) request.getSession().getAttribute("exception");
    	if (exceptionFromOtherMethod != null) request.setAttribute("exception", exceptionFromOtherMethod);
    	
    	request.getSession().removeAttribute("exception");
    	IQCase icase = dataSource.getCase(Long.parseLong(caseId));
    	if (icase == null) {
    		response.getWriter().append("Error retrieving case");
    		response.getWriter().flush();
    		return null;
    	}
    	

    	CaseUtil caseUtil = new CaseUtil();
    	_log.debug("FOUND CASE: " + icase.getEditorType());
//    	if ((editor==null && icase.getEditorType().equals(IQCase.EDITOR_MCQ)) || (editor != null && editor.equals("mcq"))) {
//    		//get question and answer separately for editcase2 (user friendly version)
//    		//if {question:mcq} is only one and at the end, then hide it (to hide {} stuff from editors)
////    		CaseUtil.QuestionAnswerText qat = caseUtil.removeQuestionAnswerMarkupSpecial(icase); // returns two variables
////    		
////    		request.setAttribute("questionHtml", caseUtil.unescapeHTMLforXML(qat.caseText));
////    		request.setAttribute("answerHtml", caseUtil.unescapeHTMLforXML(qat.answerText));
////
////    		request.setAttribute("mcqData", CaseUtil.getMCQuestionListJSON(icase));
//    		returnUrl = "/admin/editcasemcq.jsp";
//    	} else if ((editor==null && icase.getEditorType().equals(IQCase.EDITOR_SG)) || (editor != null && editor.equals("sg"))) {
//    		//get question and answer separately for editcase2 (user friendly version)
//    		//if {question:sg} is only one and at the end, then hide it (to hide {} stuff from editors)
////    		CaseUtil.QuestionAnswerText qat = caseUtil.removeQuestionAnswerMarkupSpecial(icase); // returns two variables
////    		
////    		request.setAttribute("questionHtml", caseUtil.unescapeHTMLforXML(qat.caseText));
////    		request.setAttribute("answerHtml", caseUtil.unescapeHTMLforXML(qat.answerText));
////
////    		try {
////	    		request.setAttribute("sgData", CaseUtil.getSGQuestionListJSON(icase));
////	    		request.setAttribute("qOptions", CaseUtil.getQuestionOptionsJSON(icase));
////    		} catch (ClassCastException cce) {
////    			request.setAttribute("sgData", new ArrayList<HashMap<String, Object>>());
////    			request.setAttribute("qOptions", new HashMap<String, Object>());
////    		}
//    		returnUrl = "/admin/editcasemcq.jsp";
//    	} else { 
//    		// request.setAttribute("xml", caseUtil.unescapeHTMLforXML(icase.getCaseXml()));
//    		
//    	}
    	returnUrl = "/admin/editcasemcq.jsp";
    	List<IQCaseComment> comments = icase.getComments();
		Collections.sort(comments, Collections.reverseOrder()); //order by date
    	request.setAttribute("comments", comments);
    	request.setAttribute("icase", icase);
    	request.setAttribute("exerciseId", exerciseId);
    	
    	//Load tags
    	IQExercise iqexercise = dataSource.getExercise(Long.parseLong(exerciseId));
 	   	List<IQCaseTag> availableTags = iqexercise.getAssociatedCaseTags();
		List<IQCaseTag> caseTags = dataSource.getCaseTags(icase.getCaseId(), iqexercise.getExerciseId());
		availableTags.removeAll(caseTags);
		request.setAttribute("availableTags", availableTags);
		request.setAttribute("currentTags", caseTags);
		
		request.setAttribute("lastRevision", caseUtil.getLastRevision(icase, dataSource));
		request.setAttribute("initialAuthor", caseUtil.getFirstVersion(icase, dataSource));

		ImageAction imageAction = new ImageAction();
		request.setAttribute("imagesJson", imageAction.listJSON(icase));
		
		return new ActionForward(returnUrl);
    	
    }
    

    
    public ActionForward addCase(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception{
    	String caseName = request.getParameter("casename");
    	String exerciseId = request.getParameter("exerciseid");
    	String template = request.getParameter("template");
        
    	IQExercise iexercise = dataSource.getExercise(Long.parseLong(exerciseId));
    	IQCase icase = new IQCase();
    	
    	
    	//determine case name
    	if (caseName == null || caseName.equals("")) {
    		//if not defined then do case ## (last case)
    		Long counter = new Long((Long) dataSource.getSession().createFilter(iexercise.getCases(), "select count(*)").list().iterator().next());
    		caseName = "case " + counter;
    	} else {
    		//if defined, check for dupliclates, if duplicates then insert ##
	    	Long counter = new Long((Long) dataSource.getSession().createFilter(iexercise.getCases(), "select count(*) where caseName LIKE ?")
					.setParameter(0, caseName + "%")
					.list().iterator().next());
			if (counter > 0) {
				caseName = caseName + " " + counter;
			}
    	}
    	
    	icase.setCaseName(caseName);
    	

    	icase.getParentExercises().add(iexercise); // bidirectional relationship, and iqCase owns it
    	iexercise.getCases().add(icase);
    	
    	//Create a default case based on template
    	String defaultCaseXML = "";
    	if (template.equals("mcq")) {
    		CaseUtil caseUtil = new CaseUtil();
    		//got below from JASON vueJS from editcase2.jsp (changed hidden field to visible)
    		String mcqData = "[{\"correct\":false,\"text\":\"Answer A\"},{\"correct\":false,\"text\":\"Answer B\"},{\"correct\":true,\"text\":\"Answer C\"},{\"correct\":false,\"text\":\"Answer D\"}]";
    		defaultCaseXML = caseUtil.createXml(
    				"<p>This is an instructional case that demonstrates the template for question creation.</p>\n" + 
    				"<p>Tips for Creating Questions:</p>\n" + 
    				"<ul>\n" + 
    				"<li>Most questions should be case-based</li>\n" + 
    				"<li>Avoid use of acronyms (some common acronyms are ok). First use of an acronym should be written out.</li>\n" + 
    				"<li>Avoid use of brand names - use generic names only (i.e. instead of Lasix, use furosemide)</li>\n" + 
    				"<li>Lab tables should be created using the \"Insert Lab Table\" feature on the text editor toolbar. Other tables can be created.</li>\n" + 
    				"</ul>\n" + 
    				"<p><strong>Last sentence of the question should be bolded, which asks the main question for the user to answer?</strong></p>", 
    				"<p>Answer Format:</p>\n" + 
    				"<p>First paragraph or two should summarize the case, provide teaching points and supporting graphics, and explain the correct answer to the case. All graphics should be a caption citing the source. ALL graphics must have a reference (unless they are created by you).</p>\n" + 
    				"<p><strong>Incorrect Choices:</strong></p>\n" + 
    				"<ol style=\"list-style-type: lower-roman;\">\n" + 
    				"<li><strong>Answer A - </strong>Incorrect because of ...A ... B .. C.</li>\n" + 
    				"<li><strong>Answer B</strong> - To create incorrect choices list--&gt;  click on \"Numbered List\" dropdown arrow, and select \"Lower Roman\"</li>\n" + 
    				"<li><strong>Answer D</strong> - Ensure the bolded answer matches the answer in the question above</li>\n" + 
    				"</ol>\n" + 
    				"<p><strong>Further</strong> <strong>Reading</strong></p>\n" + 
    				"<ul>\n" + 
    				"<li>Should contain a bulleted list of links. The first bullet point generally contains a link to a CardioGuide.ca summary, and second one to a resource that describes the main learning objective (often clinical practice guideline)</li>\n" + 
    				"<li><a href=\"https://cardioguide.ca/stemi\" target=\"_blank\" rel=\"noopener\">CardioGuide.ca Summary on ST Elevation MI</a></li>\n" + 
    				"<li>Try to leave as few links as possible to avoid overwhelming the user.</li>\n" + 
    				"</ul>", 
    				mcqData, "mcq", null);
    		
    		icase.setDisplayType(IQCase.DISPLAY_QUESTION_WITH_ANSWER);
    		icase.setEditorType(IQCase.EDITOR_MCQ);
    		
    		//test it (ensure case is processed - all MCQ questions are properly placed IN DB)
    		CaseXMLParser parser = new CaseXMLParser();
    		parser.parseCase(defaultCaseXML, icase, dataSource);
    	//} else if (template.equals("ecg")) {  - for later
    	} else if (template.equals("sg")) {
    		CaseUtil caseUtil = new CaseUtil();
    		//got below from JASON vueJS from editcase2.jsp (changed hidden field to visible)
    		//String qData = "[{\"score\":1,\"primary\":true,\"or\":false,\"missed\":0,\"text\":\"Pericarditis\"}]";
    		String qData = "[{}]";
    		defaultCaseXML = caseUtil.createXml("Enter question text here", "Enter answer text here", qData, "sg", null);
    		_log.debug("SAVING default case:" + defaultCaseXML);
    		icase.setDisplayType(IQCase.DISPLAY_QUESTION_WITH_ANSWER);
    		icase.setEditorType(IQCase.EDITOR_SG);
            _log.debug("SAVING CASE AS : " + icase.getEditorType());
    		//test it (ensure case is processed - all MCQ questions are properly placed IN DB)
            icase.setCaseXml(defaultCaseXML);
            dataSource.saveCase(icase);
            
    		CaseXMLParser parser = new CaseXMLParser();
    		parser.parseCase(defaultCaseXML, icase, dataSource);    		
            _log.debug("SAVING CASE AS : " + icase.getEditorType());
//    		CaseUtil caseUtil = new CaseUtil();
//    		ClassLoader classLoader = ImageQuizProperties.class.getClassLoader();
//            InputStream fs = classLoader.getResourceAsStream("/org/imagequiz/util/DefaultCaseXMLsg.xml");
//            defaultCaseXML = IOUtils.toString(fs);
//    		icase.setDisplayType(IQCase.DISPLAY_QUESTION_WITH_ANSWER);
//    		icase.setEditorType(IQCase.EDITOR_SG);
    	} else if (template.contains("ecg")) {
    		ClassLoader classLoader = ImageQuizProperties.class.getClassLoader();
            InputStream fs = classLoader.getResourceAsStream("/org/imagequiz/util/DefaultCaseXMLecg.xml");
            defaultCaseXML = IOUtils.toString(fs);
    	} else {
    		ClassLoader classLoader = ImageQuizProperties.class.getClassLoader();
            InputStream fs = classLoader.getResourceAsStream("/org/imagequiz/util/DefaultCaseXML.xml");
            defaultCaseXML = IOUtils.toString(fs); 
    	}
    	//load default case XML
    	
        icase.setCaseXml(defaultCaseXML);
    	dataSource.saveCase(icase);
    	dataSource.getSession().saveOrUpdate(iexercise);
    	
    	/*
    	ActionRedirect ar = new ActionRedirect("/admin/admin.do");
    	ar.addParameter("method", "editExercise");
    	ar.addParameter("exerciseid", exerciseId);
    	return ar;*/
    	JsonUtil jsonUtil = new JsonUtil();
    	String json = jsonUtil.getIQCaseGson().toJson(icase);
    	response.getWriter().print(json);
    	response.getWriter().flush();
    	return null;
    }
    
    public ActionForward test(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception{
    	
    	return null;
    }
    
    public ActionForward updateCaseAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	request.setAttribute("ajaxcall", true);
    	IQUser iuser = (IQUser) request.getSession().getAttribute("security");
    	Exception e;
    	try {
    		updateCase(mapping, form, request, response);
    		e = (Exception) request.getSession().getAttribute("exception");
    	} catch (Exception e1) {
    		e = e1;
    		e.printStackTrace();
    	}
    	
    	
    	//e = new Exception("Test Exception");  // for testing
    	JsonObject jsonObject = new JsonObject();
    	if (e != null) {
    		StringWriter sw = new StringWriter();
    		e.printStackTrace(new PrintWriter(sw));
    		String exceptionAsString = sw.toString();

    		jsonObject.addProperty("errorTitle", e.getMessage());
    		jsonObject.addProperty("errorDetail", exceptionAsString);
    	} else if (iuser == null) {
    		jsonObject.addProperty("loggedout", true);
    	} else {
    		jsonObject.addProperty("success", true);
    	}
    	
    	request.getSession().removeAttribute("exception");
    	
    	Gson gson = new Gson();
    	String json = gson.toJson(jsonObject);
		response.getWriter().print(json);
		response.getWriter().flush();
		return null;
    }
    


    
    public ActionForward updateCase(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception{
    	String caseId = request.getParameter("caseid");
    	String caseName = request.getParameter("casename");
    	String exerciseId = request.getParameter("exerciseid");
    	String caseTypeInterface = request.getParameter("caseTypeInterface");
    	
    	//sent by caseXml editor
    	String caseXml = request.getParameter("casexml");
    	
    	//sent by mcq editor
    	String questionHtml = request.getParameter("questionHtml");
    	String answerHtml = request.getParameter("answerHtml");
    	
    	String questionData = request.getParameter("qData");
    	_log.debug("qData is: " + questionData);
    	String questionOptions = request.getParameter("qOptions");
    	_log.debug("qOptions is: " + questionOptions);
    	_log.debug("Interface is: " + caseTypeInterface);
    	
    	IQCase icase;

    	icase = dataSource.getCase(Long.parseLong(caseId));
    	
    	if (icase == null) {
			response.getWriter().append("Cannot find case");
    		response.getWriter().flush();
    		return null;
    	}
    	
    	
    	
    	
    	icase.setCaseName(caseName);
    	CaseUtil caseUtil = new CaseUtil();
    	String oldXml = icase.getCaseXml();
    	
    	//Option 1 -->> caseXml is set, which defines the absolute case xml (from xml editor)
    	if (caseTypeInterface.equals("xml")) {
    		caseXml = caseUtil.escapeHTMLinXMLtagsSpecial(caseXml);
    		
    		icase.setCaseXml(caseXml);
    		
    	} 
    	//Option 2 --> caseXml is null, so use answerHtml and questionHtml
    	else if (caseTypeInterface.equals("mcq")||caseTypeInterface.equals("sg")) {
    		//HTML editor does <br> instead of <br/> (XML parser isn't happy)
    		questionHtml = caseUtil.fixExternalLinks(questionHtml); //do before xml is escaped
    		answerHtml = caseUtil.fixExternalLinks(answerHtml); //do before xml is escaped
    		questionHtml = caseUtil.escapeHTMLforXML(questionHtml);
    		answerHtml = caseUtil.escapeHTMLforXML(answerHtml);
    		_log.debug("Creating XML is");
    		caseXml = caseUtil.createXml(questionHtml, answerHtml, questionData, caseTypeInterface, questionOptions);		
    		icase.setCaseXml(caseXml);
    		icase.setDisplayType(IQCase.DISPLAY_QUESTION_WITH_ANSWER);
    	}
    	
    	//TRY TEST PARSE CASE TO TEST IT
    	CaseXMLParser parser = new CaseXMLParser();
    	boolean error = false;
    	try {
	    	IQCase testCase = new IQCase();
	    	parser.parseCase(caseXml, testCase, dataSource);
    	} catch (Exception e) {
    		request.getSession().setAttribute("exception", e);
    		e.printStackTrace();
    		error = true;
    	}
    	
    	//update revision history
    	
		caseUtil.updateRevisionHistory(request, dataSource, icase, oldXml, caseXml);  //update revision hx before new caseXml is set
    	
    	if (!error) {
        	parser.parseCase(caseXml, icase, dataSource);
    	}

	    
    	
    	dataSource.saveCase(icase);
    	//_log.info.println(caseList.getCaseById(Long.parseLong(caseId)).getCaseXml());
    	
    	request.setAttribute("icase", icase);
    	request.setAttribute("exerciseId", exerciseId);
    	
    	if (request.getAttribute("ajaxcall") != null) { //for ajax calls - avoids extra work
    		return null;
    	} else if (caseTypeInterface != null && caseTypeInterface.equals("mcq")) {
    		//get question and answer separately for editcase2 (user friendly version)
    		
    		//if {question:mcq} is only one and at the end, then hide it (to hide {} stuff from editors)
    		
    		CaseUtil.QuestionAnswerText qat = caseUtil.removeQuestionAnswerMarkupSpecial(icase); // returns two variables
    		request.setAttribute("questionHtml", caseUtil.unescapeHTMLforXML(qat.caseText));
    		request.setAttribute("answerHtml", caseUtil.unescapeHTMLforXML(qat.answerText));

    		request.setAttribute("mcqData", CaseUtil.getMCQuestionListJSON(icase));
    		return new ActionForward("/admin/editcasemcq.jsp");
    	} else if (caseTypeInterface != null && caseTypeInterface.equals("sg")) {
    		//get question and answer separately for editcase2 (user friendly version)
    		
    		//if {question:mcq} is only one and at the end, then hide it (to hide {} stuff from editors)
    		
    		CaseUtil.QuestionAnswerText qat = caseUtil.removeQuestionAnswerMarkupSpecial(icase); // returns two variables
    		request.setAttribute("questionHtml", caseUtil.unescapeHTMLforXML(qat.caseText));
    		request.setAttribute("answerHtml", caseUtil.unescapeHTMLforXML(qat.answerText));

    		request.setAttribute("sgData", CaseUtil.getSGQuestionListJSON(icase));
    		request.setAttribute("qOptions", CaseUtil.getQuestionOptionsJSON(icase));
    		return new ActionForward("/admin/editcasemcq.jsp");
    	} else {
    		request.setAttribute("xml", caseUtil.unescapeHTMLinXMLtagsSpecial(icase.getCaseXml()));
    		return new ActionForward("/admin/editcasexml.jsp");
    	}
    	
    }
    
    public ActionForward showCaseHx(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String caseId = request.getParameter("caseid");
    	IQCase icase = dataSource.getCase(Long.parseLong(caseId));
    	    	
    	List<IQCaseRevision> revisions = icase.getRevisionHistory();
    	JsonUtil jsonUtil = new JsonUtil();
    	String jsonRevisions = jsonUtil.getIQCaseRevisionGson().toJson(revisions);
    	request.setAttribute("revisions", jsonRevisions);
    	return new ActionForward("/admin/casehx.jsp");
    }
    
    public ActionForward updateExercise(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        String exerciseId = request.getParameter("exerciseid");
        String caseListXML = request.getParameter("casexml");
        String exerciseName = request.getParameter("exercisename");
        boolean ajaxCall = false;
        if (caseListXML == null) {
            //assume sent as JSON via ajax editor
            String dataString = IOUtils.toString(request.getInputStream(), "UTF-8");
            JSONObject jObj = new JSONObject(dataString);
            caseListXML = jObj.getString("casexml");
            exerciseName = jObj.getString("exercisename");
            ajaxCall = true;
        }
        CaseXMLParser parser = new CaseXMLParser();
        IQExercise newExercise = new IQExercise();
        Long id = null;
        try {
            //newExercise = parser.parseCase(questionXml, caseToFill)parse(caseListXML);
        	newExercise.setExerciseName(exerciseName);
            if (exerciseId != null && !exerciseId.equals("")) {
                newExercise.setExerciseId(Long.parseLong(exerciseId));
            }
            _log.info("number of cases: " + newExercise.getCases().size());
             //dataSource = new IQDataSourceJDBC();
            id = dataSource.saveExercise(newExercise);
        } catch (Exception cpe) {
            if (ajaxCall) {
                PrintWriter out = response.getWriter();  
                out.println("Error: " + cpe.getMessage());  
                out.flush();  
                _log.info("error: displayed");
                return null;
            } else {
                request.setAttribute("error", cpe.getMessage());
            }
        }
        if (ajaxCall && id != null) {
        	PrintWriter out = response.getWriter();  
            out.println("id: " + id);  
            out.flush();  
            _log.info("ID sent back");
            return null;
        }
        request.setAttribute("exercise", newExercise);
        return new ActionForward("/admin/editExercise.jsp");
    }
    
    public ActionForward archiveExercise(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        String exerciseId = request.getParameter("id");
        if (exerciseId != null && !exerciseId.equals("")) {
        	IQExercise exercise = dataSource.getExercise(Long.parseLong(exerciseId));
        	exercise.setActive(false);
        	dataSource.saveObject(exercise);
        	//dataSource.deleteExercise(Long.parseLong(exerciseId));
        }
        return new ActionRedirect("admin.do");
    }
    
//   public ActionForward tagList(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
//	   String caseId = request.getParameter("caseid");
//	   String exerciseId = request.getParameter("exerciseid");
//	   IQExercise iqexercise = dataSource.getExercise(Long.parseLong(exerciseId));
//	   List<IQCaseTag> availableTags = iqexercise.getAssociatedCaseTags();
//	   if (caseId == null || caseId.equals("")) {
//		   request.setAttribute("availableTags", availableTags);
//		   //dataSource.close();
//		   return new ActionForward("/admin/tags.jsp");
//	   } else {
//		   IQCase iqcase = dataSource.getCase(Long.parseLong(caseId));
//		   List<IQCaseTag> caseTags = dataSource.getCaseTags(iqcase.getCaseId(), iqexercise.getExerciseId());
//		   availableTags.removeAll(caseTags);
//		   request.setAttribute("availableTags", availableTags);
//		   request.setAttribute("currentTags", caseTags);
//		   request.setAttribute("exerciseId", exerciseId);
//		   request.setAttribute("caseId", caseId);
//		   request.setAttribute("returnToExerciseId", request.getParameter("returnToExerciseId")); //if tags are set after moving case from one exercise to another
//		   //dataSource.close();
//	   }
//	   return new ActionForward("/admin/tags.jsp");
//   }
   
   
   
   
   public ActionForward tagListAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String caseId = request.getParameter("caseid");
	   String exerciseId = request.getParameter("exerciseid");
	   String includeCounts = request.getParameter("includeCounts");
	   List<IQCaseTag> availableTags = new ArrayList();
	   List<IQCaseTag> caseTags = new ArrayList();
	   IQExercise iqexercise = new IQExercise();
	   Session session = dataSource.getSession();
	   
	   
	   if (exerciseId != null && !exerciseId.equals("")) {
		   iqexercise = dataSource.getExercise(Long.parseLong(exerciseId));
		   availableTags = iqexercise.getAssociatedCaseTags();
	   }
	  
	   
	   if (caseId != null && !caseId.equals("")) {
		   IQCase iqcase = dataSource.getCase(Long.parseLong(caseId));
		   caseTags = dataSource.getCaseTags(iqcase.getCaseId(), iqexercise.getExerciseId());
		   availableTags.removeAll(caseTags);
	   }
	   
	   if (includeCounts != null && includeCounts.equals("true")) {
		   
		   for (IQCaseTag t: availableTags) {
			   Long count = (Long) session.createQuery("Select count(*) FROM IQCase c JOIN c.caseTags t "
			   		+ "WHERE c.active = true AND t.tagId=:tagId") 
			   .setParameter("tagId", t.getTagId()).uniqueResult();
			   t.setPreparedCaseCount(count);
		   }
	   }
	   
	   HashMap<String, List<IQCaseTag>> result = new HashMap();
	   result.put("currentTags", caseTags);
	   result.put("availableTags", availableTags);
	   
	   
               
       Gson gson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation()
       .serializeNulls()
       .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
       .create();
	   
	   
	   response.getWriter().print(gson.toJson(result));
	   
	   return null;
	   
	   /*
	    * registerTypeAdapter(IQImage.class, new JsonSerializer<IQCaseTag>() {
       public JsonElement serialize(IQCaseTag tag, final java.lang.reflect.Type type, final JsonSerializationContext context) {
       		JsonObject fields = JsonUtil.serializeCurrentElements(tag, new JsonObject(), context);
       		return fields;
	  		  }
       })
	    */
   }
   
   public ActionForward tagSaveAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String tagJson = (String) request.getParameter("payload");
	   String exerciseIdJson = (String) request.getParameter("exerciseId");
	  
	   Long exerciseId = Long.parseLong(exerciseIdJson);
	   Gson gson = new Gson();
	   IQCaseTag payloadData = gson.fromJson(tagJson, IQCaseTag.class);
	   _log.debug("updating tag: " + payloadData.getTagId() + " " + payloadData.getTagName());
	   
	   
	   IQExercise exercise = dataSource.getExercise(exerciseId);
	   IQCaseTag savedTag = dataSource.getTagById(payloadData.getTagId());
	   

	   
	   if (savedTag == null) {
		   savedTag = new IQCaseTag();
		   savedTag.setAssociatedExercise(exercise);
		   exercise.getAssociatedCaseTags().add(savedTag);
	   } 
	   savedTag.setTagName(payloadData.getTagName());
	   savedTag.setPrefix(payloadData.getPrefix());
	   savedTag.setResourcesJson(payloadData.getResourcesJson());
	   	   
	   dataSource.saveObject(savedTag);
	   dataSource.saveObject(exercise);
	   
	   
	   savedTag.prepareForGson(dataSource, true, true);
	   
	   HashMap<String, Object> reply = new HashMap();
	   reply.put("message", "Category '" + savedTag.getTagName() + "' is saved!");
	   reply.put("payload", savedTag);
	   
	   response.getWriter().print(getGson().toJson(reply));
	   response.getWriter().flush();
	   return null;
   }
   
   
   
   public ActionForward saveTags(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String caseId = request.getParameter("caseid");
	   String exerciseId = request.getParameter("exerciseid");
	   String newTags = request.getParameter("myTagsVal");
	   IQExercise iqExercise = dataSource.getExercise(Long.parseLong(exerciseId));
	   IQCase iqCase = dataSource.getCase(Long.parseLong(caseId));
	   List<IQCaseTag> currentTags = dataSource.getCaseTags(iqCase.getCaseId(), iqExercise.getExerciseId());
	   //I can't remember why I did it this way, but I remember spending like 6 hours straight deciding.
	   if (newTags != null) {
		   String[] newTagsArray = newTags.split(",");
		   iqCase.setPrefix(""); //clear prefix - we will make a new one
		   for (String newTag: newTagsArray) {
			   if (newTag.trim().equals("")) continue;
			   IQCaseTag foundTag = dataSource.getTagByName(newTag.trim(), Long.parseLong(exerciseId));
			   if (foundTag == null) 
				   foundTag = new IQCaseTag(newTag.trim());
			   
			   if (!foundTag.getAssociatedCases().contains(iqCase)) {
				   //look through associated cases to see if it's there already, if not, add it
				   foundTag.getAssociatedCases().add(iqCase);
				   foundTag.setAssociatedExercise(iqExercise);
				   dataSource.saveTag(foundTag);
			   }
			   
			   //update prefix
			   iqCase.setPrefix(iqCase.getPrefix() + IQCaseTag.getTagPrefix(newTag));
		   }
		   for (IQCaseTag currentTag: currentTags) {
			   boolean found = false;
			   for (String newTag: newTagsArray) {
				   if (newTag.trim().equalsIgnoreCase(currentTag.getTagName())) {
					   //found, do nothing
					   found = true;
				   }
			   }
			   if (!found) {
				   currentTag.getAssociatedCases().remove(iqCase);
				   dataSource.saveTag(currentTag);
			   }
		   }
		   dataSource.saveCase(iqCase);
		   
		   
	   }
	   //this is now an ajax call
	   response.setContentType("text/html;charset=UTF-8");
       response.getWriter().write("Success");
       return null;
	   /*
	   ActionRedirect redirect = new ActionRedirect("/admin/admin.do");
	   redirect.addParameter("returnToExerciseId", request.getParameter("returnToExerciseId"));  //if finished tagging after moving case to another exercise
	   redirect.addParameter("caseid", caseId);
	   redirect.addParameter("exerciseid", request.getParameter("exerciseid"));
	   redirect.addParameter("method", "tagList");
	   
	   return redirect;
	   */
   }
   
   public ActionForward viewTags(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String exerciseId = request.getParameter("exerciseid");
	   String caseId = request.getParameter("caseid");
	   List<IQCaseTag> availableTags = new ArrayList();
	   IQExercise iqexercise = dataSource.getExercise(Long.parseLong(exerciseId));
	   
	   availableTags = iqexercise.getAssociatedCaseTags();
	   
	   for (IQCaseTag t: availableTags) {
			   t.prepareForGson(dataSource, true, true);
	   }
               
       Gson gson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation()
       .serializeNulls()
       .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
       .create();
	   
       request.setAttribute("caseId", caseId);
	   request.setAttribute("exerciseId", exerciseId);
	   request.setAttribute("tags", gson.toJson(availableTags));
	   return new ActionForward("/admin/tagsList.jsp");
   }
   
   public ActionForward tagDeleteAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String tagId = request.getParameter("tagId");
	   IQCaseTag tag = dataSource.getTagById(Long.parseLong(tagId));

	   
	   HashMap<String, Object> reply = new HashMap();
	   reply.put("message", "Category '" + tag.getTagName() + "' is deleted!");
	   reply.put("tagId", tagId);
	   
	   if (tag != null)
		   dataSource.deleteTag(tag);
	   
	   response.getWriter().print(getGson().toJson(reply));
	   response.getWriter().flush();
	   return null;
   }
   
   public ActionForward searchQuestionConfigView(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   IQDataSource dataSource = new IQDataSource();
	   List<IQSearchTermGroup> tagGroups = dataSource.getAllSearchTermGroups();
	   request.setAttribute("searchGroupList", tagGroups);
	   return new ActionForward("/admin/searchquestionconfig.jsp");
   }
   
   /*
   public ActionForward addSearchGroup(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String groupName = request.getParameter("groupname");
	   if (groupName == null || groupName.equals("")) {
   			request.setAttribute("error", "Group name cannot be empty");
   			return new ActionForward(searchQuestionConfigView(mapping, form, request, response));
	   }
	   IQSearchTermGroup searchGroup = new IQSearchTermGroup();
	   searchGroup.setGroupName(groupName);
	   dataSource.saveSearchTermGroup(searchGroup);
	   request.setAttribute("message", "Created a new group titled '" + groupName + "'");
	   return searchQuestionConfigView(mapping, form, request, response);
   }
   
   
   public ActionForward deleteSearchGroup(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String groupIdS = request.getParameter("groupid");
	   String closeWindow = request.getParameter("closewindow");
	   if (groupIdS == null || groupIdS.equals("")) {
   			request.setAttribute("error", "Group id cannot be empty");
   			return new ActionForward(searchQuestionConfigView(mapping, form, request, response));
	   }
	   Long groupId = Long.parseLong(groupIdS);
	   dataSource.deleteSearchGroup(groupId);
	   request.setAttribute("message", "Delete Successful");
	   if (closeWindow != null && !closeWindow.equals("false")) {
		   response.getWriter().print("<html><script type=\"text/javascript\">"
				+ "window.opener.location.reload();"
		   		+ "window.close();" +
				   "</script></html>");
		   response.flushBuffer();
		   return null;
	   }
	   return searchQuestionConfigView(mapping, form, request, response);
   }
   
   public ActionForward viewSearchGroup(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String groupId = request.getParameter("groupid");
	   IQSearchTermGroup searchGroup;
	   if (groupId == null || groupId.equals("")) {
		   searchGroup = new IQSearchTermGroup();
	   } else {
		   searchGroup = dataSource.getSearchTermGroup(Long.parseLong(groupId));
	   }
	   request.setAttribute("searchGroup", searchGroup);
	   return new ActionForward("/admin/editsearchgroup.jsp");
   }
   
   public ActionForward saveSearchGroup(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String groupId = request.getParameter("groupid");
	   String groupName = request.getParameter("groupname");
	   String groupTerms = request.getParameter("groupterms");

	   IQSearchTermGroup searchGroup;
	   if (groupId.equals("")) {
		   //new group
		   searchGroup = new IQSearchTermGroup();
	   } else {
		   searchGroup = dataSource.getSearchTermGroup(Long.parseLong(groupId));
	   }
	   
	   if (groupName == null || groupName.equals("")) {
		   request.setAttribute("error", "Group name cannot be empty");
		   request.setAttribute("searchGroup", searchGroup);
		   return new ActionForward("/admin/editsearchgroup.jsp");
	   }
	   
	   searchGroup.setGroupName(groupName);
	   searchGroup.setSearchTermsText(groupTerms);
	   dataSource.saveSearchTermGroup(searchGroup);
	   
	   request.setAttribute("searchGroup", searchGroup);
	   request.setAttribute("message", "Saved!  You can now close this window");
	   request.setAttribute("success", "true");
	   return new ActionForward("/admin/editsearchgroup.jsp");
   }
   */
   
   //------useradmin features.
   public ActionForward userAdmin(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   List<IQUser> users = dataSource.getSession().createQuery("FROM IQUser u ORDER BY u.lastLogin DESC", IQUser.class).list();
	   request.setAttribute("users", users);
       request.setAttribute("userGroups", dataSource.getUserAllGroups());
	   return new ActionForward("/admin/useradmin.jsp");
   }
   public ActionForward deleteUser(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   ActionRedirect redirect = new ActionRedirect("/admin/admin.do");
	   redirect.addParameter("method", "userAdmin");
	   String userId = request.getParameter("userid");
	   
	   IQUser user = dataSource.getUserById(Long.parseLong(userId));
	   for (IQUserGroup group: user.getUserGroups()) {
		   group.getUsers().remove(user);
		   dataSource.saveOrUpdate(group);
	   }
	   dataSource.deleteUser(user);
	   request.getSession().setAttribute("message", "SUCCESS: User deleted");
	   return redirect;
   }
   
   
   public ActionForward addUser(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   ActionRedirect redirect = new ActionRedirect("/admin/admin.do");
	   redirect.addParameter("method", "userAdmin");
	   String username = request.getParameter("username").trim();
	   String password = request.getParameter("password");
	   String firstName = request.getParameter("firstname").trim();
	   String lastName = request.getParameter("lastname").trim();
	   String groupId = request.getParameter("usergroup").trim();
	   String email = request.getParameter("email").trim();
	   
	   IQUser user = dataSource.getUserByUsername(username);
	   if (user != null) {
		   request.getSession().setAttribute("message", "ERROR: Username already exists");
		   return redirect;
	   }
	   user = dataSource.getUserByEmail(email);
	   if (user != null) {
		   request.getSession().setAttribute("message", "ERROR: User with this email already exists");
		   return redirect;
	   }
	   IQUser newUser = new IQUser();
	   newUser.setUsername(username);
	   newUser.setPasswordHash(UserAction.hash(password));
	   newUser.setEmail(email);
	   newUser.setLastName(lastName);
	   newUser.setFirstName(firstName);
	   

	   dataSource.saveObject(newUser);
	   
	   if (groupId != null && !groupId.equals("")) {
		   IQUserGroup group = dataSource.getUserGroupById(Long.parseLong(groupId));
		   group.getUsers().add(newUser);
		   dataSource.saveObject(group);
	   }
	   
	   
	   request.getSession().setAttribute("message", "SUCCESS: User '" + username +"' added!");
	   return redirect;
   }
   
   public ActionForward updateUser(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String userId = request.getParameter("userid");
	   String userName = request.getParameter("username");
	   String email = request.getParameter("email");
	   String firstName = request.getParameter("firstname");
	   String lastName = request.getParameter("lastname");
	   _log.info("new username: " + userName);
	   if (userId == null || userId.equals("")) {
		   ActionRedirect redirect = new ActionRedirect("/admin/admin.do");
		   redirect.addParameter("method", "userAdmin");
		   request.getSession().setAttribute("message", "ERROR: To edit users, click on the field you want to update, and then click 'Update'");
		   return redirect;
	   }
	   IQUser iuser = dataSource.getUserById(Long.parseLong(userId));
	   if (userName != null)
		   iuser.setUsername(userName.trim());
	   if (email != null && !email.equals(""))
		   iuser.setEmail(email.trim());
	   if (firstName != null)
		   iuser.setFirstName(firstName.trim());
	   if (lastName != null)
		   iuser.setLastName(lastName.trim());
	   dataSource.saveOrUpdate(iuser);
	   
	   String groupId = request.getParameter("group");
	   if (groupId != null && groupId == "") {
		   for (IQUserGroup igroup: iuser.getUserGroups()) {
			   igroup.getUsers().remove(iuser);
			   dataSource.saveOrUpdate(igroup);
		   }
	   } else if (groupId != null) {
		   IQUserGroup group = dataSource.getUserGroupById(Long.parseLong(groupId));
		   for (IQUserGroup igroup: iuser.getUserGroups()) {
			   igroup.getUsers().remove(iuser);
			   dataSource.saveOrUpdate(igroup);
		   }
		   if (group != null) {
			   group.getUsers().add(iuser);
			   dataSource.saveOrUpdate(group);
		   }
	   }
	   ActionRedirect redirect = new ActionRedirect("/admin/admin.do");
	   redirect.addParameter("method", "userAdmin");
	   return redirect;
   }
   
   public ActionForward setPassword(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   ActionRedirect redirect = new ActionRedirect("/admin/admin.do");
	   redirect.addParameter("method", "userAdmin");
	   String userId = request.getParameter("userid");
	   String newPassword = request.getParameter("newpassword");
	   IQUser user = dataSource.getUserById(Long.parseLong(userId));
	   user.setPasswordHash(UserAction.hash(newPassword));
	   dataSource.saveObject(user);
	   request.getSession().setAttribute("message", "SUCCESS: Password changed");
	   return redirect;
   }
   
   public ActionForward viewReferences(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   List<IQReference> references =  (List<IQReference>) dataSource.getSession().createCriteria(IQReference.class).list();
	   request.setAttribute("references", references);
	   return new ActionForward("/admin/reference.jsp");
   }
   
   public ActionForward addReference(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String searchText = request.getParameter("searchtext");
	   String replaceLink = request.getParameter("replacelink");
	   if (searchText == null || searchText.equals("")) {
		   request.setAttribute("message", "Search Text cannot be empty");
		   return viewReferences(mapping, form, request, response);

	   }
	   if (replaceLink == null || replaceLink.equals("")) {
		   request.setAttribute("message", "Replace Link cannot be empty");
		   return viewReferences(mapping, form, request, response);
	   }
	   IQReference newRef = new IQReference();
	   newRef.setSearchText(searchText);
	   newRef.setReplaceLink(replaceLink);
	   dataSource.saveObject(newRef);
	   
	   ActionRedirect redirect = new ActionRedirect("admin.do");
	   redirect.addParameter("method", "viewReferences");
	   return redirect;
   }
   
   public ActionForward deleteReference(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String referenceId = request.getParameter("referenceid");
	   if (referenceId == null || referenceId.equals("")) {
		   request.setAttribute("message", "Something went wrong");
		   return viewReferences(mapping, form, request, response);
	   }

	   IQReference reference = (IQReference) dataSource.getSession().get(IQReference.class, Long.parseLong(referenceId));
	   dataSource.delete(reference);
	   ActionRedirect redirect = new ActionRedirect("admin.do");
	   redirect.addParameter("method", "viewReferences");
	   return redirect;
   }
   
   public ActionForward deleteComment(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
   	String commentId = request.getParameter("commentId");
   	
   	IQUser iuser = (IQUser) request.getSession().getAttribute("security");
   	

   	IQCaseComment comment = (IQCaseComment) dataSource.getSession().get(IQCaseComment.class, Long.parseLong(commentId));
   	System.out.println("comment ID: " + comment.getUser().getUserId());
   	if (!iuser.isManagerCases() && !comment.getUser().getUserId().equals(iuser.getUserId())) return null;
   	
   	dataSource.delete(comment);

   	response.getWriter().println("success");
   	
   	response.getWriter().flush();
   	response.getWriter().close();
   	return null;
   }
   public ActionForward toggleHideComment(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
		   	String commentId = request.getParameter("commentId");
	
		   	IQCaseComment comment = (IQCaseComment) dataSource.getSession().get(IQCaseComment.class, Long.parseLong(commentId));
	
		   	comment.setHidden(!comment.isHidden());
		   	dataSource.saveObject(comment);
	
		   	response.getWriter().println("success");
		   	
		   	response.getWriter().flush();
		   	response.getWriter().close();
		   	return null;
	   }
   public ActionForward editExamProperties(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String exerciseId = request.getParameter("exerciseId");
	   String exerciseName = request.getParameter("exerciseName");
	   if (exerciseId == null || exerciseId.equals(""))
		   return new ActionRedirect("/admin/admin.do");
	   IQExercise exercise = dataSource.getExercise(Long.parseLong(exerciseId));
	   if (exercise == null) {
		   return new ActionRedirect("/admin/admin.do");
	   }
	   //should have valid exercise from now on
	   if (exerciseName == null || exerciseName.equals("")) {
		   request.getSession().setAttribute("error", "Invalid Exercise Name");
		   return new ActionRedirect("/admin/admin.do");
	   } 
	   //check duplicate names
	   List<IQExercise> duplicates = dataSource.getExerciseByName(exerciseName);
	   if (duplicates.size() > 1 || (duplicates.size() == 1 && duplicates.get(0).getExerciseId() != exercise.getExerciseId())) {
		   request.getSession().setAttribute("error", "Exercise name '" + exerciseName + "' already used");
		   return new ActionRedirect("/admin/admin.do");
	   }
	   exercise.setExerciseName(exerciseName);
	   dataSource.saveObject(exercise);
	   request.getSession().setAttribute("success", "Successfully edited exerise '" + exercise.getExerciseName() + "'");
	   return new ActionRedirect("/admin/admin.do");
   }
   
   public ActionForward conversion(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   List<IQCase> iqcases =  (List<IQCase>) dataSource.getSession().createCriteria(IQCase.class).list();
	   for (IQCase iqcase: iqcases) {
		   response.getWriter().println("processed case '" + iqcase.getCaseName() + "'");
		   CaseXMLParser parser = new CaseXMLParser();
		   parser.parseCase(iqcase.getCaseXml(), iqcase, dataSource);
		   dataSource.saveCase(iqcase);
		   
	   }
	   response.getWriter().println("done");
	   response.getWriter().flush();
	   return null;
   }
   
   public ActionForward reorderCase(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
   	String caseIdStr = request.getParameter("caseid");
   	String exerciseIdStr = request.getParameter("exerciseid");
   	String direction = request.getParameter("direction");
   	//String returnToExerciseId = request.getParameter("returntoexerciseid");
   	
   	try {
	   	IQCase iqCase = dataSource.getCase(Long.parseLong(caseIdStr));
	   	IQExercise iexercise = dataSource.getExercise(Long.parseLong(exerciseIdStr));
	   	int i = iexercise.getCases().indexOf(iqCase);
	   	//System.out.println("I is: " + i);
	   	int d = 0;
	   	int m = 0;
	   	if (direction.equals("up")) {
	   		m = -1;
	   	} else if (direction.equals("down")) {
	   		m = +1;
	   	}
	   	List<IQCase> cases = iexercise.getCases();
	   	if (i+(d+m) < 0 || i+(d+m) > cases.size()-1) return null;
	   	
	   	//must ensure to ignore deleted cases
	   	IQCase c2 = null;
	   	while (c2 == null || !c2.isActive()) {
	   		d = d + m;
	   		c2 = cases.get(i+d);
	   	}
	   	Collections.swap(cases, i, i+d);
	   	iexercise.setCases(cases);
	   	dataSource.getSession().update(iexercise);
	   	response.getWriter().println("Success");
	   	response.getWriter().flush();
	   	response.getWriter().close();
   	} catch (Exception e) {
   		response.getWriter().println("Error has occured.");
   		e.printStackTrace();
		response.setStatus(400);
		response.getWriter().flush();
	   	response.getWriter().close();
   	}
   	return null;
	   
   }
   
   public ActionForward update(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   IQDataSourceJDBC jdbc = new IQDataSourceJDBC();
	   String sql = "select distinct quizid from iqquizcaselink";
	   Statement st = jdbc.getConnection().createStatement();
	   List<String> quizids = new ArrayList();
	   try {
		   ResultSet results = st.executeQuery(sql);
	       while (results.next()) {
	           //response.getWriter().println(results.getString(1));
	           quizids.add(results.getString(1));
	       }
	
	       for (String quizid: quizids) {
	    	   response.getWriter().println("Executing: " + quizid + "\n");
	    	   String sql1 = "select @i := -1";
	    	   st.execute(sql1);
	    	   String sql2 = "update iqquizcaselink set caseorder = (select @i := @i + 1) where quizid =" + quizid;
	    	   st.execute(sql2);
	       }	
	   }catch (Exception e) {
		   e.printStackTrace();
	   } finally {
	       
	   }
	   response.getWriter().println("executed");
	   response.getWriter().flush();
	   return null;
   }
   
   public ActionForward update2(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   IQDataSourceJDBC jdbc = new IQDataSourceJDBC();
	   String sql = "select distinct exerciseid from iqexercisecaselink";
	   Statement st = jdbc.getConnection().createStatement();
	   List<String> quizids = new ArrayList();
	   try {
		   ResultSet results = st.executeQuery(sql);
	       while (results.next()) {
	           //response.getWriter().println(results.getString(1));
	           quizids.add(results.getString(1));
	       }
	
	       for (String quizid: quizids) {
	    	   response.getWriter().println("Executing: " + quizid + "\n");
	    	   String sql1 = "select @i := -1";
	    	   st.execute(sql1);
	    	   String sql2 = "update iqexercisecaselink set caseorder = (select @i := @i + 1) where exerciseid =" + quizid;
	    	   st.execute(sql2);
	       }	
	   }catch (Exception e) {
		   e.printStackTrace();
	   } finally {
	       
	   }
	   response.getWriter().println("executed");
	   response.getWriter().flush();
	   return null;
   }
   
   public ActionForward objectivesGetAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException {
	   String caseIdStr = request.getParameter("caseid");
	   
	   List<IQCaseObjective> objectives;
	   if (caseIdStr != null) {
		   objectives = dataSource.getSession().createQuery("select o FROM IQCaseObjective o JOIN o.parentCases c WHERE c.caseId = :caseId")
				   .setParameter("caseId", Long.parseLong(caseIdStr))
				   .list();
	   } else {
		   objectives = dataSource.getSession().createQuery("FROM IQCaseObjective")
				   .list();
	   }
	   
	   
	   Gson gson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation()
		       .serializeNulls()
		       .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
		       .create();

	   response.getWriter().print(gson.toJson(objectives));
	   response.getWriter().flush();
	   return null;
   }
   
   public ActionForward objectivesAddAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String objectiveStr = request.getParameter("objective");
	   
	   _log.debug("Inserting Objective");
	   
	   Gson gson = new GsonBuilder().create();
	   IQCaseObjective[] objectives = gson.fromJson(objectiveStr, IQCaseObjective[].class);
	   
	   for (IQCaseObjective o: objectives) {
		   dataSource.getSession().save(o);
	   }
	   dataSource.flush();
	   
	   response.getWriter().print(gson.toJson(objectives));
	   response.getWriter().flush();
	   return null;
   }
   
   public ActionForward objectivesDeleteAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String objectiveId = request.getParameter("objectiveid");
	   Session session = dataSource.getSession();

	   Transaction transaction = session.beginTransaction();
	   
	   IQCaseObjective objective = session.find(IQCaseObjective.class, Long.parseLong(objectiveId));
	   //session.flush();
	   if (objective != null) {
		   objective.setParentCases(new ArrayList());
		   session.saveOrUpdate(objective);
		   session.delete(objective);
		   session.flush();
		   session.close();
	   } else {
		   response.setStatus(400);
		   response.getWriter().println("Cannot find case");
	   }
	   return null;
   }
   
   public ActionForward objectivesEditAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String objectiveStr = request.getParameter("objective");
	   
	   Gson gson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation()
		       .serializeNulls()
		       .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
		       .create();
	   
	   IQCaseObjective objective = gson.fromJson(objectiveStr, IQCaseObjective.class);
	   
	   System.out.println(objective.getObjectiveId());
	   
	   IQCaseObjective objectiveSaved = dataSource.getSession().find(IQCaseObjective.class, objective.getObjectiveId());
	   
	   objectiveSaved.setObjectiveCode(objective.getObjectiveCode());
	   objectiveSaved.setObjectiveName(objective.getObjectiveName());
	   dataSource.getSession().update(objectiveSaved);
	   
	   response.getWriter().print(gson.toJson(objectiveSaved));
	   response.getWriter().flush();
	   return null;
   }
   
   public ActionForward objectivesAttachAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String caseIdStr = request.getParameter("caseid");
	   String objectivesStr = request.getParameter("objectives");
	   String operator = request.getParameter("operator");
//	   String addCategoriesStr = request.getParameter("addCategories");
//	   Boolean addCategories = Boolean.parseBoolean(addCategoriesStr);
	   String exerciseIdStr = request.getParameter("exerciseid");
	   
	   Gson gson = new GsonBuilder().create();
	   IQCaseObjective[] os = gson.fromJson(objectivesStr, IQCaseObjective[].class);
	   System.out.println(os.length + " " + operator);
	   
	   
	   IQCase c = dataSource.getSession().find(IQCase.class, Long.parseLong(caseIdStr));
	   for (IQCaseObjective o: os) {
		   o = dataSource.getSession().find(IQCaseObjective.class, o.getObjectiveId());
		   if (operator.equals("attach") && !o.getParentCases().contains(c)) {
			   System.out.println("attaching to case: " + c.getCaseId());
			   o.getParentCases().add(c);
			   c.getCaseObjectives().add(o);
			   //session.update(c);
			   dataSource.getSession().save(o);
			   //add tag if possible
			   //if (addCategories) 
				   //autoCategories(o.getObjectiveCode(), c, exerciseIdStr, session);
		   } else if (operator.equals("detach")) {
			   o.getParentCases().remove(c);
			   c.getCaseObjectives().remove(o);
			   dataSource.getSession().update(o);
		   } else {
			   log.error("Dont' know what to do");
		   }
	   }
	   response.getWriter().print("success");
	   response.getWriter().flush();
	   return null;
   }
   

   
//   private void autoCategories(String code, IQCase icase, String exerciseId, Session session) {
//	   HashMap<String, String[]> map = IQCaseTag.getCategoriesMap();
//	   for (Map.Entry<String, String[]> entry : map.entrySet()) {
//		    String key = entry.getKey();
//		    String[] value = entry.getValue();
//		    if (key.equals(code)) { //if found a code associated with a category
//		    	List<IQCaseTag> tagSearch = session.createQuery("select t FROM IQCaseTag t WHERE t.tagName = :tagname")
//		 			   .setParameter("tagname", value[0])
//		 			   .list();
//		    	if (tagSearch.size() == 0) { //category doesn't exist, make a new one
//		    		IQExercise iexercise = session.find(IQExercise.class, Long.parseLong(exerciseId));
//		    		if (iexercise == null) return;
//		    		IQCaseTag newTag = new IQCaseTag();
//		    		newTag.getAssociatedCases().add(icase);
//		    		newTag.setAssociatedExercise(iexercise);
//		    		newTag.setTagName(value[0]);
//		    		session.save(newTag);
//		    	} else {
//		    		IQCaseTag category = tagSearch.get(0);
//		    		category.getAssociatedCases().add(icase);
//		    		icase.getCaseTags().add(category);
//		    		session.saveOrUpdate(category);
//		    	}
//		    	icase.setPrefix(icase.getPrefix() + value[1]);
//		    	
//		    }
//	   }
//	   /*
//	   List<IQCaseTag> tagSearch = dataSource.getSession().createQuery("select t FROM IQCaseTag t WHERE t.tagName = :tagname")
//			   .setParameter("tagname", )
//			   .list();*/
//   }
   
   public ActionForward loadPrefixes(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   Session s = dataSource.getSession();
	   String exerciseId = request.getParameter("exerciseid");
	   List<IQCase> cs = s.createQuery("SELECT c FROM IQCase c JOIN c.parentExercises e WHERE e.exerciseId=:exerciseid")
			   .setParameter("exerciseid", Long.parseLong(exerciseId))
			   .list();
	   for (IQCase c: cs) {
		   c.setPrefix("");
		   for (IQCaseTag tag: dataSource.getCaseTags(c.getCaseId(), Long.parseLong(exerciseId))) {
			   c.setPrefix(c.getPrefix() + IQCaseTag.getTagPrefix(tag.getTagName()));
		   }
		   dataSource.saveCase(c);
		   response.getWriter().println("Processing: " + c.getCaseId() + " " + c.getCaseName() + "\n");
	   }
	   response.getWriter().println("DONE!");
	   response.getWriter().flush();
	   response.getWriter().close();
	   return null;
   }
   
   public ActionForward addSetting(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String newName = request.getParameter("newName");
	   String newValue = request.getParameter("newValue");
	   IQSetting newSetting = new IQSetting();
	   newSetting.setName(newName);
	   newSetting.setValue(newValue);
	   dataSource.saveObject(newSetting);
	   System.out.println("TESTING.................");
	   return list(mapping, form, request, response);
   }
   public ActionForward updateSetting(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String newName = request.getParameter("newName");
	   String newValue = request.getParameter("newValue");
	   List<IQSetting> settings = dataSource.getSession().createQuery("SELECT s FROM IQSetting s "
				+ "WHERE s.name=:namee")
		.setParameter("namee", newName).list();
	   for (IQSetting setting: settings) {
		   setting.setName(newName);
		   setting.setValue(newValue);
		   System.out.println("UPDATING.................");
		   dataSource.saveObject(setting);
	   }
	   return list(mapping, form, request, response);
   }
   public ActionForward deleteSetting(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String newName = request.getParameter("newName");
	   List<IQSetting> settings = dataSource.getSession().createQuery("SELECT s FROM IQSetting s "
				+ "WHERE s.name=:name")
		.setParameter("name", newName).list();
	   for (IQSetting setting: settings) {
		   dataSource.delete(setting);
	   }
	   return list(mapping, form, request, response);
   }
   
   public ActionForward authorsAjax(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   IQUser iuser = (IQUser) request.getSession().getAttribute("security");
	   String action = request.getParameter("action");
	   Gson gson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation()
    	       .serializeNulls()
    	       .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
    	       .create();
	   String reply = "{\"error\": \"Unknown action\"}";
	   
	   if (action.equals("add")) {
		   String id = request.getParameter("userid");
		   String role = request.getParameter("role");
		   String caseid = request.getParameter("caseid");
		   _log.debug("Adding: " + id + " Role: " + role);
		   IQUser targetUser = dataSource.getUserById(Long.parseLong(id));
		   
		   IQCase icase = dataSource.getCase(Long.parseLong(caseid));
		   // security
		   if (!iuser.isManagerCases() && !targetUser.getUserId().equals(iuser.getUserId())) return null;
		   if (!iuser.isManagerCases() && !iuser.isPermitted("exercise", Long.parseLong(request.getParameter("exerciseid")))) return null;
		   
		   
		   IQAuthor author = new IQAuthor();
		   author.setAuthor(targetUser);
		   author.setCreatedBy(iuser);
		   author.setIcase(icase);
		   author.setRole(role);
		   dataSource.getSession().save(author);
		   reply = gson.toJson(author);
		   dataSource.getSession().close();
	   } else if (action.equals("search")) {
		   String query = request.getParameter("query");
		   String securityModifier = "";
		   if (!iuser.isManagerCases()) securityModifier = " AND u.userId = " + iuser.getUserId();
		   List<IQUser> users = dataSource.getSession().createQuery("SELECT u FROM IQUser u "
		   		+ "WHERE (u.lastName like :query "
		   		+ "OR u.firstName like :query "
		   		+ "OR u.email like :query "
		   		+ "OR u.username like :query)" + securityModifier, IQUser.class)
		   		.setParameter("query", "%" + query + "%")
		   		.list();
		   reply = gson.toJson(users);
		   
	   } else if (action.equals("get")) {
		   Long caseId = Long.parseLong(request.getParameter("caseid"));
		   _log.debug("Getting authors for: " + caseId);
		   List<IQAuthor> authors = dataSource.getSession().createQuery("SELECT a FROM IQAuthor a JOIN a.icase c WHERE c.caseId = :caseId ORDER BY a.role ", IQAuthor.class)
				   .setParameter("caseId", caseId)
				   .list();
		   reply = gson.toJson(authors);
	   } else if (action.equals("remove")) {
		   Long authorid = Long.parseLong(request.getParameter("authorid"));
		   _log.debug("Removing: " + authorid);
		   IQAuthor author = dataSource.getSession().find(IQAuthor.class, authorid);
		   if (!iuser.isManagerCases() && !author.getAuthor().getUserId().equals(iuser.getUserId())) return null;
		   dataSource.getSession().remove(author);
		   reply = "{\"success\": true}";
		   dataSource.getSession().close();
	   }
	   response.getWriter().write(reply);
	   response.getWriter().flush();
	   return null;
   }
   
   public ActionForward doAction(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String limitStr = request.getParameter("limit");
	   if (limitStr == null) limitStr = "10";
	   Integer limit = Integer.parseInt(limitStr);
	   
	   PrintWriter writer = response.getWriter();
	   response.setContentType("text/html");
	   writer.println("<pre>");
	   int counter = 0;
		   try {
			   Long resultCount = (Long) dataSource.getSession().createQuery("SELECT count(cc) FROM IQCaseCompleted cc "
				   		+ "WHERE cc.completedCaseId NOT IN (SELECT cc.completedCaseId FROM IQCaseAnswer a JOIN a.associatedCaseCompleted cc) "
				   		+ "AND cc.answersText IS NOT NULL AND TRIM(cc.answersText) != ''") //  AND length(cc.answersText) > 4
				   							.getSingleResult();
			   writer.print("Total Records: " + resultCount);
			   
			   List<IQCaseCompleted> ccs = dataSource.getSession().createQuery("SELECT cc FROM IQCaseCompleted cc JOIN cc.userQuiz q "
				   		+ "WHERE cc.completedCaseId NOT IN (SELECT cc.completedCaseId FROM IQCaseAnswer a JOIN a.associatedCaseCompleted cc JOIN cc.userQuiz q) "
				   		+ "AND cc.answersText IS NOT NULL AND TRIM(cc.answersText) != ''"
				   		+ "ORDER BY q.dateStarted DESC", IQCaseCompleted.class)
					   						.setMaxResults(limit)
				   							.list();
			   			   
			   writer.println("Processing currently: " + ccs.size() + " entries");
				   int ccCount = 0;
				   for (IQCaseCompleted cc: ccs) {
					   ccCount += 1;
					   writer.println(ccCount + "Completed Case: " + cc.getCompletedCaseId());
					   if (cc.getAnsweredQuestions().size() == 0) {
						   cc.setAnswersText(null);
						   dataSource.getSession().update(cc);
					   }
					   boolean removeQuestions = true;
					   for (IQUserQuestionAnswered qa: cc.getAnsweredQuestions()) {
						   writer.println("\tQuestion Answered: " + qa.getQuestionId());
						   for (IQAnswer a : qa.getUserSelections()) {
							   removeQuestions = false;
							   writer.println("\t\tIQAnswer: " + a.getAnswer());
							   String questionType = qa.getQuestionType();
							   if (questionType.equals("search_term")) questionType = IQQuestion.QUESTION_TYPE_SEARCHTERM;
							   List<IQQuestion> qs = dataSource.getSession().createQuery("SELECT q FROM IQQuestion q JOIN q.parentCase c "
							   		+ "WHERE q.questionTextId=:questionTextId "
							   		+ "AND c.caseId=:caseId", IQQuestion.class)
									.setParameter("questionTextId", qa.getQuestionId())
									.setParameter("caseId", cc.getAssociatedCase().getCaseId()).list();
							   if (qs != null && qs.size() > 0) {
								   IQQuestion q = qs.get(0);
								   Long itemId = null;
								   if (questionType.equals(IQQuestion.QUESTION_TYPE_CHOICE)) {
									   List<IQAnswerChoice> choices = dataSource.getSession().createQuery("SELECT ac FROM IQAnswerChoice ac JOIN ac.parentQuestion q "
										   		+ "WHERE q.questionId=:questionId "
										   		+ "AND ac.answerString=:text", IQAnswerChoice.class)
												.setParameter("questionId", q.getQuestionId())
												.setParameter("text", a.getAnswer()).list();
									   if (choices != null && choices.size() > 0) itemId = choices.get(0).getChoiceId();
								   }
								   if (questionType.equals(IQQuestion.QUESTION_TYPE_SEARCHTERM)) {
									   List<IQAnswerSearchTermWrapper> choices = dataSource.getSession().createQuery("SELECT w FROM IQAnswerSearchTermWrapper w "
									   			+ "JOIN w.searchTerm st JOIN w.parentQuestionLine l JOIN l.parentQuestion q "
										   		+ "WHERE q.questionTextId=:questionTextId "
										   		+ "AND st.searchTermString=:text", IQAnswerSearchTermWrapper.class)
												.setParameter("questionTextId", q.getQuestionTextId())
												.setParameter("text", a.getAnswer()).list();
									   
									   if (choices != null && choices.size() > 0) itemId = choices.get(0).getSearchTerm().getSearchTermId();
								   }
								   
								   IQCaseAnswer answer = new IQCaseAnswer(cc.getUserQuiz(), cc, questionType, q, qa.getQuestionId());
								   answer.setScore(a.getScore());
								   answer.setCreatedAt(cc.getUserQuiz().getDateStarted());
								   try {
									   answer.setStatus(IQCaseAnswer.convertStatus(a.getStatus()));
								   } catch (Exception e) {}
								   answer.setItemId(itemId);
								   answer.setText(a.getAnswer());
								   
								   dataSource.getSession().save(answer);
								   writer.println("\t\t\t--------Completed Answer: " + answer.getQuestionType() + "---" + answer.getText() + "--- itemId: " + answer.getItemId());
								   writer.flush();
							   } else {
								   writer.println("\t\t\tAnswer is missing:" + qa.getQuestionId() + "--------");
								   writer.flush();
							   }
							   
						   }
					   }
					   if (removeQuestions) {
						   cc.setAnswersText(null);
						   dataSource.getSession().update(cc);
					   }
				   }
		   } catch (Exception e) {
			   e.printStackTrace(writer);
			   e.printStackTrace();
		   }
	   writer.println("</pre>");
	   writer.println("DONE!!!!");
	   writer.flush();
	   writer.close();
	   return null;
	   //	   	IQUser iuser = (IQUser) request.getSession().getAttribute("security");
//	   	if (!iuser.isAdmin()) {
//	   		response.getWriter().println("Not allowed");
//	   		return null;
//	   	} else {
//	   		List<IQUserQuiz> quizzes = dataSource.getSession().createQuery("FROM IQUserQuiz quiz WHERE quiz.dateStarted > '2020-01-01'", IQUserQuiz.class).list();
//	   		for (IQUserQuiz quiz: quizzes) {
//	   			_log.debug("Processing..." + quiz.getQuizId());
//	   			response.getWriter().println("Processing..." + quiz.getQuizId() + "\n");
//	   			IQUserQuizHelper helper = quiz.getHelper();
//	   			if (helper != null) {
//	   				if (helper.getIncompleteIds().size() == 0) {
//	   					quiz.setCompletedAllQuestions(true);
//	   					dataSource.getSession().save(quiz); 
//	   				}
//	   			}
//	   		}
//	   		
//	   		response.getWriter().println("It's done...");
//	   		return null;
//	   	}
	   }
   

   
   public ActionForward sessions(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   response.getWriter().println("Users: " + SessionCounterListener.getActiveSessions().size());
	   request.setAttribute("sessions", SessionCounterListener.getActiveSessions());
	   return new ActionForward("/admin/usersActive.jsp");
   }
   public ActionForward sessionsTerminate(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	   String sessionId = request.getParameter("sessionId");
	   for (HttpSession session :SessionCounterListener.getActiveSessions()) {
		   if (session.getId().equals(sessionId)) {
			   _log.debug("Terminating: " + session.getId() + " | " + ((IQUser) session.getAttribute("security")).getUserId() + " | " + ((IQUser) session.getAttribute("security")).getEmail());
			   session.invalidate();
		   }
	   }
	   return sessions(mapping, form, request, response);
   }
   
}
