function popitup(url, width, height) {
	newwindow=window.open(url,'name','height=' + height +',width=' + width);
	if (window.focus) {newwindow.focus()}
	return false;
}

function popitup(url, iname, width, height) {
	newwindow=window.open(url,iname,'height=' + height +',width=' + width);
	if (window.focus) {newwindow.focus()}
	return false;
}

function popupReference(url) {
	refwindow=window.open(url,'refwindow','height=500,width=900');
	
	refwindow.onload = function () {
		//refwindow.scrollTo(200, 5);
		refwindow.hide_navbar();
    };
	if (window.focus) {newwindow.focus()}
	return false;
}

function closeAndRefresh() {
	opener.location.reload(); // or opener.location.href = opener.location.href;
	window.close(); // or self.close();
}