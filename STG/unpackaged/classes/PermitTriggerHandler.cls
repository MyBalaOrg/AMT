/**
* @Description
* Handler class to handle trigger logic for Permit object
*
*————————————————————————————————————————————————————
**/
public class PermitTriggerHandler extends TriggerHandler{
    private EIS_PermitTriggerHelper ptHelper = new EIS_PermitTriggerHelper();
    private Boolean hasAccess = StaticUtils.hasAccess(String.valueOf(Label.EIS_Custom_Permission_API_AEPHIS_User));
    public override void afterInsert() {
        if (hasAccess) {
        	ptHelper.sendEmailToSiteContactList(newList);
        }
    }
    
    public override void afterUpdate() {
        if (hasAccess) {
        	ptHelper.sendEmailToSiteContactList(newList);
        }
    }
}