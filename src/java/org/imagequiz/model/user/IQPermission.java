package org.imagequiz.model.user;

import static javax.persistence.GenerationType.IDENTITY;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

import org.hibernate.Session;

import com.google.gson.annotations.Expose;

//| permissionid | int(11) unsigned | NO   | PRI | NULL              | auto_increment |
//| userid       | int(11)          | NO   | MUL | NULL              |                |
//| item         | varchar(60)      | YES  |     | NULL              |                |
//| itemid       | int(11)          | NO   |     | NULL              |                |
//| details      | json             | YES  |     | NULL              |                |
//| createdAt    | timestamp        | NO   |     | CURRENT_TIMESTAMP |                |
//| createdById  | int(11)          | NO   |     | NULL              |                |

@Entity
@Table(name = "iquser_permission")
public class IQPermission {
	@Expose
	@Id
    @Column(name = "permissionid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long permissionId;
	
	@Expose
	@ManyToOne
	@JoinColumn(name = "userid")
	private IQUser user;
	
	@Expose
	@Column(name = "item")
	private String item;
	
	@Expose
	@Column(name = "itemid")
	private Long itemId;
	
	@Expose
	@Column(name = "createdAt")
	private Date createdAt;
	
	@ManyToOne
	@JoinColumn(name = "createdById")
	private IQUser createdBy;

	public Long getPermissionId() {
		return permissionId;
	}

	public void setPermissionId(Long permissionId) {
		this.permissionId = permissionId;
	}

	public IQUser getUser() {
		return user;
	}

	public void setUser(IQUser user) {
		this.user = user;
	}

	public String getItem() {
		return item;
	}

	public void setItem(String item) {
		this.item = item;
	}

	public Long getItemId() {
		return itemId;
	}

	public void setItemId(Long itemId) {
		this.itemId = itemId;
	}

	public Date getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}

	public IQUser getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(IQUser createdBy) {
		this.createdBy = createdBy;
	}

}
