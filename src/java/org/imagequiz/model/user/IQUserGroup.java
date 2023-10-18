package org.imagequiz.model.user;

import static javax.persistence.GenerationType.IDENTITY;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.Table;

@Entity
@Table(name = "iqusergroup")
public class IQUserGroup {
	@Id
    @Column(name = "groupid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long groupId;
	
	@Column(name = "groupname")
	private String groupName;
	
	@Column(name = "users")
	
    @ManyToMany
    @JoinTable(name = "iqusergrouplink",
            joinColumns = {@JoinColumn(name = "groupid") }, 
            inverseJoinColumns = {@JoinColumn(name = "userid") })
	private List<IQUser> users = new ArrayList();

	public boolean isUserInGroup(IQUser iuser) {
		return this.getUsers().contains(iuser);
	}
	
	public String getGroupName() {
		return groupName;
	}

	public void setGroupName(String groupName) {
		this.groupName = groupName;
	}

	public List<IQUser> getUsers() {
		return users;
	}

	public void setUsers(List<IQUser> users) {
		this.users = users;
	}

	public Long getGroupId() {
		return groupId;
	}

	public void setGroupId(Long groupId) {
		this.groupId = groupId;
	}
}
