({
    
    createTreeGrid : function(component, event, helper) {
        
        /*
        var treeColumns = [{label: 'Test Number', fieldName: 'testNumber', type: 'text'},
                           {label: 'Test Name', fieldName: 'testName', type: 'text'}];
        component.set("v.treeColumns", treeColumns);
        */
        
        var testWithObsList = component.get("v.testWithObservationsList");
        console.log("*** testWithObsList : " + testWithObsList);
        var testList = [];
        if(!$A.util.isEmpty(testWithObsList)){
            testWithObsList.forEach(function(testWithObs){
                console.log(testWithObs);
                var test = new Object();
                test.testNumber = testWithObs.testNumber;
                test.testName = testWithObs.testName;
                var employeeList = [];
                var testEntryList = testWithObs.entryList;
                console.log("************** testEntryList length: " + testEntryList.length);
                testEntryList.forEach(function(testEntry) {
                    var employeeDetails = new Object();
                    employeeDetails.testNumber = testEntry.employeeName;
                    employeeDetails.testName = testEntry.employeeInfo;
                    employeeList.push(employeeDetails);
                });
            
                if(employeeList.length > 0){
                 	test._children = employeeList;
                }
                testList.push(test);
            });
        }
        
        
        console.log("JSON Test List : " + JSON.stringify(testList));
        
        component.set("v.testList", testList);
        
	},
    
    handleOnRowSelection : function(component, event, helper) {
        var treeGridCmp = component.find('testTree');
        var selectedRows = treeGridCmp.getSelectedRows();
        console.log("*** selectedRows : " + JSON.stringify(selectedRows));
        
        var selectedEmpList = component.get("v.selectedEmpList");
        console.log("*** selectedEmpList : " + JSON.stringify(selectedEmpList));
        
        if(!$A.util.isEmpty(selectedRows)){
            var parent = {};
            var testEntryWrap = new Object();
            selectedRows.forEach(function(row){
                if(row.level == 1){
                    parent = row;
                    console.log("*** parent : " + JSON.stringify(parent));
                    testEntryWrap.testNumber = parent.testNumber;
                    testEntryWrap.completed = true;
                    console.log("*** testEntryWrap : " + JSON.stringify(testEntryWrap));
                }else if(row.level == 2 && !row.hasChildren){
                    selectedEmpList.forEach(function(employee){
                        if(employee.theName === row.testNumber){
                            var testEntryWrapList = employee.testNames;
                            console.log("*** testEntryWrapList : " + testEntryWrapList);
                            var isExist = false;
                            if(testEntryWrapList != null){
                                testEntryWrapList.forEach(function(testEntry){
                                    isExist = (testEntry.testNumber === parent.testNumber) ? true : false;
                                });    
                            }
                            if(!isExist){
                                if(testEntryWrapList != null && testEntryWrap != null){
                                    testEntryWrapList.push(testEntryWrap);
                                    employee.testNames = testEntryWrapList;
                                } else if(testEntryWrapList == null && testEntryWrap != null){
                                    testEntryWrapList = [];
                                    testEntryWrapList.push(testEntryWrap);
                                    employee.testNames = testEntryWrapList;
                                }    
                            }
                            
                        }
                    });
                }
            });
            console.log("*** selectedEmpList : " + JSON.stringify(selectedEmpList));
            component.set("v.selectedEmpList", selectedEmpList);
        }
        
        //create a RevSys_TestEntryWrapper 
        
        /*
        var testList = component.get("v.testList");
        
        if(!$A.util.isEmpty(selectedRows)){
            selectedRows.forEach(function(row){
                if(row.level == 1 && row.hasChildren){
                    console.log("get childrens.!!");
                    testList.forEach(function(test){
                        if(row.testNumber == test.testNumber){
                            var childrens = test._children;
                            console.log(" childrens BEFORE : " + JSON.stringify(childrens));
                            childrens.forEach(function(child){
                                child.selected = true;
                            });
                            test._children = childrens;
                            console.log(" testList : " + JSON.stringify(testList));
                            console.log(" childrens AFTER : " + JSON.stringify(childrens));
                        }
                    });
                }
            });
            
            component.set("v.testList", testList);
        }
        */
    }
})