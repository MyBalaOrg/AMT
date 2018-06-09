({
	doInit : function(component, event, helper) {
		helper.initializeInspection(component);
	},
    
    handleHeaderButtonClicked : function(component, event, helper) {
        event.stopPropagation();
        var params = {"recordId" : component.get("v.recordId")};
        if (event.getParam("origin") == $A.get("$Label.c.EIS_Audit_Inspection_Submit_Status_Submit") ) {
            var hasEmptyDescription = helper.formHasEmptyDescription(component);
            if (!hasEmptyDescription) {
                helper.submitInspectionForm(component, "c.submitInspectionForm", params);
            }
        } else if (event.getParam("origin") == $A.get("$Label.c.EIS_Audit_Inspection_Submit_Status_Approve")) {
            helper.submitInspectionForm(component, "c.approveInspectionForm", params);
        } else if (event.getParam("origin") == $A.get("$Label.c.EIS_Audit_Inspection_Submit_Status_Reject")) {
            params.reasonForRejection = event.getParam("description");
            helper.submitInspectionForm(component, "c.rejectInspectionForm", params);
        } else if (event.getParam("origin") === "Inactivity") {
            helper.submitInspectionForm(component, "c.toggleIsActive", params);
            var inspection = component.get("v.inspection");
            inspection.EIS_Is_Active__c = !inspection.EIS_Is_Active__c;
            component.set("v.inspection", inspection);
        }
    },
    
    handleToggleLightningSpinner : function(component, event, helper) {
        event.stopPropagation();
        helper.handleToggleLightningSpinnerHelper(component, event.getParam("value"));
    }
})