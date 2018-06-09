({
	onclickTabs : function(component, event, helper) {
		var value = event.target.value;
        if (!$A.util.isEmpty(value)) {
            component.set("v.tabName", value);
        }
	},
    
    handleToggleLightningSpinner : function(component, event, helper) {
        event.stopPropagation();
        var spinner = component.find("audit-loading");
        var hideSpinner = event.getParam("value");
        if (hideSpinner) {
            if (!$A.util.hasClass(spinner, "slds-hide")) {
                 $A.util.addClass(spinner, "slds-hide");
            }
        } else {
            $A.util.removeClass(spinner, "slds-hide");
        }
    },
    
    handleHeaderButtonClicked : function(component, event, helper) {
        event.stopPropagation();
        var bodyCmp = component.find(component.get("v.tabName") + "-body");
        if (!$A.util.isEmpty(bodyCmp)) {
            var newSubmitStatus = event.getParam("origin");
        	var rejectionNote = event.getParam("description");
            bodyCmp.handleSubmissionStatus(newSubmitStatus, rejectionNote);
        }
    }
})