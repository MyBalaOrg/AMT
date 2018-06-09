({
    fireToggleSpinnerEvent : function(component, hideSpinner) {
        var toggleSpinner = component.getEvent("toggleLightningSpinner");
        toggleSpinner.setParams({"value" : hideSpinner});
        toggleSpinner.fire();
    },
    
    fireSaveButtonClickedEvent : function(component) {
        var refreshCase = component.getEvent("saveButtonClicked");
        refreshCase.setParams({"origin" : component.getLocalId()});
        refreshCase.fire();
    }
})