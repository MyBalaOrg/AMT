({
	/*
	* A map of component type, indexed by fieldType
	*
	*/
    configMap: {
        "anytype": { componentDef: "ui:inputText", attributes: {} },
        "base64": { componentDef: "ui:inputText", attributes: {} },
        "boolean": {componentDef: "ui:inputCheckbox", attributes: {} },
        "combobox": { componentDef: "ui:inputText", attributes: {} },
        "currency": { componentDef: "ui:inputText", attributes: {} },
        "datacategorygroupreference": { componentDef: "ui:inputText", attributes: {} },
        "date": {
            componentDef: "ui:inputDate",
            attributes: {
                displayDatePicker: true
            }
        },
        "datetime": {
            componentDef: "ui:inputDateTime",
            attributes: {
                displayDatePicker: true
            }
        },
        "double": { componentDef: "ui:inputNumber", attributes: {} },
        "email": { componentDef: "ui:inputEmail", attributes: {} },
        "encryptedstring": { componentDef: "ui:inputText", attributes: {} },
        "id": { componentDef: "ui:inputText", attributes: {} },
        "integer": { componentDef: "ui:inputNumber", attributes: {} },
        "multipicklist": { componentDef: "ui:inputText", attributes: {} },
        "percent": { componentDef: "ui:inputNumber", attributes: {} },
        "phone": { componentDef: "ui:inputPhone", attributes: {} },
        "picklist": { componentDef: "ui:inputSelect", attributes: {} },
        "reference": { componentDef: "c:EIS_TypeaheadSearch", attributes: {} },
        "string": { componentDef: "ui:inputText", attributes: {} },
        "textarea": { componentDef: "ui:inputText", attributes: {} },
        "time": { componentDef: "ui:inputDateTime", attributes: {} },
        "url": { componentDef: "ui:inputText", attributes: {} },
        "formula": { componentDef: "ui:outputText", attributes: {} }
    },

    createForm: function(component) {
		console.log('RevSys_ObservationTestInfoCmpHelper.createForm');
        var fields = component.get("v.editableFields");
        var observation = component.get("v.observation");
        console.log("RevSys_ObservationTestInfoCmpHelper - observation: " + observation );
        var picklistMap = component.get("v.picklistMap");
        var requiredFieldMap = component.get("v.requiredFieldMap");
        var oneIsRequiredMap = component.get("v.oneIsRequiredMap");

        var inputDesc = [];
        var fieldPaths = [];
        var oneIsRequired = [];
        var referenceFields = [];

        for (var key in oneIsRequiredMap) {
            var value = oneIsRequiredMap[key];
            oneIsRequired.push(value);
        }

        console.log("=====> oneIsRequired length: " + oneIsRequired.length);

        for (var i = 0; i < fields.length; i++) {
            var field = fields[i];
            console.log("*** field.fieldType.toLowerCase() :  " + JSON.stringify(field) + " : " + field.fieldType.toLowerCase());
            var config = this.configMap[field.fieldType.toLowerCase()];
            var fieldType = field.fieldType.toLowerCase();
            if (config) {
            	config.attributes = {"aura:id" : field.fieldPath};
                config.attributes.label = field.label;
            //    config.attributes.disabled = component.getReference("v.observation.RevSys_ReadOnly__c");
                config.attributes.value = component.getReference("v.observation."+field.fieldPath);
                if (oneIsRequired.indexOf(field.fieldPath) < 0) {
                    config.attributes.required = requiredFieldMap[field.fieldPath];
                }
                if (fieldType === "picklist") {
                	console.log("fieldType:" + fieldType);
                	var options = [];
                	var fieldName = field.fieldPath;
                	console.log("fieldName:" + fieldName);
                	var thePicklist = picklistMap[fieldName];
                	options.push({ class: "optionClass", label: "Select Value", value: "" });
                	for (var j = 0; j < thePicklist.length; j++) {
                        console.log("picklist label: " + thePicklist[j] + " ==== select: " + observation[field.fieldPath]);
                		options.push({ class: "optionClass", label: thePicklist[j], value: thePicklist[j], selected: thePicklist[j]===observation[field.fieldPath] });
                	}
                    if(fieldName == "SectionTower__c"){
                        options = [];
                        options.push({ class: "optionClass", label: "Select Value", value: "" });
                        config.attributes.options = options;
                        
                        var selectedMovementOffice = component.get("v.observation.MovementOffice__c");
                        console.log("*** selectedMovementOffice : " + JSON.stringify(selectedMovementOffice));
                        var selectionTower = component.get("v.observation.SectionTower__c");
                        console.log("*** selectionTower : " + JSON.stringify(selectionTower));
                        
                        if (!$A.util.isEmpty(selectedMovementOffice) && !$A.util.isEmpty(selectionTower)) {
                            var picklistMapMovementPosting = component.get("v.picklistMapMovementPosting");
                            
                            if (!$A.util.isEmpty(picklistMapMovementPosting)) {
                                var postingLocations = picklistMapMovementPosting[selectedMovementOffice];
                                console.log("*** postingLocations : " + JSON.stringify(postingLocations));
                                var sectionTowerCmp = component.find("SectionTower__c");
                                options = [];
                                options.push({ class: "optionClass", label: "Select Value", value: "" });
                                if (!$A.util.isEmpty(postingLocations)) {
                                    for(var i=0; i< postingLocations.length; i++){
                                        options.push({"class": "optionClass", label: postingLocations[i], value: postingLocations[i]});
                                    }
                                }
                                if (options.length > 1) {
                                    config.attributes.options = options;
                                    config.attributes.disabled = false; 
                                }
                                config.attributes.value = component.get("v.observation.SectionTower__c");
                            }
                            
                        }else{
                        	config.attributes.disabled = true;    
                        }
                        
                    }else{
                    	config.attributes.options = options;    
                    }
                	
                    
                    if(fieldName == "ObservationMethod__c"){
                        config.attributes.change = component.getReference("c.handleChangeMethod");    
                    }else if(fieldName == "MovementOffice__c"){
                        config.attributes.change = component.getReference("c.handleChangeMovementOffice");
                    }else if(fieldName == "SectionTower__c"){
                        config.attributes.change = component.getReference("c.handleChangePostingOffice");
                    }
                }
                if (fieldType === "reference") {
                	var fieldApi = field.fieldPath.toLowerCase();
                	var relatedFieldName = field.fieldPath.replace("__c", "__r.Name");
                    var referenceName = component.getReference("v.observation."+relatedFieldName);
	                config.attributes.isExpanded = "true";
					config.attributes.selectedItemLabel = referenceName;
                    config.attributes.placeholder = referenceName;
                    config.attributes.fieldLabel = field.label;
                    config.attributes.showSearchIcon = "true";
                    if (oneIsRequired.indexOf(field.fieldPath) < 0) {
					   config.attributes.isRequired = requiredFieldMap[field.fieldPath];
                    }
                    referenceFields.push(field.fieldPath);
                }
                inputDesc.push([
                    config.componentDef,
                    config.attributes
                ]);
                fieldPaths.push(field.fieldPath);
            } else {
                console.log("type " + field.fieldType.toLowerCase() + " not supported");
            }
        }
        component.set("v.referenceFields", referenceFields);
        $A.createComponents(inputDesc, function(components) {
            console.log("RevSys_ObservationTestInfoCmpHelper - createComponents");
            component.set("v.form", components);
        });
    },
    
    validateEvaluationDate : function(testResult, fieldName, dateCmp, proceed, dateError) {
        
        var evaluationDate = testResult[fieldName];	//return a string (yyyy-mm-dd) format
        console.log("*** evaluationDate : " + evaluationDate);
        if (!$A.util.isEmpty(evaluationDate)) {
            //convert a string to date
            var evaluationDateSplit = evaluationDate.split("-");
            var year = parseInt(evaluationDateSplit[0]);
            var month = parseInt(evaluationDateSplit[1] - 1);
            var date = parseInt(evaluationDateSplit[2]);
            var dateVal = new Date(year, month, date);
            console.log("*** dateVal : " + dateVal);
            var currentDate = new Date();
            currentDate.setHours(0,0,0,0);
            console.log("*** currentDate : " + currentDate);
            
            var date10DayOld = new Date();
            date10DayOld.setDate(date10DayOld.getDate() - 11);
            
            if(dateVal > currentDate){
                //cmp.set("v.errors", [{message:"Evaluation Date should not be future date."}]);
                proceed = false;
                dateError = "Evaluation Date should not be future date.";
            }else if(dateVal < date10DayOld){
                //cmp.set("v.errors",  [{message:"Evaluation Date should not be greater than 10 calendar days."}]);
                proceed = false;
                dateError = "Evaluation Date should not be greater than 10 calendar days.";
            }else{
                dateError = null;
            }
        }
        return dateError;
    }
})