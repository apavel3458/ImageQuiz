/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz;

import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.imagequiz.properties.ImageQuizProperties;

/**
 *
 * @author apavel
 */
public class Startup implements ServletContextListener {
    protected static Log _log = LogFactory.getLog(Startup.class);
    
    public void contextInitialized(ServletContextEvent sc) {
        SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss MMM dd, yyyy");
        System.out.println("Deploying imagequiz.......  Date: " + formatter.format(new Date()));
                //tomcat5 server api does not support this
        //String applicationName = sc.getServletContext().getContextPath();
        
        //GET context path the classic way:
        String servletContext = "";
	try {
            String url = sc.getServletContext().getResource("/").getPath();
            int idx = url.lastIndexOf('/');
            url = url.substring(0,idx);

            idx = url.lastIndexOf('/');
            url = url.substring(idx+1);

            idx = url.lastIndexOf('.');
            if (idx > 0) url = url.substring(0,idx);

            servletContext = url;
	} catch (Exception e) {
            e.printStackTrace();
	}
        
        _log.info("**Initializing properties..........");
        try {
            ImageQuizProperties.reloadPropertiesFile();
            _log.info("ok");
        } catch (Exception e) {
            //e.printStackTrace();
            _log.error(e);
        }
        
        //load test case
        try {
            //CaseAction iqCaseAction = new CaseAction();
            //iqCaseAction.addTestCase();
        } catch (Exception e) {
            e.printStackTrace();
        }
        /*
        _log.info("**Starting databases ........");
        try {
            IQDataSourceJDBC dataSource = new IQDataSourceJDBC();
            dataSource.getConnection()
        }*/
    }
    
    
    
    public void contextDestroyed(ServletContextEvent arg0) {}
    
}
