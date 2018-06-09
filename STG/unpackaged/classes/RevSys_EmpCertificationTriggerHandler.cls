/**
*___________________________________________________
*@Name: RevSys_EmpCertificationTriggerHandler
*@Author: Colin Caldwell
*@Created: Date: 01/26/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Employee Certification Trigger Handler for Review Systems Records 
* This class extends the Trigger Handler and invokes the Handler for further logic.
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* 04-05-2018 Added call to checkSupervisorQualificationDupe() in beforeInsert and beforeUpdate [cwalley]
**/
public class RevSys_EmpCertificationTriggerHandler extends TriggerHandler{
     /*---------------------------------------------------------------------------------------------------
    OnAfterInsert
    ---------------------------------------------------------------------------------------------------*/   
    public override void afterInsert() {
        String errMsg;
        errMsg = RevSys_EmployeeCertificationHelper.createEmpSpecRequirement(newList); 
        errMsg += RevSys_EmployeeCertificationHelper.createCertificationTargets(newList);

        EmployeeCertificationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg);
     
    }  
    /*---------------------------------------------------------------------------------------------------
    OnBeforeInsert
    ---------------------------------------------------------------------------------------------------*/    
    public override void beforeInsert() {
        system.debug('RevSys_EmpCertificationTriggerHandler beforeInsert'); 
        string errMsg;

        errMsg  = Revsys_EmployeeCertValidation.checkEmpCertDupe(newList, null);   
        errMsg += Revsys_EmployeeCertValidation.checkSupervisorQualificationDupe(newList, null); 
        errMsg += RevSys_EmployeeCertificationHelper.populateEmployeeSupervisor(newList,new map<Id,EmployeeCertification__c>());

        EmployeeCertificationStaticUtility.TriggerErrorMessage
                = StringUtility.cleanupMessage(errMsg); 
	}  
     /*---------------------------------------------------------------------------------------------------
    OnAfterUpdate
    ---------------------------------------------------------------------------------------------------  */
    public override void afterUpdate() {
        system.debug('RevSys_EmpCertificationTriggerHandler afterUpdate'); 
        string errMsg; 
        errMsg = RevSys_EmployeeCertificationHelper.checkIfReadyForArchival(newList, (Map<Id, EmployeeCertification__c>)oldMap);

        //Moved this to after insert as the Employee Certification History is going to create the EC as new records.
        //errMsg += RevSys_EmployeeCertificationHelper.createCertificationTargets(newList, (Map<Id, EmployeeCertification__c>)oldMap);
        
        errMsg += RevSys_EmployeeCertificationHelper.establishSupervisorTargets(newList, (Map<Id, EmployeeCertification__c>)oldMap);

      	
        
        EmployeeCertificationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errMsg);
 
    }  
    /*---------------------------------------------------------------------------------------------------
    OnBeforeUpdate
    ---------------------------------------------------------------------------------------------------  */    
    public override void beforeUpdate() {
        system.debug('RevSys_EmpCertificationTriggerHandler beforeUpdate'); 
        
        string errMsg;
        errMsg  = Revsys_EmployeeCertValidation.checkEmpCertDupe(newList, oldMap); 
        errMsg += Revsys_EmployeeCertValidation.checkSupervisorQualificationDupe(newList, oldMap); 
        errMsg += RevSys_EmployeeCertificationHelper.replaceLastCertifiedDate(newList, (Map<Id, EmployeeCertification__c>)oldMap);
        errMsg += RevSys_EmployeeCertificationHelper.populateEmployeeSupervisor(newList, (Map<Id, EmployeeCertification__c>)oldMap);
        
        EmployeeCertificationStaticUtility.TriggerErrorMessage  = StringUtility.cleanupMessage(errMsg);  
    } 


}