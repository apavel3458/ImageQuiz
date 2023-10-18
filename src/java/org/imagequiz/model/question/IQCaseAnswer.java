/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.model.question;

import static javax.persistence.GenerationType.IDENTITY;

import java.math.BigDecimal;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import org.imagequiz.model.IQCase;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQUserQuiz;
import org.nustaq.serialization.annotations.Version;

import com.google.gson.annotations.Expose;

/**
 *
 * @author apavel
 */
@Entity
@Table(name = "iqcase_answer")
public class IQCaseAnswer {
	public final static String STATUS_NONE = null;
	public final static String STATUS_CORRECT = "correct";
	public final static String STATUS_INCORRECT = "incorrect";
	public final static String STATUS_MISSED = "missed";
    
    @Expose
    @Id
    @Column(name = "answerid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
    private Long answerId;
    
    @Expose
    @Column(name = "text")
    private String text;
    
    @Expose
    @Column(name = "itemid")
    private Long itemId;
    
    @Expose
    @Column(name = "questiontype")
    private String questionType;
    
    @Expose
    @Column(name = "questiontextid")
    private String questionTextId;
    
    @Expose
    @Column(name = "status")
    private String status;
    
    @Expose
    @Column(name = "score")
    private BigDecimal score;
    
    @Expose
    @Column(name = "createdAt")
    private Date createdAt;
    
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "casecompletedid", nullable = false)
	private IQCaseCompleted associatedCaseCompleted;
	
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "quizid", nullable = false)
	private IQUserQuiz associatedQuiz;
	
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "questionid", nullable = false)
	private IQQuestion associatedQuestion;

    public IQCaseAnswer() {
    }
    
    public IQCaseAnswer(IQUserQuiz quiz, IQCaseCompleted cc, IQQuestion question) {
    	this.setAssociatedQuiz(quiz);
    	this.setAssociatedCaseCompleted(cc);
    	this.setQuestionType(question.getQuestionType());
    	this.setAssociatedQuestion(question);
    	this.setQuestionTextId(question.getQuestionTextId());
    }
    
    public IQCaseAnswer(IQUserQuiz quiz, IQCaseCompleted cc, String questionType, IQQuestion question, String questionTextId) {
    	this.setAssociatedQuiz(quiz);
    	this.setAssociatedCaseCompleted(cc);
    	this.setQuestionType(questionType);
    	this.setAssociatedQuestion(question);
    	this.setQuestionTextId(questionTextId);
    }
    
    public static String convertStatus(int oldStatus) {
    	if (oldStatus == IQAnswer.STATUS_CORRECT) return IQCaseAnswer.STATUS_CORRECT;
    	if (oldStatus == IQAnswer.STATUS_INCORRECT) return IQCaseAnswer.STATUS_INCORRECT;
    	if (oldStatus == IQAnswer.STATUS_MISSED) return IQCaseAnswer.STATUS_MISSED;
    	else return IQCaseAnswer.STATUS_NONE;
    }

	public Long getAnswerId() {
		return answerId;
	}

	public void setAnswerId(Long answerId) {
		this.answerId = answerId;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
	}

	public Long getItemId() {
		return itemId;
	}

	public void setItemId(Long itemId) {
		this.itemId = itemId;
	}

	public String getQuestionType() {
		return questionType;
	}

	public void setQuestionType(String questionType) {
		this.questionType = questionType;
	}

	public Date getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}
	
	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public BigDecimal getScore() {
		return score;
	}

	public void setScore(BigDecimal score) {
		this.score = score;
	}

	public IQCaseCompleted getAssociatedCaseCompleted() {
		return associatedCaseCompleted;
	}

	public void setAssociatedCaseCompleted(IQCaseCompleted associatedCaseCompleted) {
		this.associatedCaseCompleted = associatedCaseCompleted;
	}

	public IQUserQuiz getAssociatedQuiz() {
		return associatedQuiz;
	}

	public void setAssociatedQuiz(IQUserQuiz associatedQuiz) {
		this.associatedQuiz = associatedQuiz;
	}

	public String getQuestionTextId() {
		return questionTextId;
	}

	public void setQuestionTextId(String questionTextId) {
		this.questionTextId = questionTextId;
	}

	public IQQuestion getAssociatedQuestion() {
		return associatedQuestion;
	}

	public void setAssociatedQuestion(IQQuestion associatedQuestion) {
		this.associatedQuestion = associatedQuestion;
	}
    
}