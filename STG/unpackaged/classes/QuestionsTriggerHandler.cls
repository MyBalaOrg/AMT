public class QuestionsTriggerHandler extends TriggerHandler {
	private EIS_QuestionsTriggerHelper qtHelper = new EIS_QuestionsTriggerHelper();
	private Boolean hasAccess = EIS_StaticUtils.hasAccess();
    public override void afterInsert() {
        if (hasAccess) {
            qtHelper.updateInspections_AfterInsert(newList);
        }
    }
	
    public override void afterDelete() {
        if (hasAccess) {
    		qtHelper.updateInspections_AfterDelete(oldList);
        }
    }
    
    public override void afterUpdate() {
        if (hasAccess) {
    		qtHelper.updateInspections_AfterUpdate(oldList, newList);
        }
    }
}