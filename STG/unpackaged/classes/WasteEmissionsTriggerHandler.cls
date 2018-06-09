/**
*————————————————————————————————————————————————————
* @Name             WasteEmissionsTriggerHandler
* @Author           Duy Tran
* @Created Date     06-05-2017
* @Used By          Waste_Emissions__c DML operation
*————————————————————————————————————————————————————
* @Description
* Call the Waste trigger helper
* 
*————————————————————————————————————————————————————
* @Changes
*
**/
public class WasteEmissionsTriggerHandler extends TriggerHandler{
    private EIS_WasteEmissionsTriggerHelper wetHelper = new EIS_WasteEmissionsTriggerHelper();
	private Boolean hasAccess = StaticUtils.hasAccess(String.valueOf(Label.EIS_Custom_Permission_API_AEPHIS_User));
    public override void afterInsert() {
        if (hasAccess) {
            wetHelper.generateLineItemsForGHG_AfterInsert(newList);
        }
    }
}