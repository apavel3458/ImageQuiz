package org.imagequiz.model.question;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.DiscriminatorValue;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.OrderColumn;
import javax.persistence.Transient;

import com.google.gson.annotations.Expose;


@Entity
@DiscriminatorValue("sg")
public class IQQuestionSearchTerm extends IQQuestion {
	
	@ManyToMany
    @JoinTable(name = "iqcase_question_availablegroup_link", 
            joinColumns = {@JoinColumn(name = "questionid")}, 
            inverseJoinColumns = {@JoinColumn(name = "groupid") }
    )
	private List<IQSearchTermGroup> availableGroups = new ArrayList();
	
	@Expose
    @OneToMany(mappedBy="parentQuestion", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("lineid")
	private List<IQAnswerSearchTermLine> associatedAnswerLines = new ArrayList();
	
	@Expose
	@Transient
	private String availableGroupsText = "";
	
    
    
	public IQQuestionSearchTerm() {
//		this.questionType = super.QUESTION_TYPE_SEARCHTERM;
	}
	
    public ArrayList<IQAnswer> getAnswerObjList() {
		ArrayList<IQAnswer> result = new ArrayList();
    	for (IQAnswerSearchTermLine line: this.associatedAnswerLines) {
    		for (IQAnswerSearchTermWrapper wrapper: line.getAssociatedAnswerWrappers()) {
    			IQAnswer answer = new IQAnswer();
    			answer.setAnswer(wrapper.getSearchTerm().getSearchTermString());
    			answer.setScore(wrapper);
    			result.add(answer);
    		}
    	}
    	return result;
    }
	
	@Deprecated
	public ArrayList<IQAnswer> getAnswers() {
		return this.getAnswerObjList();
	}

	public List<IQSearchTermGroup> getAvailableGroups() {
		return availableGroups;
	}

	public void setAvailableGroups(List<IQSearchTermGroup> availableGroups) {
		this.availableGroups = availableGroups;
	}

	public List<IQAnswerSearchTermLine> getAssociatedAnswerLines() {
		return associatedAnswerLines;
	}

	public void setAssociatedAnswerLines(List<IQAnswerSearchTermLine> associatedAnswerLines) {
		this.associatedAnswerLines = associatedAnswerLines;
	}

	public String getAvailableGroupsText() {
		return availableGroupsText;
	}

	public void setAvailableGroupsText(String availableGroupsText) {
		this.availableGroupsText = availableGroupsText;
	}

	/*
	public List<String> getAnswersStringList() {
		List<IQAnswer> answers = new ArrayList();
		for (IQAnswerSearchTermLine line : this.getAssociatedAnswerLines()) {
			for (IQAnswerSearchTermWrapper w : line.getAssociatedAnswerWrappers()) {
				IQAnswer a = new IQAnswer();
				a.setAnswer(w.getSearchTerm().getSearchTermString());
				a.setScore(w);
			}
		}
		return answers;
	}
	*/
	

}
