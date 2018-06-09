/*
********************************************************************************************************************************************************************************************************************************************
*	@Name			PTC_AssetInstallationParentController.js
*	@Author			Deloitte Digital
*	@Created Date	10th May 2018
*	@Used By		PTC App	
*	@Controller		PTC_AssetInstallationController
********************************************************************************************************************************************************************************************************************************************
*	@Description	This is the javascript controller for PTC_AssetInstallationParent which handles events and 
 					interaction and forwards the request to helper methods for further processing.

********************************************************************************************************************************************************************************************************************************************
*	@Changes
********************************************************************************************************************************************************************************************************************************************	
*/

({
    /**
     * **********************************************************************************************************************
     * @Description
     * This method creates a new wrapper instance and gets control sys values on init
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    doInit : function(component, event, helper) {  
        debugger;
        helper.createWrapperObject(component,event);
        helper.getControlSystem(component,event);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles popup confirm event and calls saveAsset upon confirmation
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    handlePopup : function(component,event,helper) {
        var message = event.getParam("message");
        if(message == "Confirm") {
            component.set("v.confirmPressed",true);
            component.set("v.cancelPressed",false);
            helper.saveAssets(component,event);
        }  else if(message == "Cancel") {
            component.set("v.confirmPressed",false);
            component.set("v.cancelPressed",true);
        }
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method clears placeholder Contact on focus
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/    
    clearPlaceholderContact: function(component,event,helper) {
        var obvalue = component.find('InputContact').get("v.value");
        component.find('InputContact').set("v.value", '');
        component.set("v.emptyContactPlaceholder", true);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method clears placeholder Location on focus
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/    
    clearPlaceholderLocation : function(component,event,helper) {
        component.find('InputLocation').set("v.value",'');
        component.set("v.emptyLocationPlaceholder",true);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles remove row event
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/    
    removeDeletedRow : function(component,event,helper) {
        console.log("Delete Row Clicked");
        var index = event.getParam("indexVar");
        var allRows = component.get("v.wrapperList");
        console.log("allRows"+allRows);
        allRows.splice(index,1);
        console.log("allRows"+allRows);
        component.set("v.wrapperList",allRows);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles add row event
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/  
    
    addNewRow : function(component,event,helper) {
        var wrapperList = component.get("v.wrapperList");
        if(helper.validateRequiredFields(component,event)) {
            
            if(helper.checkDuplicates(component,event)) {
                helper.createWrapperObject(component,event);
            }
            else {
                helper.fireToastEvent(component,event,"Error!","Duplicate Components Added!","error");
            }  
        }
        else {
            helper.fireToastEvent(component,event,"Error!","Required Fields Missing.","error");
        }
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles control sys change event
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/  
    
    onControlSysChange : function(component,event,helper) {
        helper.clearWrapperList(component,event);
        helper.fireControlSysChangeEvent(component,event);
        helper.getComponentNames(component,event);
        helper.getAssetAssocationRecords(component,event);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles Update Asset click
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/  
    
    installAssets : function(component,event,helper) {
        console.log('In Install Assets');
        helper.validateAssetInstallation(component,event);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles select event
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/  
    
    selectLocation : function(component,event,helper) {
        var locationId= event.target.id;
        component.set("v.locationId",locationId);
        var locationName = event.target.innerHTML;
        var newLocation = ({'Id' : locationId,'Name' : locationName});
        component.set("v.location",newLocation);
        var location = component.get('v.location');
        var locationField = component.find('InputLocation');
        if(locationId !== undefined || locationId !==''){
            location.Name = locationName;
            location.Id = locationId;
            component.set('v.location', location);
            locationField.set('v.value',locationName);
            locationField.set("v.placeholder",locationName);
            locationField.set('v.errors',null);
            component.set('v.locationList',[]); 
            
        } else locationField.set("v.placeholder",'Select Location');
        
        
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles location search
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/ 
    
    findLocations : function(component,event,helper) {
        if(event.keyCode !== 9){ 
            var locationField = component.find('InputLocation');
            var fieldValue = locationField.get('v.value');
            if(fieldValue.length >0){
                helper.findLocations(component, fieldValue); 
            } else{
                component.set('v.locationList',[]);
            }
        }
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles contact selection
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/ 
    selectContact: function(component,event,helper) {
        
        var contactId= event.target.id;
        component.set("v.contactId",contactId);
        var contactName = event.target.innerHTML;
        console.log('contactId'+contactId);
        console.log('contactName'+contactName);
        var newContact = ({'Id' : contactId,'Name' : contactName});
        component.set("v.contact",newContact);
        var contact = component.get('v.contact');
        var contactField = component.find('InputContact');
        if(contactId !== undefined || contactId !==''){
            contact.Name = contactName;
            contact.Id = contactId;
            component.set('v.contact', contact);
            contactField.set('v.value',contactName);
            contactField.set("v.placeholder",contactName);
            contactField.set('v.errors',null);
            component.set('v.contactList',[]); 
            
        } else contactField.set("v.placeholder",'Select Contact');
        
        
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles location search
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/ 
    findContacts : function(component,event,helper) {
        if(event.keyCode !== 9){ 
            var contactField = component.find('InputContact');
            var fieldValue = contactField.get('v.value');
            if(fieldValue.length >0){
                helper.findContacts(component, fieldValue); 
            } else{
                component.set('v.contactList',[]);
            }
        }        
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method handles asset uninstallation
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/ 
    removeItem: function(component, event, helper) {
        helper.handleSelectedAssets(component,event);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method validates control Sys select list
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/ 
    
    validateControlSystem : function(component,event,helper) {
        var controlSystemField = component.find('InputControlSys');
        var controlSys= controlSystemField.get('v.value');
        if($A.util.isEmpty(controlSys)){
            //validInstallation = false;
            controlSystemField.set('v.errors',[{message:'Please make sure you selected a Control System.'}]);
        } else{
            controlSystemField.set('v.errors',null);
        }
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method validates Date
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/ 
    validateTransactionDate : function(component,event,helper) {
        var transactionDateField = component.find('Inputdate');
        var dateVal= transactionDateField.get('v.value');
        if($A.util.isEmpty(dateVal)){
            transactionDateField.set('v.errors',[{message:'Please make sure you selected a Date.'}]);
        } else{
            var transactionDate = new Date(dateVal);
            var currentDate = new Date();
            if(transactionDate > currentDate)
            {
                transactionDateField.set('v.errors',[{message:'Transaction Date cannot be greater than Todays date.'}]);
            }else if(!/^\d{4}\-\d{1,2}\-\d{1,2}$/.test(dateVal)) {
                transactionDateField.set('v.errors',[{message:'Invalid Date Format.'}]);
            } else {
                transactionDateField.set('v.errors',null);
            }
        }
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method validates Location
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/ 
    validateLocation : function(component,event,helper) {
        var locationField = component.find('InputLocation');
        var locationFieldValue = locationField.get('v.value');
        var locationRec = component.get('v.location');
        if($A.util.isEmpty(locationFieldValue)){
            locationField.set('v.errors',[{message:'Please make sure you selected a location.'}]);
        }
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method validates contact
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/ 
    validateContact : function(component,event,helper) {
        var contactField = component.find('InputContact');
        var contactFieldValue = contactField.get('v.value');
        var contactRec = component.get('v.contact');
        if($A.util.isEmpty(contactFieldValue)){
            component.set("v.disableUpdateButton",true);
            contactField.set('v.errors',[{message:'Please make sure you selected a Contact.'}]);
        }
    },
})