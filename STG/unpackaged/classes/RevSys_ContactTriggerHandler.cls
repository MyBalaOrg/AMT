/**
*___________________________________________________
*@Name: RevSys_ContactTriggerHandler
*@Author: Colin Caldwell
*@Created: Date: 01/26/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Contact Trigger Handler for Review Systems Records 
* This class extends the Trigger Handler and invokes the Handler for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_ContactTriggerHandler extends TriggerHandler {

    public static Boolean DoFailTest = FALSE;
    
    public override void afterInsert() {
        ContactStaticUtility.TriggerErrorMessage 
            = RevSys_ContactHelper.establishTargets(newList,RevSys_StaticUtility.OCCUPATION); 
            //ETR-731 - Changes
           
        if(Test.isRunningTest() && DoFailTest) {
            ContactStaticUtility.TriggerErrorMessage = 'Error' ;
        }
        
    }
    
    public override void afterUpdate() {
        ContactStaticUtility.TriggerErrorMessage 
            = RevSys_ContactHelper.establishTargets(newList,RevSys_StaticUtility.OCCUPATION); 
        
    }
    
    public override void beforeInsert() {
        
        String errMsg; 
        
        RevSys_ContactHelper.defaultFieldValue(newList); 
        errMsg = Revsys_ContactHelper.checkToUpdateSpartnContactWithPositionInfo(newList);
        
        ContactStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg); 
    }
    
    public override void beforeUpdate(){
        RevSys_ContactHelper.defaultFieldValue(newList); 
    }
}