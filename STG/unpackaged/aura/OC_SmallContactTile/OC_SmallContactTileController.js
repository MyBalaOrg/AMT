/**
 *	*********************************************************************************************************************
 *	@Name			OC_SmallContactTileController.js 
 * 	@Author			Luke Kanter, Deloitte Digital
 * 	@Created Date	2nd Feb 2017	
 * 	@Used By		OC_SmallContactTile.cmp
 *	**********************************************************************************************************************
 *	@Description	This is the javascript controller for OC_SmallContactTile which handles events and 
 					interaction and forwards the request to helper methods for further processing.
 *	**********************************************************************************************************************
 *	@Changes
 					05-31-2017 Modify the code to suppress the SOQLs to find the next level of
 *					subordinates
 *	**********************************************************************************************************************
 **/ 
({
	// Attempts to set attributes on initialization. In OrgChartTopLevel, this updates attributes for the subordinate tiles
    doInit : function(component, event, helper) {
 		var selected = component.get("v.selectedContact");
        helper.checkHiearchy(component,selected);
        console.log('selected '+selected);  
	},
    // Attempts to set attributes when selectedContact is changed by clicking a new contact. In OrgChartTopLevel, this updates attributes for the manager tile
    handleContactChange : function(component, event, helper) {
		var selected = event.getParam("value");
        helper.checkHiearchy(component,selected);
    	
	}, 
    // Communicates to parent component that this tile has been clicked
    fireSelection : function(component, event, helper) {
        var selected = component.get("v.selectedContact");
        var ctarget = event.currentTarget;
    	var index = ctarget.dataset.record;
		var selectedContact = selected.contacts[index];
        
        //var hasSub = component.get("v.hasSubs")
        if(selected.position.Id != '') {
            var selectContactEvent = component.getEvent("selectEvent");
            selectContactEvent.setParams({ "selectedObject" : selected,
                                          "selectedContact" : selectedContact});
            selectContactEvent.fire();
            console.log("events fired");
        } else {
            console.log("Position is vacant. Event not fired");
        }
    }
  
})