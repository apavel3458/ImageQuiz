package org.imagequiz.util;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
import org.springframework.context.ApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;
 
public class SessionCounterListener implements HttpSessionListener {
      
     private static final Map<String, HttpSession> sessions = new HashMap<>();

     public static List<HttpSession> getActiveSessions() {
         return new ArrayList<>(sessions.values());
     }

 
    @Override
    public void sessionCreated(HttpSessionEvent hse) {
           // System.out.println("sessionCreated - add one session into counter");	
           sessions.put(hse.getSession().getId(), hse.getSession());
    }
 
    @Override
    public void sessionDestroyed(HttpSessionEvent hse) {
           // System.out.println("sessionDestroyed - deduct one session from counter");	
           sessions.remove(hse.getSession().getId());
    }	
  
//    private void printCounter(HttpSessionEvent sessionEvent){
//
//          HttpSession session = sessionEvent.getSession();
//
////          ApplicationContext ctx = 
////                WebApplicationContextUtils.
////                      getWebApplicationContext(session.getServletContext());
////
////          CounterService counterService = 
////                      (CounterService) ctx.getBean("counterService");
////
////          counterService.printCounter(totalActiveSessions);
//    }
}