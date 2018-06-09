({
    doInit : function(component, event, helper) {
        if ($A.util.isEmpty(component.get("v.recordId"))) {
            helper.initializeCaseCreation(component);
        } else {
            helper.initializeCaseRecordPage(component);
        }
    },
    
    handleSaveButtonClicked : function(component, event, helper) {
        helper.toggleLightningSpinner(component, false);
        var newCase = helper.getCaseRecordForUpdate(component);
		var action = component.get("c.saveCaseRecord");
        action.setParams({
            "recordTypeName" : component.get("v.recordTypeName"),
            "caseJSON" : JSON.stringify(newCase)
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.saveCaseRecord " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
                } else {
                    component.set("v.errorMessage", "");
                    helper.setCaseInformationAfterCallBack(component, returnValue);
                    
                    //Turn off edit mode for all section components
                    var sectionCmpList = component.find("case-section-detail");
                    if (!$A.util.isEmpty(sectionCmpList)) {
                        sectionCmpList.forEach(function(sectionCmp) {
                            sectionCmp.set("v.editMode", false);
                        });
                    }
                    //Turn off edit mode for all tab components
                    var tabCmpList = component.find("case-tab-details");
                    if (!$A.util.isEmpty(tabCmpList)) {
                        tabCmpList.forEach(function(tabCmp) {
                            tabCmp.set("v.editMode", false);
                        });
                    }
                }
            } else {
                component.set("v.errorMessage", response.getError());
            }
            helper.toggleLightningSpinner(component, true);
        });
		$A.enqueueAction(action);
    },
    
    onchangeSelectRecordType : function(component, event, helper) {
        event.stopPropagation();
        if ($A.util.isEmpty(component.get("v.recordId"))) {
            helper.initializeCaseCreation(component);
        } else {
            helper.initializeCaseRecordPage(component);
        }
    },
    
    createNewCaseRecord : function(component, event, helper) {
        helper.toggleLightningSpinner(component, false);
        var newCase = helper.getCaseRecordForUpdate(component);
		var action = component.get("c.saveNewCaseRecord");
        action.setParams({ 
            "caseJSON" : JSON.stringify(newCase)
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.saveNewCaseRecord " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
                } else {
                    component.set("v.errorMessage", "");
                    var recordId = returnValue.recordId;
                    if (!$A.util.isEmpty(recordId)) {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": recordId,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    }
                }
            } else {
                component.set("v.errorMessage", response.getError());
            }
            helper.toggleLightningSpinner(component, true);
        });
		$A.enqueueAction(action);
    },
    
    onclickCaseTab : function(component, event, helper) {
        event.stopPropagation();
        var value = event.target.value;
        component.set("v.selectedTab", value);
    },
    
    handleToggleLightningSpinner : function(component, event, helper) {
        event.stopPropagation();
        var hideSpinner = event.getParam("value");
        helper.toggleLightningSpinner(component, hideSpinner);
    }
})