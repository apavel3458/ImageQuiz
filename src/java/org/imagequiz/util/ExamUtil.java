package org.imagequiz.util;

import java.util.Random;

public final class ExamUtil {
	
	public ExamUtil() {}

	private static final String userEncodingAlphabet = "eCzD2wmB48F";
	private static final int examCodeLength = 4;
	private static final String emptyUserSpacer = "a5";
	private static final String examRandomCodeAlphabet = "abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ123456789";//removed letters that look similar
	private static final int offset = 1; //insert user information after first character
	public static String generateExamCode() throws Exception {
	    	Random r = new Random();
	    	String result = "";
	    	int length = examCodeLength;
	        String alphabet = examRandomCodeAlphabet;
	        for (int i = 0; i < length; i++) {
	            result = result + alphabet.charAt(r.nextInt(alphabet.length()));
	        }
	        //insert spacer
	        result = result.substring(0, offset) + emptyUserSpacer + result.substring(offset);
	        return result;
	    }
	
    public static String generateUserAccessKey(Long userId, String examUniqueCode) throws Exception {
    	String result = examUniqueCode.substring(0, offset) + encodeUserId(userId) + examUniqueCode.substring(examUniqueCode.length() - examCodeLength + offset);
    	return result;
    }
    public static Long getUserIdFromAccessKey(String accessKey) throws Exception {
    	System.out.println("Received access key: " + accessKey);
    	String userIdEncoded = accessKey.substring(offset, accessKey.length() - examCodeLength + offset);
    	System.out.println("Exam code pulled out: " + userIdEncoded);
    	if (userIdEncoded.equals(emptyUserSpacer)) return null;
    	Long userId = decodeUserId(userIdEncoded);
    	return userId;
    }
    public static String getExamCodeFromAccessKey(String accessKey) {
    	System.out.println("Received access key: " + accessKey);
    	String examCode = accessKey.substring(0, offset) + emptyUserSpacer + accessKey.substring(accessKey.length() - examCodeLength + offset);
    	System.out.println("Exam code pulled out: " + examCode);
    	return examCode;
    }
    
    
    private static String encodeUserId(Long number)  throws Exception {
    	char[] alphabet = userEncodingAlphabet.toCharArray();
    	char[] str = number.toString().toCharArray();
    	String encoded = "";
    	for (int i=0; i< str.length; i++) {
    		encoded = encoded + alphabet[Character.getNumericValue(str[i])];
    	}
    	return encoded;
    }
    private static Long decodeUserId(String code) throws Exception{
    	String alphabet = userEncodingAlphabet;
    	char[] str = code.toCharArray();
    	String result = "";
    	for (int i=0; i< str.length; i++) {
    		result = result + alphabet.indexOf(str[i]);
    	}
    	try {
    		return Long.parseLong(result); 
    	} catch (NumberFormatException nfe) {
    		throw new Exception("malformed code!");
    	}
    }
    
    public static void checkUserIdEncoder() throws Exception {
    	if (!isUniqueChars(userEncodingAlphabet)) throw new Exception("Characters in user alphabet string are not unique!!!");
    }
    
    private static boolean isUniqueChars(String str) {
        if (str.length() > 256) { // NOTE: Are you sure this isn't 26?
            return false;
        }
        int checker = 0;
        for (int i = 0; i < str.length(); i++) {
            int val = str.charAt(i) - 'a';
            if ((checker & (1 << val)) > 0) return false;
            checker |= (1 << val);
        }
        return true;
    }
}
