/**
 * requires vue.js
 */

    var app = new Vue({
    	el: "#editExerciseContainer",
    	data: {
    		icases: [{caseId: '', caseName: 'Loading Cases..'}],
    		exerciseId: exerciseId,
    		activeCase: {},
    		onLoadOpenCaseId: null,
    		defaultExercise: [{exerciseId: "", exerciseName: "initializing...", contained: true}],
    		actionsCase: {
    			parentExercises: [{exerciseId: "", exerciseName: "initializing...", contained: true}]
    		},  
    		//later: .parentExercises and .index are added
    		actionsCaseIndex: 0,
    		actionsCaseParentExercises: [{exerciseId: "", exerciseName: "initializing...", contained: true}],
    		clearTagsOnMove: false,
    		filterType: '',
    		categories: [],
    		filterSelected: [],
    		sortByType: null
    	},
    	computed: {
    		sortedCases: function() {
    			return this.sortCases()
    		}
    	},
    	methods: {
    		getData: function() {
    			this.icases = [];
    			self = this;
    			$.ajax({
    		        url: "../admin/admin.do",
    		        data: {
    		            method: "editExerciseAjax",
    		            filterType: self.filterType,
    		            filterSelected: JSON.stringify(self.filterSelected),
    		            exerciseid: self.exerciseId
    		        },
    		        type: "GET", dataType: "html",
    		        success: function (data) {
    		        	//alert("loaded...");
    		        	self.icases = JSON.parse(data);
    		        	console.log(self.icases)
    		        	if (self.icases.length == 0) {
    		        		self.icases = [{caseId: '', caseName: 'No Cases Yet'}];
    		        	} else {
    		        		//sort
    		        		if (self.onLoadOpenCaseId != null) {
    		        			self.editCase(self.findCaseById(self.onLoadOpenCaseId));
    		        		}
    		        	}
    		        },
    		        error: function (xhr, status) {
    		        	alert("There was an error obtaining the file list. Status code: " + xhr.status);
    		        },
    		        complete: function (xhr, status) {
    		        }
    		    });
    		},
    		reloadCases: function(activeCaseId) {
    			this.getData();
    			var found = null;
    			for (var i=0; i<this.icases.length; i++) {
    				if (this.icases[i].caseId == activeCaseId) found = this.icases[i];
    			}
    			if (found != null) {
    				this.activeCase = found;
    				this.editCase(found);
    			}
    			
    		},
    		findCaseById: function(caseId) {
    			var found = null;
    			for (var i=0; i<this.icases.length; i++) {
    				if (this.icases[i].caseId == caseId) found = this.icases[i];
    			}
    			if (found != null) {
    				return found;
    			} else {
    				alert("Case " + caseId + " not found");
    			}
    		},
    		updateActiveCase: function() {
    			this.activeCase.caseName = "";
    			self = this;
    			$.ajax({
    		        url: "../admin/admin.do",
    		        data: {
    		            method: "getCaseAjax",
    		            exerciseId: self.exerciseId,
    		            caseId: self.activeCase.caseId
    		        },
    		        type: "GET", dataType: "html",
    		        success: function (data) {
    		        	var updatedActiveCase = JSON.parse(data);
    		        	self.activeCase.caseName = updatedActiveCase.caseName;
    		        	self.activeCase.prefix = updatedActiveCase.prefix;
    		        },
    		        error: function (xhr, status) {
    		        	alert("There was an error. Status code: " + xhr.status);
    		        },
    		        complete: function (xhr, status) {
    		        }
    		    });
    		},
    		editCase: function(icase) {
    			//alert("open");
    			window.open('admin.do?method=viewCase&caseid=' + icase.caseId + '&exerciseid=' + this.exerciseId, 'editcase');
				
    			this.activeCase = icase;
    			setTimeout(function () {
    				window.scrollTo(0, 0);
    				}, 100);
    		},
    		editCaseById: function(caseid) {
    			this.onLoadOpenCaseId = caseid;
    		},
    		addCase: function(casetype) {
    			self = this;
    			$.ajax({
    		        url: "../admin/admin.do",
    		        data: {
    		            method: "addCase",
    		            exerciseid: self.exerciseId,
    		            casename: $("#newcasename").val(),
    		            template: casetype
    		        },
    		        type: "GET", dataType: "html",
    		        success: function (data) {
    		        	var newCase = JSON.parse(data);
    		        	self.icases.push(newCase);
    		        	self.editCase(newCase);
    		        	$("#newcasename").val("");
    		        },
    		        error: function (xhr, status) {
    		        	alert("There was an error on the server side. Status code: " + xhr.status);
    		        },
    		        complete: function (xhr, status) {
    		        }
    		    });
    		},
    		deleteCase: function(index) {
    			//alert(this.icases[index]['caseId']);
    			self = this;
    			$.ajax({
    		        url: "../admin/admin.do",
    		        data: {
    		            method: "deleteCase",
    		            exerciseid: self.exerciseId,
    		            caseid: self.icases[index]['caseId']
    		        },
    		        type: "GET", dataType: "html",
    		        success: function (data) {
    		        	self.icases.splice(index, 1);
    		        	$('#caseActions').modal('hide');
    		        },
    		        error: function (xhr, status) {
    		        	alert("There was an error on the server side. Status code: " + xhr.status);
    		        },
    		        complete: function (xhr, status) {
    		        }
    		    });
    		},
    		reorderCase: function(index, direction) {
    			var self = this;
    			$.ajax({
    		        url: "../admin/admin.do",
    		        data: {
    		            method: "reorderCase",
    		            caseid: this.icases[index].caseId,
    		            exerciseid: this.exerciseId,
    		            direction: direction
    		        },
    		        type: "GET",
    		        dataType: "html",
    		        success: function (data) {
    		        	
    		        	if (data.trim() == "Success") {
    		        		self.reorderCaseDisplay(index, direction);
    		        	} else {}
    		        		//ie moving out of bounds
    		        },
    		        error: function (xhr, status) {
    		            alert("Error Contacting Server: '" + xhr.responseText + "'");
    		        },
    		        complete: function (xhr, status) {
    		            
    		        }
    			});
				
    		},
    		reorderCaseDisplay: function(index, direction) {
    			var targetIndex = index;
    			if (direction == 'down') {
    				if (index == this.icases.length-1) return null;
    				targetIndex += 1;
    			} else if (direction == 'up') {
    				if (index == 0) return null;
    				targetIndex -= 1;
    			}
    			var icase = this.icases[index];

    			this.icases.splice(index, 1); // remove item from old location
    			this.icases.splice(targetIndex, 0, icase); // reinsert it at new location
    		},
    		filterBy: function(filterType) {
    			this.filterType = filterType;
    			this.filterSelected = [];
    			if (filterType == "ecgDx") {
    				//	      <a href="#" class="btn btn-default btn-xs" data-load-url="searchterm.do"  id="filtersBtn" aria-expanded="false">
    				$('#searchtextmodal').modal('show');
    		   	 	$('#searchtextmodal').find('#filterSelectedBtn').show();
    		   	 	$('#searchtextmodal').find('#insertSelectedBtn').hide();
    		   	 	//rescale();
    		   	 	//parent.$('#searchtextmodal').find('.modal-iframe').load($(this).data("load-url"));
    		   	 	$('#searchtextmodal').find('.modal-iframe').attr('src', 'searchterm.do');
    				
    			} else if (filterType == "category") {
        			$.ajax({
        		        url: "../admin/admin.do",
        		        data: {
        		            method: "tagListAjax",
        		            includeCounts: true,
        		            exerciseid: this.exerciseId
        		        },
        		        type: "POST",
        		        dataType: "html"
        			}).done(data => {
        				this.categories = JSON.parse(data)['availableTags'];
        				$('#filtermodal').modal('show');
        			}).fail((xhr, status) => {
        		            alert("Error Contacting Server: '" + xhr.responseText + "'");
        		    });
    			}
    		},
    		filterSelectCategory: function(i) {
    			var category = this.categories[i];
    			if (category.selected) {
    				category.selected = false;
    				this.filterSelected.splice(this.filterSelected.indexOf(category.tagId), 1);
    				
    			} else {
    				category.selected = true;
    				this.filterSelected.push(category.tagId);
    			}
    			this.categories.splice(i, 1, category);

    		},
    		filterSelectECGDx: function(dxs) {
    			this.filterSelected.push.apply(this.filterSelected, dxs);
    			this.getData();
    			$('#searchtextmodal').modal('hide');
		   	 	$('#searchtextmodal').find('#filterSelectedBtn').hide();
		   	 	$('#searchtextmodal').find('#insertSelectedBtn').show();
    		},
    		loadExerciseSettings: function(index) {
    			var icase = this.icases[index];
    			this.actionsCase = icase;
    			this.actionsCase.index = index;
    			//this.actionsCase.parentExercises = this.defaultExercise;

    			var self = this;
				
    		    
    		    $.ajax({
    		    	url: "../admin/admin.do",
    		        data: {
    		            method: "getParentExercisesAjax",
    		            calltype: "ajax",
    		            caseid: icase.caseId,
    		            exerciseid: this.exerciseId
    		        },
    		        type: "GET",
    		        dataType: "html"
    			}).done(data => {
    				var reply = JSON.parse(data);
        		    Vue.set(this.actionsCase, 'parentExercises', reply);
        		    $('#caseActions').modal('show');
    				//alert(this.actionsCase.parentExercises[0].exerciseName);
    			}).fail(xhr => {
    				alert("Error Contacting Server: " + xhr);
    			});
    			
    			this.icases.splice(index, 1, this.actionsCase); //update in array
    		},
    		toggleContainedExercise: function(index) {
    			var selectedExercise = this.actionsCase.parentExercises[index];
    			var removingFromCurrentExercise = false;
    			if (selectedExercise.exerciseId == this.exerciseId) {
    				if (!confirm("You are removing this case from the current folder.  It will disappear from this list.")) return null;
    				removingFromCurrentExercise = true;
    			}
    			var noMoreParents = true;
    			for (var i=0; i< this.actionsCaseParentExercises.length; i++) {
    				if (this.actionsCaseParentExercises[i] != selectedExercise && this.actionsCaseParentExercises[i]['contained'] == true) {
    					noMoreParents = false;
    					break;
    				}
    			}
    			if (noMoreParents) {
    				alert("Cases cannot be without a folder.");
    				return null;
    			}

				
				$.ajax({
					url: "../admin/admin.do",
    		        data: {
    		            method: "toggleParentExercisesAjax",
    		            calltype: "ajax",
    		            caseid: self.actionsCase['caseId'],
    		            exerciseid: self.exerciseId,
    		            selectedexerciseid: selectedExercise['exerciseId'],
    		            addorremove: !selectedExercise['contained'],
    		            clearTagsOnMove: this.clearTagsOnMove
    		        },
    		        type: "GET",
    		        dataType: "html"
    			}).done(data => {
    				//this.actionsCase.parentExercises = JSON.parse(data);
    				if (removingFromCurrentExercise) {
    					this.icases.splice(this.actionsCase.index, 1);
    					$('#caseActions').modal('hide');
    				} else {
        				selectedExercise['contained'] = !selectedExercise['contained'];
        				this.actionsCase.parentExercises.splice(index, 1, selectedExercise);
    				}
    			}).fail(xhr => {
    				alert("Error Contacting Server: " + xhr.responseText);
    			});
				
    		},
    		sortBy: function(type) {
    			// sortByType can be tag or age or null
    			if (type === 'clear') this.sortByType == null;
    			else this.sortByType = type;
    		},
    		sortCases: function() {
    			if (!this.sortByType) return this.icases;
    			if (this.sortByType === 'date') {
    				return this.icases.concat().sort((a,b) => a.caseId - b.caseId);
    			} else if (this.sortByType === 'tag') {
	    			return this.icases.concat().sort(function(a, b) {
	    				if(a.prefix == '' && b.prefix == '') return a.caseId < b.caseId;
	    				if(a.prefix == '') //return 1;
	    				if(b.prefix == '') return -1;
	    				if(a.prefix < b.prefix) return -1;
	    			    if(a.prefix > b.prefix) return 1;
	    			});
    			}
    		},
    		changeActiveComments: function(caseId, change) {
    			const found = this.icases.find(c => c.caseId === caseId)
    			found.activeComments += change
    		}
    	},
    	mounted() {
    		this.getData();
    	}
    })