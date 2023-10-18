<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    <%@ page import="org.apache.commons.lang.StringEscapeUtils" %>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../css/lib/bootstrap.paper.min.css">
<link rel="stylesheet" href="css/editcase.css">
<link rel="stylesheet" href="css/casehx.css?v=1">
		<!-- To make editor feel like the real thing -->
    	<link rel="stylesheet" href="../css/case/casedisplay.css">


<script src="../jslib/moment.min.js"></script>
<script src="js/vue.js"></script>
</head>
<body>
<div id="revisionHistoryContainer">

<div id="revisionList" v-show="!detailView">
	<table class="fileTable">
		<tr>
			<th>ID</th>
			<th>Role</th>
			<th>Contribution</th>
			<th>Date Created</th>
			<th>Created By</th>
			<th>&nbsp;</th>
		</tr>
		<tr class="clickable"
			v-for="(revision, index in revisionsSorted" 
			:key="revision.revisionId" 
			v-bind:class="[index%2==0?'even':'odd']"
			v-on:click.prevent="viewRevision(revision.revisionId)">
			<td>{{revision.revisionId}}</td>
			<td>{{revision.role}}</td>
			<td>{{revision.contributionWeight}}</td>
			<td>{{formatDate(revision.datetime)}}</td>
			<td>{{revision.author}}</td>
			<td style="white-space: nowrap;">&nbsp;
	        </td>
		</tr>
	</table>
</div>
<div id="revisionDetail" class="revisionDetailContainer" v-if="detailView">
	<button class="btn btn-default btn-sm" v-on:click.prevent="viewList()">&lt; Back To Revision List</button>
	<revision-detail v-bind:revision="detailRevision"></revision-detail>
</div>


</div>

</body>
<script type="text/javascript" language="JavaScript">

var revisionsRaw = ${requestScope.revisions};

var vm = new Vue({
	el: "#revisionHistoryContainer",
	data: {
		revisions: [],
		detailView: false,
		detailRevision: {}
	},
	watched: {

		
	},
	computed: {
		revisionsSorted: function() {
				var newList = this.revisions.sort(function (a, b) {
					
					//alert(moment(b.createdDate).format('X')-moment(a.createdDate).format('X'));
					 return moment(b.datetime, "YYYY-MM-DDTHH:mm:ss")-moment(a.datetime, "YYYY-MM-DDTHH:mm:ss");
				});
				return newList;
		}
	},
	methods: {
		formatDate: function(mydate) {
			return moment(mydate).format("MMM D, YYYY");
		},
		getData: function() {
			//alert(revisionsRaw);
			this.revisions = revisionsRaw;
			//this.revisions = JSON.parse(revisionsRaw);
			
		},
		viewRevision(id) {
			this.detailView = true;
			for (var i=0; i < this.revisions.length; i++) {
		        if (this.revisions[i].revisionId === id) {
		            this.detailRevision = this.revisions[i];
		            break;
		        }
		    }
		},
		viewList() {
			this.detailView = false;
			
			this.detailRevision = null;
		}
	},
	mounted() {
		this.getData(); //get data from above
	}
});

Vue.component('revision-detail', {
	  props: ['revision'],
	  methods: {
		  unescapeJSON: function(val) {
			  return JSON.parse(val);
		  },
		  unescapeHtml: function(val) {
				  var e = document.createElement('div');
				  e.innerHTML = val;
				  // handle case of empty input
				  return e.childNodes.length === 0 ? "" : e.childNodes[0].nodeValue;
		  },
		  unescapeAll: function(val) {
			  var result;
			  result = this.unescapeJSON(val);
			  //alert(result);
			  result = this.unescapeHtml(result);
			  
			  return result;
		  }
	  },
	  template: `
	  	<div class="caseText" v-html="unescapeAll(revision.caseXmlDiff)"></div>
	  	`
	});
</script>
</html>