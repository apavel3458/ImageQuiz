<%@ page language="java" contentType="text/html; charset=US-ASCII"
    pageEncoding="US-ASCII"%>
    
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
<!DOCTYPE html>
<html>
<head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Edit Tags</title>
        <link rel="stylesheet" href="admin.css?v=1">
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/bootstrap.min.js"></script>
        <script src="js/vue.js"></script>
        
        <link href="../css/fonts/font-awesome-512/css/all.min.css" rel="stylesheet">
        <link href="../css/fonts/fonts.css" rel="stylesheet">
	

		<link rel="stylesheet" href="../css/lib/bootstrap.paper.min.css">
		<link rel="stylesheet" href="css/tagList.css">
		

</head>
<body>
<div id="app" class="container-fluid">
<table class="table table-striped table-hover table-condensed tagTable">
	<tr>
		<th>ID</th>
		<th><span class="prefix">(Prefix) - </span>Category Name</th>
		<th>#Cases</th>
		<th>Performance</th>
		<th></th>
		<th>Action</th>
	</tr>
       <tr v-for="tag in tags" >
       		<td style="color: gray;">{{tag.tagId}}</td>
       		<td><span class="prefix" v-if="tag.prefix && tag.prefix != ''">{{tag.prefix}} - </span>{{tag.tagName}}</td>
       		<td class="text-center">{{tag.preparedCaseCount}}</td>
       		<td style="width: 100%;">
       			<div class="progress tagPerformance">
				  <div class="progress-bar" :style="{width: tag.preparedGrade + '%'}"></div>
				</div>
			</td>
			<td class="text-center">{{tag.preparedGrade==null?'N/A':tag.preparedGrade}} %</td>
       		<td>
       			<a href="#" class="btn btn-default btn-xs btnFlat" @click="edit(tag)">Edit</a>
       			<a href="#" class="btn btn-default btn-xs btnFlat" @click="deleteTag(tag)">Delete</a>
       		</td>
       </tr>
</table>
<a href="#" class="btn btn-default btn-xs" @click="newTag()">Add New Category</a>

<div class="text-center" style="margin-top: 10px;">
<div class="alert alert-dismissible alert-warning text-center" style="width: 50%; margin: 10px auto 10px auto;" v-if="message">
  <button type="button" class="close" data-dismiss="alert">&times;</button>
  <strong>{{message}}</strong>
</div>
</div>


<div class="text-center">
	<a href="#" class="btn btn-info" onclick="refreshAndClose()">Close</a>
</div>



<div class="modal fade" id="editTagModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h4 class="modal-title">Editing {{editingTag.tagName}}</h4>
      </div>
      <div class="modal-body">
      
      
      	<div class="form-group">
		  <label class="control-label" for="disabledInput">Category Name</label>
		  <input class="form-control greyBackground" type="text" placeholder="Category Title" v-model.trim="editingTag.tagName">
		</div>
      	<div class="form-group">
		  <label class="control-label" for="disabledInput">Prefix (a few letters that helps organize cases)</label>
		  <input class="form-control greyBackground" type="text" placeholder="Category Prefix" v-model.trim="editingTag.prefix">
		</div>
		<div class="col-lg-10">
		    	<label class="control-label" for="disabledInput">Enable Study Resources:</label>
	        	<input type="checkbox" v-model="editingTag.resources.enabled">
      	</div>
      	<div class="form-group">
		  
		    <div v-if="editingTag.resources.enabled">
		    	<label class="control-label" for="disabledInput">Study Resources</label>
			    <div class="col-lg-10">
		        	<textarea class="form-control greyBackground" rows="3" v-model.trim="editingTag.resources.text" placeholder="Text appearing above links..." id="textArea"></textarea>
		        	<span class="help-block">Text appears at the top of the links</span>
	      		</div>
	      		<label class="control-label" for="disabledInput">Links to Study Resources (URLs)</label>
	      		<div v-for="(url, index) in editingTag.resources.urls">
	      		<div class="col-xs-5">
		        	<input class="form-control greyBackground urlName" v-model.trim="url.urlName" placeholder="Name">
		       	</div>
		       	<div class="col-xs-5">
		        	 <input class="form-control greyBackground urlUrl" v-model.trim="url.urlUrl" placeholder="URL">
	      		</div>
	      		<div class="col-xs-2">
		        	 <a class="btn btn-default btn-xs btnFlat" @click="deleteUrl(index)">X</a>
	      		</div>
	      		</div>
	      		<div class="col-xs-12">
	      			<a class="btn btn-default btn-xs btnFlat" @click.stop="addUrl()">Add URL</a>
	      		</div>
      		</div>
		</div>
      </div>
      
      
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
        <button type="button" class="btn btn-primary" @click="save()">Save changes</button>
      </div>
    </div>
  </div>
</div>
</div>
<script type="text/javascript" language="JavaScript">

var exerciseIdInput = ${exerciseId};
var tagsInput = ${tags};

// create Vue app
var app = new Vue({
			// element to mount to
			el: '#app',
			// initial data
			data: {
				tags: [],
				exerciseId: null,
				editingTag: {tagName: '', prefix: '', resources: { urls: [] }},
				editingTagDefault: {tagName: '', prefix: '',
									resources: {
										enabled: false,
										text: 'Please review the resources below.',
										urls: []
									}
								},
				defaultUrl: {urlName: '', urlUrl: ''},
				message: null
			},
			methods: {
				getData : function() {
					this.tags = tagsInput;
					this.exerciseId = exerciseIdInput
					this.tags = this.unpackResources(this.tags);

				},
				edit: function(tag) {
					if (!tag.resources) delete tag.resources; //clear if there is any garbage there like 'null'
					Object.assign(this.editingTag, this.editingTagDefault);
					Object.assign(this.editingTag, tag);
					$('#editTagModal').modal("show");
					
				},
				newTag: function() {
					this.editingTag = Object.assign({}, this.editingTagDefault);
					$('#editTagModal').modal("show");
				},
				save: function() {
					this.editingTag = this.packResources(this.editingTag);
					var self = this;
					$.get("../admin/admin.do",
	        		        {
	        		            method: 'tagSaveAjax',
	        		            exerciseId: self.exerciseId,
	        		            payload: JSON.stringify(self.editingTag)
	        		        }

	        		    ).fail(function(xhr, status) {
	        		    	alert("Could not make change: '" + xhr.responseText + "'");
	        		    }).done(function(data) {
	        		    	reply = JSON.parse(data);
	        		    	self.message = reply.message
	        		    	var found = self.tags.findIndex(function(t) { 
	        		    					return (t.tagId == reply.payload.tagId)
	        		    					});
	        		    	var newTag = reply.payload;
	        		    	newTag = self.unpackResources([newTag])[0];
	        		    	if (found == -1) self.tags.push(reply.payload);
	        		    	else self.tags.splice(found, 1, reply.payload);
	        		    	$('#editTagModal').modal("hide");
	        		})
				},
				deleteTag: function(tag) {
					if (confirm("Are you sure you want to delete '" + tag.tagName + "'?")) {
						var self = this;
						$.get("../admin/admin.do",
		        		        {
		        		            method: 'tagDeleteAjax',
		        		            exerciseId: self.exerciseId,
		        		            tagId: tag.tagId
		        		        }

		        		    ).fail(function(xhr, status) {
		        		    	alert("Could not make change: '" + xhr.responseText + "'");
		        		    }).done(function(data) {
		        		    	reply = JSON.parse(data);
		        		    	self.message = reply.message
		        		    	var found = self.tags.findIndex(function(t) { 
		        		    					return (t.tagId == tag.tagId)
		        		    					});
		        		    	if (found != -1) self.tags.splice(found, 1);
		        			})
					}
				},
				packResources: function(tag) {
					tag.resourcesJson = JSON.stringify(tag.resources);
					return tag;
				},
				unpackResources: function(tags) {
					for (var i=0; i<tags.length; i++) {
						tags[i].resources = JSON.parse(tags[i].resourcesJson);
					}
					return tags;
				},
				addUrl: function() {
					this.editingTag.resources.urls.push(Object.assign({}, this.defaultUrl))
				},
				deleteUrl: function(index) {
					this.editingTag.resources.urls.splice(index,1);
				}
			},
			mounted() {
				this.getData();
			}
})

function refreshAndClose() {
    window.opener.parent.app.reloadCases(${caseId});
    window.opener.loadData();
    window.close();
}
</script>

</body>
</html>