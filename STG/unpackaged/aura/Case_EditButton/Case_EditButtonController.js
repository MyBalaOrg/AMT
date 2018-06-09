({
	doInit : function(component, event, helper) {
        var action = component.get("c.verifyAppNameForCase_Edit");
        action.setParams({ "recordId" : component.get("v.recordId") });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.verifyAppNameForCase_Edit " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
                } else {
                    component.set("v.errorMessage", "");
                    component.set("v.appName", returnValue.appName);
                    if (returnValue.appName == "ODILR") {
                        helper.fireNavigateToEvent(component, component.get("v.recordId"), "detail");
                    }
                }
            } else {
                component.set("v.errorMessage", response.getError());
            }
        });
		$A.enqueueAction(action);
	},
    
    save : function(component, event, helper) {
        component.find("edit").get("e.recordSave").fire();
    },
    
    handleSaveSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully.",
            "type": "success"
        });
        toastEvent.fire();
        helper.fireNavigateToEvent(component, component.get("v.recordId"), "detail");
    },
    
    cancel : function(component, event, helper) {
        helper.fireNavigateToEvent(component, component.get("v.recordId"), "detail");
    }
})