public class CorrectiveActionTriggerHandler extends TriggerHandler {
	private EIS_CorrectiveActionTriggerHelper catHelper = new EIS_CorrectiveActionTriggerHelper();
    private Boolean hasAccess = EIS_StaticUtils.hasAccess();
    public override void afterInsert() {
        if (hasAccess) {
        	catHelper.updateInspectionCorrectiveActionCount_AfterInsert(newList);
        }
    }
    
    public override void afterUpdate() {
        if (hasAccess) {
        	catHelper.updateInspectionCorrectiveActionCount_AfterUpdate(oldList, newList);
        }
    }
       
    public override void afterDelete() {
        if (hasAccess) {
    		catHelper.updateInspectionCorrectiveActionCount_AfterDelete(oldList);
        }
    }
}