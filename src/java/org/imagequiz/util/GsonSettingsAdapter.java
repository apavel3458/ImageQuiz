package org.imagequiz.util;

import java.io.IOException;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonToken;
import com.google.gson.stream.JsonWriter;

public class GsonSettingsAdapter extends TypeAdapter<String> {
	    private Gson getGson() {
	        Gson gson = new GsonBuilder().excludeFieldsWithoutExposeAnnotation()
	        	       .serializeNulls()
	        	       .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
	        	       .create();
	        return gson;
	    }
	   @Override 
	   public String read(JsonReader in) throws IOException { 
		   return JsonParser.parseReader(in).toString();
	   } 
	   
	   @Override 
	   public void write(JsonWriter writer, String result) throws IOException { 
//		   Object obj = getGson().fromJson(result, String.class);
		   final JsonElement jsonElement = getGson().fromJson(result, JsonElement.class);
           getGson().toJson(jsonElement, writer);
	   } 
	   
	   
}