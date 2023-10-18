<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<script src=""></script>

<%-- requires moment.js and vue.js --%>

<c:if test="${not empty requestScope.icase}">

<div id="authorList" class="fileListContainer">
<table class="fileTable" style="margin: 10px auto; min-width: 600px;">
	<tr>
		<th>Author</th>
		<th>Role</th>
		<th>Actions</th>
	</tr>
	<tr v-for="(author, index) in authorsFiltered" :key="index">
		<td class="alignLeft" v-bind:class="{highlightAuthor: author.role==='Author'}">
			{{author.author.firstName}} {{author.author.lastName}} [{{author.author.email}}]
		</td>
		<td class="alignLeft" v-bind:class="{highlightAuthor: author.role==='Author'}" style="text-align: center;">
			{{author.role}}
		<td style="white-space: nowrap;">
        	<button v-if="${security.isManagerCases() } || author.author.userId == ${security.userId}" class="btn btn-default btn-xs" @click="remove(author)">Remove</button>
        </td>
	</tr>
	<tr>
		<td>
			<button v-if="addUser" class="btn no-shadow btn-default btn-xs" style="background-color: aliceblue;">
				({{addUser.userId}}) {{addUser.firstName}} {{addUser.lastName}} [{{addUser.email}}]
			</button>
			<input v-model="search" v-if="!addUser" class="form-control" placeholder="Start Typing to Search..." size="40">
			<div class="authorSearchWindow" v-if="!addUser && options">
				<div v-for="option in options" :key="option.userid" @click="addUser = option">
					({{option.userId}}) {{option.firstName}} {{option.lastName}} {{"[" + option.username + "]"}} ({{option.email}})
				</div>
				<div v-if="options.length == 0"><i>No Search Results</i></div>
			</div>
		</td>
		<td>
			<select class="form-control no-shadow" v-model="role">
				<option value="Author">Author</option>
				<option value="Reviewer">Reviewer</option>
				<option value="Copy Editor">Copy Editor</option>
			</select>
		</td>
		<td>
			<input type="button" class="btn btn-xs btn-default" @click="add()" value="Add">
			<input type="button" class="btn btn-xs btn-default" @click="reset()" value="Clear">
		</td>
	</tr>
</table>

</div>


<script type="text/javascript" language="JavaScript">
//transfer from java to vueJS
imagesSrc = "";
var caseid = ${requestScope.icase.caseId};
var userName = '${sessionScope.security}';

var authorsApp = new Vue({
	el: "#authorList",
	data: {
		authors: [],
		role: 'Author',
		search: '',
		addUser: null,
		options: null,
		caseId: ${requestScope.icase.caseId}
	},
	computed: {
		authorsFiltered () {
			const sortOrder = {'Author': 1, 'Reviewer': 2, 'Copy Editor': 3}
			return this.authors.sort((a, b) => {
				return sortOrder[a.role] - sortOrder[b.role]
			})
		}
	},
	watch: {
		search: function(val) {
			if (val && val.length > 2) this.updateSearch()
		}
	},
	methods: {
		getData: function() {
			this.authors = [];
			$.ajax({
				url: "../admin/admin.do",
		        data: {
		            method: "authorsAjax",
		            calltype: "ajax",
		            action: "get",
		            caseid: this.caseId
		        },
		        type: "POST",
		        dataType: "html"
			}).done(data => {
				this.authors = JSON.parse(data);
			}).fail(function (xhr) {
				alert("ERROR: " + xhr.responseText);
			});
		},
		add: function () {
			if (!this.addUser || !this.role) return;
			$.ajax({
				url: "../admin/admin.do",
		        data: {
		            method: "authorsAjax",
		            action: "add",
		            calltype: "ajax",
		            userid: this.addUser.userId,
		            caseid: this.caseId,
		            exerciseid: exerciseId,
		            role: this.role
		        },
		        type: "POST",
		        dataType: "html"
			}).done(data => {
				let reply = JSON.parse(data);
				if (reply.authorId) {
					this.authors.push(reply);
					this.reset();
				}
			}).fail(function (xhr) {
				alert("ERROR: " + xhr.responseText);
			});
		},
		remove: function (author) {
			if (!author) return;
			$.ajax({
				url: "../admin/admin.do",
		        data: {
		            method: "authorsAjax",
		            action: "remove",
		            calltype: "ajax",
		            authorid: author.authorId
		        },
		        type: "POST",
		        dataType: "html"
			}).done(data => {
				let reply = JSON.parse(data)
				if (reply.success) this.authors.splice(this.authors.findIndex(a=>a.authorId===author.authorId), 1)
			}).fail(function (xhr) {
				alert("ERROR: " + xhr.responseText);
			});
		},
		reset: function () {
			this.addUser = null;
			this.search = null;
			this.options = null;
		},
		updateSearch: function () {
			$.ajax({
				url: "../admin/admin.do",
		        data: {
		            method: "authorsAjax",
		            action: "search",
		            calltype: "ajax",
		            query: this.search
		        },
		        type: "POST",
		        dataType: "html"
			}).done(data => {
				this.options = JSON.parse(data);
			}).fail(function (xhr) {
				alert("ERROR: " + xhr.responseText);
			});
		},
		pgtDebounce(func, delay) {
		      let debounceTimer;
		      return function() {
		        const context = this;
		        const args = arguments;
		        clearTimeout(debounceTimer);
		        debounceTimer = setTimeout(() => func.apply(context, args), delay);
		      };
		}
	},
	mounted() {
		this.getData(); //- currently load data from JSP, but if you want ajax, do this. (may need to set this later)
		this.updateSearch = this.pgtDebounce(this.updateSearch, 500);
	}
})


</script>
<style lang="text/css">

</style>

</c:if>