({
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function quering the Database to retrieve current user Processes
    *-------------------------------------------------------------------------------------------
    **/
    getUserProcesses : function(component){
        
        // Sets action variable to method of Apex Class: ST_ObservationDController 
        var processList = component.get("v.processList");
        
        var action = component.get("c.getCurrentUserProcesses");
        
        // call back sets this to response
        action.setCallback(this, function(response) {
            
            var state = response.getState(); // Capture State (200, 400, codes)
            if (state === "SUCCESS") { // If 200 Response from Server
                
                var data = response.getReturnValue(); // set data to the result of getReturnValue built in method on response
                processList = data;
                console.log("process List "+processList);
                
                if(processList.length > 0){
                    component.set("v.state", 1);
                    component.set("v.processList",processList);
                    if(processList.length == 1) {
                        component.set("v.isSingleProcess",true);
                        component.set("v.defaultProcess",processList[0]);
                        //set default location
                        this.checkInitialLocation(component,processList[0].Id);
                        //get the current user Process Team
                        this.getUserProcessTeam(component,processList[0].Id);
                    }
                    
                } else{
                    this.validateServerSideMessage(component);
                }
                // Handle Errors if any
            } else if (state === "ERROR") {
                $A.log("Errors", response.getError());
                console.log('Response not coming through');
            }
        });
        
        // Sets server side action in a queue
        $A.enqueueAction(action);
        
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function quering the Database to retrieve current user Process teams
    *-------------------------------------------------------------------------------------------
    **/
    
    getUserProcessTeam : function(component,defaultProcessId) {
        
        var action = component.get('c.getCurrentUserObserver');
        
        action.setParams({"selectedProcessId" : defaultProcessId});
        // call back sets this to response
        action.setCallback(this, function(response) {   
            var state = response.getState(); 
            
            if (state === "SUCCESS") { 
                
                var processTeam = response.getReturnValue();
                 component.set("v.currentUserProcessTeam",processTeam);
                if(processTeam.Team_Role__c === "Observer") {
                    component.set("v.isObserver",true);
                } else {
                    component.set("v.isObserver",false);
                }
               
            } else if (state === "ERROR") {
                $A.log("Errors", response.getError());
                console.log('Response not coming through');
            }
        });
        
        // Sets server side action in a queue
        $A.enqueueAction(action);
        
    },
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function used to indicate that the ST_SBICmp needs to get a new list of SBI
    *-------------------------------------------------------------------------------------------
    *@param    state        represent the state of the App
    *@param    department   represent the department of the Observation__c record
    *-------------------------------------------------------------------------------------------
    **/
    callSBICmp :function(component, state, department){
        var action = component.get('c.getSBIs');
        var dept = department;
        action.setParams({"department" : dept});
        // call back sets this to response
        action.setCallback(this, function(response) {   
            var state = response.getState(); 
            
            if (state === "SUCCESS") { 
                
                var data = response.getReturnValue();
                for( var i=0 ;i<data.length;i++){
                    data[i].Safe =false;
                    data[i].Risk = false;
                    
                }
                //sbiCmp.getSBIsMethod(dept, data);
                component.set('v.sbiList', data);
                // Handle Errors if any
            } else if (state === "ERROR") {
                $A.log("Errors", response.getError());
                console.log('Response not coming through');
            }
        });
        
        // Sets server side action in a queue
        $A.enqueueAction(action);
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function used to push a new SBI to list and make sure we received all SBIs
    *-------------------------------------------------------------------------------------------
    *@param    SBI   represent an SBI record
    *-------------------------------------------------------------------------------------------
    **/
    pushSBI : function(component, SBI){
        var selectedRiskSBI = component.get('v.selectedRiskSBI');
        var initialSelectedRiskSBIs = component.get('v.initialSelectedRiskSBIs');
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function used to push a new SBI to list and make sure we received all SBIs
    *-------------------------------------------------------------------------------------------
    **/
    submitToDB : function(component){
        var obs = component.get('v.obs');
        var selectedRiskSBIs = component.get('v.selectedRiskSBIs');
        var selectedSafeSBIs = component.get('v.selectedSafeSBIs');
        var dmlMessage;
        var dmlStatus;
        
        var newFindings = [];
        
        for (var i=0; i<selectedRiskSBIs.length; i++){
            var riskSBI = selectedRiskSBIs[i];
            var riskFindings = riskSBI.Findings__r;
            for (var y=0; y<riskFindings.length; y++){
                var risk = riskFindings[y];
                newFindings.push(risk);
            }
        }
        
        for (var i=0; i<selectedSafeSBIs.length; i++){
            var safeSBI = selectedSafeSBIs[i];
            var safeFindings = safeSBI.Findings__r;
            for (var y=0; y<safeFindings.length; y++){
                var safe = safeFindings[y];
                newFindings.push(safe);
            }
        }
        
        console.log(obs);
        console.log(newFindings);
        
        var action = component.get('c.insertObservation');
        
        action.setParams({ 
            'newObservation' : obs,
            'newFindings' : newFindings,
        });
        
        action.setCallback(this, function(response){
            
            var state = response.getState();
            var returnValue = response.getReturnValue();
            console.log(state);
            console.log(response.error);
            component.set('v.state', 5);
            if( component.isValid() && state ==='SUCCESS'){
                if(returnValue === 'Error_observations'){
                    dmlMessage = 'There is an error with the information entered into the Observation Metrics Details (Basic) page. Please try again or contact your administrator for further support.';
                    dmlStatus = false;
                } else if(returnValue === 'Error_findings'){
                    dmlMessage = 'There is an error with the information entered into the At Risk Behavior Details (Descriptions) page. Please try again or contact your administrator for further support.';
                    dmlStatus = false;
                }else if(returnValue === 'Success'){
                    dmlMessage = 'Your Observation was successfully submitted!';
                    dmlStatus = true;                    
                }
            } else{
                dmlMessage = 'There was an error while submitting your data. Please try again or contact your administrator for further support.';
                dmlStatus = false;
            }
            component.set('v.dmlMessage', dmlMessage);
            component.set('v.dmlStatus', dmlStatus);
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    /**
    *-------------------------------------------------------------------------------------------
    *@Description: Function used to verify if the user has only access to one location. If so set defaultLocation
    *@param:    process    represent the Id of the process assocaited with a location. 
    *-------------------------------------------------------------------------------------------
    **/    
    checkInitialLocation : function(component, process){
        
        var action = component.get('c.findAllLocations');
        console.log('process '+process);
        
        action.setParams({
            'searchKey' : '%',
            'selectedProcessId' : process,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            console.log('returnValue '+returnValue);
            if( component.isValid() && state ==='SUCCESS'){
                if(returnValue.length === 1){
                    component.set('v.defaultLocation',returnValue[0]);
                    component.set('v.disableLocation',true);
                    this.findInitialAreas(component, returnValue[0]);
                }
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);   
    },
    
    
    validateServerSideMessage: function(component) {
        
        var action = component.get("c.getServerSideMessage");
        
        action.setCallback(this, function(a) {
            // Retrieve Response Object
            var response = a.getReturnValue();
            var state = a.getState();
            if (state ==='SUCCESS') {
                // Success completion
                if(response!==''){
                    component.set('v.state', 5);
                    component.set('v.dmlMessage', response);
                    component.set('v.dmlStatus', false);
                }      
            }
        })      
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
                component.set('v.defaultAreas',returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);   
        
    },
    
    
})