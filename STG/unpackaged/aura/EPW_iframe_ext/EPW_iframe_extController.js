({
	doInit : function(component, event, helper) {
		
        var params = decodeURIComponent(window.location.search.substring(1)).split('&');
        for(var i = 0; i < params.length; i++) {
            if(params[i].indexOf('origin') != -1) {
                component.set("v.iframeUrl", params[i].substring(params[i].indexOf("origin=") + "origin=".length, params[i].length));
            } 
            
        }
	}
})