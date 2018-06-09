({
	employeeSelectChange : function(component, event, helper) {
        
        var BreakException = {};
        
        var selectedEmpName = event.getSource().get("v.name");
        var testEntrylist = component.get("v.testEntry");
        var selectedEmp = false;
        var testWithObsList = component.get("v.testWithObs");
        var testIndex = component.get("v.testIndex");
        
        //to show or hide pill
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
        
        if(!$A.util.isEmpty(testEntrylist)){
            try{
                testEntrylist.forEach(function(testEntry){
                    if(testEntry.employeeName.toString() == selectedEmpName){
                        selectedEmp = (testEntry.selected) ? true : false;
                        throw BreakException;
                    }
                });    
            }catch(e){
                if (e !== BreakException) throw e;
            }
            
            var notSelectedCount = 0
            if(!$A.util.isEmpty(testEntrylist)){
                testEntrylist.forEach(function(testEntry){
                    if(!testEntry.selected){
                        notSelectedCount++;
                    }
                });
            }
            console.log("*** selectedEmp : " + selectedEmp);
            console.log("*** notSelectedCount : " + notSelectedCount);
            
            if(!$A.util.isEmpty(testWithObsList)){
                var testWithObs = testWithObsList[testIndex];
                if(!$A.util.isEmpty(testWithObs)){
                    if(notSelectedCount == testEntrylist.length && !selectedEmp){
                    	testWithObs.selected = false;
                        component.set("v.selectAll", false);
                    }else if(notSelectedCount < testEntrylist.length && notSelectedCount > 0){
                        testWithObs.selected = true;
                        component.set("v.selectAll", false);
                    }else if(notSelectedCount == 0){
                        testWithObs.selected = true;
                        component.set("v.selectAll", true);
                    }
                    
                }
                component.set("v.testWithObs", testWithObsList);
            }
        //    console.log("*** testWithObsList : " + JSON.stringify(testWithObsList));
            
            if(selectedEmp && selectedEmpName != ""){
                var testWithObs = testWithObsList[testIndex];
                if(!$A.util.isEmpty(selectedEmpList)){
                    selectedEmpList.forEach(function(selectedEmp){
                        if(selectedEmp.theName == selectedEmpName){
                            var testList = employeeToTestMap[selectedEmpName];
                            testList.sort();
                            if(testList.indexOf(testWithObs.testNumber) <= -1){
                                testList.push(testWithObs.testNumber);
                            }
                        }
                    });
                }
                
            } else if(!selectedEmp && selectedEmpName != ""){
                var testWithObs = testWithObsList[testIndex];
                if(!$A.util.isEmpty(selectedEmpList)){
                    selectedEmpList.forEach(function(selectedEmp){
                        if(selectedEmp.theName == selectedEmpName){
                            var testList = employeeToTestMap[selectedEmpName];
                            testList.sort();
                            if(testList.indexOf(testWithObs.testNumber) > -1){
                                testList.splice(testList.indexOf(testWithObs.testNumber), 1);
                            }
                        }
                    });
                }
            }
            
            if(!$A.util.isEmpty(employeeToTestMap) && !$A.util.isEmpty(selectedEmpList)){
                selectedEmpList.forEach(function(selectedEmp){
                    var testList = employeeToTestMap[selectedEmp.theName];
                    testList.sort();
                    var testNameList = [];
                    if(!$A.util.isEmpty(testList)){
                        testList.forEach(function(test){
                            console.log("BBBBB employeeName: " + selectedEmp.theName);
                            var testName = {};
                            testName.testNumber = test.toString();
                            testName.employeeName = selectedEmp.theName;
                            testNameList.push(testName);
                        });
                    }
                    selectedEmp.testNames = testNameList;
                });
            }
            component.set("v.selectedEmpList", selectedEmpList);
            
            
        }
        
	},
    
    selectAllEmployeeToggle : function(component, event, helper) {
        var selectedAllEmpVal = event.getSource().get("v.value");
        var testEntrylist = component.get("v.testEntry");
        var testWithObsList = component.get("v.testWithObs");
        var testIndex = component.get("v.testIndex");
        
        //to show or hide pill
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
        
        if(!$A.util.isEmpty(testEntrylist)){
            testEntrylist.forEach(function(testEntry){
                testEntry.selected = selectedAllEmpVal;
                var testList = employeeToTestMap[testEntry.employeeName];
                if(selectedAllEmpVal){
                    if(testList.indexOf(testEntry.testNumber) <= -1){
                        testList.push(testEntry.testNumber);
                    }
                }else{
                    if(testList.indexOf(testEntry.testNumber) >= 0){
                        testList.splice(testList.indexOf(testEntry.testNumber), 1);
                    }
                }
            });
            component.set("v.testEntry", testEntrylist);
        }
        
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
        component.set("v.selectedEmpList", selectedEmpList);
        
        if(!$A.util.isEmpty(testWithObsList)){
            var testWithObs = testWithObsList[testIndex];
            console.log("*** testIndex : " + testIndex);
        //    console.log("*** testWithObs : " + testWithObs);
            if(!$A.util.isEmpty(testWithObs)){
                testWithObs.selected = selectedAllEmpVal;
            }
            component.set("v.testWithObs", testWithObsList);
        }
    //    console.log("*** testWithObsList : " + JSON.stringify(testWithObsList));
    },
    
    editEmployeeDetails : function(component, event, helper) {
        event.stopPropagation();
        
        var dataset = event.target.dataset;
    	var employeeName = dataset.recordName;
        var idx = dataset.recordIndex;     
        
        var BreakException = {};
        var testEntry = component.get("v.testEntry");

        try{
            if(!$A.util.isEmpty(testEntry)){
                var count = 0;
                testEntry.forEach(function(test){
                    if(idx == count){
                        //test.checkMethodReq = false;
                        if (!$A.util.isEmpty(test.speedCheckMethodList) && test.speedCheckMethodList.length > 0) {
                            //test.checkMethodReq = true;
                        }
                        if($A.util.isEmpty(test.checkMethodReq)){
                            test.checkMethodReq = false;
                        }
                        test.requiredFields["Speed__c"] =(test.checkMethodReq) ? true : false;
                        if(test.testNumber == "128"){
                            test.Result__c = "C = Compliance";
                            test.obs.Result__c = "C = Compliance";
                        }
                        component.set("v.testEntry", testEntry);
                        throw BreakException;
                    }
                    count++;//test
                });
            }
        }catch(e){
            if(e != BreakException){
                throw e;
            }
        }

        var resultRow = component.find("resultRow");
        var theRow;
        if (resultRow.length >= 0) {
            theRow = resultRow[idx];
        }
        else {
            theRow = resultRow;
        }
        $A.util.toggleClass(theRow, "slds-hide");
        // Hide/show TestResultEntryCmp
        var showResultEntry = component.get("v.showResultEntry");
        if (showResultEntry === false) {
            component.set("v.showResultEntry", true);
        }              
    },
    
    handleupdateEmployeeStatus: function(component, event, helper){
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        var updateEmployeeStatus = paramMap.updateEmployeeStatus;
        var rowIndex = paramMap.rowIndex;
        console.log("*** rowIndex : " + rowIndex);
        var testEntry = component.get("v.testEntry");
        testEntry.completed = updateEmployeeStatus;
        component.set("v.testEntry", component.get("v.testEntry"));
        amtrak.fireMapParamEvent(component, "calculateTestPercent", {});
        
        if(rowIndex == 0 && updateEmployeeStatus){
            //var params = {"testEntry" : testEntry[0]};
            //amtrak.fireMapParamEvent(component, "populateResultInformation", params);
        }
    }
    
})