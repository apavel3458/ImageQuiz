<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Portal Communication</title>
</head>
<body>
No body
<script type="text/javascript">
var data = "${sessionScope.errorMessage}";
function sendData() {
	parent.postMessage(data, "*");
/* 	var myCustomData = { foo: 'bar' }
	var event = new CustomEvent('portalMessage', { data })
	window.parent.document.dispatchEvent(event) */
}
sendData();
</script>
</body>
</html>