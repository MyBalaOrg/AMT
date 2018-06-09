// ****************************************************************************************************************
// Component: Navigate to SObject Component
// Author:  Nathan Shinn, Deloitte Digital
// Date:    Feb 14, 2017
// Description: Used to to link to a record for example, from a list
//
// Modifications: 
// 1.00: Created     
// ****************************************************************************************************************  
({
	navigateToRecord : function(component, event, helper) {
        
        //Get the SObject
        var selected = component.get("v.objSobject");
        //get the event to set for navigation
        var selectContactEvent = component.getEvent("selectEvent");
        //Set the event parameter and fire the event
        selectContactEvent.setParams({ "selectedObject" : selected });
        selectContactEvent.fire();
        
        console.log("::NS :: Selected events fired");
        
        /*if(device != 'DESKTOP')
        {
        var device = $A.get("$Browser.formFactor");
            var navEvent = $A.get("e.force:navigateToSObject");
            navEvent.setParams({
                recordId: component.get("v.objSobject").Id,
                slideDevName: "detail"
            });
            navEvent.fire(); 
        }
        else
        {
            window.location='/'+component.get("v.objSobject").Id+'';
        }*/
	}
})