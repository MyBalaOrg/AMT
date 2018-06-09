({
    handleToggle : function(component, event, helper) {
        var employeeRow = component.find("employeesRow");
        var toggleButtons = component.find("toggleButton");
        console.log("toggleButtons : " + toggleButtons);
        var idx = event.getSource().get("v.name");
        console.log("=====> idx: " + idx);
        var theButton = null;
        if(!$A.util.isEmpty(toggleButtons)){
            if (toggleButtons.length && toggleButtons.length > 0) {
                theButton = toggleButtons[idx];
            }else{
                theButton = toggleButtons;
            }
        }
        var iconName = theButton.get("v.iconName");
        console.log("iconName : " + iconName);
        theButton.set("v.iconName",iconName==="utility:chevronright" ? "utility:chevrondown" : "utility:chevronright");
        var theRow = null;
        if(!$A.util.isEmpty(employeeRow)){
            if (employeeRow.length && employeeRow.length > 0) {
                theRow = employeeRow[idx];
            }else{
                theRow = employeeRow;
            }
        }
        $A.util.toggleClass(theRow, "slds-hide");
        
    },
    
    testSelectChange : function(component, event, helper) {
        
        var selectedTestNumber = event.getSource().get("v.name");
        console.log("selectedTestNumber : " + selectedTestNumber);
        var testWithObsList = component.get("v.filteredList");
		var selectedEmpList = component.get("v.selectedEmpList");        
        var employeeToTestMap = {};
        
        if(!$A.util.isEmpty(selectedEmpList)){
            selectedEmpList.forEach(function(selectedEmp){
                employeeToTestMap[selectedEmp.theName] = [];
                var testNames = selectedEmp.testNames;
                if(!$A.util.isEmpty(testNames)){
                    testNames.forEach(function(testName){
                        employeeToTestMap[selectedEmp.theName].push(testName.testNumber.toString());
                    });
                }
            });
        }
        
        if(!$A.util.isEmpty(testWithObsList)) {
            var count = 0;
            testWithObsList.forEach(function(testWithObs){
                if(testWithObs.testNumber.toString() == selectedTestNumber){
                    var entryList = testWithObs.entryList;
                    
                    if(!$A.util.isEmpty(entryList)) {
                        var selectedEmp = (testWithObs.selected) ? true : false;
                        
                        entryList.forEach(function(entry){
                            entry.selected = selectedEmp;
                            var testList = employeeToTestMap[entry.employeeName];
                            if(selectedEmp){
                                if(testList.indexOf(testWithObs.testNumber) <= -1){
                                    testList.push(testWithObs.testNumber);
                                }
                            }else{
                                if(testList.indexOf(testWithObs.testNumber) >= 0){
                                    if (testList.indexOf(testWithObs.testNumber) > -1) {
                                        testList.splice(testList.indexOf(testWithObs.testNumber), 1);
                                    }
                                }
                            }
                        });
                        var empTestTableCmp = component.find("testEmployees");
                        console.log("*** empTestTableCmp : " + empTestTableCmp);
                        if(!$A.util.isEmpty(empTestTableCmp)) {
                            var empTestTable = null;
                            if (empTestTableCmp.length && empTestTableCmp.length > 0) {
                                empTestTable = empTestTableCmp[count];
                            }else{
                                empTestTable = empTestTableCmp;
                            }
                            empTestTable.set("v.selectAll", selectedEmp);
                        }
                        
                        testWithObs.entryList = entryList;
                    }
                }else{
                    var entryList = testWithObs.entryList;
                    if(!$A.util.isEmpty(entryList)) {
                        entryList.forEach(function(entry){
                            var testList = employeeToTestMap[entry.employeeName];
                            if(entry.selected){
                                if(testList.indexOf(testWithObs.testNumber) <= -1){
                                    testList.push(testWithObs.testNumber);
                                }
                            }else{
                                if(testList.indexOf(testWithObs.testNumber) >= 0){
                                    if (testList.indexOf(testWithObs.testNumber) > -1) {
                                        testList.splice(testList.indexOf(testWithObs.testNumber), 1);
                                    }
                                }
                            }
                        });
                    }
                }
                count++;
            });
            console.log("@@@ testWithObsList : " + JSON.stringify(testWithObsList));
            component.set("v.filteredList", testWithObsList);
        }
        
        console.log("*** employeeToTestMap : " + JSON.stringify(employeeToTestMap));
        
        if(!$A.util.isEmpty(employeeToTestMap) && !$A.util.isEmpty(selectedEmpList)){
            selectedEmpList.forEach(function(selectedEmp){
                var testList = employeeToTestMap[selectedEmp.theName];
                testList.sort();
                var testNameList = [];
                if(!$A.util.isEmpty(testList)){
                    testList.forEach(function(test){
                        var testName = {};
                        testName.testNumber = test.toString();
                        testName.employeeName = selectedEmp.theName;
                        testNameList.push(testName);
                    });
                }
                selectedEmp.testNames = testNameList;
            });
        }
        
        console.log("*** selectedEmpList : " + JSON.stringify(selectedEmpList));
        component.set("v.selectedEmpList", selectedEmpList);
    },
    
    handlecalculateTestPercent : function(component, event, helper){
        event.stopPropagation();
        var selectedList = component.get("v.selectedList");
        var gaugeCmp = component.find("gauge");
        console.log("*** gaugeCmp : " + gaugeCmp);
        
        if (!$A.util.isEmpty(selectedList)) {
            var count = 0;
            var completedCount = 0;
            selectedList.forEach(function(filter) {
                if (!$A.util.isEmpty(gaugeCmp)) {
                    if (gaugeCmp.length && gaugeCmp.length > 0) {
                        var cmp = gaugeCmp[count];
                        console.log("cmp isEmpty: " + $A.util.isEmpty(cmp));
                        helper.calculatePercent(component, cmp, filter);
                        count++;
                    }else{
                        console.log("gaugeCmp isEmpty: " + $A.util.isEmpty(gaugeCmp));
                        helper.calculatePercent(component, gaugeCmp, filter);
                    }
                }
                if(filter.percent == "100.00%"){
                    completedCount++;
                }
            });
            
            var params = null;
            if(completedCount == selectedList.length){
                params = {"disableNextButton" : false};
                //remove all __r from the selected list 
                if(!$A.util.isEmpty(selectedList)){
                    selectedList.forEach(function(selectedCmp){
                        if(!$A.util.isEmpty(selectedCmp.entryList)){
                            selectedCmp.entryList.forEach(function(entry){
                                for (var entryData in entry) {
                                    if (entryData.indexOf("__r") > 0) {
                                        entry[entryData] = undefined;
                                    }
                                }
                            });
                        }
                    });
                }
            }else{
                params = {"disableNextButton" : true};
            }
            amtrak.fireMapParamEvent(component, "enableNextButton", params);
        }
        console.log("*** SelectedList AFTER : " + JSON.stringify(selectedList));
        component.set("v.selectedList", selectedList);
    },
    
    handlepopulateTestResult : function(component, event, helper){
        event.stopPropagation();
        console.log("Inside event handler : handlePopulateResultInformation");
        var paramMap = event.getParam("paramMap");
        console.log("*** paramMap : " + paramMap);
        debugger;
        if(!$A.util.isEmpty(paramMap)){
            var testEntry = paramMap.testEntryResult;
            var testIndex = paramMap.testIndex;
            var rowIndex = paramMap.rowIndex;
            //ETR-1203 
            var resultRequiredFieldMap = paramMap.resultRequiredFieldMap;

            var picklistMapRegionState = component.get("v.picklistMapRegionState");
            var picklistMapStateSubDivision = component.get("v.picklistMapStateSubDivision");
            
            if(!$A.util.isEmpty(testEntry)){
                var selectedList = component.get("v.selectedList");
                debugger;
                console.log("** selectedList in populate info BEFORE : " + JSON.stringify(selectedList));
                if(!$A.util.isEmpty(selectedList)){
                    selectedList.forEach(function(selectedRecord){
                        if(!$A.util.isEmpty(selectedRecord.entryList)){
                            selectedRecord.entryList.forEach(function(entry){
                                if(!entry.completed){
                                    if(testIndex == 0){
                                        
                                        if(entry.testNumber == testEntry.testNumber){
                                            entry.obs.Date__c = testEntry.obs.Date__c;
                                            entry.obs.TimeHH__c = testEntry.obs.TimeHH__c;
                                            entry.obs.TimeMM__c = testEntry.obs.TimeMM__c;
                                            entry.obs.Result__c = testEntry.obs.Result__c;
                                            entry.obs.Comments__c = testEntry.obs.Comments__c;
                                            entry.obs.Speed__c = testEntry.obs.Speed__c;
                                            entry.obs.SpeedCheckMethod__c = testEntry.obs.SpeedCheckMethod__c;
                                            entry.obs.NonComplianceRuleNumber__c = testEntry.obs.NonComplianceRuleNumber__c;
                                            entry.obs.SupervisorsCommentSelection__c = testEntry.obs.SupervisorsCommentSelection__c;
                                            // ETR-1204
                                            entry.obs.DiscussedWithEmployee__c = testEntry.obs.DiscussedWithEmployee__c;
                                        }
                                        
                                        entry.obs.RailroadRule__c = testEntry.obs.RailroadRule__c;
                                        entry.obs.RegionProperty__c = testEntry.obs.RegionProperty__c;
                                        
                                        if(!$A.util.isEmpty(testEntry.obs.RegionProperty__c)){
                                            var testEmployeesCmp = component.find("testEmployees");
                                            if(!$A.util.isEmpty(testEmployeesCmp)){
                                                if (testEmployeesCmp.length && testEmployeesCmp.length > 0) {
                                                    var testEmployees = testEmployeesCmp[testIndex];
                                                    if(!$A.util.isEmpty(testEmployees)){
                                                    	var testResultCmp = testEmployees.find("testResult");
                                                        if(!$A.util.isEmpty(testResultCmp)){
                                                            if (testResultCmp.length && testResultCmp.length > 0) {
                                                                var testResult = testResultCmp[rowIndex];
                                                                if(!$A.util.isEmpty(testResult)){
                                                                    testResult.set("v.statePicklist", picklistMapRegionState[testEntry.obs.RegionProperty__c]);
                                                                    testResult.set("v.subdivisionPicklist", picklistMapStateSubDivision[testEntry.obs.State__c]);
                                                                }
                                                            }else{
                                                                var testResult = testResultCmp;
                                                                testResult.set("v.statePicklist", picklistMapRegionState[testEntry.obs.RegionProperty__c]);
                                                                testResult.set("v.subdivisionPicklist", picklistMapStateSubDivision[testEntry.obs.State__c]);
                                                            }
                                                        }
                                                    }
                                                }else{
                                                    var testEmployees = testEmployeesCmp;
                                                    if(!$A.util.isEmpty(testEmployees)){
                                                        var testResultCmp = testEmployees.find("testResult");
                                                        if(!$A.util.isEmpty(testResultCmp)){
                                                            if (testResultCmp.length && testResultCmp.length > 0) {
                                                                var testResult = testResultCmp[rowIndex];
                                                                if(!$A.util.isEmpty(testResult)){
                                                                    testResult.set("v.statePicklist", picklistMapRegionState[testEntry.obs.RegionProperty__c]);
                                                                    testResult.set("v.subdivisionPicklist", picklistMapStateSubDivision[testEntry.obs.State__c]);
                                                                }
                                                            }else{
                                                                var testResult = testResultCmp;
                                                                testResult.set("v.statePicklist", picklistMapRegionState[testEntry.obs.RegionProperty__c]);
                                                                testResult.set("v.subdivisionPicklist", picklistMapStateSubDivision[testEntry.obs.State__c]);
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                         
                                        entry.obs.State__c = testEntry.obs.State__c;
                                        entry.obs.Subdivision__c = testEntry.obs.Subdivision__c;
                                        entry.obs.TrainDescription__c = testEntry.obs.TrainDescription__c;
                                        entry.obs.PersonalAreaCode__c = testEntry.obs.PersonalAreaCode__c;
                                        entry.obs.PersonallyObserved__c = testEntry.obs.PersonallyObserved__c;
                                        //entry.obs.NonComplianceRuleNumber__c = testEntry.obs.NonComplianceRuleNumber__c;
                                        // ETR-1204
                                        //entry.obs.DiscussedWithEmployee__c = testEntry.obs.DiscussedWithEmployee__c;
                                        //entry.obs.SupervisorsCommentSelection__c = testEntry.obs.SupervisorsCommentSelection__c;
                                        entry.obs.MpSg__c = testEntry.obs.MpSg__c;
                                        entry.obs.MpSgNumber__c = testEntry.obs.MpSgNumber__c;
                                    }else{
                                        if(entry.testNumber == testEntry.testNumber){
                                            entry.obs.Date__c = testEntry.obs.Date__c;
                                            entry.obs.TimeHH__c = testEntry.obs.TimeHH__c;
                                            entry.obs.TimeMM__c = testEntry.obs.TimeMM__c;
                                            entry.obs.Result__c = testEntry.obs.Result__c;
                                            entry.obs.Comments__c = testEntry.obs.Comments__c;
                                            entry.obs.RailroadRule__c = testEntry.obs.RailroadRule__c;
                                            entry.obs.RegionProperty__c = testEntry.obs.RegionProperty__c;
                                            
                                            if(!$A.util.isEmpty(testEntry.obs.RegionProperty__c)){
                                                var testEmployeesCmp = component.find("testEmployees");
                                                if(!$A.util.isEmpty(testEmployeesCmp)){
                                                    if (testEmployeesCmp.length && testEmployeesCmp.length > 0) {
                                                        var testEmployees = testEmployeesCmp[testIndex];
                                                        if(!$A.util.isEmpty(testEmployees)){
                                                            var testResultCmp = testEmployees.find("testResult");
                                                            if(!$A.util.isEmpty(testResultCmp)){
                                                                if (testResultCmp.length && testResultCmp.length > 0) {
                                                                    var testResult = testResultCmp[rowIndex];
                                                                    if(!$A.util.isEmpty(testResult)){
                                                                        testResult.set("v.statePicklist", picklistMapRegionState[testEntry.obs.RegionProperty__c]);
                                                                        testResult.set("v.subdivisionPicklist", picklistMapStateSubDivision[testEntry.obs.State__c]);
                                                                    }
                                                                }else{
                                                                    var testResult = testResultCmp;
                                                                    testResult.set("v.statePicklist", picklistMapRegionState[testEntry.obs.RegionProperty__c]);
                                                                    testResult.set("v.subdivisionPicklist", picklistMapStateSubDivision[testEntry.obs.State__c]);
                                                                }
                                                            }
                                                        }
                                                    }else{
                                                        var testEmployees = testEmployeesCmp;
                                                        if(!$A.util.isEmpty(testEmployees)){
                                                            var testResultCmp = testEmployees.find("testResult");
                                                            if(!$A.util.isEmpty(testResultCmp)){
                                                                if (testResultCmp.length && testResultCmp.length > 0) {
                                                                    var testResult = testResultCmp[rowIndex];
                                                                    if(!$A.util.isEmpty(testResult)){
                                                                        testResult.set("v.statePicklist", picklistMapRegionState[testEntry.obs.RegionProperty__c]);
                                                                        testResult.set("v.subdivisionPicklist", picklistMapStateSubDivision[testEntry.obs.State__c]);
                                                                    }
                                                                }else{
                                                                    var testResult = testResultCmp;
                                                                    testResult.set("v.statePicklist", picklistMapRegionState[testEntry.obs.RegionProperty__c]);
                                                                    testResult.set("v.subdivisionPicklist", picklistMapStateSubDivision[testEntry.obs.State__c]);
                                                                }
                                                            }
                                                        }
                                                    } 
                                                    
                                                }
                                            }
                                            
                                            entry.obs.State__c = testEntry.obs.State__c;
                                            entry.obs.Subdivision__c = testEntry.obs.Subdivision__c;
                                            entry.obs.TrainDescription__c = testEntry.obs.TrainDescription__c;
                                            entry.obs.PersonalAreaCode__c = testEntry.obs.PersonalAreaCode__c;
                                            entry.obs.PersonallyObserved__c = testEntry.obs.PersonallyObserved__c;
                                        //    entry.obs.NonComplianceRuleNumber__c = testEntry.obs.NonComplianceRuleNumber__c;
                                            entry.obs.DiscussedWithEmployee__c = testEntry.obs.DiscussedWithEmployee__c;
                                        //    entry.obs.SupervisorsCommentSelection__c = testEntry.obs.SupervisorsCommentSelection__c;
                                            entry.obs.MpSg__c = testEntry.obs.MpSg__c;
                                            entry.obs.MpSgNumber__c = testEntry.obs.MpSgNumber__c;
                                            entry.obs.Speed__c = testEntry.obs.Speed__c;
                                            entry.obs.SpeedCheckMethod__c = testEntry.obs.SpeedCheckMethod__c;
                                        }
                                    }
                                }
                                
                            });
                        }
                    });
                    component.set("v.selectedList", selectedList);
                    console.log("** selectedList in populate info : " + JSON.stringify(selectedList));
                    
                    
                    var testEmployeeCmp = component.find("testEmployees");
                    if(!$A.util.isEmpty(testEmployeeCmp)){
                        if (testEmployeeCmp.length && testEmployeeCmp.length > 0) {
                            testEmployeeCmp.forEach(function(testEmp) {
                                var testResultCmp = testEmp.find("testResult");
                                if(!$A.util.isEmpty(testResultCmp)){                                    
                                    if (testResultCmp.length && testResultCmp.length > 0) {
                                        testResultCmp.forEach(function(testResult) {
                                            //ETR-1203
                                            var resultTestIdx = testResult.get("v.testIndex");
                                            if (testIndex == resultTestIdx) {
                                                testResult.set("v.resultRequiredFieldMap", resultRequiredFieldMap);
                                            }
                                            testResult.checkTestCompletion();
                                        });
                                    }else{
                                        //ETR-1203
                                        var resultTestIdx = testResultCmp.get("v.testIndex");
                                        if (testIndex == resultTestIdx) {
                                            testResultCmp.set("v.resultRequiredFieldMap", resultRequiredFieldMap);
                                        }
                                        testResultCmp.checkTestCompletion();
                                    }
                                }
                            });
                        }else{
                            var testResultCmp = testEmployeeCmp.find("testResult");
                            if(!$A.util.isEmpty(testResultCmp)){
                                if (testResultCmp.length && testResultCmp.length > 0) {
                                    testResultCmp.forEach(function(testResult) {
                                        //ETR-1203
                                        var resultTestIdx = testResult.get("v.testIndex");
                                        if (testIndex == resultTestIdx) {
                                            testResult.set("v.resultRequiredFieldMap", resultRequiredFieldMap);
                                        }
                                        testResult.checkTestCompletion();
                                    });
                                }else{
                                    //ETR-1203
                                    var resultTestIdx = testResultCmp.get("v.testIndex");
                                    if (testIndex == resultTestIdx) {
                                        testResultCmp.set("v.resultRequiredFieldMap", resultRequiredFieldMap);
                                    }
                                    testResultCmp.checkTestCompletion();
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    },
    
    onkeyupFilterResults : function(component, event, helper){
        event.stopPropagation();
        var performFilter = false;
        var deleted = event.keyCode === 8;
        var colIndex = event.currentTarget.dataset.colIndex;
        var filterKey = event.currentTarget.value;
        var filterKeyList = component.get("v.filterKeyList");
        var newFilteredList = [];
        if (deleted) {
            filterKeyList[colIndex] = filterKey;
            var filteredList = component.get("v.testWithObservationsList");
            filteredList.forEach(function(item) {
                var matched = true;
                try {
                    filterKeyList.forEach(function(keyValue) {
                        if(!$A.util.isEmpty(keyValue) && colIndex == 0){
                            if (!$A.util.isEmpty(item.testNumber) && !(item.testNumber.toLowerCase().indexOf(filterKey.toLowerCase()) >= 0)) {
                                throw BreakException;
                            }          
                        } else if(!$A.util.isEmpty(keyValue) && colIndex == 1){
                            if (!$A.util.isEmpty(item.testName) && !(item.testName.toLowerCase().indexOf(filterKey.toLowerCase()) >= 0)) {
                                throw BreakException;
                            }
                        }
                    });
                } catch (err) {
                    console.log("Exception Caught");
                    matched = false;
                }
                if (matched) {
                    newFilteredList.push(item);
                }
            });
            component.set("v.filteredList", newFilteredList);
        } else if (filterKey.length > 1) {
            var filteredList = component.get("v.filteredList");
            filteredList.forEach(function(item) {
                if(!$A.util.isEmpty(filterKey) && colIndex == 0){
                    if (!$A.util.isEmpty(item.testNumber) && (item.testNumber.toLowerCase().indexOf(filterKey.toLowerCase()) >= 0)) {
                        newFilteredList.push(item);
                    }          
                } else if(!$A.util.isEmpty(filterKey) && colIndex == 1){
                    if (!$A.util.isEmpty(item.testName) && (item.testName.toLowerCase().indexOf(filterKey.toLowerCase()) >= 0)) {
                        newFilteredList.push(item);
                    }
                }
            });
            component.set("v.filteredList", newFilteredList);
        }
        //amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
    },
    
    onblurFilterResults : function(component, event, helper){
        event.stopPropagation();
        var colIndex = event.currentTarget.dataset.colIndex;
        var filterKey = event.currentTarget.value;
        var filterKeyList = component.get("v.filterKeyList");
        filterKeyList[colIndex] = filterKey;
        component.set("v.filterKeyList", filterKeyList);
    }
    
})