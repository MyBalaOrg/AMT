({
	getNewTrackingRecord : function(oldTracking) {
        var newTracking = {
            'sObjectType': 'Tracking__c', 
            'RecordTypeId': oldTracking.RecordTypeId,
            'EIS_Temperature_Type__c': oldTracking.EIS_Temperature_Type__c,
            'EIS_Location__c': '',
        }
        return newTracking;
	},
    
    validateLocationBeforeSaving : function(component, index, location) {
        var trackingList = component.get("v.trackingWrapper.trackingList");
        var existingRecords = component.get("v.trackingWrapper.existingRecords");
        if (trackingList[index].EIS_Location__c != location) {
            if (!existingRecords.includes(location.toLowerCase() + ';')) {
                var isValid = this.recordIsValidForSaving(location, trackingList[index].EIS_Temperature__c);
                trackingList[index].EIS_Location__c = location;
                if (isValid) {
                    this.saveTemperatureTracking(component, trackingList[index], "upsert");
                } else {
                    component.set("v.trackingWrapper.trackingList", trackingList);
                    component.set("v.errorMsg", "");
                }
            } else {
                component.set("v.errorMsg", $A.get("$Label.c.EIS_Form_Error_Msg_Location_Already_Exist"));
            }
        }
    },
    
    recordIsValidForSaving : function(location, temperature) {
        var isValid = !$A.util.isEmpty(location) && !$A.util.isEmpty(temperature) && !isNaN(temperature);
        return isValid;
    },
    
    saveTemperatureTracking : function(component, trackingRecord, operation) {
        this.fireToggleSpinnerEvent(component, false);
        var params = {
            "inspectionId" : component.get("v.inspectionId"),
            "trackingJSON" : JSON.stringify(trackingRecord),
            "operation" : operation
        };
        var action = component.get("c.saveTemperatureTrackingRecord");
        action.setParams({ "params" : params });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.saveTemperatureTrackingRecord " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue(); 
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    component.set("v.errorMsg", returnValue.errorMsg);
                } else {
                    component.set("v.errorMsg", "");
                    if (!$A.util.isEmpty(returnValue.trackingList)) {
                        component.set("v.trackingWrapper.trackingList", JSON.parse(returnValue.trackingList));
                    }
                    if (!$A.util.isEmpty(returnValue.existingRecords)) {
                        component.set("v.trackingWrapper.existingRecords", returnValue.existingRecords);
                    }
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