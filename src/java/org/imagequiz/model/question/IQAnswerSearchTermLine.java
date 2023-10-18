package org.imagequiz.model.question;

import static javax.persistence.GenerationType.IDENTITY;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;
import javax.persistence.Table;

import com.google.gson.annotations.Expose;

@Entity
@Table(name = "iqcase_answer_searchterm_line")
public class IQAnswerSearchTermLine {
	
	@Expose
    @Id
    @Column(name = "lineid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long lineId;
    
    @ManyToOne
    @JoinColumn(name = "questionid", nullable = false)
    private IQQuestionSearchTerm parentQuestion;
    
    @Expose
    @OneToMany(mappedBy="parentQuestionLine", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("wrapperid")
    private List<IQAnswerSearchTermWrapper> associatedAnswerWrappers = new ArrayList();
    
	@Expose
    @Column(name = "scoremodifier")
    private BigDecimal scoreModifier = new BigDecimal(0);
	
	@Expose
    @Column(name = "scoremissed")
    private BigDecimal scoreMissed = new BigDecimal(0);
    
	@Expose
	@Column(name = "primaryanswer")
	private boolean primaryAnswer = true;
	
	@Expose
	@Column(name = "correctanswer")
	private boolean correctAnswer = true;  

	public Long getLineId() {
		return lineId;
	}

	public void setLineId(Long lineId) {
		this.lineId = lineId;
	}



	public IQQuestionSearchTerm getParentQuestion() {
		return parentQuestion;
	}

	public void setParentQuestion(IQQuestionSearchTerm parentQuestion) {
		this.parentQuestion = parentQuestion;
	}

	public List<IQAnswerSearchTermWrapper> getAssociatedAnswerWrappers() {
		return associatedAnswerWrappers;
	}

	public void setAssociatedAnswerWrappers(List<IQAnswerSearchTermWrapper> associatedAnswerWrappers) {
		this.associatedAnswerWrappers = associatedAnswerWrappers;
	}

	public BigDecimal getScoreMissed() {
		return scoreMissed;
	}

	public void setScoreMissed(BigDecimal scoreMissed) {
		this.scoreMissed = scoreMissed;
	}
	
    
}
