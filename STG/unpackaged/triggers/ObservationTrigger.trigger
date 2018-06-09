trigger ObservationTrigger on Observation__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {  
    
    String ErrorMessage; 

    //Execute trigger if bypass settings are turned off
    if (!SafeTrendsOrgSettingsUtil.isObservationTriggerBypassEnabled()){        
        new ObservationHandler().process();    
    }  

    if (!RevSys_OrgSettingsUtil.isObservationTriggerBypassEnabled() && 
        StaticUtils.hasAccess(label.SPARTN_User)) {

            new RevSys_ObservationTriggerHandler().process();  
    	    errorMessage = ObservationStaticUtility.TriggerErrorMessage;  
    }
	
    if(errorMessage != null) { 
    	trigger.new[0].addError(errorMessage); 
    }
}