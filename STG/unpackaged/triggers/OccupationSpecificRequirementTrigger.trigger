trigger OccupationSpecificRequirementTrigger on OccupationSpecificRequirement__c (before insert, before update, after insert, after update)
{ 
    String ErrorMessage;
    
    //Execute trigger if bypass settings are turned off
    if (!RevSys_OrgSettingsUtil.isOccupationCertificationTriggerBypassEnabled() && 
        StaticUtils.hasAccess(label.SPARTN_User)) {    
 
        new RevSys_OccupationSpecificReqHandler().process();  
        errorMessage = OccupationSpecificReqStaticUtility.TriggerErrorMessage;  
    }   
    
    if(errorMessage != null) { 
        trigger.new[0].addError(errorMessage); 
    }

}