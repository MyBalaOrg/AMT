({
    assignSBI : function(component, selectedSBI) {
        component.set('v.componentSBI', selectedSBI);
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used generate a blank Finding record
	*param    sbiId    		represent the Id of the SBI for which we are creating a child finding	
	*-------------------------------------------------------------------------------------------
	**/
    
    generateFinding : function(component, sbiId, findingIdNumber){
        
        var tempId = sbiId+'-'+findingIdNumber;
        
        var finding = {sobjectType: 'Finding__c',
                       //Id:tempId,
                       SBI_Name__c: sbiId,
                       Behavior__c:'',
                       While__c:'',
                       Was__c:'',
                       Because__c:'',
                       Solution__c:'',
                       Try__c:'',
                       Safe_Checkbox__c: false,
                       At_Risk_Checkbox__c: true,
                       isFindingValid:false,
                      };
        
        return finding;   
    },
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used to validate a finding record
	*param    finding    		represent an at-risk finding record the needs to be validated
	*-------------------------------------------------------------------------------------------	
	**/
    validateFinding : function(finding){
        var validFinding = true;
        
        if($A.util.isEmpty(finding.Behavior__c)){
            validFinding = false;
        }
        if($A.util.isEmpty(finding.While__c)){
            validFinding = false;
        }
        if($A.util.isEmpty(finding.Was__c)){
            validFinding = false;
        }
        if($A.util.isEmpty(finding.Because__c)){
            validFinding = false;
        }		
        if($A.util.isEmpty(finding.Solution__c)){
            validFinding = false;
        }
        
        return validFinding;
    },
    
    /**
	*-------------------------------------------------------------------------------------------
	*@description: function used to call the ST_RiskSBIEvt and populate the SBI Attribute
	*param    SBI 		SBI record that has been validated
	*-------------------------------------------------------------------------------------------	
	**/
    callSBIEvent : function(component, event, SBI){
        console.log('SBI is validated has all fields populated');
        
        var ST_RiskSBIEvt = component.getEvent('ST_RiskSBIEvt');
        
        ST_RiskSBIEvt.setParams({'atRiskSBI' : SBI});
        
        ST_RiskSBIEvt.fire();
    },
    
    
})