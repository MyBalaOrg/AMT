/**
*————————————————————————————————————————————————————
* @Name             IncidentsTrigger
* @Author           Duy Tran
* @Created Date     06-05-2017
* @Used By          Incidents__c DML operation
*————————————————————————————————————————————————————
* @Description
* Check custom settings for Bypass switches and skip the trigger process if switch is turned off
* 
*————————————————————————————————————————————————————
* @Changes
*
**/
trigger IncidentsTrigger on Incidents__c (after delete, after insert, after update, before delete, before insert, before update) {
    //if (Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId()).IncidentsTrigger__c) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if (bts == null || !bts.IncidentsTrigger__c) {
        new IncidentsTriggerHandler().process();
    }
}