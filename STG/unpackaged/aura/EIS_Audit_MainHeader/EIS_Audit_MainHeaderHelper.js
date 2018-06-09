({
	fireButtonClickedEvent : function(component, newSubmitStatus, description) {
		var buttonEvent = component.getEvent("headerButtonClicked");
        buttonEvent.setParams({
            "origin" : newSubmitStatus,
            "description" : description
        });
        buttonEvent.fire();
	}
})