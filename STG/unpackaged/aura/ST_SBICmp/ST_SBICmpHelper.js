({

	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used to to populate the selectedRiskSBI attribute
	*@param    newSelectedRiskSBI    represent the new list to be used to populate selectedRiskSBI				
	*-------------------------------------------------------------------------------------------
	**/
	populateRiskArr : function(component, newSelectedRiskSBI, newSelectedSafeSBI){

		if(newSelectedRiskSBI.length >0){
			var selectedRiskSBI = component.get('v.selectedRiskSBI');
			var finalSBI = [];
			for (var i in newSelectedRiskSBI) {
				var newSBI = newSelectedRiskSBI[i];
				var oldSBI = {Id :'',
							Findings__r : undefined,
							};

				for(var y in selectedRiskSBI){
					var tempSBI = selectedRiskSBI[y];
					if(tempSBI.Id === newSBI.Id){
						oldSBI = tempSBI;
					}/*else{
						
						oldSBI.Findings__r = undefined;
					}*/
				}
				if(oldSBI !== undefined && oldSBI.Findings__r !== undefined){
					newSBI.Findings__r = oldSBI.Findings__r; 
				} else{
                    
					var newFinding = this.generateFinding(component, newSBI.Id, 'Risk');
					var findingList =[];
					findingList.push(newFinding	);
					newSBI.Findings__r = findingList;
                    
				}

				finalSBI.push(newSBI);
			}
		component.set('v.selectedRiskSBI', finalSBI);
		return finalSBI;

		} else{
			var emptyArr = [];
			component.set('v.selectedRiskSBI', emptyArr);
		return emptyArr;
		}
	},

	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used to to populate the selectedSafeSBI attribute
	*@param    newSelectedSafeSBI    represent the new list to be used to populate selectedSafeSBI				
	*-------------------------------------------------------------------------------------------
	**/
	populateSafeArr : function(component, newSelectedSafeSBI, newSelectedRiskSBI){
		if(newSelectedSafeSBI.length >0){
			var selectedSafeSBI = component.get('v.selectedSafeSBI');
			var finalSBI = [];
			for (var i in newSelectedSafeSBI) {
				var newSBI = newSelectedSafeSBI[i];
				var oldSBI;

				for(var y in selectedSafeSBI){
					var tempSBI = selectedSafeSBI[y];
					if(tempSBI.Id === newSBI.Id){
						oldSBI = tempSBI;
					}
				}

				if(oldSBI !== undefined && oldSBI.Findings__r !== undefined){

					newSBI.Findings__r = oldSBI.Findings__r; 

				} else{
					var newFinding = this.generateFinding(component, newSBI.Id, 'Safe');
					var findingList =[];
					findingList.push(newFinding	);
					newSBI.Findings__r = findingList;
				}
				finalSBI.push(newSBI);
			}
		component.set('v.selectedSafeSBI', finalSBI);

		return finalSBI;
		} else{
			var emptyArr = [];
			component.set('v.selectedSafeSBI', emptyArr);
		return emptyArr;
		}
	},

	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used to display or hide athe modal	
	*@param:    isShown    param used to decide if modal needs to be shown or not			
	*-------------------------------------------------------------------------------------------
	**/
	showModal : function(component, isShown){
		var cmpTarget1 = component.find('modal-parent');
		var cmpTarget2 = component.find('modal-backdrop');
		if(isShown === true) {
     		$A.util.addClass(cmpTarget1, 'slds-fade-in-open');
			$A.util.addClass(cmpTarget2, 'slds-backdrop--open');         
        } else {
     		$A.util.removeClass(cmpTarget1, 'slds-fade-in-open');
			$A.util.removeClass(cmpTarget2, 'slds-backdrop--open');            
        }  
	},

	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used generate a blank Finding record
	*param    sbiId    		represent the Id of teh SBI for which we are creating a child finding
	*param    riskOrSafe    represent f the SBi is Safe or At Risk 			
	*-------------------------------------------------------------------------------------------
	**/
	generateFinding : function(component, sbiId, riskOrSafe ){

		var tempId = sbiId+'-0';

		var finding = {sobjectType: 'Finding__c',
                        //Id:tempId,
                        SBI_Name__c: sbiId,
                        Behavior__c:'',
                        While__c:'',
                        Was__c:'',
                        Because__c:'',
                        Solution__c:'',
                        Try__c:'',
                        Safe_Checkbox__c:'',
                        At_Risk_Checkbox__c:'',
                       isFindingValid:false,
                        };
          
        if(riskOrSafe ==='Risk'){
        	finding.Safe_Checkbox__c = false;
            finding.At_Risk_Checkbox__c = true;
        } else if(riskOrSafe ==='Safe'){
        	finding.Safe_Checkbox__c = true;
            finding.At_Risk_Checkbox__c = false;
        } else{
        	console.log('The SBI is neither at risk or safe '+riskOrSafe);
        }
        return finding;
        
	},

	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used to tell ST_RiskFindingCmp that we need to retrieve the finding records it holds
	*-------------------------------------------------------------------------------------------
	**/
	callFindingCmp : function(component){
		var selectedRiskSBI = component.get('v.selectedRiskSBI');

		if(selectedRiskSBI.length !== 0){
			var riskCmps = component.find('ST_RiskFindingCmp');
			if(riskCmps.length === undefined){
				riskCmps.getFindings(true);
			} else{
				for(var i = 0; i<riskCmps.length ; i++){
					var riskCmp = riskCmps[i];
					riskCmp.getFindings(true);
				}
               
                
			}
		} else{
			var newState = 4;
			var mainCmpEvt = component.getEvent('ST_ObservationSubmissionEvt');

			mainCmpEvt.setParams({'state' : newState, });
			mainCmpEvt.fire();
		}
	},

	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used after we validated that we have all the at-risk SBI and to go to state 4
	*-------------------------------------------------------------------------------------------
	**/
	goToStateFour : function(component, event, finalRiskSBI){

		var newState = component.get('v.state');
		var selectedRiskSBIs = finalRiskSBI;
		if(newState === 3) newState +=1;
		var mainCmpEvt = component.getEvent('ST_ObservationSubmissionEvt');

		mainCmpEvt.setParams({'state' : newState, 
							  'selectedRiskSBIs' : selectedRiskSBIs,
							});
		mainCmpEvt.fire();
	},
    
    setFindingBehaviorOptions : function(component,event) {
        console.log("In setFindingBehave");
        var action = component.get('c.getFindingBehavePickval');
        
        
        
        action.setCallback(this, function(response){
            var state = response.getState();
            var returnValue = response.getReturnValue();
            //console.log(returnValue);
            if( component.isValid() && state ==='SUCCESS'){
                component.set('v.findingBehaviorOptions', returnValue);
            }else{
                console.log('Error calling server controller');
            }
            
        });
        
        $A.enqueueAction(action);
    },
})