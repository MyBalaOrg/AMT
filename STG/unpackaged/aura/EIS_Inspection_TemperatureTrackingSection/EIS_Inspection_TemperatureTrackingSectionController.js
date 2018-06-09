({
	doInit : function(component, event, helper) {
		var action = component.get("c.initTemperatureTrackingSection");
        action.setParams({ "inspectionId" : component.get("v.inspectionId") });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.initTemperatureTrackingSection " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue(); 
                if (!$A.util.isEmpty(returnValue.tempTrackingWrappers)) {
                    component.set("v.trackingWrappers", JSON.parse(returnValue.tempTrackingWrappers));
                }
                if (!$A.util.isEmpty(returnValue.foodTrackingWrapper)) {
                    component.set("v.foodTrackingWrapper", JSON.parse(returnValue.foodTrackingWrapper));
                }
                if (!$A.util.isEmpty(returnValue.sectionHeader)) {
                    component.set("v.sectionHeader", returnValue.sectionHeader);
                }
                component.set("v.displaySection", true);
            } else {
                console.log(response.getError());
            }
        });
		$A.enqueueAction(action);
	},
    
    toggleDisplaySection : function(component) {
        component.set("v.displaySection", !component.get("v.displaySection"));
    }
})