package org.imagequiz.web;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.imagequiz.model.user.IQUser;


public final class SecurityFilter implements Filter {
	   private static Logger _log = Logger.getLogger(SecurityFilter.class);

	   private FilterConfig filterConfig = null;
	   
	   public void init(FilterConfig filterConfig) 
	      throws ServletException {
	      this.filterConfig = filterConfig;
	   }
	   public void destroy() {
	      this.filterConfig = null;
	   }
	   public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
	      throws IOException, ServletException {
		   
		  HttpServletRequest req = (HttpServletRequest) request;
		  HttpServletResponse resp = (HttpServletResponse) response;
		  
		  
		  
		  String schema = req.getScheme();
		  String serverName = req.getServerName();
		  int serverPort = req.getServerPort();
		  String contextPath = req.getContextPath();
		  String basepath = schema + "://" + serverName + ":" + serverPort + contextPath;
		  String loginpath = basepath + "/login.jsp";
		  String dashboardURL = basepath + "/case/case.do?method=dashboard";
		  
		  //String fullRequestURL = req.getRequestURL().append('?').append(req.getQueryString()).toString();
		  // fullRequestURL gives entire URL: i.e. http://localhost:8080/ImageQuiz/admin/results.do?method=resultsByImageDiagnosis&examid=13
		  		  
		  IQUser user = (IQUser) req.getSession().getAttribute("security");
		  
		  String errorURL = null; //default error page.  If admin, see regular error pages
		  if (user != null && !user.isAdmin()) {
			  errorURL = dashboardURL;  // if logged in and see errors, take to dashboard
		  }
		  if (user != null && user.getSessionMode() != null && user.getSessionMode().equals(IQUser.SESSION_MODE_RESEARCH))
			  loginpath = basepath + "/study/registration.jsp";

		  int start = req.getContextPath().length()+1;
		  int end = req.getRequestURI().indexOf("/", start);
		  String folder;
		  if (end == -1) folder = "";
		  else folder = req.getRequestURI().substring(start, end);
		  
		  
		  //-------- ALLOW FOLDERS -----
		  if (folder.equals("") || 
				  folder.equals("/") || 
				  folder.equals("share") || 
				  folder.equals("css") || 
				  folder.equals("study")) {
			  continueRequest(request, response, chain, errorURL, "You lack permissions to access this page");
			  return;
		  }
		  
		  //------- ALLOW FILES -------
		  //assuming folder != "", otherwise next line will crash (above code ensures it isnt)
		  //allowing access to basic jquery in login screen
		  String[] allowedFiles = new String[] {
				  "jquery-1.10.1.min.js",
				  "jquery-1.12.4.min.js",
				  "bootstrap.min.js",
				  "jquery-placeholder.min.js",
				  "setupwizard.js",
				  "mobilewarning.js",
				  "bootstrap/bootstrap.min.js", 
				  "bootstrap/ie10-viewport-bug-workaround.js"
				  };
		  List<String> allowedFilesList = Arrays.asList(allowedFiles);
		  String requestedFile = req.getRequestURI().substring(end+1);
		  if (allowedFilesList.contains(requestedFile)) {
			  //allow access to first level of jslib
			  continueRequest(request, response, chain, null, null);
			  return;
		  }
		  
		  //----EVERYTHING ELSE IS RESTRICTED, CHECK USER ----
		  if (user == null) {
			  req.getSession().setAttribute("message", "You must log in to access this page");
			  
			  //ensure user is sent back to the URL they intended
			  String reentryPath = dashboardURL;
			  if (folder.equals("admin"))
				  //reentryPath = basepath + "/admin/admin.do";
				  reentryPath = req.getRequestURI().substring(contextPath.length()) + "?" + req.getQueryString();
			  
			  
			  //requestPath only gives the path /admin/results.do?method=results&caseId=54
			  req.getSession().setAttribute("requestPath", reentryPath);
			  
			  resp.sendRedirect(loginpath);
			  return;
		  }
		  if (user.isExamOnly()) {
			  if (folder.equals("exam") || folder.equals("jslib")) {
				  String failMessage = "Error has occured in the ECG quiz, please try to access it again to continue";
				  continueRequest(request, response, chain, loginpath, failMessage);
				  return;
			  } else {
				  req.getSession().setAttribute("message", "You lack permissions to access this page");
				  resp.sendRedirect(loginpath);
				  return;
			  }
		  }
		  // http://localhost:8080/ImageQuiz/admin/admin.do?method=editExercise&exerciseid=42
		  if (folder.equalsIgnoreCase("admin")) {
			  if (user.isAdmin() == true) {
				  chain.doFilter(request, response);
				  return;
			  } else {
		    	  req.getSession().setAttribute("message", "You lack permissions to access this page");
				  resp.sendRedirect(loginpath);
				  return;
			  }
		  }
		  
		  String failMessage = "Apologies!  An error has occured.  Please try again later.";
		  continueRequest(request, response, chain, errorURL, failMessage);
		  return;
	   }
	   
	   private void continueRequest(ServletRequest request, ServletResponse response, FilterChain chain, String failURL, String failMessage) throws IOException, ServletException {
		   try {
			   chain.doFilter(request, response);
		   } catch (Exception e) {
			   _log.error("Error Occured", e);
			   e.printStackTrace();
			   HttpServletResponse resp = (HttpServletResponse) response;
			   //if failURL is null, just throw regular error
			   if (failURL == null) {
				   chain.doFilter(request, response);
			   } else {
				   //if failURL exists, can formulate error message
				   
				   if (failMessage != null) {
					   ((HttpServletRequest) request).getSession().setAttribute("error", failMessage);
				   }
				   //resp.sendRedirect(failURL);  REMOVE ON DEPLOY
				   chain.doFilter(request, response);
			   }
		   }
	   }
	}