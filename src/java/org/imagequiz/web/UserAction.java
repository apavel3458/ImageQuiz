/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.web;

import java.io.IOException;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;

import javax.crypto.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionRedirect;
import org.apache.struts.actions.DispatchAction;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQExam;
import org.imagequiz.model.IQExercise;
import org.imagequiz.model.IQSetting;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserGroup;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.properties.ImageQuizProperties;
import org.imagequiz.util.AuthUtil;
import org.imagequiz.util.BCrypt;
import org.imagequiz.util.ExamUtil;
import org.imagequiz.util.VerifyRecaptcha;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;


/**
 *
 * @author apavel
 */
public class UserAction extends DispatchAction {
    protected static Log _log = LogFactory.getLog(UserAction.class);
    
    protected IQDataSource dataSource;
    
    public void setIQDataSource(IQDataSource value) {
        dataSource=value;
      }
    
    @Override
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
	
        return new ActionRedirect("index.jsp");
    }
    
    public ActionForward list(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
        List<IQExercise> exerciseList = dataSource.getActiveExerciseList();
        System.out.println("found exercises: " + exerciseList.size());
        request.setAttribute("exerciselist", exerciseList);
        return new ActionForward("/admin/admin.jsp");
    }
    
    public ActionForward logout(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	request.getSession().removeAttribute("security");
    	request.getSession().invalidate();
    	return new ActionForward("/index.jsp");
    }
    
    public ActionForward registerUser(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	ActionForward forward = new ActionForward("/register.jsp");
    	String username = request.getParameter("username");
    	if (username != null) username = username.trim();
    	String password = request.getParameter("password").trim();
    	String password2 = request.getParameter("password2").trim();
    	String email = request.getParameter("email").trim();
    	String firstName = request.getParameter("firstname").trim();
    	String lastName = request.getParameter("lastname").trim();
    	String nobots = request.getParameter("nobots").trim();  
    	
    	Enumeration varnames = request.getParameterNames();
    	while (varnames.hasMoreElements()) {
    		String curname = (String) varnames.nextElement();
    		request.setAttribute(curname, request.getParameter(curname).trim());
    	}
    	

    	//----validation
    	if (!nobots.equalsIgnoreCase("heart")) {
    		request.setAttribute("message", "Error: Wrong answer to test question, try again.  Answer is one simple word.");
    		return forward;
    	}
    	if (!password.equals(password2)) {
    		request.setAttribute("message", "Error: Passwords do not match.");
    		return forward;
    	}
    	if (password.equals("") || email.equals("")) {
    		request.setAttribute("message", "Error: Missing required field.");
    		return forward;
    	}
    	//validation complete------------
    	
    	IQUser user = new IQUser();
    	user.setUsername(username);
    	user.setPasswordHash(hash(password));
    	user.setEmail(email);
    	user.setFirstName(firstName);
    	user.setLastName(lastName);

    	if (username != null && dataSource.getUserByUsername(username) != null) {
    		request.setAttribute("message", "Username taken, please pick a different one.");
    		return forward;
    	}
    	if (dataSource.getUserByEmail(email) != null) {
    		request.setAttribute("message", "Email already registered. If you took a test in the past, try to log in with your e-mail for username and password");
    		return forward;
    	}
    	dataSource.saveObject(user);
    	
 	   
		IQUserGroup group = dataSource.getUserGroupByName("Public");
		group.getUsers().add(user);
		dataSource.saveOrUpdate(group);
		
	   
    	
    	request.getSession().setAttribute("message", "Success!  User created.");
    	ActionRedirect aresponse = new ActionRedirect("/index.jsp");
    	return aresponse;
    }
    
    public ActionForward loginGuest(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	ActionRedirect redirect = new ActionRedirect("/user.do");
    	redirect.addParameter("method", "login");
    	redirect.addParameter("username", "guest");
    	redirect.addParameter("password", "guest3458");
    	return redirect;
    }
    
    public ActionForward login(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	HttpSession session = request.getSession(false);
    	if (session != null) {
    	    session.invalidate();
    	}
    	
    	request.getSession().removeAttribute("security");
    	request.getSession().removeAttribute("exam");
    	request.getSession().removeAttribute("quiz");
    	String username = request.getParameter("username");
    	String password = request.getParameter("password");
    	String requestPath = request.getParameter("requestPath");
    	
    	String returnPath = "/index.jsp";
    	String loginJspPath = "/login.jsp";
    	String originParameter = request.getParameter("origin");
    	//if originParameter specified, then return to origin any errors
    	//if originParmaeter not specified return to index page. 
    	//if special errors come up (such as DB problems) return to login.jsp because it has more room to display them
    	if (originParameter != null && originParameter.equalsIgnoreCase("login")) {
    		returnPath = loginJspPath;
    	}
    	
    	//if puts in login code, trumps regular login, will try to access exam.
    	ActionForward result = handleExamLoginCodes(request);
    	if (result != null) return result;
    	
    	
    	//------------end exam code--
    	
    	IQUser user = dataSource.getUserByUsername(username);
    	if (user == null) {
    		//try again with e-mail
    		user = dataSource.getUserByEmail(username);
    		if (user == null) {
    			request.getSession().setAttribute("requestPath", requestPath);
    			request.getSession().setAttribute("message", "Cannot find user");
    			return new ActionRedirect(returnPath);
    		}
    	}
    	String givenHash = hash(password);

    	if (givenHash.equals(user.getPasswordHash())) {
    		acceptUser(request, user);
    	} else {
    		request.getSession().setAttribute("requestPath", requestPath);
    		request.getSession().setAttribute("message", "Incorrect Password");
    		return new ActionRedirect(returnPath);
    	}
    	
    	return directUser(request, user);
    }
    
    public void acceptUser(HttpServletRequest request, IQUser user) {
    	user.setLastLogin(new Date());
    	SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");  
    	_log.info("Login for user " + user.getUserId() + " time: " + sdf.format(new Date()));
    	user.setLoginCount(user.getLoginCount()+1);
    	user.getUserGroups().size(); // loads all groups 
    	dataSource.saveOrUpdate(user);
    	user.getPermissions().size();
    	dataSource.evict(user);
		user.setPasswordHash(""); //clear password so doesn't hang around
		request.getSession().setAttribute("security", user);
    }
    
    public ActionForward handleExamLoginCodes(HttpServletRequest request) {
    	String loginJspPath = "/login.jsp";
    	String loginCode = request.getParameter("logincode");

    	
    	if (loginCode != null && !loginCode.equals("")) {
    		try {
	    		String examCode = ExamUtil.getExamCodeFromAccessKey(loginCode);
	    		Long userId = ExamUtil.getUserIdFromAccessKey(loginCode);
	    		
	    		if (examCode == null || examCode.equals("")) {
	    			request.getSession().setAttribute("message", "Incorrect login code (1)");
	        		return new ActionRedirect(loginJspPath);
	    		}
	    		
	    		IQExam iexam = dataSource.getExamByCode(examCode);
	    		if (iexam == null) {
	    			request.getSession().setAttribute("message", "Incorrect login code (2)");
	        		return new ActionRedirect(loginJspPath);
	    		}
	    		if (!iexam.isActive()) {
	    			request.getSession().setAttribute("message", "Current Exam is Closed");
	        		return new ActionRedirect(loginJspPath);
	    		}
	    		// at this point the exam is correct, login code is accurate.
	    		
	    		//try to find user
	    		if (userId == null) { 
	    			
	    		} else {
	    			IQUser iuser = dataSource.getUserById(userId);
	    			iuser.setExamOnly(true);
	    			_log.info("Found user lastname: " + iuser.getLastName());
	    			acceptUser(request, iuser);
	    		}
	    		request.setAttribute("loginCode", loginCode);
	    		return new ActionForward("/examregister.jsp");
    		} catch (Exception e) {
    			request.getSession().setAttribute("message", "Incorrect login code (3)");
    			_log.error("Exception during parsing exam code, must be malformed code: " + loginCode);
        		return new ActionRedirect(loginJspPath);
    		}
    	} else {
    		return null;
    	}
    }
    
    public ActionRedirect directUser(HttpServletRequest request, IQUser user) {
    	
    	String requestPath = request.getParameter("requestPath");
    	ActionRedirect redirect;
    	
    	
    	if (requestPath != null && !requestPath.equals("")) {
    		System.out.println("request path:" + requestPath);
    		redirect = new ActionRedirect(requestPath);
        } else if (user.isAdmin()) {
    		redirect = new ActionRedirect("/admin/admin.do");
    	} else {
    		redirect = new ActionRedirect("/case/case.do");
    		redirect.addParameter("method", "dashboard");
    	}
    	return redirect;
    }
    
    public static String hash(String text) throws Exception {
    	return DigestUtils.sha256Hex(text);
    	//return BCrypt.hashpw(text, BCrypt.gensalt());
    }
    
    public static String hash8char(String text) throws Exception {
    	return DigestUtils.sha256Hex(text).substring(0, 6);
    	//return BCrypt.hashpw(text, BCrypt.gensalt());
    }
    
    
    /*public static boolean checkLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
    	HttpSession session = request.getSession(false);// don't create if it doesn't exist
    	if(session != null && !session.isNew()) {
    	    return true;
    	} else {
    	    response.sendRedirect("/index.jsp");
    	    return false;
    	}
    }*/
    
    public ActionForward loginForExam(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	IQUser user = (IQUser) request.getSession(true).getAttribute("security");
    	String email = request.getParameter("email").trim();
    	String firstName = request.getParameter("firstname");
    	if (firstName != null) firstName = firstName.trim();
    	String lastName = request.getParameter("lastname");
    	if (lastName != null) lastName = lastName.trim();
    	String loginCode = request.getParameter("logincode").trim();
    	if (loginCode != null) loginCode = loginCode.trim();
    	String examCode = ExamUtil.getExamCodeFromAccessKey(loginCode);
    	IQExam iexam = dataSource.getExamByCode(examCode);
    	request.getSession().setAttribute("exam", iexam);
    	
    	ActionForward error = new ActionForward("/examregister.jsp");
    	if (email == null || email.equals("")) {
			request.setAttribute("message", "Email cannot be blank");
			request.setAttribute("loginCode", loginCode);
			return error;
		}
    	
    	if (user != null) {
    		
    			//update e-mail
    		IQUser iuser = dataSource.getUserById(user.getUserId());
    		iuser.setEmail(email);
    		dataSource.saveObject(iuser);
    	} else {
    		// code put in without a user, try to find the e-mail.
    		IQUser foundUser = dataSource.getUserByEmail(email);
    		if (foundUser != null) {
    			//check if user is in correct group.
    			//if (iexam.getUserGroup().isUserInGroup(foundUser)) {
	    			foundUser.setExamOnly(true);
	    			acceptUser(request, foundUser);
    			//} else {
    				//request.setAttribute("message", "The user with that e-mail address is already registered and is not in the '" + iexam.getUserGroup().getGroupName() + "' group.  Please contact the instructor/administrator to change this or enter a different email.");
    				//request.setAttribute("loginCode", loginCode);
    				//return error;
    			//}
    		} else {
    			//register new user
    			IQUser newUser = new IQUser();
    			newUser.setUsername(email);
    			newUser.setFirstName(firstName);
    			newUser.setLastName(lastName);
    			newUser.setEmail(email);
    			newUser.setPasswordHash(hash(email));
    			dataSource.saveObject(newUser);
    			newUser.getPermissions().size();
    			dataSource.evict(newUser);
    			//put into group:
    			IQUserGroup igroup = iexam.getUserGroup();
    			igroup.getUsers().add(newUser);
    			dataSource.saveOrUpdate(igroup);
    			
    			acceptUser(request, newUser);
    		}
    	}
		ActionRedirect redirect = new ActionRedirect("/exam/exam.do");
		redirect.addParameter("method", "prepareExam");
		return redirect;
    }
    
    
    public ActionForward loginForStudy(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	//IQUser user = (IQUser) request.getSession(true).getAttribute("security");
    	String username = request.getParameter("userid").toLowerCase();
    	if (username == null || username.equals("")) {
    		ActionRedirect redirect = new ActionRedirect("/study/registration.jsp");
			request.getSession().setAttribute("error", "Please enter a User ID");
			request.getSession().setAttribute("openLogin", "true");
			return redirect;
    	}
    	
    	String hashUsername = hash8char(username);
    	IQUser iuser = dataSource.getUserByUsername(hashUsername);

    	if (iuser == null) {
    		ActionRedirect redirect = new ActionRedirect("/study/registration.jsp");
    		request.getSession().setAttribute("error", "Unable to find User ID");
    		request.getSession().setAttribute("openLogin", "true");
    		return redirect;
    	}
    	
    	
    	if (iuser.getUserGroups().size() < 1 || !iuser.getUserGroups().get(0).getGroupName().equals("Research")) {
    		ActionRedirect redirect = new ActionRedirect("/study/registration.jsp");
    		request.getSession().setAttribute("error", "User ID invalid");
    		request.getSession().setAttribute("openLogin", "true");
    		return redirect;
    	}
    	
    	iuser.setSessionMode(IQUser.SESSION_MODE_RESEARCH);
    	iuser.setExamOnly(true);
		
    	
    	
    	
    	String allocation = iuser.getUserVars().get("allocation");
    	if (allocation == null) {
    		allocation = randomAllocation();
    		iuser.getUserVars().put("allocation", allocation);
    		dataSource.saveObject(iuser);
    	}
    	Long practiceSet = getAssignedExamId(allocation);
    	
    	acceptUser(request, iuser);
    	
    	IQExam iexam = dataSource.getExamById(practiceSet);
    	//IQExam iexam = dataSource.getExamById(new Long(5));
    	
    	IQSetting util = new IQSetting();
    	List<IQUserQuiz> qList = iexam.getAllUserQuizes(dataSource, iuser.getUserId());
    	Long daysToWait = Long.parseLong(util.getProperty(dataSource.getSession(), "eecg.daysToWait"));
    	if (qList.size() > 0) { //has previously started part 1
    		IQUserQuiz part1quiz = qList.get(0); // get last one
    		if (part1quiz.isCompleted()) {  //finished first part
    			Long diffDays = differenceInDays(part1quiz.getDateLastActive(), new Date());
    			if (diffDays < daysToWait) {
    				ActionForward examNotYet = new ActionForward("/exam/examresearchnotyet.jsp");
    				request.setAttribute("daysLeft", daysToWait-diffDays);
    				return examNotYet;
    			} else {		//start part 2
    				
    				Long delayedPostTestId = Long.parseLong(util.getProperty(dataSource.getSession(), "eecg.delayedPostTest"));
    				IQExam iiexam = dataSource.getExamById(delayedPostTestId);
    				request.getSession().setAttribute("researchPart2", true);
    		    	request.getSession().setAttribute("exam", iiexam);

    				ActionRedirect redirect = new ActionRedirect("/exam/exam.do");
    				redirect.addParameter("method", "prepareExam");
    				return redirect;
    			}
    		}
    	}
    	System.out.println("HERE");
    	request.getSession().setAttribute("exam", iexam);

		ActionRedirect redirect = new ActionRedirect("/exam/exam.do");
		redirect.addParameter("method", "prepareExam");
		return redirect;
    }
    
    private Long differenceInDays(Date start, Date end) {
    	long diffTime = end.getTime() - start.getTime();
    	long diffDays = diffTime / (1000 * 60 * 60 * 24);
    	return diffDays;
    }
    
    
    public ActionForward registerForStudy(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	//IQUser user = (IQUser) request.getSession(true).getAttribute("security");
    	String username = request.getParameter("userid").toLowerCase();
    	String hashUsername = hash8char(username);
    	if (username == null || username.equals("") || dataSource.getUserByUsername(hashUsername) != null)
    		return null;  // should have already been handled in the form
    	
    	IQUser iuser = new IQUser();
    	IQUserGroup researchGroup = dataSource.getUserGroupByName("Research");// put user in research user group
    	iuser.getUserGroups().add(researchGroup);
    	researchGroup.getUsers().add(iuser);
    	iuser.setUsername(hashUsername);
    	iuser.setExamOnly(true);
    	iuser.setSessionMode(IQUser.SESSION_MODE_RESEARCH);
    	
    	//add parameters
    	Enumeration<String> registrationInfo = request.getParameterNames();
    	while (registrationInfo.hasMoreElements()) {
    		String currentName = registrationInfo.nextElement();
    		String currentVar = request.getParameter(currentName);
    		if (currentName != null && !currentName.equals("") 
    				&& currentVar != null && !currentVar.equals("")) {
    			iuser.getUserVars().put(currentName, currentVar);
    		}
    	}
    	
    	String allocation = randomAllocation();
    	iuser.getUserVars().put("allocation", allocation);
    	
    	dataSource.saveObject(iuser);
    	dataSource.saveOrUpdate(researchGroup);
		
    	acceptUser(request, iuser);
    	
    	Long practiceSet = getAssignedExamId(allocation);
    	
    	
    	IQExam iexam = dataSource.getExamById(practiceSet);
    	//IQExam iexam = dataSource.getExamById(new Long(5));
    	request.getSession().setAttribute("exam", iexam);

		ActionRedirect redirect = new ActionRedirect("/exam/exam.do");
		redirect.addParameter("method", "prepareExam");
		return redirect;
    }
    
    private String randomAllocation() {
    	long allocationRandom = Math.round(Math.random());
    	System.out.println("allocation: " + allocationRandom);
    	String allocation = allocationRandom==0?"mcq":"sg";
    	System.out.println("allocation: " + allocation);
    	return allocation;
    }
    
    private Long getAssignedExamId(String allocation) {
    	Long practiceSet = null;
    	IQSetting util = new IQSetting();
    	if (allocation == null) {
    		allocation = randomAllocation();
    	}
    	if (allocation.equals("mcq"))
    		practiceSet = Long.parseLong(util.getProperty(dataSource.getSession(), "eecg.mcq"));
    	else if (allocation.equals("sg"))
    		practiceSet = Long.parseLong(util.getProperty(dataSource.getSession(), "eecg.sg"));
    	return practiceSet;
    }
    
    public ActionForward checkUsername(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String userName = request.getParameter("userid");
    	System.out.println("checking" + userName);
    	if (userName != null 
    			//&& (dataSource.getUserByUsername(userName) == null 
    			    && dataSource.getUserByUsername(hash8char(userName)) == null) {
    		response.getWriter().println("available");
    	} else {
    		response.getWriter().println("unavailable");
    	}
    	return null;
    }
    
    public ActionForward reloadProperties(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	ImageQuizProperties.reloadPropertiesFile();
    	response.getWriter().println("Reloaded!");
    	response.getWriter().flush();
    	return null;
    }
    
    public ActionForward portal(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	String signature = request.getParameter("signature");
    	String payload = request.getParameter("payload");
    	String requestPath = request.getParameter("requestPath");
    	//signature = "3b9884d126a6f382120199ca5d252dd255098753ef0e2b3585727c2834bdce8e"; //test request
    	//payload = "{\"userid\":2,\"timestamp\":1583814248683}"; // test request
    	_log.debug("signature: " + signature);
    	_log.debug("requestPath: " + requestPath);
    	_log.debug("payload: " + payload);
    	
    	// CHECK OF REQUEST PAYLOAD IS AUTHENTIC BY HMAC SHA-256 ALGORITHM
		List<String> result = dataSource.getSession().createQuery("SELECT s.value FROM IQSetting s "
				+ "WHERE s.name=:settingName", String.class)
		.setParameter("settingName", "auth.portal.key").list();
		
		String key = result.get(0);
    	
    	String sentSignature = AuthUtil.hmacDigest(payload, key, "HmacSHA256");
    	if (sentSignature.equals(signature)) {
    		_log.debug("AUTHENTIC!");
        	Gson gson = new GsonBuilder().serializeNulls().create();
         	HashMap<String, Object> payloadMap = gson.fromJson(payload, HashMap.class);
         	
         	long timeInMillis = ((Double) payloadMap.get("timestamp")).longValue();
        	// Avoid HMAC re-injection attack by checking the time and expiration
         	if (AuthUtil.timeCheck(timeInMillis, 20)) {
         		Long userId = ((Double) payloadMap.get("userid")).longValue();
         		IQUser iuser = dataSource.getSession().get(IQUser.class, userId);
         		request.getSession().setAttribute("portal", true);
         		acceptUser(request, iuser);
         		return directUser(request, iuser);
         	} else {
         		response.getWriter().println("Error: Time check failed");
         		return null;
         	}
    	} else {
    		_log.debug("NOT AUTHENTIC!");
    		response.getWriter().println("Error: Bad request");
     		return null;
    	}
    	
    }
    
}
