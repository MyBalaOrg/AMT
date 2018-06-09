/**
*___________________________________________________
*@Name: Revsys_HierarchyAssignmentHandler
*@Author: Chuck Walley
*@Created: Date: March 15, 2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: EPW_Hierarchy_Assignment Trigger Handler for SPARTN Systems Records 
* This class extends the Trigger Handler and invokes helper and utility classes 
* for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* 04-26-2018 Added call to Revsys_HierarchyAssignmentHelper.assignTargets
* 
**/
public class Revsys_HierarchyAssignmentHandler extends TriggerHandler {
    public static Boolean DoFailTest = FALSE;

    /**
    *————————————————————————————————————————————————————
    * Before Insert
    *————————————————————————————————————————————————————
    **/

    public override void beforeInsert() {
       system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler beforeInsert-Start'); 
       String errorMsg; 

        errorMsg  = Revsys_HierarchyAssignmentHelper.getSupervisorEmail(newList,null);
         
        // Get this logic out of the trigger handler and into a helper class 
        If (RevSys_ObservationHelper.varObservationInvoked == false || RevSys_ObservationHelper.varObservationInvoked ==null){
            RevSys_HierarchyAssignmentHelper.updateContactLastTesttakenDate(newList,null); 
        }

        if(Test.isRunningTest() && DoFailTest) {
             EpwHierarchyAssignmentStaticUtility.TriggerErrorMessage = 'Error';
        }

        EpwHierarchyAssignmentStaticUtility.TriggerErrorMessage 
            = StringUtility.cleanupMessage(errorMsg);

       system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler beforeInsert-End'); 
   }  

    /**
    *————————————————————————————————————————————————————
    * After Insert
    *————————————————————————————————————————————————————
    **/
    public override void afterInsert() {  
        
        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler afterInsert-Start');   

        String errorMsg; 

        errorMsg  = Revsys_HierarchyAssignmentHelper.addNewEmployee(newList); 
        errorMsg += Revsys_MapToContactHelper.startFromHierarchyAssignment(newList);  
        errorMsg += Revsys_HierarchyAssignmentHelper.assignTargets(newList); 

        EpwHierarchyAssignmentStaticUtility.TriggerErrorMessage 
            = StringUtility.cleanupMessage(errorMsg);   

        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler afterInsert-End');   
    }

    /**
    *————————————————————————————————————————————————————
    * Before Update
    *————————————————————————————————————————————————————
    **/

    public override void beforeUpdate() {
        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler beforeUpdate-Start'); 
        String errorMsg; 

        errorMsg = Revsys_UpdateManager.updateManagerBeforeUpdate(newList);
        errorMsg += Revsys_HierarchyAssignmentHelper.getSupervisorEmail(newList, (Map<Id,EPW_Hierarchy_Assignment__c>)oldMap); 


        if(RevSys_ObservationHelper.varObservationInvoked == false || RevSys_ObservationHelper.varObservationInvoked ==null) {          
          RevSys_HierarchyAssignmentHelper.updateContactLastTesttakenDate(newList,(Map<Id,EPW_Hierarchy_Assignment__c>)oldMap);
        } 

        EpwHierarchyAssignmentStaticUtility.TriggerErrorMessage 
            = StringUtility.cleanupMessage(errorMsg);

        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler beforeUpdate-End');    

    } 

    /**
    *————————————————————————————————————————————————————
    * After Update
    *————————————————————————————————————————————————————
    **/

    public override void afterUpdate() {
        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler afterUpdate-Start'); 
        String errorMsg; 

        errorMsg  = Revsys_HierarchyAssignmentHelper.assignTargets(newList); 

        EpwHierarchyAssignmentStaticUtility.TriggerErrorMessage 
            = StringUtility.cleanupMessage(errorMsg);   
       

        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler afterUpdate-End');    

    } 
}