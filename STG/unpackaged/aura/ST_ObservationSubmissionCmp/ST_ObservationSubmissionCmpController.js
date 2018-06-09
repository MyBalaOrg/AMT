({
	/**
	*-------------------------------------------------------------------------------------------
	*@Description: Function to retrieve initial data for Observation submission
	*-------------------------------------------------------------------------------------------
	**/
	doInit : function(component, event, helper) {
		console.log('ST_ObservationSubmissionCmp init started');
        
        helper.getUserProcesses(component); // gets user info for ID and Process
	},

	/**
	*-------------------------------------------------------------------------------------------
	*@Description: Function to retrieve information sent by the ST_ObservationSubmissionEvt event
	*-------------------------------------------------------------------------------------------
	**/
	getVariables :function(component, event, helper){
		console.log('received event '+event.getName() );
		var params = event.getParams();
		var state = params.state;
		var obs = params.obs;
		var SBI = params.SBI;
		var initialRiskSBIs = params.initialRiskSBIs;
		var selectedSafeSBIs = params.selectedSafeSBIs;
		var selectedRiskSBIs = params.selectedRiskSBIs;
		var currentState = component.get('v.state');
		var currentObs = component.get('v.obs');
		
		//set state and percentage attributes
		if(state !== undefined){
			if(state === 1){	
				component.set('v.percentage','0%');
				component.set('v.state', state);
			}else if (state === 2){
				component.set('v.percentage', '33%');
				component.set('v.state', state);
			}else if (state === 3){
				component.set('v.percentage','66%');
				component.set('v.state', state);
			}else if (state === 4){
				component.set('v.percentage','100%');
				component.set('v.state', state);
			}else if (state === 5){
				component.set('v.percentage','100%');			
			}
		}
        
        if(state ===3 && currentState===4) {
            var childComponent = component.find('ST_SBICmp');
			childComponent.backButtonPress(true);
        }
		// assign the observation
		if(obs !== undefined){
			component.set('v.obs', obs);
		}
		// used to call the ST_SBICmp to tell it to retrieve departments
		
		if(state === 2 && obs !== undefined && obs.Department__c !== undefined && obs.Department__c !== currentObs.Department__c){
			helper.callSBICmp(component, state, obs.Department__c);
		}

		// set the final initial list of at-risk SBI and the final list of safe SBI from state 2 
		if(currentState === 2 && state === 3 && initialRiskSBIs !== undefined && selectedSafeSBIs !== undefined){
			component.set('v.initialRiskSBIs', initialRiskSBIs);
			component.set('v.selectedSafeSBIs', selectedSafeSBIs);
		}

		// set the final list of at-risk SBI
		if(currentState === 3 && state === 4 && selectedRiskSBIs !== undefined && selectedRiskSBIs.length !== 0){
			component.set('v.selectedRiskSBIs', selectedRiskSBIs);
		}
		// call helper function to submit to the database
		if(currentState === 4 && state === 5){
			helper.submitToDB(component);
		}
	},
	/**
	*-------------------------------------------------------------------------------------------
	*@Description: Function to go to Observation__c object page
	*-------------------------------------------------------------------------------------------
	**/
	goToStandardPage :function (component, event, helper){

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
	*@Description: Function to go to the VF page that contains this app
	*-------------------------------------------------------------------------------------------
	**/
	goToObservationApp : function(component, event, helper){
		if(typeof sforce !== 'undefined'){
	        try{
	        	var urlEvent = $A.get('e.force:navigateToURL');
	            urlEvent.setParams({
	                	"url": '/apex/ST_ObservationSubmissionPage'
	            });
	        	urlEvent.fire();

	        }catch(err1){
	            console.log("Something went wrong: ", err1.message);   
	        }
	    }else{
	        try{
	            window.open ('/apex/ST_ObservationSubmissionPage','_parent');}
	        catch(err3){
	            console.log("Something went wrong: ",err3.message);
	        }     
        }
	},

	validateServerSideMessage: function(component, event, helper) {

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
            	}      
            }
         })      
        $A.enqueueAction(action);
    },
})