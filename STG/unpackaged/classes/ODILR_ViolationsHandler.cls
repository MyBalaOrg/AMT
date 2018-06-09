/*
Author: Raj Kumar Pandy
Description: The Handler Class for the ViolationsTrigger and extends the super class TriggerHandler
*/
public class ODILR_ViolationsHandler extends TriggerHandler {
    
	//Method overrides the method in TriggerHandler for before Insert
    public override void beforeInsert() {
        if(!ODILR_OrgSettingsUtil.isViolationsTriggerInactive())
        {
         dlrs.RollupService.triggerHandler(Violation__c.SObjectType);   
        }
    }

	//Method overrides the method in TriggerHandler for before Update
    public override void beforeUpdate() {
         if(!ODILR_OrgSettingsUtil.isViolationsTriggerInactive())
        {
            dlrs.RollupService.triggerHandler(Violation__c.SObjectType);
        }
    }

	//Method overrides the method in TriggerHandler for before Delete
    public override void beforeDelete() {
         if(!ODILR_OrgSettingsUtil.isViolationsTriggerInactive())
        {
         dlrs.RollupService.triggerHandler(Violation__c.SObjectType);   
        }
    }

	//Method overrides the method in TriggerHandler for after insert
    public override void afterInsert() {
         if(!ODILR_OrgSettingsUtil.isViolationsTriggerInactive())
        {
            dlrs.RollupService.triggerHandler(Violation__c.SObjectType);
    		ODILR_ViolationTriggerHelper.UpdateCaseViolationList(newList);   
        }
    }

	//Method overrides the method in TriggerHandler for after update
    public override void afterUpdate() {
         if(!ODILR_OrgSettingsUtil.isViolationsTriggerInactive())
        {
         	dlrs.RollupService.triggerHandler(Violation__c.SObjectType);
    		ODILR_ViolationTriggerHelper.UpdateCaseViolationList(newList);
        }
    }

	//Method overrides the method in TriggerHandler for after delete
    public override void afterDelete() {
         if(!ODILR_OrgSettingsUtil.isViolationsTriggerInactive())
        {
         dlrs.RollupService.triggerHandler(Violation__c.SObjectType);
         ODILR_ViolationTriggerHelper.UpdateCaseViolationList(oldList);   
        }
    }

}