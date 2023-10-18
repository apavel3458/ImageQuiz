package org.imagequiz.model.user;

import static javax.persistence.GenerationType.IDENTITY;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import org.imagequiz.model.IQCaseTag;

@Entity
@Table(name = "iqcasetag_stat")
public class IQUserQuizPerformance {
	@Id
    @Column(name = "statid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long performanceId;
	
	@ManyToOne
	@JoinColumn(name = "quizid")
	private IQUserQuiz associatedQuiz;
	
	@ManyToOne
	@JoinColumn(name = "tagid")
	private IQCaseTag associatedTag;
	
	
	@Column(name = "score")
	private BigDecimal totalScore = BigDecimal.ZERO;
	
	@Column(name = "passScore")
	private BigDecimal totalPassScore = BigDecimal.ZERO;
	
	@Column(name = "created", insertable = false, updatable = false)
	private Date dateCreated;
	
	
	public BigDecimal getGrade() {
		return this.getTotalScore()
				.divide(this.getTotalPassScore(), RoundingMode.HALF_UP)
				.multiply(new BigDecimal(100));
	}
	
	public Long getPerformanceId() {
		return performanceId;
	}


	public void setPerformanceId(Long performanceId) {
		this.performanceId = performanceId;
	}


	public IQUserQuiz getAssociatedQuiz() {
		return associatedQuiz;
	}


	public void setAssociatedUserQuiz(IQUserQuiz associatedQuiz) {
		this.associatedQuiz = associatedQuiz;
	}


	public IQCaseTag getAssociatedTag() {
		return associatedTag;
	}


	public void setAssociatedTag(IQCaseTag associatedTag) {
		this.associatedTag = associatedTag;
	}


	public BigDecimal getTotalScore() {
		return totalScore;
	}


	public void setTotalScore(BigDecimal totalScore) {
		this.totalScore = totalScore;
	}


	public BigDecimal getTotalPassScore() {
		return totalPassScore;
	}


	public void setTotalPassScore(BigDecimal totalPassScore) {
		this.totalPassScore = totalPassScore;
	}

	public Date getDateCreated() {
		return dateCreated;
	}

	public void setDateCreated(Date dateCreated) {
		this.dateCreated = dateCreated;
	}

}
