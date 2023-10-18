<!DOCTYPE html>

    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Bootstrap 101 Template</title>

    <!-- Bootstrap -->
    <link href="<c:url value="/css/lib/bootstrap.paper.min.css"/>" rel="stylesheet">

    <link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.min.css">
    <link rel="stylesheet" type="text/css" href="../jslib/jquery-ui-1.12.1/jquery-ui.theme.min.css">
    
    <link href="<c:url value="/css/admin/searchterm.css"/>" rel="stylesheet">


    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>
  <nav class="navbar navbar-inverse">
  <div class="container-fluid">
    <div class="navbar-header">
      <div class="navbar-brand">Group Select:</div>
    </div>

    <div>
      <div class="navbar-nav">
      <ul class="navbar-form">
        <li class="dropdown" style="list-style: none;">
          <a href="#" class="dropdown-toggle btn btn-default" data-toggle="dropdown" role="button" aria-expanded="false">

          		<c:if test="${not empty requestScope.selectedGroup}">
          			<c:out value="${requestScope.selectedGroup.groupName }"/>
          		</c:if>
          		<c:if test="${not empty sessionScope.orphanedSTs}">
          			Items Without Group
          		</c:if>
          		<c:if test="${empty requestScope.selectedGroup && empty sessionScope.orphanedSTs }">
          			Select Group
          		</c:if>
          		
          		<span class="caret"></span></a>
          		<button class="btn btn-default"<c:if test="${empty requestScope.selectedGroup}"> disabled="true"</c:if> 
          		data-group-id="<c:out value="${requestScope.selectedGroup.groupId }"/>" 
          		data-group-name="<c:out value="${requestScope.selectedGroup.groupName }"/>" 
          		data-toggle="modal" data-target="#confirm-edit">
    				<span class="glyphicon glyphicon-pencil" aria-hidden="true"></span>
				</button>
          		<button class="btn btn-danger"<c:if test="${empty requestScope.selectedGroup}"> disabled="true"</c:if> 
          		data-href="searchterm.do?method=deleteGroup&groupid=<c:out value="${requestScope.selectedGroup.groupId }"/>" 
          		data-group-name="<c:out value="${requestScope.selectedGroup.groupName }"/>" 
          		data-toggle="modal" data-target="#confirm-delete">
    				<span class="glyphicon glyphicon-trash" aria-hidden="true"></span>
				</button>
          <ul class="dropdown-menu" role="menu">
          	<c:forEach var="searchGroup" items="${requestScope.searchGroups}">
            <li><a href="searchterm.do?method=showGroup&viewgroupid=<c:out value="${searchGroup.groupId}"/>"><c:out value="${searchGroup.groupName }"/></a></li>
            </c:forEach>
            <li class="divider"></li>
            <li><a href="searchterm.do?method=showOrphanedST">Items Without Group</a></li>
          </ul>
        </li>
      </ul></div>
      <div class="navbar-brand" style="margin-left: 10px; margin-right: 10px;">OR</div>
      <form action="searchterm.do" class="navbar-form navbar-left" role="search">
        <div class="form-group">
            <input type="text" name="groupName" class="form-control" placeholder="New Group Name">
            <input type="hidden" name="method" value="addGroup">
        </div>
        <button type="submit" class="btn btn-default">Add Group</button>
      </form>
      <ul class="nav navbar-nav navbar-right">
        <li><a href="#">Link</a></li>
      </ul>
    </div>
  </div>
</nav>
  
  <!-- END NAVBAR CONTENT -->
  
  
  <c:if test="${not empty requestScope.message}">
  	<div class="alert alert-warning alert-dismissable alertShorter" role="alert">
  		<a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
					<c:out value="${requestScope.message }"/>
	</div>
  </c:if>
  
  
  
  
  <!--  BEGIN GROUP MANAGEMENT -->
  
    <div class="container">
  	<c:if test="${not empty requestScope.selectedGroup }">
	  	<div class="row masonry-container">
		    <c:forEach var="section" items="${requestScope.selectedGroup.associatedSections}">
		    	<div class="item sectionItem">
			    	<div class="panel panel-success">
			  			<div class="panel-heading">
			    			<h3 class="panel-title">
			    				<c:out value="${section.sectionName }"/>
			    				<div class="pull-right">
			    					<a data-href="searchterm.do?method=editSection" data-section-id="<c:out value="${section.sectionId}"/>" data-section-name="<c:out value="${section.sectionName}"/>" data-toggle="modal" data-target="#editSection">	
	 									<span class="glyphicon glyphicon-pencil sectionTrash" aria-hidden="true"></span>&nbsp;
	 								</a>
	 								<a data-href="searchterm.do?method=deleteSection&sectionid=<c:out value="${section.sectionId}"/>" data-section-name="<c:out value="${section.sectionName}"/>" data-toggle="modal" data-target="#confirmDeleteSection">	
	 									<span class="glyphicon glyphicon-trash sectionTrash" aria-hidden="true"></span>
	 								</a>
								</div>
			    			</h3>
			  			</div>
			  			<div class="panel-body" style="white-space: nowrap;">
			    			<c:forEach var="searchterm" items="${section.associatedSearchTerms }">
				    				<button
				    					class="btn btn-primary btn-xs searchTermItem"
				    					onclick="selectItem(this, '<c:out value="${searchterm.searchTermString }"/>', <c:out value="${searchterm.searchTermId }"/>)">
				    					<c:out value="${searchterm.searchTermString }"/>
			    					</button>
		 						(${fn:length(searchterm.associatedWrappers)})
		 							<a href="#"
				    					data-toggle="modal"
				    					data-target="#editItem"
				    					data-item-name="<c:out value="${searchterm.searchTermString }"/>"
				    					data-item-id="<c:out value="${searchterm.searchTermId }"/>"
				    					data-item-keys="<c:out value="${searchterm.searchKeys }"/>">
		 									<span class="glyphicon glyphicon-cog sectionTrash termIcon" aria-hidden="true"></span>
		 							</a>
			    					<a href="searchterm.do?method=removeTerm&sectionid=<c:out value="${section.sectionId}"/>&searchtermid=<c:out value="${searchterm.searchTermId }"/>">	
		 									<span class="glyphicon glyphicon-log-out sectionTrash termIcon" aria-hidden="true"></span>
		 							</a>
		 							<br/>
			    			</c:forEach>
			    			<form action="searchterm.do">
			    				<input type="hidden" name="method" value="addTerm">
			    				<input type="hidden" name="sectionid" value="<c:out value="${section.sectionId }"/>">
			    				<div class="btn btn-primary btn-xs searchTermItemInput"><input type="text" class="form-control newTermInput nounderline" placeholder="&lt;New Item Name&gt;" name="termname"></div>
			    				<a href="#" onclick="addTerm(this)" class="btn btn-default btn-xs addTermButton">	
	 									<span class="glyphicon glyphicon-plus" aria-hidden="true"></span>
	 							</a>
	 						</form>
			  			</div>
					</div>
				</div>
		    </c:forEach>
		    
		    	<div class="item sectionItem">
			    	<div class="panel panel-warning">
			  			<div class="panel-heading form-group newSectionDiv">
			    			<h3 class="panel-title">
			    				<form action="searchterm.do" id="newSectionForm">
			    					<input type="hidden" name="method" value="addSection">
			    					<input type="text" class="form-control white-holder newSectionInput" name="sectionname" id="newSectionInput" placeholder="&lt;New Section Name&gt;">
			    				</form>
			    			</h3>
			  			</div>
			  			<div class="panel-body text-center">
			    			<a href="#" onclick="addSection()" class="btn btn-warning newSectionButton">Add Section</a>
			  			</div>
					</div>
				</div>
	    </div>
    </c:if>
    
    
    <c:if test="${not empty sessionScope.orphanedSTs }">
  			 <div class="item sectionItem">
	    	<div class="panel panel-warning">
	  			<div class="panel-heading form-group newSectionDiv" style="margin-bottom: 0px;">
	    			<h3 class="panel-title">
	    				Items Without a Group
	    			</h3>
	  			</div>
	  			<div class="panel-body" style="white-space: nowrap;">
	  				<c:forEach var="searchterm" items="${sessionScope.orphanedSTs}">
	   						<button
		    					class="btn btn-primary btn-xs searchTermItem">
		    					<c:out value="${searchterm.searchTermString }"/>
	    					</button>
	    					(${fn:length(searchterm.associatedWrappers)})
	    					<a href="#"
				    					data-toggle="modal"
				    					data-target="#editItem"
				    					data-item-name="<c:out value="${searchterm.searchTermString }"/>"
				    					data-item-id="<c:out value="${searchterm.searchTermId }"/>"
				    					data-item-keys="<c:out value="${searchterm.searchKeys }"/>">
		 									<span class="glyphicon glyphicon-cog sectionTrash termIcon" aria-hidden="true"></span>
		 					</a>
	    					<a href="searchterm.do?method=deleteTerm&searchtermid=<c:out value="${searchterm.searchTermId }"/>">	
										<span class="glyphicon glyphicon-trash sectionTrash" aria-hidden="true"></span>
							</a>
						<br/>
					</c:forEach>
	  			</div>
			</div>
		</div>
    </c:if>
    
    
    
    
    
    
    
    <!-- - IF GROUP NOT SELECTED -->
	<c:if test="${empty requestScope.selectedGroup && empty sessionScope.orphanedSTs}">
		<div class="alert alert-dismissible alert-success noGroupAlert" style="width: 90%; margin: 20px auto;">
 			<button type="button" class="close" data-dismiss="alert">&times;</button>
  			<h4 class="text-center">Please select a group at the top or make a new one</h4>
		</div>
	</c:if>
	
	
	
	
	
	
	
	
	
	
	
	
	

	<!--  DIALOGES.... -->
		
	<div class="modal fade" tabindex="-1" role="dialog" id="confirm-edit" aria-labelledby="edist">
	  <div class="modal-dialog modal-lg" role="document">
	    <div class="modal-content">
	      <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	        <h4 class="modal-title" id="myModalLabel">Edit Group</h4>
	      </div>
	      <div class="modal-body">
		  		<form action="searchterm.do" id="editGroupForm">
		  			<input type="hidden" name="groupid" id="groupIdP" value="">
		  			<input type="hidden" name="method" value="editGroup">
		  			<div class="form-group row">
      					<label for="groupNameP" class="col-xs-2 control-label" style="padding-top: 7px;font-size: 12px;">New Group Name</label>
      					<div class="col-xs-6">
        					<input type="text" class="form-control nounderline normalField" id="groupNameP" name="groupname" value="">
      					</div>
    				</div>
		  			
	     		</form>
	      </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
	        <button type="button" class="btn btn-primary" onclick="saveGroup(this)">Save</button>
	      </div>
	    </div>
	  </div>
	</div>
	
	<div class="modal fade" tabindex="-1" role="dialog" id="editItem" aria-labelledby="edist">
	  <div class="modal-dialog modal-lg" role="document">
	    <div class="modal-content">
	      <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	        <h4 class="modal-title" id="myModalLabel">Edit Item</h4>
	      </div>
	      <div class="modal-body">
		  		<form action="searchterm.do" class="form-horizontal" id="editItemForm">
		  			<input type="hidden" name="searchtermid" id="itemIdP" value="">
		  			<input type="hidden" name="method" value="editTerm">
		  			
		  			<div class="alert alert-dismissible alert-warning" id="errorAlert" style="display:none;">
 						<button type="button" class="close" data-dismiss="alert">&times;</button>
  						<span id="errorMsg" style="font-weight:bold;"></span>
					</div>

	  				<fieldset>
	    					<div class="form-group">
	      						<label for="itemNameP" class="col-lg-2 control-label">Item Name</label>
	      						<div class="col-lg-10">
	        						<input type="text" class="form-control highlightBackground" id="itemNameP" name="searchtermname" placeholder="Item Name">
	      						</div>
	    					</div>
	   						 <div class="form-group">
	      						<label for="itemKeysP" class="col-lg-2 control-label">Item Search Possibilities</label>
	      						<div class="col-lg-10">
	       						 <input type="text" class="form-control highlightBackground" name="searchtermkeys" id="itemKeysP" placeholder="&lt;None Entered&gt;">
	      						</div>
	    					</div>
	    			</fieldset>
 
	     		</form>
	      </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
	        <button type="button" class="btn btn-primary" onclick="saveItem(this)">Save</button>
	      </div>
	    </div>
	  </div>
	</div>
	
	
	<div class="modal fade" tabindex="-1" role="dialog" id="editSection" aria-labelledby="edist">
	  <div class="modal-dialog modal-lg" role="document">
	    <div class="modal-content">
	      <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	        <h4 class="modal-title" id="myModalLabel">Edit Section</h4>
	      </div>
	      <div class="modal-body">
		  		<form action="searchterm.do" id="editSectionForm">
		  			<input type="hidden" name="sectionid" id="sectionIdP" value="">
		  			<input type="hidden" name="method" value="editSection">
		  			<div class="form-group row">
      					<label for="sectionNameP" class="col-xs-2 control-label" style="padding-top: 7px;font-size: 12px;">New Section Name</label>
      					<div class="col-xs-6">
        					<input type="text" class="form-control nounderline normalField" id="sectionNameP" name="sectionname" value="">
      					</div>
    				</div>
		  			
	     		</form>
	      </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
	        <button type="button" class="btn btn-primary" onclick="saveSection(this)">Save</button>
	      </div>
	    </div>
	  </div>
	</div>
	
	<div class="modal fade" tabindex="-1" role="dialog" id="editst" aria-labelledby="edist">
	  <div class="modal-dialog modal-lg" role="document">
	    <div class="modal-content">
	      <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	        <h4 class="modal-title" id="myModalLabel">Edit Search Terms</h4>
	      </div>
	      <div class="modal-body">

	      </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
	        <button type="button" class="btn btn-primary">Save changes</button>
	      </div>
	    </div>
	  </div>
	</div>
	
	<div class="modal fade" id="confirmDeleteSection" tabindex="-1" role="dialog" aria-labelledby="sectionDeleteLabel" aria-hidden="true">
	    <div class="modal-dialog">
	        <div class="modal-content">
	            <div class="modal-header">
	                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
		        	<h4 class="modal-title" id="sectionDeleteLabel">Confirm Delete</h4>
	            </div>
	            <div class="modal-body">
	                Are you sure you want to delete the section titled '<span class="section-name-warning"></span>'?  <br/>
	                NOTE: All associated items under this section will remain under other sections or in "Items Without Group" category.
	            </div>
	            <div class="modal-footer">
	                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
	                <a class="btn btn-danger btn-ok">Delete</a>
	            </div>
	        </div>
	    </div>
	</div>
	
	<div class="modal fade" id="confirm-delete" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
	        	<h4 class="modal-title" id="myModalLabel">Confirm Delete</h4>
            </div>
            <div class="modal-body">
                Are you sure you want to delete group titled '<span class="group-name-warning"></span>'?  <br/>
                NOTE: All associated sections will also be deleted, but search terms will remain under "Items Without Group" if they aren't used anywhere else
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                <a class="btn btn-danger btn-ok">Delete</a>
            </div>
        </div>
    </div>
    

    
    
    <!-- 
   -->
	
	
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <!-- script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script-->
    <script src="<c:url value="/jslib/jquery-1.12.4.min.js"/>"></script>
    <script src="<c:url value="/jslib/jquery-ui-1.12.1.min.js"/>"></script>
	<!-- script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script-->
	<script type="text/javascript" src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/123941/masonry.js"></script>
	<script type="text/javascript" src="https://s3-us-west-2.amazonaws.com/s.cdpn.io/123941/imagesLoaded.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="<c:url value="/jslib/bootstrap.min.js"/>"></script>
    <script src="<c:url value="/jslib/autocomplete.js"/>"></script>
    
    <script type="text/javascript" language="JavaScript">
    $(function() {
    	$('#editst').modal({
	   		show: false
		 })
		 $('#confirmDeleteSection').on('show.bs.modal', function(e) {
				$(this).find('.section-name-warning').text($(e.relatedTarget).data('section-name'));
			    $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
		 });
			
		$('#confirm-delete').on('show.bs.modal', function(e) {
				$(this).find('.group-name-warning').text($(e.relatedTarget).data('group-name'));
			    $(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
		});
		
		$('#editSection').on('show.bs.modal', function(e) {
			$(this).find('#sectionNameP').val($(e.relatedTarget).data('section-name'));
			$(this).find('#sectionIdP').val($(e.relatedTarget).data('section-id'));
		    //$(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
		});
		$('#confirm-edit').on('show.bs.modal', function(e) {
			$(this).find('#groupNameP').val($(e.relatedTarget).data('group-name'));
			$(this).find('#groupIdP').val($(e.relatedTarget).data('group-id'));
		    //$(this).find('.btn-ok').attr('href', $(e.relatedTarget).data('href'));
		});
		$('#editItem').on('show.bs.modal', function(e) {
			$(this).find('#itemNameP').val($(e.relatedTarget).data('item-name'));
			$(this).find('#itemIdP').val($(e.relatedTarget).data('item-id'));
			$(this).find('#itemKeysP').val($(e.relatedTarget).data('item-keys'));
		});
		
		<c:if test="${not empty requestScope.errorSTmessage}">
			$('#editItem').modal('show');
			$(this).find('#errorAlert').show();
			$(this).find('#errorMsg').html('<c:out value="${requestScope.errorSTmessage}"/>')
			$(this).find('#itemNameP').val('<c:out value="${requestScope.errorSTname}"/>');
			$(this).find('#itemIdP').val('<c:out value="${requestScope.errorSTid}"/>');
			$(this).find('#itemKeysP').val('<c:out value="${requestScope.errorSTkeys}"/>');
		</c:if>
		
		var existingItems = [];
		<c:forEach var="item" items="${requestScope.availableSearchTerms}">
		existingItems.push("${item.searchTermString}" + " " + "${item.searchKeysBracketed}");
		</c:forEach>
		$(".newTermInput").each( function(i) {
			setAutocomplete($(this), existingItems, "New Item (No item with this name found");
		})
		
		
	});
		
	
    
    function addSection() {
			var val = $("#newSectionInput").val();
			if (val.length == 0) {
				alert("Please enter section name");
				return;
			}
			$('#newSectionForm').submit();
	}
    function addTerm(el) {
    	var form = $(el).closest("form");
    	var val = $(form).find('input[name=termname]').val();
    	if (val.length == 0) return;
    	$(form).submit();
    }
    function saveSection(el) {
    	var val = $("#sectionNameP").val();
		if (val.length == 0) {
			alert("Please enter section name");
			return;
		}
		$('#editSectionForm').submit();
    }
    function saveGroup(el) {
    	var val = $("#groupNameP").val();
		if (val.length == 0) {
			alert("Please enter group name");
			return;
		}
		$('#editGroupForm').submit();
    }
    function saveItem(el) {
    	var val = $("#itemNameP").val();
    	if (val.length == 0) {
    		alert("Please enter item name");
    		return;
    	}
    	$('#editItemForm').submit();
    }
    function insertSelectedSTs() { //old, used by editcasexml.jsp

    }
    
    function filterSelectedSTs() { //old, used by editexdercise.jsp (for filtering case list)
    	var output = '';
    	if (selectedItems.length == 0) {
    		alert("You must select items to insert");
    		return;
    	}
    	let selectedItemsPrepped = selectedItems.map(i => i.searchTermString)
    	parent.app.filterSelectECGDx(selectedItemsPrepped);
    	//selectedInput = parent.$("#filterForm").find("#selectedSTs");
    	//$(selectedInput).val(selectedItems.join("|"));
    	
    	//parent.$("#filterForm").submit();

    	//parent.$("#searchtextmodal").modal('toggle');
    }
    
    function getSelectedItems() { //NEW! preferred to use this
    	return selectedItems;
    }
    function getSelectedGroups() { //NEW! preferred to use this
    	return '<c:if test="${not empty requestScope.selectedGroup}"><c:out value="${requestScope.selectedGroup.groupName }"/></c:if>';
    }
    
    
    var selectedItems = [];
    function selectItem(ele, itemName, itemId) {
		  $(ele).toggleClass("selected");
		  var i = selectedItems.findIndex(i => {i.searchTermId === itemId});
		  if (i == -1) {
		  	selectedItems.push({searchTermId: itemId, searchTermString: itemName});
		  } else {
			selectedItems.splice(i, 1);
		  }
	}
    
    </script>
    
    <script type="text/javascript">

/* Demo Scripts for Making Twitter Bootstrap 3 Tab Play Nicely With The Masonry Library
* on SitePoint by Maria Antonietta Perna
*/

//Initialize Masonry inside Bootstrap 3 Tab component 

(function( $ ) {

  var $container = $('.masonry-container');
  $container.imagesLoaded( function () {
    $container.masonry({
      columnWidth: '.item',
      itemSelector: '.item'
    });
  });

  //Reinitialize masonry inside each panel after the relative tab link is clicked - 
  //not used here, but here if needed
  /*
  $('a[data-toggle=tab]').each(function () {
    var $this = $(this);

    $this.on('shown.bs.tab', function () {

      $container.imagesLoaded( function () {
        $container.masonry({
          columnWidth: '.item',
          itemSelector: '.item'
        });
      });

    }); //end shown
  });  //end each
*/
})(jQuery);


</script>
    </div>
  </body>
</html>