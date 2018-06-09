({
    checkPermission : function(component,event) {
        var action = component.get("c.checkPermission");
        //action.setParams({"empCertId": component.get("v.recordId")});
        
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                //component.set("v.ecRecord", JSON.parse(returnValue.ecRecord));
                console.log(returnValue.hasPermission);
                component.set("v.loadComponent", JSON.parse(returnValue.hasPermission));
            } else {
                console.log('Problem fetching the observation record, response state: ' + state);
            }
            //amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        
        $A.enqueueAction(action);
    },
    softDeleteObservation : function(component,event) {
    	amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        
        console.log("recordId :: " + component.get("v.recordId"));
        var action = component.get("c.softDeleteObservation");
        action.setParams({"observationId": component.get("v.recordId")});
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    amtrak.fireErrorToastEvent(component, "Error!", returnValue.errorMsg);
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                } else {
                        //component.set("v.ecRecord", JSON.parse(returnValue.empCert));
                        /*var obsId = component.get("v.recordId");
						console.log(obsId);
                         var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": obsId,
                                "slideDevName": "detail"
                            });
                            navEvt.fire();*/
                        $A.get('e.force:refreshView').fire();
                }
            } else {
                console.log('Problem getting ec record, response state: ' + state);
            }
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        $A.enqueueAction(action);
	},
    performSearch : function(component, event, params) {
        console.log("found searchTest: " + $A.util.isEmpty(component.get("c.searchTest")));
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var action = component.get("c.searchTest");
        action.setParams({ "params" : params });
        console.log("-------------");
        console.log("Action: c.searchTest");
        console.log(params);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.searchTest " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                } else {
                    var searchTestCmp = component.find("search-test-cmp");
                    if (!$A.util.isEmpty(searchTestCmp)) {
                        if (!$A.util.isEmpty(returnValue.resultList)) {
                            var resultList = JSON.parse(returnValue.resultList);
                            if ($A.util.isEmpty(resultList) || resultList.length == 0) {
                                var toastParams = { 
                                    'title' : "Warning!",
                                    'type' : 'warning',
                                    'duration' : 7000
                                };
                                toastParams.message = "No Test found. Please enter a different search key.";
                                amtrak.fireToastEvent(component, toastParams);
                            } else {
                                searchTestCmp.setResultList(resultList);
                            }
                        }
                        if (!$A.util.isEmpty(returnValue.fieldLabels)) {
                            searchTestCmp.set("v.fieldLabels", JSON.parse(returnValue.fieldLabels));
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
                        component.set("v.showUpdate", true);
                    }
                }
            } else {
                console.log(response.getError());
            }
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        $A.enqueueAction(action);
    },
    updateObservationTest : function(component,event, params) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        
        var action = component.get("c.updateObservationTest");
        action.setParams({ "params" : params });
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    amtrak.fireErrorToastEvent(component, "Error!", returnValue.errorMsg);
                    console.log(returnValue.errorMsg);
                    console.log(returnValue.consolelog);
                } else {
                        $A.get('e.force:refreshView').fire();
                }
            } else {
                console.log('Problem getting ec record, response state: ' + state);
            }
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
        });
        $A.enqueueAction(action);
    },
})