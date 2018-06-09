({
	doInit : function(component, event, helper) {
        var action = component.get("c.syncLineItemsFactorValue");
        action.setParams({ 
            "wasteId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.syncLineItemsFactorValue " + state);
            if (state === "SUCCESS") {
                var errorMessage = response.getReturnValue();
                if ($A.util.isEmpty(errorMessage)) {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                } else {
                    component.set("v.errorMessage", errorMessage);
                }
            } else {
                component.set("v.errorMessage", response.getError());
            }
        });
        $A.enqueueAction(action);
	}
})