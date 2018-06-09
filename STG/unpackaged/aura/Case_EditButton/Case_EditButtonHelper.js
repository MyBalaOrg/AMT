({
	fireNavigateToEvent : function(component, recordId, slideDevName) {
		var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": slideDevName
        });
        navEvt.fire();
	}
})