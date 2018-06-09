/*
Author: Raj Kumar Pandy
Decsription: The Utility Class for fetching the Custom Setting field values. Used in CaseTriggerHandler apex class
*/
public class ODILR_OrgSettingsUtil {
    public static Boolean caseTriggerFlag = True;
    
    //Method for the fetching the Custom Setting that inactivates the Case Trigger
    public static Boolean isCaseTriggerInactive(){
        ODILR_Hierarchy_Setting__c settings = ODILR_Hierarchy_Setting__c.getInstance();
        return settings.ODILR_Inactivate_CaseTriggerHandler__c;        
   }
 
	//Method for the fetching the Custom Setting that inactivates the POST Call to MuleSoft 
    public static Boolean isDocumentumCalloutInactive() {
        caseTriggerFlag = false;
		ODILR_Hierarchy_Setting__c settings = ODILR_Hierarchy_Setting__c.getInstance();
		Return settings.ODILR_Inactivate_Documentum_Callout__c;
   }
    //Method for the fetching the Custom Setting that inactivates the  ViolationsTrigger
    public static Boolean isViolationsTriggerInactive(){
        caseTriggerFlag = false;
        ODILR_Hierarchy_Setting__c settings = ODILR_Hierarchy_Setting__c.getInstance();
        return settings.ODILR_Inactivate_ViolationsTrigger__c;        
   }
    //Method for the fetching the Custom Setting that inactivates the DisciplineActionsTrigger
    public static Boolean isDisciplineActionsTriggerInactive(){
        ODILR_Hierarchy_Setting__c settings = ODILR_Hierarchy_Setting__c.getInstance();
        return settings.ODILR_Inactivate_DisciplineActionTrigger__c;        
   }
}