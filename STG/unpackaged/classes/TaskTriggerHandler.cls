/**
* @Description
* Handler class to handle trigger logic for Task object
*
*————————————————————————————————————————————————————
**/
public class TaskTriggerHandler extends TriggerHandler{
    private EIS_TaskTriggerHelper ttHelper = new EIS_TaskTriggerHelper();
    private Boolean hasAccess = StaticUtils.hasAccess(String.valueOf(Label.EIS_Custom_Permission_API_AEPHIS_User));
    public override void beforeInsert() {
        if (hasAccess) {
            System.debug('TaskTriggerHandler: beforeInsert()');
        	ttHelper.updateTaskEmailFields(newList);
        }
    }
    public override void beforeUpdate() {
        if (hasAccess) {
            System.debug('TaskTriggerHandler: beforeUpdate()');
            ttHelper.updateTaskEmailFields(newList);
            //ttHelper.updateTaskEmailFields_beforeUpdate(newList);
        }
    }
}