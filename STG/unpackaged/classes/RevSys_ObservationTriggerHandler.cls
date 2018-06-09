/**
*___________________________________________________
*@Name: RevSys_ObservationTriggerHandler
*@Author: Colin Caldwell
*@Created: Date: 01/29/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Observation Trigger Handler for Review Systems Records 
* This class extends the Trigger Handler and invokes the Handler for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
* 05-29-2018 [Boom Bertetti]added RevSys_ObservationHelper.updateEmployeeCertification to afterInsert and afterUpdate
* 6-4-2018 [walley] ETR-1286 - Code Review Remediation = renamed generateSupervisorContactMap to getPerformingSupervisorContactInfo
**/
public class RevSys_ObservationTriggerHandler extends Triggerhandler {  
    public static Boolean DoFailTest = FALSE;
    /*---------------------------------------------------------------------------------------------------
    OnBeforeInsert
    ---------------------------------------------------------------------------------------------------*/
	public override void beforeInsert() { 
		
		String errMsg; 
		
		RevSys_ObservationHelper.applyDefaultInfo(newList);  
        RevSys_ObservationHelper.changeStatusToSubmitted(newList, null);
        RevSys_ObservationHelper.updateTime(newList, null);
        errMsg  = RevSys_ObservationHelper.getPerformingSupervisorContactInfo(newList);
        errMsg += RevSys_ObservationHelper.getEmployeeSupervisorContactInfo(newList);
        
        ObservationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg); 
         
        if(Test.isRunningTest() && DoFailTest) {
            ObservationStaticUtility.TriggerErrorMessage = 'Error' ;
        }
        
        

	}
    /*---------------------------------------------------------------------------------------------------
    OnAfterInsert
    ---------------------------------------------------------------------------------------------------*/
    public override void afterInsert() {
        string errMsg; 
        //errMsg = RevSys_TargetHelper.validateCertification(newList,(Map<Id,Observation__c>)oldMap);
        errMsg = RevSys_TargetHelper2.processObservation(newList,null);
        //errMsg += RevSys_TargetHelper.validateCertification(newList,(Map<Id,Observation__c>)oldMap);
        errMsg += RevSys_ObservationHelper.updateEmployeeCertification(newList, null);

        ObservationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg);
        
    
	} 
    /*---------------------------------------------------------------------------------------------------
    OnBeforeUpdate
    ---------------------------------------------------------------------------------------------------*/           
    public override void beforeUpdate() { 
    	string errMsg;       
        
        errMsg = RevSys_ObservationHelper.changeStatusToSubmitted(newList, oldMap);
        RevSys_ObservationHelper.updateTime(newList, oldMap);
        errMsg += RevSys_OverallScoreHelper2.determineScore(newList, oldMap);
        errMsg += RevSys_ObservationHelper.getEmployeeSupervisorContactInfo(newList);
        
        ObservationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg);
       
 
    }
    /*---------------------------------------------------------------------------------------------------
    OnAfterUpdate
    ---------------------------------------------------------------------------------------------------*/
    public override void afterUpdate() {
    	string errMsg;
        string errorReturn;
               
        errMsg= RevSys_UpdateEmployeeResultSummaryHelper.updateSummary(newList, oldMap);
       
       
       
        errMsg += RevSys_ObservationHelper.updateHierarchyAssignmentwithtestdate(newList);
        
        errMsg += RevSys_TargetHelper2.processObservation(newList, (Map<Id,Observation__c>)oldMap);
       // errMsg += RevSys_TargetHelper.validateCertification(newList,(Map<Id,Observation__c>)oldMap);
        errMsg += RevSys_ObservationHelper.updateEmployeeCertification(newList, oldMap);
        
        RevSys_ObservationFieldHistoryHelper.checkForAfterSubmitted(newList, newMap, oldMap);

        ObservationStaticUtility.TriggerErrorMessage= StringUtility.cleanupMessage(errMsg);
    }  

}