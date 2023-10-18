/**
 * 
 */

function Objective (obj) {
	this.objectiveId = "";
    this.objectiveCode = "";
    this.objectiveName = "";
    this.hidden = false;
    this.selected = false;
    this.contains = false;
    this.orphan = false;
    for (var prop in obj) this[prop] = obj[prop];
}

Objective.prototype.level = function() {
	return (this.objectiveCode.split(".").length); //3
};

Objective.prototype.indent = function() {
	let lvl = this.level();
	lvl = lvl-3;
	return lvl*20;
};

Objective.hideAboveLevel = function(objs, lvl) {
	for (var i=0; i<objs.length; i++) {
		var obj = objs[i];
		if (obj.level() > lvl) {
			obj.hidden = true;
		} else {
			obj.hidden = false;
		}
	}
};

Objective.prototype.openParents = function(os) {
	let parentCode = this.objectiveCode;
	for (let i=0; i<this.level(); i++) {
		//alert(parentCode);
		parentCode = parentCode.substring(0, parentCode.lastIndexOf("."));
		let found = Objective.findByCode(os, parentCode);
		if (found != null)
			found.hidden = false;
	}
};

Objective.prototype.getParents = function(os) {
	let foundArray = Array();
	let parentCode = this.objectiveCode;
	for (let i=0; i< this.level(); i++) {
		parentCode = parentCode.substring(0, parentCode.lastIndexOf("."));
		let found = Objective.findByCode(os, parentCode);
		if (found != null)
			foundArray.push(found);
	}
	return foundArray;
}

Objective.findByCode = function(os, query) {
	for (let z=0; z<os.length; z++) {
		let o = os[z];
		if (o.objectiveCode == query) {
			return o;
		}
	}
	return null;
}

Objective.findById = function(os, query) {
	//alert(os[3].objectiveId);
	for (let z=0; z<os.length; z++) {
		let o = os[z];
		if (o.objectiveId == query) {
			return o;
		}
	}
	return null;
}

Objective.sortObjectives = function(os) {
		os.sort(function(a, b){
			let aNumbers = a.objectiveCode.split(".");
			let bNumbers = b.objectiveCode.split(".");
			//alert("RUN LOOP");
			for (var i=0; i< aNumbers.length; i++) { //ignore last one, it's empty 1.2.3.
				let aC = Number(aNumbers[i]);
				let bC = Number(bNumbers[i]);
				if (aC > bC) return 1;
				else if (aC < bC) return -1;
				
				if (i+1 == bNumbers.length) { //last bNumber
					return 1;
				}
				if (i+1 == aNumbers.length) { //last aNumber
					return -1;
				}
				
			}
		});
		return os;
}

Objective.countContained = function(objectives, displayLevel) {
	//let highestLevel = 0;
	let highestLevel = displayLevel;
	//determine highest level of objectives (to find orphaned)
	
	for (var i=0; i< objectives.length; i++) {
		//alert(i);
		let o = objectives[i];
		//determine if has children
		if (i != objectives.length-1 
				&& objectives[i+1].objectiveCode.startsWith(o.objectiveCode)) {
			o.contains = true;
		}
		//determine of orphanj
		//alert(i + " " + o.objectiveCode);
		if (o.level() > highestLevel) {
			let parentCode = o.objectiveCode.substring(0, o.objectiveCode.lastIndexOf("."));
			//alert(parentCode);
			if (i==0) {
				o.orphan = true;
			} else if (!objectives[i-1].objectiveCode.startsWith(parentCode)) {
				o.orphan = true; // is previous item a parent?
				//alert("orphan found" + o.objectiveCode);
			} else {
				o.orphan = false;
			}
		}
		
	}
}
