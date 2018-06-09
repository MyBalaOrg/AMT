({
	onclickAddTrackingItem : function(component, event, helper) {
		var trackingList = component.get("v.trackingWrapper.trackingList");
        var locationTypePicklist = component.get("v.trackingWrapper.locationTypePicklist");
        trackingList.push(helper.getNewTrackingRecord(trackingList[0], locationTypePicklist[0]));
        component.set("v.trackingWrapper.trackingList", trackingList);
	},
    
    onclickDeleteTrackingItem : function(component, event, helper) {
        event.stopPropagation();
        var index = event.currentTarget.dataset.rowIndex;
        var trackingList = component.get("v.trackingWrapper.trackingList");
        if (!$A.util.isEmpty(trackingList[index].Id)) {
            helper.saveTemperatureTracking(component, trackingList[index], "delete");
        } else {
            if (trackingList.length == 1) {
                var locationTypePicklist = component.get("v.trackingWrapper.locationTypePicklist");
                trackingList[0] = helper.getNewTrackingRecord(trackingList[0], locationTypePicklist[0]);
            } else {
                trackingList.splice(index, 1);
            }
            component.set("v.trackingWrapper.trackingList", trackingList);
        }
    },
    
    onchangeLocationTypeSelect : function(component, event, helper) {
        event.stopPropagation();
    	var locationTypeCmp = event.getSource();
        if (!$A.util.isEmpty(locationTypeCmp)) {
            var trackingList = component.get("v.trackingWrapper.trackingList");
            var index = locationTypeCmp.get("v.label");
            var isValid = helper.recordIsValidForSaving(trackingList[index].EIS_Location__c, trackingList[index].EIS_Food_Item__c, trackingList[index].EIS_Temperature__c);
            if (isValid) {
                helper.saveTemperatureTracking(component, trackingList[index], "upsert");
            }
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
    
    onblurFoodItemInputText : function(component, event, helper) {
        event.stopPropagation();
        var trackingList = component.get("v.trackingWrapper.trackingList");
        var index = event.currentTarget.dataset.rowIndex;
        var foodItem = event.currentTarget.value.trim();
        
        if (trackingList[index].EIS_Food_Item__c != foodItem) {
            var isValid = helper.recordIsValidForSaving(trackingList[index].EIS_Location__c, foodItem, trackingList[index].EIS_Temperature__c);
            trackingList[index].EIS_Food_Item__c = foodItem;
            if (isValid) {
                helper.saveTemperatureTracking(component, trackingList[index], "upsert");
            } else {
                component.set("v.trackingWrapper.trackingList", trackingList);
            }
        }
    },
    
    onblurTemperatureInputNumber : function(component, event, helper) {
        event.stopPropagation();
        var trackingList = component.get("v.trackingWrapper.trackingList");
        var index = event.currentTarget.dataset.rowIndex;
        var valueTemperature = event.currentTarget.value.trim();
        
        if (trackingList[index].EIS_Temperature__c != valueTemperature) {
            var isValid = helper.recordIsValidForSaving(trackingList[index].EIS_Location__c, trackingList[index].EIS_Food_Item__c, valueTemperature);
            trackingList[index].EIS_Temperature__c = valueTemperature;
            if (isValid) {
                helper.saveTemperatureTracking(component, trackingList[index], "upsert");
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