package org.imagequiz.model;

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
import org.imagequiz.model.user.IQUser;

/*
 * 
 * CREATE TABLE `iqcasecomments` (
  `commentid` int(11) NOT NULL AUTO_INCREMENT,
  `caseid` int(11) NOT NULL,
  `text` text default '',
  `private` boolean default false,
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
 */

@Entity
@Table(name = "iqsetting")
public class IQSetting {
	@Id
    @Column(name = "settingid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	private Long settingId;
	
	@Column(name = "name")
	private String name;
	
	@Column(name = "value")
	private String value;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public Long getSettingId() {
		return settingId;
	}

	public void setSettingId(Long settingId) {
		this.settingId = settingId;
	}
	
	public String getProperty(Session session, String settingName) {
		IQSetting setting = (IQSetting) session.createQuery("FROM IQSetting WHERE name=:name").setParameter("name", settingName).list().get(0);
		return setting.getValue();
	}
	
}
