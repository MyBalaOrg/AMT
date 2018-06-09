({
    doInit: function(component) {
        var action = component.get("c.initPage");
        var teWrapper = {};
        var recordType;
        var params = {"obsId": component.get("v.recordId"),
                      "targetPage" : "recordDetail"};
        action.setParams({ "params" : params });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("Non1872RecordDetailCmp c.initPage " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var picklistMapFormTypeDivision = {};
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    if (!$A.util.isEmpty(returnValue.observation)) {
                        component.set("v.observation", JSON.parse(returnValue.observation));
                        var obs = component.get("v.observation");
                        teWrapper.obs = obs;
                        teWrapper.testNumber = obs.TestNumber__c;
                        teWrapper.completed = true;
                    }
                    if (!$A.util.isEmpty(returnValue.occupationSpecificReq)) {
                        component.set("v.occupationSpecificReq", JSON.parse(returnValue.occupationSpecificReq));
                        console.log("*** occupationSpecificReq : " + JSON.stringify(component.get("v.occupationSpecificReq")));
                        teWrapper.osr = JSON.parse(returnValue.occupationSpecificReq);
                    }
                    if (!$A.util.isEmpty(returnValue.recordType)) {
                        component.set("v.recordType", JSON.parse(returnValue.recordType));
                        recordType = JSON.parse(returnValue.recordType);
                    }
                    if (!$A.util.isEmpty(returnValue.fieldLabelMap)) {
                        component.set("v.fieldLabelMap", JSON.parse(returnValue.fieldLabelMap));
                    }
                    if (!$A.util.isEmpty(returnValue.picklistMap)) {
                        component.set("v.picklistMap", JSON.parse(returnValue.picklistMap));
                    }
                    if (!$A.util.isEmpty(returnValue.picklistMapFormTypeDivision)) {
                        picklistMapFormTypeDivision = JSON.parse(returnValue.picklistMapFormTypeDivision);
                        var picklistMap = component.get("v.picklistMap");
                        picklistMap.RegionProperty__c = picklistMapFormTypeDivision["Form-1872"];
                        component.set("v.picklistMap", picklistMap);
                    }
                    if (!$A.util.isEmpty(returnValue.readOnlyFields)) {
                        component.set("v.readOnlyFields", JSON.parse(returnValue.readOnlyFields));
                    }
                    if (!$A.util.isEmpty(returnValue.requiredFieldMap)) {
                        component.set("v.requiredFieldMap", JSON.parse(returnValue.requiredFieldMap));
                        teWrapper.requiredFields = JSON.parse(returnValue.requiredFieldMap);
                    }
                    if (!$A.util.isEmpty(returnValue.picklistMapRegionState)) {
                        component.set("v.picklistMapRegionState", JSON.parse(returnValue.picklistMapRegionState));    
                    }
                    if (!$A.util.isEmpty(returnValue.picklistMapStateSubDivision)) {
                        component.set("v.picklistMapStateSubDivision", JSON.parse(returnValue.picklistMapStateSubDivision));    
                    }                    
                    if (!$A.util.isEmpty(returnValue.speedCheckMethodList)) {
                        teWrapper.speedCheckMethodList = JSON.parse(returnValue.speedCheckMethodList);    
                    }
                    if (!$A.util.isEmpty(returnValue.checkMethodPermitted)) {
                        teWrapper.checkMethodPermitted = JSON.parse(returnValue.checkMethodPermitted);    
                    }
                    if (!$A.util.isEmpty(returnValue.checkMethodReq)) {
                        teWrapper.checkMethodReq = JSON.parse(returnValue.checkMethodReq);    
                    }
                    if ($A.util.isEmpty(teWrapper.obs.State__c)) {
                    	component.set("v.picklistMap.State__c", []);
                    }
                    if (!$A.util.isEmpty(returnValue.isFRA)) {
                        teWrapper.isFRAtest = returnValue.isFRA;
                    }
                    var PSList = JSON.parse(returnValue.permissionSetList);  
                    var allowedPS = JSON.parse(returnValue.allowedPS); 
                    var profileName =  JSON.parse(returnValue.ProfileName);                      
                            
                    for(var ps in PSList) {  
                        for(var i in allowedPS) {  
                            console.log('PSList[ps]'+PSList[ps]+'allowedPS[i]');
                            if (PSList[ps].PermissionSet.Name === allowedPS[i]) {                                               
                                component.set("v.isTargetAdmin", "true");  
                            }                                   
                        }                       
                    }
                    component.set("v.testEntry", teWrapper);
                    component.set("v.testEntry.OccupationSpecificRequirement__r.Test_Number__c", component.get("v.observation.TestNumber__c"));
                    component.set("v.loadDetail", "true");
                } else {
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                    console.log(returnValue.consolelog); 
                }
            } else {
                amtrak.fireErrorToastEvent(component, "", response.getError());
                console.log(response.getError());
            }
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        $A.enqueueAction(action);
    },

    handleUpdate : function(component) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var action = component.get("c.saveObservation");
        
        var params = {"observationJSON" : JSON.stringify(component.get("v.testEntry.obs"))};
        console.log("*** observation : " + JSON.stringify(component.get("v.testEntry.obs")));
        action.setParams({ "params" : params });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.saveObservation " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                } 
                else if (!$A.util.isEmpty(returnValue.observation)) {
                    component.set("v.observation", JSON.parse(returnValue.observation));
                    amtrak.fireSuccessToastEvent(component, "", "The Test has been updated successfully.");
                    $A.get('e.force:refreshView').fire();
                }
            } else {
                console.log("callback error:" + response.getError());
            }
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
            console.log("-------------");
        });
        $A.enqueueAction(action);
    },

})