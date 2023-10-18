package org.imagequiz.model.user;

import org.imagequiz.model.IQExam;

public class IQDashboardItem {
	private IQUserQuiz quiz;
	private Long delayMilis;
	private Boolean success;

	//				delay.milisLeft = waitTimeLeft;
	//delay.hrsLeft = waitTimeLeft / (1000*60*60);
	//delay.minsLeft = (waitTimeLeft / (1000*60))%60;
	
	public IQUserQuiz getQuiz() {
		return quiz;
	}
	public void setQuiz(IQUserQuiz quiz) {
		this.quiz = quiz;
	}

	public Boolean getSuccess() {
		return success;
	}
	public void setSuccess(Boolean success) {
		this.success = success;
	}
	public Long getDelayMilis() {
		return delayMilis;
	}
	public void setDelayMilis(Long delayMilis) {
		this.delayMilis = delayMilis;
	}
}
