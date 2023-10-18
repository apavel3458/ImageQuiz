/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.util;

/**
 *
 * @author apavel
 */
public class CaseParseException extends Exception {
   // public String text = "";
	
	public CaseParseException() {}
    
	public CaseParseException(String text) {
		super(text);
	}
	
    public CaseParseException(String text, Exception e) {
    	super(text, e);
    }
    
}
