({
	onclickTestEntryButton : function(component, event, helper) {
        var oldIndex = component.get("v.currentEntryIndex");
        var oldEntry = component.get("v.testEntryWrapperList[" + oldIndex +"]");
        oldEntry.display = false;
        
		var index = event.currentTarget.dataset.entryIndex;
        var teWrapper = component.get("v.testEntryWrapperList[" + index + "]");
        teWrapper.display = true;
        
        component.set("v.testEntryWrapperList[" + index + "]", teWrapper);
        component.set("v.testEntryWrapperList[" + oldIndex + "]", oldEntry);
        component.set("v.currentEntryIndex", index);
        
        try {
            document.getElementById("slds-vertical-tabs-" + index + "__nav").blur(); 
        } catch (err) {
            console.log("Nothing to worry about");
        }
	},
    
    validateEvaluationDate : function(teWrapper, component, completed) {
        
        var evaluationDate = teWrapper[fieldName];	//return a string (yyyy-mm-dd) format
        console.log("inside validate func");
        //convert a string to date
        var evaluationDateSplit = evaluationDate.split("-");
        var year = parseInt(evaluationDateSplit[0]);
        var month = parseInt(evaluationDateSplit[1] - 1);
        var date = parseInt(evaluationDateSplit[2]);
        var dateVal = new Date(year, month, date);
        
        var currentDate = new Date();
        console.log("*** currentDate : " + currentDate);
        console.log("*** dateVal : " + dateVal);
        if(teWrapper["PersonallyObserved__c"] == "Yes"){
            var date10DayOld = new Date();
            date10DayOld.setDate(date10DayOld.getDate() - 11);	// use 11 to skip counting of today
            
            if(dateVal < date10DayOld){
                component.set("v.errors",  [{message:"Evaluation Date should not be greater than 10 calendar days."}]);
                completed = false;
            }else if(dateVal > currentDate){
                component.set("v.errors",  [{message:"Evaluation Date should not be future date."}]);
                completed = false;
            }else{
                component.set("v.errors",  null);
                completed = completed && !$A.util.isEmpty(teWrapper[fieldName]); 
            }
            
        } else if (teWrapper["PersonallyObserved__c"] == "No") {
            var date90DayOld = new Date();
            date90DayOld.setDate(date90DayOld.getDate() - 91);	//use 91 to skip counting of today
            
            if(dateVal < date90DayOld){
                component.set("v.errors",  [{message:"Evaluation Date should not be greater than 90 calendar days."}]);
                completed = false;
            } else if(dateVal > currentDate){
                component.set("v.errors",  [{message:"Evaluation Date should not be future date."}]);
                completed = false;
            } else {
                component.set("v.errors",  null);
                completed = completed && !$A.util.isEmpty(teWrapper[fieldName]); 
            }
        }
        
        return completed;
    },
    
    checkForTestCompletion : function(component, event, helper) {
        event.stopPropagation();
        var index = component.get("v.currentEntryIndex");
        var teWrapper = component.get("v.testEntryWrapperList[" + index + "]");
        
        console.log("teWrapper :: " + JSON.stringify(teWrapper));
        var completed = false;
        teWrapper.empList.forEach(function(empWrapper) {
            completed = completed || empWrapper.selected;
        });
        
        for (var fieldName in teWrapper.requiredFields) {
            if (teWrapper.requiredFields[fieldName]) {
                if(fieldName == "Date__c"){	
                    var fieldCmp = component.find(fieldName);
                    if (!$A.util.isEmpty(fieldCmp)) {
                        	var cmp = "";
                        	if (fieldCmp.length && fieldCmp.length > 0) {
                                fieldCmp.forEach(function(inputCmp) {
                                    cmp = inputCmp;
                                    completed = helper.validateEvaluationDate(teWrapper, fieldName, cmp, completed);
                                });
                            } else {
                                cmp = fieldCmp;
                                completed = helper.validateEvaluationDate(teWrapper, fieldName, cmp, completed);
                            }
                    }
                } else if(fieldName == "MpSgNumber__c") {
                    if (!$A.util.isEmpty(teWrapper["MpSg__c"]) && teWrapper["MpSg__c"] != "None") {
                        completed = completed && !$A.util.isEmpty(teWrapper[fieldName]);  
                    }
                } else if(fieldName == "Speed_Check_Method__c") {
                    if (!$A.util.isEmpty(teWrapper["Speed__c"]) && teWrapper["Speed__c"] != "") {
                        completed = completed && !$A.util.isEmpty(teWrapper[fieldName]);    
                    }
                } else {
                	completed = completed && !$A.util.isEmpty(teWrapper[fieldName]);    
                }
            } else if(fieldName == "MpSgNumber__c") {
                if (!$A.util.isEmpty(teWrapper["MpSg__c"]) && teWrapper["MpSg__c"] != "None") {
                    teWrapper.requiredFields.MpSgNumber__c = true;
                    completed = completed && !$A.util.isEmpty(teWrapper[fieldName]);
                }
            } else if(fieldName == "Speed_Check_Method__c") {
                if (!$A.util.isEmpty(teWrapper["Speed__c"]) && teWrapper["Speed__c"] != "") {
                    if(teWrapper.speedCheckMethodList.length > 0){
                    	teWrapper.requiredFields.Speed_Check_Method__c = true;    
                    	completed = completed && !$A.util.isEmpty(teWrapper[fieldName]);
                    }
                }
            }
        }
        component.set("v.testEntryWrapperList[" + index + "].completed", completed);
    },
    
    onchangeResult : function(component, event, helper) {
        event.stopPropagation();
        var index = component.get("v.currentEntryIndex");
        var teWrapper = component.get("v.testEntryWrapperList[" + index + "]");
        console.log("teWrapper :: " + JSON.stringify(teWrapper));
        teWrapper.requiredFields.Comments__c = (teWrapper.Result__c != "C = Compliance");
        teWrapper.requiredFields.SupervisorsCommentSelection__c = (teWrapper.Result__c != "C = Compliance");
        teWrapper.requiredFields.NonComplianceRuleNumber__c = (teWrapper.Result__c != "C = Compliance");
        
        var completed = false;
        teWrapper.empList.forEach(function(empWrapper) {
            completed = completed || empWrapper.selected;
        });
        
        for (var fieldName in teWrapper.requiredFields) {
            if (teWrapper.requiredFields[fieldName]) {
                completed = completed && !$A.util.isEmpty(teWrapper[fieldName]);
            }
        }
        teWrapper.completed = completed;
        component.set("v.testEntryWrapperList[" + index + "]", teWrapper);
    }
    
    
})