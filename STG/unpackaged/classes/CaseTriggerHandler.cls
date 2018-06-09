/*
Author: Raj Kumar Pandy
Decsription: The Handler Class for the CaseTrigger and extends the super class TriggerHandler
*/
public class CaseTriggerHandler extends TriggerHandler{
    
    //Method overrides the method in TriggerHandler for before Insert
    public override void beforeInsert() {
        //Checking the custom setting using Utility Class
        if (ODILR_OrgSettingsUtil.caseTriggerFlag && !ODILR_OrgSettingsUtil.isCaseTriggerInactive() && ODILR_CaseTriggerHelper.ContainsODILRCase(newList)) 
        {
            ODILR_CaseTriggerHelper.caseUnionAssignment(newList); 
        }
    }

    //Method overrides the method in TriggerHandler for before Update
    public override void beforeUpdate() {
        //Checking the custom setting using Utility Class
        if (ODILR_OrgSettingsUtil.caseTriggerFlag && !ODILR_OrgSettingsUtil.isCaseTriggerInactive() && ODILR_CaseTriggerHelper.ContainsODILRCase(newList)) 
        {
           ODILR_CaseTriggerHelper.caseUnionAssignment(newList); 
        }   
    }

    //Method overrides the method in TriggerHandler for before Insert
    public override void afterInsert() {
        //Checking the custom setting using Utility Class
        if (ODILR_OrgSettingsUtil.caseTriggerFlag && !ODILR_OrgSettingsUtil.isDocumentumCalloutInactive() && !ODILR_OrgSettingsUtil.isCaseTriggerInactive() && ODILR_CaseTriggerHelper.ContainsODILRCase(newList)) 
        {
            ODILR_MuleSoftAPICall.createJSON(newList);   
        }
    }
}