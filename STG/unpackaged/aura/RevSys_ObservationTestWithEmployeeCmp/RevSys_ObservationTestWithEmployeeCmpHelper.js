({
	calculatePercent : function(component, cmp, filter){
        
        var selectedEmpList = component.get("v.selectedEmpList");
        if(!$A.util.isEmpty(filter) && !$A.util.isEmpty(cmp)){
            if(!$A.util.isEmpty(filter.entryList)){
                var testEntryMap = {};
                var totalEmpCount = filter.entryList.length;
                var completedEmpCount = 0;
                filter.entryList.forEach(function(entry){
                    if(entry.completed){
                        completedEmpCount++;
                        var testKey  = entry.testNumber + "-" + entry.employeeName;
                        console.log("testKey: " + testKey);
                        testEntryMap[testKey] = true;
                    }else{
                        var testKey  = entry.testNumber + "-" + entry.employeeName;
                        console.log("testKey: " + testKey);
                        testEntryMap[testKey] = false;
                    }
                });
                var percentInNumber = ((completedEmpCount / totalEmpCount) * 100).toFixed(2);
                console.log("percentInNumber : " + percentInNumber);
                
                //completed
                
                if(percentInNumber > 0 && percentInNumber <= 30){
                    $A.util.addClass(cmp, 'gauge-c-red');
                    $A.util.removeClass(cmp, 'gauge-c-orange-50');
                    $A.util.removeClass(cmp, 'gauge-c-green');
                    $A.util.removeClass(cmp, 'gauge-c-orange-70');
                    $A.util.removeClass(cmp, 'gauge-c-orange-40');
                }else if(percentInNumber > 30 && percentInNumber <= 45){
                    $A.util.addClass(cmp, 'gauge-c-orange-40');
                    $A.util.removeClass(cmp, 'gauge-c-red');
                    $A.util.removeClass(cmp, 'gauge-c-green');
                    $A.util.removeClass(cmp, 'gauge-c-orange-70');
                    $A.util.removeClass(cmp, 'gauge-c-orange-50');
                }else if(percentInNumber > 45 && percentInNumber <= 50){
                    $A.util.addClass(cmp, 'gauge-c-orange-50');
                    $A.util.removeClass(cmp, 'gauge-c-red');
                    $A.util.removeClass(cmp, 'gauge-c-green');
                    $A.util.removeClass(cmp, 'gauge-c-orange-70');
                    $A.util.removeClass(cmp, 'gauge-c-orange-40');
                }else if(percentInNumber > 50 && percentInNumber < 100){
                    $A.util.addClass(cmp, 'gauge-c-orange-70');
                    $A.util.removeClass(cmp, 'gauge-c-red');
                    $A.util.removeClass(cmp, 'gauge-c-green');
                    $A.util.removeClass(cmp, 'gauge-c-orange-50');
                    $A.util.removeClass(cmp, 'gauge-c-orange-40');
                }else if(percentInNumber == 100){
                    $A.util.addClass(cmp, 'gauge-c-green');
                    $A.util.removeClass(cmp, 'gauge-c-red');
                    $A.util.removeClass(cmp, 'gauge-c-orange-50');
                    $A.util.removeClass(cmp, 'gauge-c-orange-40');
                    $A.util.removeClass(cmp, 'gauge-c-orange-70');
                } else if(percentInNumber == 0){
                    $A.util.addClass(cmp, 'gauge-c');
                    $A.util.removeClass(cmp, 'gauge-c-red');
                    $A.util.removeClass(cmp, 'gauge-c-orange-50');
                    $A.util.removeClass(cmp, 'gauge-c-green');
                    $A.util.removeClass(cmp, 'gauge-c-orange-40');
                    $A.util.removeClass(cmp, 'gauge-c-orange-70');
                }
                filter.percent = percentInNumber.toString() + "%";
                
            //    selectedEmpList = this.setPillColor(component, percentInNumber, filter);
                selectedEmpList = this.setPillColor(component, testEntryMap);
                
            //    console.log("*** selectedEmpList helper : " + JSON.stringify(selectedEmpList));
                component.set("v.selectedEmpList", selectedEmpList);
            }
        }
    },
    
    setPillColor : function(component, testEntryMap) {
        var selectedEmpList = component.get("v.selectedEmpList");
        console.log("testEntryMap: " +  JSON.stringify(testEntryMap));
        if (!$A.util.isEmpty(selectedEmpList)) {
            selectedEmpList.forEach(function(selectedEmp) {
                if (!$A.util.isEmpty(selectedEmp.testNames)) {
                    selectedEmp.testNames.forEach(function(testName) {
                        var empTestKey = testName.testNumber + "-" + testName.employeeName;
                        console.log("empTestKey: " + empTestKey);
                        if (!$A.util.isEmpty(testEntryMap[empTestKey])) {
                            testName.completed = testEntryMap[empTestKey];
                        }
                        console.log("testName.completed: " + testName.completed)
                    });
                }
            });
        }
        return selectedEmpList;
    },
/*
    setPillColor : function(component, percentInNumber, filter){
        var selectedEmpList = component.get("v.selectedEmpList");
        if(!$A.util.isEmpty(selectedEmpList)){
            selectedEmpList.forEach(function(selectedEmp){
                if(!$A.util.isEmpty(selectedEmp.testNames)){
                    selectedEmp.testNames.forEach(function(testName){
                        if(testName.testNumber == filter.testNumber){
                            if(percentInNumber == 100){
                            	testName.completed = true;    
                            }else{
                                testName.completed = false;
                            }
                            
                        }
                    });
                }
            });
        }
        return selectedEmpList;
    },
*/    
    clone : function(obj) {
        if (null == obj || "object" != typeof obj) return obj;
        var copy = obj.constructor();
        for (var attr in obj) {
            if (obj.hasOwnProperty(attr)) copy[attr] = obj[attr];
        }
        return copy;
    },
})