package org.imagequiz.model.question;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;

import org.imagequiz.dao.IQDataSource;

import com.google.gson.annotations.Expose;

@Entity
@DiscriminatorValue("choice")
public class IQQuestionChoice extends IQQuestion {
	
	@Expose
    @OneToMany(mappedBy="parentQuestion", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("choiceid")
	private List<IQAnswerChoice> associatedChoices = new ArrayList();
    
	@Expose
    @Column(name = "maxUserSelections")
    private Integer maxUserSelections = 1;
	
    
    public IQQuestionChoice() {}
    
	public IQQuestionChoice(int allowedChoices) {
//	     this.questionType = IQQuestion.QUESTION_TYPE_CHOICE;
	}
	
	@Deprecated
    public ArrayList<IQAnswer> getAnswerObjList() {
		ArrayList<IQAnswer> answers = new ArrayList();
		for (IQAnswerChoice choice: this.getAssociatedChoices()) {
			IQAnswer answer = new IQAnswer();
			answer.setAnswer(choice.getAnswerString());
			answer.setScore(choice.getSelectScore());
			answer.setStatus(choice.getCorrect().booleanValue()?IQAnswer.STATUS_CORRECT:IQAnswer.STATUS_INCORRECT);
			answers.add(answer);
		}
		return answers;
	}
	
	@Deprecated
	public ArrayList<IQAnswer> getAnswers() {
		return this.getAnswerObjList();
	}
	
	@Override
	public void setParentsDeleteOrphans(IQDataSource dataSource) {
		if (this.getQuestionType().equals("choice")) {
			for (IQAnswerChoice choice: this.getAssociatedChoices()) {
				choice.setParentQuestion(this);
			}	
		}
	}
	
    @Override
    public boolean equals(Object objj) {
    	if (this.getClass().isAssignableFrom(objj.getClass())) {
    		return this.getQuestionId().equals(((IQQuestionChoice) objj).getQuestionId());
    	} else {
    		return false;
    	}
    }

	public List<IQAnswerChoice> getAssociatedChoices() {
		return associatedChoices;
	}

	public void setAssociatedChoices(List<IQAnswerChoice> associatedChoices) {
		this.associatedChoices = associatedChoices;
	}

	public Integer getMaxUserSelections() {
		return maxUserSelections;
	}

	public void setMaxUserSelections(Integer maxUserSelections) {
		this.maxUserSelections = maxUserSelections;
	}

}
