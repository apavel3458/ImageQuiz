/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.model.question;

import static javax.persistence.GenerationType.IDENTITY;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Transient;

import com.google.gson.annotations.Expose;

/**
 *
 * @author apavel
 */

@Entity
@Table(name = "iqcase_answer_choice")
public class IQAnswerChoice implements Serializable {
	
	@Expose
    @Id
    @Column(name = "choiceid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
    private Long choiceId;
    
	@Expose
    @Column(name = "answerstring")
    private String answerString = "";
    
	@Expose
    @Column(name = "correct")
    private Boolean correct = false;  //hopefully for display only
    
	@Expose
    @Column(name = "selectscore")
    private BigDecimal selectScore = new BigDecimal(0);
    
	@Expose
    @Column(name = "missscore")
    private BigDecimal missScore = new BigDecimal(0);
    
    @ManyToOne
    @JoinColumn(name = "questionid", nullable = false)
    private IQQuestion parentQuestion;
    
    @Transient //OLD
    @Deprecated
    private BigDecimal score = new BigDecimal(1);
    
    @Transient //OLD
    @Deprecated
    private BigDecimal wrongChoiceScore = new BigDecimal(0);
    
    @Transient // OLD
    @Deprecated
    private String answer = "";
    
    public IQAnswerChoice() {
    }
    /**
     * @return the name
     */
    public String getAnswerString() {
        return answerString;
    }

    /**
     * @param name the name to set
     */
    public void setAnswerString(String answer) {
    	if (answer == null) answer = "";
        this.answerString = answer;
    }
	
	@Override
	public String toString() {
		return answerString;
	}
	
	public boolean equals(IQAnswerChoice a) {
		return (this.answerString.equalsIgnoreCase(a.getAnswerString()));
	}
	@Override
	public boolean equals(Object a) {
			return (this.answerString.equalsIgnoreCase(a.toString()));

	}
	
	@Deprecated
	public BigDecimal getWrongChoiceScore() {
		return wrongChoiceScore;
	}
	@Deprecated
	public void setWrongChoiceScore(BigDecimal wrongChoiceScore) {
		this.wrongChoiceScore = wrongChoiceScore;
	}
	@Deprecated
	public BigDecimal getScore() {
		return score;
	}
	@Deprecated
	public void setScore(BigDecimal score) {
		this.score = score;
	}
	@Deprecated
	public String getAnswer() {
		return answer;
	}
	@Deprecated
	public void setAnswer(String answer) {
		this.answer = answer;
	}
	public Boolean getCorrect() {
		return correct;
	}
	public void setCorrect(Boolean correct) {
		this.correct = correct;
	}

	public IQQuestion getParentQuestion() {
		return parentQuestion;
	}
	public void setParentQuestion(IQQuestion parentQuestion) {
		this.parentQuestion = parentQuestion;
	}
	public BigDecimal getSelectScore() {
		return selectScore;
	}
	public void setSelectScore(BigDecimal selectScore) {
		this.selectScore = selectScore;
	}
	public BigDecimal getMissScore() {
		return missScore;
	}
	public void setMissScore(BigDecimal missScore) {
		this.missScore = missScore;
	}
	public Long getChoiceId() {
		return choiceId;
	}
	public void setChoiceId(Long choiceId) {
		this.choiceId = choiceId;
	}
}
