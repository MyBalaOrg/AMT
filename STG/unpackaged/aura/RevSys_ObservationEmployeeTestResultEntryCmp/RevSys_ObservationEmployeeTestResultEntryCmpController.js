({
	onchangeRegionProperty : function(component, event, helper) {
        var region = event.getSource().get("v.value");
        console.log("region : " + region);
        var picklistMapRegionState = component.get("v.picklistMapRegionState");
        console.log("picklistMapRegionState : " + JSON.stringify(picklistMapRegionState));
        console.log("picklistMapRegionState region : " + JSON.stringify(picklistMapRegionState[region]));
        var picklistMap = component.get("v.picklistMap");
        var testEntry = component.get("v.testEntryResult");
        console.log("*** picklistMapRegionState[region] : " + picklistMapRegionState[region]);
        if (!$A.util.isEmpty(picklistMapRegionState[region])) {
            if(picklistMapRegionState[region].length <= 0){
                testEntry.requiredFields.State__c = false;
            }else{
                testEntry.requiredFields.State__c = true;
            }        
        }else{
            testEntry.requiredFields.State__c = false;
        }
        
        console.log("testEntry.requiredFields : " + JSON.stringify(testEntry.requiredFields));
    //   	component.set("v.picklistMap.State__c", picklistMapRegionState[region]);
        component.set("v.statePicklist", picklistMapRegionState[region]);
        var stateInputCmp = component.find("State__c");
        stateInputCmp.set("v.errors", null);
        
        var picklistMapStateSubDivision = component.get("v.picklistMapStateSubDivision");
        console.log("** picklistMapStateSubDivision : " + JSON.stringify(picklistMapStateSubDivision));
        var picklistMap = component.get("v.picklistMap");
        var testEntry = component.get("v.testEntryResult");
        
        component.set("v.subdivisionPicklist", picklistMapStateSubDivision[region]);
        var subdiviInputCmp = component.find("Subdivision__c");
        subdiviInputCmp.set("v.errors", null);
        
    },
    
    setStateValOnCopy : function(component, event, helper) {
        var region = event.getParam('arguments').region;
        console.log("region : " + region); 
        var picklistMapRegionState = component.get("v.picklistMapRegionState");
        console.log("picklistMapRegionState : " + JSON.stringify(picklistMapRegionState));
        console.log("picklistMapRegionState region : " + JSON.stringify(picklistMapRegionState[region]));
        var picklistMap = component.get("v.picklistMap");
        var testEntry = component.get("v.testEntryResult");
        console.log("*** picklistMapRegionState[region] : " + picklistMapRegionState[region]);
        if (!$A.util.isEmpty(picklistMapRegionState[region])) {
            if(picklistMapRegionState[region].length <= 0){
                testEntry.requiredFields.State__c = false;
            }else{
                testEntry.requiredFields.State__c = true;
            }        
        }else{
            testEntry.requiredFields.State__c = false;
        }
        
        console.log("testEntry.requiredFields : " + JSON.stringify(testEntry.requiredFields));
        //   	component.set("v.picklistMap.State__c", picklistMapRegionState[region]);
        component.set("v.statePicklist", picklistMapRegionState[region]);
        var stateInputCmp = component.find("State__c");
        stateInputCmp.set("v.errors", null);
    },
    
    checkForTestCompletion: function(component, event, helper) {
        event.stopPropagation();
        var testEntry = component.get("v.testEntryResult");
        var isTargetAdmin = component.get("v.isTargetAdmin");
        console.log("** testEntry LAST : " + JSON.stringify(testEntry));
        var resultRequiredFieldMap = component.get("v.resultRequiredFieldMap");
        console.log("** resultRequiredFieldMap : " + JSON.stringify(resultRequiredFieldMap));
        //var statePicklist = component.get("v.picklistMap.State__c");
        var statePicklist = component.get("v.statePicklist");
        if ($A.util.isEmpty(statePicklist) && !$A.util.isEmpty(testEntry.requiredFields)) {
            testEntry.requiredFields.State__c = false;
        }
        
        if (testEntry.checkMethodReq) {
            testEntry.requiredFields.Speed__c = true;
        }else{
            testEntry.requiredFields.Speed__c = false;
        }

        var fieldId = event.getSource().getLocalId();
        var isNew = component.get("v.isNew");
        console.log("===== fieldId: " + fieldId);
        
        console.log("*** testEntry.requiredFields : " + JSON.stringify(testEntry.requiredFields));
        var completed = true;
        if (testEntry.isFRAtest) {
            var fieldName = "Date__c"
            var fieldCmp = component.find(fieldName);
            completed = completed && !$A.util.isEmpty(testEntry.obs[fieldName]);
            if (!$A.util.isEmpty(fieldCmp) && !isTargetAdmin) {
                var cmp = "";
                if (fieldCmp.length && fieldCmp.length > 0) {
                    fieldCmp.forEach(function(inputCmp) {
                        cmp = inputCmp;
                        completed = helper.validateEvaluationDate(testEntry, fieldName, cmp, completed);
                    });
                } else {
                    cmp = fieldCmp;
                    completed = helper.validateEvaluationDate(testEntry, fieldName, cmp, completed);
                }
            }
            completed = completed && !$A.util.isEmpty(testEntry.obs["Result__c"]);
        }
        else {
            for (var fieldName in testEntry.requiredFields) {
                
                if (testEntry.requiredFields[fieldName]) {
                    console.log(fieldName + " : " + testEntry.obs[fieldName]);
                    var fieldCmp = component.find(fieldName);
                    if(fieldName == "Date__c" && (isNew || (!isNew && (fieldId == "Date__c" || fieldId == "PersonallyObserved__c")))) {	
                        completed = completed && !$A.util.isEmpty(testEntry.obs[fieldName]); 
                        if (!$A.util.isEmpty(fieldCmp) && !isTargetAdmin) {
                            var cmp = "";
                            if (fieldCmp.length && fieldCmp.length > 0) {
                                fieldCmp.forEach(function(inputCmp) {
                                    cmp = inputCmp;
                                    completed = helper.validateEvaluationDate(testEntry, fieldName, cmp, completed);
                                });
                            } else {
                                cmp = fieldCmp;
                                completed = helper.validateEvaluationDate(testEntry, fieldName, cmp, completed);
                            }
                        }
                    } else if(fieldName == "MpSgNumber__c") { 
                        if (!$A.util.isEmpty(testEntry.obs["MpSg__c"]) && testEntry.obs["MpSg__c"] != "None") {
                            completed = completed && !$A.util.isEmpty(testEntry.obs[fieldName]);  
                        }
                    } else if(fieldName == "MpSg__c") { 
                        if (!$A.util.isEmpty(testEntry.obs["MpSg__c"]) && testEntry.obs["MpSg__c"] != "") {
                            if(testEntry.obs["MpSg__c"] == "MP"){
                                if ($A.util.isEmpty(testEntry.obs["MpSgNumber__c"]) && testEntry.obs["MpSgNumber__c"] == "") {
                                    completed = false;
                                }else{
                                    completed = completed && !$A.util.isEmpty(testEntry.obs["MpSgNumber__c"]);
                                }
                            }else if(testEntry.obs["MpSg__c"] == "Location"){
                                /*if ($A.util.isEmpty(testEntry.obs["NearestStationInterlocking__c"]) && testEntry.obs["NearestStationInterlocking__c"] == "") {
                                    completed = false;
                                }else{
                                    completed = completed && !$A.util.isEmpty(testEntry.obs["NearestStationInterlocking__c"]);
                                }*/
                                
                                if ($A.util.isEmpty(testEntry.obs["PersonalAreaCode__c"]) && testEntry.obs["PersonalAreaCode__c"] == "") {
                                    completed = false;
                                }else{
                                    completed = completed && !$A.util.isEmpty(testEntry.obs["PersonalAreaCode__c"]);
                                }
                            }
                        }else{
                            completed = completed && !$A.util.isEmpty(testEntry.obs["MpSg__c"]);
                        }
                    } /*else if(fieldName == "SpeedCheckMethod__c") {
                        if (!$A.util.isEmpty(testEntry.speedCheckMethodList) && !$A.util.isEmpty(testEntry.obs["Speed__c"]) && testEntry.obs["Speed__c"] != "") {
                            completed = completed && !$A.util.isEmpty(testEntry.obs[fieldName]);    
                        }
                    }*/ 
                    else if(fieldName == "MpSgNumber__c") {
                        if (!$A.util.isEmpty(testEntry.obs["MpSg__c"]) && testEntry.obs["MpSg__c"] != "None") {
                            testEntry.requiredFields.MpSgNumber__c = true;
                            completed = completed && !$A.util.isEmpty(testEntry.obs[fieldName]);
                        }
                    } else if(fieldName == "SpeedCheckMethod__c") {
                        if (!$A.util.isEmpty(testEntry.speedCheckMethodList) && !$A.util.isEmpty(testEntry.obs["Speed__c"]) && testEntry.obs["Speed__c"] != "") {
                            if (!$A.util.isEmpty(testEntry.speedCheckMethodList)) {
                                if(testEntry.speedCheckMethodList.length > 0){
                                    testEntry.requiredFields.SpeedCheckMethod__c = true;    
                                    completed = completed && !$A.util.isEmpty(testEntry.obs[fieldName]);
                                }
                            }
                        }
                    } else {
                        completed = completed && !$A.util.isEmpty(testEntry.obs[fieldName]);    
                    }
                } 
            }

            for (var fieldName in resultRequiredFieldMap) {
                completed = completed && !$A.util.isEmpty(testEntry.obs[fieldName]);    
            }
        }

        // Validate Speed length
        var speedCmp = component.find("Speed__c");
        if (!$A.util.isEmpty(speedCmp)) {
            if (!$A.util.isEmpty(testEntry.obs.Speed__c)) {
                if (testEntry.obs.Speed__c.toString().length > 3) {
                    speedCmp.set("v.errors",  [{message:"Speed is too large."}]);
                    completed = false;
                } else {
                    speedCmp.set("v.errors",  null);
                    completed = completed && !$A.util.isEmpty(testEntry.obs.Speed__c);
                }
            }
            else {
                speedCmp.set("v.errors",  null);
            }
        }
        console.log(" completed : " + completed);
        testEntry.completed = completed;
        component.set("v.testEntryResult", testEntry);

        // ETR-1036 [BB 4/3/2018]
        if (!$A.util.isEmpty(testEntry.obs.RegionProperty__c) && testEntry.obs.RegionProperty__c.length > 0) {
            var region = testEntry.obs.RegionProperty__c;
            var picklistMapRegionState = component.get("v.picklistMapRegionState");
            var statePicklist = component.get("v.statePicklist");
            if (statePicklist != picklistMapRegionState[region]) {
            //    component.set("v.picklistMap.State__c", picklistMapRegionState[region]);
                component.set("v.statePicklist", picklistMapRegionState[region]);                
            }
            
        }

        if (!$A.util.isEmpty(testEntry.obs.State__c) && testEntry.obs.State__c.length > 0) {
            var state = testEntry.obs.State__c;
            var picklistMapStateSubDivision = component.get("v.picklistMapStateSubDivision");
            console.log("** picklistMapStateSubDivision : " + JSON.stringify(picklistMapStateSubDivision));
            var subdivisionPicklist = component.get("v.subdivisionPicklist");
            if(!$A.util.isEmpty(picklistMapStateSubDivision[region])){
                var subdiviInputCmp = component.find("Subdivision__c");
                subdiviInputCmp.set("v.disabled", false);
            }
            if (subdivisionPicklist != picklistMapStateSubDivision[state]) {
                component.set("v.subdivisionPicklist", picklistMapStateSubDivision[state]);
            }
            
        }
        
        var params = {};
        params["updateEmployeeStatus"] = completed;
        params["rowIndex"] = component.get("v.rowIndex");
        console.log(" params : " + JSON.stringify(params));
        amtrak.fireMapParamEvent(component, "updateEmployeeStatus", params);
    },
    
    onchangeResult: function(component, event, helper){
        event.stopPropagation();
        
        var testEntry = component.get("v.testEntryResult");
        // Added resultRequiredFieldMap attribute to the component to control the completion check
        var resultRequiredFieldMap = component.get("v.resultRequiredFieldMap");
        if (testEntry.obs.Result__c == "C = Compliance") {
            resultRequiredFieldMap = {};
            testEntry.obs.NonComplianceRuleNumber__c = "";
            testEntry.obs.Comments__c = "";
        //    testEntry.obs.SupervisorsCommentSelection__c = "";
        }
        else {
            resultRequiredFieldMap.Comments__c = (testEntry.obs.Result__c != "C = Compliance") ? true : false;
        //    resultRequiredFieldMap.SupervisorsCommentSelection__c = (testEntry.obs.Result__c != "C = Compliance") ? true : false;
            resultRequiredFieldMap.NonComplianceRuleNumber__c = (testEntry.obs.Result__c != "C = Compliance") ? true : false;
        }

        var completed = false;
        for (var fieldName in testEntry.requiredFields) {
            if (testEntry.requiredFields[fieldName]) {
                completed = completed && !$A.util.isEmpty(testEntry.obs[fieldName]);
            }
        }
        testEntry.completed = completed;
        console.log("=====> resultRequiredFieldMap: " + JSON.stringify(resultRequiredFieldMap));
        component.set("v.testEntryResult", testEntry);
        component.set("v.resultRequiredFieldMap", resultRequiredFieldMap);
    },
    
    handleFetchSearchItemsEvent : function(component, event, helper) {
        event.stopPropagation();
        var auraId = event.getParam("auraId");
        var objectName;
        var fieldsToSearchList = [];
        
        if (auraId === "OperatedFromCode__c" || auraId === "OperatedToCode__c") {
        	objectName = "Station__c";
            fieldsToSearchList.push("Name");
            fieldsToSearchList.push("City__c");
            fieldsToSearchList.push("Code__c");
            fieldsToSearchList.push("State__c");
        }
        else if (auraId === "Train__c") {
        	objectName = "Train__c";
            fieldsToSearchList.push("Name");
        }
        else if (auraId === "NearestStationInterlocking__c") {
        	objectName = "Station__c";
            fieldsToSearchList.push("Name");
        }
        var action = component.get("c.getItemsForTypeaheadSearch");
        action.setParams({ 
            "searchKey" : event.getParam("origin"),
            "objectName" : objectName,
            "fieldsToSearchList" : JSON.stringify(fieldsToSearchList)
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.getItemsForTypeaheadSearch " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var typeaheadCmp = component.find(auraId);
                if (!$A.util.isEmpty(returnValue)) {
                    var listItems = JSON.parse(returnValue.listItems);
                    if (!$A.util.isEmpty(typeaheadCmp)) {
                        if (typeaheadCmp.length && typeaheadCmp.length > 0) {
                            typeaheadCmp.forEach(function(typeahead) {
                                if (index == typeahead.get("v.internalId")) {
                                    typeahead.set("v.isExpanded", true);
                                    typeahead.set("v.resultItems", listItems);
                                    typeahead.set("v.listItems", listItems);
                                }
                            });
                        } else {
                            typeaheadCmp.set("v.isExpanded", true);
                            typeaheadCmp.set("v.resultItems", listItems);
                            typeaheadCmp.set("v.listItems", listItems);
                        }
                    }
                }
            } else {
                component.set("v.errorMessage", response.getError());
            }
        });
		$A.enqueueAction(action);
    },
    
    handleSearchItemSelectedEvent : function(component, event, helper) {
        event.stopPropagation();
        var auraId = event.getParam("auraId");
        var selectedItem = event.getParam("selectedItem");
        console.log("selectedItem : " + selectedItem);
        if (!$A.util.isEmpty(selectedItem)) {
            if (auraId === "OperatedFromCode__c") {
                component.set("v.testEntryResult.obs.OperatedFromCode__c", selectedItem.recordId);
                component.set("v.testEntryResult.obs.OperatedFromCode__r.Name", selectedItem.label);
            }
            if (auraId === "OperatedToCode__c") {
                component.set("v.testEntryResult.obs.OperatedToCode__c", selectedItem.recordId);
                component.set("v.testEntryResult.obs.OperatedToCode__r.Name", selectedItem.label);
            }
            if (auraId === "Train__c") {
                component.set("v.testEntryResult.obs.Train__c", selectedItem.recordId);
                component.set("v.testEntryResult.obs.Train__r.Name", selectedItem.label);
            }
            if (auraId === "NearestStationInterlocking__c") { //Nearest_Station_Interlocking__c
                component.set("v.testEntryResult.obs.NearestStationInterlocking__c", selectedItem.recordId);
                component.set("v.testEntryResult.obs.NearestStationInterlocking__r.Name", selectedItem.label);
            }
        }
        else {
            if (auraId === "OperatedFromCode__c") {
                component.set("v.testEntryResult.obs.OperatedFromCode__c", "");
            }
            if (auraId === "OperatedToCode__c") {
                component.set("v.testEntryResult.obs.OperatedToCode__c", "");
            }
            if (auraId === "Train__c") {
                component.set("v.testEntryResult.obs.Train__c", "");
            }  
            if (auraId === "NearestStationInterlocking__c") {
                component.set("v.testEntryResult.obs.NearestStationInterlocking__c", "");
            }  
        }
        component.set("v.testEntryResult", component.get("v.testEntryResult"));
    },
    
    copyTestEntryResult : function(component, event, helper) {
        event.stopPropagation();
        var testEntryResult = component.get("v.testEntryResult");
        var testIndex = component.get("v.testIndex");
        console.log("*** testIndex : " + testIndex);
        var rowIndex = component.get("v.rowIndex");
        var params = {};
        params["testEntryResult"] = testEntryResult;
        params["testIndex"] = testIndex;
        params["rowIndex"] = rowIndex;
        // ETR-1203
        params["resultRequiredFieldMap"] = component.get("v.resultRequiredFieldMap");
        console.log("*** params : " + JSON.stringify(params));
        amtrak.fireMapParamEvent(component, "populateTestResult", params);
    },
    
    onchangeMpSg : function(component, event, helper) {
        var testEntryResult = component.get("v.testEntryResult");
        if(!$A.util.isEmpty(testEntryResult)){
        	var obs = testEntryResult.obs;
            if(!$A.util.isEmpty(obs)){ 
            	var mpSg = obs.MpSg__c;
                if(mpSg == "MP"){
                    obs.PersonalAreaCode__c = "";
                }else if(mpSg == "Location"){
                    obs.MpSgNumber__c = "";
                }else{
                    obs.PersonalAreaCode__c = "";
                    obs.MpSgNumber__c = "";
                }    
                testEntryResult.obs = obs;
                component.set("v.testEntryResult", testEntryResult);
            }
        }
    }
    
})