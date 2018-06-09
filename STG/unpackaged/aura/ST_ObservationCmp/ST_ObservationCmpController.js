({
    doInit : function(component, event, helper) {
        
        
        helper.fetchPicklistValues(component, 'Department__c', 'Craft__c');
        
        //get Shift picklist option value
        helper.getShiftPickValues(component,event);
        
        
       
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function to clear placeholder when field is on focus       
    *-------------------------------------------------------------------------------------------
    **/
    clearPlaceholderObserver: function(component,event,helper) {
        var obvalue = component.find('ob_observer').get("v.value");
        component.find('ob_observer').set("v.value", '');
        component.set("v.emptyObserverPlaceholder", true);
    },
    
    clearPlaceholderLocation : function(component,event,helper) {
        component.find('ob_location').set("v.value",'');
        component.set("v.emptyLocationPlaceholder",true);
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function call on change of controller field - Department__c          
    *-------------------------------------------------------------------------------------------
    **/
    onControllerFieldChange: function(component, event, helper) {
        // get the selected value
        var controllerValueKey = event.getSource().get("v.value");
        console.log('debug controllerValueKey: ' +controllerValueKey);
        
        // get the map values   
        var Map = component.get("v.depnedentFieldMap");
        
        // check if selected value is not equal to None then call the helper function.
        // if controller field value is none then make dependent field value is none and disable field
        if (controllerValueKey !==''){
            
            // get dependent values for controller field by using map[key].  
            var ListOfDependentFields = Map[controllerValueKey];
            if(ListOfDependentFields.length == 1) {
                
                var craftField = component.find("ob_craft");
                var craftValue = [{
                class: "optionClass",
                label: ListOfDependentFields[0],
                value: ListOfDependentFields[0]
            }];
                craftField.set("v.options", craftValue);
               	component.set("v.isDependentDisable", false);
            }
            else {
                
            helper.fetchDepValues(component, ListOfDependentFields);
            }
        } else {
            var defaultVal = [{
                class: "optionClass",
                label: '-- None --',
                value: null
            }];
            component.find('ob_craft').set("v.options", defaultVal);
            component.set("v.isDependentDisable", true);
        }
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function used when the next button is pressed                
    *-------------------------------------------------------------------------------------------
    **/
    nextButtonClicked: function( component, event, helper){
        
        var state = component.get('v.state');
        //Allow the submit button to be clicked only once
        var nextButton = component.find("nextButton");
        nextButton.set("v.disabled",false);
        var newState = state+1;
        if(state === 1){    
            helper.observationValidation(component, event, newState);
        } else if(state === 4){
            helper.observationValidation(component, event, newState);
        }
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function used when the back button is pressed                
    *-------------------------------------------------------------------------------------------
    **/
    backButtonClicked : function (component, event, helper){
        var state = component.get('v.state');
        if(state === 4 ){
            var nextButton = component.find("nextButton");
            nextButton.set("v.disabled",false);
            var newState = state-1;
            var mainCmpEvt = component.getEvent('ST_ObservationSubmissionEvt');
            mainCmpEvt.setParams({'state' : newState,
                                 });
            mainCmpEvt.fire();
        }
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function used when the cancel button is pressed. Navigate to observation home               
    *-------------------------------------------------------------------------------------------
    **/
    cancelButtonClicked : function (component, event, helper){
        
        if(typeof sforce !== 'undefined'){
            try{
                var homeEvent = $A.get("e.force:navigateToObjectHome"); // If force event is supported
                if(homeEvent){
                    homeEvent.setParams({
                        "scope": "Observation__c" // send to Observation landing
                    });
                    homeEvent.fire();
                }else{
                    //
                    window.open ('/one/one.app#/sObject/Observation__c/list','_parent'); // other wise use window object to create a new window with one.app   
                }
            }catch(err){    
                console.log("Something went wrong: ", err.message);
            } 
        }else{
            try{
                window.open ('/one/one.app#/sObject/Observation__c/list','_parent');
            }catch(err2){
                console.log("Something went wrong: ", err2.message);
            }
            
        }
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function used to find a list of matching users to select from
    *               to populate the observer field.
    *-------------------------------------------------------------------------------------------
    **/ 
    findObservers : function(component, event, helper) {
        
        var observerField = component.find('ob_observer');
        var observerFieldId = 'ob_observer';
        var fieldValue = observerField.get('v.value');
        var observer = component.get('v.observer'); 
        var currentProcess = component.get("v.selectedProcess");
        
        var isSingleProcess = component.get("v.isSingleProcess");
        var defaultProcess = component.get("v.defaultProcess");
        
        //If user assigned to single process then assign the default process
        if(isSingleProcess == true)
            currentProcess = defaultProcess.Id;
        
        if(fieldValue.length >0){
            helper.findUsers(component, fieldValue, currentProcess, observerFieldId);
        }
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function used to select a user for the observer field
    *-------------------------------------------------------------------------------------------
    **/ 
    selectObserver : function(component,event, helper){
        var userId = event.target.id;
        var employeeName = event.target.innerHTML;
        var user = component.get('v.observer');
        var observerField = component.find('ob_observer');
        
		//alert(userId);
        //console.log(component.get("v.coach").Id);
		
        if(userId !== undefined || userId !==''){
            user.Id = userId;
            user.Name = employeeName;
            component.set('v.observer', user);
            observerField.set('v.value',employeeName);
            observerField.set("v.errors",null);
            component.set('v.observerProcessTeamList',[]); 
        }
        console.log('selected observer : '+component.get('v.observer').Id);
     //Akshay    
        if(userId == component.get("v.coach").Id) {
			validObservation = false;
            observerField.set('v.errors',[{message:'Coach and Observer can\'t be the same.'}]);
        }
        else{
            observerField.set('v.errors',null);
            if(component.get("v.coach").Id != "") {
                var coachField = component.find('ob_coach');
                coachField.set('v.errors',null);
            }
        }
        
        
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function used to find a list of matching users to select from
    *               to populate the coach field.
    *-------------------------------------------------------------------------------------------
    **/ 
    findCoaches : function(component, event, helper) {
        
        var coachField = component.find('ob_coach');
        var coachFieldId = 'ob_coach';
        var fieldValue = coachField.get('v.value');
        var currentProcess = component.get("v.selectedProcess");
        
        var isSingleProcess = component.get("v.isSingleProcess");
        var defaultProcess = component.get("v.defaultProcess");
        //If the user has just one process then use that
        if(isSingleProcess == true)
            currentProcess = defaultProcess.Id;
        
        if(fieldValue.length >0){
            helper.findUsers(component, fieldValue, currentProcess, coachFieldId);
        } else{
            component.set('v.coachList',[]);
        }
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@description:Added by Akshay 7/12/2017 function used to select a user for the coach field
    *-------------------------------------------------------------------------------------------
    **/ 
    selectCoach : function(component,event,helper){
        var userId = event.target.id;
        var coachField = component.find('ob_coach');
        
        var employeeName = event.target.innerHTML;
        var user = component.get('v.coach');
        var coachField = component.find('ob_coach');
        if(userId !== undefined || userId !==''){
            user.Id = userId;
            user.Name = employeeName;
            
            component.set('v.coach', user);
            coachField.set('v.value',employeeName);
            component.set('v.coachList',[]); 
        }
        console.log('coach id : '+component.get("v.coach").Id);
        console.log('observer id : '+component.get("v.observer").Id);
        //alert(component.find("ob_observer"));
        if(userId == component.get("v.observer").Id) {
            validObservation = false;
            coachField.set('v.errors',[{message:'Coach and Observer can\'t be the same.'}]);
        }
        else{
            coachField.set('v.errors',null);
            if(component.get("v.observer").Id != "") {
                var observerField = component.find('ob_observer');
                observerField.set('v.errors',null);
            }
        }
        
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function used to find a list of matching locations to select from
    *               to populate the coach field.
    *-------------------------------------------------------------------------------------------
    **/ 
    findLocations : function(component, event, helper){
        if(event.keyCode !== 9){ 
            var locationField = component.find('ob_location');
            var fieldValue = locationField.get('v.value');
            
            var selectedProcessId = component.get("v.selectedProcess");
            
            var isSingleProcess = component.get("v.isSingleProcess");
            var defaultProcess = component.get("v.defaultProcess");
            if(isSingleProcess == true)
                selectedProcessId = defaultProcess.Id;
            
            
            if(fieldValue.length >0){
                if(selectedProcessId != "")
                    helper.findLocations(component, fieldValue, selectedProcessId);
                
                else {
                    var processField = component.find('ob_process');        
                    var selectedProcess = processField.get('v.text');
                }
                
            } else{
                component.set('v.locationList',[]);
            }        
        }
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function used to select a location record for the location field.
    *               Also fires a database query to return any associated Areas to the Location__c
    *-------------------------------------------------------------------------------------------
    **/ 
    selectLocation : function(component, event, helper){
        var locationId= event.target.id;
        var locationName = event.target.innerHTML;
        var newLocation = ({'Id' : locationId,'Name' : locationName});
        component.set("v.location",newLocation);
        var location = component.get('v.location');
        var locationField = component.find('ob_location');
        if(locationId !== undefined || locationId !==''){
            location.Name = locationName;
            location.Id = locationId;
            component.set('v.location', location);
            locationField.set('v.value',locationName);
            locationField.set("v.placeholder",locationName);
            locationField.set('v.errors',null);
            component.set('v.locationList',[]); 
            helper.findAreas(component, locationId);    
        } else locationField.set("v.placeholder",'Select Location');
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function to handle change in the process
    *-------------------------------------------------------------------------------------------
    **/ 
    onProcessChange : function(component,event,helper) {
        console.log("********on Process Change********");
        //call helper method to clear the error fields and values of the components
        helper.clearAllvalues(component,event);
        //call helper method to handle change in process
        helper.handleProcessChange(component,event);
        
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function to validate the process component
    *-------------------------------------------------------------------------------------------
    **/ 
    emptyProcessCheck : function(component,event,helper)  {
        var isSingleProcess = component.get("v.isSingleProcess");
        var defaultProcess = component.get("v.defaultProcess");
        if(isSingleProcess == true)
            defaultProcessId = defaultProcess.Id;
        else
            defaultProcessId = component.get('v.selectedProcess');
        
        var processField = component.find('ob_process');
        if($A.util.isEmpty(defaultProcessId)){
            processField.set('v.errors',[{message:'Process cannot be blank'}]);
        } else {
            processField.set('v.errors',null);
        }
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function to validate the location component
    *-------------------------------------------------------------------------------------------
    **/ 
    
    emptyLocationCheck : function(component,event,helper){
        var locationField = component.find('ob_location');
        var locationFieldValue = locationField.get('v.value');
        var location = component.get('v.location');
        if(locationFieldValue =='' && locationFieldValue !== undefined){
            locationField.set('v.errors',[{message:'Please make sure you selected a location.'}]);
        }
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function to validate the observation component
    *-------------------------------------------------------------------------------------------
    **/ 
    emptyObserverCheck : function(component,event,helper) {
        var observerField = component.find('ob_observer');
        var observerFieldValue = observerField.get('v.value');
        var observer = component.get('v.observer');
        if(observerFieldValue == ''){
            observerField.set('v.errors',[{message:'Please make sure you selected an observer.'}]);
        }else {
            component.set('v.observerProcessTeamList',[]);
        }
        
        if(component.get("v.observer").Id == "") {
            observerField.set("v.value","");
        }
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function to validate the Number field
    *-------------------------------------------------------------------------------------------
    **/ 
    validNumberCheck : function(component,event,helper) {
        var numberOfWorkerField = component.find('ob_numberOfWorker');
        var numberOfWorker = numberOfWorkerField.get('v.value');
        
        if($A.util.isEmpty(numberOfWorker) || numberOfWorker > 5 || numberOfWorker < 1){
            validObservation = false;
            if($A.util.isEmpty(numberOfWorker)){
                numberOfWorkerField.set('v.errors',[{message:'Please make sure you entered a # of worker.'}]);
            } else{
                numberOfWorkerField.set('v.errors',[{message:'Enter a # of worker between 1 and 5.'}]);
            }
        }
        else{
            numberOfWorkerField.set('v.errors',null);
        }
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function to validate the date field
    *-------------------------------------------------------------------------------------------
    **/ 
    
    validateDate : function(component,event,helper) {
        var dateField = component.find('ob_date');
        var inputDate = dateField.get('v.value');
        if($A.util.isEmpty(inputDate)){
            //T VALIDATE FOR INCORRECT INPUT
            dateField.set('v.errors',[{message:'Please make sure you entered a correct date.'}]);
        } else{
            dateField.set('v.errors',null);
        }
    },
    validateCoach : function(component, event, newState) {
        console.log('ob blur of coach, coach Id : '+component.get("v.coach").Id);
        console.log('coach text value : ' + component.find("ob_coach").get("v.value").length); 
        /*var coachField = component.find("ob_coach");
        if(component.get("v.coach").Id == "" && component.find("ob_coach").get("v.value").length > 0) {
            //coachField.set("v.value","");
            coachField.set('v.errors',[{message:'Please make sure you select a valid SafeTrends User.'}]);
        }
        else {
            coachField.set('v.errors', null);
        }*/
        //component.set('v.coachList',[]);
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@description: function to validate the Department field
    *-------------------------------------------------------------------------------------------
    **/ 
    validateDepartment : function(component,event,helper){
        var departmentField = component.find('ob_department');
        var department= departmentField.get('v.value');
        if($A.util.isEmpty(department)){
            validObservation = false;
            departmentField.set('v.errors',[{message:'Please make sure you selected a department.'}]);
        } else{
            departmentField.set('v.errors',null);
        }
    }
    
})