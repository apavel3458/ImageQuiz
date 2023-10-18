/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.model;

/**
 *
 * @author apavel
 */
import javax.servlet.http.HttpServletRequest;
import org.apache.struts.action.*;
import org.apache.struts.upload.FormFile;
 
public class Form extends ActionForm
{
    private FormFile uploadFile;

    public void setUploadFile(FormFile uploadFile) {
        System.out.println("test!!! form bean called!");
        this.uploadFile = uploadFile;
    }

    public FormFile getUploadFile() {
        return uploadFile;
    }

    public ActionErrors validate(ActionMapping mapping, HttpServletRequest request)
    {
        ActionErrors errors = new ActionErrors();
        return errors;
    }
}