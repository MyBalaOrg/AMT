trigger OccupationRequirementTrigger on OccupationRequirement__c (before insert, before update) {
    
    String ErrorMessage;
    
    //Execute trigger if bypass settings are turned off
    if (!RevSys_OrgSettingsUtil.isOccupationRequirementTriggerBypassEnabled()&& 
        StaticUtils.hasAccess(label.SPARTN_User)) {    

    	new RevSys_OccRequirementTriggerHandler().process();  
    	errorMessage = OccupationRequirementStaticUtility.TriggerErrorMessage;  
    }   
    
    if(errorMessage != null) { 
    	trigger.new[0].addError(errorMessage); 
    }


}