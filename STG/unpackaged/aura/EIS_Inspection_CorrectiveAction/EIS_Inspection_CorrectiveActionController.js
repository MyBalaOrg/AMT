({
    descriptionOnBlur : function(component, event, helper) {
    	event.stopPropagation();
        var ca = component.get("v.ca");
        var value = event.target.value;
        if (!$A.util.isEmpty(component.get("v.finding.Id"))) {
            if (value != ca.EIS_Description__c && (!$A.util.isEmpty(value) || !$A.util.isEmpty(ca.EIS_Description__c))) {
            	ca.EIS_Description__c = value;
                component.set("v.ca", ca);
                if ($A.util.isEmpty(ca.Id)) {
                    var caDataMap = helper.getCorrectiveActionDataMap(component);
                    helper.saveCorrectiveAction(component, caDataMap, "c.clickNotStarted");
                } else {
                    helper.updateCorrectiveActionDescription(component);
                }
            }
        } else {
            helper.fireMissingFindingEvent(component);
        }
        if (!$A.util.isEmpty(value)) {
            helper.setErrorMessage(component, "corrective-description", false);
        }
    },
    
	onclickStatusButton : function(component, event, helper) {
        var methodName = event.target.value;
        if ($A.util.isEmpty(component.get("v.finding.Id"))) {
            helper.fireMissingFindingEvent(component);
        } else {
            var caDataMap = helper.getCorrectiveActionDataMap(component);
        	helper.saveCorrectiveAction(component, caDataMap, methodName);
        }
	},
    
    onclickDeleteCorrectiveAction : function(component, event, helper) {
        var ca = component.get("v.ca");
        if (!$A.util.isEmpty(ca) && !$A.util.isEmpty(ca.Id)) {
            var caDataMap = helper.getCorrectiveActionDataMap(component);
            helper.saveCorrectiveAction(component, caDataMap, "c.deleteCorrectiveAction");
        }
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
        event.stopPropagation();
        if ($A.util.isEmpty(component.get("v.finding.Id"))) {
            helper.fireMissingFindingEvent(component);
            
        } else {
            var auraId = event.getParam("auraId");
            var selectedItem = event.getParam("selectedItem");
            if (!$A.util.isEmpty(selectedItem)) {
                if (auraId == "contact-typeahead") {
                    component.set("v.ca.EIS_Assigned_to__c", selectedItem.recordId);
                }
                var caDataMap = helper.getCorrectiveActionDataMap(component);
                helper.saveCorrectiveAction(component, caDataMap, "c.saveAssignedToContact");
            }
        }
    }
})