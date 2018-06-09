({
    fetchContentDetails : function(component, event, helper) {
        var hero_id = window.location.search.substring(1).split("=")[1];

        var action = component.get("c.getPortalContentWithId");
        action.setParams({
            contentId : hero_id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue().length > 0)
                    component.set("v.portalContent", response.getReturnValue()[0]);
                    if(response.getReturnValue()[0].Content_Type__c == 'Special Employee Advisory'){
                        component.set("v.displayHeaders", true);
                    }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})