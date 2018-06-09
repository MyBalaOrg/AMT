({
    doInit: function(component) {
        var action = component.get("c.getObservation");
        action.setParams({
            "obsId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var returnedObservation = response.getReturnValue();
                component.set("v.showObsCloneDialog", returnedObservation.RevSysShowPopup__c);
            } else {
                amtrak.fireErrorToastEvent(component, "", response.getError());
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModal : function(component, event, helper) {
        helper.updateObsToNotShowCloneDlg(component);
        helper.closeModalHelper(component);
    },
    
    cloneObservation : function(component,event,helper){
        helper.updateObsToNotShowCloneDlg(component);
        helper.cloneObservation(component,event);
    }
})