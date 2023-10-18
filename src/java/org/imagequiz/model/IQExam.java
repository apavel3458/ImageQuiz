package org.imagequiz.model;

import static javax.persistence.GenerationType.IDENTITY;

import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

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
import javax.persistence.Table;
import javax.persistence.Transient;
import javax.persistence.TypedQuery;

import org.apache.log4j.Logger;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.IndexColumn;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.user.IQUserAchievement;
import org.imagequiz.model.user.IQUserGroup;
import org.imagequiz.model.user.IQUserQuiz;
import org.imagequiz.web.AdminAction;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

/*
 * CREATE TABLE `iqexam` (
  `examid` int(11) NOT NULL AUTO_INCREMENT,
  `examname` varchar(60),
  `casesetid` int(11),
  `usergroupid` int(11),
  PRIMARY KEY(`examid`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
 */
@Entity
@Table(name = "iqexam")
public class IQExam {
	@Transient
	private static Logger _log = Logger.getLogger(IQExam.class);
	
	@Id
    @Column(name = "examid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long examId;
	
	@Column(name = "examname")
	private String examName;
	
	@ManyToOne
	@JoinColumn(name = "exerciseid")
	private IQExercise exercise;
	
	@ManyToOne
	@JoinColumn(name = "usergroupid")
	private IQUserGroup userGroup;
	
	@Column(name = "uniquecode")
	private String uniqueCode;
	
    @OneToMany(fetch = FetchType.LAZY, mappedBy="associatedExam")
    @Cascade({CascadeType.MERGE, CascadeType.PERSIST, CascadeType.EVICT})
	private List<IQUserQuiz> userQuizes = new ArrayList();
	
	@Column(name = "active")
	private boolean active = false;
	
	@Column(name = "deleted")
	private boolean deleted = false;
	
	@Column(name = "exammode")
	private String examMode = "exam";
	
	@ManyToOne(fetch = FetchType.LAZY)
	@JoinColumn(name = "achievementid")
	private IQUserAchievement achievements;
	
	@Transient
	private HashMap optionsMap = null;
	
	@Column(name = "options")
	private String options = "{}";
	
	public List<ExamMode> getPossible_exam_modes() { return possible_exam_modes; }
	
	public static final ExamMode EXAM_MODE_EXAM = new ExamMode("Exam", "exam");
	public static final ExamMode EXAM_MODE_PRACTICE = new ExamMode("Practice Test", "practice");
	public static final ExamMode EXAM_MODE_LEVEL = new ExamMode("Dashboard Level", "level");
	public static final ExamMode EXAM_MODE_CASEREVIEW = new ExamMode("Case Review", "casereview");
	public static final ExamMode EXAM_MODE_TEST = new ExamMode("Test Mode", "testmode");
	public static final List<ExamMode> possible_exam_modes = Arrays.asList(EXAM_MODE_EXAM, EXAM_MODE_PRACTICE, EXAM_MODE_CASEREVIEW, EXAM_MODE_TEST, EXAM_MODE_LEVEL);
	
	
	public Long getTimeToRetry(IQUserQuiz lastQuiz) throws Exception {
		BigDecimal delayIfFailHrs = this.getOptionDelayIfFailHrs();
		if (delayIfFailHrs != null) {
			long dateWhenWaitEnds = lastQuiz.getDateStarted().getTime() + delayIfFailHrs.longValue()*(1000*60*60);
			long waitTimeLeft = dateWhenWaitEnds - new Date().getTime();
			//diffHrs = diff / (1000*60*60);
			if (waitTimeLeft > 0) {
				return waitTimeLeft;
			}
		}
		return null;
	}
	
	public Long getExamId() {
		return examId;
	}

	public void setExamid(Long examId) {
		this.examId = examId;
	}

	public String getExamName() {
		return examName;
	}

	public void setExamName(String examName) {
		this.examName = examName;
	}

	public IQExercise getExercise() {
		return exercise;
	}

	public void setExercise(IQExercise exercise) {
		this.exercise = exercise;
	}

	public IQUserGroup getUserGroup() {
		return userGroup;
	}

	public void setUserGroup(IQUserGroup userGroup) {
		this.userGroup = userGroup;
	}

	public boolean isDeleted() {
		return deleted;
	}

	public void setDeleted(boolean deleted) {
		this.deleted = deleted;
	}

	public boolean isActive() {
		return active;
	}

	public void setActive(boolean active) {
		this.active = active;
	}

	public String getUniqueCode() {
		return uniqueCode;
	}

	public void setUniqueCode(String uniqueCode) {
		this.uniqueCode = uniqueCode;
	}
	
	public List<IQUserQuiz> getIncompleteUserQuizes(IQDataSource dataSource, Long userId) {
		TypedQuery<IQUserQuiz> q =dataSource.getSession().createQuery("SELECT q FROM IQUserQuiz q JOIN q.associatedExam e JOIN q.user u WHERE e.examId=:examId AND q.completed=0 AND u.userId=:userId ORDER BY q.dateStarted", IQUserQuiz.class)
    			.setParameter("examId", this.getExamId())
    			.setParameter("userId", userId);
        
        return q.getResultList();
	}
	
	public List<IQUserQuiz> getAllUserQuizes(IQDataSource dataSource, Long userId) {
		TypedQuery<IQUserQuiz> q =dataSource.getSession().createQuery("SELECT q FROM IQUserQuiz q JOIN q.associatedExam e JOIN q.user u WHERE e.examId=:examId AND u.userId=:userId ORDER BY q.dateStarted", IQUserQuiz.class)
    			.setParameter("examId", this.getExamId())
    			.setParameter("userId", userId);
        return q.getResultList();
	}
	
	public List<IQUserQuiz> getLastUserQuizes(IQDataSource dataSource, Long userId, int maxNumber) {
		TypedQuery<IQUserQuiz> q =dataSource.getSession().createQuery("SELECT q FROM IQUserQuiz q JOIN q.associatedExam e JOIN q.user u WHERE e.examId=:examId AND u.userId=:userId ORDER BY q.dateStarted DESC", IQUserQuiz.class)
    			.setParameter("examId", this.getExamId())
    			.setParameter("userId", userId);
        q.setMaxResults(maxNumber);
        return q.getResultList();
	}
	

	public List<IQUserQuiz> getUserQuizes() {
		return userQuizes;
	}

	public void setUserQuizes(List<IQUserQuiz> userQuizes) {
		this.userQuizes = userQuizes;
	}

	public String getExamMode() {
		return examMode;
	}
	
	public ExamMode getExamModeClass() {
		return IQExam.getModeClass(this.getExamMode());
	}

	public void setExamMode(String examMode) {
		this.examMode = examMode;
	}
	
	
	public static ExamMode getModeClass(String internal) {
		for (ExamMode m: possible_exam_modes) {
			if (m.equals(internal)) {
				return m;
			}
		}
		return EXAM_MODE_EXAM;
	}
	
	public boolean isAllowReviewForQuiz(Boolean quizPass) throws Exception {
		if (this.getOptionAllowReview() != null && this.getOptionAllowReview().equals("true")) 
			return true;
		if (this.getOptionAllowReview() != null && (this.getOptionAllowReview().equals("showIfPass") && quizPass))
			return true;
		return false;
//		return this.getOptionAllowReview().equals("true") ||
//				(this.getOptionAllowReview().equals("showIfPass") && quizPass);
	}
	

	private String getOptions() {
		return options;
	}

	private void setOptions(String options) {
		this.options = options;
	}
	
	public void setOptionsJson(String json) {
		//first test it:
		this.optionsMap = new Gson().fromJson(json, 
				new TypeToken<HashMap<String, Object>>(){}.getType());
		this.setOptions(json);
	}
	
	public String getOptionsJson() {
		//first test it:
		return this.options;
	}
	
	//{"mode":"practice","randomOrder":"false","showGrade":"true","allowReview":"false","passGrade":"82.0","maxTime":""}
	public HashMap<String, Object> getOptionsMap() {
		if (this.optionsMap == null) {
			this.optionsMap = new Gson().fromJson(this.getOptions(), 
										new TypeToken<HashMap<String, Object>>(){}.getType());
		}
		if (this.optionsMap == null) {
			this.optionsMap = new HashMap<String, Object>();
		}
		return this.optionsMap;
	}
	
	private Boolean getOptionBoolean(Object obj) throws Exception {
		if (obj == null) return false;
		if (obj instanceof Boolean) {
			return (Boolean) obj;
		} else if (obj instanceof String) {
			return obj.toString().equals("true");
		}
		throw new Exception("Cannot recognize boolean class");
	}
	private BigDecimal getOptionNumber(Object obj) throws Exception {
		if (obj == null) return null;
		if (obj instanceof Float) {
			return new BigDecimal((Float) obj);
		} else if (obj instanceof Double) {
			return new BigDecimal((Double) obj);
		} else if (obj instanceof String) {
			if (((String) obj).equals("")) return null;
			return new BigDecimal((String) obj);
		}
		throw new Exception("Cannot recognize number class");
	}
	public Boolean isOptionRandomOrder() throws Exception  {
		return this.getOptionBoolean(this.getOptionsMap().get("randomOrder"));
	}
	public String getOptionAllowReview() throws Exception  {
		Object allowReview = this.getOptionsMap().get("allowReview");
		if (allowReview == null) return "false";
		if (allowReview.getClass() == Boolean.class) return allowReview.toString();
		else return allowReview.toString();
	}
	public boolean isOptionShowGrade() throws Exception  {
		return this.getOptionBoolean(this.getOptionsMap().get("showGrade"));
	}
	public BigDecimal getOptionPassGrade() throws Exception {
		return this.getOptionNumber(this.getOptionsMap().get("passGrade"));
	}
	public BigDecimal getOptionMaxQuestions() throws Exception {
		return this.getOptionNumber(this.getOptionsMap().get("maxQuestions"));
	}
	public BigDecimal getOptionMaxTimeMins() throws Exception {
		return this.getOptionNumber(this.getOptionsMap().get("maxTimeMins"));
	}
	
	public String getOptionMessagePostSuccess() throws Exception {
		return (String) this.getOptionsMap().get("messagePostSuccess");
	}
	
	public String getOptionMessagePostFail() throws Exception {
		return (String) this.getOptionsMap().get("messagePostFail");
	}
	
	public String getOptionLearningObjectives() throws Exception {
		return (String) this.getOptionsMap().get("learningObjectives");
	}
	
	public BigDecimal getOptionDelayIfFailHrs() throws Exception {
		return this.getOptionNumber(this.getOptionsMap().get("delayIfFailHrs"));
	}

	public void setOptionsMap(HashMap<String, Object> map) {
		this.setOptions(new Gson().toJson(map));
		this.optionsMap = map;
	}

	public IQUserAchievement getAchievements() {
		return achievements;
	}

	public void setAchievements(IQUserAchievement achievement) {
		this.achievements = achievement;
	}
	public static class ExamMode {
		
		String visual = null;
		String internal = null;
		
		public ExamMode(String visual, String internal) {
			this.visual = visual;
			this.internal = internal;
		}
		public String getVisual() { return visual; }
		public String getInternal() { return internal; }
		public String toString() { return internal; }
		public boolean equals(ExamMode e) { 
			return this.internal.equals(e.getInternal()); 
			}
		public boolean equals(String s) { return this.internal.equals(s); }
	}
}
