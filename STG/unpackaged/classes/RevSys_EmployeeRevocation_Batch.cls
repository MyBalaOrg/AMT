/**
*___________________________________________________
*@Name: 	RevSys_EmployeeRevocation_Batch
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 01/23/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Batch class to update the Certification Status to Revoked
* 
*___________________________________________________
*@Changes: 
**/
public with sharing class RevSys_EmployeeRevocation_Batch extends BatchSchedule_Handler{
	/**
	*————————————————————————————————————————————————————
	* @Name: processBatch
	* @Description
	* Builds the dynamic query to process the batch
	*————————————————————————————————————————————————————
	* @param    
	* @return   String            dynamic Query
	*————————————————————————————————————————————————————
	**/ 
	public String processBatch() {
		String query='';
		/*query = System.Label.SELECT+' EmployeeCertification__c,EmployeeCertification__r.Status__c,RevocationEndDate__c '+System.Label.FROM;
		query += ' '+RevSys_StaticUtility.OBJAPI_CERTIFICATION_REVOCATION;
		query += ' '+Label.WHERE+' EmployeeCertification__r.Status__c =\''+RevSys_StaticUtility.REVOKED+'\'';
		query += ' ORDER BY CreatedDate ASC';*/

		query = Label.SELECT+ ' Id,Status__c,ExpirationDate__c '+Label.FROM;
		query += ' '+RevSys_StaticUtility.OBJAPI_EMPLOYEE_CERTIFICATION;
		query += ' '+Label.WHERE+' Status__c =\''+RevSys_StaticUtility.REVOKED+'\'';
		query += ' '+Label.AND+' Archived__c = FALSE';

		return query;
	}
	/**
	*————————————————————————————————————————————————————
	* @Name: execute
	* @Description
	* Implemented to process the results of the query
	*————————————————————————————————————————————————————
	* @param    BatchableContext
	*			scope			List of records returned by the query
	* @return  	void
	*————————————————————————————————————————————————————
	**/ 
   	public override void execute(Database.BatchableContext BC, List<sObject> scope) {
   		if(scope!=null) {
   			Set<Id> empCertId = new Set<Id>();
   			//Get the latest Revocation record by addding into the map
   			/*Map<Id,CertificationRevocation__c> cerRevMap = new Map<Id,CertificationRevocation__c>();
   			for(CertificationRevocation__c cerRev : (List<CertificationRevocation__c>)scope) {
   				cerRevMap.put(cerRev.EmployeeCertification__c, cerRev);
   			}*/
   			for(EmployeeCertification__c ecRecord : (List<EmployeeCertification__c>)scope) {
   				empCertId.add(ecRecord.Id);
   			}

            batchErrorMessage += RevSys_EmployeeCertificationStatusHelper.processRevocationRecords(empCertId);
            batchErrorMessage = StringUtility.cleanupMessage(batchErrorMessage); 
   		}
	}
	
	/**
	*————————————————————————————————————————————————————
	* @Name: execute
	* @Description
	* Related to the schedulable interface. Schedules the batch job. Check method definition in BatchHandler
	*————————————————————————————————————————————————————
	* @param    SchedulableContext
	* @return   void
	*————————————————————————————————————————————————————
	**/ 	
	public override void execute(SchedulableContext sc) {
		Type batchClass = Type.forName('RevSys_EmployeeRevocation_Batch');
		String failureSubj = System.label.RevSys_Batch_Failure_Email_Subject;
		String failureEmail = System.label.RevSys_Batch_Failure_Email;
		BatchSchedule_Handler.runJob(batchClass,processBatch(), failureSubj, failureEmail);
	}
}