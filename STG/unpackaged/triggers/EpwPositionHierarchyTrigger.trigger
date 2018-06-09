trigger EpwPositionHierarchyTrigger on EPW_Position_Hierarchy__c (before insert, after insert, before update,after update) {

	  String ErrorMessage;

	  //Execute trigger if bypass settings are turned off
	   if (!RevSys_OrgSettingsUtil.isPositionHierarchyTriggerBypassEnabled()) {    

    	new RevSys_PositionHierarchyTriggerHandler().process();  
    	errorMessage = PositionHierarchyStaticUtility.TriggerErrorMessage;  
    }   
    
    if(errorMessage != null) { 
    	trigger.new[0].addError(errorMessage); 
    }
}