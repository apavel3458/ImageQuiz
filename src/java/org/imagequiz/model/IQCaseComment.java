package org.imagequiz.model;

import static javax.persistence.GenerationType.IDENTITY;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import org.imagequiz.model.user.IQUser;

import com.google.gson.annotations.Expose;

/*
 * 
 * CREATE TABLE `iqcasecomments` (
  `commentid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `text` text default '',
  `private` boolean default false,
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
 */

@Entity
@Table(name = "iqcasecomment")
public class IQCaseComment implements Comparable<IQCaseComment> {
	@Expose
	@Id
    @Column(name = "commentid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long commentId;
	
	@ManyToOne
	@JoinColumn(name = "userid")
	private IQUser user;
	
	@ManyToOne
	@JoinColumn(name = "caseid", nullable = false)
	private IQCase associatedCase;
	
	@Expose
	@Column(name = "text")
	private String text = "";
	
	@Expose
	@Column(name = "hidden")
	private boolean hidden = false;
	
	@Expose
	@Column(name = "createdAt")
	private Date createdDateTime;
	
	@Expose
	@Column(name = "reviewed")
	private boolean reviewed = false;
	
	@ManyToOne
	@JoinColumn(name = "reviewedBy")
	private IQUser reviewedBy;
	
	@Expose
	@Column(name = "reviewedAt")
	private Date reviewedAt;
	
	public IQCaseComment() {
		this.setCreatedDateTime(Calendar.getInstance().getTime());
	}
	
	public Long getCommentId() {
		return commentId;
	}
	public void setCommentId(Long commentId) {
		this.commentId = commentId;
	}

	public String getText() {
		return text;
	}
	public void setText(String text) {
		this.text = text;
	}
	public boolean isHidden() {
		return hidden;
	}
	public void setHidden(boolean hidden) {
		this.hidden = hidden;
	}
	public IQCase getAssociatedCase() {
		return associatedCase;
	}
	public void setAssociatedCase(IQCase associatedCase) {
		this.associatedCase = associatedCase;
	}
	public IQUser getUser() {
		return user;
	}
	public void setUser(IQUser user) {
		this.user = user;
	}

	public Date getCreatedDateTime() {
		return createdDateTime;
	}

	public void setCreatedDateTime(Date createdDateTime) {
		this.createdDateTime = createdDateTime;
	}
	
	public String toString() {
		return this.getText();
	}
	
	public int compareTo(IQCaseComment o) {
		return getCreatedDateTime().compareTo(o.getCreatedDateTime());
	}
	
	//util String
	public static List<IQCaseComment> getCommentByUserId(List<IQCaseComment> comments, Long userId) {
		List<IQCaseComment> finalComments = new ArrayList();
		for (IQCaseComment comment: comments) {
			if (comment.getUser().getUserId() == userId) {
				finalComments.add(comment);
			}
		}
		return finalComments;
	}
	
	public static List<IQCaseComment> removeHiddenComments(List<IQCaseComment> comments) {
		List<IQCaseComment> finalComments = new ArrayList();
		for (IQCaseComment comment: comments) {
			if (!comment.isHidden()) {
				finalComments.add(comment);
			}
		}
		return finalComments;
	}

	public boolean isReviewed() {
		return reviewed;
	}

	public void setReviewed(boolean reviewed) {
		this.reviewed = reviewed;
	}

	public IQUser getReviewedBy() {
		return reviewedBy;
	}

	public void setReviewedBy(IQUser reviewedBy) {
		this.reviewedBy = reviewedBy;
	}

	public Date getReviewedAt() {
		return reviewedAt;
	}

	public void setReviewedAt(Date reviewedAt) {
		this.reviewedAt = reviewedAt;
	}
}
