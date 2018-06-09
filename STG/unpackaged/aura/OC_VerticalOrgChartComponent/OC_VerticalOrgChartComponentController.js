/**
 *	*********************************************************************************************************************
 *	@Name			OC_VerticalOrgChartComponentController.js 
 * 	@Author			Luke Kanter, Deloitte Digital
 * 	@Created Date	14th Feb 2017	
 * 	@Used By		OC_VerticalOrgChartComponent.cmp
 *	**********************************************************************************************************************
 *	@Description	This is the javascript controller for OC_VerticalOrgChartComponent which handles events and 
 					interaction and forwards the request to helper methods for further processing.
 *	**********************************************************************************************************************
 *	@Changes
 	8th June 2017 - Modified to handle multiple contacts per position
 *	**********************************************************************************************************************
 **/ 

({
    /**
     * **********************************************************************************************************************
     * @Description
     * Init Method which calls helper methods in order to get the default tile.
     * **********************************************************************************************************************
     * @param	component	
     * @param	event
     * @param	helper
     * **********************************************************************************************************************
     **/
    doInit : function(component, event, helper) {
               
        // The function below is to allow for parsing url parameters in the future
        //helper.parseUrlAndQueryForContact(component);
        // Because no ID is passed to selectContact it returns the default contact: "Amtrak Summary"
        
        //Sarang : Changed the methodname from selectContact to selectEmployee 6/6/2017
        helper.selectEmployee(component, '');
        // Simultaneously query custom settings to grab the URL for the advanced search button
        // and the fields that should be searchable
        helper.querySearchUrl(component);
        helper.exportAllHelper(component);
        helper.querySearchFieldList(component);
        
        helper.queryExportFieldList(component);
        helper.queryTableFieldList(component);
        
        //get the job Aid Doc name from the custom label
        var jobAidDocName = $A.get("$Label.c.OC_JobAidDocName");
        component.set("v.documentName",jobAidDocName);
        
        // Check attributes and hide appropriate sections
        var displayHierarchy = component.get("v.showHierarchy");
        var displayCard = component.get("v.showCard");
        if(!displayHierarchy) {
            var hierarchyElement = component.find("hierarchy");
            $A.util.addClass(hierarchyElement, 'hide');
            var headerElement = component.find("header");
            $A.util.addClass(headerElement, 'hide');
            var headerButtonElements = component.find("headerButtons");
            $A.util.addClass(headerButtonElements, 'hide');
        }
        if(!displayCard) {
            var cardElement = component.find("contactCard");
            $A.util.addClass(cardElement, 'hide');
        }
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * Changes selected contact upon receiving event that a tile was clicked.
     * **********************************************************************************************************************
     * @param	component	
     * @param	event
     * @param	helper
     * **********************************************************************************************************************
     **/
    switchSelection : function(component, event, helper) {
        //Refresh the selected Contact
        component.set("v.selectedContact",null);
        
        //Recieve the selected contact from the tile component
        var selected = event.getParam("selectedObject");
        var selectedContact = event.getParam("selectedContact");
        
        //Set the Selected Contact from Small Contact Tile on this component
        if(typeof selectedContact != "undefined") {
            component.set("v.selectedContact",selectedContact);
         }
        console.log('switchSelection ID:' + selected);
        helper.selectEmployee(component, selected.position.Id,null);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * Changes selected contact upon receiving event that a contact was chosen in the search component.
     * **********************************************************************************************************************
     * @param	component	
     * @param	event
     * @param	helper
     * **********************************************************************************************************************
     **/ 
    handleUpdate : function(component, event, helper) {
        //Refresh the selected Contact
        component.set("v.selectedContact",null);
        var selectedId = event.getParam("sObjectId");
        //handle event from the search selection
        helper.handleSearchUpdate(component, selectedId);
       
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * Generates print preview of the organization chart.
     * **********************************************************************************************************************
     * @param	component	
     * @param	event
     * @param	helper
     * **********************************************************************************************************************
     **/
    
    printChart : function(component, event, helper) {
        window.print();
        
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * Call helper method to view the Job Aid
     * **********************************************************************************************************************
     * @param	component	
     * @param	event
     * @param	helper
     * **********************************************************************************************************************
     **/
    downloadJobAid : function(component,event,helper) {
        helper.downloadDocument(component);
    },
    
    
    
})