/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.OrderColumn;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

import static javax.persistence.GenerationType.IDENTITY;

import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.Transient;
import javax.persistence.TypedQuery;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.IndexColumn;
import org.hibernate.annotations.Where;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.question.IQAnswerSearchTerm;
import org.imagequiz.model.user.IQUserQuiz;

import com.google.gson.annotations.Expose;

/**
 *
 * @author apavel
 */

@Entity
@Table(name = "iqexercise")
public class IQExercise implements Serializable {
	@Expose
    @Column(name = "exercisename")
    private String exerciseName;
    
	@Expose
    @Id
    @Column(name = "exerciseid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
    private Long exerciseId;
    
    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "iqexercisecaselink", 
            joinColumns = {@JoinColumn(name = "exerciseid")}, 
            inverseJoinColumns = {@JoinColumn(name = "caseid") })
    @OrderColumn(name="caseorder")
    private List<IQCase> cases = new ArrayList();
    
    /*
    @ManyToMany(cascade = CascadeType.ALL)
    @JoinTable(name = "iqexercisetaggrouplink",
            joinColumns = {@JoinColumn(name = "exerciseid") }, 
            inverseJoinColumns = {@JoinColumn(name = "taggroupid") })
    private Set<IQTagGroup> tagGroupList = new LinkedHashSet();
*/
    
    @OneToMany(fetch = FetchType.LAZY, cascade = CascadeType.ALL, mappedBy="associatedExercise")
    private List<IQCaseTag> associatedCaseTags = new ArrayList();

    @OneToMany(mappedBy = "exercise")
    @Cascade({org.hibernate.annotations.CascadeType.DELETE})
    private List<IQExam> associatedExams = new ArrayList();
    
    @Expose
    @Column(name = "active")
    private boolean active = true;
    
    public IQExercise() {
        
    }
    
    public IQExercise(String exerciseName) {
        this.exerciseName = exerciseName;
    }
    
    /**
     * @return the tagGroupList
     */
/*
    public Set<IQTagGroup> getTagGroupList() {
        return tagGroupList;
    }
*/
    /**
     * @param tagGroupList the tagGroupList to set
     */
/*
    public void setTagGroupList(Set<IQTagGroup> tagGroupList) {
        this.tagGroupList = tagGroupList;
    }
*/
    /**
     * @return the exerciseName
     */

    public String getExerciseName() {
        return exerciseName;
    }

    /**
     * @param exerciseName the exerciseName to set
     */
    public void setExerciseName(String exerciseName) {
        this.exerciseName = exerciseName;
    }

    /**
     * @return the exerciseId
     */

    public Long getExerciseId() {
        return exerciseId;
    }

    /**
     * @param exerciseId the exerciseId to set
     */
    public void setExerciseId(Long exerciseId) {
        this.exerciseId = exerciseId;
    }

    public List<IQCase> getCases() {
        return cases;
    }
    
    
    public List<IQCase> getActiveCases() {
    	ArrayList<IQCase> result = new ArrayList();
    	for (IQCase c: this.getCases()) {
    		if (c != null && c.isActive()) {
    			result.add(c);
    		}
    	}
    	return result;
    }
    
    public List<IQCase> getActiveCases(IQDataSource dataSource) {
    	TypedQuery<IQCase> q =dataSource.getSession().createQuery("SELECT c FROM IQCase c JOIN c.parentExercises e WHERE e.exerciseId=:exerciseId AND c.active=1", IQCase.class)
    			.setParameter("exerciseId", this.getExerciseId());
    	
        
        return q.getResultList();
    }
    
    public Long getActiveCasesSize(IQDataSource dataSource) {
    	return dataSource.getSession().createQuery("SELECT count(*) FROM IQCase c JOIN c.parentExercises e WHERE e.exerciseId=:exerciseId AND c.active=1", Long.class)
    			.setParameter("exerciseId", this.getExerciseId())
    			.uniqueResult();
    }
    
    public List<Long> getActiveCasesIds(IQDataSource dataSource) {
		return dataSource.getSession().createQuery("SELECT c.caseId FROM IQCase c JOIN c.parentExercises e WHERE e.exerciseId=:exerciseId AND c.active=1", Long.class)
    			.setParameter("exerciseId", this.getExerciseId())
    			.getResultList();
    }
    
    public List<Long> getActiveCasesIds() {
    	List<Long> result = new ArrayList();
		for (IQCase c: this.getActiveCases()) {
			result.add(c.getCaseId());
		}
		return result;
    }
    
    public String getCasesXml() {
        String xml = "";
        for (IQCase iqcase: cases) {
            xml = xml + "\n" +  iqcase.getCaseXml();
        }
        xml = "<case-list xmlns=\"http://www.w3.org/2001/XMLSchema\">\n" + xml + "\n</case-list>";
        return xml;
    }

    /**
     * @param cases the caseList to set
     */
    public void setCases(List<IQCase> cases) {
        this.cases = cases;
    }

    public IQCase getCaseById(Long caseId) {
    	for (IQCase mycase: this.cases) {
    		if (mycase.getCaseId().longValue() == caseId.longValue()) {
    			return mycase;
    		}
    	}
    	return null;
    }
    



	public List<IQCaseTag> getAssociatedCaseTags() {
		return associatedCaseTags;
	}

	public void setAssociatedCaseTags(List<IQCaseTag> associatedCaseTags) {
		this.associatedCaseTags = associatedCaseTags;
	}

	static boolean removeExerciseById(List<IQExercise> list, Long id) {
		for (int i=0; i< list.size(); i++) {
			IQExercise e = list.get(i);
			if (e.getExerciseId() == id) {
				list.remove(i);
				return true;
			}
		}
		return false;
	}

	public List<IQExam> getAssociatedExams() {
		return associatedExams;
	}

	public void setAssociatedExams(List<IQExam> associatedExams) {
		this.associatedExams = associatedExams;
	}

	public boolean isActive() {
		return active;
	}

	public void setActive(boolean active) {
		this.active = active;
	}

}
