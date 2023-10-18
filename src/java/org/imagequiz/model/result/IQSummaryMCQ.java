package org.imagequiz.model.result;

import java.util.ArrayList;
import java.util.List;

import org.imagequiz.model.IQCase;
import org.imagequiz.model.question.IQAnswerChoice;
import org.imagequiz.model.question.IQQuestionChoice;

public class IQSummaryMCQ extends IQSummaryQ {
	protected List<IQSummaryAnswerChoice> choices = new ArrayList();
	
	public class IQSummaryAnswerChoice {
		public IQAnswerChoice choice;
		public int count = 0;
		
		public IQAnswerChoice getChoice() { return this.choice; }
		public int getCount() { return this.count; }
		
	}
	
	public IQSummaryMCQ() {
		this.setType(TYPE_MCQ);
	}
	
	public IQSummaryMCQ(IQSummaryQ q) {
		this();
		this.setProperties(q);
	}

	public IQCase getAssociatedCase() {
		return associatedCase;
	}

	public void setAssociatedCase(IQCase associatedCase) {
		this.associatedCase = associatedCase;
	}

	public List<IQSummaryAnswerChoice> getChoices() {
		return choices;
	}

	public void setChoices(List<IQSummaryAnswerChoice> choices) {
		this.choices = choices;
	}

	public int getTotalCount() {
		return totalCount;
	}

	public void setTotalCount(int totalCount) {
		this.totalCount = totalCount;
	}
}