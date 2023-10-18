package org.imagequiz.model.user;

import java.io.IOException;
import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.OrderColumn;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQCaseBaseClass;
import org.imagequiz.model.question.IQCaseAnswer;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.util.CaseUtil;

import static javax.persistence.GenerationType.IDENTITY;

@Entity
@Table(name = "iqcasecompleted")
public class IQCaseCompleted extends IQCaseBaseClass {
	
	private Long completedCaseId;
	
	private IQCase associatedCase;
	
	private IQUserQuiz userQuiz;
	
	@Deprecated
	private byte[] answersText;
	
	@Deprecated
	private List<IQUserQuestionAnswered> answeredQuestions = new ArrayList<IQUserQuestionAnswered>();
	
	private List<IQCaseAnswer> answers = new ArrayList<IQCaseAnswer>();
	
	private BigDecimal score;
	
	private BigDecimal passScore;

	private Boolean pass;
	
	private boolean completed = true;
	
	private Long secondsTaken = new Long(0);
	
	
	@Id
	@Column(name = "casecompletedid", unique = true, nullable = false)
	@GeneratedValue(strategy = IDENTITY)
	public Long getCompletedCaseId() {
		return completedCaseId;
	}

	public void setCompletedCaseId(Long completedCaseId) {
		this.completedCaseId = completedCaseId;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "caseid", nullable = false)
	public IQCase getAssociatedCase() {
		return associatedCase;
	}
	
	
	/* UTILs -----*/
	@Transient
	public String getScoreDisplay() {
		return this.getScore().setScale(2, RoundingMode.HALF_UP).stripTrailingZeros().toPlainString();
	}
	@Transient
	public String getPassScoreDisplay() {
		return this.getPassScore().setScale(2, RoundingMode.HALF_UP).stripTrailingZeros().toPlainString();
	}
	/* GETTERS/SETTERS -----*/
	public void setAssociatedCase(IQCase associatedCase) {
		this.associatedCase = associatedCase;
	}
	
	@Transient
	public Long getCaseId() {
		return associatedCase.getCaseId();
	}



	@Column(name = "score")
	public BigDecimal getScore() {
		return score;
	}

	public void setScore(BigDecimal score) {
		this.score = score;
	}

	@Column(name = "pass")
	public Boolean isPass() {
		return pass;
	}

	public void setPass(Boolean pass) {
		this.pass = pass;
	}

	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "quizid", nullable = false)
	@OrderColumn(name = "completedcaseid")
	public IQUserQuiz getUserQuiz() {
		return userQuiz;
	}

	public void setUserQuiz(IQUserQuiz userQuiz) {
		this.userQuiz = userQuiz;
	}

	@Column(name = "passscore")
	public BigDecimal getPassScore() {
		return passScore;
	}

	public void setPassScore(BigDecimal passScore) {
		this.passScore = passScore;
	}

	@Column(name = "answersB")
	public byte[] getAnswersText() throws IOException {
		return this.answersText;
//		if (answeredQuestions != null) {
//			answersText = CaseUtil.toString((Serializable) answeredQuestions);
//			//System.out.println("serialized into: " + answersText);
//		}
//		return answersText;
	}

	public void setAnswersText(byte[] answersText) throws ClassNotFoundException, IOException {
		if (answersText != null) {
			ArrayList<IQUserQuestionAnswered> answeredQuestions = (ArrayList<IQUserQuestionAnswered>) CaseUtil.fromString(answersText);
			this.setAnsweredQuestions(answeredQuestions);
		} else {
			this.setAnsweredQuestions(new ArrayList());
		}
		
		this.answersText = answersText;
	}

	@Transient
	public List<IQUserQuestionAnswered> getAnsweredQuestions() {
		return answeredQuestions;
	}

	public void setAnsweredQuestions(ArrayList<IQUserQuestionAnswered> answeredQuestions) {
		this.answeredQuestions = answeredQuestions;
	}

	@Transient
	public boolean isCompleted() {
		return completed;
	}

	public void setCompleted(boolean completed) {
		this.completed = completed;
	}

	@Column(name = "secondstaken")
	public Long getSecondsTaken() {
		return secondsTaken;
	}

	public void setSecondsTaken(Long secondsTaken) {
		this.secondsTaken = secondsTaken;
	}

    @OneToMany(mappedBy = "associatedCaseCompleted", 
    		cascade = {javax.persistence.CascadeType.ALL}, 
    		orphanRemoval = true,
            fetch = FetchType.LAZY)
	public List<IQCaseAnswer> getAnswers() {
		return answers;
	}

	public void setAnswers(List<IQCaseAnswer> answers) {
		this.answers = answers;
	}
	
}
