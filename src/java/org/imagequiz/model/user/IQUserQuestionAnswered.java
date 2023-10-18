package org.imagequiz.model.user;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import org.imagequiz.model.question.IQAnswer;
import org.imagequiz.model.question.IQAnswerChoice;
import org.nustaq.serialization.annotations.Version;


public class IQUserQuestionAnswered implements Serializable {
	
	private String questionId;
	private ArrayList<IQAnswer> userSelections = new ArrayList<IQAnswer>();
	@Version(2)
	private ArrayList<IQAnswer> correctAnswers = new ArrayList<IQAnswer>();
	@Version(3)
	private String questionType = null;
	
	public IQUserQuestionAnswered() {
		
	}
	
	public ArrayList<IQAnswer> getUserSelections() {
		return userSelections;
	}



	public void setUserSelections(ArrayList<IQAnswer> userSelections) {
		this.userSelections = userSelections;
	}


	public BigDecimal getTotalScore() {
		BigDecimal totalScore = new BigDecimal(0);
		for (IQAnswer userSelection: userSelections)
			totalScore = totalScore.add(userSelection.getScore());
		//prevent negative score for question
		if (totalScore.compareTo(new BigDecimal(0)) == -1) return new BigDecimal(0);
		return totalScore;
	}

	public String getQuestionId() {
		return questionId;
	}

	public void setQuestionId(String questionId) {
		this.questionId = questionId;
	}
	
	public static IQUserQuestionAnswered getQuestionById(String questionId, List<IQUserQuestionAnswered> answeredQuestionList) {
		for (IQUserQuestionAnswered answered: answeredQuestionList) {
			if (answered.getQuestionId().equalsIgnoreCase(questionId)) {
				return answered;
			}
		}
		return null;
	}

	public ArrayList<IQAnswer> getCorrectAnswers() {
		return correctAnswers;
	}

	public void setCorrectAnswers(ArrayList<IQAnswer> correctAnswers) {
		this.correctAnswers = correctAnswers;
	}

	public String getQuestionType() {
		return questionType;
	}

	public void setQuestionType(String questionType) {
		this.questionType = questionType;
	}
	
}
