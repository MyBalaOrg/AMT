({
    doInit : function(component, event, helper) {
        var tabName = component.get("v.tabName");
        var sideTabList = component.get("v.sideTabList");
        var params = {'auditId': component.get("v.auditId")};
        
        if (tabName === $A.get("$Label.c.EIS_Audit_Form_Tab_Protocol")) {
            helper.initializeAuditBody(component, "c.initializeProtocols", params);
        } else if (tabName === $A.get("$Label.c.EIS_Audit_Form_Tab_Department")) {
            helper.initializeAuditBody(component, "c.initializeDepartments", params);
        }
        
        /*if ($A.util.isEmpty(sideTabList) || $A.util.isEmpty(sideTabList.length)) {
            //To improve performance, set up event to update front end components instead of making server call
        } else {
            var selectedIndex = component.get("v.selectedSideTabIndex");
            component.set("v.customSectionList", sideTabList[selectedIndex].customSectionList);
        }*/
        component.set("v.pfDeptBtnList", helper.generateDefaultDepartmentButtonList());
    },
    
    handleAuditChange : function(component, event, helper) {
        event.stopPropagation();
        var audit = event.getParam("value");
        var sideTabList = component.get("v.sideTabList");
        helper.configureDepartmentSideTabs(component, audit, sideTabList);
    },
    
	onclickSideTab : function(component, event, helper) {
        var oldIndex = component.get("v.selectedSideTabIndex");
        var newIndex = event.currentTarget.value;
        if (!$A.util.isEmpty(newIndex)) {
            var sideTabList = component.get("v.sideTabList");
            sideTabList[oldIndex].selected = false;
            sideTabList[newIndex].selected = true;
            component.set("v.selectedSideTabIndex", newIndex); 
            if (sideTabList[newIndex].label === $A.get("$Label.c.EIS_Audit_Form_SideTab_Positive_Finding")) {
                component.set("v.positiveFinding", true);
                component.set("v.sideTabList", sideTabList);
            } else {
                if ($A.util.isEmpty(sideTabList[newIndex].customSectionList) || component.get("v.tabName") === $A.get("$Label.c.EIS_Audit_Form_Tab_Department")) {
                    helper.getSelectedSectionList(component, sideTabList, newIndex);
                } else {
                    component.set("v.sideTabList", sideTabList);
                    component.set("v.customSectionList", sideTabList[newIndex].customSectionList);
                }
                component.set("v.positiveFinding", false);
            }
            window.scrollTo(0, 0);
        }
	},
    
    onkeypressPositiveFinding : function(component, event, helper) {
        var keyPressed = "which" in event ? event.which : event.keyCode; //; - 59   Enter - 13
        if (keyPressed === 59) {
            event.preventDefault();  //Escaping the semicolon
        } 
    },
    
    onclickDeptResponsibility : function (component, event, helper) {
		var index = event.target.value;
        if (!$A.util.isEmpty(index)) {
        	var pfDeptBtnList = component.get("v.pfDeptBtnList");
            pfDeptBtnList[index].selected = !pfDeptBtnList[index].selected;
            component.set("v.pfDeptBtnList", pfDeptBtnList);
        }
    },    
    
    onclickSavePositiveFinding : function(component, event, helper) {
        event.preventDefault();
        var pfIndex = component.get("v.editPFIndex");
        var newPF = component.find("positive-finding-textarea");
        if (!$A.util.isEmpty(newPF) && !$A.util.isEmpty(newPF.getElement().value)) {
            newPF = newPF.getElement().value;
            var pfDeptBtnList = component.get("v.pfDeptBtnList");
            var selectedDepts = "";
            pfDeptBtnList.forEach(function(deptBtn) {
                selectedDepts += deptBtn.selected ? "1" : "0";
            });
            var params = { 
                "newPositiveFinding": newPF.replace(/;/g, ""), 
                "selectedDepartments": selectedDepts,
                "auditId": component.get("v.auditId") 
            };
            if (pfIndex < 0) {
                helper.updatePositiveFindingAction(component, "c.saveNewPositiveFinding", params);
            } else {
                params["pfIndex"] = JSON.stringify(pfIndex);
                helper.updatePositiveFindingAction(component, "c.editPositiveFinding", params);
            }
        }
    },
    
    onclickEditPositiveFinding : function(component, event, helper) {
        var index = event.currentTarget.dataset.pfindex;
        if (!$A.util.isEmpty(index)) {
        	component.set("v.editPFIndex", parseInt(index));
            var pfDeptBtnList = component.get("v.pfDeptBtnList");
            var selectedDeptList = component.get("v.positiveFindingDeptList")[index].split("");
            for (var i = 0; i < selectedDeptList.length; i++) {
                pfDeptBtnList[i].selected = selectedDeptList[i] === "0" ? false : true;
            }
            component.set("v.pfDeptBtnList", pfDeptBtnList);
            
            var pfList = component.get("v.positiveFindingList");
            component.find("positive-finding-textarea").getElement().value = pfList[index];
            component.find("positive-finding-textarea").getElement().focus();
        }
    },
    
    onclickDeletePositiveFinding : function(component, event, helper) {
        var index = event.currentTarget.dataset.pfindex;
        if (!$A.util.isEmpty(index)) {
            var selectedDepartments = component.get("v.positiveFindingDeptList")[index];
            var params = { 
                "deleteIndex": index + "",
                "selectedDepartments": selectedDepartments,
                "auditJSON": JSON.stringify(component.get("v.audit")) 
            };
            helper.updatePositiveFindingAction(component, "c.deletePositiveFinding", params);
        }
    },
    
    clearPositiveFinding : function(component, event, helper) {
        helper.clearPositiveFindingFields(component);
    },
    
    handleHeaderButtonClicked : function(component, event, helper) {
        helper.fireToggleSpinnerEvent(component, false);
        var methodParams = event.getParam("arguments"); 
        var params = {
            "auditId" : component.get("v.auditId"),
            "newSubmitStatus" : methodParams.newSubmitStatus,
            "rejectionNote" : methodParams.rejectionNote
        };
		var action = component.get("c.updateSubmitStatus");
        action.setParams({ "params" : params });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.updateSubmitStatus " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.missingQuestionList)) {
                    helper.fireToggleSpinnerEvent(component, true);
                    // Handle rendering of missing questions
                    var missingQuestionList = JSON.parse(returnValue.missingQuestionList);
                    component.set("v.missingQuestionList", missingQuestionList);
                    component.set("v.errorMessage", "");
                    window.scrollTo(0, 0);
                } else if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    helper.fireToggleSpinnerEvent(component, true);
                    // Handle rendering of server side exception message
                    component.set("v.missingQuestionList", []);
                	component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
            	} else {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.audit.Id"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                }
            } else {
                component.set("v.errorMessage", response.getError());
                helper.fireToggleSpinnerEvent(component, true);
            }
        });
		$A.enqueueAction(action);
    }
})