// ****************************************************************************************************************
// Component: SObject List Component Helper
// Author:  Nathan Shinn, Deloitte Digital
// Date:    Feb 14, 2017
// Description: Used to render a list of records given a query
//
// Modifications: 
// 1.00: Created     
// ****************************************************************************************************************  
({
    /**
     * Load the list of objects via Apex from the supplied query
     */
	loadSobjects : function(component) {
        //pass a query to the apex controller and retrieve the data as well 
        //as the associated Fields and Labels
        var action = component.get("c.fetchRecords");
        action.setParams({ strQuery : component.get("v.query")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            //load the local variables with the results of the apex call
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
				component.set("v.lstSobject", result.lstSobject);
                component.set("v.lstFieldApi", result.lstFieldApi);
                component.set("v.lstFieldLabel", result.lstFieldLabel);
                
                setTimeout(function(){ $('#example').DataTable(); }, 500);
            }
            else if (state === "ERROR") {
                //$A.log("Errors", a.getError());
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
	}
})