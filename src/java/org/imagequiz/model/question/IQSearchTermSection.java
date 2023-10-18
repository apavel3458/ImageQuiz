package org.imagequiz.model.question;

import static javax.persistence.GenerationType.IDENTITY;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.Table;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.imagequiz.model.IQExam;

@Entity
@Table(name = "iqcase_answer_searchterm_section")
public class IQSearchTermSection {
    @Id
    @Column(name = "sectionid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long sectionId;
    
    @Column(name = "sectionname")
    private String sectionName = "";
    
    @ManyToOne
    @JoinColumn(name = "groupid", nullable = false)
    private IQSearchTermGroup parentGroup;
    
	@ManyToMany(mappedBy = "parentSections")
	@OrderBy("searchTermString ASC")
	private List<IQAnswerSearchTerm> associatedSearchTerms = new ArrayList();

	public String getSectionName() {
		return sectionName;
	}

	public void setSectionName(String sectionName) {
		this.sectionName = sectionName;
	}

	public Long getSectionId() {
		return sectionId;
	}

	public void setSectionId(Long sectionId) {
		this.sectionId = sectionId;
	}

	public IQSearchTermGroup getParentGroup() {
		return parentGroup;
	}

	public void setParentGroup(IQSearchTermGroup parentGroup) {
		this.parentGroup = parentGroup;
	}

	public List<IQAnswerSearchTerm> getAssociatedSearchTerms() {
		return associatedSearchTerms;
	}

	public void setAssociatedSearchTerms(List<IQAnswerSearchTerm> associatedSearchTerms) {
		this.associatedSearchTerms = associatedSearchTerms;
	}
	
}
