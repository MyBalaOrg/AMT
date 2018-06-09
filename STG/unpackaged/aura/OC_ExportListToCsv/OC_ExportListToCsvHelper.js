/**
 **********************************************************************************************************************
 *	@Name			OC_ExportListToCsvHelper.js 
 * 	@Author			Nathan Shinn, Deloitte Digital
 * 	@Created Date	14th Feb 2017	
 * 	@Used By		OC_ExportListToCsvController.js
 ***********************************************************************************************************************
 *	@Description	This is the javascript helper controller for OC_ExportListToCsv which processes requests
 					from the controller and calls the apex controller methods to process data and display results
                    back to the component.
 ***********************************************************************************************************************
 *	@Changes
 
 ***********************************************************************************************************************
 **/ 
({
    /**
     * Load the list from a query executed by apex or via a list of SObjects
     */
	loadSobjects : function(component) {
        var qry = component.get("v.query");
        console.log("::qry:: "+qry);
        
        if(qry != null && qry != "")
        {
            var action = component.get("c.fetchRecords");
            //Load the query passed into the component
            action.setParams({ strQuery : qry});
            
            //call the controller to retrieve the data
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                //If successful, Load the results into the local parameters
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set("v.lstSobject", result.lstSobject);
                    component.set("v.lstFieldApi", result.lstFieldApi);
                    component.set("v.lstFieldLabel", result.lstFieldLabel);
                    
                    setTimeout(function(){ $('#example').DataTable(); }, 500);
                }
                else if (state === "ERROR") {
                   console.log(":::EXPORT Errors::::", response.getError());
                }
            });
            $A.enqueueAction(action);
        }
        
	}
})