({
	handleAuditChange : function(component, event, helper) {
        event.stopPropagation();
        var barColor = "green-bg";
        var audit = component.get("v.audit");
        if (audit.EIS_Count_Open_Immediate_CA__c == 0 && audit.EIS_Count_Open_Long_Term_CA__c == 0) {
            barColor = "green-bg";
        } else if (audit.EIS_Count_Open_Immediate_CA__c > 0) {
            barColor = "red-bg";
        } else if (audit.EIS_Count_Open_Long_Term_CA__c > 0) {
            barColor = "orange-bg";
        }
        component.set("v.barColor", barColor);
        
        if (audit.PH_Submission_Status__c === $A.get("$Label.c.EIS_Audit_Inspection_Submit_Status_Approve")) {
            component.set("v.approvalStatusColor", "green-text");
        } else if (audit.PH_Submission_Status__c === $A.get("$Label.c.EIS_Audit_Inspection_Submit_Status_Reject")) {
            component.set("v.approvalStatusColor", "red-text");
        } else if (audit.PH_Submission_Status__c === $A.get("$Label.c.EIS_Audit_Inspection_Submit_Status_Submit")) {
            component.set("v.approvalStatusColor", "orange-text");
        } else {
            component.set("v.approvalStatusColor", "");
        }
	},
    
    onclickHeaderButton : function(component, event, helper) {
        var newSubmitStatus = event.target.value;
        if (newSubmitStatus === $A.get("$Label.c.EIS_Audit_Inspection_Submit_Status_Reject")) {
            component.set("v.openReasonForRejection", true);
        } else {
            var buttonName = event.target.innerHTML;
            var confirmationModalLabels = component.get("v.confirmationModalLabels");
            confirmationModalLabels.header = buttonName + " Confirmation";
            if (buttonName === $A.get("$Label.c.EIS_Form_Button_Submit_Obs")) {
                confirmationModalLabels.body = "Are you sure you want to submit observations for this " + component.get("v.audit.RecordType.Name") + "?";
            } else if (buttonName === $A.get("$Label.c.EIS_Form_Button_Submit_CA")) {
                confirmationModalLabels.body = "Are you sure you want to submit corrective actions for this " + component.get("v.audit.RecordType.Name") + "?";
            } else if (buttonName === $A.get("$Label.c.EIS_Form_Button_Final_Submit")) {
                confirmationModalLabels.body = "Are you sure you want to submit this " + component.get("v.audit.RecordType.Name") + " for final approval and closure?";
            } else {
                confirmationModalLabels.body = "Are you sure you want to approve this " + component.get("v.audit.RecordType.Name") + "?";
            }
            confirmationModalLabels.newSubmitStatus = newSubmitStatus;
            component.set("v.confirmationModalLabels", confirmationModalLabels);
            component.set("v.openClickConfirmation", true);
        }
    },
    
    fireHeaderButtonClickedEvents : function(component, event, helper) {
        var newSubmitStatus = component.get("v.confirmationModalLabels.newSubmitStatus");
        helper.fireButtonClickedEvent(component, newSubmitStatus, "");
        component.set("v.openClickConfirmation", false);
    },
    
    closeConfirmationModal : function(component, event, helper) {
        component.set("v.openClickConfirmation", false);
    },
    
    submitReasonForRejection : function(component, event, helper) {
        var textarea = component.find("reason-for-rejection");
        if (!$A.util.isEmpty(textarea) && $A.util.isEmpty(textarea.getElement().value)) {
            if (!$A.util.hasClass(textarea)) {
                $A.util.addClass(textarea, "has-error");
                textarea.getElement().focus();
            }
        } else {
            helper.fireButtonClickedEvent(component, $A.get("$Label.c.EIS_Audit_Inspection_Submit_Status_Reject"), textarea.getElement().value);
            component.set("v.openReasonForRejection", false);
        }
    },
    
    closeReasonForRejection : function(component, event, helper) {
        component.set("v.openReasonForRejection", false);
    },
    
    toggleAuditInactivity : function(component, event, helper) {
        if (component.get("v.userIsAPM")) {
            helper.fireButtonClickedEvent(component, "toggleAuditInactivity", "");
        }
    }
})