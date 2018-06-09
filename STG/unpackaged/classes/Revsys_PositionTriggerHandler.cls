/**
*___________________________________________________
*@Name: Revsys_PositionTriggerHandler
*@Author: Chuck Walley
*@Created: Date: March 15, 2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Position Trigger Handler for SPARTN Systems Records 
* This class extends the Trigger Handler and invokes helper and utility classes 
* for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* 
* 
**/
public class Revsys_PositionTriggerHandler extends TriggerHandler {
    public static Boolean DoFailTest = FALSE;

    
    /**
    *————————————————————————————————————————————————————
    * After Update
    *————————————————————————————————————————————————————
    **/
     public override void afterUpdate() {
        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler afterUpdate-Start'); 
        
        String errorMsg; 
        
        SelectorWrapper myWrap = Revsys_PositionHelper.checkToUpdateSpartnContact(newList, oldMap);

        PositionStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(myWrap.ErrorMessage);  

        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler afterUpdate-End');    

    } 
}