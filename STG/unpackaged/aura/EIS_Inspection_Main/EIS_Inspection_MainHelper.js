({
	initializeInspection : function(component) {
        this.handleToggleLightningSpinnerHelper(component, false);
		var action = component.get("c.initInspection");
        action.setParams({ "recordId" : component.get("v.recordId") });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.initInspection " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue(); 
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    var inspection = returnValue.inspection;
                    if (!$A.util.isEmpty(inspection)) {
                        component.set("v.inspection", JSON.parse(inspection));
                    }
                    if (!$A.util.isEmpty(returnValue.inspectionForm)) {
                        component.set("v.inspectionForm", JSON.parse(returnValue.inspectionForm));
                    }
                    if (!$A.util.isEmpty(returnValue.disableFindings)) {
                        component.set("v.disableFindings", JSON.parse(returnValue.disableFindings));
                    }
                    if (!$A.util.isEmpty(returnValue.disableCorrectiveActions)) {
                        component.set("v.disableCorrectiveActions", JSON.parse(returnValue.disableCorrectiveActions));
                    }
                    if (!$A.util.isEmpty(returnValue.disableHeaderButtons)) {
                        component.set("v.disableHeaderButtons", JSON.parse(returnValue.disableHeaderButtons));
                    }
                    component.set("v.errorMessage", "");
                } else {
                    component.set("v.errorMessage", returnValue.errorMsg);
                }
            } else {
                console.log(response.getError());
            }
            this.handleToggleLightningSpinnerHelper(component, true);
        });
		$A.enqueueAction(action);
	},
    
    submitInspectionForm : function(component, apexMethodName, params) {
        this.handleToggleLightningSpinnerHelper(component, false);
        var action = component.get(apexMethodName);
        action.setParams(params);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(apexMethodName + " " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if ($A.util.isEmpty(returnValue.errorMsg)) {
                    var inspection = returnValue.inspection;
                    if (!$A.util.isEmpty(inspection)) {
                        component.set("v.inspection", JSON.parse(inspection));
                    }
                    if(!$A.util.isEmpty(returnValue.disableFindings)) {
                        component.set("v.disableFindings", JSON.parse(returnValue.disableFindings));
                    }
                    if(!$A.util.isEmpty(returnValue.disableCorrectiveActions)) {
                        component.set("v.disableCorrectiveActions", JSON.parse(returnValue.disableCorrectiveActions));
                    }
                    if(!$A.util.isEmpty(returnValue.disableHeaderButtons)) {
                        component.set("v.disableHeaderButtons", JSON.parse(returnValue.disableHeaderButtons));
                    }
                    component.set("v.errorMessage", "");
                } else {
                    component.set("v.errorMessage", returnValue.errorMsg);
                }
                
            } else {
                component.set("v.errorMessage", response.getError());
            }
            this.handleToggleLightningSpinnerHelper(component, true);
        });
		$A.enqueueAction(action);
    },
        
    formHasEmptyDescription : function(component) {
        var inspectionStatus = component.get("v.inspection.PH_Report_Status__c");
        var hasEmptyDescription = [false];
        var sectionCmp = component.find("inspection-question-section");
        if (!$A.util.isEmpty(sectionCmp)) {
            for (var s = 0; s < sectionCmp.length; s++) {
                if (!$A.util.isEmpty(sectionCmp[s])) {
                    var displaySection = sectionCmp[s].get("v.displaySection");
                    if (!$A.util.isEmpty(displaySection) && !displaySection) {
                        sectionCmp[s].set("v.displaySection", true);
                    }
                    var questionCmp = sectionCmp[s].find("inspection-question");
                    if (!$A.util.isEmpty(questionCmp)) {
                        if (!$A.util.isEmpty(questionCmp.length)) {
                            for (var q = 0; q < questionCmp.length; q++) {
                                if (!$A.util.isEmpty(questionCmp[q].get("v.question_c.question.Id"))) {
                                    this.traverseFindingCmp(questionCmp[q], hasEmptyDescription, inspectionStatus);
                                }
                            }
                        } else {
                            if (!$A.util.isEmpty(questionCmp.get("v.question_c.question.Id"))) {
                                this.traverseFindingCmp(questionCmp, hasEmptyDescription, inspectionStatus);
                            }
                        }
                    }
                }
            }
        }
        
        return hasEmptyDescription[0];
    },
    
    traverseFindingCmp : function(questionCmp, hasEmptyDescription, inspectionStatus) {
        var displayFindings = questionCmp.get("v.displayFindings");
        if (!$A.util.isEmpty(displayFindings) && !displayFindings) {
            questionCmp.set("v.displayFindings", true);
        }
        var findingCmp = questionCmp.find("inspection-finding");
        if (!$A.util.isEmpty(findingCmp)) {
            if (!$A.util.isEmpty(findingCmp.length)) {
                for (var f = 0; f < findingCmp.length; f++) {
                    this.validateEmptyDescription(findingCmp[f], "v.finding_c.finding", "finding-description", hasEmptyDescription, false);
                    if (inspectionStatus == $A.get("$Label.c.EIS_Audit_Inspection_Report_Status_Conditional")) {
                    	this.traverseCorrectiveActionCmp(findingCmp[f], hasEmptyDescription);
                    }
                }
            } else {
                this.validateEmptyDescription(findingCmp, "v.finding_c.finding", "finding-description", hasEmptyDescription, true);
                if (inspectionStatus == $A.get("$Label.c.EIS_Audit_Inspection_Report_Status_Conditional")) {
                    this.traverseCorrectiveActionCmp(findingCmp, hasEmptyDescription);
                }
            }
        }
    },
    
    traverseCorrectiveActionCmp : function(findingCmp, hasEmptyDescription) {
        var caCmp = findingCmp.find("inspection-corrective-action");
        if (!$A.util.isEmpty(caCmp)) {
            if (!$A.util.isEmpty(caCmp.length)) {
                for (var c = 0; c < caCmp.length; c++) {
                    this.validateEmptyDescription(caCmp[c], "v.ca", "corrective-description", hasEmptyDescription, (caCmp.length === 1));
                }
            } else {
                this.validateEmptyDescription(caCmp, "v.ca", "corrective-description", hasEmptyDescription, true);
            }
        }
    },
    
    validateEmptyDescription : function(cmp, attributeName, className, hasEmptyDescription, isSingleCmp) {
        var record = cmp.get(attributeName);
        var textarea = cmp.find(className); 
        var errorMsg = cmp.find(className + "-error");
        if (!$A.util.isEmpty(record)) {
            if (!$A.util.isEmpty(record.Id)){
                if ($A.util.isEmpty(record.EIS_Description__c)) {
                    if (!$A.util.hasClass(textarea, "has-error")) {
                        $A.util.addClass(textarea, "has-error");
                    }
                    errorMsg.set("v.rendered", true);
                    if (!hasEmptyDescription[0]) { 
                        textarea.getElement().focus();
                        hasEmptyDescription[0] = true;
                    }
                } else {
                    $A.util.removeClass(textarea, "has-error");
                    errorMsg.set("v.rendered", false);
                }
                
                // Checking for empty Assigned To field on Corrective Action
                if (className === "corrective-description") {
                    var searchCmp = cmp.find("contact-typeahead");
                    var searchErrorCmp = cmp.find("contact-typeahead-error");
                    if (!$A.util.isEmpty(searchCmp)) {
                        var searchBox = searchCmp.find("search-box");
                        if ($A.util.isEmpty(record.EIS_Assigned_to__r) || $A.util.isEmpty(record.EIS_Assigned_to__r.Name)) {
                            if (!$A.util.hasClass(searchBox, "has-error")) {
                                $A.util.addClass(searchBox, "has-error");
                            }
                            searchErrorCmp.set("v.rendered", true);
                            if (!hasEmptyDescription[0]) { 
                                searchBox.getElement().focus();
                                hasEmptyDescription[0] = true;
                            }
                        } else {
                            $A.util.removeClass(searchBox, "has-error");
                            searchErrorCmp.set("v.rendered", false);
                        }
                    }
                }
            } else {
                if (isSingleCmp && className == "corrective-description" && !$A.util.isEmpty(record.EIS_Finding__c)) {
                    if (!$A.util.hasClass(textarea, "has-error")) {
                        $A.util.addClass(textarea, "has-error");
                    }
                    errorMsg.set("v.rendered", true);
                    if (!hasEmptyDescription[0]) { 
                        textarea.getElement().focus(); 
                        hasEmptyDescription[0] = true;
                    }
                }
            }
        }
    },
    
    handleToggleLightningSpinnerHelper : function(component, hideSpinner) {
        var spinner = component.find("audit-loading");
        if (hideSpinner) {
            if (!$A.util.hasClass(spinner, "slds-hide")) {
                 $A.util.addClass(spinner, "slds-hide");
            }
        } else {
            $A.util.removeClass(spinner, "slds-hide");
        }
    }
})