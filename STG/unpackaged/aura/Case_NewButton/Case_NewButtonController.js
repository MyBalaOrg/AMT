({
	doInit : function(component, event, helper) {
        var recordTypeId = "";
        var pageUrl = window.location.href;
        var pageUrlArray = pageUrl.split('recordTypeId=');
        try {
            pageUrlArray = pageUrlArray[1].split('&');
            recordTypeId = pageUrlArray[0];
        } catch (err) {
            console.log("User only has access to one record type.");
        }
        
		var action = component.get("c.verifyAppNameForCase_New");
        action.setParams({ "recordTypeId" : recordTypeId });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.verifyAppNameForCase_New " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
                } else {
                    component.set("v.errorMessage", "");
                    component.set("v.recordTypeName", returnValue.recordTypeName);
                    component.set("v.appName", returnValue.appName);
                    if (!$A.util.isEmpty(returnValue.recordTypeId)) {
                        recordTypeId = returnValue.recordTypeId;
                    }
                    component.set("v.recordTypeId", recordTypeId);
                    if (returnValue.appName != $A.get("$Label.c.App_Name_ODILR")) {
                        
                        var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "Case",
                            "defaultFieldValues": {
                                'RecordTypeId' : recordTypeId
                            }
                        });
                        createRecordEvent.fire();
                    }
                }
            } else {
                component.set("v.errorMessage", response.getError());
            }
        });
		$A.enqueueAction(action);
	}
})