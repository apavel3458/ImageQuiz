package org.imagequiz.model.result;

import java.math.BigDecimal;

public class IQSummaryExam {
	private long totalCount = 0;
	private long completedCount = 0;
	private long passCount = 0;
	private long attemptsBeforePass = 0;
	private BigDecimal meanFailGrade = BigDecimal.ZERO;
	private BigDecimal meanPassGrade = BigDecimal.ZERO;
	private BigDecimal meanTotalGrade = BigDecimal.ZERO;
	private long meanTimeTaken = 0;
	
	
	public long getFailCount() {
		return completedCount - passCount;
	}
	
	public long getTotalCount() {
		return totalCount;
	}
	public void setTotalCount(long totalCount) {
		this.totalCount = totalCount;
	}
	public long getCompletedCount() {
		return completedCount;
	}
	public void setCompletedCount(long completedCount) {
		this.completedCount = completedCount;
	}
	public long getPassCount() {
		return passCount;
	}
	public void setPassCount(long passCount) {
		this.passCount = passCount;
	}
	public long getAttemptsBeforePass() {
		return attemptsBeforePass;
	}
	public void setAttemptsBeforePass(long attemptsBeforePass) {
		this.attemptsBeforePass = attemptsBeforePass;
	}
	public BigDecimal getMeanFailGrade() {
		return meanFailGrade;
	}
	public void setMeanFailGrade(BigDecimal meanFailGrade) {
		this.meanFailGrade = meanFailGrade;
	}
	public BigDecimal getMeanPassGrade() {
		return meanPassGrade;
	}
	public void setMeanPassGrade(BigDecimal meanPassGrade) {
		this.meanPassGrade = meanPassGrade;
	}
	public BigDecimal getMeanTotalGrade() {
		return meanTotalGrade;
	}
	public void setMeanTotalGrade(BigDecimal meanTotalGrade) {
		this.meanTotalGrade = meanTotalGrade;
	}

	public long getMeanTimeTaken() {
		return meanTimeTaken;
	}

	public void setMeanTimeTaken(long meanTimeTaken) {
		this.meanTimeTaken = meanTimeTaken;
	}
	
	
}