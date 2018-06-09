/**
*————————————————————————————————————————————————————
* @Name             WasteEmissionsTrigger
* @Author           Duy Tran
* @Created Date     06-05-2017
* @Used By          Waste_Emissions__c DML operation
*————————————————————————————————————————————————————
* @Description
* Check custom settings for Bypass switches and skip the trigger process if switch is turned off
* 
*————————————————————————————————————————————————————
* @Changes
*
**/
trigger WasteEmissionsTrigger on Waste_Emissions__c (after delete, after insert, after update, before delete, before insert, before update) {
    //if (Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId()).WasteEmissionsTrigger__c) {
    Bypass_Trigger_Settings__c bts = Bypass_Trigger_Settings__c.getInstance(UserInfo.getUserId());
    if (bts == null || !bts.WasteEmissionsTrigger__c) {
        new WasteEmissionsTriggerHandler().process();
    }
}