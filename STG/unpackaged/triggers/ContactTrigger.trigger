// ****************************************************************************************************************
// Trigger: Contact Trigger 
// Author:  Sarang Padhye, Deloitte Digital
// Date:    Mar 22, 2017
// Description: Master Trigger to handle all contact related functionality.
//
// Modifications: 
// 1.00: Created
// 2.00: Hemanth Modified to include Review Systems Functionality
// 3.00: Colin Modified to include new Review Systems Trigger Handler 
trigger ContactTrigger on Contact (after delete, after insert, after update, 
before delete, before insert, before update) {
    String ErrorMessage; 
    new ContactTriggerHandler().process();
    
     if (!RevSys_OrgSettingsUtil.isContactTriggerBypassEnabled() && 
        StaticUtils.hasAccess(label.SPARTN_User)) {    

        new RevSys_ContactTriggerHandler().process(); 
        errorMessage  = ContactStaticUtility.TriggerErrorMessage;  
        errorMessage += ObservationStaticUtility.TriggerErrorMessage; 
        errorMessage  = StringUtility.cleanupMessage(errorMessage); 
    }  

    if(errorMessage != null) { 
        trigger.new[0].addError(errorMessage); 
    } 
   
}