({
    updateObservationAction : function(component, params, apexMethodName) {
        this.fireToggleSpinnerEvent(component, false);
        var action = component.get(apexMethodName);
        action.setParams({ "params" : params });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(apexMethodName + " " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var finding = returnValue.finding;
                if (!$A.util.isEmpty(finding)) {
                    component.set("v.customObservation.finding", JSON.parse(finding));
                }
                var audit = returnValue.audit;
                if (!$A.util.isEmpty(audit)) {
                    component.set("v.audit", JSON.parse(audit));
                }
                var question = returnValue.question;
                if (!$A.util.isEmpty(question)) {
                    component.set("v.question", JSON.parse(question));
                }
                var caList = returnValue.caList;
                if (!$A.util.isEmpty(caList)) {
                    component.set("v.customObservation.caList", JSON.parse(caList));
                }
            } else {
                console.log(response.getError());
            }
            if (apexMethodName === "c.deleteFinding") {
                this.fireDeleteObservationEvent(component, component.get("v.obsNum") - 1);
            }
            this.fireToggleSpinnerEvent(component, true);
        });
        $A.enqueueAction(action);
    },
    
    getParams : function(component) {
        var params = {
            "auditId" : component.get("v.audit.Id"),
            "questionJSON" : JSON.stringify(component.get("v.question")),
            "findingJSON" : JSON.stringify(component.get("v.customObservation.finding"))
        };
        return params;
    },
    
    setErrorMessage : function(component, className, hasError) {
        var targetCmp = component.find(className);
        var errorMsg = component.find(className + "-error");
        if (hasError) {
            if (!$A.util.hasClass(targetCmp, "has-error")) {
                $A.util.addClass(targetCmp, "has-error");
            }
            errorMsg.set("v.rendered", true);
            targetCmp.getElement().focus();
        } else {
            $A.util.removeClass(targetCmp, "has-error");
            errorMsg.set("v.rendered", false);
        }
    },
    
    newCorrectiveAction : function(sampleCA) {
    	var ca = {
            'sObjectType' : 'Corrective_Action__c', 
            'RecordTypeId' : sampleCA.RecordTypeId,
            'EIS_Description__c' : '',
            'EIS_Status__c' : $A.get("$Label.c.EIS_Corrective_Action_Status_Not_Started")
        };
        return ca;
    },
    
    fireDeleteObservationEvent : function(component, obsIndex) {
        var deleteEvent = component.getEvent("deleteObservation");
        deleteEvent.setParams({"index" : obsIndex});
        deleteEvent.fire();
    },
    
    fireUpdateDepartmentScoreEvent : function(component, index, score) {
        var updateEvent = component.getEvent("updateDepartmentScore");
        updateEvent.setParams({
            "index" : index,
            "integerValue" : score
        });
        updateEvent.fire();
    },
    
    fireToggleSpinnerEvent : function(component, hideSpinner) {
        var toggleSpinner = component.getEvent("toggleLightningSpinner");
        toggleSpinner.setParams({"value" : hideSpinner});
        toggleSpinner.fire();
    }
})