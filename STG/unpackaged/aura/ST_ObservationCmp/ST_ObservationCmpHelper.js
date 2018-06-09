({
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used return a list of Users records from Salesforce
	*@param: searchKey	represent the value entered in the observer or coach fields.
	*@param: process	Name of the process associated with the current user. 
	*-------------------------------------------------------------------------------------------
	**/	
    findUsers : function(component, searchKey, process, fieldId) {
        
        var action = component.get('c.findObserverOrCoach');({
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used return a list of Users records from Salesforce
	*@param: searchKey	represent the value entered in the observer or coach fields.
	*@param: process	Name of the process associated with the current user. 
	*-------------------------------------------------------------------------------------------
	**/	
    findUsers : function(component, searchKey, process, fieldId) {
        
        var action = component.get('c.findObserverOrCoach');
        
        action.setParams({
            'searchKey' : searchKey,
            'selectedProcessId' : process,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            
            if( component.isValid() && state ==='SUCCESS'){
                if(fieldId ==='ob_observer'){
                    component.set('v.observerProcessTeamList',returnValue);
                } else if(fieldId ==='ob_coach'){
                    component.set('v.coachList', returnValue);
                }
                
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used return a list of Location records from Salesforce
	*@param: searchKey	represent the value entered in the location field.
	*@param: process	Name of the process associated with the current user. 
	*-------------------------------------------------------------------------------------------
	**/	
    findLocations : function(component, searchKey, process){
        
        var action = component.get('c.findAllLocations');
        
        action.setParams({
            'searchKey' : searchKey,
            'selectedProcessId' : process,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            //console.log(returnValue);
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.locationList', returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);		
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used to return a list of Areas records from Salesforce
	*@param: location	location selected by the user.
	*-------------------------------------------------------------------------------------------
	**/	
    findAreas :function(component, locationId){
        var action = component.get('c.getAreas');
        
        action.setParams({
            'location' : locationId,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            //console.log(returnValue);
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.Areas', returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);		
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function to fetch controlling picklist value
	*@param: controllerField  represent the controlling field name.
	*@param: dependentField  represent the dependent field name.
	*-------------------------------------------------------------------------------------------
	**/	
    fetchPicklistValues: function(component, controllerField, dependentField) {
        // call the server side function  
        var action = component.get("c.getDependentOptionsImpl");
        
        // pass paramerters [object name , contrller field name ,dependent field name] to server side function 
        action.setParams({
            'objApiName': component.get("v.objInfo"),
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap", StoreResponse);
                
                // create empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = [];
                // create empty array for store controller picklist value to set on ui field. 
                var ControllerField = []; 
                
                // play a for loop on Return map and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for ui:inputSelect  
                if (listOfkeys.length > 0) {
                    ControllerField.push({
                        class: "optionClass",
                        label: ' Select Department',
                        value: null
                    });
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push({
                        class: "optionClass",
                        label: listOfkeys[i],
                        value: listOfkeys[i]
                    });
                }
                // set the ControllerField variable values to controller picklist field - Department__c
                component.find('ob_department').set("v.options", ControllerField);
            }
        });
        $A.enqueueAction(action);
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function to fetch dependent picklist value
	*@param: ListOfDependentFields  represent the dependent field value list.
	*-------------------------------------------------------------------------------------------
	**/	
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field)  
        var dependentFields = [];
        
        if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
            dependentFields.push({
                class: "optionClass",
                label: '-- None --',
                value: null
            });
            
        }
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push({
                class: "optionClass",
                label: ListOfDependentFields[i],
                value: ListOfDependentFields[i]
            });
        }
        // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
        component.find('ob_craft').set("v.options", dependentFields);
        // make disable false for ui:inputselect field 
        component.set("v.isDependentDisable", false);
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function to validate entry, flag error fields and populate newObservation.
	*@param: newState	represent the next state, used for navigation.
	*-------------------------------------------------------------------------------------------
	**/	
    observationValidation : function(component, event, newState){
        
        var newObs = component.get('v.newObservation');
        var observerField = component.find('ob_observer');
        var observerFieldValue = observerField.get('v.value');
        var observer = component.get('v.observer');
        var state = component.get('v.state');
        var processField = component.find('ob_process');
        var isObserver = component.get("v.isObserver");
        var emptyObserver = component.get("v.emptyObserverPlaceholder");
        //Check if user has just one process
        var isSingleProcess = component.get("v.isSingleProcess");
        var defaultProcess = component.get("v.defaultProcess");
        if(isSingleProcess == true) {
            defaultProcessId = defaultProcess.Id;
            if((isObserver == true || isSingleProcess == true) && emptyObserver !== true) observerFieldValue = observer.Name;
        }
        else
            defaultProcessId = component.get('v.selectedProcess');
        
        var coachField = component.find('ob_coach');
        var coachFieldValue = coachField.get('v.value');
        var coach = component.get('v.coach');
        
        var locationField = component.find('ob_location');
        var locationFieldValue = locationField.get('v.value');
        var location = component.get('v.location');
        
        var numberOfWorkerField = component.find('ob_numberOfWorker');
        var numberOfWorker = numberOfWorkerField.get('v.value');
        
        var areaField = component.find('ob_area');
        var areaId = areaField.get('v.value');
        var dateField = component.find('ob_date');
        var inputDate = dateField.get('v.value');
        var departmentField = component.find('ob_department');
        var department= departmentField.get('v.value');
        var shiftField = component.find('ob_shift');
        var shift = shiftField.get('v.value');
        
        var isSingleCraft = component.get("v.isSingleCraft");
        
      
        var craftField = component.find('ob_craft');
        var craft = craftField.get('v.value');    
      
        
        
        var commentsField = component.find('ob_overallCmt');
        var comments = commentsField.get('v.value');
        
        //verify required fields
        
        var validObservation = true;
        
        
        
        //validate required fields
        if(!$A.util.isEmpty(observer)){
            if($A.util.isEmpty(observer.Id) || observer.Name !== observerFieldValue || observerFieldValue === '' ){
                validObservation = false;
                observerField.set('v.errors',[{message:'Please make sure you selected an observer.'}]);
            } else{
                observerField.set('v.errors',null);
            }
        } else {
            validObservation = false;
            observerField.set('v.errors',[{message:'Please make sure you selected an observer.'}]);
        }
        
        if($A.util.isEmpty(defaultProcessId)){
            validObservation = false;
            processField.set('v.errors',[{message:'Please make sure that a process is selected'}]);
        }
        
        if(!$A.util.isEmpty(location)){
            if($A.util.isEmpty(location.Id) || (location.Name !== locationFieldValue && locationFieldValue !== undefined) ){
                validObservation = false;
                locationField.set('v.errors',[{message:'Please make sure you selected a location.'}]);
            } else{
                locationField.set('v.errors',null);
            }
        } else {
            validObservation = false;
            locationField.set('v.errors',[{message:'Please make sure you selected a location.'}]);
        }
        
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
        
        if($A.util.isEmpty(inputDate)){
            //T VALIDATE FOR INCORRECT INPUT
            validObservation = false;
            dateField.set('v.errors',[{message:'Please make sure you entered a correct date.'}]);
        } else{
            dateField.set('v.errors',null);
        }
        
        if($A.util.isEmpty(department)){
            validObservation = false;
            departmentField.set('v.errors',[{message:'Please make sure you selected a department.'}]);
        } else{
            departmentField.set('v.errors',null);
        }
        
    //    alert('1234');
        //var coachField = component.find("ob_coach");
        //console.log('coach id : '+component.get("v.coach").Id);
        //console.log('coach id : '+component.find("ob_coach").get("v.value").length);
        /*if(component.get("v.coach").Id == "" && component.find("ob_coach").get("v.value").length > 0) {
            //coachField.set("v.value","");
            validObservation = false;
            coachField.set('v.errors',[{message:'Please make sure you select a valid SafeTrends User.'}]);
        }
        else {
            coachField.set('v.errors', null);
        }*/
        // end required field validation
        
        
        //transfor the date input into something we can use with the DB
        var dateAtt = inputDate.split('-');
        var parsedDate = dateAtt[1]+'/'+dateAtt[2]+'/'+dateAtt[0];
        
        // if we have all the required field information assign values to the observation object
        //if(validObservation === true){
        if(validObservation === false){
        	// Data to be corrected and validation failed
        }
        else {
            //assign values to newObs object
            newObs.Observer_ID_Process_Team__c =observer.Id;
            newObs.Process__c = defaultProcessId;
            newObs.Coached_ID_Process_Team__c = coach.Id;
            newObs.Location__c = location.Id;
            newObs.Number_of_Workers_Observed__c = numberOfWorker;
            newObs.Area__c = areaId;
            newObs.Date__c = parsedDate;//inputDate;
            newObs.Department__c = department;
            newObs.Shift__c = shift;
            newObs.Craft__c = craft;
            newObs.Overall_Comments__c = comments;
            
            //pass object to other function
            component.set('v.newObservation', newObs);
            this.sendObservation(component, event, newState, newObs);
            //Disable submit button only if the state is 4
            if(state === 4) {
                var nextButton = component.find("nextButton");
                nextButton.set("v.disabled",true);
            }
        }
        
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function to send event with a validated observation to main component
	*@param: newState	represent the next state, used for navigation.
	*@param: newObs		represent the validated observation.
	*-------------------------------------------------------------------------------------------
	**/	
    sendObservation :function (component, event, newState, newObs){
        
        
        
        var mainCmpEvt = component.getEvent('ST_ObservationSubmissionEvt');
        mainCmpEvt.setParams({'state' : newState,
                              'obs' : newObs,
                             });
        mainCmpEvt.fire();
        
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function get shift picklist Values
	*-------------------------------------------------------------------------------------------
	**/	
    
    getShiftPickValues : function(component,event){
        var shiftAction = component.get("c.getShiftPickval");
        var shiftInputsel = component.find("ob_shift");
        var shiftOpts=[];
        shiftAction.setCallback(this, function(b) {
            for(var r=0;r< b.getReturnValue().length;r++){
                
                if(b.getReturnValue()[r] ==='-- None --'){
                    shiftOpts.push({"class": "optionClass", label: b.getReturnValue()[r], value: null});
                } else{
                    shiftOpts.push({"class": "optionClass", label: b.getReturnValue()[r], value: b.getReturnValue()[r]}); 
                }
            } 
            shiftInputsel.set("v.options", shiftOpts);
        });
        
        //get today's date
        var today = new Date();
        component.set('v.todaysDate', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
        
        $A.enqueueAction(shiftAction);  
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: helper method to handle process change
	*-------------------------------------------------------------------------------------------
	**/	
    
    handleProcessChange : function(component,event) {
        var processList = component.get("v.processList");      
        var selectedProcessId = component.get("v.selectedProcess");
        
        
        if(selectedProcessId != '') {
            //assign default location
            this.checkInitialLocation(component,selectedProcessId);
            this.getUserProcessTeam(component,selectedProcessId);
            
        }
        
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function used to verify if the user has only access to one location. If so set defaultLocation
    *@param:    process    represent the Id of the process assocaited with a location. 
    *-------------------------------------------------------------------------------------------
    **/    
    checkInitialLocation : function(component, processId){
        console.log('processId '+processId);
        var action = component.get("c.findAllLocations");
        
        action.setParams({
            'searchKey' : '%',
            'selectedProcessId' : processId,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            var location = component.get('v.location');
            var locationField = component.find('ob_location');
            if( component.isValid() && state ==='SUCCESS'){
                if(returnValue.length === 1){
                    
                    var defaultLocation = returnValue[0];
                    
                    locationField.set('v.value',defaultLocation.Name);
                    component.set('v.location',defaultLocation);
                    component.set('v.disableLocation',true);
                    this.findInitialAreas(component, returnValue[0]);
                }
                else {
                    //this.setLocationPlaceHolder(component,'Select Location');
                    
                    locationField.set("v.placeholder",'Select Location');
                    locationField.set("v.value",'');
                    component.set('v.disableLocation',false);
                }
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function used if user has access to 1 location to autoload the ares the user has access to 
    *@param:    location    represent the Location record associated with the areas.
    *-------------------------------------------------------------------------------------------
    **/    
    findInitialAreas :function(component, location){
        //getAreas
        //location is an id
        var action = component.get('c.getAreas');
        
        action.setParams({
            'location' : location.Id,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.Areas',returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);   
        
    },
    
    setLocationPlaceHolder : function(component,placeHolderValue) {
        var locationSelectComponent = component.find("ob_location");
        locationSelectComponent.set("v.placeholder",placeHolderValue);
    },
    
    setObserverPlaceHolder : function(component,placeHolderValue) {
        
        var observerSelectComponent = component.find("ob_observer");
        observerSelectComponent.set("v.placeholder",placeHolderValue);
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function quering the Database to retrieve current user's process Team
    *-------------------------------------------------------------------------------------------
    **/
    getUserProcessTeam : function(component,processId){
        
        // Sets action variable to method of Apex Class: ST_ObservationDController 
        var action = component.get("c.getCurrentUserObserver");
        var observerSelectComponent = component.find("ob_observer");
        action.setParams({
            'selectedProcessId' : processId,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if(component.isValid() && state ==='SUCCESS'){
                var processTeam = response.getReturnValue();
                //set observer fields
                component.set("v.currentUserProcessTeam",processTeam);
                component.set("v.observer",processTeam);
                observerSelectComponent.set("v.placeholder",processTeam.Name);
                observerSelectComponent.set("v.value",processTeam.Name);
                console.log(processTeam);
                //Mark the observerfield disabled if the user is an Observer
                if(processTeam.Team_Role__c === "Observer") {
                    component.set("v.isObserver",true);
                } else {
                    component.set("v.isObserver",false);
                }
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        
        // Sets server side action in a queue
        $A.enqueueAction(action);
        
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function to clear all the fields after the process change
    *-------------------------------------------------------------------------------------------
    **/
    clearAllvalues : function(component,event) {
        
        var areaField = component.find('ob_area');
        var departmentField = component.find('ob_department');
        var shiftField = component.find('ob_shift');
        var coachField = component.find('ob_coach');
        var locationField = component.find('ob_location');
        var observerField = component.find('ob_observer');
        var numberOfWorkerField = component.find('ob_numberOfWorker');
        var isSingleCraft = component.get("v.isSingleCraft");
        //clear process fields
        var processField = component.find('ob_process');
        processField.set("v.errors",null);
        //clear location fields
        component.set("v.location",null);
        locationField.set("v.errors",null);
        locationField.set("v.value",'');
        locationField.set("v.disabled",false);
        
        //clear observer field
        observerField.set("v.errors",'');
        observerField.set("v.disabled",false);
        
        //clear area
        areaField.set("v.value",'');
        
        //clear Department
        departmentField.set("v.value",'--None--');
        departmentField.set("v.errors",'');
        
        //clear shift
        shiftField.set("v.value",'--None--');
        
        
        //clear craft
       
             var craftField = component.find('ob_craft');
             craftField.set("v.value",'--None--');
       
        
        //clear coach
        coachField.set("v.value",'');
        
        //clear numberOfWorker field
        numberOfWorkerField.set("v.value",'');
        numberOfWorkerField.set("v.errors",'');
    },
    
    
})
        
        action.setParams({
            'searchKey' : searchKey,
            'selectedProcessId' : process,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            
            if( component.isValid() && state ==='SUCCESS'){
                if(fieldId ==='ob_observer'){
                    component.set('v.observerProcessTeamList',returnValue);
                } else if(fieldId ==='ob_coach'){
                    component.set('v.coachList', returnValue);
                }
                
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used return a list of Location records from Salesforce
	*@param: searchKey	represent the value entered in the location field.
	*@param: process	Name of the process associated with the current user. 
	*-------------------------------------------------------------------------------------------
	**/	
    findLocations : function(component, searchKey, process){
        
        var action = component.get('c.findAllLocations');
        
        action.setParams({
            'searchKey' : searchKey,
            'selectedProcessId' : process,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            //console.log(returnValue);
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.locationList', returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);		
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used to return a list of Areas records from Salesforce
	*@param: location	location selected by the user.
	*-------------------------------------------------------------------------------------------
	**/	
    findAreas :function(component, locationId){
        var action = component.get('c.getAreas');
        
        action.setParams({
            'location' : locationId,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            //console.log(returnValue);
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.Areas', returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);		
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function to fetch controlling picklist value
	*@param: controllerField  represent the controlling field name.
	*@param: dependentField  represent the dependent field name.
	*-------------------------------------------------------------------------------------------
	**/	
    fetchPicklistValues: function(component, controllerField, dependentField) {
        // call the server side function  
        var action = component.get("c.getDependentOptionsImpl");
        
        // pass paramerters [object name , contrller field name ,dependent field name] to server side function 
        action.setParams({
            'objApiName': component.get("v.objInfo"),
            'contrfieldApiName': controllerField,
            'depfieldApiName': dependentField
        });
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //store the return response from server (map<string,List<string>>)  
                var StoreResponse = response.getReturnValue();
                
                // once set #StoreResponse to depnedentFieldMap attribute 
                component.set("v.depnedentFieldMap", StoreResponse);
                
                // create empty array for store map keys(@@--->which is controller picklist values) 
                var listOfkeys = [];
                // create empty array for store controller picklist value to set on ui field. 
                var ControllerField = []; 
                
                // play a for loop on Return map and fill the all map key on listOfkeys variable.
                for (var singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                //set the controller field value for ui:inputSelect  
                if (listOfkeys.length > 0) {
                    ControllerField.push({
                        class: "optionClass",
                        label: ' Select Department',
                        value: null
                    });
                }
                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push({
                        class: "optionClass",
                        label: listOfkeys[i],
                        value: listOfkeys[i]
                    });
                }
                // set the ControllerField variable values to controller picklist field - Department__c
                component.find('ob_department').set("v.options", ControllerField);
            }
        });
        $A.enqueueAction(action);
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function to fetch dependent picklist value
	*@param: ListOfDependentFields  represent the dependent field value list.
	*-------------------------------------------------------------------------------------------
	**/	
    fetchDepValues: function(component, ListOfDependentFields) {
        // create a empty array var for store dependent picklist values for controller field)  
        var dependentFields = [];
        
        if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
            dependentFields.push({
                class: "optionClass",
                label: '-- None --',
                value: null
            });
            
        }
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push({
                class: "optionClass",
                label: ListOfDependentFields[i],
                value: ListOfDependentFields[i]
            });
        }
        // set the dependentFields variable values to State(dependent picklist field) on ui:inputselect    
        component.find('ob_craft').set("v.options", dependentFields);
        // make disable false for ui:inputselect field 
        component.set("v.isDependentDisable", false);
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function to validate entry, flag error fields and populate newObservation.
	*@param: newState	represent the next state, used for navigation.
	*-------------------------------------------------------------------------------------------
	**/	
    observationValidation : function(component, event, newState){
        
      //  alert('1234');
        var newObs = component.get('v.newObservation');
        var observerField = component.find('ob_observer');
        var observerFieldValue = observerField.get('v.value');
        var observer = component.get('v.observer');
        var state = component.get('v.state');
        var processField = component.find('ob_process');
        var isObserver = component.get("v.isObserver");
        var emptyObserver = component.get("v.emptyObserverPlaceholder");
        //Check if user has just one process
        var isSingleProcess = component.get("v.isSingleProcess");
        var defaultProcess = component.get("v.defaultProcess");
        if(isSingleProcess == true) {
            defaultProcessId = defaultProcess.Id;
            if((isObserver == true || isSingleProcess == true) && emptyObserver !== true) observerFieldValue = observer.Name;
        }
        else
            defaultProcessId = component.get('v.selectedProcess');
        
        var coachField = component.find('ob_coach');
        var coachFieldValue = coachField.get('v.value');
        var coach = component.get('v.coach');
        
        var locationField = component.find('ob_location');
        var locationFieldValue = locationField.get('v.value');
        var location = component.get('v.location');
        
        var numberOfWorkerField = component.find('ob_numberOfWorker');
        var numberOfWorker = numberOfWorkerField.get('v.value');
        
        var areaField = component.find('ob_area');
        var areaId = areaField.get('v.value');
        var dateField = component.find('ob_date');
        var inputDate = dateField.get('v.value');
        var departmentField = component.find('ob_department');
        var department= departmentField.get('v.value');
        var shiftField = component.find('ob_shift');
        var shift = shiftField.get('v.value');
        
        var isSingleCraft = component.get("v.isSingleCraft");
        
      
        var craftField = component.find('ob_craft');
        var craft = craftField.get('v.value');    
      
        
        
        var commentsField = component.find('ob_overallCmt');
        var comments = commentsField.get('v.value');
        
        //verify required fields
        
        var validObservation = true;
        
        //validate required fields
        if(!$A.util.isEmpty(observer)){
            if($A.util.isEmpty(observer.Id) || observer.Name !== observerFieldValue || observerFieldValue === '' ){
                validObservation = false;
                observerField.set('v.errors',[{message:'Please make sure you selected an observer.'}]);
            } else{
                observerField.set('v.errors',null);
            }
        } else {
            validObservation = false;
            observerField.set('v.errors',[{message:'Please make sure you selected an observer.'}]);
        }
        
		//	Validate Coach and Observer not to be same - Lakshmi, 07/JAN
        if(component.get("v.coach").Id == component.get("v.observer").Id) {
            validObservation = false;
            var observerField = component.find('ob_observer');
            observerField.set('v.errors',[{message:'Coach and Observer can\'t be the same.'}]);
        }
        
        if($A.util.isEmpty(defaultProcessId)){
            validObservation = false;
            processField.set('v.errors',[{message:'Please make sure that a process is selected'}]);
        }
        
        if(!$A.util.isEmpty(location)){
            if($A.util.isEmpty(location.Id) || (location.Name !== locationFieldValue && locationFieldValue !== undefined) ){
                validObservation = false;
                locationField.set('v.errors',[{message:'Please make sure you selected a location.'}]);
            } else{
                locationField.set('v.errors',null);
            }
        } else {
            validObservation = false;
            locationField.set('v.errors',[{message:'Please make sure you selected a location.'}]);
        }
        
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
        
        if($A.util.isEmpty(inputDate)){
            //T VALIDATE FOR INCORRECT INPUT
            validObservation = false;
            dateField.set('v.errors',[{message:'Please make sure you entered a correct date.'}]);
        } else{
            dateField.set('v.errors',null);
        }
        
        if($A.util.isEmpty(department)){
            validObservation = false;
            departmentField.set('v.errors',[{message:'Please make sure you selected a department.'}]);
        } else{
            departmentField.set('v.errors',null);
        }
        
        if(component.get("v.coach").Id == "" && component.find("ob_coach").get("v.value").length > 0) {
            //coachField.set("v.value","");
            validObservation = false;
            coachField.set('v.errors',[{message:'Please make sure you select a valid SafeTrends User.'}]);
        }
        else {
            coachField.set('v.errors', null);
        }
        // end required field validation
        
        
        //transfor the date input into something we can use with the DB
        var dateAtt = inputDate.split('-');
        var parsedDate = dateAtt[1]+'/'+dateAtt[2]+'/'+dateAtt[0];
        
        // if we have all the required field information assign values to the observation object
        if(validObservation === true){
            //assign values to newObs object
            newObs.Observer_ID_Process_Team__c =observer.Id;
            newObs.Process__c = defaultProcessId;
            newObs.Coached_ID_Process_Team__c = coach.Id;
            newObs.Location__c = location.Id;
            newObs.Number_of_Workers_Observed__c = numberOfWorker;
            newObs.Area__c = areaId;
            newObs.Date__c = parsedDate;//inputDate;
            newObs.Department__c = department;
            newObs.Shift__c = shift;
            newObs.Craft__c = craft;
            newObs.Overall_Comments__c = comments;
            
            //pass object to other function
            component.set('v.newObservation', newObs);
            this.sendObservation(component, event, newState, newObs);
            //Disable submit button only if the state is 4
            if(state === 4) {
                var nextButton = component.find("nextButton");
                nextButton.set("v.disabled",true);
            }
        }
        
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function to send event with a validated observation to main component
	*@param: newState	represent the next state, used for navigation.
	*@param: newObs		represent the validated observation.
	*-------------------------------------------------------------------------------------------
	**/	
    sendObservation :function (component, event, newState, newObs){
        
        
        
        var mainCmpEvt = component.getEvent('ST_ObservationSubmissionEvt');
        mainCmpEvt.setParams({'state' : newState,
                              'obs' : newObs,
                             });
        mainCmpEvt.fire();
        
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function get shift picklist Values
	*-------------------------------------------------------------------------------------------
	**/	
    
    getShiftPickValues : function(component,event){
        var shiftAction = component.get("c.getShiftPickval");
        var shiftInputsel = component.find("ob_shift");
        var shiftOpts=[];
        shiftAction.setCallback(this, function(b) {
            for(var r=0;r< b.getReturnValue().length;r++){
                
                if(b.getReturnValue()[r] ==='-- None --'){
                    shiftOpts.push({"class": "optionClass", label: b.getReturnValue()[r], value: null});
                } else{
                    shiftOpts.push({"class": "optionClass", label: b.getReturnValue()[r], value: b.getReturnValue()[r]}); 
                }
            } 
            shiftInputsel.set("v.options", shiftOpts);
        });
        
        //get today's date
        var today = new Date();
        component.set('v.todaysDate', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
        
        $A.enqueueAction(shiftAction);  
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: helper method to handle process change
	*-------------------------------------------------------------------------------------------
	**/	
    
    handleProcessChange : function(component,event) {
        var processList = component.get("v.processList");      
        var selectedProcessId = component.get("v.selectedProcess");
        
        
        if(selectedProcessId != '') {
            //assign default location
            this.checkInitialLocation(component,selectedProcessId);
            this.getUserProcessTeam(component,selectedProcessId);
            
        }
        
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function used to verify if the user has only access to one location. If so set defaultLocation
    *@param:    process    represent the Id of the process assocaited with a location. 
    *-------------------------------------------------------------------------------------------
    **/    
    checkInitialLocation : function(component, processId){
        console.log('processId '+processId);
        var action = component.get("c.findAllLocations");
        
        action.setParams({
            'searchKey' : '%',
            'selectedProcessId' : processId,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            var location = component.get('v.location');
            var locationField = component.find('ob_location');
            if( component.isValid() && state ==='SUCCESS'){
                if(returnValue.length === 1){
                    
                    var defaultLocation = returnValue[0];
                    
                    locationField.set('v.value',defaultLocation.Name);
                    component.set('v.location',defaultLocation);
                    component.set('v.disableLocation',true);
                    this.findInitialAreas(component, returnValue[0]);
                }
                else {
                    //this.setLocationPlaceHolder(component,'Select Location');
                    
                    locationField.set("v.placeholder",'Select Location');
                    locationField.set("v.value",'');
                    component.set('v.disableLocation',false);
                }
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function used if user has access to 1 location to autoload the ares the user has access to 
    *@param:    location    represent the Location record associated with the areas.
    *-------------------------------------------------------------------------------------------
    **/    
    findInitialAreas :function(component, location){
        //getAreas
        //location is an id
        var action = component.get('c.getAreas');
        
        action.setParams({
            'location' : location.Id,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.Areas',returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);   
        
    },
    
    setLocationPlaceHolder : function(component,placeHolderValue) {
        var locationSelectComponent = component.find("ob_location");
        locationSelectComponent.set("v.placeholder",placeHolderValue);
    },
    
    setObserverPlaceHolder : function(component,placeHolderValue) {
        
        var observerSelectComponent = component.find("ob_observer");
        observerSelectComponent.set("v.placeholder",placeHolderValue);
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function quering the Database to retrieve current user's process Team
    *-------------------------------------------------------------------------------------------
    **/
    getUserProcessTeam : function(component,processId){
        
        // Sets action variable to method of Apex Class: ST_ObservationDController 
        var action = component.get("c.getCurrentUserObserver");
        var observerSelectComponent = component.find("ob_observer");
        action.setParams({
            'selectedProcessId' : processId,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            if(component.isValid() && state ==='SUCCESS'){
                var processTeam = response.getReturnValue();
                //set observer fields
                component.set("v.currentUserProcessTeam",processTeam);
                component.set("v.observer",processTeam);
                observerSelectComponent.set("v.placeholder",processTeam.Name);
                observerSelectComponent.set("v.value",processTeam.Name);
                console.log(processTeam);
                //Mark the observerfield disabled if the user is an Observer
                if(processTeam.Team_Role__c === "Observer") {
                    component.set("v.isObserver",true);
                } else {
                    component.set("v.isObserver",false);
                }
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        
        // Sets server side action in a queue
        $A.enqueueAction(action);
        
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function to clear all the fields after the process change
    *-------------------------------------------------------------------------------------------
    **/
    clearAllvalues : function(component,event) {
        
        var areaField = component.find('ob_area');
        var departmentField = component.find('ob_department');
        var shiftField = component.find('ob_shift');
        var coachField = component.find('ob_coach');
        var locationField = component.find('ob_location');
        var observerField = component.find('ob_observer');
        var numberOfWorkerField = component.find('ob_numberOfWorker');
        var isSingleCraft = component.get("v.isSingleCraft");
        //clear process fields
        var processField = component.find('ob_process');
        processField.set("v.errors",null);
        //clear location fields
        component.set("v.location",null);
        locationField.set("v.errors",null);
        locationField.set("v.value",'');
        locationField.set("v.disabled",false);
        
        //clear observer field
        observerField.set("v.errors",'');
        observerField.set("v.disabled",false);
        
        //clear area
        areaField.set("v.value",'');
        
        //clear Department
        departmentField.set("v.value",'--None--');
        departmentField.set("v.errors",'');
        
        //clear shift
        shiftField.set("v.value",'--None--');
        
        
        //clear craft
       
             var craftField = component.find('ob_craft');
             craftField.set("v.value",'--None--');
       
        
        //clear coach
        coachField.set("v.value",'');
        
        //clear numberOfWorker field
        numberOfWorkerField.set("v.value",'');
        numberOfWorkerField.set("v.errors",'');
    },
    
    
})