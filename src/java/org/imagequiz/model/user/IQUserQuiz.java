package org.imagequiz.model.user;

import static javax.persistence.GenerationType.IDENTITY;

import java.io.Serializable;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.OrderBy;
import javax.persistence.OrderColumn;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.Transient;
import javax.persistence.TypedQuery;

import org.apache.log4j.Logger;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQCaseBaseClass;
import org.imagequiz.model.IQCaseTag;
import org.imagequiz.model.IQExam;
import org.imagequiz.model.question.IQCaseAnswer;
import org.imagequiz.model.question.IQQuestion;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.web.AdminAction;

@Entity
@Table(name = "iquserquiz")
public class IQUserQuiz implements Serializable {
	@Transient
	private static Logger _log = Logger.getLogger(IQUserQuiz.class);
	
	
	@Id
    @Column(name = "quizid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long quizId;
	
	@Column(name = "quizname")
	private String quizName;
	
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "userid", nullable = false)
	private IQUser user;
	
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "userQuiz")
	@Cascade({CascadeType.ALL})
	@OrderBy("completedCaseId")
	private List<IQCaseCompleted> completedCases = new ArrayList();
	
	@ManyToMany(fetch = FetchType.LAZY)
	@JoinTable(name = "iqquizcaselink",
    joinColumns = {@JoinColumn(name = "quizid") }, 
    inverseJoinColumns = {@JoinColumn(name = "caseid") })
	@OrderColumn(name = "caseorder")
	private List<IQCase> incompleteCases = new ArrayList();
	
	@Column(name = "completed")
	private boolean completed = false;
	
	@Column(name = "dateStarted", columnDefinition="DATETIME")
	@Temporal(TemporalType.TIMESTAMP)
	private Date dateStarted;
	
	@Column(name = "dateLastActive", columnDefinition="DATETIME")
	@Temporal(TemporalType.TIMESTAMP)
	private Date dateLastActive;
	
    @ManyToOne
    @JoinColumn(name = "examid")
    private IQExam associatedExam;
    
    @Transient
	private boolean doSave = true;
    
    @Column(name = "fixedquestions")
    private boolean fixedQuestions = true;
    
    @Column(name = "pass")
    private Boolean pass = null;
    
    @Column(name = "score")
    private BigDecimal score = null;
    
    @Column(name = "passScore")
    private BigDecimal passScore = null;
    
    @OneToOne(fetch = FetchType.LAZY, mappedBy = "quiz", cascade = javax.persistence.CascadeType.ALL)
    @Cascade({CascadeType.ALL})
	private IQUserQuizHelper helper;
    
    @OneToMany(mappedBy = "associatedQuiz", 
    		cascade = {javax.persistence.CascadeType.ALL}, 
    		orphanRemoval = true,
            fetch = FetchType.LAZY)
    private List<IQUserQuizPerformance> performance = new ArrayList();
    
    @OneToMany(mappedBy = "associatedQuiz")
    private List<IQCaseAnswer> answers = new ArrayList();
    
    @Transient
    private boolean adminTestMode = false;
    
    @Column(name = "seenAllQuestions")
    private boolean completedAllQuestions = false;
	
	public IQUserQuiz() {
		this.setCompletedCases(new ArrayList());
		this.setIncompleteCases(new ArrayList());
		helper = new IQUserQuizHelper(this);
	}
	
	public BigDecimal calcTotalGrade() {
		if (this.getScore() == null || this.getPassScore() == null) return BigDecimal.ZERO;
		BigDecimal totalGrade = this.getScore().divide(this.getPassScore(), RoundingMode.HALF_UP);
		return totalGrade;
	}
	
	// datasource for the incomplete case retrieval 
	public void calcMarkQuiz(IQDataSource dataSource) throws Exception {
		BigDecimal totalScore = this.calcTotalScore();
		
		if (totalScore == null) totalScore = BigDecimal.ZERO;
		this.setScore(totalScore); // assign quiz score permanently
		
		BigDecimal totalPassScore = this.calcTotalPassScore(dataSource);
		if (totalPassScore == null) totalPassScore = BigDecimal.ZERO;
		this.setPassScore(totalPassScore); ///assign quiz pass score permanently
		
		BigDecimal totalGrade = totalScore.divide(totalPassScore, RoundingMode.HALF_UP);
		
		
		//default passGrade to 70
		BigDecimal passGrade = this.getAssociatedExam().getOptionPassGrade()!=null?
										this.getAssociatedExam().getOptionPassGrade():new BigDecimal(70);
		
		Boolean pass = (totalGrade.compareTo(
								passGrade.divide(new BigDecimal(100))
								) >= 0)?true:false;
		this.setPass(pass);
	}
	
	//NOT CURRENTLY USED, BUT HERE IF NEEDED
	public List<IQCaseTag> getTagsOfCompletedQuestions(IQDataSource dataSource) {
		List<IQCaseTag> tags = dataSource.getSession().createQuery("SELECT DISTINCT t FROM IQUserQuiz q JOIN q.completedCases cc JOIN cc.associatedCase c JOIN c.caseTags t JOIN q.associatedExam e JOIN e.exercise ex "
				+ "WHERE c.active=1 AND q.quizId=:quizId AND t.associatedExercise.exerciseId = 100", IQCaseTag.class)
    			.setParameter("quizId", this.quizId)
    			.list();
		return tags;
	}
	
	public List<IQCaseTag> getPerformanceTags(IQDataSource dataSource) {
		List<IQCaseTag> tags = dataSource.getSession().createQuery("SELECT DISTINCT t FROM IQUserQuizPerformance p JOIN p.associatedTag t JOIN p.associatedQuiz q "
				+ "WHERE q.quizId = :quizId", IQCaseTag.class)
    			.setParameter("quizId", this.quizId)
    			.list();
		return tags;
	}
	
	//determines if there is a time limit, if there is, then check if it's within limit
	//false if no time left, true if time not defined or still has time left.
	public boolean hasTimeLeft() throws Exception {
		Long timeLeft = this.getTimeLeft();
		if (timeLeft == null) return true;
		long diffInSeconds = TimeUnit.MILLISECONDS.toSeconds(timeLeft);
		return (diffInSeconds > 0);
	}
	
	public Long getTimeLeft() throws Exception {
		if (this.getAssociatedExam() == null) return null;
		BigDecimal maxTime = this.getAssociatedExam().getOptionMaxTimeMins();
		if (maxTime == null || (maxTime.compareTo(BigDecimal.ZERO) <= 0)) return null;
		long endTime = this.getDateStarted().getTime()+(maxTime.longValue()*60000);
		long diff = endTime - new Date().getTime();
		return diff;
	}
	
	public Long calcTimeTakenMilis() throws Exception {
		long diff = this.getDateLastActive().getTime() - this.getDateStarted().getTime();
		return diff;
	}
	
    public BigDecimal calcTotalPassScore(IQDataSource dataSource) {
    	BigDecimal totalPassScore = new BigDecimal(0);
    	for (IQCaseCompleted caseCompleted: this.getCompletedCases()) {
    		totalPassScore = totalPassScore.add(caseCompleted.getPassScore());
    	}
    	_log.debug("adding total pass score from complete: " + totalPassScore);
    	
    	for (Long incompleteId: this.getHelper().getIncompleteIds()) {
    		IQCase incompleteCase = dataSource.getCase(incompleteId);
    		//_log.debug("incomplete case: " + incompleteCase.getCaseId());
    		for (IQQuestion q: incompleteCase.getQuestionList()) {
    			_log.debug("incomplete question pass score: " + q.getPassScore());
    			totalPassScore = totalPassScore.add(q.getPassScore());
    		}
    	}
    	
    	return totalPassScore;
    }
    public BigDecimal calcTotalScore() {
    	BigDecimal totalScore = new BigDecimal(0);
    	for (IQCaseCompleted caseCompleted: this.getCompletedCases()) {
    		_log.debug("Question #: " + caseCompleted.getCompletedCaseId());
    		_log.debug("Question Score: " + caseCompleted.getScoreDisplay());
    		totalScore = totalScore.add(caseCompleted.getScore());
    	}
    	return totalScore;
    }
    
    public static class GradedCategory {
    	public IQCaseTag categoryTag;
    	public BigInteger score;
    	private GradedCategory() {}
    }

	public IQCase getCaseByIdFromIncompleted(Long caseId, IQDataSource dataSource) {
		TypedQuery<IQCase> q = dataSource.getSession().createQuery("SELECT c FROM IQUserQuiz q JOIN q.incompleteCases c WHERE c.active=1 AND c.caseId=:caseId)", IQCase.class)
    			.setParameter("caseId", caseId);
		List<IQCase> result = q.getResultList();
		if (result.size() == 0) return null;
		else return result.get(0);
	}
	public IQCaseCompleted getCaseByIdFromCompleted(Long caseId, IQDataSource dataSource) {
		TypedQuery<IQCaseCompleted> q = dataSource.getSession().createQuery("SELECT cc FROM IQCaseCompleted cc JOIN cc.associatedCase c WHERE c.active=1 AND c.caseId=:caseId)", IQCaseCompleted.class)
    			.setParameter("caseId", caseId);
		List<IQCaseCompleted> result = q.getResultList();
		if (result.size() == 0) return null;
		else return result.get(0);
	}
	
	public int getCaseIndexByIdFromCompleted(Long caseId, IQDataSource dataSource) {
		TypedQuery<Long> q = dataSource.getSession().createQuery("SELECT c.caseId FROM IQCaseCompleted cc JOIN cc.userQuiz q JOIN cc.associatedCase c WHERE q.quizId=:quizId ORDER BY cc.completedCaseId)", Long.class)
    			.setParameter("quizId", this.quizId);
		List<Long> result = q.getResultList();
		if (result.size() == 0) return -1;
		else {
		
			for (int i=0; i< result.size(); i++) {
				Long cid = (Long) result.get(i);
				if (cid.compareTo(caseId) == 0) {
					return i;
				}
			}
			return -1;
		}
	}
	
	public Long getCompletedCaseCount(IQDataSource dataSource) {
		Long count = (Long) dataSource.getSession().createQuery("SELECT count(*) FROM IQUserQuiz q JOIN q.completedCases cc WHERE q.quizId=:quizid)", Long.class)
		.setParameter("quizid", this.quizId).uniqueResult();
		return count;
	}
	
	public boolean containsCompletedCase(Long caseId, IQDataSource dataSource) {
		Long count = (Long) dataSource.getSession().createQuery("SELECT count(*) FROM IQCaseCompleted cc JOIN cc.associatedCase c JOIN cc.userQuiz q WHERE q.quizId=:quizId AND c.caseId=:caseId)", Long.class)
				.setParameter("quizId", this.quizId)
				.setParameter("caseId", caseId).uniqueResult();
		return (count > 0);
	}
	
	public IQCaseBaseClass getCaseByIdCompletedAndIncompleted(Long caseId, IQDataSource dataSource) {
		IQCase foundCase = this.getCaseByIdFromIncompleted(caseId, dataSource);
		if (foundCase != null) return foundCase;
		else
			return this.getCaseByIdFromCompleted(caseId, dataSource);
	}
	
	public Long getQuizId() {
		return quizId;
	}

	public void setUserQuizId(Long quizId) {
		this.quizId = quizId;
	}

	public List<IQCaseCompleted> getCompletedCases() {
		return completedCases;
	}

	public void setCompletedCases(List<IQCaseCompleted> completedCases) {
		this.completedCases = completedCases;
	}

	@Deprecated
	public List<IQCase> getIncompleteCases() {
		return incompleteCases;
	}

	public void setIncompleteCases(List<IQCase> incompleteCases) {
		this.incompleteCases = incompleteCases;
	}

	public boolean isCompleted() {
		return completed;
	}

	public void setCompleted(boolean completed) {
		this.completed = completed;
	}

	public IQUser getUser() {
		return user;
	}

	public void setUser(IQUser user) {
		this.user = user;
	}

	public Date getDateStarted() {
		return dateStarted;
	}

	public void setDateStarted(Date dateStarted) {
		this.dateStarted = dateStarted;
	}

	public Date getDateLastActive() {
		return dateLastActive;
	}

	public void setDateLastActive(Date dateLastActive) {
		this.dateLastActive = dateLastActive;
	}

	public IQExam getAssociatedExam() {
		return associatedExam;
	}

	public void setAssociatedExam(IQExam associatedExam) {
		this.associatedExam = associatedExam;
	}

	public String getQuizName() {
		return quizName;
	}

	public void setQuizName(String quizName) {
		this.quizName = quizName;
	}

	public boolean isDoSave() {
		return doSave;
	}

	public void setDoSave(boolean doSave) {
		this.doSave = doSave;
	}

	public boolean isFixedQuestions() {
		return fixedQuestions;
	}

	public void setFixedQuestions(boolean fixedQuestions) {
		this.fixedQuestions = fixedQuestions;
	}

	public IQUserQuizHelper getHelper() {
		if (helper == null) {
			helper = new IQUserQuizHelper(this);
		}
		return helper;
	}

	public void setHelper(IQUserQuizHelper helper) {
		this.helper = helper;
	}

	public boolean isAdminTestMode() {
		return adminTestMode;
	}

	public void setAdminTestMode(boolean adminTestMode) {
		this.adminTestMode = adminTestMode;
	}

	public Boolean getPass() {
		return pass;
	}

	public void setPass(Boolean pass) {
		this.pass = pass;
	}

	public BigDecimal getScore() {
		return score;
	}

	public void setScore(BigDecimal score) {
		this.score = score;
	}

	public List<IQUserQuizPerformance> getPerformance() {
		return performance;
	}

	public void setPerformance(List <IQUserQuizPerformance> performance) {
		this.performance = performance;
	}

	public BigDecimal getPassScore() {
		return passScore;
	}

	public void setPassScore(BigDecimal passScore) {
		this.passScore = passScore;
	}

	public boolean isCompletedAllQuestions() {
		return completedAllQuestions;
	}

	public void setCompletedAllQuestions(boolean completedAllQuestions) {
		this.completedAllQuestions = completedAllQuestions;
	}

	public List<IQCaseAnswer> getAnswers() {
		return answers;
	}

	public void setAnswers(List<IQCaseAnswer> answers) {
		this.answers = answers;
	}

}
