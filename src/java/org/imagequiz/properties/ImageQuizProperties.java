/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.imagequiz.properties;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 *
 * @author apavel
 */
public class ImageQuizProperties extends Properties {
    protected static Log _log = LogFactory.getLog(ImageQuizProperties.class);
    public static final String IMAGE_DIRECTORY = "imagequiz.imageDir";
    
    public static final String EMAIL_SMTP_HOST = "imagequiz.email.smtp.host";
    public static final String EMAIL_SMTP_PORT = "imagequiz.email.smtp.port";
    public static final String EMAIL_SMTP_SENDER = "imagequiz.email.sender";
    public static final String EMAIL_SMTP_SENDER_NAME = "imagequiz.email.sender.name";

    
    //Servlet Context Listener org.myoscar.Startup will call reloadProperties() to create the instance
    private static ImageQuizProperties _instance;
    private static String fileName = "imagequiz.properties";
    
    private ImageQuizProperties() throws IOException {
        _log.info("ImageQuiz Properties Constructor Call");
        //check user home dir for imagequiz.properties
        File propsFile = new File(System.getProperty("user.home") + "/" + fileName);
        try {
            if (propsFile.exists()) {
                FileInputStream fis = new FileInputStream(propsFile);
                this.load(fis);
            } else { //if not exist, use default in classpath
                ClassLoader classLoader = ImageQuizProperties.class.getClassLoader();
                InputStream fs = classLoader.getResourceAsStream("/org/imagequiz/properties/imagequiz.properties");
                this.load(fs);
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
            _instance = null;
        }
    }
    
    //calls the constructor and handles exceptions
    private static ImageQuizProperties createImageQuizProperties() {
        try {
            return new ImageQuizProperties();
        } catch (IOException ioe) {
            _log.error("Failed to read the myoscar properties file.  Optional one can be created here: '" + System.getProperty("user.home") + "/" + fileName + "'", ioe);
        }
        return null;
    }
    
    //Servlet Context Listener org.myoscar.Startup will call this to create the instance
    public static void reloadPropertiesFile() throws IOException {
        _instance = new ImageQuizProperties();
    }
    
    public static ImageQuizProperties getInstance() {
        if (_instance == null)
            _instance = createImageQuizProperties();
        return _instance;
    }
    
    //if value is false, assuming false
    //if value does not appear to be boolean, assuming we are checking if the value exists, so returning true if exists;
    public boolean getBooleanProperty(String key) {
        String value = this.getProperty(key);
        if (value == null) return false;
        if (value.equals("on") || value.equals("yes") || value.equals("true")) return true;
        if (value.equals("off") || value.equals("no") || value.equals("false")) return false;
        return true; 
    }
    
    //for comma-separated keys
    public boolean csvContainsValue(String key, String compareValue) {
        String value = this.getProperty(key);
        List<String> csvs = Arrays.asList(StringUtils.split(value, ','));
        return csvs.contains(compareValue);
    }
    
    public static String getFileName() {
        return fileName;
    }

    public static void setFileName(String aFileName) {
        fileName = aFileName;
    }
    
    //some common properties that makes it easy to retrieve
    public String getSitenameShort() {
    	return this.getProperty("imagequiz.sitenameShort", "DEFAULT NAME");
    }
    public String getSitenameLong() {
    	return this.getProperty("imagequiz.sitenameLong", "DEFAULT NAME");
    	
    }
    public String getSitePostfix() {
    	return this.getProperty("imagequiz.siteAbbr", "ecg");
    }
}
