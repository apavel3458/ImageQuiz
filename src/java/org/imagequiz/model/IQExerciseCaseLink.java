/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.model;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;

import static javax.persistence.GenerationType.IDENTITY;

import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Transient;
import javax.persistence.UniqueConstraint;

import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.question.IQAnswerChoice;
import org.imagequiz.model.question.IQAnswerSearchTerm;
import org.imagequiz.model.question.IQAnswerSearchTermLine;
import org.imagequiz.model.question.IQAnswerSearchTermWrapper;
import org.imagequiz.model.question.IQQuestion;
import org.imagequiz.model.question.IQQuestionChoice;
import org.imagequiz.model.question.IQQuestionSearchTerm;
import org.imagequiz.model.question.IQSearchTermGroup;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.caseutil.IQCaseObjective;
import org.imagequiz.model.caseutil.IQCaseRevision;
import org.imagequiz.util.CaseHtmlUtil;
import org.imagequiz.util.CaseParseException;
import org.imagequiz.util.CaseUtil;

import com.google.gson.annotations.Expose;

/**
 *
 * @author apavel
 */
@Entity
@Table(name = "iqexercisecaselink")
public class IQExerciseCaseLink {
	@Expose
    @Id
    @Column(name = "exercisecaselinkid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private long exerciseCaseId;
	
	@Expose
	@Column(name = "caseorder")
	private long caseOrder;
	
	@ManyToOne
	@JoinColumn(name = "caseid")
	private IQCase parentCase;
	
	@ManyToOne
	@JoinColumn(name = "exerciseId")
	private IQExercise parentExercise;
	
	public long getExerciseCaseId() {
		return exerciseCaseId;
	}

	public void setExerciseCaseId(long exerciseCaseId) {
		this.exerciseCaseId = exerciseCaseId;
	}

	public long getCaseOrder() {
		return caseOrder;
	}

	public void setCaseOrder(long caseOrder) {
		this.caseOrder = caseOrder;
	}

	public IQCase getParentCase() {
		return parentCase;
	}

	public void setParentCase(IQCase parentCase) {
		this.parentCase = parentCase;
	}
}