trigger EmployeeCertificationTrigger on EmployeeCertification__c (after insert,before update, after update,before insert) {
    
    String ErrorMessage;
    
    //Execute trigger if bypass settings are turned off
    if (!RevSys_OrgSettingsUtil.isEmployeeCertificationTriggerBypassEnabled() && 
        StaticUtils.hasAccess(label.SPARTN_User)) {    
 
        new RevSys_EmpCertificationTriggerHandler().process();  
        errorMessage = EmployeeCertificationStaticUtility.TriggerErrorMessage;  
    }   
    
    if(errorMessage != null) { 
        trigger.new[0].addError(errorMessage); 
    }

}