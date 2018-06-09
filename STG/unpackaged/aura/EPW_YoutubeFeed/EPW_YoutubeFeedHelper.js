({
    getVideoIdFromObject : function(component, event, helper) {
        
        // Create the action
        var action = component.get("c.getVideoId");
        action.setParams({
            "objApiName": component.get("v.objApiName"), "fieldApiName": component.get("v.fieldApiName")
        });
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {                
                component.set('v.videoId', response.getReturnValue());  
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        
        // Send action off to be executed
        $A.enqueueAction(action);
        
    }
})