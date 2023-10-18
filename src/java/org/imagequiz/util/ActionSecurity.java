package org.imagequiz.util;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionRedirect;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.web.AdminAction;


public class ActionSecurity {
	private static Logger _log = Logger.getLogger(AdminAction.class);
	
	public ActionForward filter(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response, Object me) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException {
    	String methodName = request.getParameter("method");
    	if (methodName == null) methodName = "unspecified";
    	//just add exerciseID to your request to allow it
    	
    	String exerciseid = request.getParameter("exerciseid");
    	String[] allowedMethods = new String[] {
				  "unspecified", "authorsAjax", "reviewCommentAjax", "objectivesGetAjax", "showGroup"
				  };
    	if (exerciseid == null) exerciseid = request.getParameter("exerciseId");
    	
    	
    	
    	
    	IQUser iuser = (IQUser) request.getSession().getAttribute("security");
    	boolean permitted = false;
    	if (iuser.isManagerCases()) permitted = true;
    	else {
    		if (exerciseid != null) {
	    		Long exerciseId = Long.parseLong(exerciseid);
	    		permitted = iuser.isPermitted("exercise", exerciseId);
    		} else {
    			for (String allowedMethod: allowedMethods) {
    				if (allowedMethod.equals(methodName)) permitted = true;
    			}
    		}
    	}
    	_log.debug("access method is: " + methodName + " : " + permitted);
    	
    	if (!permitted) {
    		request.getSession().setAttribute("message", "You lack permissions to access this page");
			return new ActionRedirect("../login.jsp");
    	}
    	
    	try {
    		Method foundMethod = me.getClass().getMethod(methodName, ActionMapping.class, ActionForm.class, HttpServletRequest.class, HttpServletResponse.class);
    		return (ActionForward) foundMethod.invoke(me, mapping, form, request, response);
    	} catch (NoSuchMethodException e) {
    		return (ActionForward) me.getClass().getMethod("unspecified", ActionMapping.class, ActionForm.class, HttpServletRequest.class, HttpServletResponse.class)
    				.invoke(me,  mapping, form, request, response); }
    }
}
