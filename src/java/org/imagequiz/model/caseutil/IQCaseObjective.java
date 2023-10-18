package org.imagequiz.model.caseutil;

import static javax.persistence.GenerationType.IDENTITY;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.OrderColumn;
import javax.persistence.Table;

import org.imagequiz.model.IQCase;

import com.google.gson.annotations.Expose;

/*
 * 
 * CREATE TABLE iqobjectives (
	`objectiveid` int(11) NOT NULL AUTO_INCREMENT,
	`objectivecode` varchar(60) NOT NULL,
	`objectivename` text,
	 PRIMARY KEY (`objectiveid`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE iqcase_objectives_link (
    `objectivelinkid` int(11) NOT NULL AUTO_INCREMENT,
	`caseid` int(11) NOT NULL REFERENCES iqcase(caseid),
	`objectiveid` int(11) NOT NULL REFERENCES iqobjectives(objectiveid),
	 PRIMARY KEY (`objectivelinkid`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
 */

@Entity
@Table(name = "iqobjectives")
public class IQCaseObjective {
	@Expose
	@Id
    @Column(name = "objectiveid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long objectiveId;
	
	@Expose
	@Column(name = "objectivecode")
	private String objectiveCode;
	
	@Expose
	@Column(name = "objectivename")
	private String objectiveName;
	
	@ManyToMany(fetch = FetchType.LAZY)
	@JoinTable(name = "iqcase_objectives_link",
    joinColumns = {@JoinColumn(name = "objectiveid") }, 
    inverseJoinColumns = {@JoinColumn(name = "caseid") })
	private List<IQCase> parentCases = new ArrayList();

	public Long getObjectiveId() {
		return objectiveId;
	}

	public void setObjectiveId(Long objectiveId) {
		this.objectiveId = objectiveId;
	}

	public String getObjectiveCode() {
		return objectiveCode;
	}

	public void setObjectiveCode(String objectiveCode) {
		this.objectiveCode = objectiveCode;
	}

	public String getObjectiveName() {
		return objectiveName;
	}

	public void setObjectiveName(String objectiveName) {
		this.objectiveName = objectiveName;
	}

	public List<IQCase> getParentCases() {
		return parentCases;
	}

	public void setParentCases(List<IQCase> parentCases) {
		this.parentCases = parentCases;
	}

}
