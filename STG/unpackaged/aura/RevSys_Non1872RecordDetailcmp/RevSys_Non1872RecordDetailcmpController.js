({
    scriptsLoaded : function(component, event, helper) {
        amtrak.scriptLoadedCheck();
        helper.doInit(component);
    },

    handleToggleLightningSpinner : function(component, event, helper) {
        event.stopPropagation();
        var paramMap = event.getParam("paramMap");
        amtrak.toggleLightningSpinner(component.find("fidget-spinner"), paramMap.hideSpinner);
    },

    validateForm : function(component, event, helper) {
        event.stopPropagation();
        var obsEditCmp = component.find("obsEditCmp");
        var testScoreCmp = component.find("testScore-cmp");
        var fieldLabelMap = component.get("v.fieldLabelMap");
        var needsImprovement = fieldLabelMap['NeedsImprovement__c'];
        var needImpCmp = component.find("NeedsImprovement__c");
        needImpCmp.set("v.errors", null); 

        var validationMap = obsEditCmp.validateInfo();
        var errorMessage = validationMap.message;
        var proceed = validationMap.proceed;
        var scoreErrMsg = testScoreCmp.validateScores();
        var finalError = errorMessage + scoreErrMsg;
        if (proceed === false || (finalError != null && !$A.util.isEmpty(finalError))) {
            if (errorMessage != null && !$A.util.isEmpty(errorMessage)) {
                if (errorMessage.indexOf(needsImprovement) > -1) {
                    console.log("====== found needsImproement");
                    needImpCmp.set("v.errors", true);                            
                }
                amtrak.fireErrorToastEvent(component, "Incomplete Form!", errorMessage);
            }
            if (scoreErrMsg != null && !$A.util.isEmpty(scoreErrMsg)) {
                amtrak.fireErrorToastEvent(component, "Incomplete Score!", scoreErrMsg);
            }
        }
        else  {
            helper.handleUpdate(component);        
        } 
    },

})