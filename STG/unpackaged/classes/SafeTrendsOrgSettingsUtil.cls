/**************************************************************************************************************/
// SafeTrendsOrgSettingsUtil: Util class to get the Safe Trends Org settings for trigger executions
/**************************************************************************************************************/

public class SafeTrendsOrgSettingsUtil {
   
    public static Boolean isObservationTriggerBypassEnabled(){
        ST_Bypass_Trigger_Settings__c settings = ST_Bypass_Trigger_Settings__c.getInstance();
        return settings.ObservationTrigger__c;        
    }
    
    public static Boolean isFindingTriggerBypassEnabled(){
        ST_Bypass_Trigger_Settings__c settings = ST_Bypass_Trigger_Settings__c.getInstance();
        return settings.FindingTrigger__c;        
    }
    
    public static Boolean isProcessTeamTriggerBypassEnabled(){
        ST_Bypass_Trigger_Settings__c settings = ST_Bypass_Trigger_Settings__c.getInstance();
        return settings.ProcessTeamTrigger__c;        
    }
    
}