({
	performSearch : function(component, params) {
        debugger;
		amtrak.fireToggleSpinnerEvent(component.getEvent("toggleLightningSpinner"), false);
        var action = component.get("c.searchForEmployee");
        action.setParams({ "params" : params });
        console.log("-------------");
        console.log("Action: c.searchForEmployee");
        console.log(params);
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.searchForEmployee " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                debugger;
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                } else {
                    var searchEmployeeCmp = component.find("search-employee-cmp");
                    if (!$A.util.isEmpty(searchEmployeeCmp)) {
                        if (!$A.util.isEmpty(returnValue.resultList)) {
                            var resultList = JSON.parse(returnValue.resultList);
                            if ($A.util.isEmpty(resultList) || resultList.length == 0) {
                                var toastParams = { 
                                    'title' : "Warning!",
                                    'type' : 'warning',
                                    'duration' : 7000
                                };
                                if (component.get("v.selectedRecordType.Name") == $A.get("$Label.c.RevSys_Observation_RT_Label_Test_1872")) {
                                    toastParams.message = "No employee found for the tests selected. Please select a different test number or enter a different search key.";
                                } else {
                                    toastParams.message = "No employee found for the tests selected. Please enter a different search key.";
                                }
                                var searchModalCmp = searchEmployeeCmp.find("search-result");
                                console.log("*** searchModalCmp : " + searchModalCmp);
                                if (!$A.util.isEmpty(searchModalCmp)) {
                                	searchModalCmp.set("v.filteredList", null);    
                                } 
                                
                                amtrak.fireToastEvent(component, toastParams);
                            } else {
                                console.log("found result for performSearch");
                                searchEmployeeCmp.setResultList(resultList);
                            }
                        }
                        if (!$A.util.isEmpty(returnValue.fieldLabels)) {
                            console.log("*** searchEmployeeCmp : " + searchEmployeeCmp);
                            searchEmployeeCmp.set("v.fieldLabels", JSON.parse(returnValue.fieldLabels));
                            var fieldLabels = JSON.parse(returnValue.fieldLabels);
                            var filterKeyList = [];
                            fieldLabels.forEach(function(label) {
                                filterKeyList.push("");
                            });
                            searchEmployeeCmp.set("v.filterKeyList", filterKeyList);
                        }
                        if (!$A.util.isEmpty(returnValue.limitBreak)) {
                            var toastParams = { 
                                'title' : "Warning!",
                                'message' : returnValue.limitBreak,
                                'type' : 'warning',
                                'duration' : 7000
                            };
                            amtrak.fireToastEvent(component, toastParams);
                        }
                    }
                }
            } else {
                console.log(response.getError());
            }
            amtrak.fireToggleSpinnerEvent(component.getEvent("toggleLightningSpinner"), true);
            console.log("-------------");
        });
		$A.enqueueAction(action);
	}
})