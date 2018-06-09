({
    updateObsToNotShowCloneDlg : function(component) {
        var action = component.get('c.updateObservationRecord');
        action.setParams({
            "obs" : {
                "sobjectType" : "Observation__c",
                "Id" : component.get('v.recordId'),
                "RevSysShowPopup__c" : false
            }
        });
        action.setCallback(this,function(response){
           
            var state = response.getState();
            if (state === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
            }
            
        });
        $A.enqueueAction(action);
    },
    
    closeModalHelper : function(component) {
        component.set("v.showObsCloneDialog", false);
    },
    
    cloneObservation : function(component, event){
        var action = component.get("c.getObservation");
        action.setParams({
            "obsId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var returnedObservation = response.getReturnValue();
                returnedObservation.Id = null;
                //returnedObservation.Status__c = "Pending";
                returnedObservation.Status__c = $A.get("$Label.c.RevSys_Observation_Status_Draft");
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
    }
})