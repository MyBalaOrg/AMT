// ****************************************************************************************************************
// Component: SObject List Component COntroller
// Author:  Nathan Shinn, Deloitte Digital
// Date:    Feb 14, 2017
// Description: Used to render a list of records given a query or list of SObjects
//
// Modifications: 
// 1.00: Created     
// ****************************************************************************************************************  

({
    /**
     * Initial results
     */
	init : function(component, event, helper) {
        //initialize by running the sullpied query to load the component grid
        var qry = component.get("v.query")
        if(qry != null && qry != "")
        	helper.loadSobjects(component);
	},
    /**
     * Refresh the components results
     */
    requery : function(component, event, helper){
        console.log(":>>event query handled<<:");
  		//get the query set in the event's query parameter
  		var qry = event.getParam("query");

        //set the query
  		component.set("v.query", qry);
        
        //requery
        helper.loadSobjects(component);
    },
    /**
     * show a timer while results are generating
     */
     showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    /**
     * When the list is renedered, hide the spiner
     */
    hideSpinner : function (component, event, helper) {
       var spinner = component.find('spinner');
       var evt = spinner.get("e.toggle");
       evt.setParams({ isVisible : false });
       evt.fire();    
    }   
})