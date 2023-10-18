<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- requires moment.js and vue.js --%>

<c:if test="${not empty requestScope.icase}">

<div id="fileList" class="fileListContainer" style="display: none;">

<table class="fileTable">
	<tr>
		<th>ID</th>
		<th>Description/Filename</th>
		<th>Date Created</th>
		<th>Created By</th>
		<th>&nbsp;</th>
	</tr>
	<tr v-for="(image, index) in imagesSorted" :key="image.imageId" v-bind:class="[index%2==0?'even':'odd']">
		<td>{{image.imageId}}</td>
		<td class="alignLeft">{{image.description}}</td>
		<td>{{formatDate(image.createdDate)}}</td>
		<td>{{image.createdBy}}</td>
		<td style="white-space: nowrap;"><a href="#" v-on:click.prevent="openPreview(image.imageId)">View</a> 
        	<a href="#" v-on:click.prevent="openPreviewNW(image.imageId)" id="popupDetailed">(NW)</a>
        	<a href="#" v-on:click.prevent="deleteImage(image)">Delete</a>
        </td>
	</tr>
</table>
<div class="fileUploadDiv">
	<input type="text" id="descriptionInput" placeholder="New File Name (optional)" style="width: 250px;">
	<input type="file" id="fileUploadInput" class="fileUploadInput" @change="onFileUpload" style="display: none;">
	<input type="button" class="btn btn-default btn-sm fileUploadButton" value="Select File To Upload" onclick="$('#fileUploadInput').click();" />
	
</div>

</div>


<script type="text/javascript" language="JavaScript">
//transfer from java to vueJS
//var imagesSrc = ${requestScope.imagesJson};
imagesSrc = "";
var caseid = ${requestScope.icase.caseId};
var userName = '${sessionScope.security}';

function convertDateObjects(src) {
	for (var i = 0; i < src.length; i++) {
		item = src[i];
		Object.keys(item).forEach(function(key,index) {
		    var testDate = item[key];
			var date = moment(testDate, "YYYY-MM-DDTHH:mm:ss", true);
		    if (date.isValid()) {
		      item[key] = date;
		    }
		});
		src[i] = item;
	}
}

$(function() {
	if (typeof tinymce !== 'undefined') {
		
		if (tinymce.editors.length > 0) {
			alert("test");
			tinymce.editors.settings.image_list = [
		    {title: 'Dog', value: 'mydog.jpg'},
		    {title: 'Tiger', value: 'mycat.gif'}
		  ]
		}
	}
})

//convertDateObjects(imagesSrc);

var filevm = new Vue({
	el: "#fileList",
	data: {
		images: [{
			'imageId': '',
			'descrption': 'No files',
			'createdDate': ''
		}]
	},
	watched: {

		
	},
	computed: {
		imagesSorted: function() {
				var newList = this.images.sort(function (a, b) {
					
					//alert(moment(b.createdDate).format('X')-moment(a.createdDate).format('X'));
					 return moment(b.createdDate, "YYYY-MM-DDTHH:mm:ss")-moment(a.createdDate, "YYYY-MM-DDTHH:mm:ss");
				});
				return newList;
		}
	},
	methods: {
		formatDate: function(mydate) {
			return moment(mydate).format("MMM D, YYYY");
		},
		getData: function() {
			self = this;
			$.ajax({
		        url: "../admin/images.do",
		        data: {
		            method: "listJson",
		            caseid: caseid
		        },
		        type: "GET", dataType: "html",
		        success: function (data) {
		        	self.images = JSON.parse(data);
		        },
		        error: function (xhr, status) {
		        	alert("There was an error obtaining the file list. Status code: " + xhr.status);
		        },
		        complete: function (xhr, status) {
		        }
		    });
			
		},
		openPreview: function(id) {
			  var preview = parent.$("#preview");
			  $(preview).html("<img id='previewimage' style='max-width: 900px;' src='images.do?method=getImage&imageid=" + id + "'>");
			  parent.$("#loading").dialog("open");
			  parent.$("#previewimage").load(function() {
				  parent.$("#loading").dialog("close");
				  parent.$("#preview").dialog("open");
				  parent.$('#previewimage')
				    .wrap('<span style="display:inline-block"></span>')
				    .css('display', 'block')
				    .parent()
				    .zoom({
				    	on: 'grab'
				    });
			  });
		},
		openPreviewNW: function(id) {
			newwindow=window.open('viewimage3.jsp?id=' + id,'name','height=' + 500 +',width=' + 900);
			if (window.focus) {newwindow.focus()}
			return false;
		},
		deleteImage: function(image) {
			if (confirm("Are you sure you want to delete '" + image.description + "' image?")) {
				//images.do?method=deleteImage&imageid=&caseid=
						self = this;
						$.ajax({
					        url: "../admin/images.do",
					        data: {
					            method: "deleteImage",
					            imageid: image.imageId,
					            caseid: caseid
					        },
					        type: "GET", dataType: "html",
					        success: function (data) {
					        	//alert("done");
					        	var idx = self.images.indexOf(image);
					        	if (idx != -1) self.images.splice(idx, 1);
					        },
					        error: function (xhr, status) {
					        	alert("There was an error deleting the file. Status code: " + xhr.status);
					        },
					        complete: function (xhr, status) {
					        }
					    });
			}
		},
		onFileUpload: function() {
			self = this;
			var data = new FormData();
			jQuery.each(jQuery('#fileUploadInput')[0].files, function(i, file) {
				var filename = $('#fileUploadInput').val().split('\\').pop();
				$('#descriptionInput').val(filename);
				//alert(filename);
			    data.append('uploadFile', file);
			    data.append('caseid', caseid);
			    data.append('method', 'upload');
			    data.append('description', $('#descriptionInput').val());
			    data.append('mode', 'ajax');
			});
			jQuery.ajax({
			    url: '../admin/images.do',
			    data: data,
			    cache: false,
			    contentType: false,
			    processData: false,
			    method: 'POST',
			    type: 'POST', // For jQuery < 1.9
			    success: function(data){
			    	/*var newImage = {
			    			'imageId': self.images.length,
			    			'description': $('#descriptionInput').val(),
			    			'createdBy': userName,
			    			'createdDate': new Date()
			    	}*/
			    	var newImage = JSON.parse(data);
			        self.images.push(newImage);
			    },
			    error: function (xhr, status) {
			    	alert("There was an error uploading the file. Status code: " + xhr.status);
			    }
			});
		}
		
	},
	mounted() {
		this.getData(); //- currently load data from JSP, but if you want ajax, do this. (may need to set this later)
	}
})


</script>

</c:if>