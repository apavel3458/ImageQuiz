/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.model.question;

import static javax.persistence.GenerationType.IDENTITY;


import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.DiscriminatorColumn;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Inheritance;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;

import javax.persistence.Table;
import javax.persistence.Transient;
import javax.persistence.UniqueConstraint;

import org.hibernate.annotations.Type;
import org.hibernate.annotations.TypeDef;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.util.CaseParseException;
import org.imagequiz.util.GsonSettingsAdapter;

import com.google.gson.JsonElement;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.JsonAdapter;

import com.vladmihalcea.hibernate.type.json.*;

/**
 *
 * @author apavel
 */

@Entity
@Table(name = "iqcase_question",
      uniqueConstraints = { @UniqueConstraint( columnNames = { "caseid", "questiontextid" } ) } )
@Inheritance(strategy = javax.persistence.InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name="questiontype_java",discriminatorType=javax.persistence.DiscriminatorType.STRING)
public abstract class IQQuestion {
    public static final String QUESTION_TYPE_TEXT = "text";
    public static final String QUESTION_TYPE_SEARCHTERM = "sg";
    public static final String QUESTION_TYPE_SEARCHTERM_SETS = "sgs";
    public static final String QUESTION_TYPE_CHOICE = "choice";
    public static List<String> possible_question_types = Arrays.asList(QUESTION_TYPE_TEXT, 
    															QUESTION_TYPE_SEARCHTERM,
    															QUESTION_TYPE_CHOICE,
    															QUESTION_TYPE_SEARCHTERM_SETS
    															);
    @Expose
    @Id
    @Column(name = "questionid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long questionId;
    
    @Expose
    @Column(name = "questiontextid")
	private String questionTextId;
    
    @Expose
    @Column(name = "questiontype")
    protected String questionType;
    
    @Expose
    @Column(name = "questiontext")
    private String questionText = "";
	
    @Expose
    @Column(name = "passScore")
	private BigDecimal passScore = new BigDecimal(1);
    
    @Expose
    @Column(name = "scoreincorrectchoice")
    private BigDecimal scoreIncorrectChoice = new BigDecimal(0);
    
    @Expose
    @Column(name = "shuffle")
    private Boolean shuffle = false;
    
    @Expose
    @JsonAdapter(GsonSettingsAdapter.class)
//    @Type(type = "json")
    @Column(name = "options")
    private String options = null;
    
    @ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "caseid", nullable = false)
    private IQCase parentCase;
    
    @Transient //OLD
    @Deprecated
    private BigDecimal wrongChoiceScore = new BigDecimal(0);

    //tags you add to the <settings part, that add or override tags in tagGroups (i.e. special lab values)
    
    public IQQuestion() {
    }
    
    @Override
    public boolean equals(Object objj) {
    	if (this.getClass().isAssignableFrom(objj.getClass())) {
    		return this.getQuestionId().equals(((IQQuestion) objj).getQuestionId());
    	} else {
    		return false;
    	}
    }
        
    public static boolean typeExists(String questionType) {
    	if (possible_question_types.contains(questionType)) {
            return true;
        } else {
        	return false;
        }
    }
    
    public void setParentsDeleteOrphans(IQDataSource dataSource) {
    	System.out.println("Nothing to do...");
    }
    
    @Deprecated
    public abstract ArrayList<IQAnswer> getAnswerObjList();
    @Deprecated
    public abstract ArrayList<IQAnswer> getAnswers();
    
   

    /**
     * @return the questionType
     */
    public String getQuestionType() {
        return questionType;
    }

    /**
     * @param questionType the questionType to set
     */
    public void setQuestionType(String questionType) throws CaseParseException {
        if (possible_question_types.contains(questionType)) {
            this.questionType = questionType;
        } else {
            throw new CaseParseException("Unable to find question type '" + questionType + "'");
        }
    }

	public String getQuestionText() {
		return questionText;
	}

	public void setQuestionText(String questionText) {
		this.questionText = questionText;
	}

	public BigDecimal getPassScore() {
		return passScore;
	}

	public void setPassScore(BigDecimal passScore) {
		this.passScore = passScore;
	}

	public BigDecimal getScoreIncorrectChoice() {
		return scoreIncorrectChoice;
	}

	public void setScoreIncorrectChoice(BigDecimal scoreIncorrectChoice) {
		this.scoreIncorrectChoice = scoreIncorrectChoice;
	}

	public BigDecimal getWrongChoiceScore() {
		return wrongChoiceScore;
	}

	public void setWrongChoiceScore(BigDecimal wrongChoiceScore) {
		this.wrongChoiceScore = wrongChoiceScore;
	}

	public Long getQuestionId() {
		return questionId;
	}

	public void setQuestionId(Long questionId) {
		this.questionId = questionId;
	}

	public String getQuestionTextId() {
		return questionTextId;
	}

	public void setQuestionTextId(String questionTextId) {
		this.questionTextId = questionTextId;
	}

	public IQCase getParentCase() {
		return parentCase;
	}

	public void setParentCase(IQCase parentCase) {
		this.parentCase = parentCase;
	}

	public Boolean getShuffle() {
		return shuffle;
	}

	public void setShuffle(Boolean shuffle) {
		this.shuffle = shuffle;
	}

	public String getOptions() {
		return options;
	}

	public void setOptions(String options) {
		this.options = options;
	}
	

}
