trigger OccupationCertificationTrigger on OccupationCertification__c (before insert, after insert, before update,after update) {
    
    String ErrorMessage;
    
    //Execute trigger if bypass settings are turned off
    if (!RevSys_OrgSettingsUtil.isOccupationCertificationTriggerBypassEnabled() && 
        StaticUtils.hasAccess(label.SPARTN_User)) {   
 
        new RevSys_OccCertificationTriggerHandler().process();  
    	errorMessage = OccupationCertificationStaticUtility.TriggerErrorMessage;  
    }   
    
    if(errorMessage != null) { 
    	trigger.new[0].addError(errorMessage); 
    }

}