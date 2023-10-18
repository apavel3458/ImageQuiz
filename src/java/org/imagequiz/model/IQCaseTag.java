package org.imagequiz.model;

import static javax.persistence.GenerationType.IDENTITY;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

import org.apache.log4j.Logger;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.user.IQUserQuizPerformance;
import org.imagequiz.web.AdminAction;

import com.google.gson.annotations.Expose;


@Entity
@Table(name = "iqcasetag")
public class IQCaseTag {
	private static Logger _log = Logger.getLogger(AdminAction.class);
	
	@Expose
    @Id
    @Column(name = "tagid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long tagId;
	
	@Expose
	@Column(name = "tagname")
	private String tagName;
	
	@Expose
	@Column(name = "prefix")
	private String prefix = "";
	
    @ManyToMany(fetch = FetchType.LAZY)
    @Cascade({CascadeType.SAVE_UPDATE, CascadeType.REFRESH})
    @JoinTable(name = "iqcasetaglink",
            joinColumns = {@JoinColumn(name = "tagid") },
            inverseJoinColumns = {@JoinColumn(name = "caseid") })
    private List<IQCase> associatedCases = new ArrayList();
	
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinTable(name = "iqexercisetaglink", 
	joinColumns = {@JoinColumn(name = "tagid") },
	inverseJoinColumns = {@JoinColumn(name = "exerciseid")})
    private IQExercise associatedExercise;
    
    @OneToMany(fetch = FetchType.LAZY, cascade = {javax.persistence.CascadeType.ALL}, mappedBy="associatedTag")
    private List<IQUserQuizPerformance> performance = new ArrayList();
    
    @Column(name = "resources")
    @Expose
    private String resourcesJson = null;
    
    @Transient
    @Expose
    private Long preparedCaseCount = new Long(0); 
    
    @Transient
    @Expose
    private BigDecimal preparedGrade = null;
    
    public void prepareForGson(IQDataSource dataSource, boolean getPerformance, boolean getCaseCount) {
    	//case count
    	if (getCaseCount) {
	    	Long count = (Long) dataSource.getSession().createQuery("Select count(*) FROM IQCase c JOIN c.caseTags t "
			   		+ "WHERE c.active = true AND t.tagId=:tagId") 
			   .setParameter("tagId", this.getTagId()).uniqueResult();
	    	this.setPreparedCaseCount(count);
    	}
    	
    	if (getPerformance) {
    		List<IQUserQuizPerformance> ps = dataSource.getSession().createQuery("SELECT DISTINCT p FROM IQUserQuizPerformance p JOIN p.associatedTag t JOIN t.associatedCases c"
			   		+ " WHERE c.active = true AND t.tagId=:tagId", IQUserQuizPerformance.class) 
			   .setParameter("tagId", this.getTagId()).list();
	    	//_log.debug("FOUND PERFORMANCES: " + ps.size());
    		BigDecimal score = BigDecimal.ZERO;
    		BigDecimal passScore = BigDecimal.ZERO;
    		BigDecimal total = BigDecimal.ZERO;
	    	//set performance numbers
	    	for (IQUserQuizPerformance p: ps) {
	    		//_log.debug(" PERFORMANCES NAME: " + p.getAssociatedTag().getTagName());
	    		score = score.add(p.getTotalScore());
	    		passScore = passScore.add(p.getTotalPassScore());
	    		total = total.add(BigDecimal.ONE);
	    	}

	    	if (passScore.equals(BigDecimal.ZERO))
	    		this.setPreparedGrade(null);
	    	else
	    		this.setPreparedGrade(score.divide(passScore, RoundingMode.HALF_UP).multiply(new BigDecimal(100)));
    	}
    }
    
	public String getTagName() {
		return tagName;
	}
	
	public IQCaseTag() {
		
	}
	public IQCaseTag(String tagName) {
		this.tagName = tagName;
	}
	
	public void setTagName(String tagName) {
		this.tagName = tagName;
	}


	public List<IQCase> getAssociatedCases() {
		return associatedCases;
	}

	public void setAssociatedCases(List<IQCase> associatedCases) {
		this.associatedCases = associatedCases;
	}
	
	public static ArrayList<IQCaseTag> stringToCaseTags(String stringCaseTags) {
		String[] stringArray = stringCaseTags.split(",");
		ArrayList<IQCaseTag> tagArray = new ArrayList();
		for (String tag: stringArray) {
			tagArray.add(new IQCaseTag(tag.trim()));
		}
		return tagArray;
	}
	
	
	public boolean equals(Object caseTagObj) {
		IQCaseTag caseTag = (IQCaseTag) caseTagObj;
		if (this.tagId == caseTag.getTagId()) {
			return true;
		}
		return false;
	}

	public Long getTagId() {
		return tagId;
	}

	public void setTagId(Long tagId) {
		this.tagId = tagId;
	}

	public IQExercise getAssociatedExercise() {
		return associatedExercise;
	}

	public void setAssociatedExercise(IQExercise associatedExercise) {
		this.associatedExercise = associatedExercise;
	}
	
	static HashMap<String, String[]> map = new HashMap();
	public static HashMap<String, String[]> getCategoriesMap() {
		   if (map.size() == 0) {
			   map.put("2.1.1", new String[] {"Critical Care", "Cc" });
			   map.put("2.1.2", new String[] {"Cardiology", "C"});
			   map.put("2.1.3", new String[] {"Cardiology", "C"});
			   map.put("2.1.4", new String[] {"Respirology", "R"});
			   map.put("2.1.5", new String[] {"Gastroenterology", "G"});
			   map.put("2.1.6", new String[] {"Nephrology", "N"});
			   map.put("2.1.7", new String[] {"Endocrinology", "E"});
			   map.put("2.1.8", new String[] {"Neurology", "Nr"});
			   map.put("2.1.9", new String[] {"Hematology", "H"});
			   map.put("2.1.10", new String[] {"Rheumatology", "Rh"});
			   map.put("2.1.11", new String[] {"Infectious Diseases", "I"});
			   map.put("2.1.12", new String[] {"Dermatology", "D"});
			   map.put("2.1.13", new String[] {"Infectious Diseases", "I"});
			   map.put("2.1.14.1", new String[] {"Perioperative Medicine", "Pm"});
			   map.put("2.1.14.4", new String[] {"Obstetrical Medicine", "Ob"});
			   map.put("2.1.14.5", new String[] {"Geriatrics", "G"});
			   map.put("2.1.14.6", new String[] {"Palliative Care", "P"});
			   map.put("2.1.14.7", new String[] {"Oncology", "O"});
		   }
		   return map;
	 }
	
	 public static String getTagPrefix(String tagName) {
		   for (Map.Entry<String, String[]> entry: getCategoriesMap().entrySet()) {
			   if (entry.getValue()[0].equals(tagName)) {
				   return entry.getValue()[1];
			   }
		   }
		   return "";
	 }

	public List<IQUserQuizPerformance> getPerformance() {
		return performance;
	}

	public void setPerformance(List<IQUserQuizPerformance> performance) {
		this.performance = performance;
	}

	public Long getPreparedCaseCount() {
		return preparedCaseCount;
	}

	public void setPreparedCaseCount(Long preparedCaseCount) {
		this.preparedCaseCount = preparedCaseCount;
	}

	public BigDecimal getPreparedGrade() {
		return preparedGrade;
	}

	public void setPreparedGrade(BigDecimal preparedGrade) {
		this.preparedGrade = preparedGrade;
	}

	public String getPrefix() {
		return prefix;
	}

	public void setPrefix(String prefix) {
		this.prefix = prefix;
	}

	public String getResourcesJson() {
		return resourcesJson;
	}

	public void setResourcesJson(String resourcesJson) {
		this.resourcesJson = resourcesJson;
	}

}
