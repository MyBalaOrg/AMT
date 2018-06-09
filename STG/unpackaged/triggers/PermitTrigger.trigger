/**
*————————————————————————————————————————————————————
* @Name             PermitTrigger
* @Author           Duy Tran
* @Created Date     06-05-2017
* @Used By          Permit_Plan__c DML operation
*————————————————————————————————————————————————————
* @Description
* Check custom settings for Bypass switches and skip the trigger process if switch is turned off
* 
*————————————————————————————————————————————————————
* @Changes
*
**/
trigger PermitTrigger on Permit_Plan__c (after delete, after insert, after update, before delete, before insert, before update) {
    //if (Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId()).PermitTrigger__c) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if (bts == null || !bts.PermitTrigger__c) {
        new PermitTriggerHandler().process();
        dlrs.RollupService.triggerHandler(Permit_Plan__c.SObjectType);
    }
}