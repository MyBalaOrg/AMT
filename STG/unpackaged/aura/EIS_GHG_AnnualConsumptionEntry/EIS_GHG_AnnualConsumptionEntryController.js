({
	doInit : function(component, event, helper) {
		var action = component.get("c.getLineItemGroupList");
        action.setParams({ 
            "wasteId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.getLineItemGroupList " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue)) {
                    component.set("v.ligList", JSON.parse(returnValue));
                }
            } else {
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
	},
    
    onchangeSelectLineItemGroup : function(component, event, helper) {
        event.stopPropagation();
        var selectedKey = component.get("v.selectedKey");
        if ($A.util.isEmpty(selectedKey)) {
            component.set("v.selectedLig", null);
        } else {
            var ligList = component.get("v.ligList");
            ligList.forEach(function(lig) {
                if (lig.identifier === selectedKey) {
                    component.set("v.selectedLig", lig);
                    return;
                }
            });
        }
    },
    
    onclickSubmitConsumption : function(component, event, helper) {
        var selectedLig = component.get("v.selectedLig");
        if ($A.util.isEmpty(selectedLig.consumptionValue) && $A.util.isEmpty(selectedLig.conversionFactor) && $A.util.isEmpty(selectedLig.calculatedUMO)) {
            component.set("v.errorMessage", "Please provide data for at least one input field.");
        } else {
            var action = component.get("c.updateLineItemAnnualConsumption");
            action.setParams({ 
                "selectedLigJSON" : JSON.stringify(selectedLig)
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("c.updateLineItemAnnualConsumption " + state);
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
    }
})