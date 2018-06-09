({
    saveFinding : function(component, apexMethodName) {
        this.fireToggleSpinnerEvent(component, false);
        var action = component.get(apexMethodName);
        action.setParams({
            "findingDataMap" : this.getFindingDataMap(component)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(apexMethodName + " " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.finding)) {
                    var finding = JSON.parse(returnValue.finding);
                    component.set("v.finding_c.finding", finding);
                    if ($A.util.isEmpty(finding.Id)) {
                        this.fireDeleteFindingEvent(component, finding);
                    }
                }
                var inspection = returnValue.inspection;
                if (!$A.util.isEmpty(inspection)) {
                    component.set("v.inspection", JSON.parse(inspection));
                }
                var question = returnValue.question;
                if (!$A.util.isEmpty(question)) {
                    component.set("v.question", JSON.parse(question));
                }
                var caList = returnValue.caList;
                if (!$A.util.isEmpty(caList) && !$A.util.isEmpty(component.get("v.finding_c"))) {
                    component.set("v.finding_c.caList", JSON.parse(caList));
                }
            } else {
                console.log(response.getError());
            }
            this.fireToggleSpinnerEvent(component, true);
        });
        $A.enqueueAction(action);
    },
    
    getFindingDataMap : function(component) {
        var dataMap = {
            "inspectionId" : component.get("v.inspection.Id"),
            "questionJSON" : JSON.stringify(component.get("v.question")),
            "findingJSON" : JSON.stringify(component.get("v.finding_c.finding")),
            "caListJSON" : JSON.stringify(component.get("v.finding_c.caList"))
        };
        //console.log(dataMap);
        return dataMap;
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
    
    fireDeleteFindingEvent : function(component, finding) {
        var deleteFindingEvent = component.getEvent("deleteFinding");
        deleteFindingEvent.setParams({
            "finding" : finding,
            "index" : component.get("v.findingNum") - 1
        });
        deleteFindingEvent.fire();
    },
    
    fireToggleSpinnerEvent : function(component, hideSpinner) {
        var toggleSpinner = component.getEvent("toggleLightningSpinner");
        toggleSpinner.setParams({"value" : hideSpinner});
        toggleSpinner.fire();
    }
})