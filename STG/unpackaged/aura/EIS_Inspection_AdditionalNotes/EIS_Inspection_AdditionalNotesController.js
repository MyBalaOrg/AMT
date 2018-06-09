({
	toggleDisplaySection : function(component, event, helper) {
        component.set("v.displaySection", !component.get("v.displaySection"));
    },
    
    onblurAdditionalNotes : function(component, event, helper) {
        var newNotes = event.target.value;
        var additionalNotes = component.get("v.additionalNotes")
        if (newNotes != additionalNotes && (!$A.util.isEmpty(newNotes) || !$A.util.isEmpty(additionalNotes))) {
            helper.fireToggleSpinnerEvent(component, false);
            var action = component.get("c.updateAdditionalNotes");
            action.setParams({
                "inspectionId" : component.get("v.inspectionId"),
                "additionalNotes" : newNotes
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log("c.updateAdditionalNotes " + state);
                if (state === "SUCCESS") {
                    component.set("v.additionalNotes", newNotes);
                } else {
                    console.log(response.getError());
                }
                helper.fireToggleSpinnerEvent(component, true);
            });
            $A.enqueueAction(action);
        }
    }
})