/**
 * 
 */

		// require caseId and exerciseId to be declared
var app = new Vue({
  	// element to mount to
  	el: '#caseEditorApp',
  	data: {
  		icase: {
  			caseName: 'Case Name',
  			caseText: 'Enter casetext here...',
  			caseAnswerText: 'Enter answer text here...'
  		},
		loading: false,
		labTable: labsDefinitions,
		activeEditor: null,
		labsSelected: [],
		isTitleChanged: false,
		workingQuestion: null,
		eligibleVideoFiles: [],
		videoIncludeCaption: true
  	},
  	created () {
  		this.getData();
  	},
	methods: {
		getData () {
			$.ajax({
				url: "../admin/case.do",
		    	
		        data: {
		            method: "viewCaseAjax",
		            calltype: "ajax",
		            caseid: caseId,
		            exerciseid: exerciseId,
		            editor: 'mcq'
		        },
		        type: "POST",
		        dataType: "html"
			}).done(data => {
				this.icase = Object.assign({}, JSON.parse(data));
				console.log(this.icase)
				this.preViewProcess();
			}).fail(function (xhr) { alert("ERROR: " + xhr.responseText); });
		},
		save () {
			const icaseToSend = this.preSaveProcess();
			console.log("SENDING....");
			// delete icaseToSend.questionList[0].associatedAnswerLines;
			// console.log(icaseToSend);
			this.loading = true;
			$.ajax({
				url: "../admin/case.do",
		    	
		        data: {
		            method: "saveCaseAjax",
		            calltype: "ajax",
		            caseid: caseId,
		            exerciseid: exerciseId,
		            editor: 'mcq',
		            payload: JSON.stringify(icaseToSend)
		        },
		        type: "POST",
		        dataType: "html"
			}).done(data => {
				let reply = JSON.parse(data);
				console.log(reply.questionList);
				if (this.icase && this.icase.questionList.length > 0) {
					Vue.set(this.icase, 'questionList', reply.questionList)
				}
				
				if (this.isTitleChanged) { //update title in menu
					parent.app.updateActiveCase();
					this.isTitleChanged = false;
				}
				
				$(".autosaveTimestamp").html(moment().format('MMMM Do YYYY, h:mm:ss a'));
				window.clearTimeout(loginTimeoutWarn);
	       		window.clearTimeout(autosaveTimeout);
	       		let self = this;
	       		setTimeout(function(){ self.loading = false; }, 500); // show spin wheel
			}).fail(function (xhr) { 
				self.loading = false;
				console.log(xhr.responseText);
				alert("ERROR: " + xhr.responseText); 
				
			});
		},
		preViewProcess () {
			let questionAtEndRegex = /({question:.+?})+$/g;
			let questionRegex = /{question:.+?}/g;
			let answerAtStartRegex = /^({answer:.+?})+/g;
			let answerRegex = /({answer:.+?})+/g;
			if (!questionRegex.test(this.icase.caseText.replace(questionAtEndRegex, ''))) {
				this.icase.caseText = this.icase.caseText.replace(questionRegex, '');
			}
			if (!answerRegex.test(this.icase.caseAnswerText.replace(answerAtStartRegex, ''))) {
				this.icase.caseAnswerText = this.icase.caseAnswerText.replace(answerRegex, '');
			}
		},
		preSaveProcess () {
			let caseText = this.$refs.caseTextRef.innerHTML;
			let caseAnswerText = this.$refs.caseAnswerTextRef.innerHTML;
			this.icase.caseText = caseText
			this.icase.caseAnswerText = caseAnswerText;
			//deep copy
			let icaseToSend = JSON.parse(JSON.stringify(this.icase))
			// console.log(icaseToSend)
			let questionRegex = /{question:.+?}/g
			let answerRegex = /{answer:.+?}/g
			if (!questionRegex.test(caseText)) {
				icaseToSend.questionList.forEach(q => {caseText = caseText + '{question:'+q.questionTextId + '}'});
			}
			if (!answerRegex.test(caseAnswerText)) {
				icaseToSend.questionList.slice().reverse().forEach(q => {caseAnswerText = '{answer:'+q.questionTextId + '}' + caseAnswerText});
			}
			icaseToSend.caseText = caseText;
			icaseToSend.caseAnswerText = caseAnswerText;
			
			this.preSaveProcessSG(icaseToSend)
			return icaseToSend;
		},
		preSaveProcessSG(icase) {
			icase.questionList.forEach(q => {
				if (q.associatedAnswerLines != null) {
					q.associatedAnswerLines.forEach(l => {
						l.associatedAnswerWrappers.forEach(w => {
							w.correctAnswer = w.scoreModifier > 0
						})
					})
				}
			})
		},
		setCorrect (question, choice) {
//			question.associatedChoices.forEach((c) => {
//				c.correct = false;
//				c.selectScore = 0;
//				});
			if (choice.correct) choice.selectScore = 1;
			else choice.selectScore = 0;
			question.maxUserSelections = question.associatedChoices.reduce((acc, val) => acc + val.correct, 0)
			question.passScore = question.associatedChoices.reduce((acc, val) => acc + val.selectScore, 0)
		},
		addChoice: function (question) {
			if (question.associatedChoices == null) Vue.set(question, 'associatedChoices', []);
			question.associatedChoices.push(this.getDefaultChoice());
		},
		addQuestion: function (type) {
			if (type == 'mcq') {
				this.icase.questionList.push(Object.assign({}, this.getDefaultMcqQuestion()));
			} else if (type == 'sg') {
				this.icase.questionList.push(Object.assign({}, this.getDefaultSgQuestion()));
			} else if (type == 'sgs') {
				this.icase.questionList.push(Object.assign({}, this.getDefaultSgsQuestion()));
			} else if (type == 'text') {
				this.icase.questionList.push(Object.assign({}, this.getDefaultTextQuestion()));
			}
		},
		removeQuestion: function (question) {
			this.icase.questionList.splice(this.icase.questionList.indexOf(question), 1);
		},
		removeChoice: function (question, choice) {
			question.associatedChoices.splice(question.associatedChoices.indexOf(choice), 1);
		},
		numberToLetter: function (number) {
			return String.fromCharCode(65 + number);
		},
		getDefaultChoice(text) {
			return {
				answerString: text,
				correct: false,
				selectScore: 0,
				missScore: 0
			};
//			choiceId: (...)
//			answerString: (...)
//			correct: (...)
//			selectScore: (...)
//			missScore: (...)
		},
		getDefaultChoices() {
			const array = [];
			array.push(Object.assign({}, this.getDefaultChoice("Choice A")));
			array.push(Object.assign({}, this.getDefaultChoice("Choice B")));
			array.push(Object.assign({}, this.getDefaultChoice("Choice C")));
			array.push(Object.assign({}, this.getDefaultChoice("Choice D")));
			array[2].correct= true;
			array[2].selectScore= 1;
			return array;
		},
		getDefaultMcqQuestion() {
			let question = 
			{
					maxUserSelections: 1,
					questionTextId: 'q'+this.icase.questionList.length,
					questionType: 'choice',
					questionText: '',
					passScore: 1,
					scoreIncorrectChoice: 0,
					wrongChoiceScore: 0,
					associatedChoices: this.getDefaultChoices()
			}
			// console.log(question);
			return question;
//			associatedChoices: (...)
//			maxUserSelections: (...)
//			questionId: (...)
//			questionTextId: (...)
//			questionType: (...)
//			questionText: (...)
//			passScore: (...)
//			scoreIncorrectChoice: (...)
//			wrongChoiceScore: (...)
		},
		getDefaultSgQuestion() {
			let question = 
			{
					maxUserSelections: 1,
					questionTextId: 'q'+this.icase.questionList.length,
					questionType: 'sg',
					questionText: '',
					passScore: 1,
					scoreIncorrectChoice: 0,
					wrongChoiceScore: 0,
					associatedAnswerLines: [
						{
							associatedAnswerWrappers: [
								{
									scoreModifier: 1,
									scoreMissed: 0,
									primaryAnswer: true,
									correctAnswer: true,
									searchTerm: {
										searchTermId: 62,
										searchTermString: 'Pericarditis'
									}
								}
							]
						}
					]
			}
			// console.log(question);
			return question;
//			associatedChoices: (...)
//			maxUserSelections: (...)
//			questionId: (...)
//			questionTextId: (...)
//			questionType: (...)
//			questionText: (...)
//			passScore: (...)
//			scoreIncorrectChoice: (...)
//			wrongChoiceScore: (...)
		},
		getDefaultSgsQuestion() {
			let question = 
			{
					maxUserSelections: 1,
					questionTextId: 'q'+this.icase.questionList.length,
					questionType: 'sgs',
					questionText: '',
					passScore: 1,
					scoreIncorrectChoice: 0,
					wrongChoiceScore: 0,
					associatedAnswerLines: [
						{
							associatedAnswerWrappers: [
								{
									scoreModifier: 1,
									scoreMissed: 0,
									primaryAnswer: true,
									correctAnswer: true,
									searchTerm: {
										searchTermId: 62,
										searchTermString: 'Pericarditis'
									}
								}
							]
						}
					]
			}
			// console.log(question);
			return question;
		},
		getDefaultTextQuestion() {
			let question = 
			{
					questionTextId: 'q'+this.icase.questionList.length,
					questionType: 'text',
					questionText: '',
					passScore: 0,
					options: {
						maxLength: 100,
						modelAnswer: ''
					}
					
			}
			// console.log(question);
			return question;
//			associatedChoices: (...)
//			maxUserSelections: (...)
//			questionId: (...)
//			questionTextId: (...)
//			questionType: (...)
//			questionText: (...)
//			passScore: (...)
//			scoreIncorrectChoice: (...)
//			wrongChoiceScore: (...)
		},
		getLabTable (editor) {
			this.activeEditor = editor;
			this.labsSelected = [];
			$('#labSelect').modal('show');
			
		},
		insertVideo (editor) {
			this.activeEditor = editor;
			this.mediaSelected = [];
			this.eligibleVideoFiles = filevm.images.filter(f => /(.mp4|.ogg|.webm)$/g.test(f.filename))
			console.log(this.eligibleVideoFiles)
			if (this.eligibleVideoFiles == null || this.eligibleVideoFiles.length === 0) {
				alert('No compatible files uploaded, please upload mp4/ogg/webm files to this case in "Settings Upload Files (Optional)" section ');
				return;
			}
			$('#videoSelect').modal('show');
			
		},
		insertSelectedVideo(file) {
			$('#videoSelect').modal('hide');
			let h = `
			<div class="video">
				<video loop controls>
				    <source src="../image?getfile=${file.filename}">
				</video>
				${this.videoIncludeCaption?'<div class="videoCaption">Insert caption here</div>':''}
			</div>`
			this.activeEditor.insertContent(h);
		},
		getRandomInRange (min, max, decimals) {
			if (decimals == null) decimals = 0;
			if (min == null || max == null) return ' ';
			return (Math.random() * (max - min) + min).toFixed(decimals);
		},
		insertSelectedLabs () {
			$('#labSelect').modal('hide');
		    //let insertHtml = tableHtml = "<table style=\"width: 370px; height: 597px;\" border=\"1\">\n<tbody>\n<tr style=\"height: 25px;\">\n<th style=\"height: 25px; width: 184px;\">Investigations</th>\n<th style=\"height: 25px; width: 88px;\">Value</th>\n<th style=\"height: 25px; width: 98px;\">Unit</th>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"height: 26px; width: 184px;\">Hemoglobin</td>\n<td style=\"text-align: center; height: 26px; width: 88px;\">140</td>\n<td style=\"height: 26px; width: 98px;\">g/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">MCV</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">85</td>\n<td style=\"width: 98px; height: 26px;\">fL</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"height: 26px; width: 184px;\">WBC</td>\n<td style=\"height: 26px; width: 88px; text-align: center;\">14.5</td>\n<td style=\"height: 26px; width: 98px;\">x10<sup>9</sup>/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">&nbsp; Neutrophils</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">4.5</td>\n<td style=\"width: 98px; height: 26px;\">x10<span style=\"font-size: 10.5px; line-height: 0; position: relative; vertical-align: baseline; top: -0.5em; letter-spacing: 0.1px;\">9</span><span style=\"letter-spacing: 0.1px;\">/L</span></td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">&nbsp; Lymphocytes</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">2.1</td>\n<td style=\"width: 98px; height: 26px;\">x10<span style=\"font-size: 10.5px; line-height: 0; position: relative; vertical-align: baseline; top: -0.5em; letter-spacing: 0.1px;\">9</span><span style=\"letter-spacing: 0.1px;\">/L</span></td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Platelets</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">280</td>\n<td style=\"width: 98px; height: 26px;\">x10<span style=\"font-size: 10.5px; line-height: 0; position: relative; vertical-align: baseline; top: -0.5em; letter-spacing: 0.1px;\">9</span><span style=\"letter-spacing: 0.1px;\">/L</span></td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Na+</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">138</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Cl-</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">107</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">K+</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">4.1</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">HCO3</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">24</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Creatinine</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">68</td>\n<td style=\"width: 98px; height: 26px;\">umol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Mg++</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">0.81</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Ca++</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">2.3</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">PO4</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">1.2</td>\n<td style=\"width: 98px; height: 26px;\">mmol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Albumin</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">38</td>\n<td style=\"width: 98px; height: 26px;\">g/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">AST</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">35</td>\n<td style=\"width: 98px; height: 26px;\">IU/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">ALT</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">28</td>\n<td style=\"width: 98px; height: 26px;\">IU/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">ALP</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">82</td>\n<td style=\"width: 98px; height: 26px;\">IU/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">Total Bilirubin</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">8</td>\n<td style=\"width: 98px; height: 26px;\">umol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">&nbsp; Conjugated Bilirubin</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">3</td>\n<td style=\"width: 98px; height: 26px;\">umol/L</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">INR</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">1.1</td>\n<td style=\"width: 98px; height: 26px;\">&nbsp;</td>\n</tr>\n<tr style=\"height: 26px;\">\n<td style=\"width: 184px; height: 26px;\">TSH</td>\n<td style=\"text-align: center; width: 88px; height: 26px;\">2.1</td>\n<td style=\"width: 98px; height: 26px;\">mIU/L</td>\n</tr>\n</tbody>\n</table>";
			let h = '<table style="width: 370px;" border="1">'
				+ '<tbody>'
				+ '<tr style="height: 25px;">'
				+ '<th style="height: 25px; width: 184px;">Investigations</th>'
				+ '<th style="height: 25px; width: 88px;">Value</th>' 
				+ '<th style="height: 25px; width: 98px;">Unit</th>'
				+ '</tr>';
			
			this.labsSelected.forEach(l => {
				l.items.forEach(item => {
					h = h + '<tr style="height: 26px;">'
					+ '<td style="height: 26px; width: 184px;">' + item.label.replace(/ /g, '&nbsp;') + '</td>'
					+ '<td style="text-align: center; height: 26px; width: 88px;">' + this.getRandomInRange(item.min, item.max, item.decimals) + '</td>'
					+ '<td style="height: 26px; width: 98px; text-align: center;">' + item.unit + '</td>'
					+ '</tr>'
				});
			});
			
			h = h + '</tbody>'
			h = h + '</table>'
			this.activeEditor.insertContent(h);
		},
		answerOptionCSS: function(wrapper) {
				if (wrapper.scoreModifier<0) return 'incorrect';
				if (wrapper.primaryAnswer) return 'primary';
				if (!wrapper.primaryAnswer) return 'secondary';
				//if (choice.or) return 'optional';
		},
		editDefaultScore: function(wrapper, scorePrimary=1, scoreSecondary=0.25) {
  				if (!wrapper.primaryAnswer) wrapper.scoreModifier=scorePrimary;
  				else wrapper.scoreModifier=scoreSecondary;
  		},
  		moveUp: function(question, line, wrapper) {
  			if (line.associatedAnswerWrappers.length === 1 || line.associatedAnswerWrappers.indexOf(wrapper) === 0) {
  				let i = question.associatedAnswerLines.indexOf(line)
  				question.associatedAnswerLines.splice(i, 1)
  				question.associatedAnswerLines.splice(i-1, 0, line)
  			} else {
  				let wi = line.associatedAnswerWrappers.indexOf(wrapper)
  				line.associatedAnswerWrappers.splice(wi, 1);
  				line.associatedAnswerWrappers.splice(wi-1, 0, wrapper)
  			}
  			this.clearIds(question) // allow order to re-save
  		},
  		moveDown: function(question, line, wrapper) {
  			if (line.associatedAnswerWrappers.length === 1 || line.associatedAnswerWrappers.indexOf(wrapper) === 0) {
  				let i = question.associatedAnswerLines.indexOf(line)
  				question.associatedAnswerLines.splice(i, 1)
  				question.associatedAnswerLines.splice(i+1, 0, line)
  			} else {
  				let wi = line.associatedAnswerWrappers.indexOf(wrapper)
  				line.associatedAnswerWrappers.splice(wi, 1);
  				line.associatedAnswerWrappers.splice(wi+1, 0, wrapper)
  			}
  			this.clearIds(question) // allow order to re-save
  		},
  		clearIds (question) {
  			if (question.associatedAnswerLines) {
  				question.associatedAnswerLines.forEach(l => {
  					l.lineId = undefined
  					l.associatedAnswerWrappers.forEach(w => {
  						w.wrapperId = undefined
  					})
  				})
  			}
  		},
  		sgCalculatePassScore (question) {
  			let passScore = 0
  			question.associatedAnswerLines.forEach(l => {
  				let highestScoreInLine = 0
  				l.associatedAnswerWrappers.forEach(w => {
  						if (w.scoreModifier > highestScoreInLine) highestScoreInLine = w.scoreModifier
  				})
  				passScore += highestScoreInLine
  			})
  			question.passScore = passScore
  		},
  		addSGLine: function (question) {
			  question.associatedAnswerLines.push(
				  {
					  scoreModifier: 1,
					  scoreMissed: 0,
					  primaryAnswer: true,
					  correctAnswer: true,
					  associatedAnswerWrappers: []
				  }
			  )
		},
		addSGChoice: function (question) {
			this.workingQuestion = question
			this.workingLine = null
	   		parent.launchSearchTextModal('sgInsertAnswer');  	   	 	
		},
		addSGChoice: function (question, line) {
			this.workingQuestion = question
			this.workingLine = line
	   		parent.launchSearchTextModal('sgInsertAnswer');  	   	 	
		},
		insertAnswerChoices: function (selectedItems, itemGroup) {
				
  				for (var i=0; i<selectedItems.length; i++) {
  					//default settings
  					if (this.workingLine != null) {
						 this.workingLine.associatedAnswerWrappers.push(
	  										{
	  											scoreModifier: 0,
	  											scoreMissed: 0,
	  											or: false,
	  											primaryAnswer: true,
	  											correctAnswer: true,
	  											searchTerm: {
	  												searchTermId: selectedItems[i].searchTermId,
	  												searchTermString: selectedItems[i].searchTermString
	  											}
	  										}
	  					)
					} else {
	  					this.workingQuestion.associatedAnswerLines.push(
	  								{
	  									associatedAnswerWrappers: [
	  										{
	  											scoreModifier: 1,
	  											scoreMissed: 0,
	  											or: false,
	  											primaryAnswer: true,
	  											correctAnswer: true,
	  											searchTerm: {
	  												searchTermId: selectedItems[i].searchTermId,
	  												searchTermString: selectedItems[i].searchTermString
	  											}
	  										}
	  									]
	  								}
	  					)
	  				}
  				}
  				this.addGroupIfNotExist(this.workingQuestion, itemGroup);
  				// console.log(this.workingQuestion)
  		},
		addGroupIfNotExist: function (question, group) {
			if (question.availableGroupsText != null) {
  				var groupsA = question.availableGroupsText.split(",");
  				var found = false;
  				for (var i=0; i<groupsA.length; i++) {
  					if (groupsA[i].trim() == group) found = true;
  				}
  				if (!found) {
  					if (question.availableGroupsText != null && question.availableGroupsText.length != 0) question.availableGroupsText += ", ";
  					else question.availableGroupsText = ''
  					question.availableGroupsText += group;
  				}
			} else { question.availableGroupsText = group }
  		},
  		removeSGChoice: function (question, lineI, wrapperI) {
			if (wrapperI != null) {
	  			question.associatedAnswerLines[lineI].associatedAnswerWrappers.splice(wrapperI, 1);
	  			if (question.associatedAnswerLines[lineI].associatedAnswerWrappers.length == 0) {
	  				question.associatedAnswerLines.splice(lineI, 1);
	  			}
	  		} else {
				  question.associatedAnswerLines.splice(lineI, 1);
			  }
		},
		sgMakeOr: function (question, wrapper, or) {
			// console.log("or : " + or)
			for (let i=0; i< question.associatedAnswerLines.length; i++) {
				let l = question.associatedAnswerLines[i]
				for (let ii=0; ii< l.associatedAnswerWrappers.length; ii++) {
					let w = l.associatedAnswerWrappers[ii]
					if (w.wrapperId === wrapper.wrapperId) {
						if (!or) {
							question.associatedAnswerLines[i-1].associatedAnswerWrappers.push(w)
							l.associatedAnswerWrappers.splice(ii, 1)
							// clear empties
							if (l.associatedAnswerWrappers.length === 0) question.associatedAnswerLines.splice(i, 1)
						} else {
							if (question.associatedAnswerLines.length > i+1) {
								question.associatedAnswerLines[i+1].associatedAnswerWrappers.push(w)
							} else {
								question.associatedAnswerLines.push({associatedAnswerWrappers: [w]})
							}
							l.associatedAnswerWrappers.splice(ii, 1)
							if (l.associatedAnswerWrappers.length === 0) question.associatedAnswerLines.splice(i, 1)
						}
						w.wrapperId = undefined // need this otherwise hibernate gets confused (tries to delete and save)
					}
				}
			}
			// console.log(question)
		}
	}
})
function insertAnswerChoices(selectedItems, group) { //called by editExercise.jsp, just ports the call to Vue
	   app.insertAnswerChoices(selectedItems, group)
}

        