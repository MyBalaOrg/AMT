/**
*————————————————————————————————————————————————————
* @Name             TaskTrigger
* @Author           Duy Tran
* @Created Date     06-05-2017
* @Used By          Task DML operation
*————————————————————————————————————————————————————
* @Description
* Check custom settings for Bypass switches and skip the trigger process if switch is turned off
* 
*————————————————————————————————————————————————————
* @Changes
*
**/
trigger TaskTrigger on Task (after delete, after insert, after update, before delete, before insert, before update) {
    //if (Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId()).TaskTrigger__c) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if (bts == null || !bts.TaskTrigger__c) {
        new TaskTriggerHandler().process();
        dlrs.RollupService.triggerHandler(Task.SObjectType);
    }
}