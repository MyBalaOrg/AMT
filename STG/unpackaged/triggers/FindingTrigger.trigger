trigger FindingTrigger on Finding__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    //Execute trigger if bypass settings are turned off
    if (!SafeTrendsOrgSettingsUtil.isFindingTriggerBypassEnabled()){
        //Finding generic handler
        new FindingHandler().process();     
        //Handler from Declarative Lookup Rollup Summaries Tool package
        dlrs.RollupService.triggerHandler(Finding__c.SObjectType);    
    }

    if (!RevSys_OrgSettingsUtil.isFindingTriggerBypassEnabled() && 
        StaticUtils.hasAccess(label.SPARTN_User)) {    

        new RevSys_FindingTriggerHandler().process();	
    }   
   
}