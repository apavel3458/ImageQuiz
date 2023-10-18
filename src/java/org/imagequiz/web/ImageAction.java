package org.imagequiz.web;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;
import org.apache.struts.actions.DispatchAction;
import org.apache.struts.upload.FormFile;
import org.imagequiz.dao.IQDataSource;
import org.imagequiz.model.Form;
import org.imagequiz.model.IQCase;
import org.imagequiz.model.IQExercise;
import org.imagequiz.model.IQImage;
import org.imagequiz.model.user.IQUser;
import org.imagequiz.properties.ImageQuizProperties;
import org.imagequiz.util.JsonUtil;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import com.google.gson.annotations.Expose;
import com.google.gson.reflect.TypeToken;

public class ImageAction extends DispatchAction {
	
    protected IQDataSource dataSource;
    
    public void setIQDataSource(IQDataSource value) {
        dataSource = value;
      }
	
    @Override
    public ActionForward unspecified(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
    	
        return list(mapping, form, request, response);
    }
	
	 public ActionForward list(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) {
	        String forward = request.getParameter("forward");
	        String caseId = request.getParameter("caseid");
	        if (caseId == null) {
	        	caseId = (String) request.getAttribute("caseid");
	        }
	        String exerciseId = request.getParameter("exerciseid");
	        List<IQImage> images;
	        
	        //different ways to get images (by caseId, or exerciseId, or all images).
	        if (caseId != null && !caseId.equals("")) {
	        	images = dataSource.getCase(Long.parseLong(caseId)).getImages();
	        } else if (exerciseId != null && !exerciseId.equals("")) {
	        	IQExercise exercise = dataSource.getExercise(Long.parseLong(exerciseId));
	        	images = new ArrayList();
	        	for (IQCase casei: exercise.getCases()) {
	        		images.addAll(casei.getImages());
	        	}
	        } else {
	        	images = dataSource.getImageList();
	        }
	        
	        request.setAttribute("images", images);
	        request.setAttribute("caseid", caseId);
	        request.setAttribute("exerciseid", exerciseId);
	        if (forward == null || forward.equals(""))
	        	forward = "/admin/images.jsp";
	        return new ActionForward(forward);
	    }
	 
	 public ActionForward listJson(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException{
	        String caseId = request.getParameter("caseid");
	        List<IQImage> images;
	        
	        //different ways to get images (by caseId, or exerciseId, or all images).
	        IQCase icase = dataSource.getCase(Long.parseLong(caseId));
	        
	        String json = listJSON(icase);
	        
	        response.getWriter().print(json);
	        response.getWriter().flush();
	        return null;
	 }
	 
	 public ActionForward listTinyMce(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws IOException{
	        String caseId = request.getParameter("caseid");
	        List<IQImage> images;
	        
	        //different ways to get images (by caseId, or exerciseId, or all images).
	        IQCase icase = dataSource.getCase(Long.parseLong(caseId));
	        images = icase.getImages();
	        
	        JsonArray replyJson = new JsonArray();
	        for (IQImage image: images) {
	        	JsonObject jo = new JsonObject();
	        	jo.addProperty("title", image.getDescription());
	        	jo.addProperty("value", image.getRelativeUrl());
	        	replyJson.add(jo);
	        }
	        
	        Gson gson = new Gson();
	        response.getWriter().print(gson.toJson(replyJson));
	        response.getWriter().flush();
	        return null;
	 }
	 
	 public String listJSON(IQCase icase) {
		 return listJSON(icase.getImages());
	 }
	 
	 public String listJSON(List<IQImage> images) {
	        
	        String json;
            
            GsonBuilder gsonBuilder = new GsonBuilder();
            /*Gson gson = gsonBuilder.excludeFieldsWithoutExposeAnnotation().create();//.registerTypeAdapter(IQImage.class, new JsonUtil().new ImageAdapter()).create();
            json = gson.toJson(images, new TypeToken<List<IQImage>>() {}.getType());*/
	        return JsonUtil.getIQImageGson().toJson(images);
	 }
	    
	    public ActionForward getImage(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	        String imageIdStr = request.getParameter("imageid");
	        IQImage image = dataSource.getImage(Long.parseLong(imageIdStr));
	        String imageFilename = getImageServerPath(image.getFilename(), request);
	        
	        File file = new File(imageFilename);
	        if (file.exists()) {
	        	try {
		            int bytes = 0;
		            ServletOutputStream op = response.getOutputStream();
	
		            response.setContentType(getMimeType(file));
		            response.setContentLength((int) file.length());
		            response.setHeader( "Content-Disposition", "inline; filename=\"" + file.getName() + "\"" );
	
		            byte[] bbuf = new byte[1024];
		            DataInputStream in = new DataInputStream(new FileInputStream(file));
	
		            while ((in != null) && ((bytes = in.read(bbuf)) != -1)) {
		                op.write(bbuf, 0, bytes);
		            }
		            
		            in.close();
		            op.flush();
		            op.close();
	        	} catch (Exception ioe) {
	        		response.getWriter().println("Encountered an error: " + ioe.getMessage());
	        		ioe.printStackTrace();
	        		response.getWriter().flush();
		        	response.getWriter().close();
	        	}
	        } else {
	        	response.getWriter().println("Encountered an error: Unable to find image");
	        	response.getWriter().flush();
	        	response.getWriter().close();
	        }
	        return null;
	    }
	    
	    public ActionForward upload(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	          // Directory where files will be saved
	    	
	        String imageDir = getFileDirectoryPath(request);
	        File dir = new File(imageDir);

	        
	        String description = request.getParameter("description");
	        String mode = request.getParameter("mode"); //mode = froala
	        IQUser iuser = (IQUser) request.getSession().getAttribute("security");
	        iuser = dataSource.getUserById(iuser.getUserId());
	        
	        Form fm = (Form) form;
	        FormFile uploadFile = fm.getUploadFile();
	        String caseId = request.getParameter("caseid");
	        if (description == null || description.equals("")) {
	        	//description = "File" + new SimpleDateFormat("yyyy-MM-dd-hh.mm.ss").format(new Date());
	        	description = uploadFile.getFileName();
	        }
	        if (uploadFile.getFileSize() == 0) {
	            request.setAttribute("errorMessage", "File is empty.");
	            System.out.println("FILE IS EMPTY------");
	            return list(mapping, form, request, response);
	        }
	        System.out.println("FILE IS not EMPTY------");
	        
	        //make filename
	        java.util.Random random = new java.util.Random();
	        String randomNumber = random.nextInt(9999) + "";
	        SimpleDateFormat nowTimeFormat = new SimpleDateFormat("yyyyMMdd_HHmmss-SSS");
	        String timestamp = nowTimeFormat.format(new Date());
	        String oldFilename = uploadFile.getFileName();
	        String extension = "";
	        if (oldFilename.contains(".")) {
	        	extension = oldFilename.split("\\.(?=[^\\.]+$)")[1];
	        }
	        String filename = "file_" + timestamp + "." + extension;
	        FileOutputStream fos = new FileOutputStream(dir + "/" + filename);
	        InputStream is = uploadFile.getInputStream();
	        byte[] buffer = new byte[1024];
	        int bytesRead = 0;
	        while ((bytesRead = is.read(buffer)) != -1) {
	            fos.write(buffer, 0, bytesRead);
	        }
	        
	        IQImage newImage = new IQImage();
	        newImage.setFilename(filename);
	        newImage.setDescription(description);
	        newImage.setCreatedBy(iuser);
	        newImage.setCreatedDate(new Date());
	      
	        if (caseId != null && !caseId.equals("")) {
	        	IQCase iqCase = (IQCase) dataSource.getCase(Long.parseLong(caseId));
	        	iqCase.getImages().add(newImage);
	        	dataSource.saveCase(iqCase);
	        } else {
	        	dataSource.addImage(newImage);
	        }
	        
	        //decide what to do at the end of image processing
	        if (mode != null && mode.equals("froala")) {
		        //Print JSON
		        //String imageUrl = "images.do?method=getImage&imageid=" + newImage.getImageId(); // this only works in admin interface
	        	String imageUrl = "../image?getfile=" + newImage.getFilename();
		        String output = "{ \"link\": \"" + imageUrl + "\" }";
		        response.getWriter().println(output);
		        response.getWriter().flush();
		        return null;
	        } else if (mode!= null && mode.equals("tinymce")) {
	        	//format: { "location": "folder/sub-folder/new-location.png" }
	        	String imageUrl = "../image?getfile=" + newImage.getFilename();
	        	String output = "{ \"location\": \"" + imageUrl + "\" }";
		        response.getWriter().println(output);
		        response.getWriter().flush();
		        return null;
	        } else if (mode != null && mode.equals("ajax")) {
	        	response.getWriter().print(JsonUtil.getIQImageGson().toJson(newImage));
	        	response.getWriter().flush();
	        	return null;
	        } else {
	        	return list(mapping, form, request, response);
	        }
	    }
	    
	    public ActionForward deleteImage(ActionMapping mapping, ActionForm form, HttpServletRequest request, HttpServletResponse response) throws Exception {
	        String imageid = request.getParameter("imageid");
	        Long imageId = Long.parseLong(imageid);
	        String caseid = request.getParameter("caseid");
	        if (imageid != null && !imageid.equals("")) {
	            if (caseid != null && !caseid.equals("")) {
	            	Long caseId = Long.parseLong(caseid);
	            	String filename = dataSource.getImage(imageId).getFilename();
	            	boolean imageDeleted = dataSource.deleteImageFromCase(imageId, caseId);
	            	if (imageDeleted) {
	            		//if orphaned, and deleted, then remove from filesystem
	            		this.deleteFile(filename, request);
	            	}
	            	request.setAttribute("caseid", caseid);
	            } else {
	            	//delete image and all associations
	            	dataSource.deleteImageFromAllCases(Long.parseLong(imageid));
	            }
	        }
	        return list(mapping, form, request, response);
	    }
	    
	    private void deleteFile(String fileName, HttpServletRequest request) {
	    	String imageDir = getFileDirectoryPath(request);
	    	File imageFile = new File(imageDir + "/" + fileName);
	    	if (imageFile.exists())
            	imageFile.delete();
	    }
	    
	    private String getImageServerPath(String imageFilename, HttpServletRequest request) {
	    	return getFileDirectoryPath(request) + "/" + imageFilename;
	    }
	    
	    private String getFileDirectoryPath(HttpServletRequest request) {
	        String imageDir = ImageQuizProperties.getInstance().getProperty(ImageQuizProperties.IMAGE_DIRECTORY);
	        if (imageDir.contains("{ServerPathToWebDir}")) {
	            String contextPath = request.getSession().getServletContext().getRealPath(File.separator);
	            imageDir= imageDir.replaceAll("\\{ServerPathToWebDir\\}", contextPath);
	        }
	        System.out.println("FileUploadPath : " + imageDir);
	        return imageDir;
	    }
	    
	    private String getMimeType(File file) {
	        String mimetype = "";
	        if (file.exists()) {
	            if (getSuffix(file.getName()).equalsIgnoreCase("png")) {
	                mimetype = "image/png";
	            }else if(getSuffix(file.getName()).equalsIgnoreCase("jpg")){
	                mimetype = "image/jpg";
	            }else if(getSuffix(file.getName()).equalsIgnoreCase("jpeg")){
	                mimetype = "image/jpeg";
	            }else if(getSuffix(file.getName()).equalsIgnoreCase("gif")){
	                mimetype = "image/gif";
	            }else {
	                javax.activation.MimetypesFileTypeMap mtMap = new javax.activation.MimetypesFileTypeMap();
	                mimetype  = mtMap.getContentType(file);
	            }
	        }
	        return mimetype;
	    }
	    private String getSuffix(String filename) {
	        String suffix = "";
	        int pos = filename.lastIndexOf('.');
	        if (pos > 0 && pos < filename.length() - 1) {
	            suffix = filename.substring(pos + 1);
	        }
	        return suffix;
	    }
}
