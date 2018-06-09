({
    function1 : function(component,event,helper){
        component.find("assetRecordCreator").getNewRecord(
            "Asset", // sObject type (objectApiName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newAsset");
                var error = component.get("v.newAssetError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
                // console.log("Record template initialized: " + rec.sobjectType);
                console.log("Record template initialized: " + rec);
            })
        )
    },
    function2 : function(component,event,helper){
        var action2 = component.get("c.getStatus");
        var StatusField = component.find("InputStatus");
        var optsStatus=[];
        //action2.setCallback(this, function(a) {
        //  var state = a.getReturnValue();
        //if(state===SUCCESS)
        
        
        action2.setCallback(this, function(a){
            var state = a.getState(); 
            if (state === "SUCCESS") {
                console.log('zdcsc===='+a.getReturnValue());
                //component.set("v.result", response.getReturnValue());
                
                
                for(var i=0;i< a.getReturnValue().length;i++){
                    optsStatus.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }
                StatusField.set("v.options", optsStatus);
            }
        });
        $A.enqueueAction(action2);
    },
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
    findProduct : function(component,searchKey){
        var ctrlSystemCompName = component.find('InputCtrlSystemCompName');
       // var ctrlSysCompName = ctrlSystemCompName.get("v.value");
       	var ctrlSysCompName = component.get('v.ctrlSystemCompNameId');
        var action = component.get('c.findAllProducts');
        console.log('searchKey=='+searchKey);
        console.log('ctrlSysCompName=='+ctrlSysCompName);
        action.setParams({
            'searchKey' : searchKey,
            'ctrlSysCompName' : ctrlSysCompName
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.productList', returnValue);
                console.log('productList=='+returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);
    },
    findCtrlSystemCompNameField : function(component,searchKey){
        var action = component.get('c.findAllCtrlSystemCompNameField');
        
        action.setParams({
            'searchKey' : searchKey,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.ctrlSystemCompNameList', returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);
    },
    gotoList : function (component, event) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Asset"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    validateAssetForm : function(component,event){
        component.set("v.simpleNewAsset.SerialNumber", component.get("v.simpleNewAsset.Name"));
        var validInstallation = true;
        var locationRec = component.get('v.location');
        var contactRec = component.get('v.contact');
        var productRec= component.get('v.product');
        var ctrlSystemCompNameRec = component.get('v.ctrlSystemCompName');
        
        //Validate Location
        var locationField = component.find('InputLocation');
        var locationFieldValue = locationField.get('v.value');
        if($A.util.isEmpty(locationFieldValue) || $A.util.isEmpty(locationRec.Id)){
            validInstallation = false;
            locationField.set('v.errors',[{message:'Please select a valid location.'}]);
        }
        //Validate Contact
        var contactField = component.find('InputContact');
        var contactFieldValue = contactField.get('v.value');
        if($A.util.isEmpty(contactRec.Id) || $A.util.isEmpty(contactFieldValue)){
            validInstallation = false;
            contactField.set('v.errors',[{message:'Please select a valid Contact.'}]);
        }
        //Validate Product
        var productField = component.find('InputProduct');
        var productFieldValue = productField.get('v.value');
        if($A.util.isEmpty(productFieldValue) || $A.util.isEmpty(productRec.Id)){
            validInstallation = false;
            productField.set('v.errors',[{message:'Please select a valid Product.'}]);
        }
        //Validate Control System - Component Name
        var ctrlSystemCompNameField = component.find('InputCtrlSystemCompName');
        var ctrlSystemCompNameFieldValue = ctrlSystemCompNameField.get('v.value');
        if($A.util.isEmpty(ctrlSystemCompNameFieldValue) || $A.util.isEmpty(ctrlSystemCompNameRec.Id)){
            validInstallation = false;
            console.log('test');
            ctrlSystemCompNameField.set('v.errors',[{message:'Please select a valid Control System - Component Name.'}]);
        }
        
        var serialNumberField = component.find('InputSerialNumber');
        var serialnumberValue = serialNumberField.get('v.value');
        if($A.util.isEmpty(serialnumberValue)){
            validInstallation = false;
            serialNumberField.set('v.errors',[{message:'Please make sure you that you enter the Serial Number.'}]);
        } else {
            serialNumberField.set('v.errors',null);
        }
        
        
        
        if(validInstallation)
        {
            console.log('validated==');
            this.saveAssetData(component, event);
        }
        
    },
    saveAssetData :function(component, event) {
        
        component.set("v.simpleNewAsset.Id", component.get("v.recordId"));
       // component.set("v.simpleNewAsset.SerialNumber", component.get("v.simpleNewAsset.Name"));
        var asset = component.get("v.simpleNewAsset");
        console.log(asset + "Testnewnew");
        component.find("assetRecordCreator").saveRecord(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                // record is saved successfully
                component.set("v.newAssetError", "");
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully.",
                    "type" : "success"
                });
                resultsToast.fire();
                
                var action = component.get("c.getListViews");
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var listviews = response.getReturnValue();
                        var navEvent = $A.get("e.force:navigateToList");
                        navEvent.setParams({
                            "listViewId": listviews.Id,
                            "listViewName": null,
                            "scope": "Asset"
                        });
                        navEvent.fire();
                    }
                });
                $A.enqueueAction(action);
                
            } else if (saveResult.state === "INCOMPLETE") {
                // handle the incomplete state
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                // handle the error state
                console.log('Problem saving contact, error: ' + JSON.stringify(saveResult.error));
                var errMsg = "";
                // saveResult.error is an array of errors, 
                // so collect all errors into one message
                for (var i = 0; i < saveResult.error.length; i++) {
                    errMsg += saveResult.error[i].message + "\n";
                }
                component.set("v.newAssetError", errMsg);
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        });
    }
    
    
})