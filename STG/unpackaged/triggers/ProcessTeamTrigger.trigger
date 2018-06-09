trigger ProcessTeamTrigger on Process_Team__c (after delete, after insert, after update, before delete, before insert, before update) {
    
    //Execute trigger if bypass settings are turned off
    if (!SafeTrendsOrgSettingsUtil.isProcessTeamTriggerBypassEnabled()){
        new ProcessTeamHandler().process();
    }
}