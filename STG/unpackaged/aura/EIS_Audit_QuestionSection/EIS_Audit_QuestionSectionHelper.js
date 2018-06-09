({
	getCustomQuestionList : function(component, customSection) {
        this.fireToggleSpinnerEvent(component, false);
		var action = component.get("c.getCustomQuestions");
        var params = { 
            'sideTabName' : customSection.sideTabName,
            'sectionHeader' : customSection.sectionHeader,
            'auditId' : component.get("v.audit.Id"),
            'recordTypeAPI' : component.get("v.audit.RecordType.DeveloperName") 
        };
        action.setParams({ "params" : params });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.getCustomQuestions " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var customQuestionList = returnValue.customQuestionList;
                if (!$A.util.isEmpty(customQuestionList)) {
                    customSection.customQuestionList = JSON.parse(customQuestionList);
                    component.set("v.customSection", customSection);
                }
            } else {
                console.log(response.getError());
            }
            this.fireToggleSpinnerEvent(component, true);
        });
		$A.enqueueAction(action);
	},
    
    fireToggleSpinnerEvent : function(component, hideSpinner) {
        var toggleSpinner = component.getEvent("toggleLightningSpinner");
        toggleSpinner.setParams({"value" : hideSpinner});
        toggleSpinner.fire();
    }
})