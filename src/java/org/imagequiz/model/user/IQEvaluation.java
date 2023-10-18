package org.imagequiz.model.user;

import java.io.Serializable;

public class IQEvaluation implements Serializable {
	private Long caseId;
	private Long grade;

	public Long getCaseId() {
		return caseId;
	}

	public void setCaseId(Long caseId) {
		this.caseId = caseId;
	}
}
