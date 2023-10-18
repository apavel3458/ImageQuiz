<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Objectives Editor</title>
	
        <script src="../jslib/jquery-1.10.1.min.js"></script>
        <script src="../jslib/jquery-ui.min.js"></script>
        <script src="../jslib/bootstrap.min.js"></script>
        <script src="js/vue.js"></script>
        <script src="js/objectives.js"></script>
        
        <link rel="stylesheet" href="../css/lib/bootstrap.paper.min.css">
		<link rel="stylesheet" href="css/editcase.css">
		<link rel="stylesheet" href="css/objectives.css">
		<link rel="stylesheet" href="css/admin.css">
		<link href="../css/lib/fa/css/all.css" rel="stylesheet"> <!--load all styles -->

</head>
<body>
	<div id="objectiveContainer" class="objectiveContainer">
		<div class="inputContainer">
				<div class="addNewDiv" v-if="editing==null">
					<template v-if="!multiple">
						<input v-model="newObjectiveCode" placeholder="Code" style="text-align: center; width: 70px;">
						<input v-model="newObjectiveName" placeholder="Objective Name" class="objectiveNameField" style="width: 300px;">
					</template>
					<template v-else>
						<textarea v-model="newObjectiveName" style="width: 500px; height: 100px;" placeholder="Enter objectives one per line"></textarea>
						<br/>
					</template>
					<input type="button" class="btn btn-primary btn-sm" v-on:click.prevent="addObjective()" value="Add Objective">
					<input type="button" class="btn btn-default btn-sm" v-on:click.prevent="multiple = !multiple" v-bind:value="multiple ? 'Single Entry' : 'Multiple Entry'">
					<br>
						<div class="status" v-show="status != ''" v-bind:class="{'error':error}">{{status}}</div>
				</div>
				<div class="editDiv" v-if="editing!=null" v-cloak>
						<input v-model="editing.objectiveCode" placeholder="Code" style="text-align: center; width: 70px;">
						<input v-model="editing.objectiveName" placeholder="Objective Name" class="objectiveNameField" style="width: 300px;">
					<input type="button" class="btn btn-primary btn-sm" v-on:click.prevent="editObjectiveAjax(editing)" value="Save Objective">
					<input type="button" class="btn btn-default btn-sm" v-on:click.prevent="editing = null" value="Cancel Edit">
					<br>
						<div class="status" v-show="status != ''" v-bind:class="{'error':error}">{{status}}</div>
				</div>
		</div>

		
		
		<hr>

		<hr>
	<span class="properties">Orphaned Objectives: {{countOrphaned()}}<br>
	 Selected Objectives: {{objectivesSelected.length}}<br>
	 Auto Add Categories: <input type="checkbox" v-model:bind="addCategories"></span>
	<table class="objTable">
		<tr>
			<th colspan="3">
				<div class="searchbox" style="float:left;">
					<i class="fas fa-search"></i><input id="searchTextField"  placeholder="Search Term"> {{openObjectiveCode}}
				</div>
				Code & Name
			</th>
			<th>Action</th>
		</tr>
		<template v-for="objective, i in filteredObjectives" 
				:key="objective.objectiveId"
				v-if="(searchQuery == '' && (!objective.hidden || objective.orphan)
						|| (searchQuery != '' && !objective.hidden))">
			<tr v-bind:class="[{selected:objective.selected}, {orphan: objective.orphan}]">
				<td class="objectiveCodeTd" v-bind:class="[{contains: objective.contains}]">
					<span v-bind:style="{'padding-left': objective.indent() + 'px'}" class="objectiveCode" 
						v-on:click="clickedObjective(objective)">
						{{objective.objectiveCode}} 
					</span>
				</td>
				<td class="objectiveIconTd">
					<i v-if="objective.contains" class="far fa-copy"></i>
				</td>
				<td class="objectiveNameTd" v-bind:class="{contains: objective.contains}">
					<span class="objectiveName" 
						v-on:click="clickedObjective(objective)">
						{{objective.objectiveName}}
					</span>
				</td>
				<td class="actionsTd">
						<input type="button" class="btn btn-default btn-xs actionButton" 
							v-on:click.prevent="selectObjective(objective)" 
							 value="Select" >
						<input type="button" class="btn btn-default btn-xs actionButton" 
							v-on:click.prevent="deleteObjective(objective)" 
							 value="Delete" >
						<input type="button" class="btn btn-default btn-xs actionButton" 
							v-on:click.prevent="editObjective(objective)" 
							value="Edit">
				</td>
			</tr>
		</template>
	</table>
	
	</div>
	
	<script type="text/javascript" language="JavaScript">
	
	//global vars
	var newObjectiveDefault = {objectiveCode: '', objectiveName: ''};
	
	function getNewObjectiveDefault() { JSON.parse(JSON.stringify(newObjectiveDefault))}
	
	// create Vue app
	var app = new Vue({
				// element to mount to
				el: '#objectiveContainer',
				// initial data
				data: {
					objectives: new Array(),
					objectivesSelected: [],
					searchQuery: "",
					searchQueryTxt: "",
					newObjectiveCode: "",
					newObjectiveName: "",
					status: "",
					error: false,
					multiple: false,
					openObjectiveCode: '',
					displayLevel: 3,
					editing: null,
					editingIndex: "",
					caseId: ${param.caseid},
					exerciseId: ${param.exerciseid},
					addCategories: false
				},
				computed: {
					filteredObjectives: function() {
						//alert("called filter");
						this.objectives = Objective.sortObjectives(this.objectives);
						
						Objective.countContained(this.objectives, this.displayLevel);
						

						if (this.searchQuery != "") {
							var query = this.searchQuery.toLowerCase();
							for (let i = 0; i < this.objectives.length; i++) {
								if (this.objectives[i].objectiveName.toLowerCase().includes(query)) {
									//match
									this.objectives[i].openParents(this.objectives);
									this.objectives[i].hidden = false;
								} else {
									this.objectives[i].hidden = true;
								}
								this.objectives.splice(i, 1, this.objectives[i]); //trigger VueJS
							}
						}
						
					    
					    return this.objectives;
					}
				},
				watch: {
					status: function(val) {
						let regex = /Error/gi;
						if (regex.test(val)) {
							this.error = true;
						} else
							this.error = false;
					}
				},
				methods: {
					getData: function() {
						console.log("getData")
						//get all objectives
						$.ajax({
							url: "../admin/admin.do",
		    		        data: {
		    		            method: "objectivesGetAjax",
		    		            calltype: "ajax"
		    		        },
		    		        type: "POST",
		    		        dataType: "html"
		    			}).done(data => {
		    				//alert("done");
		    				
		    				let returnList = JSON.parse(data);
		    				this.updateData(returnList);
		    				
		    				
		    				
		    				
		    				//todo: put above and below ajax into one
							//get associated objectives
							$.ajax({
								url: "../admin/admin.do",
			    		        data: {
			    		            method: "objectivesGetAjax",
			    		            calltype: "ajax",
			    		            caseid: ${param.caseid}
			    		        },
			    		        type: "POST",
			    		        dataType: "html"
			    			}).done(data => {
			    				//alert("done");
			    				
			    				let parsedJson = JSON.parse(data);
			    				for (var i=0; i<parsedJson.length; i++) {
			    					let o = Objective.findById(this.objectives, parsedJson[i].objectiveId)
			    					o.selected = true;
			    					this.objectives.splice(this.objectives.indexOf(o), 1, o);
			    					this.objectivesSelected.push(new Objective(parsedJson[i]));
			    				}
			    			}).fail(function (xhr) {
			    				alert("ERROR: " + xhr.responseText);
			    			}); 
		    				
		    				
		    				
		    			}).fail(function (xhr) {
		    				alert("ERROR: " + xhr.responseText);
		    			});
						
						
					},
					updateData: function(parsedJson) {
	    				for (var i=0; i<parsedJson.length; i++) {
	    					this.objectives.push(new Objective(parsedJson[i]));
	    				}
	    				this.objectives = Objective.sortObjectives(this.objectives);
						Objective.hideAboveLevel(this.objectives, this.displayLevel);
					},
					countOrphaned: function() {
						return this.objectives.filter(i => i.orphan===true).length;
					},
					clickedObjective: function(objective) {
						let starti = this.objectives.indexOf(objective);
						let rootCode = objective.objectiveCode;
						let opening = this.objectives[starti+1].hidden;
						for (var i=starti+1; i<this.objectives.length; i++) {
							if (this.objectives[i].objectiveCode.startsWith(rootCode) 
									&& (!opening || this.objectives[i].level() == objective.level()+1)) {
								this.objectives[i].hidden = !opening; // if closing close all children, if opening open immediate children
								
							} else if (!this.objectives[i].objectiveCode.startsWith(rootCode)) {
								//if past the child elements, then stop loop
								i = this.objectives.length;
							}
						}
						if (opening) {//scroll down a bit
							//parent.$('#objectivesiframe').contents().scrollTop("+= 100");
							$('html,body').animate({ scrollTop: "+=115" }, 500);
						}
					},
					selectObjective: function(o) {
						let objectivesList = [];
						if (o.selected) {
							objectivesList.push(o);
							this.attachObjectiveAjax(objectivesList, "detach");
						} else {
							operator = "attach";
							objectivesList.push(o);
							let parents = o.getParents(this.objectives);
							for (let i=0; i< parents.length; i++) {
								objectivesList.push(parents[i]);
							}
							this.attachObjectiveAjax(objectivesList, "attach");
						}
					},
					attachObjectiveAjax: function(os, operator) {
						console.log("attachObjectiveAjax")
						$.ajax({
							url: "../admin/admin.do",
		    		        data: {
		    		            method: "objectivesAttachAjax",
		    		            calltype: "ajax",
		    		            caseid: this.caseId,
		    		            operator: operator,
		    		            exerciseid: this.exerciseId,
		    		            addCategories: this.addCategories,
		    		            objectives: JSON.stringify(os)
		    		        },
		    		        type: "POST",
		    		        dataType: "html"
		    			}).done(data => {
		    				//alert("done");
		    				
		    				//let parsedJson = JSON.parse(data);
		    				if (data == "success") {
		    					if (operator == "detach") {
		    						for (let i=0; i< os.length; i++) {
		    							os[i].selected = false;
										this.objectivesSelected.splice(this.objectivesSelected.indexOf(os[i]), 1);
		    						}
		    					} else if (operator == "attach") {
		    						for (let i=0; i< os.length; i++) {
		    							os[i].selected = true;
		    							this.objectivesSelected.push(os[i]);
		    						}
		    					}
		    				}
		    				
		    			}).fail(function (xhr) {
		    				alert("ERROR: " + xhr.responseText);
		    			});
					},
					addObjective: function() {
						console.log("addObjective")
						let enteredName = this.newObjectiveName;
						let newObjective = {};
						const regexp = /([0-9]+\.)+/g;  //#.#. Text
						let newObjectives = [];
						
						enteredName = enteredName.split("\n").join("");
						
						const count = (str) => {
							  return ((str || '').match(regexp) || []).length
						} //number of patterns in string
						
						let objectiveCount = count(enteredName);
						//alert(objectiveCount);
						if (objectiveCount > 0) {
							while ((match = regexp.exec(enteredName)) != null) {
							    newObjective.objectiveCode = match[0].trim();
								if (newObjective.objectiveCode.endsWith(".")) 
									newObjective.objectiveCode = newObjective.objectiveCode.substring(0, newObjective.objectiveCode.length-1);
							    
							    let nextIndex1 = enteredName.substring(match.index+match[0].length).search(regexp); //start from initial part, find next one
							    let nextIndex = nextIndex1 + match.index+match[0].length; //add initial part
							    //alert(nextIndex);
							    let extractedName;
							    if (nextIndex1 != -1)
							    	extractedName = enteredName.substring(match.index+match[0].length, nextIndex);
							    else
							    	extractedName = enteredName.substring(match.index+match[0].length);
							    newObjective.objectiveName = extractedName.trim();
							    newObjectives.push(JSON.parse(JSON.stringify(newObjective)));
							}
						} else {
							if (this.newObjectiveCode != "" && this.newObjectiveName != "") {
								if (this.newObjectiveCode.endsWith(".")) {
									this.newObjectiveCode = this.newObjectiveCode.substring(0, this.newObjectiveCode.length-1);
								}
								newObjective.objectiveCode = this.newObjectiveCode.trim();
								newObjective.objectiveName = this.newObjectiveName.trim();
								newObjectives.push(JSON.parse(JSON.stringify(newObjective)));
							} else {
								alert("Incomplete entry, ensure the code and name are entered");
							}
						}
						
						this.newObjectiveCode = '';
						this.newObjectiveName = '';
						
						if (newObjectives.length > 0)
							this.addObjectiveAjax(newObjectives);
						
					},
					addObjectiveAjax: function(objectives) {
						console.log("addObjectiveAjax")
						$.ajax({
							url: "../admin/admin.do",
		    		        data: {
		    		            method: "objectivesAddAjax",
		    		            calltype: "ajax",
		    		            objective: JSON.stringify(objectives)
		    		        },
		    		        type: "POST",
		    		        dataType: "html"
		    			}).done(data => {
		    				
							let returnList = JSON.parse(data);
		    				this.updateData(returnList);
							this.status = "Saved new objectives!";
		    			}).fail(function (xhr) {
		    				alert("ERROR: " + xhr.responseText);
		    				this.status = "Error, unable to save new objective!";
		    			});
					},
					editObjective: function(objective) {
						console.log("editObjective")
						this.editingIndex = this.objectives.indexOf(objective);
						this.editing = new Objective(JSON.parse(JSON.stringify(objective))); //make deep copy for editing
					    document.body.scrollTop = 0; // For Safari
					    document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
					},
					editObjectiveAjax: function(objective) {
						console.log("editObjectiveAjax")
						$.ajax({
							url: "../admin/admin.do",
		    		        data: {
		    		            method: "objectivesEditAjax",
		    		            calltype: "ajax",
		    		            objective: JSON.stringify(objective)
		    		        },
		    		        type: "POST",
		    		        dataType: "html"
		    			}).done(data => {
		    				this.objectives.splice(this.editingIndex, 1, new Objective(returnO));
		    				this.updateData([]);
							this.status = "Objective Updated!";
							this.editing = null;
							this.editingIndex = null;
		    			}).fail(function (xhr) {
		    				alert("ERROR: " + xhr.responseText);
		    				this.status = "Error, unable to save new objective!";
		    			});
					},
					deleteObjective: function(objective) {
						//if (!confirm("Are you sure you want to delete " + objective.objectiveCode + " : '" + 
						//			objective.objectiveName + "'")) return;
						$.ajax({
							url: "../admin/admin.do",
		    		        data: {
		    		            method: "objectivesDeleteAjax",
		    		            calltype: "ajax",
		    		            objectiveid: objective.objectiveId
		    		        },
		    		        type: "POST",
		    		        dataType: "html"
		    			}).done(data => {
		    				this.objectives.splice(this.objectives.indexOf(objective), 1);
		    				this.status = "Removed objective!";
		    			}).fail(function (xhr) {
		    				alert("ERROR: Could not delete objective.  Cause: " + xhr.responseText);
		    				this.status = "Error, unable to remove objective!";
		    			});
					},
					searchText: function(searchQueryText) {
						if (searchQueryText == "") {
							//Objective.resetHidden(this.objectives);
							Objective.hideAboveLevel(this.objectives, this.displayLevel);
						} 
						this.searchQuery = searchQueryText;
						
					}
				},
				mounted() {
					this.getData(); //- currently load data from JSP, but if you want ajax, do this. (may need to set this later)
				}
	});
	
	var timer;
	$("#searchTextField").keyup(function (e) {
	    clearTimeout(timer); // Clear the timer so we don't end up with dupes.
	    timer = setTimeout(function() { // assign timer a new timeout 
	        app.searchText($(e.target).val());
	    }, 300);
	});
	</script>
</body>
</html>