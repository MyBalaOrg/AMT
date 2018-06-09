({
    
    doInit: function(component, event, helper) {
        helper.function1(component,event,helper);
       // helper.function2(component,event,helper);
        
        setTimeout(function(){
            helper.function2(component,event,helper);
        }, 1000);
        
    },
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
            component.get('v.simpleNewAsset');
            component.set("v.simpleNewAsset.PTC_Location__c",newLocation.Id); 
        } else locationField.set("v.placeholder",'Select Location');
        
        
    },
    validateLocation : function(component,event,helper) {
        var locationField = component.find('InputLocation');
        var locationFieldValue = locationField.get('v.value');
        var locationRec = component.get('v.location');
        if($A.util.isEmpty(locationFieldValue)){
            locationField.set('v.errors',[{message:'Please make sure you selected a location.'}]);
        }
    },
    clearPlaceholderLocation : function(component,event,helper) {
        component.find('InputLocation').set("v.value",'');
        component.set("v.emptyLocationPlaceholder",true);
    },
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
    clearPlaceholderContact: function(component,event,helper) {
        var obvalue = component.find('InputContact').get("v.value");
        component.find('InputContact').set("v.value", '');
        component.set("v.emptyContactPlaceholder", true);
    },
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
            component.get('v.simpleNewAsset');
            component.set("v.simpleNewAsset.PTC_Employee__c",contact.Id);
            
        } else contactField.set("v.placeholder",'Select Contact');
        
        
    },
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
    validateContact : function(component,event,helper) {
        var contactField = component.find('InputContact');
        var contactFieldValue = contactField.get('v.value');
        var contactRec = component.get('v.contact');
        if($A.util.isEmpty(contactFieldValue)){
            // component.set("v.disableUpdateButton",true);
            contactField.set('v.errors',[{message:'Please make sure you selected a Contact.'}]);
        }
    },
    
    validateSerialNumber : function(component,event,helper) {
        var serialNumberField = component.find('InputSerialNumber');
        var serialnumberValue = serialNumberField.get('v.value');
        if($A.util.isEmpty(serialnumberValue)){
            // component.set("v.disableUpdateButton",true);
            serialNumberField.set('v.errors',[{message:'Please make sure you that you enter the Serial Number.'}]);
        } else {
            serialNumberField.set('v.errors',null);
        }
    },
    selectProduct : function(component,event,helper) {
        var productId= event.target.id;
        component.set("v.productId",productId);
        var productName = event.target.innerHTML;
        var newProduct = ({'Id' : productId,'Name' : productName});
        component.set("v.product",newProduct);
        var product = component.get('v.product');
        var productField = component.find('InputProduct');
        if(productId !== undefined || productId !==''){
            product.Name = productName;
            product.Id = productId;
            component.set('v.product', product);
            productField.set('v.value',productName);
            productField.set("v.placeholder",productName);
            productField.set('v.errors',null);
            component.set('v.productList',[]); 
            component.get('v.simpleNewAsset');
            component.set("v.simpleNewAsset.PTC_Vendor_Part_Number__c",product.Id);
            
        } else productField.set("v.placeholder",'Select Product');
        
        
    },
    validateProduct : function(component,event,helper) {
        var productField = component.find('InputProduct');
        var productFieldValue = productField.get('v.value');
        var ProductRec = component.get('v.product');
        if($A.util.isEmpty(productFieldValue)){
            // productField.set('v.errors',[{message:'Please make sure you selected a product.'}]);
        }
    },
    clearPlaceholderProduct : function(component,event,helper) {
        component.find('InputProduct').set("v.value",'');
        component.set("v.emptyProductPlaceholder",true);
    },
    findProduct : function(component,event,helper) {
        if(event.keyCode !== 9){ 
            var productField = component.find('InputProduct');
            var fieldValue = productField.get('v.value');
            if(fieldValue.length >0){
                helper.findProduct(component, fieldValue); 
            } else{
                component.set('v.productList',[]);
            }
        }
    },
    selectCtrlSystemCompName : function(component,event,helper) {
        var ctrlSystemCompNameId= event.target.id;
        component.set("v.ctrlSystemCompNameId",ctrlSystemCompNameId);
        console.log(ctrlSystemCompNameId + "test");
        var ctrlSystemCompName = event.target.innerHTML;
        ctrlSystemCompName = ctrlSystemCompName.replace(/&amp;/g, '&');
        var newCtrlSystemCompName = ({'Id' : ctrlSystemCompNameId,'Name' : ctrlSystemCompName});
        component.set("v.ctrlSystemCompName",newCtrlSystemCompName);
        var cscn = component.get('v.ctrlSystemCompName');
        var ctrlSystemCompNameField = component.find('InputCtrlSystemCompName');
        if(ctrlSystemCompNameId !== undefined || ctrlSystemCompNameId !==''){
            cscn.Name = ctrlSystemCompName;
            cscn.Id = ctrlSystemCompNameId;
            component.set('v.ctrlSystemCompName', cscn);
            ctrlSystemCompNameField.set('v.value',ctrlSystemCompName);
            ctrlSystemCompNameField.set("v.placeholder",ctrlSystemCompName);
            ctrlSystemCompNameField.set('v.errors',null);
            component.set('v.ctrlSystemCompNameList',[]);
            component.get('v.simpleNewAsset');
            component.set("v.simpleNewAsset.PTC_Control_Systems_Component_Name__c",cscn.Id);
            
        } else ctrlSystemCompNameField.set("v.placeholder",'Select Control System - Component Name');
        
        
    },
    validateCtrlSystemCompName : function(component,event,helper) {
        var ctrlSystemCompNameField = component.find('InputCtrlSystemCompName');
        var ctrlSystemCompNameFieldValue = ctrlSystemCompNameField.get('v.value');
        var CtrlSystemCompNameRec = component.get('v.ctrlSystemCompName');
        if($A.util.isEmpty(ctrlSystemCompNameFieldValue)){
            ctrlSystemCompNameField.set('v.errors',[{message:'Please make sure you selected a Control System - Component Name.'}]);
        }
    },
    clearPlaceholderCtrlSystemCompName : function(component,event,helper) {
        component.find('InputCtrlSystemCompName').set("v.value",'');
        component.set("v.emptyCtrlSystemCompNamePlaceholder",true);
    },
    findCtrlSystemCompName : function(component,event,helper) {
        if(event.keyCode !== 9){ 
            var ctrlSystemCompNameField = component.find('InputCtrlSystemCompName');
            var fieldValue = ctrlSystemCompNameField.get('v.value');
            if(fieldValue.length >0){
                helper.findCtrlSystemCompNameField(component, fieldValue); 
            } else{
                component.set('v.ctrlSystemCompNameFieldList',[]);
            }
        }
    },
    
    toggleDisplaySection : function(component, event, helper) {
        component.set("v.displaySection", !component.get("v.displaySection"));
    },
    
    handleSaveAsset: function(component,event,helper){
        helper.validateAssetForm(component,event);
        
    },
    
    handleCancel : function(component,event,helper) {
       helper.gotoList(component,event);
    }
})