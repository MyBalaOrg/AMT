/**
*___________________________________________________
*@Name: 	RevSys_EmployeeRevocationBatch_Test
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 01/28/2018
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Test for RevSys_EmployeeRevocation_Batch
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
private class RevSys_EmployeeRevocationBatch_Test {

	@TestSetup
	public static void loadTestData() {
		//Calling helper class to create OC,OR, OSR and EC Records
		RevSys_TestDataHelper.buildCertificationData();
		EmployeeCertification__c ecRecord = [SELECT Id FROM EmployeeCertification__c LIMIT 1];
		ecRecord.Status__c = RevSys_StaticUtility.REVOKED;
        ecRecord.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
		update ecRecord;

		//Create Certification Revocation Records
		CertificationRevocation__c crRecord = new CertificationRevocation__c();
		crRecord.EmployeeCertification__c = ecRecord.Id;
		crRecord.RevocationEndDate__c = System.today();
        crRecord.IncidentDate__c = Date.today();
        crRecord.Description__c = 'Description';
        crRecord.PerformingAs__c = 'Conductor'; 
        crRecord.TrackType__c = 'Main Track';
        crRecord.RevocationBeginDate__c = System.today();
		insert crRecord;


	}
	
	public static testMethod void testBatchException() {
		// Implement test code
		Test.startTest();
		RevSys_EmployeeRevocation_Batch myJob = new RevSys_EmployeeRevocation_Batch(); 

		String sch = '00 03 * * * ? *';
		String jobID = system.schedule('Test'+Math.random(), sch, myJob); 

		List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors, jobitemsprocessed, totalJobItems FROM AsyncApexJob];
		AsyncApexJob apexJob;
		if(jobInfo!=null && jobInfo.size()!=0) {
			apexJob = jobInfo.get(0);
			List<Messaging.SingleEmailMessage> errorEmails = myJob.generateErrorEmail(apexJob);
			System.assertEquals(1, errorEmails.size());
		}
	
		Test.stopTest();
	}

	public static testMethod void testBatch() {
		// Implement test code
		Test.startTest();
		
		Contact employee = [Select Id from Contact Limit 1];

		EmployeeCertification__c temEmpCertObj = [Select id,RecordTypeId,Certification__c,Employee__c,Status__c,ExpirationDate__c,(Select id from Employee_Specific_Requirements__r) from EmployeeCertification__c Limit 1];
        List<EmployeeSpecificRequirement__c> ecListToUpdate = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : temEmpCertObj.Employee_Specific_Requirements__r) {
            esr.LastFulfilledDate__c = System.today();
            ecListToUpdate.add(esr);
        }
        update ecListToUpdate;

        // Motor Vehicle Review Form for Contact
        EmployeeResultSummary__c vehicleReviewForm = new EmployeeResultSummary__c
        (
            RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID,
            Employee__c = employee.Id,
            Status__c = RevSys_StaticUtility.PASS
        );
        insert vehicleReviewForm;


		RevSys_EmployeeRevocation_Batch myJob = new RevSys_EmployeeRevocation_Batch(); 

		String sch = '00 03 * * * ? *';
		String jobID = system.schedule('Test'+Math.random(), sch, myJob); 

		List<AsyncApexJob> jobInfo = [SELECT Status,NumberOfErrors, jobitemsprocessed, totalJobItems FROM AsyncApexJob];
		AsyncApexJob apexJob;
		if(jobInfo!=null && jobInfo.size()!=0) {
			apexJob = jobInfo.get(0);
			List<Messaging.SingleEmailMessage> errorEmails = myJob.generateErrorEmail(apexJob);
			System.assertEquals(1, errorEmails.size());
		}
	
		Test.stopTest();
	}
	
	/*private static String processDate() {
		DateTime dt = System.now();
		String seconds = String.valueOf(dt.addSeconds(10).second());
		String minutes = String.valueOf(dt.minute());
		String hours = String.valueOf(dt.hour());
		String day = String.valueOf(dt.day());
		String month = String.valueOf(dt.month());
		String year = String.valueOf(dt.year());
		String cronExpression = seconds+' '+minutes+' '+hours+' '+day+' '+month+' ? '+year;
		System.debug(cronExpression);
		return cronExpression;
	}*/
	
}