package org.imagequiz.web;

import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.TypedQuery;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.hibernate.query.Query;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.question.IQAnswerSearchTerm;
import org.imagequiz.model.question.IQAnswerSearchTermWrapper;
import org.imagequiz.model.question.IQSearchTermGroup;
import org.imagequiz.model.question.IQSearchTermSection;
import org.imagequiz.util.ActionSecurity;
import org.springframework.stereotype.Controller;

@Controller
public class AdminSearchTermAction extends DispatchAction {
    private static final boolean IQAnswerSearchTerm = false;

	protected static Log _log = LogFactory.getLog(AdminAction.class);
        
    protected IQDataSource dataSource;
    
    public void setIQDataSource(IQDataSource value) {
        dataSource = value;
      }
    
    public AdminSearchTermAction() {
    }
    
    @Override
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
	
        return list(mapping, form, request, response);
    }
    
    public ActionForward execute(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws InvocationTargetException, IllegalAccessException, NoSuchMethodException {
    	ActionSecurity actionSecurity = new ActionSecurity();
    	return actionSecurity.filter(mapping, form, request, response, this);
    }
    
    public ActionForward list(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	
    	
    	//if specified group
    	Long activeGroupId = (Long) request.getSession().getAttribute("activegroupid");
    	if (activeGroupId!= null) {
    		request.getSession().removeAttribute("orphanedSTs");
    		//IQSearchTermGroup g = dataSource.getSession().get(IQSearchTermGroup.class, activeGroupId);
    		Query<IQSearchTermGroup> query =dataSource.getSession().createQuery("SELECT g FROM IQSearchTermGroup g WHERE g.groupId = :groupId", IQSearchTermGroup.class).setParameter("groupId", activeGroupId);
            IQSearchTermGroup g = query.getResultList().get(0);
            if (g != null) {
            	request.setAttribute("selectedGroup", g);
            }
    	}
    	
    	//if loading orphaned STs
    	if (request.getSession().getAttribute("orphanedSTs") != null) {
    		//reload orphaned STs
    		List<IQAnswerSearchTerm> orphanedSts = new ArrayList();
            TypedQuery<IQAnswerSearchTerm> query =dataSource.getSession().createQuery("SELECT c FROM IQAnswerSearchTerm c", IQAnswerSearchTerm.class);
            List<IQAnswerSearchTerm> allSTs = query.getResultList();
            for (IQAnswerSearchTerm st: allSTs) {
            	if (st.getParentSections().size() == 0) {
            		orphanedSts.add(st);
            	}
            }
            request.getSession().setAttribute("orphanedSTs", orphanedSts);
    	}
    	
    	//load Groups
    	TypedQuery<IQSearchTermGroup> query =dataSource.getSession().createQuery("SELECT c FROM IQSearchTermGroup c", IQSearchTermGroup.class);
        List<IQSearchTermGroup> results = query.getResultList();
        
        //load all search terms (for auto-fill)
        TypedQuery<IQAnswerSearchTerm> queryST =dataSource.getSession().createQuery("SELECT c FROM IQAnswerSearchTerm c", IQAnswerSearchTerm.class);
        List<IQAnswerSearchTerm> allSTs = queryST.getResultList();
        
        request.setAttribute("searchGroups", results);
        request.setAttribute("availableSearchTerms", allSTs);
        return new ActionForward("/admin/searchterm.jsp");
    }
    
    public ActionForward showGroup(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String selectedGroupId = request.getParameter("viewgroupid");
    	if (selectedGroupId != null) { 
    		request.getSession().setAttribute("activegroupid", Long.parseLong(selectedGroupId)); 
    		request.getSession().removeAttribute("orphanedSTs");
    	}
    	return list(mapping, form, request, response);
    }
    
    public ActionForward showOrphanedST(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {

        request.getSession().setAttribute("orphanedSTs", "");
        request.getSession().removeAttribute("activegroupid");
        return list(mapping, form, request, response);
    }
    
    public ActionForward addGroup(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String groupName = request.getParameter("groupName");
    	if (groupName != null && groupName.length() > 0 && groupName.length() < 100) {
    		IQSearchTermGroup newGroup = new IQSearchTermGroup();
    		newGroup.setGroupName(groupName);
    		dataSource.getSession().save(newGroup);
    		request.getSession().setAttribute("activegroupid", newGroup.getGroupId());
    	}
    	return list(mapping, form, request, response);
    }
    
    public ActionForward deleteGroup(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String groupId = request.getParameter("groupid");
		IQSearchTermGroup g = dataSource.getSession().get(IQSearchTermGroup.class, Long.parseLong(groupId));
		for (IQSearchTermSection section: g.getAssociatedSections()) {
			for (IQAnswerSearchTerm st: section.getAssociatedSearchTerms()) {
				st.getParentSections().remove(section);
				dataSource.getSession().save(st);
			}
		}
		request.getSession().removeAttribute("activegroupid");
		dataSource.getSession().delete(g);
		return list(mapping, form, request, response);
    }
    
    public ActionForward editGroup(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String groupId = request.getParameter("groupid");
    	String groupName = request.getParameter("groupname");
    	if (groupName != null && !groupName.equals("")) {
    		IQSearchTermGroup g = dataSource.getSession().get(IQSearchTermGroup.class, Long.parseLong(groupId));
    		g.setGroupName(groupName);
    		dataSource.getSession().save(g);
    	}
		return list(mapping, form, request, response);
    }
    
    public ActionForward addSection(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String sectionName = request.getParameter("sectionname");
    	Long groupId = (Long) request.getSession().getAttribute("activegroupid");
		IQSearchTermGroup group = dataSource.getSession().get(IQSearchTermGroup.class, groupId);
    	if (sectionName != null && group != null) {
    		IQSearchTermSection newSection = new IQSearchTermSection();
    		newSection.setParentGroup(group);
    		newSection.setSectionName(sectionName);
    		dataSource.getSession().save(newSection);
    	}
		return list(mapping, form, request, response);
    }
    
    public ActionForward editSection(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String sectionName = request.getParameter("sectionname");
    	String sectionId = request.getParameter("sectionid");
    	if (sectionName != null && sectionId != null) {
    		IQSearchTermSection section = dataSource.getSession().get(IQSearchTermSection.class, Long.parseLong(sectionId));
    		section.setSectionName(sectionName);
    		dataSource.getSession().save(section);
    	}
		return list(mapping, form, request, response);
    }
    
    public ActionForward deleteSection(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String sectionId = request.getParameter("sectionid");
    	if (sectionId != null) {
    		IQSearchTermSection section = dataSource.getSession().get(IQSearchTermSection.class, Long.parseLong(sectionId));
    		for (IQAnswerSearchTerm term: section.getAssociatedSearchTerms()) {
    			term.getParentSections().remove(section);
    			dataSource.getSession().save(term);
    		}
    		dataSource.getSession().delete(section);
    	}
		return list(mapping, form, request, response);
    }
    
    public ActionForward addTerm(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String termNameStr = request.getParameter("termname").trim();
    	String termName;
    	String termKeys = "";
    	if (termNameStr.contains("[")) {
    		termName = termNameStr.substring(0, termNameStr.indexOf("[")).trim();
    		termKeys = termNameStr.substring(termNameStr.indexOf("[")+1, termNameStr.length()-1).trim();
    	} else {
    		termName = termNameStr;
    	}
    	String sectionId = request.getParameter("sectionid");
    	IQSearchTermSection section = dataSource.getSession().get(IQSearchTermSection.class, Long.parseLong(sectionId));
    	if (termName != null && !termName.equals("") && sectionId != null) {
    		//try to find term name
    		Query<IQAnswerSearchTerm> query =dataSource.getSession().createQuery("SELECT c FROM IQAnswerSearchTerm c WHERE c.searchTermString = :searchname", IQAnswerSearchTerm.class).setParameter("searchname", termName);
            List<IQAnswerSearchTerm> results = query.getResultList();
            ;
            if (results.size() > 0) {
        		if (section.getAssociatedSearchTerms().contains(results.get(0))) {
        			request.setAttribute("message", "This section already contains '" + termName +"'");
        			return list(mapping, form, request, response);
        		}

        		IQAnswerSearchTerm ast = results.get(0);
        		ast.getParentSections().add(section);
        		section.getAssociatedSearchTerms().add(ast);
        		dataSource.getSession().update(ast);
        		
            } else {
            	IQAnswerSearchTerm  ast = new IQAnswerSearchTerm();
            	ast.setSearchTermString(termName);
            	if (!termKeys.equals("")) 
            		ast.setSearchKeys(termKeys);
        		ast.getParentSections().add(section);
        		section.getAssociatedSearchTerms().add(ast);
        		dataSource.getSession().save(ast);
            }
    		//dataSource.getSession().flush();
    	}
		return list(mapping, form, request, response);
    }
    
    public ActionForward editTerm(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String termId = request.getParameter("searchtermid");
    	String termName = request.getParameter("searchtermname");
    	String termKeys = request.getParameter("searchtermkeys");
    	IQAnswerSearchTerm st = dataSource.getSession().get(IQAnswerSearchTerm.class, Long.parseLong(termId));
    	if (termName != null && !termName.equals("") && st != null) {
    		//try to find term name
    		Query<IQAnswerSearchTerm> query =dataSource.getSession().createQuery("SELECT c FROM IQAnswerSearchTerm c WHERE c.searchTermString = :searchname", IQAnswerSearchTerm.class).setParameter("searchname", termName);
    		List<IQAnswerSearchTerm> results = query.getResultList();  //there would always be one (MySQL constraint)
            if (results.size() > 0 && results.get(0).getSearchTermId() != Long.parseLong(termId)) {
            	request.setAttribute("errorSTmessage", "Error: Name '" + termName + "' already exists, select another");
            	request.setAttribute("errorSTid", termId);
            	request.setAttribute("errorSTname", termName);
            	request.setAttribute("errorSTkeys", termKeys);
            } else {
            	st.setSearchTermString(termName);
            	st.setSearchKeys(termKeys);
            	dataSource.getSession().save(st);
            }
    	} else {
    		System.out.println("CANNOT FIND SOMETHING: " + termId + termName + termKeys);
    	}
		return list(mapping, form, request, response);
    }
    
    public ActionForward removeTerm(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	String termId = request.getParameter("searchtermid");
    	String sectionId = request.getParameter("sectionid");
    	IQSearchTermSection section = dataSource.getSession().get(IQSearchTermSection.class, Long.parseLong(sectionId));
    	if (termId != null && section != null) {
    		//try to find term name
        	IQAnswerSearchTerm st = dataSource.getSession().get(IQAnswerSearchTerm.class, Long.parseLong(termId));
            st.getParentSections().remove(section);
    		dataSource.getSession().save(st);
    	}
    	return list(mapping, form, request, response);
    }
    
    public ActionForward deleteTerm(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	//NEVER DELETE A TERM THAT IS STILL USED!!!
    	String termId = request.getParameter("searchtermid");
    	IQAnswerSearchTerm st = dataSource.getSession().get(IQAnswerSearchTerm.class, Long.parseLong(termId));
    	if (st != null) {
    		//try to find term name
            if (st.getAssociatedWrappers().size() > 0) {
    			String message = "Item still associated with cases, please remove from case answers first.  Cases:";
    			for (IQAnswerSearchTermWrapper wrapper: st.getAssociatedWrappers()) {
    				message = message + wrapper.getParentQuestionLine().getParentQuestion().getParentCase().getCaseName() + 
    						" (" + wrapper.getParentQuestionLine().getParentQuestion().getParentCase().getCaseId() + ") ";
    			}
            	request.setAttribute("message", message);
    			return list(mapping, form, request, response);
            } else {
            	//if Item not associated with any cases:
            	dataSource.getSession().delete(st);
            }
    	}
    	return showOrphanedST(mapping, form, request, response);
    }
    
}