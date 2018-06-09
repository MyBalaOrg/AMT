// ****************************************************************************************************************
// Title: SObject Search Component  Helper
// Author:  Nathan Shinn, Deloitte Digital
// Date:    January 31, 2017
// Description: Dynamic/generic search allows for the object and fields to be passed into the component
//              Uses SOSL to retrieve the records based on user input as they type.
// Modifications: 
// 1.00: Created  
// 2.00: Updated to redirect to the Position-specific search given the object parameter of "Position__p"  
// 3.00: Updated to work with Locker Service enabled 
// ****************************************************************************************************************

({
    /**
     * Perform the SObject search via an Apex Controller
     */
    doSearch : function(cmp) {
        // Get the search string, input element and the selection container
        var searchString = cmp.get("v.searchString");
        var fieldList = cmp.get("v.fieldList");
        $A.util.addClass(lookupList, 'slds-hide');
        //reset the search string
        var inputElement = cmp.find('lookup');
        var lookupList = cmp.find("lookuplist");
        var lookupListItems = cmp.find("lookuplist-items");
 		
        // Clear any errors and destroy the old lookup items container
        inputElement.set('v.errors', null);
       
        
        // We need at least 2 characters for an effective search
        if (typeof searchString === 'undefined' || searchString.length < 3)
        {
            // Hide the lookuplist
            $A.util.addClass(lookupList, 'slds-hide');
            return;
        }
 
        // Show the lookuplist
        $A.util.removeClass(lookupList, 'slds-hide');
 
        // Get the API Name
        var sObjectAPIName = cmp.get('v.sObjectAPIName');
 
        // Create an Apex action
        var action;
        
        if(sObjectAPIName == 'Position__P')
            action = cmp.get("c.lookupEmployeePosition");
        else
            action = cmp.get("c.lookup");
            
 
        // Mark the action as abortable, this is to prevent multiple events from the keyup executing
        action.setAbortable();
 
        // Set the parameters
        if(sObjectAPIName == 'Position__P')
            action.setParams({ "searchString" : searchString}); 
        else
            action.setParams({ "searchString" : searchString, "sObjectAPIName" : sObjectAPIName, "fieldList":fieldList});
                           
        // Define the callback
        action.setCallback(this, function(response) {
            var state = response.getState();
 
            // Callback succeeded
            if (cmp.isValid() && state === "SUCCESS")
            {
                // Get the search matches
                var matches = response.getReturnValue();
                
                //reset the results list
 				cmp.set("v.resultList", matches);
                   
            }
            else if (state === "ERROR") // Handle any error by reporting it
            {
                var errors = response.getError();
                console.log('::::ERROR::::'+errors);
                 
                if (errors) 
                {
                    if (errors[0] && errors[0].message) 
                    {
                        this.displayToast('Error', errors[0].message);
                    }
                }
                else
                {
                    this.displayToast('Error', 'Unknown error.');
                }
            }
        });
         
        // Enqueue the action                  
        $A.enqueueAction(action);                
    },
 
    
    /**
     * Handle the Selection of an Item
     */
    handleSelection : function(cmp, event) {
        // Resolve the Object Id from the events Element Id (this will be the <a> tag)
        var objectId = event.currentTarget.id;
        //var objectId = this.resolveId(event.getSource().get("v.id"));
        console.log(':::::::::>>'+objectId);

        // The Object label is the 2nd child (index 1)
        var objectLabel = event.currentTarget.innerText;//.children[1].innerText;
        
        // Log the Object Id and Label to the console
        console.log('::::::::objectId=' + objectId);
        console.log('::::::::objectLabel=' + objectLabel);
                 
        // Create the UpdateLookupId event
        var updateEvent = cmp.getEvent("updateLookupIdEvent");
         
        // Populate the event with the selected Object Id
        updateEvent.setParams({
            "sObjectId" : objectId
        });
 
        // Fire the event
        updateEvent.fire();
 
        // Update the Searchstring with the Label
        cmp.set("v.searchString", objectLabel);
 
        // Hide the Lookup List
        var lookupList = cmp.find("lookuplist");
        $A.util.addClass(lookupList, 'slds-hide');
 
        // Hide the Input Element
        var inputElement = cmp.find('lookup');
        $A.util.addClass(inputElement, 'slds-hide');
 
        // Show the Lookup pill
        var lookupPill = cmp.find("lookup-pill");
        $A.util.removeClass(lookupPill, 'slds-hide');
 
        // Lookup Div has selection
        var inputElement = cmp.find('lookup-div');
        $A.util.addClass(inputElement, 'slds-has-selection');
 
    },
 
    /**
     * Clear the Selection
     */
    clearSelection : function(cmp) {
        // Create the ClearLookupId event
        var clearEvent = cmp.getEvent("clearLookupIdEvent");
         
        // Fire the event
        clearEvent.fire();
 
        // Clear the Searchstring
        cmp.set("v.searchString", '');
 
        // Hide the Lookup pill
        var lookupPill = cmp.find("lookup-pill");
        $A.util.addClass(lookupPill, 'slds-hide');
 
        // Show the Input Element
        var inputElement = cmp.find('lookup');
        $A.util.removeClass(inputElement, 'slds-hide');
 
        // Lookup Div has no selection
        var inputElement = cmp.find('lookup-div');
        $A.util.removeClass(inputElement, 'slds-has-selection');
    },
 
    /**
     * Display a message
     */
    displayToast : function (title, message) 
    {
        var toast = $A.get("e.force:showToast");
 
        // For lightning1 show the toast
        if (toast)
        {
            //fire the toast event in Salesforce1
            toast.setParams({
                "title": title,
                "message": message
            });
 
            toast.fire();
        }
        else // otherwise throw an alert
        {
            alert(title + ': ' + message);
        }
    }
})