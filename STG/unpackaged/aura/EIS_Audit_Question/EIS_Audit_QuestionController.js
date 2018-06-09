({
	doInit : function(component, event, helper) {
		var questionIssued = component.get("v.customQuestion.question.EIS_Issued__c");
        if (!$A.util.isEmpty(questionIssued)) {
            component.set("v.customQuestion.display", questionIssued);
        }
	},
    
    toggleQuestionSelection : function(component, event, helper) {
        component.set("v.customQuestion.display", !component.get("v.customQuestion.display"));
    },
    
    updateObservationLevelFields : function(component, event, helper) {
        var fieldName = event.target.dataset.fieldName;
        if (!$A.util.isEmpty(fieldName)) {
            var fieldValue = event.target.value;
            fieldValue = (fieldValue === "true") ? true : (fieldValue === "false") ? false : fieldValue;
            component.set(fieldName, fieldValue);
            if (!$A.util.isEmpty(component.get("v.customQuestion.question.Id"))) {
                helper.updateQuestionHelper(component);
            }
        }
    },
    
    addObservation : function(component, event, helper) {
        var obsList = component.get("v.customQuestion.customObservationList");
        obsList.push(helper.newCustomObservation(obsList[0]));
        component.set("v.customQuestion.customObservationList", obsList);
    },
    
    handleDeleteObservation : function(component, event, helper) {
        event.stopPropagation();
        var index = event.getParam("index");
        var obsList = component.get("v.customQuestion.customObservationList");
        if (!$A.util.isEmpty(obsList)) {
            if (obsList.length > 1) {
            	obsList.splice(index, 1);
            } else {
                obsList = [helper.newCustomObservation(obsList[0])];
            }
            component.set("v.customQuestion.customObservationList", obsList);
        }
    },
    
    showToolTip : function(component, event, helper) {
        component.set("v.displayToolTip", true);
    },
    
    hideToolTip : function(component, event, helper) {
        component.set("v.displayToolTip", false);
    }
})