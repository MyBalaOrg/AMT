/*
********************************************************************************************************************************************************************************************************************************************
*	@Name			PTC_AssetInstallationParentHelper.js
*	@Author			Deloitte Digital
*	@Created Date	10th May 2018
*	@Used By		PTC App	
********************************************************************************************************************************************************************************************************************************************
*	@Description	This is the javascript helper controller for PTC_AssetInstallationParent which processes requests
 					from the controller and calls the apex controller methods to process data and display results
                    back to the component.

********************************************************************************************************************************************************************************************************************************************
*	@Changes
********************************************************************************************************************************************************************************************************************************************	
*/

({
    /**
     * **********************************************************************************************************************
     * @Description
     * This method creates a new wrapper instance and updates the wrapperlist
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    createWrapperObject : function(component,event) {
        console.log('In createWrapperObject');
        var rowItemList = component.get("v.wrapperList");
        rowItemList.push({
            'assetId': '',
            'prodId' :'',
            'controlSys': '',
            'componentName' :'',
            'partNumber': '',
            'serialNumber': '',
            'hwVersion': '',
            'swVersion': '',
            'status' : '',
            'minHwVersion':'',
            'minSwVersion':'',
            'selected' : false
        });
        // set the updated list to attribute again    
        component.set("v.wrapperList", rowItemList);
        this.fireControlSysChangeEvent(component,event);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method generates component names for a locomotive id
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    getControlSystem : function(component,event) {
        console.log('In getControlSystem');
        var recordId = component.get("v.recordId");
        var action = component.get("c.getControlSystemsValues");
        action.setParams({
            LocoId:recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var controlSystemPickValues = response.getReturnValue();
                component.set("v.controlSystemPickValues",controlSystemPickValues);
                console.log('controlSystemPickValues----'+controlSystemPickValues);
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(action);
        
    },
    fireControlSysChangeEvent : function(component,event) {
        console.log("In handleControlSysChange");
        var controlSysSelectList = component.find("InputControlSys");
        var selectedControlSysValue = controlSysSelectList.get("v.value");
        var recordId = component.get("v.recordId");
        if(!$A.util.isEmpty(selectedControlSysValue)) {
            component.set("v.selectedControlSys",selectedControlSysValue);
            var sendMessage = $A.get("e.c:PTC_SelectionEvt");
            sendMessage.setParams({
                "message" :  selectedControlSysValue
            });
            sendMessage.fire();
        }
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method updates / inserts all the assets in the database.
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    saveAssets : function(component,event) {
        var updateWrapperList = component.get("v.wrapperList");
        var recordId = component.get("v.recordId");
        var location = component.get("v.location");
        var contact = component.get("v.contact");
        var selectedDate = component.get("v.selectedDate");
        var installedDate = this.formatDate(selectedDate);
        
        var listToUninstall = component.get("v.listToUninstall");
        var deleteWrapperListJSON = JSON.stringify(listToUninstall);
        var updateWrapperListJSON = JSON.stringify(updateWrapperList);
        var action = component.get("c.updateAssets");
        
        action.setParams({ 
            locoId : recordId, 
            listToUpdate : updateWrapperListJSON,
            listToUninstall : deleteWrapperListJSON,
            locationId :location.Id,
            contactId : contact.Id,
            installedDate : installedDate
        })
        component.set("{!v.isLoading}", true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("{!v.isLoading}", false);
                this.clearDeleteWrapperList(component,event);
                component.set("v.listToUninstall",[]);
                this.clearWrapperList(component,event);
                this.fireControlSysChangeEvent(component,event);
                //this.clearControlSysSelectList(component,event);
                this.getComponentNames(component,event);
                this.getAssetAssocationRecords(component,event);   
                this.fireToastEvent(component,event,"Success!","The records are updated successfully.","success");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " + 
                                      errors[0].message);
                        component.set("{!v.isLoading}", false);
                        this.fireToastEvent(component,event,"Error!",errors[0].message,"error");
                    }
                } else {
                    console.error("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action); 
        
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method validates all the assets before update / insert
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    validateAssetInstallation : function(component,event) {
        var validInstallation = true;
        var transactionDateField = component.find('Inputdate');
        var dateVal= transactionDateField.get('v.value');
        var locationField = component.find('InputLocation');
        var locationFieldValue = locationField.get('v.value');
        var contactField = component.find('InputContact');
        var contactFieldValue = contactField.get('v.value');
        var controlSystemField = component.find('InputControlSys');
        var controlSys= controlSystemField.get('v.value');
        var locationRec = component.get('v.location');
        var contactRec = component.get('v.contact');
        
        
        //Validate Date
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
                validInstallation = false;
            }else if(!/^\d{4}\-\d{1,2}\-\d{1,2}$/.test(dateVal)) {
                transactionDateField.set('v.errors',[{message:'Invalid Date Format.'}]);
                validInstallation = false;
            } else {
                transactionDateField.set('v.errors',null);
            }
        }
        //Validate Control Sys
        if($A.util.isEmpty(controlSys)){
            controlSystemField.set('v.errors',[{message:'Please make sure you selected a Control System.'}]);
            validInstallation = false;
        } else{
            controlSystemField.set('v.errors',null);
        }
        //Validate Date
        if($A.util.isEmpty(dateVal)){
            transactionDateField.set('v.errors',[{message:'Please make sure you selected a Date.'}]);
            validInstallation = false;
        } else{
            var transactionDate = new Date(dateVal);
            var currentDate = new Date();
            if(transactionDate > currentDate) {
                transactionDateField.set('v.errors',[{message:'Transaction Date cannot be greater than Todays date.'}]);
            } else transactionDateField.set('v.errors',null);
        }
        //Validate Location
        var locationField = component.find('InputLocation');
        var locationFieldValue = locationField.get('v.value');
        if($A.util.isEmpty(locationFieldValue) || $A.util.isEmpty(locationRec.Id)){
            validInstallation = false;
            locationField.set('v.errors',[{message:'Please make sure you selected a location.'}]);
        }
        //Validate Contact
        var contactField = component.find('InputContact');
        var contactFieldValue = contactField.get('v.value');
        if($A.util.isEmpty(contactFieldValue) || $A.util.isEmpty(contactRec.Id)){
            validInstallation = false;
            contactField.set('v.errors',[{message:'Please make sure you selected a Contact.'}]);
        }    
        var listToUninstall = component.get("v.listToUninstall");
        var nonConfList = [];
        
        //Validations
        if(validInstallation) {
            // The top fields are ok
            if(!this.hasDuplicatesOnUpdate(component,event)){
                //There are no duplicates
                if(this.areRequiredFieldsValidated(component,event)) {
                    //All Required Fields are filled
                    nonConfList = this.generateNonConfirmingList(component,event);
                    if(nonConfList.length > 0) {
                        //Some assets are non confirming
                        component.set('v.openModal',true);
                        component.set('v.nonConformingList',nonConfList);
                    } else {
                        var uninstallList = component.get("v.listToUninstall");
                        var areAllRowsEmpty = this.areAllRowsEmpty(component,event);
                        //Are there assets to be uninstalled when everything is validate 
                        if((uninstallList.length >0 && !areAllRowsEmpty) || 
                           (uninstallList.length >0 && areAllRowsEmpty) ||
                           (uninstallList.length < 1 && !areAllRowsEmpty)) {
                            //Save Assets in case
                            //1) If there are records to uinstall and no empty rows
                            //2) If there are records to uinstall and empty rows
                            //3) no records to uninstall but there are records to be updated
                            this.saveAssets(component,event);
                        } else {
                            //Clear list if no uninsallation and no rows to update
                            this.clearWrapperList(component,event);
                            this.fireControlSysChangeEvent(component,event);
                        }
                    }
                } else this.fireToastEvent(component,event,"Error!","Required Fields Missing!","error");
            } else this.fireToastEvent(component,event,"Error!","Duplicate Components Added!","error");
            
        }
    },    
    areRequiredFieldsValidated : function(component,event) {
        var isValid = true;
        if(! this.areAllRowsEmpty(component,event)) {
            var wrapperList = component.get('v.wrapperList');
            for(var i=0;i<wrapperList.length;i++) {
                var componentName = wrapperList[i].componentName;
                var prodId = wrapperList[i].prodId;
                var serialNumber = wrapperList[i].serialNumber;
                var swVersion = wrapperList[i].swVersion;
                var hwVersion = wrapperList[i].hwVersion;
                var assetId = wrapperList[i].assetId;
                var status = wrapperList[i].status
                if(status == 'INSERT') {
                    //Do not check assetId
                    if(componentName == '' || prodId == '' || serialNumber == '' || swVersion == '' || hwVersion == ''){
                        isValid = false;
                        break;
                    }
                } else {
                    //Check assetId
                    if(componentName == '' || prodId == '' || serialNumber == '' || swVersion == '' || hwVersion == '' || assetId == ''){
                        isValid = false;
                        break;
                    }
                }
            }
        } else isValid = true;
        
        return isValid;
        
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method invokes the showToast Event
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    fireToastEvent : function(component,event,title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    },
    forceRefresh : function(component,event) {
        $A.get("e.force:refreshView").fire();
    },
    
    clearControlSysSelectList : function(component,event) {
        var controlSysSelectList = component.find("InputControlSys");
        controlSysSelectList.set("v.value","");
    },
    
    clearWrapperList : function(component,event) {
        component.set("v.wrapperList","");
        var rowItemList =[];  
        rowItemList.push({
            'assetId': '',
            'prodId' :'',
            'controlSys': '',
            'componentName' :'',
            'partNumber': '',
            'serialNumber': '',
            'hwVersion': '',
            'swVersion': '',
            'status' : '',
            'minHwVersion':'',
            'minSwVersion':'',
            'selected' : false
        });                
        component.set("v.wrapperList",rowItemList);        
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method searches the location based on a search key
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    
    findLocations : function(component,searchKey){
        var action = component.get('c.findAllLocations');
        
        action.setParams({
            'searchKey' : searchKey,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.locationList', returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method searches the Contacts based on the search key
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    findContacts : function(component,searchKey){
        var action = component.get('c.findAllContacts');
        
        action.setParams({
            'searchKey' : searchKey,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.contactList', returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This formats the date to MM/DD/YYYY before insert/update
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    formatDate : function(strDate) {
        var splitString = [];
        splitString = strDate.split("-");
        var year = splitString[0];
        var month = splitString[1];
        var day = splitString[2];
        var newDate = month + "/" + day + "/" + year;
        return newDate;
    },
    /**
     * **********************************************************************************************************************
     * @Description
     * This method gets all the assets already installed on the locomotive
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    getAssetAssocationRecords : function(component,event) {
        var recordId = component.get("v.recordId");
        var controlSysSelectList = component.find("InputControlSys");
        var selectedControlSysValue = controlSysSelectList.get("v.value");
        var action = component.get("c.getExistingRecords");
        action.setParams({
            recordId : recordId,
            controlSystem : selectedControlSysValue
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var existingRecords = response.getReturnValue();
                component.set("v.assetDeleteWrapperList",existingRecords);
                console.log('assetDeleteWrapperList----'+existingRecords);
                var assetList = component.get("v.assetDeleteWrapperList");
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(action);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method finds the the checked assets for uninstallation
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    handleSelectedAssets: function(component, event, helper) {
        var assetList = component.get("v.assetDeleteWrapperList");
        var selectedAssets = [];
        var removeSelectedAssets = [];
        var k = 0;
        var l = 0;
        for (var i=0; i<assetList.length; i++){
            var c = assetList[i];
            if(c.isSelected) {
                selectedAssets[k] = c;
                k++; 
            } 
        }
        component.set("v.listToUninstall",selectedAssets);
        console.log('selectedAssets==='+selectedAssets);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method validates if each row is filed
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    validateRequiredFields: function(component, event) {
        var isValid = true;
        var allRows = component.get("v.wrapperList");
        for (var indexVar = 0; indexVar < allRows.length; indexVar++) {
            if (allRows[indexVar].componentName == '' || allRows[indexVar].partNumber == '' || allRows[indexVar].serialNumber == '' || allRows[indexVar].hwVersion == ''  || allRows[indexVar].swVersion == '') {
                isValid = false;
            }
        }
        return isValid;
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method validates any consecutive rows are duplicates
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    checkDuplicates : function(component,event) {
        var isDuplicate = true;
        var allRows = component.get("v.wrapperList");
        if(allRows.length >= 2) {
            if(allRows[allRows.length-1].componentName == allRows[allRows.length-2].componentName) {
                isDuplicate = false;
            }
            
        }
        return isDuplicate;
    },
    
    clearControlSysPickErrors : function(component,event) {
        var controlSystemField = component.find('InputControlSys');
        var controlSys= controlSystemField.get('v.value');
        if(!$A.util.isEmpty(controlSys)){
            controlSystemField.set('v.errors',null);
        }
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method clears uninstall list after save action
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    clearDeleteWrapperList : function(component,event) {
        var clearList = []
        clearList = component.get("v.assetDeleteWrapperList");
        if(clearList.length > 0) clearList = [];
        component.set("v.assetDeleteWrapperList",clearList);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method call the action to get component names
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    getComponentNames : function(component,event) {
        
        var controlSysSelectList = component.find("InputControlSys");
        var selectedControlSysValue = controlSysSelectList.get("v.value");
        
        if(!$A.util.isEmpty(selectedControlSysValue)) {
            this.getCompNames(component,selectedControlSysValue);
        }
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method gets all the component names for the selected control system
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    getCompNames : function(component,selectedControlSysValue) {
        console.log("In getComponentNames");
        var action = component.get("c.getComponentNames");
        var locoId = component.get("v.recordId");
        console.log('locoId'+locoId);
        action.setParams({
            locoId : component.get("v.recordId"),
            selectedControlSys:selectedControlSysValue
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var  componentNames = response.getReturnValue();
                component.set("v.componentNames",componentNames);
                console.log('componentname----'+componentNames);
            }
            else {
                alert('Error in getting data');
            }
        });
        $A.enqueueAction(action);
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method generates the non conforming list
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    generateNonConfirmingList : function(component,event) {
        var nonConfList = [];
        var wrapperList = component.get("v.wrapperList");
        for(var i =0 ;i<wrapperList.length;i++) {
            var hwVersion =  wrapperList[i].hwVersion;
            var swVersion =  wrapperList[i].swVersion;
            var minHwVersion =  wrapperList[i].minHwVersion;
            var minSwVersion = wrapperList[i].minSwVersion;
            if(hwVersion !== '' && swVersion !== '' && minHwVersion !== '' && minSwVersion !== '' && 
               minSwVersion != 'N/A' && minSwVersion != '0' && minHwVersion != 'N/A' && minHwVersion != '0' )
                if((hwVersion < minHwVersion) || (swVersion < minSwVersion)) {
                    nonConfList.push(wrapperList[i]);
                }
        }
        
        return nonConfList;
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method checks if all rows are empty
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    areAllRowsEmpty : function(component,event) {
        var wrapperList = component.get("v.wrapperList");
        var allRowsEmpty = false;
        for(var i = 0;i<wrapperList.length ;i++){
            var componentName = wrapperList[i].componentName;
            var prodId = wrapperList[i].prodId;
            var serialNumber = wrapperList[i].serialNumber;
            var swVersion = wrapperList[i].swVersion;
            var hwVersion = wrapperList[i].hwVersion;
            if(componentName == '' && prodId == '' && serialNumber == '' && swVersion == '' && hwVersion == ''){
                allRowsEmpty = true;
            } else {
                allRowsEmpty = false;
                break;
            }
        }
        return allRowsEmpty;
    },
    
    /**
     * **********************************************************************************************************************
     * @Description
     * This method checks for any duplicate entries before insert/update
     * **********************************************************************************************************************
     * @param	cmp		component passed from the controller	
     * **********************************************************************************************************************
     **/
    
    hasDuplicatesOnUpdate : function(component,event) {
        var wrapperList = component.get("v.wrapperList");
        var componentNamesSoFar = [];
        for(var i=0;i<wrapperList.length;i++) {
            componentNamesSoFar.push(wrapperList[i].componentName);
        }
        var valuesSoFar = Object.create(null);        
        for (var i = 0; i < componentNamesSoFar.length; ++i) {
            var value = componentNamesSoFar[i];
            if (value in valuesSoFar) {
                return true;
            }
            valuesSoFar[value] = true;
        }
        return false;
    },
    
    
})