package org.imagequiz.model.result;

import java.util.ArrayList;
import java.util.List;

import org.imagequiz.model.IQCase;
import org.imagequiz.model.question.IQAnswerChoice;
import org.imagequiz.model.question.IQQuestionChoice;

public class IQSummaryText extends IQSummaryQ {
	protected List<String> answers = new ArrayList();
	
	public IQSummaryText() {
		this.setType(TYPE_TEXT);
	}
	
	public List<String> getAnswers() {
		return answers;
	}

	public void setAnswers(List<String> answers) {
		this.answers = answers;
	}
}