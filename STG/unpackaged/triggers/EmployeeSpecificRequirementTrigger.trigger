trigger EmployeeSpecificRequirementTrigger on EmployeeSpecificRequirement__c (before insert, after insert,
                                                                              before update, after update)  { 
    String ErrorMessage; 
   
    if (!RevSys_OrgSettingsUtil.isEmployeeSpecificRequirementTriggerBypassEnabled()  && 
        StaticUtils.hasAccess(label.SPARTN_User)) {  
      
            new Revsys_EmployeeSpecificReqHandler().process();  
            errorMessage = EmployeeSpecificRequirementStaticUtility.TriggerErrorMessage;     
     }
                                                                                  
    
    if(errorMessage != null) { 
        trigger.new[0].addError(errorMessage); 
    }
}