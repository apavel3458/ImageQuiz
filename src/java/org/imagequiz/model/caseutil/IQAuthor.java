package org.imagequiz.model.caseutil;

import static javax.persistence.GenerationType.IDENTITY;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import org.imagequiz.model.IQCase;
import org.imagequiz.model.user.IQUser;

import com.google.gson.annotations.Expose;

@Entity
@Table(name = "iqcase_authors_link")
public class IQAuthor {
	@Expose
	@Id
    @Column(name = "authorid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long authorId;
	
	@Expose
	@ManyToOne
	@JoinColumn(name = "userid")
	private IQUser author;
	
	@ManyToOne
	@JoinColumn(name = "caseid")
	private IQCase icase;
	
	@Expose
	@ManyToOne
	@JoinColumn(name = "createdBy")
	private IQUser createdBy;
	
	@Expose
	@Column(name = "role")
	private String role;

	public IQUser getAuthor() {
		return author;
	}

	public void setAuthor(IQUser author) {
		this.author = author;
	}

	public IQCase getIcase() {
		return icase;
	}

	public void setIcase(IQCase icase) {
		this.icase = icase;
	}

	public IQUser getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(IQUser createdBy) {
		this.createdBy = createdBy;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public Long getAuthorId() {
		return authorId;
	}

	public void setAuthorId(Long authorId) {
		this.authorId = authorId;
	}
}
