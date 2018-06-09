({
    initializeCaseCreation : function(component) {
        this.toggleLightningSpinner(component, false);
		var action = component.get("c.initializeCaseCreationPage");
        action.setParams({ "recordTypeName" : component.get("v.recordTypeName") });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.initializeCaseCreationPage " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
                } else {
                    component.set("v.errorMessage", "");
                    this.setCaseInformationAfterCallBack(component, returnValue);
                }
            } else {
                component.set("v.errorMessage", response.getError());
            }
            this.toggleLightningSpinner(component, true);
        });
		$A.enqueueAction(action);
	},
    
	initializeCaseRecordPage : function(component) {
        this.toggleLightningSpinner(component, false);
		var action = component.get("c.initializeCaseRecord");
        action.setParams({ 
            "caseId" : component.get("v.recordId"),
            "recordTypeName" : component.get("v.recordTypeName")
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.initializeCaseRecord " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if (!$A.util.isEmpty(returnValue.errorMsg)) {
                    component.set("v.errorMessage", returnValue.errorMsg);
                    window.scrollTo(0, 0);
                } else {
                    component.set("v.errorMessage", "");
                    this.setCaseInformationAfterCallBack(component, returnValue);
                }
            } else {
                component.set("v.errorMessage", response.getError());
            }
            this.toggleLightningSpinner(component, true);
        });
		$A.enqueueAction(action);
	},
    
    setCaseInformationAfterCallBack : function(component, returnValue) {
        if (!$A.util.isEmpty(returnValue.sectionWrappers)) {
            component.set("v.sectionWrappers", JSON.parse(returnValue.sectionWrappers));
            //console.log(component.get("v.sectionWrappers"));
        }
        if (!$A.util.isEmpty(returnValue.sectionWrappersBottom)) {
            component.set("v.sectionWrappersBottom", JSON.parse(returnValue.sectionWrappersBottom));
            //console.log(component.get("v.sectionWrappersBottom"));
        }
        if (!$A.util.isEmpty(returnValue.tabsWrappers)) {
            component.set("v.tabsWrappers", JSON.parse(returnValue.tabsWrappers));
            //console.log(component.get("v.tabsWrappers"));
        }
        if (!$A.util.isEmpty(returnValue.tabList)) {
            component.set("v.tabList", JSON.parse(returnValue.tabList));
        }
        if (!$A.util.isEmpty(returnValue.selectedTab)) {
            component.set("v.selectedTab", returnValue.selectedTab);
        }
        if (!$A.util.isEmpty(returnValue.recordTypeId)) {
            component.set("v.recordTypeId", returnValue.recordTypeId);
        }
        if (!$A.util.isEmpty(returnValue.recordTypes)) {
            var recordTypes = JSON.parse(returnValue.recordTypes);
            component.set("v.recordTypes", recordTypes);
            if (!$A.util.isEmpty(returnValue.recordTypeName)) {
                component.set("v.recordTypeName", returnValue.recordTypeName);
            } else {
                component.set("v.recordTypeName", recordTypes[0]);
            }
        }
        if (!$A.util.isEmpty(returnValue.disableRecordType)) {
            component.set("v.disableRecordType", JSON.parse(returnValue.disableRecordType));
        }
    },
    
    getCaseRecordForUpdate : function(component) {
        var self = this;
        var caseRecord = { 'sobjectType' : 'Case' };
        if (!$A.util.isEmpty(component.get("v.recordId"))) {
            caseRecord.Id = component.get("v.recordId");
        } 
        if (!$A.util.isEmpty(component.get("v.recordTypeId"))) {
            caseRecord.RecordTypeId = component.get("v.recordTypeId");
        }
        var sectionWrappers = component.get("v.sectionWrappers");
        sectionWrappers.forEach(function(section) {
            section.caseWrappers.forEach(function(swrapper) {
                if ($A.util.isEmpty(caseRecord[swrapper.fieldName])) {
                    self.setValueToCaseRecordFields(caseRecord, swrapper);
                }
            });
        }); 
        
        var tabsWrappers = component.get("v.tabsWrappers");
        tabsWrappers.forEach(function(tabWrapper) {
            tabWrapper.caseWrappers.forEach(function(twrapper) {
                if ($A.util.isEmpty(caseRecord[twrapper.fieldName])) {
                    self.setValueToCaseRecordFields(caseRecord, twrapper);
                }
            });
        }); 
        
        var sectionWrappersBottom = component.get("v.sectionWrappersBottom");
        sectionWrappersBottom.forEach(function(section) {
            section.caseWrappers.forEach(function(sbwrapper) {
                if ($A.util.isEmpty(caseRecord[sbwrapper.fieldName])) {
                    self.setValueToCaseRecordFields(caseRecord, sbwrapper);
                }
            });
        }); 

        console.log(caseRecord);
        return caseRecord;
    },
    
    setValueToCaseRecordFields : function(caseRecord, wrapper) {
        //console.log(wrapper.fieldValue);
        if (!$A.util.isEmpty(wrapper.fieldValue)) {
            caseRecord[wrapper.fieldName] = wrapper.fieldValue;
        } else {
            if (wrapper.fieldValue == null) {
                caseRecord[wrapper.fieldName] = undefined;
            } else if (wrapper.fieldType == 'boolean') {
                caseRecord[wrapper.fieldName] = false;
            } else {
                if ($A.util.isEmpty(caseRecord.Id)) {
                    caseRecord[wrapper.fieldName] = undefined;
                } else {
                    caseRecord[wrapper.fieldName] = null;
                }
            }
        }
    },
    
    toggleLightningSpinner : function(component, hideSpinner) {
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