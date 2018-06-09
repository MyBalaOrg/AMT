({
    updateCorrectiveActionDescription : function(component) {
        this.fireToggleSpinnerEvent(component, false);
        var action = component.get("c.updateDescription");
        action.setParams({"caJSON" : JSON.stringify(component.get("v.ca"))});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("updateCorrectiveActionDescription " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.ca)) {
                    this.fireUpdateCorrectiveActionEvent(component, JSON.parse(returnValue.ca));
                }
            } else {
                console.log(response.getError());
            }
            this.fireToggleSpinnerEvent(component, true);
        });
        $A.enqueueAction(action);
    },
    
	saveCorrectiveAction : function(component, caDataMap, apexMethodName) {
        this.fireToggleSpinnerEvent(component, false);
        var action = component.get(apexMethodName);
        action.setParams({ "caDataMap" : caDataMap });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(apexMethodName + " " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.question)) {
                    component.set("v.question", JSON.parse(returnValue.question));
                }
                if (!$A.util.isEmpty(returnValue.inspection)) {
                   component.set("v.inspection", JSON.parse(returnValue.inspection));
                }
                if (!$A.util.isEmpty(returnValue.ca)) {
                    this.fireUpdateCorrectiveActionEvent(component, JSON.parse(returnValue.ca));
                    component.set("v.ca", JSON.parse(returnValue.ca));
                }
            } else {
                console.log(response.getError());
            }
            this.fireToggleSpinnerEvent(component, true);
        });
		$A.enqueueAction(action);
	},
    
    getCorrectiveActionDataMap : function(component) {
        var ca = component.get("v.ca");
        var caDataMap = {
            "inspectionId": component.get("v.inspection.Id"),
            "questionId": component.get("v.question.Id"),
            "findingId": component.get("v.finding.Id"),
            "caJSON": JSON.stringify(ca)
        };
        //console.log(caDataMap);
        return caDataMap;
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
    
	fireUpdateCorrectiveActionEvent : function(component, ca) {
        var updateCAEvent = component.getEvent("updateCorrectiveAction");
        updateCAEvent.setParams({
            "origin" : component.get("v.findingNum"),
            "index" : component.get("v.caNum") - 1,
            "correctiveaction" : ca
        });
        updateCAEvent.fire();
    },
    
    fireMissingFindingEvent : function(component) {
        var missingFindingEvent = component.getEvent("missingFinding");
        missingFindingEvent.setParams({
            "origin" : component.get("v.findingNum"),
            "value" : true
        });
        missingFindingEvent.fire();
    },
    
    fireToggleSpinnerEvent : function(component, hideSpinner) {
        var toggleSpinner = component.getEvent("toggleLightningSpinner");
        toggleSpinner.setParams({"value" : hideSpinner});
        toggleSpinner.fire();
    }
})