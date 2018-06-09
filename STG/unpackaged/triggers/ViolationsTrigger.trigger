/*
Author: Raj Kumar Pandy
Description: The Trigger on Violation Object
*/
trigger ViolationsTrigger on Violation__c (before insert, before update, before delete, after insert, after update, after delete) {
        String ErrorMessage;
        try{
            new ODILR_ViolationsHandler().process();

            if (!RevSys_OrgSettingsUtil.isViolationTriggerBypassEnabled() && 
                StaticUtils.hasAccess(label.SPARTN_User)) { 
                   
                  new Revsys_ViolationHandler().process();  
                  errorMessage = ViolationStaticUtility.TriggerErrorMessage;  
            }   
        }
        catch(System.DmlException e){
            trigger.new[0].AddError(e.getDmlMessage(0));
        }
        

}