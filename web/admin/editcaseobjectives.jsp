<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<script src="js/objectives.js"></script>

<%-- requires moment.js and vue.js --%>

<c:if test="${not empty requestScope.icase}">

<div id="objectiveList" class="fileListContainer">

<table class="fileTable" style="margin: 10px auto;">
	<tr>
		<th>ID</th>
		<th>Objective</th>
		<th>&nbsp;</th>
	</tr>
	<tr v-for="objective, index in objectivesSorted" :key="objective.objectiveId" v-bind:class="[index%2==0?'even':'odd']">
		<td class="alignLeft" v-bind:class="{contains:objective.contains}" v-bind:style="{'padding-left': objective.indent() + 10 + 'px'}">
			{{objective.objectiveCode}}
		</td>
		<td class="alignLeft" v-bind:class="{contains:objective.contains}">
			{{objective.objectiveName}}
		</td>
		<td style="white-space: nowrap;">
        	<a href="#" v-on:click.prevent="removeObjective(objective)">Remove</a>
        </td>
	</tr>
</table>
<div class="fileUploadDiv">
	<input type="button" class="btn btn-default btn-sm" data-load-url="editcaseobjectivesEditor.jsp?caseid=${requestScope.icase.caseId }&exerciseid=${requestScope.exerciseId}" id="insertObjectives" value="Insert Objectives"/>
</div>

</div>


<script type="text/javascript" language="JavaScript">
//transfer from java to vueJS
//var imagesSrc = ${requestScope.imagesJson};
imagesSrc = "";
var caseid = ${requestScope.icase.caseId};
var userName = '${sessionScope.security}';

$(function() {
   	$("#insertObjectives").click( function() {
   	 	parent.$('#objectivesmodal').modal('show');
   	 	parent.setModalHeight();
   	 	//parent.$('#searchtextmodal').find('.modal-iframe').load($(this).data("load-url"));
   	 	parent.$('#objectivesmodal').find('.modal-iframe').attr('src', $(this).data("load-url"));
   	})
   	
   	
   	
})

function objectivesModalClose() {
   		objectivesApp.getData();
   		if (loadData) loadData();
}

//convertDateObjects(imagesSrc);

var objectivesApp = new Vue({
	el: "#objectiveList",
	data: {
		objectives: [],
		caseId: ${requestScope.icase.caseId}
	},
	computed: {
		objectivesSorted: function() {
				this.objectives = Objective.sortObjectives(this.objectives);
				Objective.countContained(this.objectives, 3);
				return this.objectives;
		}
	},
	methods: {
		getData: function() {
			console.log("getData")
			this.objectives = [];
			$.ajax({
				url: "../admin/admin.do",
		        data: {
		            method: "objectivesGetAjax",
		            calltype: "ajax",
		            caseid: this.caseId
		        },
		        type: "POST",
		        dataType: "html"
			}).done(data => {
				
				let returnList = JSON.parse(data);
				this.updateData(returnList);
				
			}).fail(function (xhr) {
				alert("ERROR: " + xhr.responseText);
			});
		},
		updateData: function(parsedJson) {
			this.objectives = [];
			for (var i=0; i<parsedJson.length; i++) {
				this.objectives.push(new Objective(parsedJson[i]));
			}
			
		},
		removeObjective: function(o) {
			console.log("removeObjective")
			let os = [o];
			$.ajax({
				url: "../admin/admin.do",
		        data: {
		            method: "objectivesAttachAjax",
		            calltype: "ajax",
		            caseid: this.caseId,
		            operator: "detach",
		            objectives: JSON.stringify(os),
		            exerciseid: exerciseId
		        },
		        type: "POST",
		        dataType: "html"
			}).done(data => {
				//alert("done");
				
				//let parsedJson = JSON.parse(data);
				if (data == "success") {
					
						for (let i=0; i< os.length; i++) {
							this.objectives.splice(this.objectives.indexOf(os[i]), 1);
						}
					
				}
				
			}).fail(function (xhr) {
				alert("ERROR: " + xhr.responseText);
			});
		}
	},
	mounted() {
		this.getData(); //- currently load data from JSP, but if you want ajax, do this. (may need to set this later)
	}
})


</script>

</c:if>