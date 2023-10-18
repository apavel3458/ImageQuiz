/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package org.imagequiz.model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;

import static javax.persistence.GenerationType.IDENTITY;

import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.Table;

import org.imagequiz.model.user.IQUser;

import com.google.gson.annotations.Expose;

/**
 *
 * @author bubbles
 */
@Entity
@Table(name = "iqimage")
public class IQImage {
	@Id
    @Column(name = "imageid", unique = true, nullable = false)
    @GeneratedValue(strategy = IDENTITY)
	@Expose
    private Long imageId;
    
	@Expose
    @Column(name = "filename")
    private String filename;
    
	@Expose
    @Column(name = "description")
    private String description;
    
	@Expose
    @Column(name = "createddate")
    private Date createdDate;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "createdby")
    private IQUser createdBy;

    @ManyToMany(cascade = {CascadeType.PERSIST, CascadeType.MERGE}, mappedBy="images")
    private List<IQCase> associatedCases = new ArrayList();
    
    
    public String getRelativeUrl() {
    	return "../image?getfile=" + this.getFilename();
    }
    
    
    /**
     * @return the imageid
     */
    public Long getImageId() {
        return imageId;
    }

    /**
     * @param imageid the imageid to set
     */
    public void setImageId(Long imageId) {
        this.imageId = imageId;
    }

    /**
     * @return the filename
     */
    public String getFilename() {
        return filename;
    }

    /**
     * @param filename the filename to set
     */
    public void setFilename(String filename) {
        this.filename = filename;
    }

    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param description the description to set
     */
    public void setDescription(String description) {
        this.description = description;
    }

	public List<IQCase> getAssociatedCases() {
		return associatedCases;
	}

	public void setAssociatedCases(List<IQCase> associatedCases) {
		this.associatedCases = associatedCases;
	}

	public Date getCreatedDate() {
		return createdDate;
	}

	public void setCreatedDate(Date createdDate) {
		this.createdDate = createdDate;
	}

	public IQUser getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(IQUser createdBy) {
		this.createdBy = createdBy;
	}
}
