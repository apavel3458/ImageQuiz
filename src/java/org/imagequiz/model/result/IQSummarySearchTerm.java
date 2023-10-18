package org.imagequiz.model.result;

import java.util.ArrayList;
import java.util.List;

import org.imagequiz.model.IQCase;
import org.imagequiz.model.question.IQAnswerChoice;
import org.imagequiz.model.question.IQQuestionChoice;

public class IQSummarySearchTerm extends IQSummaryQ {
	protected List<Answer> answers = new ArrayList();
	
	public IQSummarySearchTerm() {
		this.setType(TYPE_SEARCH_TERM);
	}
	
	public IQSummarySearchTerm(IQSummaryQ q) {
		this();
		this.setProperties(q);
	}
	
	public List<Answer> getAnswers() {
		return answers;
	}

	public void setAnswers(List<Answer> answers) {
		this.answers = answers;
	}
	
	public class Answer {
		public long count = 0;
		public String text = "<<Unknown>>";
		public Long itemId = null;
		public boolean correct = false;
		public boolean primary = true;
		public boolean onAnswerKey = false;
		
		public long getCount() { return this.count; }
		public String getText() { return this.text; }
		public Long getItemId() { return this.itemId; }
		public boolean isCorrect() { return this.correct; }
		public boolean isPrimary() { return this.primary; }
		public boolean isOnAnswerKey() { return this.onAnswerKey; }
	}
}
