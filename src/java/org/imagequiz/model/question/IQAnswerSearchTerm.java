package org.imagequiz.model.question;

import static javax.persistence.GenerationType.IDENTITY;

import java.util.ArrayList;
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
import javax.persistence.Table;

import com.google.gson.annotations.Expose;


@Entity
@Table(name = "iqcase_answer_searchterm")
public class IQAnswerSearchTerm {
	@Expose
	@Id
    @Column(name = "searchtermid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long searchTermId;
	
	@ManyToMany
	@JoinTable(name = "iqcase_answer_searchterm_section_link", 
    joinColumns = {@JoinColumn(name = "searchtermid")}, 
    inverseJoinColumns = {@JoinColumn(name = "sectionid") })
	private List<IQSearchTermSection> parentSections = new ArrayList();
	
	
	@ManyToMany(mappedBy = "searchTerm")
	private List<IQAnswerSearchTermWrapper> associatedWrappers = new ArrayList();
	
	@Expose
	@Column(name = "searchtermstring", unique = true, nullable = false)
	private String searchTermString;
	
	@Expose
	@Column(name = "searchkeys")
	private String searchKeys = "";
	
	public IQAnswerSearchTerm() {
	}
	
	public IQAnswerSearchTerm(String searchTerm) {
		this.setSearchTermString(searchTerm);
	}
	
	public String getSearchTermStringWithKeys() {
		return this.getSearchTermString() + "[" + this.getSearchKeys() + "]";
	}
	
	public Long getSearchTermId() {
		return searchTermId;
	}
	public void setSearchTermId(Long searchTermId) {
		this.searchTermId = searchTermId;
	}

	// also returns [....] annotations
	public String getSearchTermString() {
		return searchTermString;
	}

	
	// removes searchable [...] annotations
	/*
	public String getSearchTermStringWithoutannotations() {
		return removeAnswerAnnotations(this.searchTermString);
	}*/
	
	public void setSearchTermString(String searchTermString) {
		this.searchTermString = searchTermString;
	}

	@Override
	public String toString() {
		return this.getSearchTermString();
	}
	
	public static String removeAnswerAnnotations(String text) {
		return text.replaceAll("\\s*\\[.*\\]\\s*", "");
	}

	public String getSearchKeys() {
		return searchKeys;
	}
	
	public String getSearchKeysBracketed() {
		return "[" + searchTermString + "]";
	}

	public void setSearchKeys(String searchKeys) {
		this.searchKeys = searchKeys;
	}

	public List<IQSearchTermSection> getParentSections() {
		return parentSections;
	}

	public void setParentSection(List<IQSearchTermSection> parentSections) {
		this.parentSections = parentSections;
	}

	public List<IQAnswerSearchTermWrapper> getAssociatedWrappers() {
		return associatedWrappers;
	}

	public void setAssociatedWrappers(List<IQAnswerSearchTermWrapper> associatedWrappers) {
		this.associatedWrappers = associatedWrappers;
	}
	
}
