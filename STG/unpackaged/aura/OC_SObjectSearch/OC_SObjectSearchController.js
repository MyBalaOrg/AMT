// ****************************************************************************************************************
// Title: SObject Search Component Cotroller
// Author:  Nathan Shinn, Deloitte Digital
// Date:    January 31, 2017
// Description: Dynamic/generic search allows for the object and fields to be passed into the component
//              Uses SOSL to retrieve the records based on user input as they type.
// Modifications: 
// 1.00: Created     
// ****************************************************************************************************************

({
    /**
     * Search an SObject for a match
     */
    search : function(cmp, event, helper) {
        //console.log(':::searching:::');
        //setTimeout(function(){helper.doSearch(cmp);}, 500);
                
        helper.doSearch(cmp);        
    },
 
    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
        helper.handleSelection(cmp, event);
    },
     
    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
        helper.clearSelection(cmp);    
    }
})