/**
*————————————————————————————————————————————————————
* @Name             QuestionsTrigger
* @Author           Duy Tran
* @Created Date     06-05-2017
* @Used By          Questions__c DML operation
*————————————————————————————————————————————————————
* @Description
* Check custom settings for Bypass switches and skip the trigger process if switch is turned off
* 
*————————————————————————————————————————————————————
* @Changes
*
**/
trigger QuestionsTrigger on Questions__c (after delete, after insert, after update, before delete, before insert, before update) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if (bts == null || !bts.QuestionsTrigger__c) {
        new QuestionsTriggerHandler().process();
    }
}