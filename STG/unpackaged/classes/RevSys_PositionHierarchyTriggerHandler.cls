/**
*___________________________________________________
*@Name: RevSys_PositionHierarchyTriggerHandler
*@Author: Hemanth Kesapragada
*@Created: Date: 03/14/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Position Hierarchy Trigger Handler for SPARTN Records 
* This class extends the Trigger Handler and invokes the Handler for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* 04-26-2018 Added call to Revsys_PositionHierarchyHelper2.assignTargets() method
**/
public class RevSys_PositionHierarchyTriggerHandler  extends TriggerHandler{
   public static Boolean DoFailTest = FALSE; 
    /*---------------------------------------------------------------------------------------------------
    OnAfterUpdate
    ---------------------------------------------------------------------------------------------------*/
    public override void afterUpdate() {
        String errMsg;

        errMsg  = Revsys_MapToContactHelper.startFromPositionHierarchy(newList);
        errMsg += Revsys_PositionHierarchyHelper2.updateSupervisorDetails(newList,(Map<Id,EPW_Position_Hierarchy__c>)oldMap);
        errMsg += Revsys_PositionHierarchyHelper2.assignTargets(newList);

        PositionHierarchyStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg);

        if(Test.isRunningTest() && DoFailTest) {
            PositionHierarchyStaticUtility.TriggerErrorMessage = 'Error' ;
        }
    }

}