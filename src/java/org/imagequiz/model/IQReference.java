package org.imagequiz.model;

import static javax.persistence.GenerationType.IDENTITY;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;


@Entity
@Table(name = "iqreference")
public class IQReference {
	@Id
    @Column(name = "referenceid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private
	Long referenceId = null;
	
	@Column(name = "searchtext")
	private
	String searchText = null;
	
	@Column(name = "replacelink")
	private
	String replaceLink = "";

	public Long getReferenceId() {
		return referenceId;
	}

	public void setReferenceId(Long referenceId) {
		this.referenceId = referenceId;
	}

	public String getSearchText() {
		return searchText;
	}

	public void setSearchText(String searchText) {
		this.searchText = searchText;
	}

	public String getReplaceLink() {
		return replaceLink;
	}

	public void setReplaceLink(String replaceLink) {
		this.replaceLink = replaceLink;
	}
	
	
}
