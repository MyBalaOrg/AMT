({
    init : function(component, event, helper) {
        helper.createForm(component);
    },

    handleFetchSearchItemsEvent : function(component, event, helper) {
        event.stopPropagation();
        var auraId = event.getParam("auraId");
        var objectName;
        var fieldsToSearchList = [];
        
        if (auraId === "OperatedFromCode__c" || auraId === "OperatedToCode__c") {
        	objectName = "Station__c";
            fieldsToSearchList.push("Name");
            fieldsToSearchList.push("City__c");
            fieldsToSearchList.push("Code__c");
            fieldsToSearchList.push("State__c");
        }
        else if (auraId === "Train__c") {
        	objectName = "Train__c";
            fieldsToSearchList.push("Name");
        }
        else if (auraId === "Nearest_Station_Interlocking__c") {
        	objectName = "Station__c";
            fieldsToSearchList.push("Name");
        }
        var action = component.get("c.getItemsForTypeaheadSearch");
        action.setParams({ 
            "searchKey" : event.getParam("origin"),
            "objectName" : objectName,
            "fieldsToSearchList" : JSON.stringify(fieldsToSearchList)
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("c.getItemsForTypeaheadSearch " + state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                var typeaheadCmp = component.find(auraId);
                if (!$A.util.isEmpty(returnValue)) {
                    var listItems = JSON.parse(returnValue.listItems);
                    if (!$A.util.isEmpty(typeaheadCmp)) {
                        if (typeaheadCmp.length && typeaheadCmp.length > 0) {
                            typeaheadCmp.forEach(function(typeahead) {
                                if (index == typeahead.get("v.internalId")) {
                                    typeahead.set("v.isExpanded", true);
                                    typeahead.set("v.resultItems", listItems);
                                    typeahead.set("v.listItems", listItems);
                                }
                            });
                        } else {
                            typeaheadCmp.set("v.isExpanded", true);
                            typeaheadCmp.set("v.resultItems", listItems);
                            typeaheadCmp.set("v.listItems", listItems);
                        }
                    }
                }
            } else {
                component.set("v.errorMessage", response.getError());
            }
        });
		$A.enqueueAction(action);
    },

    handleSearchItemSelectedEvent : function(component, event, helper) {
        event.stopPropagation();
        var auraId = event.getParam("auraId");
        var selectedItem = event.getParam("selectedItem");
        if (!$A.util.isEmpty(selectedItem)) {
            if (auraId === "OperatedFromCode__c") {
                component.set("v.observation.OperatedFromCode__c", selectedItem.recordId);
                component.set("v.observation.OperatedFromCode__r.Name", selectedItem.label);
            }
            if (auraId === "OperatedToCode__c") {
                component.set("v.observation.OperatedToCode__c", selectedItem.recordId);
                component.set("v.observation.OperatedToCode__r.Name", selectedItem.label);
            }
            if (auraId === "Train__c") {
                component.set("v.observation.Train__c", selectedItem.recordId);
                component.set("v.observation.Train__r.Name", selectedItem.label);
            }
            if (auraId === "Nearest_Station_Interlocking__c") {
                component.set("v.observation.Nearest_Station_Interlocking__c", selectedItem.recordId);
                component.set("v.observation.Nearest_Station_Interlocking__r.Name", selectedItem.label);
            }
        }
        else {
            if (auraId === "OperatedFromCode__c") {
                component.set("v.observation.OperatedFromCode__c", "");
            }
            if (auraId === "OperatedToCode__c") {
                component.set("v.observation.OperatedToCode__c", "");
            }
            if (auraId === "Train__c") {
                component.set("v.observation.Train__c", "");
            }  
            if (auraId === "Nearest_Station_Interlocking__c") {
                component.set("v.observation.Nearest_Station_Interlocking__c", "");
            }  
        }
        component.set("v.observation", component.get("v.observation"));
    },

    handleValidation : function(component, event, helper) {
        console.log("in handlevalidation testInfo")
        event.stopPropagation();
        
        var proceed = true;
        var message = "Please Enter Required Fields ";
        var validationMap = {};

        var fields = component.get("v.editableFields");
        var rfMap = component.get("v.requiredFieldMap");
        var observation = component.get("v.observation");
        var fieldLabelMap = component.get("v.fieldLabelMap");
        var oneIsRequiredMap = component.get("v.oneIsRequiredMap");
        var referenceFields = component.get("v.referenceFields");
        var isTargetAdmin = component.get("v.isTargetAdmin");
        var oneIsRequired = [];
        var errorFields = [];

        for (var key in oneIsRequiredMap) {
            var value = oneIsRequiredMap[key];
            oneIsRequired.push(value);
        }

        for (var fieldName in rfMap) {
            var fieldCmp = component.find(fieldName);
            var hasError = null;
            var dateError = null;
            console.log(" ### observation - " + fieldName + " : " + observation[fieldName]);
            if ($A.util.isEmpty(observation[fieldName]) || (observation[fieldName] == "")) {             
                if (oneIsRequired.indexOf(fieldName) >= 0) {
                    var requiredPair = oneIsRequiredMap[fieldName];
                    if (requiredPair != "undefined" && requiredPair.length > 0) {
                        if ($A.util.isEmpty(observation[requiredPair]) || (observation[requiredPair] == "")) {
                            proceed = false;
                            hasError = true;
                            message += " ";                            
                        }
                    }                    
                } 
                else {
                    if(fieldName !== "Comments__c"){
                    	errorFields.push(fieldLabelMap[fieldName]);
                        proceed = false;
                        hasError = true;    
                    }
                }
                
            }else{
                if(fieldName == "Date__c"){
                    //proceed = proceed && !$A.util.isEmpty(observation[fieldName]); 
                    if (!$A.util.isEmpty(fieldCmp) && !isTargetAdmin) {
                        dateError = helper.validateEvaluationDate(observation, fieldName, fieldCmp, proceed, dateError);
                        if(dateError != null){
                            proceed = false;
                            hasError = true;
                            console.log("*** proceed AFTER : " + proceed);
                            console.log("*** hasError AFTER : " + hasError);
                        }
                        console.log("*** dateError : " + dateError);
                    }
                }
            }
            if (!$A.util.isEmpty(fieldCmp)) {
                if (oneIsRequired.indexOf(fieldName) < 0 && referenceFields.indexOf(fieldName) < 0) {
                    fieldCmp.set("v.errors", hasError);
                }
                else if (referenceFields.indexOf(fieldName) < 0) {
                    var requiredPair = oneIsRequiredMap[fieldName];
                    if (hasError === true) {
                        var labelOne = fieldLabelMap[fieldName];
                        var labelTwo = fieldLabelMap[requiredPair];
                        fieldCmp.set("v.errors",  [{message:"You must enter either " + labelOne + " or " + labelTwo + "."}]);
                    }
                    else {
                        fieldCmp.set("v.errors", null);
                    }
                } 
                if (referenceFields.indexOf(fieldName) >= 0) {
                    fieldCmp.set("v.hasError", hasError);
                }
                if(fieldName == "Date__c" && dateError != null && hasError){
                    console.log("inside IF ");
                    //fieldCmp.set("v.errors", hasError);
                    fieldCmp.set("v.errors", [{message:dateError.toString()}]);
                }
            }
        }
        
        if(component.get("v.observation.ObservationMethod__c") === "Meeting"){
            var fieldCmp = component.find("ObservationMethod__c");
            if($A.util.isEmpty(component.get("v.observation.Comments__c"))){
                component.set("v.commentRequired", true);
                //fieldCmp.set("v.errors",  [{message:"Please enter comments."}]);
                proceed = false;
            }
        }

        if (component.get("v.needImprovementRequired") && $A.util.isEmpty(component.get("v.observation.NeedsImprovement__c"))) {
            errorFields.push(fieldLabelMap['NeedsImprovement__c']);
            proceed = false;
        }
        
        if (component.get("v.commentRequired") && $A.util.isEmpty(component.get("v.observation.Comments__c"))) {
            errorFields.push(fieldLabelMap['Comments__c']);
            proceed = false;
        }

        if (proceed === false) {
            message = errorFields.join(", ");
        }else{
            message = "";
        }
        validationMap.proceed = proceed;
        validationMap.message = message;
        console.log("testInforCmp validationMap.proceed: " + validationMap.proceed);
        console.log("testInforCmp validationMap.message: " + validationMap.message);
        return validationMap;
    },
    
    handleValidationTest: function(component, event, helper) {
        console.log("inside validation test");
        return "This is validation test";
    },
    
    handleChangeMethod: function(component, event, helper) {
        var requiredFieldMap = component.get("v.requiredFieldMap");
        var commentRequired = false;
        var trainDescReq = false;
        
        if(component.get("v.observation.ObservationMethod__c") == "Meeting"){
        	component.set("v.commentRequired", !commentRequired);
        } else if(component.get("v.observation.ObservationMethod__c") == "Actual Ride"){
            component.set("v.commentRequired", commentRequired);
            trainDescReq = true;
            //requiredFieldMap.TrainDescription__c = true;
        } else {
            component.set("v.commentRequired", commentRequired);
            //requiredFieldMap.TrainDescription__c = false;
            trainDescReq = false;
        }
        
        requiredFieldMap.TrainDescription__c = trainDescReq;
        component.set("v.requiredFieldMap", requiredFieldMap);
        var trainDescCmp = component.find("TrainDescription__c");
        if(!$A.util.isEmpty(trainDescCmp)){
            trainDescCmp.set("v.required", trainDescReq);
        }
        
    },
    
    handleChangeMovementOffice: function(component, event, helper) {
        
        var picklistMapMovementPosting = component.get("v.picklistMapMovementPosting");
        var selectedMovementOffice = component.get("v.observation.MovementOffice__c");
        
        if (!$A.util.isEmpty(selectedMovementOffice) && !$A.util.isEmpty(picklistMapMovementPosting)) {
        	var postingLocations = picklistMapMovementPosting[selectedMovementOffice];
            var sectionTowerCmp = component.find("SectionTower__c");
            var options = [];
            options.push({ class: "optionClass", label: "Select Value", value: "" });
            if (!$A.util.isEmpty(postingLocations)) {
                for(var i=0; i< postingLocations.length; i++){
                    options.push({"class": "optionClass", label: postingLocations[i], value: postingLocations[i]});
                }
            }
            if (!$A.util.isEmpty(sectionTowerCmp) && options.length > 1) {
                sectionTowerCmp.set("v.options", options);
                sectionTowerCmp.set("v.disabled", false);
            }
        }
    },
    
    handleChangePostingOffice: function(component, event, helper) {
        var sectionTowerCmp = component.find("SectionTower__c");
        console.log("** sectionTowerCmp value : " + sectionTowerCmp.get("v.value"));
        component.set("v.observation.SectionTower__c", sectionTowerCmp.get("v.value"));
    }

})