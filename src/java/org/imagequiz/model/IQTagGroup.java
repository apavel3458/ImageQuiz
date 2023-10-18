/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.model;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;

import static javax.persistence.GenerationType.IDENTITY;

import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Transient;

/**
 *
 * @author apavel
 */
@Entity
@Table(name = "iqtaggroup")
public class IQTagGroup {
    @Id
    @Column(name = "taggroupid")
    @GeneratedValue(strategy = IDENTITY)
    private Long tagGroupId = null;
    
    @Column(name="taggroupname")
    private String listName;
    
    @Column(name = "tagxml")
    private String tagXml = null;
    
    
    public IQTagGroup() {
        
    }
    
    public IQTagGroup(String listName) {
        this.listName = listName;
    }

    /**
     * @return the listName
     */

    public String getListName() {
        return listName;
    }

    /**
     * @param listName the listName to set
     */
    public void setListName(String listName) {
        this.listName = listName;
    }

    /**
     * @return the tagGroupId
     */
    public Long getTagGroupId() {
        return tagGroupId;
    }

    /**
     * @param tagGroupId the tagGroupId to set
     */
    public void setTagGroupId(Long tagGroupId) {
        this.tagGroupId = tagGroupId;
    }



    /**
     * @return the tagXml
     */

    public String getTagXml() {
        return tagXml;
    }

    /**
     * @param tagXml the tagXml to set
     */
    public void setTagXml(String tagXml) {
        this.tagXml = tagXml;
    }
}
