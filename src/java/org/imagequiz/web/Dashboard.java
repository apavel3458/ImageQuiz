package org.imagequiz.web;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.hibernate.query.Query;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQExam;
import org.imagequiz.model.user.IQDashboardItem;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserQuiz;

public class Dashboard extends DispatchAction {
	private static Logger _log = Logger.getLogger(CaseAction.class);
	protected IQDataSource dataSource;
	
	
	public void setIQDataSource(IQDataSource value) {
	    dataSource = value;
	  }
	
	@Override
	public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	    return dashboard(mapping, form, request, response);
	}
	
	
	    
	public Dashboard() {
	}
	public Dashboard(IQDataSource dataSource) {
		this.setIQDataSource(dataSource);
	}
	
    public ActionForward dashboardSubspecialty(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	return new ActionForward("/case/dashboardSubspecialty.jsp");
    }
	
    public ActionForward dashboardCardiology(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
        IQUser iuser = (IQUser) request.getSession().getAttribute("security");
    	HashMap<String,IQDashboardItem> hs = new HashMap<String, IQDashboardItem>();
        	//null = no record of doing practice set
        	//ID = last quiz ID
    	if (dataSource == null) {
    		_log.debug("DATASOURCE IS NULL");
    	}
        Query<IQExam> query = dataSource.getSession().createQuery("SELECT DISTINCT e FROM IQExam e JOIN e.userQuizes q JOIN q.user u WHERE u.userId=:userId", IQExam.class)
        			.setParameter("userId", iuser.getUserId());
    	List<IQExam> exams = query.getResultList();
    	for (IQExam exam: exams) {
    			System.out.println("level: " + exam.getExamName());
    			Query<IQUserQuiz> query2 = dataSource.getSession().createQuery("SELECT q FROM IQUserQuiz q JOIN q.associatedExam e JOIN q.user u WHERE e.examId=:examId AND u.userId=:userId ORDER BY q.dateStarted DESC", IQUserQuiz.class)
    						.setParameter("examId", exam.getExamId())
    						.setParameter("userId", iuser.getUserId());
    			List<IQUserQuiz> quizzes = query2.getResultList();
    			if (quizzes.size() > 0) {
    					IQUserQuiz latestQuiz = quizzes.get(0);
    					Long delayMilis = exam.getTimeToRetry(latestQuiz);
    					IQDashboardItem dItem = new IQDashboardItem();
    					dItem.setQuiz(latestQuiz);
    					_log.debug("set milis:" + delayMilis);
    					dItem.setDelayMilis(delayMilis);
    					dItem.setSuccess(latestQuiz.getPass());
    					hs.put(exam.getExamName(), dItem);
    			}
    			
    	}
    	request.setAttribute("quizzes", hs); 
    	return new ActionForward("/case/dashboardCardiology.jsp");
    }
    
    public ActionForward dashboardEcg(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	IQUser user = (IQUser) request.getSession().getAttribute("security");
    	
    	String errorMessage = (String) request.getSession().getAttribute("errorMessage");
    	if (errorMessage != null) {
    		request.setAttribute("errorMessage", errorMessage);
    		request.getSession().removeAttribute("errorMessage");
    	}
    	
    	IQUser iuser = dataSource.getUserById(user.getUserId());
    	request.setAttribute("practiceLevels", getLastQuizForPracticeLevel(iuser, dataSource));
    	return new ActionForward("/case/dashboardEcg.jsp");
    }
    
    public ActionForward dashboard(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
  	  return new ActionForward("/case/dashboard.jsp");
    }
    
    public static HashMap<String, IQUserQuiz> getLastQuizForPracticeLevel(IQUser iuser, IQDataSource dataSource) {
    	HashMap<String,IQUserQuiz> hs = new HashMap<String, IQUserQuiz>();
    	//null = no record of doing practice set
    	//ID = last quiz ID
    	Query<String> query = dataSource.getSession().createQuery("SELECT DISTINCT e.examName FROM IQExam e JOIN e.userQuizes q JOIN q.user u WHERE e.examMode='level' AND u.userId=:userId", String.class)
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
    
    public ActionForward report(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	IQUser iuser = (IQUser) request.getSession().getAttribute("security");
    	_log.debug("called me");
    	return new ActionForward("/case/dashboardReport.jsp");
    }

}
