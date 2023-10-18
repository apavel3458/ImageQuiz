package org.imagequiz.model.user;

import static javax.persistence.GenerationType.IDENTITY;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.CollectionTable;
import javax.persistence.Column;
import javax.persistence.ElementCollection;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.MapKey;
import javax.persistence.MapKeyColumn;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.LazyCollection;
import org.hibernate.annotations.LazyCollectionOption;
import org.hibernate.query.Query;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.caseutil.IQCaseRevision;
import org.imagequiz.model.user.IQCaseCompleted;
import org.imagequiz.model.user.IQUserQuiz;

import com.google.gson.annotations.Expose;

@Entity
@Table(name = "iquser")
public class IQUser {
	@Expose
	@Id
    @Column(name = "userid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long userId;
	
	@Expose
	@Column(name = "username")
	private String username;
	
	@Expose
	@Column(name = "email")
	private String email;
	
	@Column(name = "password")
	private String passwordHash;
	
	@Expose
	@Column(name = "firstname")
	private String firstName;
	
	@Expose
	@Column(name = "lastname")
	private String lastName;
	
	@Column(name = "admin")
	private boolean admin = false;
	
	@Column(name = "totalminutes")
	private Long totalMinutes = Long.valueOf(0);
	
	@Column(name = "loginCount")
	private Long loginCount = Long.valueOf(0);
	
	@Column(name = "lastlogin")
	private Date lastLogin = new Date();
	
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "user")
	@Cascade({CascadeType.ALL})
	private List<IQUserQuiz> userQuizes;
	
	@ManyToMany(mappedBy = "users")
	@Cascade({CascadeType.PERSIST, CascadeType.DETACH})
	private List<IQUserGroup> userGroups = new ArrayList();
	
	@OneToMany(mappedBy = "author", fetch = FetchType.LAZY)
	@Cascade({CascadeType.ALL})
	private List<IQCaseRevision> caseContributions = new ArrayList();
	
	@ManyToMany(mappedBy = "associatedUsers", fetch = FetchType.EAGER)
	private List<IQUserAchievement> achievements = new ArrayList();
	/*
    @OneToMany(mappedBy = "parent")
    @MapKey(name = "uservars")
    private Map<String, String> userVars;
    */
    
    @ElementCollection
    @CollectionTable(name="iquservar" , joinColumns=@JoinColumn(name="userid"))
    @MapKeyColumn(name="name")
    @Column(name="value")
	private Map<String, String> userVars = new HashMap();
    
    @OneToMany(mappedBy="user", cascade = javax.persistence.CascadeType.ALL, orphanRemoval = true)
    private List<IQPermission> permissions = new ArrayList();
    
	@Transient
	private String sessionid;
	
	@Transient 
	private String sessionMode = "";
	
	@Transient
	public static String SESSION_MODE_RESEARCH = "research";
	
	@Transient
	private boolean examOnly = false; //used for partial exam access
	
	@Override
	public String toString() {
		return this.firstName + " " + this.lastName;
	}
	
	public static Comparator<IQUser> byLastName = new Comparator<IQUser>() {
			public int compare(IQUser u1, IQUser u2) {
				if (u1.getLastName() == null) return -1;
				if (u2.getLastName() == null) return 1;
				return u1.getLastName().compareTo(u2.getLastName());
			}
	};
	
	public boolean isManagerExams() {
		for (IQUserGroup group : this.getUserGroups()) {
			if (group.getGroupName().equals("_Admin All")) return true;
		}
		return false;
	}
	public boolean isManagerUsers() {
		for (IQUserGroup group : this.getUserGroups()) {
			if (group.getGroupName().equals("_Admin All")) return true;
		}
		return false;
	}
	public boolean isManagerSite() {
		for (IQUserGroup group : this.getUserGroups()) {
			if (group.getGroupName().equals("_Admin All")) return true;
		}
		return false;
	}
	public boolean isManagerCases() {
		for (IQUserGroup group : this.getUserGroups()) {
			if (group.getGroupName().equals("_Admin Cases") 
					|| group.getGroupName().equals("_Admin All")) return true;
		}
		return false;
	}
	public boolean isPermitted(String item, Long itemId) {
		for (IQPermission permission : this.getPermissions()) {
			if (permission.getItem().equals(item) && permission.getItemId().equals(itemId)) return true;
		}
		return false;
	}
	
	public boolean equals(IQUser user) {
		return (user.getUserId() == this.getUserId());
	}
	
	
	
	public IQUser() {
		
	}

	public Long getUserId() {
		return userId;
	}

	public void setUserId(Long userId) {
		this.userId = userId;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getSessionid() {
		return sessionid;
	}

	public void setSessionid(String sessionid) {
		this.sessionid = sessionid;
	}

	public String getPasswordHash() {
		return passwordHash;
	}

	public void setPasswordHash(String passwordHash) {
		this.passwordHash = passwordHash;
	}

	public boolean isAdmin() {
		return admin;
	}

	public void setAdmin(boolean admin) {
		this.admin = admin;
	}

	public Long getTotalMinutes() {
		return totalMinutes;
	}

	public void setTotalMinutes(Long totalMinutes) {
		this.totalMinutes = totalMinutes;
	}

	public Date getLastLogin() {
		return lastLogin;
	}

	public void setLastLogin(Date lastLogin) {
		this.lastLogin = lastLogin;
	}

	public List<IQUserQuiz> getUserQuizes() {
		return userQuizes;
	}

	public void setUserQuizes(List<IQUserQuiz> userQuizes) {
		this.userQuizes = userQuizes;
	}
	
	public IQUserQuiz getUserQuizLatestByName(String quizName, IQDataSource dataSource) {
    	Query<IQUserQuiz> query = dataSource.getSession().createQuery("SELECT c FROM IQUserQuiz c WHERE c.quizName=:quizName ORDER BY c.dateStarted", IQUserQuiz.class).setParameter("quizName", quizName);
		List<IQUserQuiz> quizzes = query.getResultList();
		if (quizzes.size() == 0) {
			return null;
		} else {
			return quizzes.get(0);
		}
	}
	
	public List<IQCaseCompleted> getCompletedCases() {
		List<IQCaseCompleted> completed = new ArrayList<IQCaseCompleted>();
		for (IQUserQuiz quiz: this.getUserQuizes()) {
			completed.addAll(quiz.getCompletedCases());
		}
		return completed;
	}

	public List<IQUserGroup> getUserGroups() {
		return userGroups;
	}

	public void setUserGroups(List<IQUserGroup> userGroups) {
		this.userGroups = userGroups;
	}

	public String getLastName() {
		return lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public boolean isExamOnly() {
		return examOnly;
	}

	public void setExamOnly(boolean examOnly) {
		this.examOnly = examOnly;
	}



	public String getSessionMode() {
		return sessionMode;
	}



	public void setSessionMode(String sessionMode) {
		this.sessionMode = sessionMode;
	}






	public Map<String, String> getUserVars() {
		return userVars;
	}



	public void setUserVars(Map<String, String> userVars) {
		this.userVars = userVars;
	}



	public List<IQCaseRevision> getCaseContributions() {
		return caseContributions;
	}



	public void setCaseContributions(List<IQCaseRevision> caseContributions) {
		this.caseContributions = caseContributions;
	}



	public List<IQUserAchievement> getAchievements() {
		return achievements;
	}



	public void setAchievements(List<IQUserAchievement> achievements) {
		this.achievements = achievements;
	}



	public Long getLoginCount() {
		return loginCount;
	}



	public void setLoginCount(Long loginCount) {
		this.loginCount = loginCount;
	}
	public List<IQPermission> getPermissions() {
		return permissions;
	}
	public void setPermissions(List<IQPermission> permissions) {
		this.permissions = permissions;
	}

/*

	public Map<String, String> getUserVars() {
		return userVars;
	}



	public void setUserVars(Map<String, String> userVars) {
		this.userVars = userVars;
	}

	*/
}
