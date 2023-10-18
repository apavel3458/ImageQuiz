package org.imagequiz.model.question;

import static javax.persistence.GenerationType.IDENTITY;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.ManyToMany;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.imagequiz.dao.IQDataSource;

@Entity
@Table(name = "iqcase_answer_searchterm_group")
public class IQSearchTermGroup {
    @Id
    @Column(name = "groupid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long groupId;
    
    @Column(name = "groupname")
    private String groupName;
    
    @Transient
    private String searchTermsText = "";
    
    @ManyToMany(mappedBy = "availableGroups")
    private List<IQQuestionSearchTerm> associatedQuestions = new ArrayList();
    
    @OneToMany(mappedBy = "parentGroup", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<IQSearchTermSection> associatedSections = new ArrayList();
	
	public IQSearchTermGroup() {
	}
	
	// for better efficiency
	public List<IQAnswerSearchTerm> getSearchTerms(IQDataSource dataSource) {
		String hql = "SELECT st FROM IQAnswerSearchTerm st JOIN st.parentSections s JOIN s.parentGroup g WHERE g.groupName=:groupName";
		return (List<IQAnswerSearchTerm>) dataSource.getSession().createQuery(hql).setParameter("groupName", this.getGroupName()).list();
	}
	
	public List<String> getSearchTermStrings(IQDataSource dataSource) {
		
		List<IQAnswerSearchTerm> answerSTs = this.getSearchTerms(dataSource);
		System.out.println("found: " + answerSTs.size());
		List<String> result = new ArrayList();
		for (Iterator<IQAnswerSearchTerm> i = answerSTs.iterator(); i.hasNext();) {
			IQAnswerSearchTerm answer = i.next();
			result.add(answer.getSearchTermStringWithKeys());
		}
		return result;
	}
	
	/*
	public List<String> getSearchTermStrings() {
		List<String> result = new ArrayList();
		for (IQSearchTermSection section: this.getSearchTermSections()) {
			for (IQAnswerSearchTerm st: section.getSearchTerms()) {
				result.add(st.getSearchTermStringWithKeys());
			}
		}
		return result;
	}
	*/
	public IQSearchTermGroup(Long groupId, String groupName) {
		this.groupId = groupId;
		this.groupName = groupName;
	}
	public Long getGroupId() {
		return groupId;
	}
	public void setGroupId(Long groupId) {
		this.groupId = groupId;
	}
	public String getGroupName() {
		return groupName;
	}
	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}

	public String getSearchTermsText() {
		return searchTermsText;
	}

	public void setSearchTermsText(String searchTermsText) {
		this.searchTermsText = searchTermsText;
	}

	public List<IQSearchTermSection> getAssociatedSections() {
		return associatedSections;
	}

	public void setAssociatedSections(List<IQSearchTermSection> associatedSections) {
		this.associatedSections = associatedSections;
	}
}
