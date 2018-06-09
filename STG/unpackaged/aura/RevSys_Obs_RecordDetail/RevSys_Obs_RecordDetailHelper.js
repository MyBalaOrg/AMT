({
    cloneObservationHelper : function(component, event){
        var action = component.get("c.getObservation");
        action.setParams({
            "obsId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var returnedObservation = response.getReturnValue();
                returnedObservation.Id = null;
                returnedObservation.Status__c = $A.get("$Label.c.RevSys_Observation_Status_Draft");
               	//returnedObservation.Status__c = null;
                this.closeModalHelper(component);
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Observation__c",
                    "defaultFieldValues": returnedObservation
                });
                createRecordEvent.fire();
            } else {
                amtrak.fireErrorToastEvent(component, "", response.getError());
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    
    doInit : function(component) {
        var action = component.get('c.initializeObservationDetailPage');
        var params = {'obsId': component.get("v.recordId")};
        action.setParams({ "params" : params });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("c.initializeObservationDetailPage " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    if (!$A.util.isEmpty(returnValue.obs)) {
                        component.set("v.obs", JSON.parse(returnValue.obs));
                    }
                    if (!$A.util.isEmpty(returnValue.findingList)) {
                        component.set("v.findingList", JSON.parse(returnValue.findingList));
                        console.log(JSON.parse(returnValue.findingList));
                    }
                    if (!$A.util.isEmpty(returnValue.scoreListString)) {
                        var scoreList = returnValue.scoreListString.split(',');
                        component.set("v.scoreList", scoreList);
                    }
                } else {
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                    console.log(returnValue.consolelog); 
                }
            } else {
                amtrak.fireErrorToastEvent(component, "", response.getError());
                console.log(response.getError());
            }
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        $A.enqueueAction(action);
    },
    
    showObservationCloneDialog : function(component) {
        var action= component.get('c.getObservation');
        debugger;
        action.setParams({ "obsId" : component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state=='SUCCESS'){
                var returnValue = response.getReturnValue();
                debugger;
                /*
                if(returnValue.Status__c== $A.get("$Label.c.RevSys_Observation_Status_Complete")) { 
                    component.set("v.showObsCloneDialog", true);
                } else {
                    component.set("v.showObsCloneDialog", false);
                }
                */
            } else {
                amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                console.log(returnValue.consolelog); 
            }
            
            
        }
                          );
       $A.enqueueAction(action);
        
    },
    
    closeModalHelper : function(component) {
        component.set("v.showObsCloneDialog", false);
    }
})