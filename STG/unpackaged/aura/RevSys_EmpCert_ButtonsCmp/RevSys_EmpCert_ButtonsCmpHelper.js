({
    loadECRecord : function(component,event) {
        //amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        // Prepare the action to load account record
        var action = component.get("c.getEmpCertifications");
        action.setParams({"empCertId": component.get("v.recordId")});
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.ecRecord", JSON.parse(returnValue.ecRecord));
                component.set("v.loadComponent", JSON.parse(returnValue.hasPermission));
                var archivedRecord = component.get("v.ecRecord.Archived__c");
                console.log(archivedRecord);
                if(!archivedRecord) {
                    component.set("v.certifyBtn",false);
                }
                var now = new Date();
                now.setDate(now.getDate() + 30);
                var expDate = new Date(component.get("v.ecRecord.ExpirationDate__c"));
                console.log(expDate+' '+now);
                if(expDate <= now) {
                    component.set("v.expired",true);
                    
                } else {
                    component.set("v.expired",false);
                }
            } else {
                console.log('Problem getting ec record, response state: ' + state);
            }
            //amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        
        $A.enqueueAction(action);
        
    },
    printDetailsOnEC: function(component,event) {
        // Prepare the action to load account record
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var action = component.get("c.saveLastPrintedDetails");
        action.setParams({"empCertId": component.get("v.recordId")});
        var btnSource = event.target.id;
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log('Test');
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                } else {
                    if (!$A.util.isEmpty(returnValue.empCert)) {
                        component.set("v.ecRecord", JSON.parse(returnValue.empCert));
                        $A.get('e.force:refreshView').fire();
                    }
                }
            } else {
                console.log('Problem getting ec record, response state: ' + state);
            }
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
            
            //Drawloop Logic
            var recordId = component.get("v.recordId");
            var urlEvent = $A.get("e.force:navigateToURL");
            var perEngineerUrl = $A.get("$Label.c.RevSys_PrintCert_Permanent_Url_Engineer"); 
            var temUrl = $A.get("$Label.c.RevSys_PrintCert_Temp_Url");
            var perConductorUrl = $A.get("$Label.c.RevSys_PrintCert_Permanent_Url_Conductor");
            var conductor = $A.get("$Label.c.RevSys_ClassOfService_Conductor");
            var certType = component.get("v.ecRecord.CertificationType__c");
            
            
            if(temUrl !='skip' || perEngineerUrl !='skip' || perConductorUrl != 'skip'){ 
                if(btnSource =='permanentBtn'){
                    if(certType == conductor){
                        urlEvent.setParams({
                            "url":	perConductorUrl+recordId
                        });
                    }
                    else{
                        urlEvent.setParams({
                            "url":	perEngineerUrl+recordId
                        });
                    }
                }
                else if(btnSource=='temporaryBtn'){
                    urlEvent.setParams({
                        "url":	temUrl+recordId
                    }); 
                }
                urlEvent.fire();
            } 
        });
        $A.enqueueAction(action);
    },
    checkForCertification : function (component,event) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        
        var action = component.get("c.validateCertification");
        var params = {
            "empCertRecord" : JSON.stringify(component.get("v.ecRecord"))
        };
        action.setParams({"params": params});
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var message;
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    message = returnValue.errorMsg;
                    amtrak.fireErrorToastEvent(component, "Error!", message);
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                } else {
                    if (!$A.util.isEmpty(returnValue.successMsg)) {
                        message = returnValue.successMsg;
                        console.log(returnValue.redirectId);
                        amtrak.fireSuccessToastEvent(component,"",message);
                        if(!$A.util.isEmpty(returnValue.redirectId)) {
                            var newECID = returnValue.redirectId;
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": newECID,
                                "slideDevName": "detail"
                            });
                            navEvt.fire();
                        }
                        else {
                            $A.get('e.force:refreshView').fire(); 
                        }
                    }
                }
            } else {
                console.log('Problem getting ec record, response state: ' + state);
            }
            component.set("v.isOpenWarning", false);
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        
        $A.enqueueAction(action);
    }
})