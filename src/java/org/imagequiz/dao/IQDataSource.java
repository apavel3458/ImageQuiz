/*
 * To change this template, choose Tools | Templates

 * and open the template in the editor.
 * Complex query reference: 
 */

//complex query reference: https://docs.jboss.org/hibernate/orm/3.3/reference/en/html/querycriteria.html
package org.imagequiz.dao;
//http://www.sergiy.ca/how-to-write-many-to-many-search-queries-in-mysql-and-hibernate/
//amazing read

//ways to fetch:
//method 1: no initialization
/*Query q = this.em.createQuery("SELECT o FROM Order o JOIN FETCH o.items i WHERE o.id = :id");
		q.setParameter("id", orderId);
		newOrder = (Order) q.getSingleResult();*/

//method 2: (single object)
/*
 * Order order = this.em.find(Order.class, orderId);
 */

/*
 * List<IQExercise> exercise = session.createQuery("FROM IQExercise WHERE active = true").list();
 
 //Method 3:
  * session.createFilter(collection, queryString)
 */



import org.imagequiz.model.IQCaseDAO;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.Restrictions;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQUserGroup;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.web.AdminAction;
import org.imagequiz.model.IQExam;
import org.imagequiz.model.IQExercise;
import org.imagequiz.model.IQCaseTag;
import org.imagequiz.model.IQImage;
import org.imagequiz.model.question.IQSearchTermGroup;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.model.user.IQUserAchievement;
import org.springframework.transaction.annotation.Transactional;

/**
 *
 * @author apavel
 */
@Transactional
public class IQDataSource {
	
	protected static Log _log = LogFactory.getLog(IQDataSource.class);
	
	protected SessionFactory sessionFactory;
	
	public void setSessionFactory(SessionFactory value) {
	    sessionFactory = value;
	  }

	  // Shortcut for sessionFactory.getCurrentSession()
	public Session getSession() {
	    Session session = sessionFactory.getCurrentSession();
	    return session;
	}
	

   // public IQDataSource() {
    	//session = getSession();
   // }
    
    /*
    
    private Session getSession() {
    	if (session == null || !session.isOpen()) {
	    	session = HibernateUtil.getSessionFactory().getCurrentSession();
	    	
	    	session.beginTransaction();
	    	session.flush();
	    	session.clear();
	        if (!session.isOpen()) {
	        	//session = HibernateUtil.getSessionFactory().openSession();
	        }
    	}
        return session;
    }
    */
    public void evict(Object obj) {
    	Session session = getSession();
    	session.evict(obj);
    }
    public void merge(Object obj) {
    	Session session = getSession();
    	session.merge(obj);
    }
    
    public void saveOrUpdate(Object obj) {
    	Session session = getSession();
    	session.saveOrUpdate(obj);
    }
    
    public Object get(Class objClass, Long id) {
    	Session session = getSession();
    	return session.get(objClass, id);
    }
    
    public void update(Object obj) {
    	Session session = getSession();
    	session.update(obj);
    }
    
    public void delete(Object obj) {
    	Session session = getSession();
    	session.delete(obj);
    }
    
    public void flush() {
    	getSession().flush();
    }
    
/*
    public void close() {
    	if (session != null) {
    		if (session.isOpen()) {
    			session.close();
    		}
    	}
    }*/
    
    public static <T> List<T> castList(Class<? extends T> clazz, Collection<?> c) {
        List<T> r = new ArrayList<T>(c.size());
        for(Object o: c)
          r.add(clazz.cast(o));
        return r;
    }
    
    public IQCaseCompleted getCaseCompleted(Long caseId, Long userId, Long quizId) {
    	Session session = getSession();
    	Criteria crit = session.createCriteria(IQCaseCompleted.class);
    	crit.createCriteria("associatedCase").add(Restrictions.eq("caseId",  caseId));
    	crit.createCriteria("userQuiz").add(Restrictions.eq("quizId", quizId)).createCriteria("user").add(Restrictions.eq("userId", userId));

    	List<IQCaseCompleted> cases = crit.list();
    	System.out.println("found caseCompleted: " + cases.size() + " userId: " + cases.get(0).getCaseId() + " userId:" + cases.get(0).getUserQuiz().getUser().getUserId());
    	if (cases.size() == 0) return null;
    	else return cases.get(0);
    }
    
    public IQCase getCase(Long id) {
    	Session session = getSession();
        Criteria crit = session.createCriteria(IQCase.class);
        crit.add(Restrictions.eq("caseId", id));
        List<IQCase> cases = crit.list();

        if (cases.size() == 0) {
            return null;
        } else {
        	IQCase pulledCase = cases.get(0);
        	//System.out.println("Pulled case xml: " + pulledCase.getCaseXml());
        	session.update(pulledCase);
            return pulledCase;
        }
    }
    
    public Long saveCase(IQCase iqCase) {
    	Session session = getSession();
        
        Long caseId = iqCase.getCaseId();
        session.saveOrUpdate(iqCase);
        session.flush();
        return caseId;
    }
    
    public List<IQExercise> getActiveExerciseList() {
    	Session session = getSession();
    	List<IQExercise> exerciseList = session.createQuery("FROM IQExercise WHERE active = true").list();
        return exerciseList;
    }
    
    public List<IQExercise> getExerciseByName(String exerciseName) {
    	Session session = getSession();
    	
    	Criteria crit = session.createCriteria(IQExercise.class);
    	crit.add(Restrictions.eq("exerciseName", exerciseName));
    	return (List<IQExercise>) crit.list();
    }
    
    public IQExercise getExercise(Long id) {
    	Session session = getSession();
        Criteria crit = session.createCriteria(IQExercise.class);
        crit.add(Restrictions.eq("exerciseId", id));
        List<IQExercise> exercises = crit.list();
        if (exercises.size() == 0) {
            return null;
        } else {
            return exercises.get(0);
        }
    }
    
    public Long saveExercise(IQExercise caseList) {
    	Session session = getSession();
    	session.saveOrUpdate(caseList);
        //txn.commit();
    	session.flush();
        return caseList.getExerciseId();
    }
    
    
    public void deleteExercise(Long id) {
    	Session session = getSession();
        Transaction transaction = session.beginTransaction();
        IQExercise exercise = (IQExercise) session.get(IQExercise.class, id);
        session.delete(exercise);
        //transaction.commit();
        session.flush();
    }
    
    public IQCaseDAO getLastIQCase() {
    	Session session = getSession();
        List<IQCaseDAO> caseList = null;
        try {
            org.hibernate.Transaction tx = session.beginTransaction();
            Query q = session.createQuery("from IQCaseDAO as IQCase");
            caseList = (List<IQCaseDAO>) q.list();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return caseList.get(caseList.size()-1);
    }
    
   /* public Long addIQCase(IQCaseDAO iqCase) {
        //Session session = HibernateUtil.getSessionFactory().getCurrentSession();;
    	Session session = getSession();
        Long caseId = null;
        Transaction tx = null;
        try {
            tx = session.beginTransaction();
            caseId = (Long) session.save(iqCase);

        } catch (Exception e) {
            e.printStackTrace();
        } 
        txn.commit();
        return caseId;
    }*/
    
    
    public Long addImage(IQImage image) {
        //Session session = HibernateUtil.getSessionFactory().getCurrentSession();;
    	Session session = getSession();
        Long imageId = null;
        imageId = (Long) session.save(image);
        session.flush();
        //txn.commit();
        return imageId;
    }
    
    public List<IQImage> getImageList() {
        //Session session = HibernateUtil.getSessionFactory().getCurrentSession();;
    	Session session = getSession();
        Criteria crit = session.createCriteria(IQImage.class);
        //txn.commit();
        return crit.list();
    }
    
    //returns true if image is orphan and was deleted, false if still has cases associated
    public boolean deleteImageFromCase(Long imageId, Long caseId) {  
    	
    	IQCase iqcase = this.getCase(caseId);
    	List<IQImage> imagesForCase = iqcase.getImages();
    	boolean deleted = false;
    	for (int i=0; i<imagesForCase.size(); i++) {
    		if (imagesForCase.get(i).getImageId().equals(imageId)) {
    			iqcase.getImages().remove(i);
    		}
    	}
    	this.saveCase(iqcase);
    	
    	IQImage iqimage = this.getImage(imageId);
    	if (iqimage.getAssociatedCases().size() <= 1) {
    		//only association is the one we just removed (or none)
    		Session session = getSession();
        	session = getSession();
    		session.delete(iqimage);
            //txn.commit();
    		session.flush();
            deleted = true;
    	}
    	return deleted;
    }
    
    public void deleteImageFromAllCases(Long id) {
        //Session session = HibernateUtil.getSessionFactory().getCurrentSession();;
    	Session session = getSession();
    	
    	session = getSession();
        IQImage image = (IQImage) session.get(IQImage.class, id);
        //clear associations
        for (IQCase iqcase: image.getAssociatedCases()) {
        	List<IQImage> images = iqcase.getImages();
        	int i=0;
        	//remove this image from all cases (because bi-directional relationship)
        	for (IQImage curimage: images) {
        		if (curimage.getImageId().equals(id)) {
        			iqcase.getImages().remove(i);
        		}
        		i++;
        	}
        	this.saveCase(iqcase);
        }
        //delete orphan
        session.delete(image);
        //txn.commit();
        session.flush();
    }
    
    public IQImage getImage(Long imageId) {
        //Session session = HibernateUtil.getSessionFactory().getCurrentSession();;
    	Session session = getSession();
        Criteria crit = session.createCriteria(IQImage.class);
        
        crit.add(Restrictions.eq("imageId", imageId));
        List<IQImage> images = crit.list();
        //txn.commit();
        if (images.size() == 0) {
            return null;
        } else {
            return images.get(0);
        }
    }
    
    public List<IQCaseTag> getCaseTags(Long caseId, Long exerciseId) {
    	Session session = getSession();
    	String hql = "SELECT DISTINCT t from IQCaseTag t " +
    					"JOIN t.associatedExercise e JOIN t.associatedCases c " +
    					"WHERE e.exerciseId = :exerciseid AND c.caseId = :caseid";
    	Query q = session.createQuery(hql)
    			.setParameter("exerciseid", exerciseId)
    			.setParameter("caseid", caseId);
    	List<IQCaseTag> results = q.list();
    	session.flush();
    	return results;
    }
    
    public List<IQCaseTag> getCaseTagsForQuiz(Long caseId, Long quizId) {
    	
    	String hql = "SELECT DISTINCT t from IQCaseTag t " +
    					"JOIN t.associatedExercise e JOIN e.associatedExams ex JOIN ex.userQuizes q JOIN t.associatedCases c " +
    					"WHERE q.quizId = :quizId AND c.caseId = :caseid";
    	List<IQCaseTag> results = getSession().createQuery(hql, IQCaseTag.class)
    			.setParameter("quizId", quizId)
    			.setParameter("caseid", caseId)
    			.list();

    	return results;
    }
    
    public List<IQCaseTag> getAllTags(Long exerciseId) {
    	Session session = getSession();
    	String hql = "SELECT DISTINCT t from IQCaseTag t " +
    					"JOIN t.associatedExercise e " +
    					"WHERE e.exerciseId = :exerciseid";
    	Query q = session.createQuery(hql)
    			.setParameter("exerciseid", exerciseId);
    	List<IQCaseTag> results = q.list();
    	session.flush();
    	return results;
    }
    
    
    
    public List<IQCaseTag> getAllTags(String exerciseName) {
    	Session session = getSession();
    	String hql = "SELECT DISTINCT t from IQCaseTag t " +
    					"JOIN t.associatedExercise e " +
    					"WHERE e.exerciseName = :en";
    	Query q = session.createQuery(hql)
    			.setParameter("en", exerciseName);
    	
    	List<IQCaseTag> results = q.list();
    	session.flush();
    	return results;
    }
    
    public IQCaseTag getTagByName(String nameSearch, String exerciseName) {
    	Session session = getSession();
    	String hql = "SELECT DISTINCT t from IQCaseTag t " +
    					"join t.associatedExercise e " +
    					"where e.exerciseName = :exercisename AND t.tagName = :tagname";
    	Query q = session.createQuery(hql)
    			.setParameter("exercisename", exerciseName)
    			.setParameter("tagname", nameSearch);
    	List<IQCaseTag> results = castList(IQCaseTag.class, q.list());
    	
    	if (results.size() < 1) return null;
    	else return results.get(0);
    }
    
    public IQCaseTag getTagByName(String nameSearch, Long exerciseId) {
    	Session session = getSession();
    	// 
    	String hql = "SELECT DISTINCT t from IQCaseTag t " +
    					"join t.associatedExercise e " +
    					"where e.exerciseId = :exerciseid AND t.tagName = :tagname";
    	Query q = session.createQuery(hql)
    			.setParameter("exerciseid", exerciseId)
    			.setParameter("tagname", nameSearch);
    	List<IQCaseTag> results = castList(IQCaseTag.class, q.list());
    	
    	if (results.size() < 1) return null;
    	else return results.get(0);
    }
    
    public IQCaseTag getTagById(Long tagId) {
    	Session session = getSession();
    	
    	Criteria crit = session.createCriteria(IQCaseTag.class);
    	crit.add(Restrictions.eq("tagId", tagId));
    	List<IQCaseTag> results = crit.list();
    	if (results.size() < 1) return null;
    	else return results.get(0);
    }
    
    public void deleteTag(IQCaseTag tag) {
    	Session session = getSession();
    	

    	session.refresh(tag);
    	session.delete(tag);
    	session.flush();
    }
    
    public void saveTag(IQCaseTag tag) {
    	Session session = getSession();
    	
    	session.saveOrUpdate(tag);
    	session.flush();
    }
    
    public IQSearchTermGroup getSearchTermGroup(Long groupId) {
    	Session session = getSession();
    	
    	IQSearchTermGroup searchGroup = (IQSearchTermGroup) session.get(IQSearchTermGroup.class, groupId);
        return searchGroup;
    }
    
    public IQSearchTermGroup getSearchTermGroupByName(String nameString) {
    	Session session = getSession();
    	
    	Criteria crit = session.createCriteria(IQSearchTermGroup.class);
    	crit.add(Restrictions.eq("groupName", nameString));
    	List<IQSearchTermGroup> searchGroups = crit.list();
    	if (searchGroups == null || searchGroups.size() == 0) return null;
    	else return searchGroups.get(0);
    }
    
    public List<IQSearchTermGroup> getAllSearchTermGroups() {
    	Session session = getSession();
    	
    	String hql = "FROM IQSearchTermGroup";
    	Query query = session.createQuery(hql);
    	List<IQSearchTermGroup> results = query.list();
    	return results;
    }
    
    public Long saveSearchTermGroup(IQSearchTermGroup searchGroup) {
    	Session session = getSession();
    	
    	Long searchGroupId = (Long) session.save(searchGroup);
        return searchGroupId;
    }
    
    public Long saveObject(Object object) {
    	Session session = getSession();
    	
    	Long id = (Long) session.save(object);
        //txn.commit();
    	session.flush();
        return id;
    }
    
    public void softDeleteCase(IQCase iqCase) {
    	Session session = getSession();
    	
    	
    	iqCase.setActive(false);
    	
    	session.save(iqCase);
    	
    	
    	
    	//session.refresh(iqCase);
    	//session.delete(iqCase);
        //txn.commit();
    	session.flush();
    }
    
    public void deleteSearchGroup(Long id) {
    	Session session = getSession();
    	
        IQSearchTermGroup searchGroup = (IQSearchTermGroup) session.get(IQSearchTermGroup.class, id);
        session.delete(searchGroup);
        //txn.commit();
        session.flush();
    }
    
    
    //--------user stuff----
    public IQUser getUserByUsername(String username) {
    	Session session = getSession();
    	
    	Criteria crit = session.createCriteria(IQUser.class);
    	crit.add(Restrictions.eq("username", username));
    	List<IQUser> results = crit.list();
    	if (results.size() < 1) return null;
    	IQUser user = results.get(0);
    	//session.evict(user);
    	return user;
    }
    
    public IQUser getUserByEmail(String email) {
    	Session session = getSession();
    	String hql = "FROM IQUser WHERE email = :email";
    	List<IQUser> results = session.createQuery(hql)
    		.setParameter("email", email).list();
    	if (results.size() == 0) return null;
    	else return results.get(0);
    }
    
    public IQUser getUserById(Long userId) {
    	Session session = getSession();
    	IQUser iuser = session.get(IQUser.class, userId);
    	return iuser;
    }
    
    public IQUserQuiz getUserQuizById(Long quizId) {
    	//IQUserQuiz userQuiz =  getSession().createQuery("SELECT q FROM IQUserQuiz q WHERE q.quizId=:quizid", IQUserQuiz.class)
    	//    			.setParameter("quizid", quizId).uniqueResult();
    	IQUserQuiz userQuiz = (IQUserQuiz) getSession().load(IQUserQuiz.class, quizId);
    	return userQuiz;
    }
    
    public List<IQUserAchievement> getAllAchievements() {
    	List<IQUserAchievement> result =  this.getSession().createQuery("SELECT a FROM IQUserAchievement a", IQUserAchievement.class)
    			.list();
    	return result;
    }
    
    public List<IQUser> getAllUsers() {
    	Session session = getSession();
    	String hql = "FROM IQUser";
    	Query query = session.createQuery(hql);
    	List<IQUser> results = query.list();
    	return results;
    }
    
    public IQUserGroup getUserGroupByName(String groupName) {
    	Session session = getSession();
    	String hql = "FROM IQUserGroup WHERE groupName = :groupname";
    	List<IQUserGroup> results = session.createQuery(hql).setParameter("groupname", groupName).list();
    	if (results == null || results.size() == 0) return null;
    	else return results.get(0);
    }
    
    public IQUserGroup getUserGroupById(Long groupId) {
    	Session session = getSession();
    	String hql = "FROM IQUserGroup WHERE groupId = :groupid";
    	List<IQUserGroup> results = session.createQuery(hql).setParameter("groupid", groupId).list();
    	if (results == null || results.size() == 0) return null;
    	else return results.get(0);
    }
    
    public List<IQUserGroup> getUserAllGroups() {
    	Session session = getSession();
    	String hql = "FROM IQUserGroup";
    	return session.createQuery(hql).list();
    }
    
    public void deleteUser(IQUser user) {
    	Session session = getSession();
    	

    	session.refresh(user);
    	session.delete(user);
    	session.flush();
    	//txn.commit();
    }
    
    public List<IQCaseCompleted> getUserCompletedCasesByTag(String tagName) {
    	Session session = getSession();
    	Criteria crit = session.createCriteria(IQCaseCompleted.class, "compl")
                .createAlias("compl.associatedCase", "iqcase")
                .createAlias("iqcase.caseTags", "casetags")
                .add(Restrictions.eq("casetags.tagName", tagName));
    	return (List<IQCaseCompleted>) crit.list();
    }
    
    public List<IQCase> getCasesByTags(List<IQCaseTag> categories) {
    	Session session = getSession();
    	
    	String hql = "SELECT cs FROM IQCase AS cs INNER JOIN cs.caseTags as tags";
    	if (categories != null && categories.size() > 0) {
    		hql = hql + " WHERE ";
    	}
    	boolean first;
    	boolean last;
    	
    	for (int i=0; i<categories.size(); i++) {
    		IQCaseTag category = categories.get(i);
    		first = (i==0);
    		last = (i == categories.size()-1);
    		if (first) hql = hql + "(";
    		if (!first) hql = hql + " OR ";
    		hql = hql + "tags.tagId = " + category.getTagId();
    		if (last) hql = hql + ")";
    	}
    	if (categories.size() > 0) {
    		hql = hql + " AND cs.active = '1'";
    	} else {
    		hql = hql + " WHERE cs.active = '1'";
    	}
    	System.out.println("made query: " + hql);
    	Query query = session.createQuery(hql);
    	List<IQCase> results = query.list();
    	return results;
    }
    
    
    public List<IQExam> getExamsAll() {
    	Session session = getSession();
    	String hql = "FROM IQExam WHERE deleted = false";
    	return session.createQuery(hql).list();
    }
    public IQExam getExamById(Long id) {
    	Session session = getSession();
    	String hql = "FROM IQExam where examId = :id AND deleted = false";
    	List<IQExam> results = session.createQuery(hql)
    			.setParameter("id", id).list();
    	if (results.size() == 0) return null;
    	else return results.get(0);
    }
    
    public IQExam getExamByCode(String examCode) throws Exception {
    	Session session = getSession();
    	String hql = "FROM IQExam where cast(uniqueCode as binary) = cast(:examcode as binary) AND deleted = false";
    	List<IQExam> results = session.createQuery(hql)
    						.setParameter("examcode", examCode).list();
    	if (results.size() == 0) return null;
    	if (results.size() > 1) throw new Exception("The impossible happened: exam codes match");
    	else return results.get(0);
    }
    
    public IQCaseCompleted getCompeletedCaseById(Long completedCaseId) {
    	return (IQCaseCompleted) getSession().createQuery("SELECT cc FROM IQCaseCompleted cc WHERE cc.completedCaseId=:ccid", IQCaseCompleted.class)
    			.setParameter("ccid",completedCaseId).uniqueResult();
    }
}
