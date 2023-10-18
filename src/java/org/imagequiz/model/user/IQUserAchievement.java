package org.imagequiz.model.user;

import static javax.persistence.GenerationType.IDENTITY;

import java.util.Date;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.Table;

import com.google.gson.annotations.Expose;


@Entity
@Table(name = "iquser_achievement")
public class IQUserAchievement {
	@Expose
	@Id
    @Column(name = "achievementid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private String achievementId;
	
	@ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "iquser_achievement_link",
            joinColumns = {@JoinColumn(name = "achievementid") }, 
            inverseJoinColumns = {@JoinColumn(name = "userid") })
	private List<IQUser> associatedUsers;
	
	@Expose
	@Column(name = "achievementName")
	private String achievementName;
	
	@Expose
	@Column(name = "achievementShort")
	private String achievementShort;
	
	@Expose
	@Column(name = "level")
	private Integer level;
	
	
	public boolean equals(Object compare) {
		return (this.getAchievementId().equals(((IQUserAchievement) compare).getAchievementId()));
	}

	public String getAchievementId() {
		return achievementId;
	}

	public void setAchievementId(String achievementId) {
		this.achievementId = achievementId;
	}

	public String getAchievementName() {
		return achievementName;
	}

	public void setAchievementName(String achievementName) {
		this.achievementName = achievementName;
	}

	public String getAchievementShort() {
		return achievementShort;
	}

	public void setAchievementShort(String achievementShort) {
		this.achievementShort = achievementShort;
	}

	public Integer getLevel() {
		return level;
	}

	public void setLevel(Integer level) {
		this.level = level;
	}

	public List<IQUser> getAssociatedUsers() {
		return associatedUsers;
	}

	public void setAssociatedUsers(List<IQUser> associatedUsers) {
		this.associatedUsers = associatedUsers;
	}
	
}
