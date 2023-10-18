/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.web;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.lang.management.ManagementFactory;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.management.MBeanServer;
import javax.management.ObjectName;
import javax.management.openmbean.CompositeData;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionRedirect;
import org.apache.struts.actions.DispatchAction;
import org.apache.struts.upload.FormFile;
import org.hibernate.SessionFactory;
import org.hibernate.jmx.StatisticsService;
import org.hibernate.stat.Statistics;
import org.imagequiz.HibernateUtil;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.Form;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQExercise;
import org.imagequiz.model.IQCaseTag;
import org.imagequiz.model.IQImage;
import org.imagequiz.model.IQTagGroup;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.properties.ImageQuizProperties;
import org.imagequiz.util.CaseParseException;
import org.imagequiz.util.CaseXMLParser;
import org.json.JSONObject;

import com.mchange.v2.c3p0.PooledDataSource;

/**
 *
 * @author apavel
 */
public class SurveillanceAction extends DispatchAction {
    protected static Log _log = LogFactory.getLog(AdminAction.class);
    
    protected IQDataSource dataSource;
    
    public void setIQDataSource(IQDataSource value) {
        dataSource = value;
    }
    
    @Override
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
    	//response.getWriter().println("Data Source Statistics Entities:" + dataSource.getSession().getStatistics().getCollectionCount());
    	
    	Statistics stats=dataSource.getSession().getSessionFactory().getStatistics();
    	response.getWriter().println("<pre>Session Open Count: " + stats.getSessionOpenCount());
    	response.getWriter().println("<pre>Session Close Count: " + stats.getSessionCloseCount());
    	
    	
    	PooledDataSource pds = (PooledDataSource) com.mchange.v2.c3p0.C3P0Registry.getPooledDataSources().toArray()[0];
    	
    	int numConnections = pds.getNumConnections();
    	
    	response.getWriter().println("<pre>NumConnections(): " + numConnections);
    	response.getWriter().println("<br/>NumBusyConnectionsAllUsers(): " + pds.getNumBusyConnectionsAllUsers());
    	response.getWriter().println("<br/>NumConnectionsAllUsers(): " + pds.getNumConnectionsAllUsers());
    	response.getWriter().println("<br/>NumIdleConnectionsAllUsers(): " + pds.getNumIdleConnectionsAllUsers());
    	response.getWriter().println("<br/>NumUnclosedOrphanedConnectionsAllUsers(): " + pds.getNumUnclosedOrphanedConnectionsAllUsers());
    	response.getWriter().println("<br/>SampleThreadPoolStatus(): " + pds.sampleThreadPoolStatus());
    	response.getWriter().println("<br/>ThreadPoolActiveThreads(): " + pds.getThreadPoolNumActiveThreads());
    	response.getWriter().println("<br/>ThreadPoolIdleThreads(): " + pds.getThreadPoolNumIdleThreads());
    	response.getWriter().println("<br/>ThreadPoolSize(): " + pds.getThreadPoolSize());
    	response.getWriter().println("<br/>NumUserPools(): " + pds.getNumUserPools());
    	response.getWriter().println("<br/>StatementCacheNumStatementsAllUsers(): " + pds.getStatementCacheNumStatementsAllUsers());
    	response.getWriter().println("<br/>StatementCacheNumConnectionsWithCachedStatementsAllUsers(): " + pds.getStatementCacheNumConnectionsWithCachedStatementsAllUsers());
    	response.getWriter().println("<br/>StatementCacheNumCheckedOutStatementsAllUsers(): " + pds.getStatementCacheNumCheckedOutStatementsAllUsers());
    	response.getWriter().println("<br/>StatementDestroyerNumIdleThreads(): " + pds.getStatementDestroyerNumIdleThreads());
    	response.getWriter().println("<br/>AllUsers(): " + pds.getAllUsers().toArray().length); 
    	response.getWriter().println("<br/>sampleStatementCacheStatusDefaultUser(): " + pds.sampleStatementCacheStatusDefaultUser());
    	response.getWriter().println("<br/>sampleStatementDestroyerStackTraces(): " + pds.sampleStatementDestroyerStackTraces());
    	response.getWriter().println("<br/>sampleThreadPoolStatus(): " + pds.sampleThreadPoolStatus());
    	response.getWriter().println("</pre>");
        return null;
    }
    
}
