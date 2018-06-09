({
    doInit: function(component, event, helper) {
    	var action = component.get("c.getAuditInfo");
        action.setParams({"auditId": component.get("v.audit").Id});
        
        action.setCallback(this, function(response) {
      		var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                var resp = response.getReturnValue(); 
                var auditInfo = JSON.parse(resp)[0];
                if(auditInfo.EIS_Department_Weight_Transportation__c == '0' || typeof auditInfo.EIS_Department_Weight_Transportation__c == 'undefined') {
                    component.set("v.enableTransportation", false);
                }
                if(auditInfo.EIS_Department_Weight_Mechanical__c == '0' || typeof auditInfo.EIS_Department_Weight_Mechanical__c === 'undefined') {
                    component.set("v.enableMechanical", false);
                }
                if(auditInfo.EIS_Department_Weight_Material__c == '0' || typeof auditInfo.EIS_Department_Weight_Material__c == 'undefined') {
                    component.set("v.enableMaterial", false);
                }
                if(auditInfo.EIS_Department_Weight_Engineering__c == '0' || typeof auditInfo.EIS_Department_Weight_Engineering__c == 'undefined') {
                    component.set("v.enableEngineering", false);
                }
                if(auditInfo.EIS_Department_Weight_Environment__c == '0' || typeof auditInfo.EIS_Department_Weight_Environment__c == 'undefined') {
                    component.set("v.enableEnvironment", false);
                }
                console.log(component.get("v.enableEnvironment"));
            }
        });
        $A.enqueueAction(action); 
    },
    onclickDeptResponsibility : function(component, event, helper) {
    	var index = event.target.value;
        if (!$A.util.isEmpty(index)) {
            var deptRes = component.get("v.customObservation.customDeptList");
            deptRes[index].selected = !deptRes[index].selected;
            component.set("v.customObservation.customDeptList", deptRes);
            var selectedDepts = "";
            for (var i = 0; i < deptRes.length; i++) {
                if (deptRes[i].selected) {
                    selectedDepts += deptRes[i].label + ";";
                }
            }
            component.set("v.customObservation.finding.EIS_Responsible_Department__c", selectedDepts);
            var params = helper.getParams(component);
            params["clickedDepartment"] = deptRes[index].label;
            helper.updateObservationAction(component, params, "c.updateFinding");
        }
    },
    
    updateObservationFields : function(component, event, helper) {
        var fieldName = event.target.dataset.fieldName;
        if (!$A.util.isEmpty(fieldName)) {
            var newValue = event.target.value;
            var oldValue = component.get(fieldName);
            if (oldValue != newValue && (!$A.util.isEmpty(newValue) || !$A.util.isEmpty(oldValue))) {
                component.set(fieldName, newValue);
                var params = helper.getParams(component);
            	helper.updateObservationAction(component, params, "c.updateFinding");
            }
            var auraId = event.target.dataset.auraId;
            if (!$A.util.isEmpty(auraId) && !$A.util.isEmpty(newValue)) {
                helper.setErrorMessage(component, auraId, false);
            }
        }
    },
    
    toggleRepeatFinding : function(component, event, helper) {
        var params = helper.getParams(component);
        params["clickedRepeatFinding"] = "true";
        helper.updateObservationAction(component, params, "c.updateFinding");
    },
    
    onclickDeleteObservation : function(component, event, helper) {
        if (!$A.util.isEmpty(component.get("v.customObservation.finding.Id"))) {
            helper.updateObservationAction(component, helper.getParams(component), "c.deleteFinding");
        }
    },
    
	addCorrectiveAction : function(component, event, helper) {
		var caList = component.get("v.customObservation.caList");
        caList.push(helper.newCorrectiveAction(caList[0]));
        component.set("v.customObservation.caList", caList);
	},
    
    handleMissingFindingEvent : function(component, event, helper) {
        event.stopPropagation();
        helper.setErrorMessage(component, "observation-description", true);
    },
    
    handleDeleteCorrectiveAction : function(component, event, helper) {
        event.stopPropagation();
        var index = event.getParam("index");
        var caList = component.get("v.customObservation.caList");
        if (!$A.util.isEmpty(caList)) {
            if (caList.length > 1) {
            	caList.splice(index, 1);
            } else {
                caList = [helper.newCorrectiveAction(caList[0])];
            }
            component.set("v.customObservation.caList", caList);
        }
    }
})