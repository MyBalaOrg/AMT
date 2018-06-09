({
	init : function (component) {
    	// Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's Unique Name.
        var flowName = component.get("v.stationAuditType");
        flow.startFlow(flowName);
    },
    
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "STARTED") {
            // Get the output variables from flow and iterate over them
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                // Pass the values to the component's attributes
                if(outputVar.name === "CreatedFindingId") {
                    component.set("v.parentId", outputVar.value);
                } else if(outputVar.name === "showLoadImage") {
                    component.set("v.showLoadImage", outputVar.value);
                }
            }
        }  
    },    
})