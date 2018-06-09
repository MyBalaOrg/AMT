({
	initializeTestSelection : function(component) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var action = component.get("c.initializeTestSelectionComponent");
        var params = {};
        action.setParams({ "params" : params });
        console.log("-------------");
        console.log("Action: c.initializeTestSelectionComponent");
        console.log(params);
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.initializeTestSelectionComponent " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                } else {
                    if (!$A.util.isEmpty(returnValue.obsRecordTypes)) {
                        component.set("v.obsRecordTypes", JSON.parse(returnValue.obsRecordTypes));
                        console.log("Record types: " + JSON.stringify(returnValue.obsRecordTypes));
                    }
                    if (!$A.util.isEmpty(returnValue.obsTemplate)) {
                        component.set("v.obsTemplate", JSON.parse(returnValue.obsTemplate));
                    }
                    if (!$A.util.isEmpty(returnValue.osrWrapperList)) {
                        component.set("v.osrWrapperList", JSON.parse(returnValue.osrWrapperList));
                        console.log("### osrWrapper list : " + JSON.stringify(component.get("v.osrWrapperList")));
                    }
                    if (!$A.util.isEmpty(returnValue.recordTypeToDisplayTestNumbers)) {
                        component.set("v.recordTypeToDisplayTestNumbers", returnValue.recordTypeToDisplayTestNumbers);
                    }
                    if (!$A.util.isEmpty(returnValue.obsFieldLabelMap)) {
                        component.set("v.obsFieldLabelMap", JSON.parse(returnValue.obsFieldLabelMap));
                        
                        console.log("----------");
                        console.log("Observation field labels map");
                        console.log(JSON.stringify(returnValue.obsFieldLabelMap));
                        console.log("----------");
                    }
                    if (!$A.util.isEmpty(returnValue.allInfoReqFieldsMap)) {
                        component.set("v.allInfoReqFieldsMap", JSON.parse(returnValue.allInfoReqFieldsMap));
                    }
                    if (!$A.util.isEmpty(returnValue.allEntryReqFieldsMap)) {
                        component.set("v.allEntryReqFieldsMap", JSON.parse(returnValue.allEntryReqFieldsMap));
                    }
                    if (!$A.util.isEmpty(returnValue.testQuestionMap)) {
                        component.set("v.testQuestionMap", JSON.parse(returnValue.testQuestionMap));
                    }
                    if (!$A.util.isEmpty(returnValue.scoreListMap)) {
                        component.set("v.scoreListMap", JSON.parse(returnValue.scoreListMap));
                    }
                    if (!$A.util.isEmpty(returnValue.needImprovementMap)) {
                        console.log("JSON.stringify(returnValue.needImprovementMap) :: " + JSON.stringify(returnValue.needImprovementMap));
                        component.set("v.needImprovementMap", JSON.parse(returnValue.needImprovementMap));
                    }
                    console.log("picklist map " + JSON.stringify(returnValue.testInfoPicklistMap));
                    var testInfoCmp = component.find("test-info-cmp");
                    if (!$A.util.isEmpty(testInfoCmp)) {
                        if (!$A.util.isEmpty(returnValue.testInfoPicklistMap)) {
                            testInfoCmp.set("v.picklistMap", JSON.parse(returnValue.testInfoPicklistMap));
                        }
                        if (!$A.util.isEmpty(returnValue.testInfoPicklistMapRegionState)) {
                            testInfoCmp.set("v.picklistMapRegionState", JSON.parse(returnValue.testInfoPicklistMapRegionState));
                        }
                    }
                    
                    var testEntryCmp = component.find("test-entry-cmp");
                    if (!$A.util.isEmpty(testEntryCmp)) {
                        if (!$A.util.isEmpty(returnValue.testEntryPicklistMap)) {
                            testEntryCmp.set("v.picklistMap", JSON.parse(returnValue.testEntryPicklistMap));
                        }
                    }

                    var testResultCmp = component.find("test-result-cmp");
                    if (!$A.util.isEmpty(testResultCmp)) {
                        if (!$A.util.isEmpty(returnValue.testPicklistMap)) {
                            testResultCmp.set("v.picklistMap", JSON.parse(returnValue.testPicklistMap));
                        }
                        if (!$A.util.isEmpty(returnValue.currentUser)) {
                            testResultCmp.set("v.currentUser", returnValue.currentUser);
                            console.log("=====> currentUser: ", returnValue.currentUser);
                        }
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
    
    handleSaveAndPreview : function(component, params) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var action = component.get("c.multiTestFormSaveAndPreview");
        action.setParams({ "params" : params });
        console.log("-------------");
        console.log("Action: c.multiTestFormSaveAndPreview");
        console.log(params);
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.multiTestFormSaveAndPreview " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                } else {
                    if (!$A.util.isEmpty(returnValue.trWrapperList)) {
                        var testResultCmp = component.find("test-result-cmp");
                        if (!$A.util.isEmpty(testResultCmp)) {
                            testResultCmp.set("v.trWrapperList", JSON.parse(returnValue.trWrapperList));
                        }
                        window.scrollTo(0, 0);
                        component.set("v.selectionState", 6);
                        this.setTestFormLabels(component);
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
    
    handleSaveAndPreviewNon1872 : function(component, params) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var action = component.get("c.multiTestFormSaveAndPreviewNon1872");
        action.setParams({ "params" : params });
        console.log("-------------");
        console.log("Action: c.multiTestFormSaveAndPreviewNon1872");
        console.log(params);
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.multiTestFormSaveAndPreviewNon1872 " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                    /*
                } else {
                    if (!$A.util.isEmpty(returnValue.trWrapperList)) {
                        var obsId = JSON.parse(returnValue.trWrapperList)[0].testResults[0].Id;
                        console.log("Observation Id: "+obsId);
                        var navEvtToObs = $A.get("e.force:navigateToSObject");
                        navEvtToObs.setParams({
                            "recordId": obsId,
                            "slideDevName": "detail"
                        });
                        navEvtToObs.fire();
                    }
                }
                */
                } else {
                    if (!$A.util.isEmpty(returnValue.trWrapperList)) {
                        var testResultCmp = component.find("test-result-cmp");
                        if (!$A.util.isEmpty(testResultCmp)) {
                            testResultCmp.set("v.trWrapperList", JSON.parse(returnValue.trWrapperList));
                            console.log("response :: " + JSON.parse(returnValue.trWrapperList));
                        }
                        window.scrollTo(0, 0);
                        component.set("v.selectionState", 6);
                        console.log(component.get("v.selectionState"));
                        component.set("v.subComponentSize", "1-of-1");
                        this.setTestFormLabels(component);
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
    
    handleSaveAndSubmit : function(component, params) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var action = component.get("c.multiTestFormSaveAndSubmit");
        action.setParams({ "params" : params });
        console.log("-------------");
        console.log("Action: c.multiTestFormSaveAndSubmit");
        console.log(params);
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.multiTestFormSaveAndSubmit " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                } else {
                    amtrak.fireSuccessToastEvent(component, "", "All tests have been submitted successfully.");
                    if (!$A.util.isEmpty(returnValue.trWrapperList)) {
                        var testResultCmp = component.find("test-result-cmp");
                        if (!$A.util.isEmpty(testResultCmp)) {
                            var trWrapperList = JSON.parse(returnValue.trWrapperList);
                            testResultCmp.set("v.trWrapperList", trWrapperList);
                            testResultCmp.set("v.testQuestionList", trWrapperList[0].findingList);
                            
                            var non1872SavePreviwCmp = testResultCmp.find("non1872-save-preview");
                            console.log("non1872SavePreviwCmp :: " + non1872SavePreviwCmp);
                            if (!$A.util.isEmpty(non1872SavePreviwCmp)) {
                                non1872SavePreviwCmp.set("v.trWrapperList", trWrapperList);
                                non1872SavePreviwCmp.set("v.testQuestionList", trWrapperList[0].findingList);
                            }
                        }
                        console.log("### tr wrapper list : " + JSON.stringify(returnValue.trWrapperList));
                        window.scrollTo(0, 0);
                        component.set("v.testCompleted", true);
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
    
    setTestFormLabels : function(component) {
        var selectionState = component.get("v.selectionState");
        var testName = component.get("v.selectedRecordType.Name");
        console.log("testName :: " + testName);
        switch (selectionState) {
            case 1: 
                component.set("v.nextButtonLabel", "Next"); 
                component.set("v.headerTitle", "Select Form");
                break;
            case 2: 
                component.set("v.nextButtonLabel", "Next"); 
                component.set("v.headerTitle", testName + " Info");
                break;
            case 3: 
                component.set("v.nextButtonLabel", "Next"); 
                component.set("v.headerTitle", "Select Test Number"); 
                break;
            case 4: 
                if(testName != $A.get("$Label.c.RevSys_Observation_RT_Label_Test_1872")){
                    component.set("v.headerTitle", testName + " Info");
                }else{
                    component.set("v.headerTitle", "Select Employee");
                }
                component.set("v.nextButtonLabel", "Next");     
                break;
            case 5: 
                component.set("v.nextButtonLabel", "Save and Preview"); 
                component.set("v.headerTitle", testName + " Entry");
                break;
            case 6:
                if(testName != $A.get("$Label.c.RevSys_Observation_RT_Label_Test_1872") && component.get("v.submittedForm")){
                    component.set("v.nextButtonLabel", "Update"); 
                }else{
                    component.set("v.nextButtonLabel", "Save and Submit"); 
                }
                component.set("v.headerTitle", testName + " Results");
                break;
        }
    },
    
    handleReloadObservations : function(component, params) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var action = component.get("c.reloadTestResultWrapper");
        params["RecordTypeName"] = component.get("v.selectedRecordType.Name"); 
        action.setParams({ "params" : params });
        console.log("-------------");
        console.log("Action: c.reloadTestResultWrapper");
        console.log(params);
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.reloadTestResultWrapper " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                    amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                } else {
                    if (!$A.util.isEmpty(returnValue.trWrapperList)) {
                        var testResultCmp = component.find("test-result-cmp");
                        if (!$A.util.isEmpty(testResultCmp)) {
                            testResultCmp.set("v.trWrapperList", JSON.parse(returnValue.trWrapperList));
                        }
                        window.scrollTo(0, 0);
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
	
    getEmployeeWrapperListJSON : function(selectedEmpList) {
        var nameIndex = 0;
        var deptIndex = 0;
        var craftIndex = 0;
        var additionalIndex = 0;
        if (!$A.util.isEmpty(selectedEmpList[0])) {
            for (var i = 0; i < selectedEmpList[0].fieldNames.length; i++) {
                if (selectedEmpList[0].fieldNames[i] == "Name") {
                    nameIndex = i;
                } else if (selectedEmpList[0].fieldNames[i] == "Department") {
                    deptIndex = i;
                } else if (selectedEmpList[0].fieldNames[i] == "Craft__c") {
                    craftIndex = i;
                } else if (selectedEmpList[0].fieldNames[i] == "AdditionalCrafts__c") {
                    additionalIndex = i;
                }
            }
        }
        
        var empList = [];
        selectedEmpList.forEach(function(selectedEmp) {
            //var craftList = $A.util.isEmpty(selectedEmp.fieldValues[craftIndex]) ? [] : [selectedEmp.fieldValues[craftIndex]];
            var craftList = [];
            if (!$A.util.isEmpty(selectedEmp.fieldValues[additionalIndex])) {
                craftList = selectedEmp.fieldValues[additionalIndex].split(';');
            }
            if (!$A.util.isEmpty(selectedEmp.fieldValues[craftIndex])) {
                craftList.push(selectedEmp.fieldValues[craftIndex]);
            }
            empList.push({
                "selected" : true,
                "name" : selectedEmp.fieldValues[nameIndex],
                "recordId" : selectedEmp.recordId,
                "department" : selectedEmp.fieldValues[deptIndex],
                "craftList" : craftList
            });
        });
        var empListJSON = JSON.stringify(empList);
        empList = undefined;
        return empListJSON;
    },
    
    getTestEntryWrapper : function(osrWrapper, obsTemplateJSON, empListJSON, requiredFieldsJSON) {
        var empList = JSON.parse(empListJSON);
        var teWrapper = {
            "display" : false,
            "completed" : false,
            "obs" : JSON.parse(obsTemplateJSON),
            "requiredFields" : JSON.parse(requiredFieldsJSON),
            "empList" : [],
            "speedCheckMethodList" : []
        }
        console.log("teWrapper JSON : " + JSON.stringify(teWrapper));
        if ($A.util.isEmpty(osrWrapper)) {
            teWrapper.empList = empList;
        } else {
            teWrapper.obs.OccupationSpecificRequirement__c = osrWrapper.recordId;
            teWrapper.obs.TestNumber__c = osrWrapper.testNumber;
            teWrapper.obs.TestName__c = osrWrapper.testName;
            teWrapper.obs.Department__c = osrWrapper.department;
            teWrapper.obs.Craft__c = osrWrapper.craft;
            teWrapper.obs.Result__c = "";
            teWrapper.requiredFields.Comments__c = false;
            teWrapper.requiredFields.SupervisorsCommentSelection__c = false;
            teWrapper.requiredFields.NonComplianceRuleNumber__c = false;
            teWrapper.requiredFields.MpSgNumber__c = false;
            teWrapper.requiredFields.Speed_Check_Method__c = false;
            osrWrapper.speedCheckMethodList = osrWrapper.speedCheckMethodList;
            var osrSpeedChecklist = osrWrapper.speedCheckMethodList;
            if(!$A.util.isEmpty(osrSpeedChecklist)){
                osrSpeedChecklist.forEach(function(spdChk) {
                    teWrapper.speedCheckMethodList.push(spdChk);
                });
            }
            empList.forEach(function(emp) {
                try {
                    if (!$A.util.isEmpty(osrWrapper.allCraftDeptMap[emp.department])) {
                        teWrapper.empList.push(emp);
                    } else if (!$A.util.isEmpty(osrWrapper.deptCraftMap[emp.department])) {
                        emp.craftList.forEach(function(craft) {
                            if (!$A.util.isEmpty(osrWrapper.deptCraftMap[emp.department][craft])) {
                                teWrapper.empList.push(emp);
                                throw BreakException;
                            }
                        });
                    }
                } catch (err) {
                    //console.log("Matched employee found: " + emp.name);
                }
            });
        }
        return teWrapper;
    },
    
    setTestEntryFor1872 : function(component, testEntryCmp, empListJSON, rtDisplayTestNumberCheck) {
        var sellf = this;
        var teWrapperList = [];
        var osrWrapperList = component.get("v.osrWrapperList");
        var obsTemplateJSON = JSON.stringify(component.get("v.obsTemplate"));
        var requiredFieldsJSON = JSON.stringify(testEntryCmp.get("v.obsRequiredFieldMap"));
        console.log("requiredFieldsJSON :: " + requiredFieldsJSON);
        if (rtDisplayTestNumberCheck) {
            var selectedRecordType = component.get("v.selectedRecordType");
            teWrapperList.push(sellf.getTestEntryWrapper(null, obsTemplateJSON, empListJSON, requiredFieldsJSON));
        } else {
            osrWrapperList.forEach(function(osrWrapper) {
                if (osrWrapper.selected) {
                    var teWrapper = sellf.getTestEntryWrapper(osrWrapper, obsTemplateJSON, empListJSON, requiredFieldsJSON);
                    if (teWrapper.empList.length > 0) {
                        teWrapperList.push(teWrapper);
                    }
                }
            });
        }
        teWrapperList[0].display = true;
        
        //set default values
        if(!$A.util.isEmpty(teWrapperList) && teWrapperList.length > 0){
            teWrapperList.forEach(function(teWrap) {
                teWrap["PersonallyObserved__c"] = "Yes";
                teWrap["Date__c"] = component.get("v.obsTemplate")["Date__c"];
            });
        }
        console.log("### teWrapperList :: " + JSON.stringify(teWrapperList));
        testEntryCmp.set("v.testEntryWrapperList", teWrapperList);
    },
    
    setTestEntryForNon1872 : function(component, testEntryCmp, empListJSON) {
        var sellf = this;
        var teWrapperList = [];
        var selectedRT = component.get("v.selectedRecordType");
        var scoreList = component.get("v.scoreListMap[" + selectedRT.Id + "]");
        var testQuestionList = component.get("v.testQuestionMap[" + selectedRT.Name + "]");
        var requiredFields = component.get("v.allEntryReqFieldsMap[" + selectedRT.Id + "]");
        var testResultCmp = component.find("test-result-cmp");
        
        testEntryCmp.set("v.testQuestionList", testQuestionList);
        testEntryCmp.set("v.scoreList", scoreList);
        
        if (!$A.util.isEmpty(requiredFields)) {
            testEntryCmp.set("v.commentsRequired", requiredFields["Comments__c"]);
            testResultCmp.set("v.commentsRequired", requiredFields["Comments__c"]);
        }
    },
    
    validateEvaluationDate : function(teWrapper, fieldName, cmp, completed) {
        
        var evaluationDate = teWrapper[fieldName];	//return a string (yyyy-mm-dd) format
        
        console.log("evaluationDate : " + evaluationDate);
        //convert a string to date
        var evaluationDateSplit = evaluationDate.split("-");
        var year = parseInt(evaluationDateSplit[0]);
        var month = parseInt(evaluationDateSplit[1] - 1);
        var date = parseInt(evaluationDateSplit[2]);
        var dateVal = new Date(year, month, date);
        
        var currentDate = new Date();
        currentDate.setHours(0,0,0,0);
        
        console.log("PersonallyObserved__c : " + teWrapper["PersonallyObserved__c"]);
        
        if(teWrapper["PersonallyObserved__c"] == "Yes"){
            var date10DayOld = new Date();
            date10DayOld.setDate(date10DayOld.getDate() - 11);	// use 11 to skip counting of today
            
            if(dateVal < date10DayOld){
                cmp.set("v.errors",  [{message:"Evaluation Date should not be greater than 10 calendar days."}]);
                completed = false;
            }else if(dateVal > currentDate){
                cmp.set("v.errors",  [{message:"Evaluation Date should not be future date."}]);
                completed = false;
            } else {
                cmp.set("v.errors",  null);
                completed = completed && !$A.util.isEmpty(teWrapper[fieldName]); 
            }
            
        } else if (teWrapper["PersonallyObserved__c"] == "No") {
            var date90DayOld = new Date();
            date90DayOld.setDate(date90DayOld.getDate() - 91);	//use 91 to skip counting of today
            
            if(dateVal < date90DayOld){
                cmp.set("v.errors",  [{message:"Evaluation Date should not be greater than 90 calendar days."}]);
                completed = false;
            }else if(dateVal > currentDate){
                cmp.set("v.errors",  [{message:"Evaluation Date should not be future date."}]);
                completed = false;
            } else {
                cmp.set("v.errors",  null);
                completed = completed && !$A.util.isEmpty(teWrapper[fieldName]); 
            }
        }
        
        return completed;
    },
    
    validateTestEntriesAndSave1872 : function(component, testEntryCmp) {
        var proceed = true;
        var teWrapperList = component.get("v.testEntryWrapperList");
        var sellf = this;
        var rfMap = testEntryCmp.get("v.obsRequiredFieldMap");
        var obsFieldLabelMap = component.get("v.obsFieldLabelMap");
        var entryFieldList = ["Result__c","PersonallyObserved__c","NonComplianceRuleNumber__c","Discussed_with_Employee__c","SupervisorsCommentSelection__c","Comments__c","Date__c","TimeHH__c","TimeMM__c","MpSg__c","MpSgNumber__c","Speed__c","Speed_Check_Method__c"];
        teWrapperList.forEach(function(teWrapper) {
            if (teWrapper.completed) {
                entryFieldList.forEach(function(fieldName) {
                    teWrapper.obs[fieldName] = teWrapper[fieldName];
                });
            } else {
                proceed = false;
                console.log("teWrapper req fields" + JSON.stringify(teWrapper.requiredFields));
                for (var fieldName in teWrapper.requiredFields) {
                    if (teWrapper.requiredFields[fieldName]) {
                        var fieldCmp = testEntryCmp.find(fieldName);
                        if (!$A.util.isEmpty(fieldCmp)) {
                            var completed = false;
                            if (fieldCmp.length && fieldCmp.length > 0) {
                                fieldCmp.forEach(function(inputCmp) {
                                    if ($A.util.isEmpty(inputCmp.get("v.value"))) {
                                        console.log("inputCmp :: " + inputCmp);
                                        inputCmp.set("v.errors", true);
                                    } else if(!$A.util.isEmpty(inputCmp.get("v.value")) && fieldName == "Date__c"){
                                        
                                        var evaluationDate = teWrapper[fieldName];	//return a string (yyyy-mm-dd) format
                                        //convert a string to date
                                        var evaluationDateSplit = evaluationDate.split("-");
                                        var year = parseInt(evaluationDateSplit[0]);
                                        var month = parseInt(evaluationDateSplit[1] - 1);
                                        var date = parseInt(evaluationDateSplit[2]);
                                        var evalDateVal = new Date(year, month, date);
                                        
                                        var componentDate = inputCmp.get("v.value");	//return a string (yyyy-mm-dd) format
                                        //convert a string to date
                                        var componentDateSplit = componentDate.split("-");
                                        var componentYear = parseInt(componentDateSplit[0]);
                                        var componentMonth = parseInt(componentDateSplit[1] - 1);
                                        var componentDate = parseInt(componentDateSplit[2]);
                                        var componentDateVal = new Date(componentYear, componentMonth, componentDate);
                                        
                                        if(evalDateVal.getTime() === componentDateVal.getTime()){
                                        	completed = sellf.validateEvaluationDate(teWrapper, fieldName, inputCmp, completed);    
                                        }
                                        
                                    } else {
                                        inputCmp.set("v.errors", null);
                                    }
                                });
                            } else {
                                if ($A.util.isEmpty(fieldCmp.get("v.value"))) {
                                    fieldCmp.set("v.errors", true);
                                } else if(!$A.util.isEmpty(fieldCmp.get("v.value")) && fieldName == "Date__c"){
                                    completed = sellf.validateEvaluationDate(teWrapper, fieldName, fieldCmp, completed);
                                } else {
                                    fieldCmp.set("v.errors", null);
                                }
                            }
                        }
                    }
                };
            }
        });
        if (proceed) {
            teWrapperList.forEach(function(teWrapper) {
                entryFieldList.forEach(function(fieldName) {
                    teWrapper[fieldName] = undefined;
                });
            });
            console.log("teWrapperList JSON : " + JSON.stringify(teWrapperList));
            var params = {
                "testEntryWrapperListJSON" : JSON.stringify(teWrapperList)
            };
            this.handleSaveAndPreview(component, params);
        }
        
        return proceed;
    },
    
    validateTestQuestionsAndSaveNon1872 : function(component, testEntryCmp) {
        var proceed = true;
        var commentsText = testEntryCmp.find("Comments__c");
        var testResult = component.find("test-result-cmp");
        
        //testResult.set("v.comments", testEntryCmp.get("v.comments"));

        console.log("needImprovementRequired: " + testEntryCmp.get("v.needImprovementRequired"));
        if (testEntryCmp.get("v.needImprovementRequired") && $A.util.isEmpty(testEntryCmp.get("v.needImprovement"))) {
            proceed = false;
        } 
        if (testEntryCmp.get("v.commentsRequired") && $A.util.isEmpty(testEntryCmp.get("v.comments"))) {
            proceed = false;
            //commentsText.set("v.errors", true);
        } else {
            //commentsText.set("v.errors", null);
        }

        if (proceed) {
            var empList = [];
            var obsTemplate = component.get("v.obsTemplate");
            for (var fieldName in obsTemplate) {
                if (fieldName.indexOf("__r") > 0) {
                    obsTemplate[fieldName] = undefined;
                }
            }
            console.log("### OBS Template : " + JSON.stringify(obsTemplate));
            var selectedEmpList = component.get("v.selectedEmpList");
            selectedEmpList.forEach(function(selectedEmp) {
                empList.push(selectedEmp.recordId);
            });
            var testQuestionList = testEntryCmp.get("v.testQuestionList");
            var params = {
                "obsJSON" : JSON.stringify(obsTemplate),
                "empListJSON" : JSON.stringify(empList),
                "testQuestionListJSON" : JSON.stringify(testQuestionList),
                "needImprovement" : testEntryCmp.get("v.needImprovement"),
                "comments" : testEntryCmp.get("v.comments")
            }
            
            this.handleSaveAndPreviewNon1872(component, params);
        }
        
        /*
        var needImpInput = testEntryCmp.find("NeedsImprovement__c");
        if (!$A.util.isEmpty(needImpInput) && testEntryCmp.get("v.needImprovementRequired")) {
            needImpInput.set("v.errors", !proceed);
        } else {
            needImpInput.set("v.errors", null);
        }
        */
        return proceed;
    },
    
    resetFormValues : function(component) {
        // Clear test number selection list
        var osrWrapperList = component.get("v.osrWrapperList");
        osrWrapperList.forEach(function(osrWrapper) {
            osrWrapper.selected = false;
        });
        component.set("v.osrWrapperList", osrWrapperList);
        
        // Clear previous search attributes
        var selectEmployeeCmp = component.find("select-employee-cmp");
        if (!$A.util.isEmpty(selectEmployeeCmp)) {
            selectEmployeeCmp.set("v.deptCraftMap", null);
            selectEmployeeCmp.set("v.allCraftDeptMap", null);
        }
        
        var obsTemplate = component.get("v.obsTemplate");
        for (var fieldName in obsTemplate) {
            if (fieldName != "Date__c" && fieldName.indexOf("__c") > 0) {
                obsTemplate[fieldName] = undefined;
            }
        }
        component.set("v.obsTemplate", obsTemplate);
    }
})