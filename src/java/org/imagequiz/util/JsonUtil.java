package org.imagequiz.util;

import java.io.IOException;
import java.lang.reflect.Field;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;

import org.apache.poi.util.StringUtil;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQCaseTag;
import org.imagequiz.model.IQImage;
import org.imagequiz.model.caseutil.IQCaseRevision;
import org.imagequiz.model.question.IQAnswerSearchTermLine;
import org.imagequiz.model.question.IQAnswerSearchTermWrapper;
import org.imagequiz.model.question.IQQuestion;
import org.imagequiz.model.question.IQQuestionChoice;
import org.imagequiz.model.question.IQQuestionText;
import org.imagequiz.model.question.IQQuestionSearchTerm;
import org.imagequiz.model.question.IQSearchTermGroup;
import org.imagequiz.model.user.IQUserAchievement;

import com.google.gson.ExclusionStrategy;
import com.google.gson.FieldAttributes;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import com.google.gson.TypeAdapter;
import com.google.gson.annotations.Expose;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;

public class JsonUtil {

	/*
	public class ImageAdapter implements JsonSerializer<IQImage> {
		  @Override
		  public JsonElement serialize(IQImage image, java.lang.reflect.Type type, JsonSerializationContext jsc) {
		    JsonObject jsonObject = new JsonObject();
		    jsonObject.addProperty("imageId", image.getImageId());
		    jsonObject.addProperty("description", image.getDescription());
		    jsonObject.addProperty("createdDate", image.getCreatedDate().toString());
		    jsonObject.addProperty("createdBy", image.getCreatedBy().toString());
		    return jsonObject;      
		  }
		}
	*/
	public class IQImageAdapter implements JsonSerializer<IQImage> {
	    	public JsonElement serialize(IQImage image, final java.lang.reflect.Type type, final JsonSerializationContext context) {
	    		JsonObject fields = JsonUtil.serializeCurrentElements(image, new JsonObject(), context);
	    		fields.add("createdBy", context.serialize(image.getCreatedBy().toString()));
	    		return fields;
	  		  }
	}
	
	public static Gson getIQImageGson() {
		GsonBuilder gsonBuilder = new GsonBuilder();
		Gson gson = gsonBuilder.excludeFieldsWithoutExposeAnnotation().registerTypeAdapter(IQImage.class, new JsonSerializer<IQImage>() {
        	public JsonElement serialize(IQImage image, final java.lang.reflect.Type type, final JsonSerializationContext context) {
        		JsonObject fields = JsonUtil.serializeCurrentElements(image, new JsonObject(), context);
        		fields.add("createdBy", context.serialize(image.getCreatedBy().toString()));
        		return fields;
	  		  }
        })
        .serializeNulls()
        .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
        .create();
		return gson;
	}
	
	public static Gson getIQCaseGson() {
		GsonBuilder gsonBuilder = new GsonBuilder();
		Gson gson = gsonBuilder.excludeFieldsWithoutExposeAnnotation().registerTypeAdapter(IQCase.class, new JsonSerializer<IQCase>() {
        	public JsonElement serialize(IQCase icase, final java.lang.reflect.Type type, final JsonSerializationContext context) {
        		JsonObject fields = JsonUtil.serializeCurrentElements(icase, new JsonObject(), context);
        		//fields.add("createdBy", context.serialize(icase.getCreatedBy().toString()));
        		return fields;
	  		  }
        })
        .serializeNulls()
        .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
        .create();
		return gson;
	}

	public static Gson getIQExerciseGson() {
		GsonBuilder builder = new GsonBuilder();
//    	builder.registerTypeAdapter(IQQuestion.class, new JsonUtil.IQQuestionDeserializer());
//    	builder.registerTypeAdapter(IQQuestion.class, new JsonUtil.IQQuestionSerializer());
    	// builder.registerTypeAdapter(IQQuestionSearchTerm.class, new JsonUtil.IQQuestionChoiceDeserializer());
        Gson gson = builder.excludeFieldsWithoutExposeAnnotation()
        	       .serializeNulls()
        	       .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
        	       .create();
        
        return gson;
	}
	
	
	public static Gson getIQUserAchievementGson() {
		GsonBuilder gsonBuilder = new GsonBuilder();
		Gson gson = gsonBuilder.excludeFieldsWithoutExposeAnnotation().registerTypeAdapter(IQUserAchievement.class, new JsonSerializer<IQUserAchievement>() {
        	public JsonElement serialize(IQUserAchievement achievement, final java.lang.reflect.Type type, final JsonSerializationContext context) {
        		JsonObject fields = JsonUtil.serializeCurrentElements(achievement, new JsonObject(), context);
        		//fields.add("createdBy", context.serialize(icase.getCreatedBy().toString()));
        		return fields;
	  		  }
        })
        .serializeNulls()
        .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
        .create();
		return gson;
	}
	
	public static Gson getIQCaseRevisionGson() {
		GsonBuilder gsonBuilder = new GsonBuilder();
		Gson gson = gsonBuilder.excludeFieldsWithoutExposeAnnotation().registerTypeAdapter(IQCaseRevision.class, new JsonSerializer<IQCaseRevision>() {
        	public JsonElement serialize(IQCaseRevision obj, final java.lang.reflect.Type type, final JsonSerializationContext context) {
        		JsonObject fields = JsonUtil.serializeCurrentElements(obj, new JsonObject(), context);
        		fields.add("author", context.serialize(obj.getAuthor().toString()));
        		return fields;
	  		  }
        })
        .serializeNulls()
        .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
        .create();
		return gson;
	}
	
    public List<IQCase> prepareCasesForJson(List<IQCase> icases, IQDataSource dataSource, Long exerciseId) {
    	List<Object[]> prefixes = dataSource.getSession().createQuery("SELECT DISTINCT c.caseId, t.prefix FROM IQCaseTag t JOIN t.associatedExercise e JOIN t.associatedCases c"
    			+ " WHERE e.exerciseId = :exerciseId AND c.active = 1", Object[].class)
    			.setParameter("exerciseId", exerciseId)
    			.list();
    	HashMap<Long, String> map = new HashMap();
    	for (Object[] prefix: prefixes) {
    		String find = map.get((Long) prefix[0]);
    		if (find == null) map.put((Long) prefix[0], (String) prefix[1]);
    		if (find != null) map.put((Long) prefix[0], find + " " + prefix[1]);
    	}
    	for (IQCase icase: icases) {
    		icase.setPrefix(map.get(icase.getCaseId()));
    	}
    	List<Object[]> commentCounts = dataSource.getSession().createQuery("SELECT count(com) as count, c.caseId FROM IQCaseComment com JOIN com.associatedCase c JOIN c.parentExercises e"
    			+ " WHERE e.exerciseId = :exerciseId AND c.active = 1 AND com.reviewed = 0 GROUP BY c.caseId", Object[].class)
    			.setParameter("exerciseId", exerciseId)
    			.list();
    	for (Object[] result : commentCounts) {
    		for (IQCase c : icases) {
    			if (((Long)result[1]).equals(c.getCaseId())) c.setActiveComments((Long) result[0]);
    		}
    	}
    	return icases;
    }
	
//	public static Gson getIQCaseTagsGson() {
//		GsonBuilder gsonBuilder = new GsonBuilder();
//		Gson gson = gsonBuilder.excludeFieldsWithoutExposeAnnotation().registerTypeAdapter(IQCaseTag.class, new JsonSerializer<IQCaseTag>() {
//        	public JsonElement serialize(IQCaseTag obj, final java.lang.reflect.Type type, final JsonSerializationContext context) {
//        		JsonObject fields = JsonUtil.serializeCurrentElements(obj, new JsonObject(), context);
//        		//fields.add("caseNumber", context.serialize(obj.getCaseNumber()));
//        		return fields;
//	  		  }
//        })
//        .serializeNulls()
//        .setDateFormat("yyyy-MM-dd'T'HH:mm:ssX") //ISO 8601
//        .create();
//		return gson;
//	}
	
	public class ExcludeProxiedFields implements ExclusionStrategy{

	    @Override
	    public boolean shouldSkipField(FieldAttributes fa) {
	        return fa.getAnnotation(ManyToOne.class) != null ||
	           fa.getAnnotation(OneToOne.class) != null  ||
	           fa.getAnnotation(ManyToMany.class) != null  ||
	           fa.getAnnotation(OneToMany.class) != null ;
	    }

	    @Override
	    public boolean shouldSkipClass(Class<?> type) {
	        return false;
	    }   
	}
	
	public static JsonObject serializeCurrentElements(Object obj, JsonObject jsonObject, JsonSerializationContext context) {
		for (Field f: obj.getClass().getDeclaredFields()) {
			if (f.isAnnotationPresent(Expose.class)) {
				f.setAccessible(true);
				try {
					jsonObject.add(f.getName(), context.serialize(f.get(obj)));
					//System.out.println("field: " + f.getName() + " answer: " + f.get(image).toString());
				} catch (IllegalAccessException e ) {
					e.printStackTrace();
				}
			}
		}
		return jsonObject;
	}
	
	
	public static class IQQuestionDeserializer implements JsonDeserializer<IQQuestion> 
	{  
	    @Override
	    public IQQuestion deserialize(JsonElement json, Type typeOfT, 
	                JsonDeserializationContext context) throws JsonParseException 
	    {
	    	//if (json is of class B) return context.deserialize(json, B.class)
	    	if (json.isJsonObject()) {
	    		JsonObject object = json.getAsJsonObject();
	    		if (object.get("questionType").getAsString().equalsIgnoreCase(IQQuestion.QUESTION_TYPE_CHOICE)) {
	    			return context.deserialize(json, IQQuestionChoice.class);
	    		}
	    		if (object.get("questionType").getAsString().equalsIgnoreCase(IQQuestion.QUESTION_TYPE_SEARCHTERM)) {
	    			return context.deserialize(json, IQQuestionSearchTerm.class);
	    		}
	    		if (object.get("questionType").getAsString().equalsIgnoreCase(IQQuestion.QUESTION_TYPE_SEARCHTERM_SETS)) {
	    			return context.deserialize(json, IQQuestionSearchTerm.class);
	    		}
	    		if (object.get("questionType").getAsString().equalsIgnoreCase(IQQuestion.QUESTION_TYPE_TEXT)) {
	    			return context.deserialize(json, IQQuestionText.class);
	    		}
	    	}
	    	return context.deserialize(json, IQQuestion.class);
	    		
	    }
	}
	public static class IQQuestionSerializer implements JsonSerializer<IQQuestion> {
    	public JsonElement serialize(IQQuestion question, final java.lang.reflect.Type type, final JsonSerializationContext context) {
    		//JsonObject fields = new JsonObject();
//    		System.out.println("Serializing ..." + question.getQuestionType());
    		if (question.getClass().isAssignableFrom(IQQuestionChoice.class)) {
    			IQQuestionChoice questionChoice = (IQQuestionChoice) question;
    			return context.serialize(questionChoice);
    		}
    		if (question.getClass().isAssignableFrom(IQQuestionSearchTerm.class)) {
    			
    			if (question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_SEARCHTERM) || question.getQuestionType().equals(IQQuestion.QUESTION_TYPE_SEARCHTERM_SETS)) {
    				System.out.println("Serializing .. base");
    				IQQuestionSearchTerm questionST = (IQQuestionSearchTerm) question;
    				List<String> groups = new ArrayList();
        			for (IQSearchTermGroup group : questionST.getAvailableGroups()) {
        				groups.add(group.getGroupName());
        			}
        			questionST.setAvailableGroupsText(StringUtil.join(groups.toArray(), ","));
        			return context.serialize(questionST);
    			}
    			
//    			for (IQAnswerSearchTermLine line: questionST.getAssociatedAnswerLines()) {
//    				for (IQAnswerSearchTermWrapper wrapper : line.getAssociatedAnswerWrappers()) {
//    					System.out.println("FOUND STRING: " + wrapper.getSearchTerm().getSearchTermString());
//    				}
//    			}
    			
    		}
    		if (question.getClass().isAssignableFrom(IQQuestionText.class)) {
    			IQQuestionText questionText = (IQQuestionText) question;
    			return context.serialize(questionText);
    		}
    		
    		// fields.add("createdBy", context.serialize(image.getCreatedBy().toString()));
    		return context.serialize(question);
  	}
}
	
}

