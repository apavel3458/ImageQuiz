package org.imagequiz.util;

import java.io.UnsupportedEncodingException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Calendar;
import java.util.concurrent.TimeUnit;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class AuthUtil {
	public static String hmacDigest(String msg, String keyString, String algo) {
		String digest = null;
		try {
			SecretKeySpec key = new SecretKeySpec((keyString).getBytes("UTF-8"), algo);
			Mac mac = Mac.getInstance(algo);
			mac.init(key);
			
			byte[] bytes = mac.doFinal(msg.getBytes("ASCII"));
			
			StringBuffer hash = new StringBuffer();
			for (int i=0; i<bytes.length; i++) {
				String hex = Integer.toHexString(0xFF & bytes[i]);
				if (hex.length() == 1) {
					hash.append('0');
				}
				hash.append(hex);
			}
			digest = hash.toString();
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		} catch (InvalidKeyException e) {
			e.printStackTrace();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}
		return digest;
	}
	
	public static boolean timeCheck(Long timeInMillis, int seconds) {
		long MAX_DURATION = TimeUnit.MILLISECONDS.convert(seconds, TimeUnit.SECONDS);
		
    	Calendar calendar = Calendar.getInstance();
    	calendar.setTimeInMillis(timeInMillis);

		long duration = Calendar.getInstance().getTime().getTime() - calendar.getTime().getTime();

		if (duration >= MAX_DURATION) {
		    return false;
		} else {
			return true;
		}
	}
}
