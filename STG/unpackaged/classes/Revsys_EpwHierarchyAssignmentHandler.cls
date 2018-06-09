/**
*___________________________________________________
*@Name: Revsys_EpwHierarchyAssignmentHandler
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
* 
**/
public class Revsys_EpwHierarchyAssignmentHandler extends TriggerHandler {
    public static Boolean DoFailTest = FALSE;
    /**
    *————————————————————————————————————————————————————
    * After Update
    *————————————————————————————————————————————————————
    **/
    public override void afterUpdate() {
        
     }
     public override void beforeInsert() {
       system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler beforeInsert-Start'); 
       String errorMsg; 

       errorMsg  = Revsys_HierarchyAssignmentHelper.getSupervisorEmail(newList,null); 
       EpwHierarchyAssignmentStaticUtility.TriggerErrorMessage 
       = StringUtility.cleanupMessage(errorMsg);
         if(Test.isRunningTest() && DoFailTest) {
             EpwHierarchyAssignmentStaticUtility.TriggerErrorMessage = 'Error';
         }

       system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler beforeInsert-End'); 
   }  

    public override void beforeUpdate() {
        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler beforeUpdate-Start'); 
        String errorMsg; 

        errorMsg = Revsys_UpdateManager.updateManagerBeforeUpdate(newList);
        errorMsg += Revsys_HierarchyAssignmentHelper.getSupervisorEmail(newList, (Map<Id,EPW_Hierarchy_Assignment__c>)oldMap); 

        EpwHierarchyAssignmentStaticUtility.TriggerErrorMessage 
            = StringUtility.cleanupMessage(errorMsg);

         system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler beforeUpdate-End');    

    } 
    public override void afterInsert() {  
        
        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler afterInsert-Start');   

        String errorMsg; 

        /*
        if(System.isQueueable() ) {
            errorMsg  = Revsys_HierarchyAssignmentHelper.addNewEmployee(newList); 
            errorMsg += Revsys_MapToContactHelper.startFromHierarchyAssignment(newList);  
        }
        else {
            Revsys_HierAssgn_Queueable updateJob = new Revsys_HierAssgn_Queueable(newList);
            ID jobID = System.enqueueJob(updateJob);
        }
        */ 


        errorMsg  = Revsys_HierarchyAssignmentHelper.addNewEmployee(newList); 
        errorMsg += Revsys_MapToContactHelper.startFromHierarchyAssignment(newList);  


        EpwHierarchyAssignmentStaticUtility.TriggerErrorMessage 
            = StringUtility.cleanupMessage(errorMsg);   

        system.debug('HANDLER Revsys_EpwHierarchyAssignmentHandler afterInsert-End');   
    }
    
}