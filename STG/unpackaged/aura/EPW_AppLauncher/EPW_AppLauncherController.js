({
	closeDialog : function(component, event, helper) {
		helper.closeDialog(component);
	},
    
    doInit : function(component, event, helper) {
        helper.doInit(component);
    },
    
    navigateToApplication : function(component, event, helper) {
        if(event.currentTarget.dataset.type.toUpperCase() == "TABSET") {
            var applicationId = event.currentTarget.dataset.applicationid,
                staticPartialUrl = '/home/home.jsp?tsid=',
                domainUrl = component.get("v.domainUrl");
            var url = domainUrl + staticPartialUrl + applicationId
            window.open(url, "_blank");
        } else {
            window.open(event.currentTarget.dataset.url, "_blank");
        }
    }
})