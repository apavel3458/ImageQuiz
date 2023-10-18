package org.imagequiz.model;

public abstract class IQCaseBaseClass {
	
	abstract public Long getCaseId();
	abstract public boolean isCompleted();
	
	//used by AdminAction in .remove(object) in saveTags();
	public boolean equals(IQCaseBaseClass compareCases) {
		if (this.getCaseId() == compareCases.getCaseId()) {
			return true;
		}
		return false;
	}
	
}
