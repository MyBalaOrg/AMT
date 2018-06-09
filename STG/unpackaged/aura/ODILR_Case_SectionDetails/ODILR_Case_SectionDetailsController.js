({
    doInit : function(component, event, helper) {
        component.set("v.editMode", component.get("v.newCaseCreation"));
    },
    
    toggleEditMode : function(component, event, helper) {
        event.stopPropagation();
        var value = event.target.value;
        var editMode = component.get("v.editMode");
        if (editMode && value != $A.get("$Label.c.EIS_Form_Button_Cancel")) {
            helper.fireSaveButtonClickedEvent(component);
        } else {
            component.set("v.editMode", !editMode);    
        }
    },
    
    navigateToRecordPage : function(component, event, helper) {
        event.stopPropagation();
        var dataset = event.target.dataset;
        if (!$A.util.isEmpty(dataset)) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": dataset.recordId,
                "slideDevName": "detail"
            });
            navEvt.fire();
        }
    },
    
    handleFetchSearchItemsEvent : function(component, event, helper) {
        event.stopPropagation();
        helper.fireToggleSpinnerEvent(component, false);
        var auraId = event.getParam("auraId");
        var index = event.getParam("index");
        var caseWrappers = component.get("v.caseWrappers");
        
        var action = component.get("c.getItemsForTypeaheadSearch");
        action.setParams({ 
            "searchKey" : event.getParam("origin"),
            "objectName" : caseWrappers[index].referenceToSObject,
            "fieldName" : caseWrappers[index].fieldName
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.getItemsForTypeaheadSearch " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var typeaheadCmp = component.find(auraId);
                if (!$A.util.isEmpty(returnValue)) {
                    var listItems = JSON.parse(returnValue.listItems);
                    if (!$A.util.isEmpty(typeaheadCmp)) {
                        if (typeaheadCmp.length && typeaheadCmp.length > 0) {
                            typeaheadCmp.forEach(function(typeahead) {
                                if (index == typeahead.get("v.internalId")) {
                                    typeahead.set("v.isExpanded", true);
                                    typeahead.set("v.resultItems", listItems);
                                    typeahead.set("v.listItems", listItems);
                                }
                            });
                        } else {
                            typeaheadCmp.set("v.isExpanded", true);
                            typeaheadCmp.set("v.resultItems", listItems);
                            typeaheadCmp.set("v.listItems", listItems);
                        }
                    }
                }
            } else {
                component.set("v.errorMessage", response.getError());
            }
            helper.fireToggleSpinnerEvent(component, true);
        });
		$A.enqueueAction(action);
    },
    
    handleSearchItemSelectedEvent : function(component, event, helper) {
        event.stopPropagation();
        var auraId = event.getParam("auraId");
        var index = event.getParam("index");
        var selectedItem = event.getParam("selectedItem");
        var caseWrappers = component.get("v.caseWrappers");
        if (!$A.util.isEmpty(selectedItem)) {
            caseWrappers[index].fieldValue = selectedItem.recordId;
            caseWrappers[index].referenceValue = selectedItem.label;
        } else {
            caseWrappers[index].fieldValue = "";
            caseWrappers[index].referenceValue = "";
        }
        component.set("v.caseWrappers", caseWrappers);
    },
    
    showToolTip : function(component, event, helper) {
        event.stopPropagation();
        if (!$A.util.isEmpty(event.currentTarget.dataset)) {
            component.set("v.displayHelperTextKey", event.currentTarget.dataset.fieldName);
        }
    },
    
    hideToolTip : function(component, event, helper) {
        component.set("v.displayHelperTextKey", "");
    },
    
    toggleDisplaySection : function(component, event, helper) {
        component.set("v.displaySection", !component.get("v.displaySection"));
    }
})