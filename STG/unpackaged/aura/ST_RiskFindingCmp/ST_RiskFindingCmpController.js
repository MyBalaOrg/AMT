({
	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used to assign componentSBI on init		
	*-------------------------------------------------------------------------------------------
	**/
	doInit : function(component, event, helper){
		var selectedSBI = component.get('v.selectedSBI');
        console.log('selectedSBI');
		helper.assignSBI(component, selectedSBI);
       
	},

	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used to assign componentSBI if selectedSBI changes	
	*-------------------------------------------------------------------------------------------
	**/
	selectedSBIChange :function(component, event, helper){
		var selectedSBI = component.get('v.selectedSBI');
        console.log('selectedSBI');
		helper.assignSBI(component, selectedSBI);
	},

	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used to display or hide sections of the page			
	*-------------------------------------------------------------------------------------------
	**/
	toggleDesc : function(component, event, helper) {

		var isExpanded = component.get('v.isExpanded');  
        if(isExpanded === true) {
            component.set("v.isExpanded", false);
        } else if(isExpanded === false) {
            component.set("v.isExpanded", true);
        }
	},

	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used to add a finding to the SBI		
	*-------------------------------------------------------------------------------------------
	**/
	addFinding : function(component, event, helper){

		var SBI = component.get('v.componentSBI');
		var sbiId = SBI.Id;
		var findings = SBI.Findings__r;
		var findingArrayLength = findings.length;
		var newFinding = helper.generateFinding(component, sbiId, findingArrayLength);
		findings.push(newFinding);
		SBI.Findings__r = findings;

		component.set('v.componentSBI', SBI);

	},

	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used to remove a finding to the SBI		
	*-------------------------------------------------------------------------------------------
	**/
	removeFinding : function(component, event, helper){

		var target = event.getSource();
		var index = target.get('v.name');
		var SBI = component.get('v.componentSBI');
		var findings = SBI.Findings__r;
		
		findings.splice(index, 1);
		SBI.Findings__r = findings;

		component.set('v.componentSBI', SBI);
	},
	/**
	*-------------------------------------------------------------------------------------------
	*@description: function used to validate and retrieve all findings.
	*-------------------------------------------------------------------------------------------
	**/
	getFindings : function(component, event, helper){

		var params = event.getParam('arguments');
		var getFinding = params.getFinding;

		//function to validate ALL the input fields.
        var allValid = component.find('inputField').reduce(function (validSoFar, inputCmp) {
            	inputCmp.showHelpMessageIfInvalid();
            	return validSoFar && inputCmp.get('v.validity').valid;
         }, true);

		if(getFinding === true){
			var SBI = component.get('v.componentSBI');
			var riskFindings__r = SBI.Findings__r;
			var validSBI = true;

			for( var i=0; i< riskFindings__r.length; i++){
				var riskFinding = riskFindings__r[i];
				if(riskFinding !== undefined){
					var validFinding = helper.validateFinding(riskFinding);
					if(validFinding === false){
						validSBI = false;
					} else riskFinding.isFindingValid = true;

				}
			}
			if(validSBI === true && allValid === true){
				helper.callSBIEvent(component, event, SBI);
			}
		}

	},


})