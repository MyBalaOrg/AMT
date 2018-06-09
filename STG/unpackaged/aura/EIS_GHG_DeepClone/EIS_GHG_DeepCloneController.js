({
	cloneTable : function(component, event, helper) {
        var startDate = component.find("start-date");
        var endDate = component.find("end-date");
        if (!$A.util.isEmpty(startDate) && !$A.util.isEmpty(endDate)) {
            startDate = startDate.get("v.value");
            endDate = endDate.get("v.value");
            if (!$A.util.isEmpty(startDate) && !$A.util.isEmpty(endDate)) {
                var action = component.get("c.deepCloneLogisticRecord");
                action.setParams({ 
                    "recordId" : component.get("v.recordId"),
                    "startDate" : startDate,
                    "endDate" : endDate
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log("c.deepCloneLogisticRecord " + state);
                    if (state === "SUCCESS") {
                        var returnValue = response.getReturnValue();
                        if ($A.util.isEmpty(returnValue.errorMsg)) {
                            var newRecordId = returnValue.factorId;
                            if (!$A.util.isEmpty(newRecordId)) {
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": newRecordId,
                                    "slideDevName": "Detail"
                                });
                                navEvt.fire();
                            }
                        } else {
                            component.set("v.errorMessage", returnValue.errorMsg);
                        }
                    } else {
                        component.set("v.errorMessage", response.getError());
                    }
                });
                $A.enqueueAction(action);
            }
        }
	}
})