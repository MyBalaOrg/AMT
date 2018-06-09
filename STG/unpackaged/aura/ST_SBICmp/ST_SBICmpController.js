({
    doInit : function(component,event,helper) {
        helper.setFindingBehaviorOptions(component,event);
    },
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used to set Risk and Safe value for each SBI
	*				to be used for step 3
	*-------------------------------------------------------------------------------------------
	**/
    radioClicked : function(component, event, helper){
        /*
        var clickedRadio =event.getSource();	
        var index = clickedRadio.get('v.value');
        var name = clickedRadio.get('v.name');
        var itemLabel = clickedRadio.get('v.label');
        
        var sbiList = component.get('v.sbiList');
        var sbi = sbiList[index];
        
        if(itemLabel === 'Safe' && sbi.Safe !==true){
            sbi.Safe = true;
            sbi.Risk = false;
        } else if(itemLabel === 'At Risk' && sbi.Risk !==true){
            sbi.Safe = false;
            sbi.Risk = true;
        } else if((itemLabel === 'Not Observed')){
            sbi.Safe = false;
            sbi.Risk = false;
        }
        
        component.set('v.sbiList', sbiList);
      */
        
    },
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used to display a modal when the description icon is clicked				
	*-------------------------------------------------------------------------------------------
	**/
    showDescInfo : function(component, event, helper){
        event.preventDefault();
        var title = event.target.title;
        var description = event.target.getAttribute('rel')
        
        component.set('v.modalTitle',title);		
        component.set('v.modalDescription',description); 
        
        helper.showModal(component,true);
    },
    
    afterScriptsLoaded :function(component, event, helper){
        console.log('script loaded');
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used to hide the modal when the description icon is clicked				
	*-------------------------------------------------------------------------------------------
	**/
    cancelModal : function(component, event, helper){
        helper.showModal(component,false);
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used when the next button is pressed				
	*-------------------------------------------------------------------------------------------
	**/
    nextButtonClicked : function( component, event, helper){
        
        console.log("next Button Clicked");
        console.log("NEXT BUTTON "+component.find("ST_SBIcmp_next").get("v.disabled"));
        var sbiList = component.get('v.sbiList');
        var state = component.get('v.state');
        var nextButton = component.find("ST_SBIcmp_next");
        var numberOfSelectedSBI ;
        var newSelectedRiskSBI = [];
        var newSelectedSafeSBI = [];
        
        if(state === 2){
            
            //nextButton.set("v.disabled",true);
            var newState = state+1;
            for(var i in sbiList){
                var SBI = sbiList[i];
                if(SBI.Risk === true){
                    newSelectedRiskSBI.push(SBI);
                } else if(SBI.Safe === true){
                    newSelectedSafeSBI.push(SBI);
                }
            }
            numberOfSelectedSBI =newSelectedRiskSBI.length + newSelectedSafeSBI.length;
            
            console.log('risk array length '+newSelectedRiskSBI.length);
            console.log('safe array length '+newSelectedSafeSBI.length);
            
            if(numberOfSelectedSBI >0){
                var selectedRiskSBIs = helper.populateRiskArr(component, newSelectedRiskSBI, newSelectedSafeSBI);
                var selectedSafeSBIs = helper.populateSafeArr (component, newSelectedSafeSBI, newSelectedRiskSBI);
                // event call to update state to 3
                var mainCmpEvt = component.getEvent('ST_ObservationSubmissionEvt');
                mainCmpEvt.setParams({'state' : newState, 
                                      'initialRiskSBIs' : selectedRiskSBIs , 
                                      'selectedSafeSBIs' : selectedSafeSBIs 
                                     });
                mainCmpEvt.fire();
            }else{
                component.set('v.modalTitle','Error');		
                component.set('v.modalDescription','Please select at least one Safety Behavior Item.'); 
                helper.showModal(component,true);
            }
        } else if(state === 3){
            
            helper.callFindingCmp(component);
            
        }
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used when the back button is pressed, set the state to minus 1				
	*-------------------------------------------------------------------------------------------
	**/
    backButtonClicked : function (component, event, helper){
        var state = component.get('v.state');
        var newState = state-1;
        var nextButton = component.find("ST_SBIcmp_next");
        
        if(newState === 2 || newState === 1){
            var mainCmpEvt = component.getEvent('ST_ObservationSubmissionEvt');
            mainCmpEvt.setParams({'state' : newState});
            mainCmpEvt.fire();
            component.set('v.finalRiskSBI',[]);
        } else{
            console.log('New state is '+newState+ ' and is out of bound');
            console.log('Only state allowed is 2');
        }
    },
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used when the cancel button is pressed, brings the user to the observation object home page				
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
	*@description: function called by the ST_RiskSBIEvt	to populate the finalRiskSBI attribute and got to state 4		
	*-------------------------------------------------------------------------------------------
	**/
    receiveRiskSBI : function(component, event, helper){
        var params = event.getParams();
        var riskSBI = params.atRiskSBI;
        
        var selectedRiskSBI = component.get('v.selectedRiskSBI');
        var finalRiskSBI = component.get('v.finalRiskSBI');
        var areAllFindingsChecked = component.get("v.areAllFindingsChecked");
        var nextButton = component.find("ST_SBIcmp_next");
        nextButton.set("v.disabled",false);
        if(riskSBI !== undefined){
            if(finalRiskSBI.length === 0){
                finalRiskSBI.push(riskSBI);
            } else{
                for(var i=0 ; i<finalRiskSBI.length; i++){
                    var tempSBI = finalRiskSBI[i];
                    if(tempSBI.Id === riskSBI.Id){
                        finalRiskSBI.splice(i,1);
                        //finalRiskSBI.push(riskSBI);
                    }
                    
                }
                finalRiskSBI.push(riskSBI);
            }
            
            
            component.set('v.finalRiskSBI', finalRiskSBI);
            
            var continueToStageFour = true;
            
            //verify that we have the same amount of SBI from state 3 as the ones selected in state 2
            // if so call helper fct
            if(selectedRiskSBI.length === finalRiskSBI.length){
                //revalidate the findings
                for(var i=0;i<finalRiskSBI.length;i++) {
                    var findings = finalRiskSBI[i].Findings__r;
                    for(var j=0;j<findings.length;j++) {
                        var finding = findings[j];
                        if(finding !== undefined) {
                            if(finding.isFindingValid === false) {
                                continueToStageFour = false;
                                break;
                            }
                        }
                    }
                }
                if(continueToStageFour)                
                    helper.goToStateFour(component, event, finalRiskSBI);
            }
            
        }
        
    },
    
    enableNextButton : function(component,event,helper) {
        var params = event.getParam('arguments');
        var param = params.param;
        if(param === true) {
            var nextButton = component.find("ST_SBIcmp_next");
            nextButton.set("v.disabled",false);
            
        }
    },
    
    createSafe : function(component, event, helper) { // label elements safe with class of safe-selected
		
        var sbiList = component.get("v.sbiList");
        var index = event.target.value;
        
        var sbi = sbiList[index];
        
        if(event.target.classList.contains("selected-safe")) {
            event.target.className = '';
            sbi.Safe = false;
            sbi.Risk = false;
           
        } else {
            sbi.Safe = true;
            sbi.Risk = false;
            event.target.className += 'selected-safe';
            
        }
        
        var elem = event.target.id;
        var riskId = elem.replace("safe","risk");
        
        var riskItem = document.getElementById(riskId);
        console.log(component.find(riskId));
       // riskItem.value = false;
        $A.util.removeClass(riskItem, "selected-risk");
        // application will look for items with these classnames and add them for an array to be used in descriptions or state 3
    	
    
    },
    createRisk : function(component, event, helper) { // label elements safe with class of selected-risk
		
        var sbiList = component.get("v.sbiList");
        var index = event.target.value;
		var sbi = sbiList[index];
       
       
       
        if(event.target.classList.contains("selected-risk")) {
            event.target.className = '';
            sbi.Safe = false;
            sbi.Risk = false;
    
        } else {
            
            sbi.Risk = true;
            sbi.Safe = false;
            
            event.target.className += 'selected-risk';
            
        }
        
        var elem = event.target.id;
        var safeId = elem.replace("risk","safe");
        
        var safeItem = document.getElementById(safeId);
       
        $A.util.removeClass(safeItem, "selected-safe");
        // application will look for items with these classnames and add them for an array to be used in descriptions or state 3     
    	
    
    },
    
})