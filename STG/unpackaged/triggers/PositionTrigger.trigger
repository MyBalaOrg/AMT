trigger PositionTrigger on Position__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    String ErrorMessage;
    //Execute trigger if bypass settings are turned off
	if (!RevSys_OrgSettingsUtil.isPositionTriggerBypassEnabled()) {    
        new RevSys_PositionTriggerHandler().process();  
    	errorMessage = PositionStaticUtility.TriggerErrorMessage;  
    }   
    
    if(errorMessage != null) { 
    	trigger.new[0].addError(errorMessage); 
    }

}