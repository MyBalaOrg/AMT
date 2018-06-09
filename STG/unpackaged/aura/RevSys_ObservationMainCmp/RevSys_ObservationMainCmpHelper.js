({
    doInit: function(component) {
       
		debugger;
        var action = component.get("c.initPage");
        var params = {"targetPage" : "obsTab"};       
        action.setParams({ "params" : params });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("c.initPage " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    if (!$A.util.isEmpty(returnValue.observation)) {
                        component.set("v.observation", JSON.parse(returnValue.observation));
                    }
                    if (!$A.util.isEmpty(returnValue.recordTypeToDisplayTestNumbers)) {
                        component.set("v.recordTypeToDisplayTestNumbers", returnValue.recordTypeToDisplayTestNumbers);
                    }
                    
                    if (!$A.util.isEmpty(returnValue.fieldLabelMap)) {
                        component.set("v.fieldLabelMap", JSON.parse(returnValue.fieldLabelMap));
                        console.log("field label map : " + (returnValue.fieldLabelMap));
                    }
                    if (!$A.util.isEmpty(returnValue.picklistMap)) {
                        component.set("v.picklistMap", JSON.parse(returnValue.picklistMap));
                    }
                    if (!$A.util.isEmpty(returnValue.picklistMapFormTypeDivision)) {
                        component.set("v.picklistMapFormTypeDivision", JSON.parse(returnValue.picklistMapFormTypeDivision));
                    }
                    /*
                    if (!$A.util.isEmpty(returnValue.osrWrapperList)) {
                        component.set("v.osrWrapperList", JSON.parse(returnValue.osrWrapperList));
                    }
                    if (!$A.util.isEmpty(returnValue.currentUser)) {
                        component.set("v.currentUser", returnValue.currentUser);
                    }*/
                    if (!$A.util.isEmpty(returnValue.allRequiredFieldMap)) {
                        component.set("v.requiredFieldMap", JSON.parse(returnValue.allRequiredFieldMap));
                    }
                    if (!$A.util.isEmpty(returnValue.scoreListMap)) {
                        component.set("v.scoreListMap", JSON.parse(returnValue.scoreListMap));
                    }
                    if (!$A.util.isEmpty(returnValue.testQuestionMap)) {
                        component.set("v.testQuestionMap", JSON.parse(returnValue.testQuestionMap));
                    }
                    if (!$A.util.isEmpty(returnValue.needImprovementMap)) {
                        component.set("v.needImprovementMap", JSON.parse(returnValue.needImprovementMap));
                    }
                    if (!$A.util.isEmpty(returnValue.readOnlyFields)) {
                        var non1872Form = component.find("non-1872-form");
                        non1872Form.set("v.readOnlyFields", JSON.parse(returnValue.readOnlyFields));
                    }
                    if (!$A.util.isEmpty(returnValue.allEditableFieldMap)) {
                        component.set("v.editableFieldMap", JSON.parse(returnValue.allEditableFieldMap));
                    }
                    if (!$A.util.isEmpty(returnValue.allOneIsRequiredMap)) {
                        component.set("v.allOneIsRequiredMap", JSON.parse(returnValue.allOneIsRequiredMap));
                    }
                    if (!$A.util.isEmpty(returnValue.allFormCraftMap)) {
                        component.set("v.allFormCraftMap", JSON.parse(returnValue.allFormCraftMap));
                    }
                    if (!$A.util.isEmpty(returnValue.allFormScoreDefinitionMap)) {
                        component.set("v.allFormScoreDefinitionMap", JSON.parse(returnValue.allFormScoreDefinitionMap));
                        debugger;
                        var test = JSON.parse(returnValue.allFormScoreDefinitionMap);
                    }
                    
                    
                    if (!$A.util.isEmpty(returnValue.obsRecordTypes)) {
                        component.set("v.obsRecordTypes", JSON.parse(returnValue.obsRecordTypes));
                        var recordTypes = component.get("v.obsRecordTypes");
                    /*    var myrecordType = component.get("v.selectedRecordTypeId");      
                       	var non1872Cmp =  component.find("non-1872-form"); 
                        var selectTestCmp = component.find("select-test-cmp"); 
                        debugger;
                        if(myrecordType !=null && myrecordType !=""){ // selected record type   
                        	for(var i in recordTypes){
                            	var str = recordTypes[i].Id;                              
                                if(str.indexOf(myrecordType) != -1){                                 
                                    component.set("v.selectedRecordType", recordTypes[i]);
                                    selectTestCmp.set("v.theObject.RecordTypeId", recordTypes[i].Id);
                                    this.setNon1872Values(component, recordTypes[i].Name, recordTypes[i].Id);
                                }
                             }
                        }
                        else{ // default record type
                            component.set("v.selectedRecordType", recordTypes[0]);
                        }*/
                            
                        component.set("v.selectedRecordType", recordTypes[0]);
                        var selectedRecordType = component.get("v.selectedRecordType");
                        var recordTypeToDisplayTestNumbers = component.get("v.recordTypeToDisplayTestNumbers");
                        var editableFieldMap = component.get("v.editableFieldMap");
                        if (selectedRecordType.Id === recordTypeToDisplayTestNumbers) {
                            var testTree = component.find("select-test-tree");
                            testTree.set("v.editableFields", editableFieldMap[selectedRecordType.Name]);
                            
                            //
                            var picklistMap = component.get("v.picklistMap");
                            var picklistMapFormTypeDivision = component.get("v.picklistMapFormTypeDivision");
                            picklistMap.RegionProperty__c = picklistMapFormTypeDivision["Form-1872"];
                            component.set("v.picklistMap", picklistMap);
                        }
                                        
                    }
                    console.log("picklistMapRegionState : " + returnValue.picklistMapRegionState);
                    if (!$A.util.isEmpty(returnValue.picklistMapRegionState)) {
                        var selectTestTree = component.find("select-test-tree");
                        console.log("selectTestTree : " + selectTestTree);
                        if (!$A.util.isEmpty(selectTestTree)) {
                            selectTestTree.set("v.picklistMapRegionState", JSON.parse(returnValue.picklistMapRegionState));    
                        }                      
                    }
                    
                    if (!$A.util.isEmpty(returnValue.picklistMapStateSubDivision)) {
                        var selectTestTree = component.find("select-test-tree");
                        console.log("selectTestTree : " + selectTestTree);
                        if (!$A.util.isEmpty(selectTestTree)) {
                            selectTestTree.set("v.picklistMapStateSubDivision", JSON.parse(returnValue.picklistMapStateSubDivision));    
                        }                      
                    }
                    
                    console.log("picklistMapMovementPosting : " + returnValue.picklistMapMovementPosting);
                    if(!$A.util.isEmpty(returnValue.picklistMapMovementPosting)) {
                        var non1872Form = component.find("non-1872-form");
                        console.log("non1872Form : " + non1872Form);
                        if (!$A.util.isEmpty(non1872Form)) {
                            non1872Form.set("v.picklistMapMovementPosting", JSON.parse(returnValue.picklistMapMovementPosting));    
                        }                      
                    }
                    
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

    setNon1872Values: function(component, rtName, rtId, selectedRecordType) {
        console.log("inside non 1872");
        var non1872Form = component.find("non-1872-form");
        var selectEmp = component.find("select-employee-cmp");
        var rt1872 = component.get("v.recordTypeToDisplayTestNumbers");
        var filterMap = {};
        selectEmp.set("v.filterMap", filterMap);

        var testQuestionMap = component.get("v.testQuestionMap");
        var requiredFieldMap = component.get("v.requiredFieldMap");
        var editableFieldMap = component.get("v.editableFieldMap");
        var needImprovementMap = component.get("v.needImprovementMap");
        var scoreListMap = component.get("v.scoreListMap");
        var allOneIsRequiredMap = component.get("v.allOneIsRequiredMap");
        var allFormCraftMap = component.get("v.allFormCraftMap");
        filterMap.Craft = allFormCraftMap[rtId]; // Set the limit search by craft for non-1872
        console.log("filterMap In Main : " + JSON.stringify(filterMap));
        selectEmp.set("v.filterMap", filterMap);
        selectEmp.set("v.selectedRecordType", selectedRecordType);
        
        //craft
        non1872Form.set("v.findingList", testQuestionMap[rtName]);
        non1872Form.set("v.editableFields", editableFieldMap[rtName]);
        non1872Form.set("v.needImprovementMap", needImprovementMap[rtId]);
        non1872Form.set("v.scoreList", scoreListMap[rtId]);
        non1872Form.set("v.requiredFieldMap", requiredFieldMap[rtId]);
        non1872Form.set("v.oneIsRequiredMap", allOneIsRequiredMap[rtId]);
        
        var selectEmpCmp = component.find("select-employee-cmp");
        if(!$A.util.isEmpty(selectEmpCmp)){
            var searchTabularResultCmp = selectEmpCmp.find("search-employee-cmp");
            if(!$A.util.isEmpty(searchTabularResultCmp)){
                var searchModalCmp = searchTabularResultCmp.find("search-result");        
                if(!$A.util.isEmpty(searchModalCmp)){
                    var filteredList = searchModalCmp.get("v.filteredList");
                    if(!$A.util.isEmpty(filteredList) && rtName != "Form-1872"){
                        selectEmp.empSearchNon1872RTChange(); 
                    }else{
                        searchModalCmp.set("v.filteredList", null);  
                    }
                } 
            }
        }
    },

    createNon1872: function(component) {
        debugger;
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        console.log("RevSys_ObservationMainCmpHelper createNon1872 - START");       
        var observation = component.get("v.observation");
        var recordType = component.get("v.selectedRecordType");
        var selectedEmpList = component.get("v.selectedEmpList");
        var rtName = recordType.Name;
        var currentTime = new Date();
        var currentTimeStr = currentTime.getFullYear().toString()+"-"+(currentTime.getMonth()+1).toString()+"-"+(currentTime.getDate()-1).toString();
        console.log("*** currentTimeStr : " + JSON.stringify(currentTimeStr));
        var currentHr = currentTime.getHours();
		var currentMin = currentTime.getMinutes();
        if((currentHr.toString()).length == 1){currentHr = "0"+currentHr;}
        if((currentMin.toString()).length == 1){currentMin = "0"+currentMin;}
        
        console.log("Date__C"+currentTime);
        observation.RecordTypeId = recordType.Id;
        observation.Employee__c = selectedEmpList[0].recordId; 
        //default date/time for 1878 form
        //
       	var recordTypeName = recordType.Name;        
        if (recordTypeName.indexOf("1878") != -1 ) {
            observation.Date__c= currentTimeStr;
            observation.TimeHH__c = currentHr;            
            observation.TimeMM__c=  currentMin;           
        } 
        var action = component.get("c.insertNon1872");
        var non1872Form = component.find("non-1872-form");

        
        
        var params = {"observationJSON" : JSON.stringify(observation),
                      "rtName" : rtName};     
        
        console.log("*** params : " + JSON.stringify(params));

        action.setParams({ "params" : params });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("c.insertNon1872 " + state);
            debugger;
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    if (!$A.util.isEmpty(returnValue.observation)) {
                        console.log("has observation!!!!!")
                        console.log("*** returnValue.observation : " + returnValue.observation);
                        component.set("v.observation", JSON.parse(returnValue.observation));
                        non1872Form.set("v.observation", JSON.parse(returnValue.observation));
                        var findings = JSON.parse(returnValue.findings);
                        if (recordTypeName.indexOf("1876") != -1 ) {
                            findings.splice(0, 14);
                        }
                        non1872Form.set("v.findingList", findings);
                        component.set("v.nextButtonLabel", "Submit");                  
                      //  var Obs = JSON.parse(returnValue.observation);
                      //  console.log("ObsID$$"+Obs.Id);
                    }              
                } else {
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                    console.log(returnValue.consolelog); 
                }
            } else {
                amtrak.fireErrorToastEvent(component, "", response.getError());
                console.log(response.getError());
            }
            console.log("RevSys_ObservationMainCmpHelper createNon1872 - END");
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        $A.enqueueAction(action);
    },
    
    updateNon1872: function(component) {       
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        console.log("RevSys_ObservationMainCmpHelper updateNon1872 - START");
        var observation = component.get("v.observation");
        var recordType = component.get("v.selectedRecordType");
        var selectedEmpList = component.get("v.selectedEmpList");        
        var non1872Cmp = component.find("non-1872-form");       
        var testScoreCmp =  non1872Cmp.find("testScore-cmp");       
        var findingList = testScoreCmp.get("v.findingList");
        
        debugger;
        
        
        // For some reason the Main component's observation doesn't have the latest observation values
        // The workaround: we have to get observation from the child component "non-1872-form" and use it in the update.
        var obsToUpdate = non1872Cmp.get("v.observation");
        if(obsToUpdate.TimeHH__c == "--"){
            obsToUpdate.TimeHH__c = undefined;
        }
        if(obsToUpdate.TimeMM__c == "--"){
            obsToUpdate.TimeMM__c = undefined;
        }
        console.log("*** obsToUpdate : " + JSON.stringify(obsToUpdate));
        var rtName = recordType.Name;        
        //observation.RecordTypeId = recordType.Id;
        //observation.Employee__c = selectedEmpList[0].recordId;      
        
        var action = component.get("c.updateObservation");
        var non1872Form = component.find("non-1872-form");
        var submitForm = component.find("test-submit");
        
        var params = {"observationJSON" : JSON.stringify(obsToUpdate),
                      "rtName" : rtName,
                      "findingListJSON" : JSON.stringify(findingList)};     
        
        console.log("*** params : " + JSON.stringify(params));
        action.setParams({ "params" : params });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("c.updateNon1872 " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log("*** returnValue : " + returnValue);
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    amtrak.fireSuccessToastEvent(component, "", "Observation have been submitted successfully.");
                    if (!$A.util.isEmpty(returnValue.observation)) {
                        component.set("v.resEmpSumObservation", JSON.parse(returnValue.observation));
                        console.log("has observation!!!!!" + returnValue.observation);
                        var thePath = component.find("thePath");
                        var finalStep = thePath.find("finalStep")
                        $A.util.addClass(finalStep, "slds-is-complete");
                        $A.util.removeClass(finalStep, "slds-is-active");
                        $A.util.removeClass(finalStep, "slds-is-current");
                        $A.util.addClass(component.find("nextbuttonFooter"), "slds-hide");
                        $A.util.addClass(component.find("nextbuttonPath"), "slds-hide");
                        //resEmpSummList
                        if (!$A.util.isEmpty(returnValue.resEmpSummList)) {
                            component.set("v.resEmpSummList",JSON.parse(returnValue.resEmpSummList)); 
                            console.log("*** resEmpSummList : " + JSON.stringify(component.get("v.resEmpSummList")));
                        }
                        /*if (!$A.util.isEmpty(returnValue.resEmpSummMap)) {
                            var resEmpSummMap = JSON.parse(returnValue.resEmpSummMap);
                            console.log("*** resEmpSummMap : " + JSON.stringify(resEmpSummMap));
                            component.set("v.resEmpSummMap",resEmpSummMap); 
                            
                            var empKey = [];                		
                            for(var key in resEmpSummMap){
                                console.log("resEmpSummMap[key] : " + JSON.stringify(resEmpSummMap[key]));
                                empKey.push({value:resEmpSummMap[key], key:key});
                            }                        
                            console.log("empKey : " + JSON.stringify(empKey));
                            component.set("v.resEmpSummList",empKey); 
                        }  */
                                                
                        var testMap = JSON.parse(returnValue.totalTests);
                        console.log("*** testMap : " + JSON.stringify(testMap));
                        var msg=[];
                        // Added script to show the final message after submission
                       	if (testMap != null){ 
                            var i=0;
                             for (var key in testMap) {
                                msg[i] = testMap[key];
                                i++; 
                             }
                         }  
                        if (!$A.util.isEmpty(returnValue.observationNumber)) {
                            var observationNumber = returnValue.observationNumber;
                            msg.push("Observation Number: " + observationNumber);
                        }
                        component.set("v.SubmitStatusMessage", "SUCCESSFULLY SUBMITTED");
                        component.set("v.submitMessage",msg); 
                    }              
                } else {
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                    console.log(returnValue.consolelog); 
                }
            } else {
                amtrak.fireErrorToastEvent(component, "", response.getError());
                console.log(response.getError());
            }
            console.log("RevSys_ObservationMainCmpHelper updateNon1872 - END");
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        $A.enqueueAction(action);
    },

    setNon1872Observation: function(component) {
        var non1872Form = component.find("non-1872-form");
        var selectedEmpList = component.get("v.selectedEmpList");
        var observation = component.get("v.observation");
        
        if (!$A.util.isEmpty(selectedEmpList)) {
            console.log("==== setting observation");
            var employee = selectedEmpList[0];
            var otherFields = employee.additionalFieldandValueMap;
            observation.Division__c = otherFields.Division__c;
            observation.Region__c = otherFields.Region__c;
            observation.Occupation__c = otherFields.Occupation__c;
           

        }

        non1872Form.set("v.observation", observation);
    },
    
    validatePage: function(component, selectionState){
        var varObservation = component.get("v.observation");  
        var errorMessage = null;    
        var validationMap = {};     
        var non1872Cmp = component.find("non-1872-form");        
        var obsEditCmp = non1872Cmp.find("obsEditCmp");       
        var testScoreCmp =  non1872Cmp.find("testScore-cmp");    
        if(selectionState==2){
        	validationMap = obsEditCmp.validateInfo();
            if(validationMap.proceed){
                validationMap.message = null;
            }
            errorMessage = testScoreCmp.validateScores();
            validationMap.scoreErrMsg = errorMessage;
            if (errorMessage != null && !$A.util.isEmpty(errorMessage)) {
                validationMap.proceed = false;
            }
        	console.log("*** returnVal  validateScore: " + errorMessage);
    	}         
        return validationMap;        
    },
    
    loadTestSelection: function(component, selectionState){
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var selectedEmpList = component.get("v.selectedEmpList");
        
        var action = component.get("c.loadTestSelection");
        var params = {"selectedEmployees" : JSON.stringify(selectedEmpList)};
        console.log("** params in loadTestSelection : " + JSON.stringify(params));
        action.setParams({ "params" : params });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log("c.loadTestSelection " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    if (!$A.util.isEmpty(returnValue.testWithObservationsList)) {
                        var selectTestTreeCmp = component.find("select-test-tree");
                        var testWithObservationsList = JSON.parse(returnValue.testWithObservationsList);
                        
                        if (!$A.util.isEmpty(testWithObservationsList)) {
                            testWithObservationsList.forEach(function(testWithObs){
                                if (!$A.util.isEmpty(testWithObs.entryList)) {
                                    testWithObs.entryList.forEach(function(entry){
                                        entry.obs.FormType__c = "Form-1872";
                                    });
                                }
                            });
                        }
                        
                        selectTestTreeCmp.set("v.testWithObservationsList", testWithObservationsList);
                        selectTestTreeCmp.set("v.filteredList", testWithObservationsList);
                        
                        //set speed check methods
                    //    var testSpeedCheckMap = JSON.parse(returnValue.testSpeedCheckMap); 
                    //    if(testSpeedCheckMap != undefined){
                    //    	selectTestTreeCmp.set("v.testSpeedCheckMap", testSpeedCheckMap);
                    //    }
                        
                        //check speed field required
					//	var testCheckMethodReq = JSON.parse(returnValue.testCheckMethodReq); 
                    //    if(testCheckMethodReq != undefined){
                    //    	selectTestTreeCmp.set("v.testCheckMethodReq", testCheckMethodReq);
                    //    }
                    //    selectTestTreeCmp.createcreate1872
                    //    TreeGrid();
                    }              
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
    
    loadTestResultSection : function(component) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var selectTestTreeCmp = component.find("select-test-tree");
        var testWithObsList = selectTestTreeCmp.get("v.testWithObservationsList");
    //    var osrWrapperList = component.get("v.osrWrapperList");
        var selectedList = [];
        var selff = this;
        
        if (!$A.util.isEmpty(testWithObsList)) {
            
            testWithObsList.forEach(function(testWithObs){
                var selectedTest = selff.clone(testWithObs);
                if(selectedTest.selected){
                    console.log("### selectedTest selected : " + selectedTest.selected);
                    var empFilteredList = [];
                    if (!$A.util.isEmpty(selectedTest.entryList)) {
                        selectedTest.entryList.forEach(function(emp){
                            if(emp.selected){
                                empFilteredList.push(emp);
                            }
                        });
                        if(empFilteredList.length > 0){
                            selectedTest.entryList = empFilteredList;
                            selectedList.push(selectedTest);
                        }
                    }
                }
            });
            
            
            var requiredFieldMap = component.get("v.requiredFieldMap");
            var selectedRecordType = component.get("v.selectedRecordType");
            var rtId = selectedRecordType.Id;
            if (!$A.util.isEmpty(selectedList)) {
                selectedList.forEach(function(filter){
                    filter.percent = "0.00%";
                    if(!$A.util.isEmpty(filter.entryList)){
                        filter.entryList.forEach(function(entry){
                            entry.requiredFields = requiredFieldMap[rtId];
                            
                            /*var speedCheckMethodList = [];
                            if(!$A.util.isEmpty(osrWrapperList)){
                                osrWrapperList.forEach(function(osrWrapper){
                                    if(osrWrapper.testNumber == entry.testNumber){
                                        speedCheckMethodList = osrWrapper.speedCheckMethodList;
                                    }
                                });
                            }
                            entry.speedCheckMethodList = speedCheckMethodList;*/
                            
                            //set a result
                            //entry.Result__c = "C = Compliance";
                            
                            //set a personally observed
                            // Users don't want this preselected
                        //    entry.PersonallyObserved__c = "Yes";
                        });  
                    }    
                });
                
            }
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
            console.log("*** selectedList in Main : " + JSON.stringify(selectedList));
            selectTestTreeCmp.set("v.selectedList", selectedList);
        }
    },
    
    clone : function(obj) {
        if (null == obj || "object" != typeof obj) return obj;
        var copy = obj.constructor();
        for (var attr in obj) {
            if (obj.hasOwnProperty(attr)) copy[attr] = obj[attr];
        }
        return copy;
    },
    
    create1872 : function(component) {
    	//get filtererd list
    	amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
    	var selectTestTreeCmp = component.find("select-test-tree");
        var selectedList = selectTestTreeCmp.get("v.selectedList");
        var entryFieldList = ["Result__c","PersonallyObserved__c","NonComplianceRuleNumber__c","DiscussedWithEmployee__c","SupervisorsCommentSelection__c","Comments__c","Date__c","TimeHH__c","TimeMM__c","MpSg__c","MpSgNumber__c","Speed__c","SpeedCheckMethod__c","RailroadRule__c","RegionProperty__c","State__c","TrainDescription__c","PersonalAreaCode__c"];
        if(!$A.util.isEmpty(selectedList)){
            var completedCount = 0;
            selectedList.forEach(function(filter){
                console.log("filter.percent : " + filter.percent);
                var percent = filter.percent.replace("%", "");
                console.log(Number(percent));
                if(Number(percent) == 100){
                    completedCount++;
                }
            });
            
            if(completedCount == selectedList.length){
                var testEntry = [];
                selectedList.forEach(function(filter){
                    if(!$A.util.isEmpty(filter.entryList)){
                        filter.entryList.forEach(function(entry){
                            /*
                            entryFieldList.forEach(function(fieldName) {
                                entry.obs[fieldName] = entry[fieldName];
                                entry[fieldName] = undefined;
                            });*/
                            entry.obs["RecordTypeId"] = component.get("v.selectedRecordType").Id;                            
                            testEntry.push(entry);
                        });
                    }
                });
                console.log("testEntry JSON : " + JSON.stringify(testEntry));
                var params = {
                    "testEntryJSON" : JSON.stringify(testEntry)
                };
                this.handleSaveAndSubmit1872(component, params);
            }
        }
    },
    
    handleSaveAndSubmit1872 : function(component, params) {        
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);        
        var action = component.get("c.insertForm1872");
        action.setParams({ "params" : params });
        console.log("-------------");
        console.log("Action: c.insertForm1872");
        console.log("*** params in Save & Submit : " + JSON.stringify(params));
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.insertForm1872 " + state);
            
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                } else {
                    if (!$A.util.isEmpty(returnValue.trWrapperList)) {
                        var thePath = component.find("thePath");
                        var finalStep = thePath.find("step4");
                        $A.util.addClass(finalStep, "slds-is-complete");
                        $A.util.removeClass(finalStep, "slds-is-active");
                        $A.util.addClass(component.find("nextbuttonFooter"), "slds-hide");
                        $A.util.addClass(component.find("nextbuttonPath"), "slds-hide");
                        $A.util.addClass(component.find("prevbuttonPath"), "slds-hide")
                        $A.util.addClass(component.find("prevbuttonFooter"), "slds-hide")
                        
                        amtrak.fireSuccessToastEvent(component, "", "All tests have been submitted successfully.");
                        component.set("v.SubmitStatusMessage", "SUCCESSFULLY SUBMITTED");
                        
                        var testMap = JSON.parse(returnValue.totalTests);                        
                        var msg=[];
                          // Added script to show the final message after submission
                      	if (testMap != null){ 
                            var i=0;
                             for (var key in testMap) {
                                msg[i] = testMap[key];
                                i++; 
                             }
                         }  
                        component.set("v.SubmitStatusMessage", "SUCCESSFULLY SUBMITTED");
                        component.set("v.submitMessage",msg);
                        console.log("msg$$$"+msg);
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
    
    populateScoreDefinitions : function(component){
        var recordType = component.get("v.selectedRecordType");            
        var scoreMap = component.get("v.allFormScoreDefinitionMap");
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
    	
	},
    
})