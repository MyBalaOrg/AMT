({
    openForceRecordEdit : function(component, event, helper) {
        event.stopPropagation();
        component.set("v.openEditModal", true);
        var dataset = event.target.dataset;
        var editCmp = component.find("force-record-edit");
        if (!$A.util.isEmpty(dataset) && !$A.util.isEmpty(editCmp)) {
            editCmp.set("v.recordId", dataset.recordId);
            if ($A.util.isEmpty(dataset.testNumber)) {
                editCmp.set("v.modalTitle", "Edit Test");
            } else {
                editCmp.set("v.modalTitle", "Edit Test " + dataset.testNumber);
            }
        } else {
            component.set("v.openEditModal", false);
        }
    },
    
    toggleResultDisplay : function(component, event, helper) {
        event.stopPropagation();
        var index = event.currentTarget.dataset.wrapperIndex;
        var trWrapper = component.get("v.trWrapperList[" + index +"]");
        trWrapper.display = !trWrapper.display;
        component.set("v.trWrapperList[" + index +"]", trWrapper);
        
        console.log(trWrapper.employeeName + " DISPLAY: " + trWrapper.display);
    },
    
    onclickToggleAllTables : function(component, event, helper) {
        var display = $A.util.isEmpty(event.target.value);
        var trWrapperList = component.get("v.trWrapperList");
        trWrapperList.forEach(function(trWrapper) {
            trWrapper.display = display;
        });
        component.set("v.trWrapperList", trWrapperList);
    },
    
    openEditFinndingModal : function(component, event, helper) {
        event.stopPropagation();
        var index = event.currentTarget.dataset.wrapperIndex;
        var trWrapperList = component.get("v.trWrapperList");
        console.log(index);
        if (!$A.util.isEmpty(index)) {
            component.set("v.testQuestionList", trWrapperList[index].findingList);
            component.set("v.needImprovement", trWrapperList[index].testResults[0].NeedsImprovement__c);
            component.set("v.needImprovementRequired", !$A.util.isEmpty(trWrapperList[index].testResults[0].NeedsImprovement__c));
            component.set("v.openEditFindingModal", true);
            component.set("v.selectedResultIndex", index);
        }
    },
    
    cancelEditFindings : function(component, event, helper) {
        component.set("v.openEditFindingModal", false);
    },
    
    saveEditFindings : function(component, event, helper) {
        var proceed = true;
        var needImprovementValue = component.find("NeedsImprovement__c");
        var commentsValue = component.find("Comments__c");

        if ($A.util.isEmpty(component.get("v.needImprovement")) && component.get("v.needImprovementRequired")) {
            proceed = false;
            needImprovementValue.set("v.errors", true);
        } else {
            needImprovementValue.set("v.errors", null);
        }

        if ($A.util.isEmpty(component.get("v.comments")) && component.get("v.commentsRequired")) {
            proceed = false;
            commentsValue.set("v.errors", true);
        } else {
            commentsValue.set("v.errors", null);
        }

        if (proceed) {
            var trWrapperList = component.get("v.trWrapperList");
            var index = component.get("v.selectedResultIndex");
            trWrapperList[index].testResults[0].NeedsImprovement__c = component.get("v.needImprovement");
            trWrapperList[index].testResults[0].Comments__c = component.get("v.comments");
            
            var params = {
                "findingListJSON" : JSON.stringify(component.get("v.testQuestionList")),
                "obsId" : trWrapperList[index].testResults[0].Id,
                "needImprovement" : component.get("v.needImprovement"),
                "comments" : component.get("v.comments")
            }
            
            amtrak.toggleLightningSpinner(component.find("fidget-spinner"), false);
            var action = component.get("c.saveEditedTestQuestions");
            action.setParams({ "params" : params });
    		action.setCallback(this, function(response) {
                var state = response.getState();
                console.log("c.saveEditedTestQuestions " + state);
                if (state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    if (!$A.util.isEmpty(returnValue.errorMsg)) {
                        console.log(returnValue.errorMsg);
                        console.log(returnValue.consolelog);
                        amtrak.fireErrorToastEvent(component, "", returnValue.errorMsg);
                    } else {
                        if (!$A.util.isEmpty(returnValue.trWrapperList)) {
                        	component.set("v.trWrapperList", JSON.parse(returnValue.trWrapperList));
                        } else {
                            component.set("v.trWrapperList", trWrapperList);
                        }
                    }
                } else {
                    console.log(response.getError());
                }
                
                amtrak.toggleLightningSpinner(component.find("fidget-spinner"), true);
                component.set("v.openEditFindingModal", false);
            });
    		$A.enqueueAction(action);
        }
    }
})