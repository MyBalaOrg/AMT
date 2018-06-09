/**
*___________________________________________________
*@Name: RevSys_OccRequirementTriggerHandler
*@Author: Colin Caldwell
*@Created: Date: 01/25/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Occupation Requirement Trigger Handler for Review Systems Records 
* This class extends the Trigger Handler and invokes helper and utility classes 
* for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_OccRequirementTriggerHandler extends Triggerhandler {
public static Boolean DoFailTest = FALSE; 

    public override void beforeInsert() {
        String errorMessage; 
        RevSys_OccupationRequirementHelper.defaultObsName(newList);  
        errorMessage  = RevSys_OccupationRequirementHelper.deactivateChild(newList);  
        errorMessage += Revsys_OccupationRequirementValidation.checkDupeName(newList, null);
        OccupationRequirementStaticUtility.TriggerErrorMessage 
                      =StringUtility.cleanupMessage(errorMessage); 
        if(Test.isRunningTest() && DoFailTest) {
            OccupationRequirementStaticUtility.TriggerErrorMessage = 'Error' ;
        }
    }


    public override void beforeUpdate() {
        String errorMessage; 
        RevSys_OccupationRequirementHelper.defaultObsName(newList);  
        errorMessage  = RevSys_OccupationRequirementHelper.deactivateChild(newList);  
        errorMessage += Revsys_OccupationRequirementValidation.checkDupeName(newList, oldMap);
        OccupationRequirementStaticUtility.TriggerErrorMessage 
                      =StringUtility.cleanupMessage(errorMessage);         
     
    }  
}