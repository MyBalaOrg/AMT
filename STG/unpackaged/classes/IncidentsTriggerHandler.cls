public class IncidentsTriggerHandler extends TriggerHandler{
    EIS_IncidentsTriggerHelper itHelper = new EIS_IncidentsTriggerHelper();
    private Boolean hasAccess = EIS_StaticUtils.hasAccess();
	public override void afterInsert() {
        if (hasAccess) {
            itHelper.sendEmailToSiteContactList_AfterInsert(newList);
        }
    }
}