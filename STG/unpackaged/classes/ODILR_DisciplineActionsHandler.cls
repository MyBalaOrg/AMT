public class ODILR_DisciplineActionsHandler extends TriggerHandler{
    public override void beforeInsert() {
        if(!ODILR_OrgSettingsUtil.isDisciplineActionsTriggerInactive())
        {
            dlrs.RollupService.triggerHandler(Disciplinary_Action__c.SObjectType);
        }
    }
    public override void beforeUpdate() {
         if(!ODILR_OrgSettingsUtil.isDisciplineActionsTriggerInactive())
        {
            dlrs.RollupService.triggerHandler(Disciplinary_Action__c.SObjectType);
        }
    }
    public override void beforeDelete() {
         if(!ODILR_OrgSettingsUtil.isDisciplineActionsTriggerInactive())
        {
            dlrs.RollupService.triggerHandler(Disciplinary_Action__c.SObjectType);
        }
    }
    public override void afterInsert() {
            
         if(!ODILR_OrgSettingsUtil.isDisciplineActionsTriggerInactive())
        {
            dlrs.RollupService.triggerHandler(Disciplinary_Action__c.SObjectType);  
             ODILR_DisciplinaryActionsTriggerHelper.UpdateCaseDisciplinaryActionsList(newList); 
        }
    }
    public override void afterUpdate() {
         if(!ODILR_OrgSettingsUtil.isDisciplineActionsTriggerInactive())
        {
            dlrs.RollupService.triggerHandler(Disciplinary_Action__c.SObjectType);
             ODILR_DisciplinaryActionsTriggerHelper.UpdateCaseDisciplinaryActionsList(newList);   
        }
    }
    public override void afterDelete() {
         if(!ODILR_OrgSettingsUtil.isDisciplineActionsTriggerInactive())
        {
            dlrs.RollupService.triggerHandler(Disciplinary_Action__c.SObjectType);
             ODILR_DisciplinaryActionsTriggerHelper.UpdateCaseDisciplinaryActionsList(oldList);   
        }
    }

}