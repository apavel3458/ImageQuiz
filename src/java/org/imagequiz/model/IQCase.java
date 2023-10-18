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
import org.imagequiz.model.user.IQUserQuiz;
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
@Table(name = "iqcase", uniqueConstraints = @UniqueConstraint(columnNames = {"caseid"}))
public class IQCase extends IQCaseBaseClass {
	@Expose
    @Id
    @Column(name = "caseid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
    private Long caseId = null;
    
	@Expose
    @Column(name = "casename")
    private String caseName;
    
	@Expose
    @Column(name = "casetext")
    private String caseText;
    
	@Expose
    @Column(name = "caseanswertext")
    private String caseAnswerText;
    
    @Column(name = "casexml")
    private String caseXml;
    
    @Expose
    @OneToMany(mappedBy="parentCase", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<IQQuestion> questionList = new ArrayList();
    //also contain scoring/ answers.
    
    
    //all question tags, customInvestigations, and customTreatments go into customTags
    @Transient
    private List<IQTagGroup> customTags = new ArrayList();  //MAKE LIST OF TAG GROUPS
    
    @ManyToMany(cascade = javax.persistence.CascadeType.ALL)
    @JoinTable(name = "iqcaseimagelink",
            joinColumns = {@JoinColumn(name = "caseid") }, 
            inverseJoinColumns = {@JoinColumn(name = "imageid") })
    private List<IQImage> images = new ArrayList();
    
    @ManyToMany(fetch = FetchType.LAZY, cascade = CascadeType.REFRESH, mappedBy = "associatedCases")
    private List<IQCaseTag> caseTags = new ArrayList();
    
    @ManyToMany(fetch = FetchType.LAZY, mappedBy = "cases")
    //@Where(clause="active <> '0'")
    private List<IQExercise> parentExercises = new ArrayList();
    
    @OneToMany(mappedBy="associatedCase", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<IQCaseComment> comments = new ArrayList();
    
    @OneToMany(mappedBy="parentCase")
    private List<IQCaseRevision> revisionHistory = new ArrayList();
    
    @ManyToMany(fetch = FetchType.LAZY, mappedBy="parentCases")
    private List<IQCaseObjective> caseObjectives = new ArrayList();
    
    @OneToMany(fetch = FetchType.LAZY, mappedBy="parentCase")
    private List<IQExerciseCaseLink> exerciseCaseLink = new ArrayList();
    
    @Column(name = "active")
    private boolean active = true;
    
    //determines if special code is needed to display the question (i.e. for mcq needs to display question and answer
    @Expose
    @Column(name = "displaytype")
    private Integer displayType = 0;
    
    @Column(name = "editortype")
    private String editorType = "";
    
    @Expose
    @Transient
    private String prefix = "";
    
    @Transient
    public static Integer DISPLAY_QUESTION_WITH_ANSWER = 1;
    public static String EDITOR_MCQ = "mcq";
    public static String EDITOR_SG = "sg";
    
    @Transient
    private boolean parsed = false;
    
    @Transient
    private boolean completed = false;
    
    @Expose
    @Transient
    private Long activeComments = null;
    
    /*
    //maps things in <settings tag to case-text text i..e <settings><question id=1>   <case-text> first question: {1:question}
    private HashMap<String, Object[]> caseItemIdMap;
    //first object is String (array name), second is Integer (index),
    */ 
    
    public IQCase() {
        
    }
    
    
    public IQCase(IQCaseDAO iqCaseDao) {
        caseXml = iqCaseDao.getQuestionxml();
        //parseMe();
    }
    
   
    public boolean equals(Object compareCase) {
    	if (compareCase == null) return false;
    	return this.getCaseId() == ((IQCaseBaseClass) compareCase).getCaseId();
    }
    
    public void addJsonProps(IQCase ncase, IQDataSource dataSource) {
    	// must associate child objects
		this.setCaseAnswerText(ncase.getCaseAnswerText());
		this.setCaseText(ncase.getCaseText());
		this.setParsed(true);
		this.setDisplayType(ncase.getDisplayType());
		
		for (IQQuestion question: ncase.getQuestionList()) {
			question.setParentCase(this);
			question.setParentsDeleteOrphans(dataSource);
			if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_SEARCHTERM) || question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_SEARCHTERM_SETS)) {
				IQQuestionSearchTerm qst = (IQQuestionSearchTerm) question;
				for (IQAnswerSearchTermLine line : qst.getAssociatedAnswerLines()) {
					line.setParentQuestion(qst);
					for (IQAnswerSearchTermWrapper wrapper: line.getAssociatedAnswerWrappers()) {
						wrapper.setParentQuestionLine(line);
						IQAnswerSearchTerm item = dataSource.getSession().find(IQAnswerSearchTerm.class, wrapper.getSearchTerm().getSearchTermId());
						wrapper.setSearchTerm(item);
					}
				}
				for (String groupName : qst.getAvailableGroupsText().split(",")) {
					groupName = groupName.trim();
					List<IQSearchTermGroup> groups = dataSource.getSession().createQuery("SELECT g FROM IQSearchTermGroup g WHERE g.groupName = :groupName", IQSearchTermGroup.class)
						.setParameter("groupName", groupName)
						.list();
					qst.getAvailableGroups().addAll(groups);
				}
			}
		}
		this.setQuestionList(ncase.getQuestionList());
		for (IQQuestion q: this.getQuestionList()) {
			System.out.println(q.getQuestionTextId());
		}
    }
    
    public String getCaseQuestionHtml(IQDataSource dataSource, IQCaseCompleted caseCompleted, IQUserQuiz quiz) throws CaseParseException {
        CaseHtmlUtil caseHtmlUtil = new CaseHtmlUtil();
        CaseUtil caseUtil = new CaseUtil();
        //IQCaseCompleted nullCompletedCase = new IQCaseCompleted();
        //String caseText = caseUtil.unescapeHTMLforXML(this.getCaseText());
        caseText = this.getCaseText();
        return caseHtmlUtil.convertToCaseHtml(caseText, this, caseCompleted, quiz, dataSource, false);        
    }
    
    public String getCaseAnswerHtml(IQDataSource dataSource, IQCaseCompleted completedCase, IQUserQuiz quiz) throws CaseParseException {
        CaseHtmlUtil caseHtmlUtil = new CaseHtmlUtil();
        String caseAnswerText = this.getCaseAnswerText();
        String caseFinalText;
    	if (this.getDisplayType().equals(IQCase.DISPLAY_QUESTION_WITH_ANSWER)) {
    		CaseUtil caseUtil = new CaseUtil();
    		String caseQuestionText = caseUtil.removeAllQuestionMarkup(this.getCaseText());
    		caseFinalText = caseQuestionText + caseAnswerText;
    	} else 
    		caseFinalText = caseAnswerText;
    	CaseUtil caseUtil = new CaseUtil();
    	//caseFinalText = caseUtil.unescapeHTMLforXML(caseFinalText);
        return caseHtmlUtil.convertToCaseHtml(caseFinalText, this, completedCase, quiz,  dataSource, true);        
    }
    
    public List<IQExercise> getParentActiveExercises(IQDataSource dataSource) {
    	List<IQExercise> exerciseList = dataSource.getSession().createQuery("FROM IQExercise e JOIN e.cases c WHERE e.active = true AND c.caseId=:caseId")
    			.setParameter("caseId", this.getCaseId())
    			.list();
    	return exerciseList;
    }

    /**
     * @return the caseXml
     */
    public String getCaseXml() {
        return caseXml;
    }

    /**
     * @param caseXml the caseXml to set
     */
    public void setCaseXml(String caseXml) {
        this.caseXml = caseXml;
    }
    
    public IQQuestion getQuestionById(String id) {
        for (IQQuestion question: questionList) {//CHECK TO STRING IF WORKS
            if (question.getQuestionTextId().equalsIgnoreCase(id)) return question;
        }
        /*
        for (IQInvestigation inv: customInvestigations) {
            if (inv.getInvestigationId().equalsIgnoreCase(id)) return inv;
        }*/
        
        return null;
    }
    
    public List<IQQuestion> getQuestionsByType(String questionTypeStr) {
    	List<IQQuestion> found = new ArrayList();
    	for (IQQuestion question: questionList) {
            if (question.getQuestionType().equalsIgnoreCase(questionTypeStr)) {
            	found.add(question);
            }
        }
    	return found;
    }

    /**
     * @return the questionList
     */
    public List<IQQuestion> getQuestionList() {
        return questionList;
    }

    /**
     * @param questionList the questionList to set
     */
    public void setQuestionList(List<IQQuestion> questionList) {
        this.questionList = questionList;
    }

    /**
     * @return the customTags
     */
    public List<IQTagGroup> getCustomTags() {
        return customTags;
    }

    /**
     * @param customTags the customTags to set
     */
    public void setCustomTags(List<IQTagGroup> customTags) {
        this.customTags = customTags;
    }

    /**
     * @return the caseId
     */

    public Long getCaseId() {
        return caseId;
    }

    /**
     * @param caseId the caseId to set
     */
    public void setCaseId(Long caseId) {
        this.caseId = caseId;
    }

	public String getCaseName() {
		return caseName;
	}

	public void setCaseName(String caseName) {
		this.caseName = caseName;
	}

	public List<IQImage> getImages() {
		return images;
	}

	public void setImages(List<IQImage> images) {
		this.images = images;
	}

	public String getCaseText() {
		return caseText;
	}

	public void setCaseText(String caseText) {
		this.caseText = caseText;
	}

	public String getCaseAnswerText() {
		return caseAnswerText;
	}

	public void setCaseAnswerText(String caseAnswerText) {
		this.caseAnswerText = caseAnswerText;
	}

	public List<IQCaseTag> getCaseTags() {
		return caseTags;
	}

	public void setCaseTags(List<IQCaseTag> caseTags) {
		this.caseTags = caseTags;
	}
	
	public boolean hasCaseByIdUtil(List<IQCase> cases, Long caseId) {
		for (IQCase curCase: cases) {
			if (curCase.getCaseId() == caseId)
				return true;
		}
		return false;
	}

	public List<IQExercise> getParentExercises() {
		return parentExercises;
	}

	public void setParentExercises(List<IQExercise> parentExercises) {
		this.parentExercises = parentExercises;
	}

	public boolean isParsed() {
		return parsed;
	}

	public void setParsed(boolean parsed) {
		this.parsed = parsed;
	}

	public boolean isCompleted() {
		return completed;
	}

	public void setCompleted(boolean completed) {
		this.completed = completed;
	}

	public boolean isActive() {
		return active;
	}

	public void setActive(boolean active) {
		this.active = active;
	}

	public List<IQCaseComment> getComments() {
		return comments;
	}

	public void setComments(List<IQCaseComment> comments) {
		this.comments = comments;
	}

	public Integer getDisplayType() {
		return displayType;
	}

	public void setDisplayType(Integer displayType) {
		this.displayType = displayType;
	}

	public String getEditorType() {
		return editorType;
	}

	public void setEditorType(String editorType) {
		this.editorType = editorType;
	}

	public List<IQCaseRevision> getRevisionHistory() {
		return revisionHistory;
	}

	public void setRevisionHistory(List<IQCaseRevision> revisionHistory) {
		this.revisionHistory = revisionHistory;
	}

	public List<IQCaseObjective> getCaseObjectives() {
		return caseObjectives;
	}

	public void setCaseObjectives(List<IQCaseObjective> caseObjectives) {
		this.caseObjectives = caseObjectives;
	}

	public String getPrefix() {
		return prefix;
	}

	public void setPrefix(String prefix) {
		this.prefix = prefix;
	}


	public Long getActiveComments() {
		return activeComments;
	}


	public void setActiveComments(Long activeComments) {
		this.activeComments = activeComments;
	}
	


}