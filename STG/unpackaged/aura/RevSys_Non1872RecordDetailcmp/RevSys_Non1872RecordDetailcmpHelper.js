({
    doInit: function(component) {
        var action = component.get("c.initPage");
        var recordType;
        var params = {"obsId": component.get("v.recordId"),
                      "targetPage" : "recordDetail"};
        action.setParams({ "params" : params });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("Non1872RecordDetailCmp c.initPage " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    if (!$A.util.isEmpty(returnValue.observation)) {
                        component.set("v.observation", JSON.parse(returnValue.observation));
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
                    if (!$A.util.isEmpty(returnValue.readOnlyFields)) {
                        component.set("v.readOnlyFields", JSON.parse(returnValue.readOnlyFields));
                    }
                    if (!$A.util.isEmpty(returnValue.editableFields)) {
                        component.set("v.editableFields", JSON.parse(returnValue.editableFields));
                    }
                    if (!$A.util.isEmpty(returnValue.requiredFieldMap)) {
                        component.set("v.requiredFieldMap", JSON.parse(returnValue.requiredFieldMap));
                    }
                    if (!$A.util.isEmpty(returnValue.scoreListString)) {
                        var scoreList = returnValue.scoreListString.split(',');
                        component.set("v.scoreList", scoreList);
                    }
                    if (!$A.util.isEmpty(returnValue.findingList)) {
                        component.set("v.findingList", JSON.parse(returnValue.findingList));
                    }
                    if (!$A.util.isEmpty(returnValue.needImprovementMap)) {
                        component.set("v.needImprovementMap", JSON.parse(returnValue.needImprovementMap));
                        this.setNeedImprovement(component)
                    }
                    if (!$A.util.isEmpty(returnValue.oneIsRequiredMap)) {
                        component.set("v.oneIsRequiredMap", JSON.parse(returnValue.oneIsRequiredMap));
                    }
                    if (!$A.util.isEmpty(returnValue.allFormScoreDefinitionMap)) {
                        var scoreMap = JSON.parse(returnValue.allFormScoreDefinitionMap);
                        var scoredefMap = [];         
                        for(var key in scoreMap){                     
                            if(recordType.Name ===  key){
                                var tempArray = scoreMap[key].split(";");
                                for(var key1 in tempArray){
                                    scoredefMap[key1] = tempArray[key1];                    
                                }
                                              
                            }
                        }
                        component.set("v.allFormScoreDefinitionArray", scoredefMap)
                    }
                    console.log("picklistMapMovementPosting : " + returnValue.picklistMapMovementPosting);
                    if(!$A.util.isEmpty(returnValue.picklistMapMovementPosting)) {
                        component.set("v.picklistMapMovementPosting", JSON.parse(returnValue.picklistMapMovementPosting));    
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

    setNeedImprovement : function(component) {
        var findingList = component.get("v.findingList");
        var needImprovementMap = component.get("v.needImprovementMap");
        var needImprovement = false;
        try {
            findingList.forEach(function(finding) {
                if (!$A.util.isEmpty(needImprovementMap[finding.Score__c + ""])) {
                    needImprovement = true;
                    throw BreakException;
                }
            });
        } catch (err) {
            
        }
        component.set("v.needImprovementRequired", needImprovement);
    },

    handleUpdate : function(component) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var action = component.get("c.updateObservation");
        
        var params = {"observationJSON" : JSON.stringify(component.get("v.observation")),
                      "findingListJSON" : JSON.stringify(component.get("v.findingList"))};
        console.log("*** observation : " + JSON.stringify(component.get("v.observation")));
        action.setParams({ "params" : params });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.updateObservation " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                } 
                else if (!$A.util.isEmpty(returnValue.observation)) {
                    component.set("v.observation", JSON.parse(returnValue.observation));
                //    amtrak.fireSuccessToastEvent(component, "", "The Test has been updated successfully.");
                    $A.get('e.force:refreshView').fire();
                    
                    var obsEmployeeInfoCmp = component.find("obsEmployeeInfo");
                    if (!$A.util.isEmpty(obsEmployeeInfoCmp)) {
                        //obsEmployeeInfoCmp
                    }
                }
            } else {
                console.log(response.getError());
            }
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
            console.log("-------------");
        });
        $A.enqueueAction(action);
    },
})