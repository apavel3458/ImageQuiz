package org.imagequiz.model.user;

import static javax.persistence.GenerationType.IDENTITY;

import java.io.IOException;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.OneToOne;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.imagequiz.util.CaseUtil;

@Entity
@Table(name = "iquserquizhelper")
public class IQUserQuizHelper implements Serializable{
	private Long helperId;
	
	private IQUserQuiz quiz;
		
	private List<TwoIds> completedIds = new ArrayList();
	
	private List<Long> incompleteIds = new ArrayList();
	

	private String performanceString = "";
	
	private LinkedHashMap<String, Object> performance = new LinkedHashMap();

	private IQUserQuizHelper() {}
	
	public IQUserQuizHelper(IQUserQuiz quiz) {
		this.setQuiz(quiz);
	}
	
	
	@Id
    @Column(name = "helperid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	public Long getHelperId() {
		return helperId;
	}

	public void setHelperId(Long helperId) {
		this.helperId = helperId;
	}

	@OneToOne
	@JoinColumn(name = "quizid")
	public IQUserQuiz getQuiz() {
		return quiz;
	}

	public void setQuiz(IQUserQuiz quiz) {
		this.quiz = quiz;
	}
	
	private static String arrayToString(List<Long> array) {
		StringBuilder strbul  = new StringBuilder();
	     Iterator<Long> iter = array.iterator();
	     while(iter.hasNext())
	     {
	         strbul.append(iter.next());
	        if(iter.hasNext()){
	         strbul.append(",");
	        }
	     }
	 return strbul.toString();
	}
	
	private static List<Long> stringToArray(String array) {
		 String[] stringList = array.split(",");
		 List<Long> result = new ArrayList();
	     for (String string: stringList)
	     {
	     if (string != null && !string.equals(""))
	        result.add(Long.parseLong(string));
	     }
	 return result;
	}

	@Column(name = "completedids")
	private String getCompletedIdsText() {
		/*try {
			return new String(CaseUtil.toString((Serializable) this.getCompletedIds()));
		} catch (IOException e) {
			e.printStackTrace();
			return "";
		}*/
		
		StringBuilder strbul  = new StringBuilder();
	     Iterator<TwoIds> iter = this.completedIds.iterator();
	     while(iter.hasNext())
	     {
	         strbul.append(iter.next());
	        if(iter.hasNext()){
	         strbul.append(",");
	        }
	     }
	     return strbul.toString();
	}

	public void setCompletedIdsText(String completedIdsText) {
		/*try {
			this.setCompletedIds((List<TwoIds>) CaseUtil.fromString(completedIdsText.getBytes()));
		} catch (Exception e) {
			e.printStackTrace();
			this.setCompletedIds(null);
		}*/
		 String[] stringList = completedIdsText.split(",");
		 List<TwoIds> result = new ArrayList();
	     for (String string: stringList) {
		     if (string != null && !string.equals(""))
		        result.add(new TwoIds(string));
	     }
	     this.setCompletedIds(result);
	}

	@Column(name = "incompleteids")
	private String getIncompleteIdsText() {
		return arrayToString(this.getIncompleteIds());
	}

	private void setIncompleteIdsText(String incompleteIdsText) {
		this.incompleteIds = stringToArray(incompleteIdsText);
	}
	
	@Transient
	public List<TwoIds> getCompletedIds() {
		return completedIds;
	}

	public void setCompletedIds(List<TwoIds> completedIds) {
		this.completedIds = completedIds;
	}

	@Transient
	public List<Long> getIncompleteIds() {
		return incompleteIds;
	}

	public void setIncompleteIds(List<Long> incompleteIds) {
		this.incompleteIds = incompleteIds;
	}

	@Column(name = "performance")
	private String getPerformanceText() {
		try {
			this.performanceString = new String(CaseUtil.toString(this.performance));
			return this.performanceString;
		} catch (IOException e) { e.printStackTrace(); }
		return "";
	}

	private void setPerformanceText(String performanceString) throws Exception {
		try {
			LinkedHashMap<String, Object> result = (LinkedHashMap<String, Object>) CaseUtil.fromString(performanceString.getBytes());
		} catch (Exception e) { e.printStackTrace(); }
	}

	@Transient
	public LinkedHashMap<String, Object> getPerformance() {
		return performance;
	}

	public void setPerformance(LinkedHashMap<String, Object> performance) {
		this.performance = performance;
	}
	
	
	
	/* utility classes */
	
	
	@Transient
	public TwoIds getCompletedIdByCaseId(Long caseId) {
		for (TwoIds e: this.completedIds) {
			if (e.caseId.equals(caseId))
				return e;
		}
		return null;
	}
	
	public boolean hasCompletedIdByCaseId(Long caseId) {
		if (getCompletedIdByCaseId(caseId) != null) {
			return true;
		}
		return false;
	}
	
	public int getCompletedIndexByCaseId(Long caseId) {
		for (int i=0; i< this.completedIds.size(); i++) {
			TwoIds e = this.completedIds.get(i);
			if (e.caseId.equals(caseId)) {
				return i;
			}
		}
		return -1;
	}
	
	
	@Transient
	public boolean hasIncompleteIdByCaseId(Long caseId) {
		for (Long e: this.incompleteIds) {
			if (e.equals(caseId))
				return true;
		}
		return false;
	}
	
	
	public class TwoIds implements Serializable {
		public Long completedCaseId;
		public Long caseId;
		@Override
		public boolean equals(Object obj) {
			return caseId.equals(((TwoIds) obj).caseId);
		}
		public TwoIds(Long caseId, Long completedCaseId) {
			this.caseId = caseId;
			this.completedCaseId = completedCaseId;
		}
		@Override
		public String toString() {			
			if (completedCaseId == null) 
				return "|" + caseId.toString();
			if (caseId == null) 
				return completedCaseId.toString() + "|";
			return completedCaseId.toString() + "|" + caseId.toString();
		}
		public TwoIds(String str) {
			String[] s =  str.split("\\|", -1);  //NEED TO CHECK TO MAKE SURE "|23" PARSES TO NULL + 23
			//System.out.println("PARSED STRING: " + str);
			try {
				completedCaseId = Long.parseLong(s[0]);
				caseId = Long.parseLong(s[1]);
			} catch (NumberFormatException nfe) {
				nfe.printStackTrace();
			}
		}
	}
	
}
