({
	sendMessageAction: function(component, message){
        //Send message to VF
        message.origin = window.location.hostname;
        var iframeId = "iframe-" + component.get("v.parentId");
        var vfWindow = document.getElementById(iframeId).contentWindow;
        if (!$A.util.isEmpty(vfWindow)) {
            vfWindow.postMessage(message, component.get("v.vfHost"));
        }
    },
    
    getDocumentList : function(component, apexMethodName, params) {
        var action = component.get(apexMethodName);
        if (!$A.util.isEmpty(action)) {
            action.setParams(params);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    if (!$A.util.isEmpty(returnValue)) {
                        component.set("v.documentList", returnValue);
                    }
                } else {
                    console.log(response.getError());
                }
                this.fireToggleSpinnerEvent(component, true);
            });
            $A.enqueueAction(action);
        }
    },
    
    fireToggleSpinnerEvent : function(component, hideSpinner) {
        var toggleSpinner = component.getEvent("toggleLightningSpinner");
        if (!$A.util.isEmpty(toggleSpinner)) {
            toggleSpinner.setParams({"value" : hideSpinner});
            toggleSpinner.fire();
        }
    }
})