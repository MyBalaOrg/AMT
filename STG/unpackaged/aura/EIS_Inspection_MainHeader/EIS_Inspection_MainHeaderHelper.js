({
    fireButtonClickedEvent : function(component, buttonName, description) {
        var buttonEvent = component.getEvent("headerButtonClicked");
        buttonEvent.setParams({
            "origin" : buttonName,
            "description" : description
        });
        buttonEvent.fire();
    },
    //Method Created by Shiva
    content : function(component,buttonName,event)
    {
        var action = component.get("c.getContentSize");
        console.log("id" +component.get("v.recordId"));
        action.setParams({
            "auditInspection" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState(); 
            if(state === "SUCCESS"){
                var contentSize = response.getReturnValue();
                if(contentSize > 49000000) {
                    var confirmationModalLabels = component.get("v.confirmationModalLabels");
                    confirmationModalLabels.header = event.target.innerHTML + " Confirmation";
                    confirmationModalLabels.body = "The file you are trying to send is to big ,reduce its size to less than 49MB ,Are you sure you want to " + event.target.innerHTML + " this " + component.get("v.inspection.RecordType.Name") + " without sending attachments ?";
                    confirmationModalLabels.buttonName = buttonName;
                    component.set("v.confirmationModalLabels", confirmationModalLabels);
                    component.set("v.openClickConfirmation", true);
                } else if(contentSize > 3000000 && contentSize < 49000000) {
                    var confirmationModalLabels = component.get("v.confirmationModalLabels");
                    confirmationModalLabels.header = event.target.innerHTML + " Confirmation";
                    confirmationModalLabels.body = "The Size of the Attachments are larger then 3MB, the attchments will be sent as link. Are you sure you want to " + event.target.innerHTML + " this " + component.get("v.inspection.RecordType.Name") + "?";
                    confirmationModalLabels.buttonName = buttonName;
                    component.set("v.confirmationModalLabels", confirmationModalLabels);
                    component.set("v.openClickConfirmation", true);
                } else {
                    var confirmationModalLabels = component.get("v.confirmationModalLabels");
                    confirmationModalLabels.header = event.target.innerHTML + " Confirmation";
                    confirmationModalLabels.body = "Are you sure you want to " + event.target.innerHTML + " this " + component.get("v.inspection.RecordType.Name") + "?";
                    confirmationModalLabels.buttonName = buttonName;
                    component.set("v.confirmationModalLabels", confirmationModalLabels);
                    component.set("v.openClickConfirmation", true);
                }
            }
        }); 
        $A.enqueueAction(action);
    }
})