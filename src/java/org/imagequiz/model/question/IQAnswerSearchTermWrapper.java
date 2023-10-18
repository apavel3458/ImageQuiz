/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.model.question;

import static javax.persistence.GenerationType.IDENTITY;

import java.io.Serializable;
import java.math.BigDecimal;
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

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

import com.google.gson.annotations.Expose;

/**
 *
 * @author apavel
 */

@Entity
@Table(name = "iqcase_answer_searchterm_wrapper")
public class IQAnswerSearchTermWrapper {
	
	@Expose
    @Id
    @Column(name = "wrapperid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
    private Long wrapperId;
    
	@Expose
    @Column(name = "scoremodifier")
    private BigDecimal scoreModifier = new BigDecimal(0);
    
	@Expose
    @Column(name = "scoremissed")
    private BigDecimal scoreMissed = new BigDecimal(0);
    
	@Expose
	@Column(name = "primaryanswer")
	private boolean primaryAnswer = true;
	
	@Expose
	@Column(name = "correctanswer")
	private boolean correctAnswer = true;  
	
    @ManyToOne
    @JoinColumn(name = "lineid", nullable = false)
    private IQAnswerSearchTermLine parentQuestionLine;
    
    @Expose
    @ManyToOne(fetch=FetchType.EAGER)
    @JoinColumn(name = "searchtermid", nullable = false)
    private IQAnswerSearchTerm searchTerm;
    
//    @Column(name = "alternateanswer")  //if this is not linked to searchTermId, then need alternate answer which is text. 
//    private String alternateAnswer = "";

	public BigDecimal getScoreMissed() {
		return scoreMissed;
	}

	public void setScoreMissed(BigDecimal scoreMissed) {
		this.scoreMissed = scoreMissed;
	}

	public IQAnswerSearchTerm getSearchTerm() {
		return searchTerm;
	}

	public void setSearchTerm(IQAnswerSearchTerm searchTerm) {
		this.searchTerm = searchTerm;
	}

	public Long getWrapperId() {
		return wrapperId;
	}

	public void setWrapperId(Long wrapperId) {
		this.wrapperId = wrapperId;
	}

	public IQAnswerSearchTermLine getParentQuestionLine() {
		return parentQuestionLine;
	}

	public void setParentQuestionLine(IQAnswerSearchTermLine parentQuestionLine) {
		this.parentQuestionLine = parentQuestionLine;
	}

	public boolean isPrimaryAnswer() {
		return primaryAnswer;
	}

	public void setPrimaryAnswer(boolean primaryAnswer) {
		this.primaryAnswer = primaryAnswer;
	}

	public boolean isCorrectAnswer() {
		return correctAnswer;
	}

	public void setCorrectAnswer(boolean correctAnswer) {
		this.correctAnswer = correctAnswer;
	}

	public BigDecimal getScoreModifier() {
		return scoreModifier;
	}

	public void setScoreModifier(BigDecimal scoreModifier) {
		this.scoreModifier = scoreModifier;
	}



}
