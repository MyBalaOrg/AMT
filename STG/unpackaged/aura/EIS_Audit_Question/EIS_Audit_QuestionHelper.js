({
    updateQuestionHelper : function(component) {
     	this.fireToggleSpinnerEvent(component, false);
        var action = component.get("c.updateQuestionFields");
        action.setParams({ "questionJSON" : JSON.stringify(component.get("v.customQuestion.question")) });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("c.updateQuestionFields " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.question)) {
                    component.set("v.customQuestion.question", JSON.parse(returnValue.question));
                }
                if (!$A.util.isEmpty(returnValue.audit)) {
                    component.set("v.audit", JSON.parse(returnValue.audit));
                }
            } else {
                console.log(response.getError());
            }
            this.fireToggleSpinnerEvent(component, true);
        });
        $A.enqueueAction(action);
    },
    
	newCustomObservation : function(sampleObs) {
        var deptList = [];
        sampleObs.customDeptList.forEach(function(department) {
            deptList.push({'label' : department.label, 'selected' : false});
        });
        var customObservation = {
            'caList': [{
                'sObjectType':'Corrective_Action__c', 
                'RecordTypeId': sampleObs.caList[0].RecordTypeId, 
                'EIS_Status__c': $A.get("$Label.c.EIS_Corrective_Action_Status_Not_Started")
            }],
            'finding': {
                'sObjectType':'Finding__c', 
                'RecordTypeId': sampleObs.finding.RecordTypeId, 
                'EIS_Description__c': '',
                'EIS_Regulatory_Citation__c': sampleObs.finding.EIS_Regulatory_Citation__c
            },
            'customDeptList': deptList
        };
        return customObservation;
	},
    
    fireToggleSpinnerEvent : function(component, hideSpinner) {
        var toggleSpinner = component.getEvent("toggleLightningSpinner");
        toggleSpinner.setParams({"value" : hideSpinner});
        toggleSpinner.fire();
    }
})