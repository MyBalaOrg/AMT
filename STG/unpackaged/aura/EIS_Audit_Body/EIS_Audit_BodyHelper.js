({
	initializeAuditBody : function(component, apexMethodName, params) {
        this.fireToggleSpinnerEvent(component, false);
		var action = component.get(apexMethodName);
        action.setParams({ "params" : params });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(apexMethodName + " " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    this.setInitializationAttributes(component, returnValue);
                    component.set("v.errorMessage", "");
                } else {
                    component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
                }
            } else {
                console.log(response.getError());
            }
            this.fireToggleSpinnerEvent(component, true);
        });
		$A.enqueueAction(action);
	},
    
    setInitializationAttributes : function(component, returnValue) {
        var audit = returnValue.audit;
        if (!$A.util.isEmpty(audit)) {
            audit = JSON.parse(audit);
            component.set("v.audit", audit);
            if (!$A.util.isEmpty(audit.EIS_Positive_Findings__c)) {
                component.set("v.positiveFindingList", audit.EIS_Positive_Findings__c.split(";"));
                component.set("v.positiveFindingDeptList", audit.EIS_Positive_Findings_Departments__c.split(";"));
            }
        }
        var sideTabList = returnValue.sideTabList;
        if (!$A.util.isEmpty(sideTabList)) {
            sideTabList = JSON.parse(sideTabList);
            this.configureDepartmentSideTabs(component, component.get("v.audit"), sideTabList);
            //component.set("v.sideTabList", sideTabList);
            if (sideTabList.length > 0) {
                component.set("v.customSectionList", sideTabList[0].customSectionList);
            }
        }
        if (!$A.util.isEmpty(returnValue.userIsAPM)) {
            component.set("v.userIsAPM", JSON.parse(returnValue.userIsAPM));
        }
        if (!$A.util.isEmpty(returnValue.disableFindings)) {
            component.set("v.disableFindings", JSON.parse(returnValue.disableFindings));
            component.set("v.disablePositiveFindings", JSON.parse(returnValue.disablePositiveFindings));
            component.set("v.disableCorrectiveActions", JSON.parse(returnValue.disableCorrectiveActions));
        }
        if (!$A.util.isEmpty(returnValue.disableHeaderButtons)) {
            component.set("v.disableHeaderButtons", JSON.parse(returnValue.disableHeaderButtons));
        }
    },
    
    configureDepartmentSideTabs : function(component, audit, sideTabList) {
        if (component.get("v.tabName") === $A.get("$Label.c.EIS_Audit_Form_Tab_Department")) {
            var score = 0, pvCount = 0, mpCount = 0;
            for (var i = 0; i < sideTabList.length; i++) {
                score = component.get("v.audit.EIS_Department_Score_" + sideTabList[i].label + "__c");
                pvCount = component.get("v.audit.EIS_Potential_Violation_" + sideTabList[i].label + "__c");
                mpCount = component.get("v.audit.EIS_Management_Practice_" + sideTabList[i].label + "__c");
                if (!$A.util.isEmpty(score)) {
                    sideTabList[i].departmentScore = score;
                }
                //sideTabList[i].disabled = true;
                if (!$A.util.isEmpty(pvCount) && !$A.util.isEmpty(mpCount)) {
                    sideTabList[i].disabled = (pvCount + mpCount <= 0);
                }
            }
        }
        component.set("v.sideTabList", sideTabList);
    },
    
    getSelectedSectionList : function(component, sideTabList, selectedIndex) {
        this.fireToggleSpinnerEvent(component, false);
		var action = component.get("c.getCustomSections");
        var params = {
            "tabName" : component.get("v.tabName"),
            "sideTabName" : sideTabList[selectedIndex].label,
            "auditId" : component.get("v.auditId")
        };
        action.setParams({ "params" : params });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.getCustomSections " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    var customSectionList = returnValue.customSectionList;
                    if (!$A.util.isEmpty(customSectionList)) {
                        customSectionList = JSON.parse(customSectionList);
                        sideTabList[selectedIndex].customSectionList = customSectionList;
                        component.set("v.sideTabList", sideTabList);
                        component.set("v.customSectionList", customSectionList);
                    }
                    component.set("v.errorMessage", "");
                } else {
                    component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
                }
            } else {
                console.log(response.getError());
            }
            this.fireToggleSpinnerEvent(component, true);
        });
		$A.enqueueAction(action);
	},
    
    updatePositiveFindingAction : function(component, apexMethodName, params) {
        this.fireToggleSpinnerEvent(component, false);
        var action = component.get(apexMethodName);
        action.setParams({ "params" : params });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(apexMethodName + " " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    if (!$A.util.isEmpty(returnValue.audit)) {
                        var audit = JSON.parse(returnValue.audit);
                        component.set("v.audit", audit);
                        if (!$A.util.isEmpty(audit.EIS_Positive_Findings__c)) {
                            component.set("v.positiveFindingList", audit.EIS_Positive_Findings__c.split(";"));
                            component.set("v.positiveFindingDeptList", audit.EIS_Positive_Findings_Departments__c.split(";"));
                        } else {
                            component.set("v.positiveFindingList", []);
                            component.set("v.positiveFindingDeptList", []);
                        }
                    }
                    this.clearPositiveFindingFields(component);
                    component.set("v.errorMessage", "");
                } else {
                    component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
                }
            } else {
                console.log(response.getError());
            }
            this.fireToggleSpinnerEvent(component, true);
        });
		$A.enqueueAction(action);
    },
    
    clearPositiveFindingFields : function(component) {
        component.set("v.editPFIndex", -1);
        component.find("positive-finding-textarea").getElement().value = '';
        component.set("v.pfDeptBtnList", this.generateDefaultDepartmentButtonList());
    },
    
    generateDefaultDepartmentButtonList : function() {
        var deptBtnList = [
            {"label" : $A.get("$Label.c.EIS_Finding_Department_Engineering"), "selected" : false},
            {"label" : $A.get("$Label.c.EIS_Finding_Department_Environment"), "selected" : false},
            {"label" : $A.get("$Label.c.EIS_Finding_Department_Material"), "selected" : false},
            {"label" : $A.get("$Label.c.EIS_Finding_Department_Mechanical"), "selected" : false},
            {"label" : $A.get("$Label.c.EIS_Finding_Department_Transportation"), "selected" : false}
        ];
        return deptBtnList;
    },
    
    fireToggleSpinnerEvent : function(component, hideSpinner) {
        var toggleSpinner = component.getEvent("toggleLightningSpinner");
        toggleSpinner.setParams({"value" : hideSpinner});
        toggleSpinner.fire();
    }
})