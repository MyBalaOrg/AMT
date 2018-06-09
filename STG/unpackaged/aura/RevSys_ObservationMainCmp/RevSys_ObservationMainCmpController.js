({
    scriptsLoaded : function(component, event, helper) {
        debugger;
        amtrak.scriptLoadedCheck();
        helper.doInit(component);
    },
    
    handleToggleLightningSpinner : function(component, event, helper) {
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), paramMap.hideSpinner);
    },

    handleNext : function(component, event, helper) {
        
        var BreakException = {};

        var selectionState = component.get("v.selectionState");
        var recordType = component.get("v.selectedRecordType");
        var fieldLabelMap = component.get("v.fieldLabelMap");
        var recordTypeToDisplayTestNumbers = component.get("v.recordTypeToDisplayTestNumbers");
        var non1872Cmp = component.find("non-1872-form");        
        var validationMap = {};
        console.log("recordTypeToDisplayTestNumbers :: " + recordTypeToDisplayTestNumbers);
        console.log("selectionState BEFORE :::: " + selectionState);
        //debugger;
        helper.populateScoreDefinitions(component);
        
        if (recordType.Id != recordTypeToDisplayTestNumbers) {
            validationMap = helper.validatePage(component, selectionState);
            if (selectionState === 2) {
                var needImpCmp = non1872Cmp.find("NeedsImprovement__c");
                var commentsCmp = non1872Cmp.find("Comments__c");
                console.log("needImpCmp: " + needImpCmp);
                if (needImpCmp != "undefined" && needImpCmp != null) {
                    needImpCmp.set("v.errors", null); 
                }
                if (commentsCmp != "undefined" && commentsCmp != null) {
                    commentsCmp.set("v.errors", null); 
                }
            }
        }          
    
        if ($A.util.isEmpty(validationMap) || validationMap.proceed){
            selectionState++;
            console.log("selectionState AFTER :: " + selectionState);
            if (selectionState === 2 && recordType.Id != recordTypeToDisplayTestNumbers) {
                helper.createNon1872(component);
                component.set("v.nextButtonLabel", "Submit");
            } else if (selectionState === 2 && recordType.Id == recordTypeToDisplayTestNumbers){
                helper.loadTestSelection(component);
            } else if (selectionState === 3 && recordType.Id != recordTypeToDisplayTestNumbers){ //&& recordType.Id == recordTypeToDisplayTestNumbers
                helper.updateNon1872(component);
            } else if(selectionState === 3 && recordType.Id == recordTypeToDisplayTestNumbers){
                amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
                var selectTestTreeCmp = component.find("select-test-tree");
                var testWithObservationsList = selectTestTreeCmp.get("v.testWithObservationsList");
                var provideError = true;
                try {
                    if (!$A.util.isEmpty(testWithObservationsList)) {
                        testWithObservationsList.forEach(function(testWithObs){
                            if(testWithObs.selected){
                                provideError = false;
                                throw BreakException;
                            }
                        });
                    }
                }catch (e) {
                    if (e !== BreakException) throw e;
                }
                if(!provideError){
                    component.set("v.nextButtonLabel", "Submit");
                    component.set("v.disableNextButton", true);
                    helper.loadTestResultSection(component);    
                }else{
                    selectionState--;
                    amtrak.fireErrorToastEvent(component, "", "Please select atleast one test number.");
                    amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
                } 
            }  else if(selectionState === 4 && recordType.Id == recordTypeToDisplayTestNumbers){
            //    component.set("v.disableNextButton", false);
                helper.create1872(component);
            }
            component.set("v.selectionState", selectionState);
        } 
        else
        {    
            var needsImprovement = fieldLabelMap['NeedsImprovement__c'];
            var comments = fieldLabelMap['Comments__c'];
            if (validationMap.message != null){
                if (validationMap.message.indexOf(needsImprovement) > -1) {
                    needImpCmp.set("v.errors", true); 
                }
                if (validationMap.message.indexOf(comments) > -1) {
                    commentsCmp.set("v.errors", true); 
                }    
            }
            if (validationMap.message != null && !$A.util.isEmpty(validationMap.message)) {
                amtrak.fireErrorToastEvent(component, "Incomplete Form!", validationMap.message);
            }
            if (validationMap.scoreErrMsg != null && !$A.util.isEmpty(validationMap.scoreErrMsg)) {
                amtrak.fireErrorToastEvent(component, "Incomplete Score!", validationMap.scoreErrMsg);
            }
        }        
    },

    handlePrevious : function(component, event, helper) {
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
        var recordType = component.get("v.selectedRecordType");
        var recordTypeToDisplayTestNumbers = component.get("v.recordTypeToDisplayTestNumbers");
        var selectionState = component.get("v.selectionState");
        selectionState--;
        component.set("v.selectionState", selectionState);
        if (selectionState === 2 && recordType.Id == recordTypeToDisplayTestNumbers){
            component.set("v.nextButtonLabel", "Next");
            component.set("v.disableNextButton", false);
        }
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
    },

    handleSelectRecordType : function(component, event, helper) {
        //debugger;
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        var selectedRecordType = paramMap.selectedRecordType;
        var rtName = selectedRecordType.Name;
        var rtId   = selectedRecordType.Id;
        console.log("=====> rtName: " + rtName);
        console.log("=====> rtId: " + rtId);
        component.set("v.selectedEmpList", []);
        component.set("v.selectedEmpIdSet", "");
        
        if(rtName == "Form-1872"){
        	var picklistMap = component.get("v.picklistMap");
            var picklistMapFormTypeDivision = component.get("v.picklistMapFormTypeDivision");
            picklistMap.RegionProperty__c = picklistMapFormTypeDivision["Form-1872"];
            component.set("v.picklistMap", picklistMap);
        }
        
        helper.setNon1872Values(component, rtName, rtId, selectedRecordType);
    },
    
    handleEnableNextButton : function(component, event, helper) {
        var paramMap = event.getParam("paramMap");
        //var selectedEmpList = paramMap.disableNextButton;
        component.set("v.disableNextButton", paramMap.disableNextButton);
    },
    
    navigateToResSumRecord : function(component, event, helper) {
        var idx = event.target.getAttribute('data-index');
        var resEmpSumm = component.get("v.resEmpSummList")[idx];
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                  recordId: resEmpSumm.Id,
                  slideDevName: "detail"
            });
            navEvent.fire(); 
        }
        /*else{
            window.location.href = '/one/one.app#/sObject/'+resEmpSumm.Id+'/view'
        }*/
    }
    
/*
    handlePerformSearch : function(component, event, helper) {
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        var params = { 
            "searchKey" : paramMap.searchKey,
            "filterMap" : JSON.stringify(component.get("v.filterMap")),
        };
        helper.performSearch(component, params);
    },
*/
    
})