({ 
    doInit : function(component, event, helper) {
        component.set("v.previousDueDate", component.get("v.ca.EIS_Due_Date__c"));
    },
    
    updateCorrectiveActionFields : function(component, event, helper) {
        event.stopPropagation();
        var fieldName = event.target.dataset.fieldName;
        var withParent = event.target.dataset.withParent;
        var missingFinding = $A.util.isEmpty(component.get("v.finding.Id"));
        if (missingFinding) {
            helper.fireMissingFindingEvent(component);
        }
        if (!$A.util.isEmpty(fieldName) && !missingFinding) {
            var emptyAuraId = event.target.dataset.emptyAuraId;
            var newValue = event.target.value;
            var oldValue = component.get(fieldName);
            var hasError = false;
            // Check if required validations are needed and set error messages
            if (!$A.util.isEmpty(emptyAuraId)) {
                emptyAuraId = emptyAuraId.split(",");
                emptyAuraId.forEach(function(auraId) {
                    var checkEmptyCmp = component.find(auraId);
                    if (!$A.util.isEmpty(checkEmptyCmp)) {
                        var inputValue = '';
                        if (auraId.includes("uiinput")) {
                            inputValue = checkEmptyCmp.get("v.value");
                        } else if (auraId.includes("typeahead")) {
                            inputValue = checkEmptyCmp.get("v.selectedItemLabel");
                            checkEmptyCmp.set("v.hasError", $A.util.isEmpty(inputValue));
                        } else {
                            inputValue = checkEmptyCmp.getElement().value;
                        }
                        if ($A.util.isEmpty(inputValue)) {
                            helper.setErrorMessage(component, auraId, true);
                            hasError = true;
                        } else {
                            helper.setErrorMessage(component, auraId, false);
                        }
                    }
                });
            }
            // If no error found, proceed to update Corrective Action
            if (!hasError) {
                if (oldValue != newValue && (!$A.util.isEmpty(newValue) || !$A.util.isEmpty(oldValue))) {
                    component.set(fieldName, newValue);
                    var params = helper.getParams(component);
                    var apexMethodName = "c.updateCorrectiveAction";
                    if (fieldName === "v.ca.EIS_Status__c") {
                        if (newValue === $A.get("$Label.c.EIS_Corrective_Action_Status_Correct")) {
                            params["completionClicked"] = "true";
                        }
                        if (newValue === $A.get("$Label.c.EIS_Corrective_Action_Status_Fail_Correction")) {
                            params["rejectionClicked"] = "true";
                        }
                        if (newValue === $A.get("$Label.c.EIS_Corrective_Action_Status_Approve")) {
                            helper.setErrorMessage(component, "rejection-notes", false);
                            helper.setErrorMessage(component, "corrective-description", false);
                        }
                    }
                    if ($A.util.isEmpty(component.get("v.ca.Id")) || !$A.util.isEmpty(withParent)) {
                        apexMethodName = "c.updateCorrectiveActionWithParent";
                    }
                    if (fieldName !== "v.ca.EIS_Rejection_Notes__c") {
                        helper.saveCorrectiveAction(component, params, apexMethodName);
                    }
                }
            }
        }
    },
    
    updateCorrectiveActionDateFields : function(component, event, helper) {
        event.stopPropagation();
        if (component.get("v.previousDueDate") != component.get("v.ca.EIS_Due_Date__c")) {
            var params = helper.getParams(component);
            var apexMethodName = "c.updateCorrectiveAction";
            helper.saveCorrectiveAction(component, params, apexMethodName);
        }
    },
    
    onclickDeleteCorrectiveAction : function(component, event, helper) {
        helper.fireToggleSpinnerEvent(component, false);
        var action = component.get("c.deleteCorrectiveAction");
        action.setParams({ "params" : helper.getParams(component) });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.deleteCorrectiveAction " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.question)) {
                    component.set("v.question", JSON.parse(returnValue.question));
                }
                if (!$A.util.isEmpty(returnValue.audit)) {
                    component.set("v.audit", JSON.parse(returnValue.audit));
                }
                helper.fireDeleteCorrectiveActionEvent(component, component.get("v.caNum") - 1);
            } else {
                console.log(response.getError());
            }
            helper.fireToggleSpinnerEvent(component, true);
        });
		$A.enqueueAction(action);
    },
    
    handleFetchSearchItemsEvent : function(component, event, helper) {
        event.stopPropagation();
        helper.fireToggleSpinnerEvent(component, false);
        var auraId = event.getParam("auraId");
        var action = component.get("c.getContactsForTypeaheadSearch");
        action.setParams({ "searchKey" : event.getParam("origin") });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.getContactsForTypeaheadSearch " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var typeaheadCmp = component.find(auraId);
                if (!$A.util.isEmpty(returnValue)) {
                    var listItems = JSON.parse(returnValue.listItems);
                    if (!$A.util.isEmpty(typeaheadCmp)) {
                        typeaheadCmp.set("v.isExpanded", true);
                        typeaheadCmp.set("v.resultItems", listItems);
                        typeaheadCmp.set("v.listItems", listItems);
                    }
                }
            } else {
                console.log(response.getError());
            }
            helper.fireToggleSpinnerEvent(component, true);
        });
		$A.enqueueAction(action);
    },
    
    handleSearchItemSelectedEvent : function(component, event, helper) {
        var auraId = event.getParam("auraId");
        var selectedItem = event.getParam("selectedItem");
        if (!$A.util.isEmpty(selectedItem)) {
            if (auraId == "contact-typeahead") {
                component.set("v.ca.EIS_Assigned_to__c", selectedItem.recordId);
            } else if (auraId == "raosignoff-typeahead") {
                component.set("v.ca.EIS_RAO_Sign_Off__c", selectedItem.recordId);
            }
            var params = helper.getParams(component);
            helper.saveCorrectiveAction(component, params, "c.updateCorrectiveAction");
        }
    }
})