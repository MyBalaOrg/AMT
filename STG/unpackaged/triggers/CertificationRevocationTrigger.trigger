trigger CertificationRevocationTrigger on CertificationRevocation__c (after insert,before update, after update,before insert, after delete) {

	 String ErrorMessage;

	 //Execute trigger if bypass settings are turned off
    if (!RevSys_OrgSettingsUtil.isCertificationRevocationTriggerBypassEnabled()&& 
        StaticUtils.hasAccess(label.SPARTN_User)) {      

     	new RevSys_CertificationRevocationHandler().process();  
        errorMessage = CertificationRevocationStaticUtility.TriggerErrorMessage;  
        
    }   
    
    if(errorMessage != null) { 
        trigger.new[0].addError(errorMessage); 
    }

}