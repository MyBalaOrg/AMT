({
    handleInspectionChange : function(component, event, helper) {
        var inspection = component.get("v.inspection");
        var report = inspection.PH_Report_Status__c;
        var corrective = inspection.PH_Corrective_Action_Status__c;
        
        component.set("v.reportClassName", (report == $A.get("$Label.c.EIS_Audit_Inspection_Report_Status_Conditional")) ? "red-text" : "green-text");
        if (corrective == $A.get("$Label.c.EIS_Audit_Inspection_Corrective_Status_Not_Started")) {
            component.set("v.correctiveClassName", "red-text");
        } else if (corrective == $A.get("$Label.c.EIS_Audit_Inspection_Corrective_Status_In_Progress")) {
            component.set("v.correctiveClassName", "orange-text");
        } else {
            component.set("v.correctiveClassName", "green-text");
        }
        
        var barColor = "";
        var barMessage = "";
        
        var deadline = new Date();
        deadline.setDate(deadline.getDate() + 9);
        if (!$A.util.isEmpty(inspection.EIS_Correction_Deadline__c)) {
            deadline = new Date(inspection.EIS_Correction_Deadline__c);
        }
        var deadlineString = deadline.toDateString();
        
        if (inspection.EIS_Count_Not_Corrected_CA__c == 0 && inspection.EIS_Count_Corrected_CA__c > 0) {
            barColor = "green-bg";
            barMessage = inspection.EIS_Count_Corrected_CA__c + " " + $A.get("$Label.c.EIS_Form_Bar_Msg_CA_Taken");
        } else {
            if (inspection.EIS_Count_Critical_Not_Corrected_CA__c > 0) {
                barColor = "red-bg";
                barMessage = inspection.EIS_Count_Not_Corrected_CA__c + " " + $A.get("$Label.c.EIS_Form_Bar_Msg_CA_Deadline") + " " + deadlineString.substring(3);
            } else {
                barColor = "orange-bg";
                if (report == $A.get("$Label.c.EIS_Audit_Inspection_Report_Status_Satisfactory")) {
                    barMessage = $A.get("$Label.c.EIS_Form_Bar_Msg_No_CA_Required");
                } else {
                    barMessage = inspection.EIS_Count_Not_Corrected_CA__c + " " + $A.get("$Label.c.EIS_Form_Bar_Msg_CA_Deadline") + " " + deadlineString.substring(3);
                }
            }
        }
        
        component.set("v.barColor", barColor);
        component.set("v.barMessage", barMessage);
    },
    
    onclickHeaderButton : function(component, event, helper) {
        
        var buttonName = event.target.value;
        if (buttonName == $A.get("$Label.c.EIS_Audit_Inspection_Submit_Status_Reject")) {
            component.set("v.openReasonForRejection", true);
        } 
        else {	
            	helper.content(component,buttonName,event);
        }        
        }, 
            
            fireHeaderButtonClickedEvents : function(component, event, helper) {
                var buttonName = component.get("v.confirmationModalLabels.buttonName");
                helper.fireButtonClickedEvent(component, buttonName, "");
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
                            
                            toggleInspectionInactivity : function(component, event, helper) {
                                helper.fireButtonClickedEvent(component, 'Inactivity', "");
                            },
    
 
    })