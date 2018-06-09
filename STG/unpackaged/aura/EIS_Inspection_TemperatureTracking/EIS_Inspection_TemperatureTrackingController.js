({
	onclickAddTrackingItem : function(component, event, helper) {
		var trackingList = component.get("v.trackingWrapper.trackingList");
        trackingList.push(helper.getNewTrackingRecord(trackingList[0]));
        component.set("v.trackingWrapper.trackingList", trackingList);
	},
    
    onclickDeleteTrackingItem : function(component, event, helper) {
        event.stopPropagation();
        var index = event.currentTarget.dataset.rowIndex;
        var trackingList = component.get("v.trackingWrapper.trackingList");
        if (!$A.util.isEmpty(trackingList[index].Id)) {
            helper.saveTemperatureTracking(component, trackingList[index], "delete");
        } else {
            if (trackingList.length === 1) {
                trackingList[0] = helper.getNewTrackingRecord(trackingList[0]);
            } else {
                trackingList.splice(index, 1);
            }
            component.set("v.trackingWrapper.trackingList", trackingList);
        }
    },
    
    onfocusLocationInputText : function(component, event, helper) {
        event.stopPropagation();
        var index = event.currentTarget.dataset.rowIndex;
        var picklistId = component.getGlobalId() + "_picklist-" + index;
        var picklistElement = document.getElementById(picklistId);
        $A.util.removeClass(picklistElement, "hide-picklist");
    },
    
    onblurLocationInputText : function(component, event, helper) {
        event.stopPropagation();
        var index = event.currentTarget.dataset.rowIndex;
        var picklistId = component.getGlobalId() + "_picklist-" + index;
        var picklistElement = document.getElementById(picklistId);
        setTimeout(function(){ $A.util.addClass(picklistElement, "hide-picklist"); }, 500);
        
        var valueLocation = event.currentTarget.value.trim();
        helper.validateLocationBeforeSaving(component, index, valueLocation);
    },
    
    handleLocationSelection : function(component, event, helper) {
        event.stopPropagation();
        var location = event.currentTarget.dataset.location;
        var index = event.currentTarget.dataset.rowIndex;
        
        helper.validateLocationBeforeSaving(component, index, location);
    },
    
    onblurTemperatureInputNumber : function(component, event, helper) {
        event.stopPropagation();
        var trackingList = component.get("v.trackingWrapper.trackingList");
        var index = event.currentTarget.dataset.rowIndex;
        var valueTemperature = event.currentTarget.value.trim();
        
        if (trackingList[index].EIS_Temperature__c != valueTemperature) {
            var isValid = helper.recordIsValidForSaving(trackingList[index].EIS_Location__c, valueTemperature);
            trackingList[index].EIS_Temperature__c = valueTemperature;
            if (isValid) {
                if ($A.util.isEmpty(trackingList[index].Id)) {
                    var existingRecords = component.get("v.trackingWrapper.existingRecords");
                    if (!existingRecords.includes(trackingList[index].EIS_Location__c.toLowerCase() + ';')) {
                        helper.saveTemperatureTracking(component, trackingList[index], "upsert");
                    } else {
                        component.set("v.trackingWrapper.trackingList", trackingList);
                    }
                } else {
                    helper.saveTemperatureTracking(component, trackingList[index], "upsert");
                }
            } else {
                component.set("v.trackingWrapper.trackingList", trackingList);
            }
        }
    },
    
    preventInvalidKeypressed : function(component, event, helper) {
    	event.stopPropagation();
        var keyPressed = "which" in event ? event.which : event.keyCode;
        if (keyPressed == 59 || keyPressed == 13) {
        	event.preventDefault();    
        }
    },
    
    validateNumericInput : function(component, event, helper) {
        event.stopPropagation();
        var keyPressed = "which" in event ? event.which : event.keyCode;
        var currentValue = event.target.value;
        if ((keyPressed >= 48 && keyPressed <= 57) || keyPressed == 45 || keyPressed == 46) {
            if ((keyPressed == 45 && !$A.util.isEmpty(currentValue)) || (keyPressed == 46 && currentValue.includes('.'))) {
                event.preventDefault();
            } else {
                //valid numeric value
            }
        } else {
            event.preventDefault();
        }
    }
})