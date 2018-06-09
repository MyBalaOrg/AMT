({
    doInit : function(component, event, helper) {
    	var numOfColList = [
            {"value" : 8, "selected" : false},
            {"value" : 7, "selected" : false},
            {"value" : 6, "selected" : false},
            {"value" : 5, "selected" : false},
            {"value" : 4, "selected" : true },
            {"value" : 3, "selected" : false},
            {"value" : 2, "selected" : false},
            {"value" : 1, "selected" : false}
        ];    
        component.set("v.numOfColList", numOfColList);
    },
    
    changeNumberOfColumn : function(component, event, helper) {
        event.stopPropagation();
        var colNumber = event.currentTarget.value;
        if (!$A.util.isEmpty(colNumber)) {
            var numOfColList = component.get("v.numOfColList");
            numOfColList.forEach(function(col) {
                col.selected = (col.value == colNumber);
            });
            component.set("v.numOfCol", colNumber);
            component.set("v.numOfColList", numOfColList);
        }
    },
    
    setNeedImprovement : function(component, event, helper) {
        event.stopPropagation();
        var findingList = component.get("v.findingList");
        var needImprovementMap = component.get("v.needImprovementMap");
        console.log("needImprovementMap :: " + JSON.stringify(component.get("v.needImprovementMap")));
        var needImprovement = false;
        try {
            findingList.forEach(function(finding) {
                if (!$A.util.isEmpty(needImprovementMap[finding.Score__c + ""])) {
                    needImprovement = true;
                    throw BreakException;
                }
            });
        } catch (err) {
            
        }
        component.set("v.needImprovementRequired", needImprovement);
    },
    
    showScoreDefination : function(component, event, helper) {
        /*
        if(!component.get("v.popoverOpen")){
        	var popover = component.find("scoreDefination");
            $A.util.removeClass(popover,'slds-hide');
            
            component.set("v.popoverOpen", true);    
        }
        */
    },
    
   	hideScoreDefination : function(component, event, helper) {
        /*
        if(component.get("v.popoverOpen")){
        	var popover = component.find("scoreDefination");
            $A.util.addClass(popover,'slds-hide');
            
            component.set("v.popoverOpen", false);    
        }
        */
    },
    
    handleValidation : function(component, event, helper) {
        console.log("in handlevalidation testInfo")
        event.stopPropagation();
        
        var proceed = true;
        var message = "";
        
        
        var findingList = component.get("v.findingList");       
        var overallScore = 0;
        
        try {
            findingList.forEach(function(finding) {
                overallScore = overallScore+finding.Score__c;
            });
        }
        catch (err) {
            
        }
        
        if(overallScore==0 && component.get("v.obs.ObservationMethod__c") !== "Meeting"){
            proceed = false;
            message = "Atleast one test should have score value";
        }
        if (proceed === false) {
            message = message.replace(/,\s*$/, "");
            // amtrak.fireErrorToastEvent(component, "Incomplete Form!", message);
        }
        
        
        // amtrak.fireMapParamEvent(component, "proceedStep", params); 
        return message;
    }
    
})