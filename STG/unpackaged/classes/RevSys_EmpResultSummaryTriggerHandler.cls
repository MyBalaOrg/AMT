/**
*___________________________________________________
*@Name: RevSys_EmployeeResultSummaryTriggerHandler
*@Author: Colin Caldwell
*@Created: Date: 01/25/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Employee Result Summary Trigger Handler for Review Systems Records 
* This class extends the Trigger Handler and invokes helper and utility classes 
* for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_EmpResultSummaryTriggerHandler extends TriggerHandler{
     public static Boolean DoFailTest = FALSE; 
    /*---------------------------------------------------------------------------------------------------
    OnBeforeInsert
    ---------------------------------------------------------------------------------------------------*/  
    public override void beforeInsert() {
        String errMsg; 
        errMsg  = RevSys_EmployeeResultSummaryHelper.processSupervisor(newList);  
        //errMsg += RevSys_EmployeeResultSummaryHelper.processNurse(newList);
        errMsg += RevSys_EmployeeResultSummaryHelper.autoPopulateFields(newList);
        errMsg += RevSys_EmployeeResultSummaryHelper.updateHealthServices(newList);
       EmployeeResultSummaryStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg); 
        if(Test.isRunningTest() && DoFailTest) {
            EmployeeResultSummaryStaticUtility.TriggerErrorMessage = 'error';
        }
    }  
    /*---------------------------------------------------------------------------------------------------
    OnBeforeUpdate
    ---------------------------------------------------------------------------------------------------*/ 
    public override void beforeUpdate() {
        String errMsg;
        errMsg  = RevSys_EmployeeResultSummaryHelper.processSupervisor(newList);  
       // errMsg += RevSys_EmployeeResultSummaryHelper.processNurse(newList);
        errMsg += RevSys_EmployeeResultSummaryHelper.autoPopulateFields(newList);
        errMsg += RevSys_EmployeeResultSummaryHelper.updateHealthServices(newList);
        
        EmployeeResultSummaryStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg);
    }  
    /*---------------------------------------------------------------------------------------------------
    OnAfterInsert
    ---------------------------------------------------------------------------------------------------*/
    public override void afterInsert() {
    	EmployeeCertificationStaticUtility.TriggerErrorMessage 
    		= RevSys_EmployeeResultSummaryHelper.updateRecords(newList, (Map<Id, EmployeeResultSummary__c>)oldMap);  
    }   
    /*---------------------------------------------------------------------------------------------------
    OnAfterUpdate
    ---------------------------------------------------------------------------------------------------*/ 
    public override void afterUpdate() {
        EmployeeCertificationStaticUtility.TriggerErrorMessage 
            = RevSys_EmployeeResultSummaryHelper.updateRecords(newList, (Map<Id, EmployeeResultSummary__c>)oldMap);   
    }
}