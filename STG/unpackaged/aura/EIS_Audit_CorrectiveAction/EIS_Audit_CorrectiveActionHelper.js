({
	saveCorrectiveAction : function(component, params, apexMethodName) {
        this.fireToggleSpinnerEvent(component, false);
        var action = component.get(apexMethodName);
        action.setParams({ "params" : params });
        console.log(params);
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(apexMethodName + " " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                } else {
                    if (!$A.util.isEmpty(returnValue.ca)) {
                        component.set("v.ca", JSON.parse(returnValue.ca));
                        component.set("v.previousDueDate", component.get("v.ca.EIS_Due_Date__c"));
                        this.clearAllRequiredFieldErrors(component);
                    }
                    if (!$A.util.isEmpty(returnValue.question)) {
                        component.set("v.question", JSON.parse(returnValue.question));
                    }
                    if (!$A.util.isEmpty(returnValue.audit)) {
                        component.set("v.audit", JSON.parse(returnValue.audit));
                    }
                }
            } else {
                console.log(response.getError());
            }
            this.fireToggleSpinnerEvent(component, true);
        });
		$A.enqueueAction(action);
	},
    
    getParams : function(component) {
        var ca = component.get("v.ca");
        if ($A.util.isEmpty(ca.EIS_Due_Date__c)) { ca.EIS_Due_Date__c = null; }
        if ($A.util.isEmpty(ca.EIS_Sign_Off_Date__c)) { ca.EIS_Sign_Off_Date__c = null; }
        
        var params = {
            "auditId": component.get("v.audit.Id"),
            "questionId": component.get("v.question.Id"),
            "findingId": component.get("v.finding.Id"),
            "caJSON": JSON.stringify(ca)
        };
        //console.log(params);
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
        } else {
            $A.util.removeClass(targetCmp, "has-error");
            errorMsg.set("v.rendered", false);
        }
    },
    
    clearAllRequiredFieldErrors : function(component) {
        // Clear description field error
        this.setErrorMessage(component, "corrective-description", false);
        
        // Clear Assigned To field error
        this.setErrorMessage(component, "contact-typeahead", false);
        component.find("contact-typeahead").set("v.hasError", false);
        
        // Clear Due Date field error
        this.setErrorMessage(component, "uiinput-due-date", false);
    },
    
    fireMissingFindingEvent : function(component) {
        var missingFindingEvent = component.getEvent("missingFinding");
        missingFindingEvent.fire();
    },
    
    fireDeleteCorrectiveActionEvent : function(component, caIndex) {
        var deleteEvent = component.getEvent("deleteCorrectiveAction");
        deleteEvent.setParams({
            "index" : caIndex
        });
        deleteEvent.fire();
    },
    
    fireToggleSpinnerEvent : function(component, hideSpinner) {
        var toggleSpinner = component.getEvent("toggleLightningSpinner");
        toggleSpinner.setParams({"value" : hideSpinner});
        toggleSpinner.fire();
    }
})