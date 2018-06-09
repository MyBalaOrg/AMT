({
    closeDialog : function(component) {
        window.history.back();
	},
    
    doInit : function(component) {
        var action = component.get("c.getApplications");
        action.setParams({ applicationType : component.get("v.applicationType") });
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() == "SUCCESS" && response.getReturnValue() != null) {
                component.set("v.applications", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})