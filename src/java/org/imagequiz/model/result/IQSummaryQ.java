package org.imagequiz.model.result;

import java.util.ArrayList;
import java.util.List;

import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQCaseComment;
import org.imagequiz.model.question.IQQuestion;

public class IQSummaryQ {
	public String TYPE_MCQ = "mcq";
	public String TYPE_SEARCH_TERM = "sg";
	public String TYPE_TEXT = "text";
	
	protected IQCase associatedCase = new IQCase();
	protected IQQuestion question;
	protected int totalCount = 0;
	protected int setMeanSecondsTaken = 0;
	protected String type = null;
	private List<IQCaseComment> comments = new ArrayList();
	
	public void setProperties(IQSummaryQ q) {
		this.setAssociatedCase(q.getAssociatedCase());
		this.setComments(q.getComments());
		this.setTotalCount(q.getTotalCount());
		this.setQuestion(q.getQuestion());
		this.setMeanSecondsTaken(q.getMeanSecondsTaken());
		this.setTotalCount(q.getTotalCount());
	}

	public IQCase getAssociatedCase() {
		return associatedCase;
	}

	public void setAssociatedCase(IQCase associatedCase) {
		this.associatedCase = associatedCase;
	}

	public IQQuestion getQuestion() {
		return question;
	}

	public void setQuestion(IQQuestion question) {
		this.question = question;
	}

	public int getTotalCount() {
		return totalCount;
	}

	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}

	public int getMeanSecondsTaken() {
		return setMeanSecondsTaken;
	}

	public void setMeanSecondsTaken(int setMeanSecondsTaken) {
		this.setMeanSecondsTaken = setMeanSecondsTaken;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public List<IQCaseComment> getComments() {
		return comments;
	}

	public void setComments(List<IQCaseComment> comments) {
		this.comments = comments;
	}

}