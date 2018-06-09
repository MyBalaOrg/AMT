trigger EmployeeResultSummaryTrigger on EmployeeResultSummary__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    String ErrorMessage;
    
    //Execute trigger if bypass settings are turned off
    if (!RevSys_OrgSettingsUtil.isEmployeeResultSummaryTriggerBypassEnabled() && 
        StaticUtils.hasAccess(label.SPARTN_User)) {    

        new RevSys_EmpResultSummaryTriggerHandler().process();  
    	errorMessage = EmployeeResultSummaryStaticUtility.TriggerErrorMessage; 
    }   
    
    if(errorMessage != null) { 
    	trigger.new[0].addError(errorMessage); 
    }

}