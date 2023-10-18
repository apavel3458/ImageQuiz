package org.imagequiz.model.caseutil;

import static javax.persistence.GenerationType.IDENTITY;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import org.imagequiz.model.user.IQUser;

import com.google.gson.annotations.Expose;

import org.imagequiz.model.IQCase;

@Entity
@Table(name = "iqcaserevisions")
public class IQCaseRevision {
	
	@Expose
	@Id
    @Column(name = "revisionid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long revisionId;
	
	@ManyToOne
	@JoinColumn(name = "userid")
	private IQUser author;
	
	@ManyToOne
	@JoinColumn(name = "caseid")
	private IQCase parentCase;
	
	@Expose
	@Column(name = "datetime")
	private Date datetime = new Date();
	
	//disabled for space purposes, can enable by uncommenting the getter and setter below
	@Expose
	@Column(name = "casexml")
	private String caseXml = "";
	
	@Expose
	@Column(name = "casexmldiff")
	private String caseXmlDiff = "";
	
	@Expose
	@Column(name = "contributionWeight")
	private Long contributionWeight = new Long(0);
	
	@Expose
	@Column(name = "role")
	private String role = ROLE_EDITOR;
	
	public static String ROLE_EDITOR = "Editor";
	public static String ROLE_REVIEWER = "Reviewer";
	public static String ROLE_AUTHOR = "Author";
	
	
	
	public IQUser getAuthor() {
		return author;
	}
	public void setAuthor(IQUser author) {
		this.author = author;
	}
	public Date getDatetime() {
		return datetime;
	}
	public void setDatetime(Date datetime) {
		this.datetime = datetime;
	}
	/*public String getCaseXml() { // disabled for speed purposes, can enable later
		return caseXml;
	}
	public void setCaseXml(String caseXml) {
		this.caseXml = caseXml;
	}*/
	public IQCase getParentCase() {
		return parentCase;
	}
	public void setParentCase(IQCase parentCase) {
		this.parentCase = parentCase;
	}
	public String getCaseXmlDiff() {
		return caseXmlDiff;
	}
	public void setCaseXmlDiff(String caseXmlDiff) {
		this.caseXmlDiff = caseXmlDiff;
	}
	public Long getContributionWeight() {
		return contributionWeight;
	}
	public void setContributionWeight(Long contributionWeight) {
		this.contributionWeight = contributionWeight;
	}
	public String getRole() {
		return role;
	}
	public void setRole(String role) {
		this.role = role;
	}
	public Long getRevisionId() {
		return revisionId;
	}
	public void setRevisionId(Long revisionId) {
		this.revisionId = revisionId;
	}
}
