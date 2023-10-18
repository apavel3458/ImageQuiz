<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html ng-app="demoApp">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script src="https://ajax.googleapis.com/ajax/libs/angularjs/1.5.6/angular.min.js"></script>
<script src="test.js"></script>
<title>Insert title here</title>
</head>
<body>
<div ng-controller="demoCtrl">Welcome {{txtName}}</div>
enter name: <input type="text" ng-model="txtName"/>
<br>

</body>
</html>