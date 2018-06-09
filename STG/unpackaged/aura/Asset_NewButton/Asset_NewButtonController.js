({
	doInit : function(component, event, helper) {
        var recordTypeId = "";
        var pageUrl = window.location.href;
        var pageUrlArray = pageUrl.split('recordTypeId=');
        console.log(' $$ Page '+pageUrlArray);
        try {
            pageUrlArray = pageUrlArray[1].split('&');
            recordTypeId = pageUrlArray[0];
            debugger;
        } catch (err) {
            console.log("User only has access to one record type.");
        }
        
		var action = component.get("c.verifyAppNameForAsset_New");
        action.setParams({ "recordTypeId" : recordTypeId });
          console.log(' $$ recordTypeId '+recordTypeId);
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.verifyAppNameForAsset_New " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(' $$ returnValue.errorMsg '+returnValue);
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    
                     console.log(' $$ returnValue.errorMsg '+returnValue.errorMsg);
                    
                    component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
                } else {
                    component.set("v.errorMessage", "");
                    component.set("v.recordTypeName", returnValue.recordTypeName);
                    component.set("v.appName", returnValue.appName);
                    component.set("v.recordTypeId",returnValue.recordTypeId);
                    console.log('returnValue.appName'+returnValue.appName);
                    console.log('returnValue.recordTypeName'+returnValue.recordTypeName);
                    console.log('returnValue.recordTypeId'+returnValue.recordTypeId);
                    if (!$A.util.isEmpty(returnValue.recordTypeId)) {
                        recordTypeId = returnValue.recordTypeId;
                    }
                    component.set("v.recordTypeId", recordTypeId);
                    if (returnValue.appName != $A.get("$Label.c.App_Name_PTC")) {
                        console.log('===in create');
                        var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "Asset"
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