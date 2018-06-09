({
    onchangeObsRegionProperty : function(component, event, helper) {
        var region = event.getSource().get("v.value");
        var picklistMapRegionState = component.get("v.picklistMapRegionState");
        var picklistMap = component.get("v.picklistMap");
       	component.set("v.picklistMap.State__c", picklistMapRegionState[region]);
        var stateInputCmp = component.find("State__c");
        stateInputCmp.set("v.errors", null);
    },
    
    updateObsTemplateFields : function(component, event, helper) {
        component.set("v.obsTemplate", component.get("v.obsTemplate"));
    },
    
    handleFetchSearchItemsEvent : function(component, event, helper) {
        event.stopPropagation();
        var auraId = event.getParam("auraId");
        var objectName;
        var fieldsToSearchList = [];
        
        if (auraId === "OperatedFromCode__c" || auraId === "OperatedToCode__c") {
        	objectName = "Station__c";
            fieldsToSearchList.push("Name");
            fieldsToSearchList.push("City__c");
            fieldsToSearchList.push("Code__c");
            fieldsToSearchList.push("State__c");
        }
        else if (auraId === "Train__c") {
        	objectName = "Train__c";
            fieldsToSearchList.push("Name");
        }
        else if (auraId === "Nearest_Station_Interlocking__c") {
        	objectName = "Station__c";
            fieldsToSearchList.push("Name");
        }
        var action = component.get("c.getItemsForTypeaheadSearch");
        action.setParams({ 
            "searchKey" : event.getParam("origin"),
            "objectName" : objectName,
            "fieldsToSearchList" : JSON.stringify(fieldsToSearchList)
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
        });
		$A.enqueueAction(action);
    },
    
    handleSearchItemSelectedEvent : function(component, event, helper) {
        event.stopPropagation();
        var auraId = event.getParam("auraId");
        var selectedItem = event.getParam("selectedItem");
        if (!$A.util.isEmpty(selectedItem)) {
            if (auraId === "OperatedFromCode__c") {
                component.set("v.obsTemplate.OperatedFromCode__c", selectedItem.recordId);
                component.set("v.obsTemplate.OperatedFromCode__r.Name", selectedItem.label);
            }
            if (auraId === "OperatedToCode__c") {
                component.set("v.obsTemplate.OperatedToCode__c", selectedItem.recordId);
                component.set("v.obsTemplate.OperatedToCode__r.Name", selectedItem.label);
            }
            if (auraId === "Train__c") {
                component.set("v.obsTemplate.Train__c", selectedItem.recordId);
                component.set("v.obsTemplate.Train__r.Name", selectedItem.label);
            }
            if (auraId === "Nearest_Station_Interlocking__c") {
                component.set("v.obsTemplate.Nearest_Station_Interlocking__c", selectedItem.recordId);
                component.set("v.obsTemplate.Nearest_Station_Interlocking__r.Name", selectedItem.label);
            }
        }
        else {
            if (auraId === "OperatedFromCode__c") {
                component.set("v.obsTemplate.OperatedFromCode__c", "");
            }
            if (auraId === "OperatedToCode__c") {
                component.set("v.obsTemplate.OperatedToCode__c", "");
            }
            if (auraId === "Train__c") {
                component.set("v.obsTemplate.Train__c", "");
            }  
            if (auraId === "Nearest_Station_Interlocking__c") {
                component.set("v.obsTemplate.Nearest_Station_Interlocking__c", "");
            }  
        }
        component.set("v.obsTemplate", component.get("v.obsTemplate"));
    },
})