/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.model.question;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.Transient;

import com.google.gson.annotations.Expose;

/**
 *
 * @author apavel
 */
@Entity
@DiscriminatorValue("text")
public class IQQuestionText extends IQQuestion {
	
	@Expose
	@Transient
	private int height = 1;
	
	@Expose
	@Transient
	private int maxLength = 500;
	
	@Expose
	@Transient
	private String modelAnswer = "";
	
    public IQQuestionText() {
        super();
        this.questionType = this.QUESTION_TYPE_TEXT;
    }
    
    public ArrayList<IQAnswer> getAnswerObjList() {
		ArrayList<IQAnswer> result = new ArrayList();
    	return result;
    }
    
	@Deprecated
	public ArrayList<IQAnswer> getAnswers() {
		return this.getAnswerObjList();
	}
    
    
	public int getHeight() {
		return height;
	}
	public void setHeight(int height) {
		this.height = height;
	}


	public int getMaxLength() {
		return maxLength;
	}


	public void setMaxLength(int maxLength) {
		this.maxLength = maxLength;
	}

	public String getModelAnswer() {
		return modelAnswer;
	}

	public void setModelAnswer(String modelAnswer) {
		this.modelAnswer = modelAnswer;
	}
    
}