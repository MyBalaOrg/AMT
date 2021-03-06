({
    scriptsLoaded : function(component, event, helper) {
        amtrak.scriptLoadedCheck();
        helper.initializeTestSelection(component);
    },
    
    handleToggleLightningSpinner : function(component, event, helper) {
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), paramMap.hideSpinner);
    },
    
    onclickNextButton : function(component, event, helper) {
        var selectionState = component.get("v.selectionState");
        var proceed = false;
        var message = "";
        var selectedRecordType = component.get("v.selectedRecordType");
        var recordTypeId = component.get("v.obsTemplate.RecordTypeId");
        var recordTypeToDisplayTestNumbers = component.get("v.recordTypeToDisplayTestNumbers");
        var isSaveAndSubmit = false;
        
        var currentDate = new Date();
        currentDate.setHours(0,0,0,0);
        
        console.log("recordTypeId :: " + recordTypeId);
        console.log("recordTypeToDisplayTestNumbers :: " + recordTypeToDisplayTestNumbers);
        var isTest1872 = selectedRecordType.Name == $A.get("$Label.c.RevSys_Observation_RT_Label_Test_1872");
        switch (selectionState) {
            case 1:
                proceed = !$A.util.isEmpty(recordTypeId);
                message = "Please select a test.";
                if (proceed) {
                    // Assign required field map to the required field map in test info lightning component
                    var testInfoCmp = component.find("test-info-cmp");
                    if (!$A.util.isEmpty(testInfoCmp)) {
                        var allInfoRFMap = component.get("v.allInfoReqFieldsMap");
                        testInfoCmp.set("v.obsRequiredFieldMap", allInfoRFMap[component.get("v.obsTemplate.RecordTypeId")]);
                    }
                    var needImprovementMap = component.get("v.needImprovementMap");
                    // Assign required field map to the required field map in test entry lightning component
                    var testEntryCmp = component.find("test-entry-cmp");
                    if (!$A.util.isEmpty(testEntryCmp)) {
                        var allEntryRFMap = component.get("v.allEntryReqFieldsMap");
                        var testQuestionMap = component.get("v.testQuestionMap");
                        testEntryCmp.set("v.obsRequiredFieldMap", allEntryRFMap[component.get("v.obsTemplate.RecordTypeId")]);
                        testEntryCmp.set("v.testQuestionList", testQuestionMap[selectedRecordType.Name]);
                        testEntryCmp.set("v.needImprovementMap", needImprovementMap[selectedRecordType.Id]);
                    }
                    var testResultCmp = component.find("test-result-cmp");
                    if (!$A.util.isEmpty(testResultCmp)) {
                        testResultCmp.set("v.needImprovementMap", needImprovementMap[selectedRecordType.Id]);
                    }
                    helper.resetFormValues(component);
                }
                if(proceed && ($A.util.isEmpty(recordTypeToDisplayTestNumbers) || recordTypeToDisplayTestNumbers.indexOf(recordTypeId) < 0)){
                    //var testEntryCmp = component.find("test-entry-cmp");
                    var testInfoCmp = component.find("test-info-cmp");
                    var selectEmployeeCmp = component.find("select-employee-cmp");
                    selectEmployeeCmp.set("v.picklistMap", testInfoCmp.get("v.picklistMap"));
                    selectEmployeeCmp.set("v.picklistMapRegionState", testInfoCmp.get("v.picklistMapRegionState"));
                    
                    var allInfoRFMap = component.get("v.allInfoReqFieldsMap");
                    selectEmployeeCmp.set("v.obsRequiredFieldMap", allInfoRFMap[component.get("v.obsTemplate.RecordTypeId")]);
                    
                    selectionState += 2;
                    
                }
                break;
            case 2:
                var testInfoCmp = component.find("test-info-cmp");
                message = "Please enter required fields: ";
                proceed = true;
                if (!$A.util.isEmpty(testInfoCmp)) {
                    var rfMap = testInfoCmp.get("v.obsRequiredFieldMap");
                    var obsTemplate = component.get("v.obsTemplate");
                    var obsFieldLabelMap = component.get("v.obsFieldLabelMap");
                    console.log("osrWrapperList : " + JSON.stringify(component.get("v.osrWrapperList")));
                    var proceedFinal = true;
                    for (var fieldName in rfMap) {
                        var fieldCmp = testInfoCmp.find(fieldName);
                        var hasError = null;
                        proceed = true;
                        console.log(" ### obsTemplate - " + fieldName + " : " + obsTemplate[fieldName]);
                        if ($A.util.isEmpty(obsTemplate[fieldName]) || (obsTemplate[fieldName] == "")) {
                            
                            if (fieldName === "State__c") {
                                if (!$A.util.isEmpty(testInfoCmp.get("v.picklistMap.State__c"))) {
                                    message += obsFieldLabelMap[fieldName.toLowerCase()];
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                            } else if (fieldName === "Method__c") {
                                if (obsTemplate["IsOnJobTraining__c"] === true) {
                                    message += obsFieldLabelMap[fieldName.toLowerCase()];
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                                
                            } else if (fieldName === "MpSgNumber__c") {
                                if (!$A.util.isEmpty(obsTemplate["MpSg__c"]) && obsTemplate["MpSg__c"] != "None") {
                                    message += obsFieldLabelMap[fieldName.toLowerCase()];
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                                
                            } else if (fieldName === "Speed__c") {
                                if (!$A.util.isEmpty(obsTemplate["Speed_Check_Method__c"]) && (obsTemplate["Speed__c"] != "")) {
                                    //if (!$A.util.isEmpty(obsTemplate["Speed_Check_Method__c"])) {
                                    message += obsFieldLabelMap[fieldName.toLowerCase()];
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                                
                            } else if (fieldName === "OperatedFromCode__c" || fieldName === "OperatedFromText__c") {
                                if ($A.util.isEmpty(obsTemplate["OperatedFromCode__c"]) && $A.util.isEmpty(obsTemplate["OperatedFromText__c"])) {
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                            } else if (fieldName === "OperatedToCode__c" || fieldName === "OperatedToText__c") {
                                if ($A.util.isEmpty(obsTemplate["OperatedToCode__c"]) && $A.util.isEmpty(obsTemplate["OperatedToText__c"])) {
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                                
                                
                            } else if (fieldName === "Nearest_Station_Interlocking__c" || fieldName === "Nearest_Station_Interlocking_Description__c") {
                                if ($A.util.isEmpty(obsTemplate["Nearest_Station_Interlocking__c"]) && $A.util.isEmpty(obsTemplate["Nearest_Station_Interlocking_Description__c"])) {
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                            } else {
                                if(fieldName !== "Result__c" && fieldName !== "PersonallyObserved__c" && fieldName !== "Discussed_with_Employee__c"){
                                    message += obsFieldLabelMap[fieldName.toLowerCase()];
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;    
                                }
                                
                            }
                            
                        } else if ((fieldName === "Nearest_Station_Interlocking__c" || fieldName === "Nearest_Station_Interlocking_Description__c")
                                   && !$A.util.isEmpty(obsTemplate["Nearest_Station_Interlocking__c"]) 
                                   && !$A.util.isEmpty(obsTemplate["Nearest_Station_Interlocking_Description__c"])){
                            proceed = false;
                            hasError = true;
                            proceedFinal = (proceedFinal) ? false : false;
                        }
                        if (!proceed) {
                            if (fieldName != "OperatedFromCode__c" 
                                && fieldName != "OperatedFromText__c"
                                && fieldName != "OperatedToCode__c"
                                && fieldName != "OperatedToText__c"
                                && fieldName != "Nearest_Station_Interlocking__c"
                                && fieldName != "Nearest_Station_Interlocking_Description__c") {
                                message += ', ';
                            }
                        }
                        proceed = proceedFinal;
                        if (!$A.util.isEmpty(fieldCmp)) {
                            if (fieldName != "OperatedFromText__c"  
                                && fieldName != "OperatedToText__c"
                                && fieldName != "OperatedFromCode__c" 
                                && fieldName != "OperatedToCode__c" 
                                && fieldName != "Nearest_Station_Interlocking__c"
                                && fieldName != "Nearest_Station_Interlocking_Description__c" 
                                && fieldName != "Train__c") {
                                fieldCmp.set("v.errors", hasError);
                            }
                            else if (fieldName === "OperatedFromText__c") {
                                if (hasError === true) {
                                    fieldCmp.set("v.errors",  [{message:"You must enter one of the Operated From fields."}]);
                                }
                                else {
                                    fieldCmp.set("v.errors", null);
                                }
                            } else if (fieldName === "OperatedToText__c") {
                                if (hasError === true) {
                                    fieldCmp.set("v.errors",  [{message:"You must enter one of the Operated To fields."}]);
                                }
                                else {
                                    fieldCmp.set("v.errors", null);
                                }
                            } else if (fieldName === "Nearest_Station_Interlocking_Description__c") {
                                if (hasError === true) {
                                    if (!$A.util.isEmpty(obsTemplate["Nearest_Station_Interlocking__c"]) && !$A.util.isEmpty(obsTemplate["Nearest_Station_Interlocking_Description__c"])) {
                                        fieldCmp.set("v.errors",  [{message:"You cannot enter both Nearest Station Interlocking fields."}]);
                                    } else if($A.util.isEmpty(obsTemplate["Nearest_Station_Interlocking__c"]) && $A.util.isEmpty(obsTemplate["Nearest_Station_Interlocking_Description__c"])) {
                                        fieldCmp.set("v.errors",  [{message:"You must enter one of the Nearest Station Interlocking fields."}]);    
                                    }
                                }
                                else {
                                    fieldCmp.set("v.errors", null);
                                }
                            }
                            if (fieldName === "OperatedFromCode__c" ||
                                fieldName === "OperatedToCode__c" ||
                                fieldName === "Nearest_Station_Interlocking__c" ||
                                fieldName === "Train__c" ) {
                                fieldCmp.set("v.hasError", hasError);
                            }
                        }
                    }
                }
                for (var fieldName in obsTemplate) {
                    if (fieldName.indexOf("__r") > 0) {
                        obsTemplate[fieldName] = undefined;
                    }
                }
                if (proceed && ($A.util.isEmpty(recordTypeToDisplayTestNumbers) || recordTypeToDisplayTestNumbers.indexOf(recordTypeId) < 0)) {
                    selectionState += 1;
                }
                var selectTestNumberCmp = component.find("select-test-number-cmp");
                console.log("picklist map : " + testInfoCmp.get("v.picklistMap"));
                selectTestNumberCmp.set("v.picklistMap", testInfoCmp.get("v.picklistMap"));
                selectTestNumberCmp.set("v.osrWrapperListCopy", component.get("v.osrWrapperList"));
                break;
            case 3:
                message = "Please select at least one test number.";
                var deptCraftMap = {};
                var allCraftDeptMap = {};
                var osrWrapperList = component.get("v.osrWrapperList");
                console.log("osr wrapper list ");
                console.log(osrWrapperList);
                osrWrapperList.forEach(function(osrWrapper) {
                    if (osrWrapper.selected) {
                        for (var dept in osrWrapper.deptCraftMap) {
                            if (deptCraftMap[dept] == undefined) {
                                deptCraftMap[dept] = {};
                            }
                            for (var craft in osrWrapper.deptCraftMap[dept]) {
                                deptCraftMap[dept][craft] = true;
                            }
                        }
                        for (var dept in osrWrapper.allCraftDeptMap) {
                            allCraftDeptMap[dept] = true;
                        }
                    }
                });
                console.log("Department and Craft Map");
                console.log(deptCraftMap);
                console.log(allCraftDeptMap);
                if (!$A.util.isEmpty(deptCraftMap) || !$A.util.isEmpty(allCraftDeptMap)) {
                    var selectEmployeeCmp = component.find("select-employee-cmp");
                    if (!$A.util.isEmpty(selectEmployeeCmp)) {
                        selectEmployeeCmp.set("v.deptCraftMap", deptCraftMap);
                        selectEmployeeCmp.set("v.allCraftDeptMap", allCraftDeptMap);
                        selectEmployeeCmp.allEmployeeSearch();
                    }
                    proceed = true;
                } else {
                    message = "Selected tests don't have departments and crafts. Please select a different set of test numbers.";
                }
                break;
            case 4:
                var testEntryCmp = component.find("test-entry-cmp");
                var selectedEmpList = component.get("v.selectedEmpList");
                var empListJSON = helper.getEmployeeWrapperListJSON(selectedEmpList);
                message = "Please search and select at least one employee and Please enter required fields: ";
                //check for employee
                //proceed = (!$A.util.isEmpty(selectedEmpList) && selectedEmpList.length > 0);
                var isEmployee = (!$A.util.isEmpty(selectedEmpList) && selectedEmpList.length > 0);
                
                //check for validation
                var isValidation = true;
                
                //check validations
                var selectEmployeeCmp = component.find("select-employee-cmp");
                
                if(!$A.util.isEmpty(selectEmployeeCmp)){
                    var rfMap = selectEmployeeCmp.get("v.obsRequiredFieldMap");
                    var obsTemplate = component.get("v.obsTemplate");
                    var obsFieldLabelMap = component.get("v.obsFieldLabelMap");
                    var proceedFinal = true;
                    
                    //InitialQualification__c
                    for (var fieldName in rfMap) {
                        var fieldCmp = selectEmployeeCmp.find(fieldName);
                        var hasError = null;
                        proceed = true;
                        console.log(" ### obsTemplate - " + fieldName + " : " + obsTemplate[fieldName]);
                        if ($A.util.isEmpty(obsTemplate[fieldName]) || (obsTemplate[fieldName] == "")) {
                            
                            if (fieldName === "OperatedFromCode__c" || fieldName === "OperatedFromText__c") {
                                if ($A.util.isEmpty(obsTemplate["OperatedFromCode__c"]) && $A.util.isEmpty(obsTemplate["OperatedFromText__c"])) {
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                            } else if (fieldName === "OperatedToCode__c" || fieldName === "OperatedToText__c") {
                                if ($A.util.isEmpty(obsTemplate["OperatedToCode__c"]) && $A.util.isEmpty(obsTemplate["OperatedToText__c"])) {
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                                
                                
                            } else {
                                message += obsFieldLabelMap[fieldName.toLowerCase()];
                                proceed = false;
                                hasError = true;
                                proceedFinal = (proceedFinal) ? false : false;
                            }
                            
                        }else if(fieldName === "Date__c"){
                            var evaluationDateSplit = obsTemplate["Date__c"].split("-");
                            var year = parseInt(evaluationDateSplit[0]);
                            var month = parseInt(evaluationDateSplit[1] - 1);
                            var date = parseInt(evaluationDateSplit[2]);
                            var dateVal = new Date(year, month, date);
                            console.log("dateVal :: " + dateVal);
                            if(dateVal > currentDate){
                                message += obsFieldLabelMap[fieldName.toLowerCase()];
                                proceed = false;
                                hasError = true;
                                proceedFinal = (proceedFinal) ? false : false;
                            }
                        } else if ((fieldName === "OperatedFromCode__c" || fieldName === "OperatedFromText__c")
                                   && !$A.util.isEmpty(obsTemplate["OperatedFromCode__c"]) 
                                   && !$A.util.isEmpty(obsTemplate["OperatedFromText__c"])){
                            proceed = false;
                            hasError = true;
                            proceedFinal = (proceedFinal) ? false : false;
                        }
                        else if ((fieldName === "OperatedToCode__c" || fieldName === "OperatedToText__c")
                                   && !$A.util.isEmpty(obsTemplate["OperatedToCode__c"]) 
                                   && !$A.util.isEmpty(obsTemplate["OperatedFromText__c"])){
                            proceed = false;
                            hasError = true;
                            proceedFinal = (proceedFinal) ? false : false;
                        }
                        
                        if (!proceed) {
                            if (fieldName != "OperatedFromCode__c" 
                                && fieldName != "OperatedFromText__c"
                                && fieldName != "OperatedToCode__c"
                                && fieldName != "OperatedToText__c") {
                                message += ', ';
                            }
                        }
                        proceed = proceedFinal;
                        if (!$A.util.isEmpty(fieldCmp)) {
                            console.log(fieldName + " - " + fieldCmp);
                            if (fieldName != "OperatedFromText__c"  
                                && fieldName != "OperatedToText__c"
                                && fieldName != "OperatedFromCode__c" 
                                && fieldName != "OperatedToCode__c" 
                                && fieldName != "Nearest_Station_Interlocking__c"
                                && fieldName != "Train__c"
                               	&& fieldName != "Date__c") {
                                fieldCmp.set("v.errors", hasError);
                            }else if (fieldName === "OperatedFromText__c") {
                                if (hasError === true) {
                                    if (!$A.util.isEmpty(obsTemplate["OperatedFromCode__c"]) && !$A.util.isEmpty(obsTemplate["OperatedFromText__c"])) {
                                        fieldCmp.set("v.errors",  [{message:"You cannot enter both Operated From fields."}]);
                                    } else if($A.util.isEmpty(obsTemplate["OperatedFromCode__c"]) && $A.util.isEmpty(obsTemplate["OperatedFromText__c"])) {
                                        fieldCmp.set("v.errors",  [{message:"You must enter one of the Operated From fields."}]);    
                                    }
                                    //fieldCmp.set("v.errors",  [{message:"You must enter one of the Operated From fields."}]);
                                }
                                else {
                                    fieldCmp.set("v.errors", null);
                                }
                            } else if (fieldName === "OperatedToText__c") {
                                if (hasError === true) {
                                    if (!$A.util.isEmpty(obsTemplate["OperatedToCode__c"]) && !$A.util.isEmpty(obsTemplate["OperatedToText__c"])) {
                                        fieldCmp.set("v.errors",  [{message:"You cannot enter both Operated To fields."}]);
                                    } else if($A.util.isEmpty(obsTemplate["OperatedToCode__c"]) && $A.util.isEmpty(obsTemplate["OperatedToText__c"])) {
                                        fieldCmp.set("v.errors",  [{message:"You must enter one of the Operated To fields."}]);    
                                    }
                                    //fieldCmp.set("v.errors",  [{message:"You must enter one of the Operated To fields."}]);
                                }
                                else {
                                    fieldCmp.set("v.errors", null);
                                }
                            } else if (fieldName === "Date__c") {
                                if (hasError === true) {
                                    fieldCmp.set("v.errors",  [{message:"Evaluation Date should not be future date."}]);
                                }
                                else {
                                    fieldCmp.set("v.errors", null);
                                }
                            } 
                            if (fieldName === "OperatedFromCode__c" ||
                                fieldName === "OperatedToCode__c" ||
                                fieldName === "Nearest_Station_Interlocking__c" ||
                                fieldName === "Train__c" ||
                               	fieldName === "Date__c") {
                                fieldCmp.set("v.hasError", hasError);
                            }
                        }
                    }
                    isValidation = proceedFinal;
                }
                
                console.log("isEmployee :: " + isEmployee);
                console.log("isValidation :: " + isValidation);
                
                if(isTest1872){
                    proceed = isEmployee;
                    message = "Please search and select at least one employee.";
                } else{
                    proceed = (isEmployee && isValidation);
                    if(isEmployee && !isValidation){
                        message = message.replace("Please search and select at least one employee and","");
                    } else if(!isEmployee && isValidation){
                        message = "Please search and select at least one employee.";    
                    }
                }
                if (proceed) {
                    if (isTest1872) {
                        var rtDisplayTestNumberCheck = ($A.util.isEmpty(recordTypeToDisplayTestNumbers) || recordTypeToDisplayTestNumbers.indexOf(recordTypeId) < 0);
                        helper.setTestEntryFor1872(component, testEntryCmp, empListJSON, rtDisplayTestNumberCheck);
                    } else {
                        
                        helper.setTestEntryForNon1872(component, testEntryCmp, empListJSON);
                        
                        proceed = helper.validateTestQuestionsAndSaveNon1872(component, testEntryCmp);
                        message = "Please complete all required fields.";
                        
                        var testResultCmp = component.find("test-result-cmp");
                        
                        var scoreList = component.get("v.scoreListMap[" + selectedRecordType.Id + "]");
                        testResultCmp.set("v.scoreList", scoreList);
                        
                        var testInfoCmp = component.find("test-info-cmp");
                        testResultCmp.set("v.picklistMap", testInfoCmp.get("v.picklistMap"));
                        var allInfoRFMap = component.get("v.allInfoReqFieldsMap");
                        testResultCmp.set("v.obsRequiredFieldMap", allInfoRFMap[component.get("v.obsTemplate.RecordTypeId")]);
                        
                        console.log("selectionState :: " + selectionState);
                        
                    }
                }
                break;
            case 5:
                message = "Please check validation error and complete all required fields on each test.";
                proceed = true;
                var testEntryCmp = component.find("test-entry-cmp");
                var testResultCmp = component.find("test-result-cmp");
                if (!$A.util.isEmpty(testEntryCmp)) {
                    if (isTest1872) {
                        proceed = helper.validateTestEntriesAndSave1872(component, testEntryCmp);
                    } else {
                        proceed = helper.validateTestQuestionsAndSaveNon1872(component, testEntryCmp);
                        message = "Please complete all required fields.";
                        
                        var scoreList = component.get("v.scoreListMap[" + selectedRecordType.Id + "]");
                        testResultCmp.set("v.scoreList", scoreList);
                        
                        var testInfoCmp = component.find("test-info-cmp");
                        testResultCmp.set("v.picklistMap", testInfoCmp.get("v.picklistMap"));
                        var allInfoRFMap = component.get("v.allInfoReqFieldsMap");
                        testResultCmp.set("v.obsRequiredFieldMap", allInfoRFMap[component.get("v.obsTemplate.RecordTypeId")]);
                    }
                }
                break;
            case 6:
                message = "Please enter required fields: ";
                var testResultCmp = component.find("test-result-cmp");
                
                if(!isTest1872){
                    
                    var non1872SavePreviwCmp = testResultCmp.find("non1872-save-preview");
                    
                    //check for validation
                    var formValidation = true;
                    var needImpValidation = true;
                    
                    //need improvement validation
                    var needImpInput = non1872SavePreviwCmp.find("NeedsImprovement__c").get("v.value");
                    var needImpCmp = non1872SavePreviwCmp.find("NeedsImprovement__c");
                    console.log("needs improvement required :: " + non1872SavePreviwCmp.get("v.needImprovementRequired"));
                    console.log("needImpInput :: " + needImpInput);
                    if (($A.util.isEmpty(needImpInput) || typeof  needImpInput === "undefined" || needImpInput == "") && non1872SavePreviwCmp.get("v.needImprovementRequired")) {
                        needImpValidation = false;
                        needImpCmp.set("v.errors", true);
                        message += "Needs Improvement, ";
                    } else {
                        needImpCmp.set("v.errors", null);
                    }
                    console.log("needImpValidation :: " + needImpValidation);
                    
                    //form validation
                    //check validations
                    var trWrapperList = non1872SavePreviwCmp.get("v.trWrapperList");
                    if(!$A.util.isEmpty(non1872SavePreviwCmp)){
                        var rfMap = non1872SavePreviwCmp.get("v.obsRequiredFieldMap");
                        console.log("rfMap : " + JSON.stringify(rfMap));
                        var obsTemplate = trWrapperList[0].testResults[0];
                        /*if($A.util.isEmpty(obsTemplate.OverallScore__c)){
                        	obsTemplate.OverallScore__c = null;    
                        }*/
                        console.log("obsTemplate of trwapper : " + JSON.stringify(obsTemplate));
                        var obsFieldLabelMap = component.get("v.obsFieldLabelMap");
                        var proceedFinal = true;
                        for (var fieldName in rfMap) {
                            var fieldCmp = non1872SavePreviwCmp.find(fieldName);
                            var hasError = null;
                            proceed = true;
                            if ($A.util.isEmpty(obsTemplate[fieldName]) || (obsTemplate[fieldName] == "")) {
                                
                                if (fieldName === "OperatedFromCode__c" || fieldName === "OperatedFromText__c") {
                                    if ($A.util.isEmpty(obsTemplate["OperatedFromCode__c"]) && $A.util.isEmpty(obsTemplate["OperatedFromText__c"])) {
                                        proceed = false;
                                        hasError = true;
                                        proceedFinal = (proceedFinal) ? false : false;
                                    }
                                } else if (fieldName === "OperatedToCode__c" || fieldName === "OperatedToText__c") {
                                    if ($A.util.isEmpty(obsTemplate["OperatedToCode__c"]) && $A.util.isEmpty(obsTemplate["OperatedToText__c"])) {
                                        proceed = false;
                                        hasError = true;
                                        proceedFinal = (proceedFinal) ? false : false;
                                    }
                                } else {
                                    message += obsFieldLabelMap[fieldName.toLowerCase()];
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                                
                            } else if(fieldName === "Date__c"){
                                var evaluationDateSplit = obsTemplate["Date__c"].split("-");
                                var year = parseInt(evaluationDateSplit[0]);
                                var month = parseInt(evaluationDateSplit[1] - 1);
                                var date = parseInt(evaluationDateSplit[2]);
                                var dateVal = new Date(year, month, date);
                                console.log("dateVal :: " + dateVal);
                                if(dateVal > currentDate){
                                    message += obsFieldLabelMap[fieldName.toLowerCase()];
                                    proceed = false;
                                    hasError = true;
                                    proceedFinal = (proceedFinal) ? false : false;
                                }
                            }else if ((fieldName === "OperatedFromCode__c" || fieldName === "OperatedFromText__c")
                                      && !$A.util.isEmpty(obsTemplate["OperatedFromCode__c"]) 
                                      && !$A.util.isEmpty(obsTemplate["OperatedFromText__c"])){
                                proceed = false;
                                hasError = true;
                                proceedFinal = (proceedFinal) ? false : false;
                            }else if ((fieldName === "OperatedToCode__c" || fieldName === "OperatedToText__c")
                                      && !$A.util.isEmpty(obsTemplate["OperatedToCode__c"]) 
                                      && !$A.util.isEmpty(obsTemplate["OperatedFromText__c"])){
                                proceed = false;
                                hasError = true;
                                proceedFinal = (proceedFinal) ? false : false;
                            }
                            if (!proceed) {
                                if (fieldName != "OperatedFromCode__c" 
                                    && fieldName != "OperatedFromText__c"
                                    && fieldName != "OperatedToCode__c"
                                    && fieldName != "OperatedToText__c") {
                                    message += ', ';
                                }
                            }
                            proceed = proceedFinal;
                            if (!$A.util.isEmpty(fieldCmp)) {
                                if (fieldName != "OperatedFromText__c"  
                                    && fieldName != "OperatedToText__c"
                                    && fieldName != "OperatedFromCode__c" 
                                    && fieldName != "OperatedToCode__c" 
                                    && fieldName != "Nearest_Station_Interlocking__c"
                                    && fieldName != "Train__c" 
                                   	&& fieldName != "Date__c" ) {
                                    fieldCmp.set("v.errors", hasError);
                                }
                                else if (fieldName === "OperatedFromText__c") {
                                    if (hasError === true) {
                                        if (!$A.util.isEmpty(obsTemplate["OperatedFromCode__c"]) && !$A.util.isEmpty(obsTemplate["OperatedFromText__c"])) {
                                            fieldCmp.set("v.errors",  [{message:"You cannot enter both Operated From fields."}]);
                                        } else if($A.util.isEmpty(obsTemplate["OperatedFromCode__c"]) && $A.util.isEmpty(obsTemplate["OperatedFromText__c"])) {
                                            fieldCmp.set("v.errors",  [{message:"You must enter one of the Operated From fields."}]);    
                                        }
                                        //fieldCmp.set("v.errors",  [{message:"You must enter one of the Operated From fields."}]);
                                    }
                                    else {
                                        fieldCmp.set("v.errors", null);
                                    }
                                } else if (fieldName === "OperatedToText__c") {
                                    if (hasError === true) {
                                        if (!$A.util.isEmpty(obsTemplate["OperatedToCode__c"]) && !$A.util.isEmpty(obsTemplate["OperatedToText__c"])) {
                                            fieldCmp.set("v.errors",  [{message:"You cannot enter both Operated To fields."}]);
                                        } else if($A.util.isEmpty(obsTemplate["OperatedToCode__c"]) && $A.util.isEmpty(obsTemplate["OperatedToText__c"])) {
                                            fieldCmp.set("v.errors",  [{message:"You must enter one of the Operated To fields."}]);    
                                        }
                                        //fieldCmp.set("v.errors",  [{message:"You must enter one of the Operated To fields."}]);
                                    }
                                    else {
                                        fieldCmp.set("v.errors", null);
                                    }
                                } else if (fieldName === "Date__c") {
                                    if (hasError === true) {
                                        fieldCmp.set("v.errors",  [{message:"Evaluation Date should not be future date."}]);
                                    }
                                    else {
                                        fieldCmp.set("v.errors", null);
                                    }
                                }
                                if (fieldName === "OperatedFromCode__c" ||
                                    fieldName === "OperatedToCode__c" ||
                                    fieldName === "Nearest_Station_Interlocking__c" ||
                                    fieldName === "Train__c" ||
                                   	fieldName === "Date__c" ) {
                                    fieldCmp.set("v.hasError", hasError);
                                }
                            }
                        }
                        formValidation = proceedFinal;
                    }
                    
                    console.log("formValidation :: " + formValidation);
                    console.log("proceedFinal :: " + proceedFinal);
                    
                    if(formValidation && needImpValidation){
                        proceed = true;
                        var obsFindingList = trWrapperList[0].testResults[0].Findings__r.records;
                        if(!$A.util.isEmpty(obsFindingList)){
                            var count = 0;
                            obsFindingList.forEach(function(finding) {
                                finding.Score__c = trWrapperList[0].findingList[count].Score__c;
                                count++;
                            });
                        }
                        trWrapperList[0].testResults[0].Findings__r.records = obsFindingList;
                        
                        for (var fieldName in trWrapperList[0].testResults[0]) {
                            if (fieldName.indexOf("__r") > 0 && fieldName != "Findings__r" && fieldName != "Employee__r" ) {
                                trWrapperList[0].testResults[0][fieldName] = undefined;
                            }
                        }
                    } else {
                        proceed = false;
                    }
                }else{
                    proceed = true;
                }
                console.log("selectionState before :: " + selectionState);
                if(proceed){
                    var params = {
                        "trWrapperListJSON" : JSON.stringify(testResultCmp.get("v.trWrapperList"))
                    };
                    helper.handleSaveAndSubmit(component, params);
                    selectionState -= 1;    
                    if(!isTest1872){
                    	component.set("v.submittedForm", true);
                    }
                }
                console.log("selectionState after :: " + selectionState);
                break;
        }
        
        if (proceed) {
            component.set("v.selectionState", selectionState + 1);
        } else {
            var messageFinal = message.slice(0, message.lastIndexOf(","));
            amtrak.fireErrorToastEvent(component, "Incomplete Form!", messageFinal);
        }
        helper.setTestFormLabels(component);
    },
    
    onclickPreviousButton : function(component, event, helper) {
        var selectionState = component.get("v.selectionState");
        console.log("selectionState :: " + selectionState);
        if (selectionState == 4) {
            var recordTypeId = component.get("v.obsTemplate.RecordTypeId");
            var recordTypeToDisplayTestNumbers = component.get("v.recordTypeToDisplayTestNumbers");
            if ($A.util.isEmpty(recordTypeToDisplayTestNumbers) || recordTypeToDisplayTestNumbers.indexOf(recordTypeId) < 0) {
                selectionState -= 2;
            }
            component.set("v.selectedEmpList", []);
            component.set("v.selectedEmpIdSet", "");
        } else if (selectionState == 5) {
            component.set("v.testEntryWrapperList", []);
            var testEntryCmp = component.find("test-entry-cmp");
            testEntryCmp.set("v.testEntryWrapperList", []);
        } 
        component.set("v.selectionState", selectionState - 1);
        helper.setTestFormLabels(component);
    },
    
    reloadTestWrapper : function(component, event, helper) {
        // Call server to reload Observation in TestResultWrapper
        console.log("MultiTestFormCmpController.reloadTestWrapper BEGIN");
        var testResultCmp = component.find("test-result-cmp");
        var params = {
            "trWrapperListJSON" : JSON.stringify(testResultCmp.get("v.trWrapperList"))
        };
        helper.handleReloadObservations(component, params);
        console.log("MultiTestFormCmpController.reloadTestWrapper END");
    }
})