/**
*___________________________________________________
*@Name: 	RevSys_TargetHelper2_Test
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 04/12/2018
*@Used_By: 	Global 
*___________________________________________________
*@Description: Test class for RevSys_TargetHelper2 Class 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
private class RevSys_TargetHelper2_Test {

	@TestSetup
	public static void loadTestData() {

		List<Contact> contactList = new List<Contact>();
		//Create Employee;
		Contact employee = new Contact
		(
			LastName			='Employee', 
			FirstName			='Amy', 
			Personnel_Number__c = 1234567,
			Email 				= 'test.test@amtrak.com',
            Employment_Status__c = 'Active',
            Department = 'Transportation'
		);
		contactList.add(employee);

		//Create Supervisor;
		Contact supervisor = new Contact
		(
			LastName			='Supervisor', 
			FirstName			='Amy', 
			Personnel_Number__c = 1234568,
			Email 				= 'test.test2@amtrak.com',
            Employment_Status__c = 'Active',
            Department = 'Transportation'
		);
		contactList.add(Supervisor);

		insert contactList;

		//Create Supervisor Targets.
		List<OccupationCertification__c> ocList = new List<OccupationCertification__c>();
		OccupationCertification__c supTarget = new  OccupationCertification__c();
        supTarget.Name = 'Supervisor Target';
        supTarget.TargetType__c = 'Supervisor';
        supTarget.Status__c= 'Active';
        supTarget.SupervisorType__c = 'Applies to all Observations';
        supTarget.Frequency__c = 'Months';
        supTarget.LengthOfPeriod__c = 1;
        supTarget.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
        supTarget.StartDate__c = System.today();
        supTarget.Department__c = 'Transportation';
        ocList.add(supTarget);

        OccupationCertification__c certificate = new OccupationCertification__c();
    	certificate.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
	    certificate.Name='New Occupation';
	    certificate.CertificationType__c = 'Conductor';
	    certificate.Frequency__c = 'Months';
	    certificate.LengthOfPeriod__c = 1;
	    certificate.Status__c = 'Active';
		ocList.add(certificate);


		OccupationCertification__c occT = new OccupationCertification__c();
        occT.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
        occT.TargetType__c = RevSys_StaticUtility.OCCUPATION;
        occT.SourceRecordType__c = 'FORM-1872';
        occT.Name = 'Occupational New Target';
        occT.Frequency__c = 'Months';
        occT.LengthOfPeriod__c = 1;
        occT.NumberOfTestsPerPeriod__c=10;
        occT.Status__c='Active';
        occT.StartDate__c = System.today();
        occT.Department__c = 'Transportation';
        ocList.add(occT);
        insert ocList;

        //Create Tests
        List<OccupationRequirement__c> orList = new List<OccupationRequirement__c>();
       	OccupationRequirement__c test1 = new OccupationRequirement__c(
       		Name = '101 - Stopping within One-Half the Range of Vision',
       		Status__c = 'Active',
       		SpeedCheckMethod__c = 'Stopping within One-Half the Range of Vision',
       		Check_Method_Required__c = 'Yes - Required',
       		Source__c = 'Observation',
       		SourceRecordType__c = 'FORM-1872',
       		TestNumber__c	 = '101',
       		TestName__c = 'Stopping within One-Half the Range of Vision',
       		RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID
       	);
       	orList.add(test1);
       	OccupationRequirement__c test2 = new OccupationRequirement__c(
       		Name = '102 - Stop Signal',
       		Status__c = 'Active',
       		//SpeedCheckMethod__c = 'Set-up Test',
       		//Check_Method_Required__c = 'Yes - Required',
       		Source__c = 'Observation',
       		SourceRecordType__c = 'FORM-1872',
       		TestNumber__c	 = '102',
       		TestName__c = 'Stop Signal',
       		RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID
       	);
       	orList.add(test2);
       	OccupationRequirement__c requirement = new OccupationRequirement__c(
       		Name = 'NewObs',
       		Status__c = 'Active',
       		Source__c = 'Observation',
       		SourceRecordType__c = 'FORM-1872',
       		RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID
       	);
       	orList.add(requirement);

       	insert orList;

       	//Insert OSR as Target requirements
		List<OccupationSpecificRequirement__c> osrList = new List<OccupationSpecificRequirement__c>();
		OccupationSpecificRequirement__c osr1 = new OccupationSpecificRequirement__c(
			RecordTypeId = RevSys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID,
			Observation__c = orList[0].Id,
			TargetRequirement__c = orList[2].Id,
			Status__c = 'Active'
		);
		osrList.add(osr1);

		OccupationSpecificRequirement__c osr2 = new OccupationSpecificRequirement__c(
			RecordTypeId = RevSys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID,
			Observation__c = orList[1].Id,
			TargetRequirement__c = orList[2].Id,
			Status__c = 'Active'
		);
		osrList.add(osr2);

		OccupationSpecificRequirement__c osr3 = new OccupationSpecificRequirement__c(
			RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID,
			Certification__c = ocList[1].Id,
			Requirement__c = orList[2].Id,
			Frequency__c = 'Months',
			LengthOfPeriod__c = 1,
			Status__c = 'Active'
		);
		osrList.add(osr3);
		insert osrList;

		//This will create Supervisor Targets to the Supervisor
		EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTSUPV_RECTYPE_ID;
        empCertObj.Employee__c = contactList[0].id;
        empCertObj.Status__c = 'Inactive';
        insert empCertObj;

        empCertObj.Status__c = 'Active';
        update empCertObj;

        //This will creat ESRs based on the Emploee Certification
        EmployeeCertification__c newEmpCert = new EmployeeCertification__c();
	    newEmpCert.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
	    newEmpCert.Certification__c = certificate.id;
	    newEmpCert.Employee__c = contactList[1].id;
	    newEmpCert.Status__c = RevSys_StaticUtility.CURRENT;
	    newEmpCert.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
	    insert newEmpCert;

	    //Target are applied to contacts
	    Contact con = contactList[1];
	    update con;


	}
	
	public static testMethod void testCreateObservation() {
		Test.startTest();
		Contact employee = [Select Id from Contact where LastName='Employee' Limit 1];
		List<OccupationSpecificRequirement__c> osrList = [Select Id from OccupationSpecificRequirement__c where Observation__r.TestNumber__c in ('101','102') ];
		
		List<Observation__c> obsList = new List<Observation__c>();
		Observation__c obs1 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID,
            Status__c                       = 'Submitted',
            Date__c                         = Date.today(), 
            Department__c                   = 'Transportation',
            Employee__c                     = employee.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = osrList[0].Id,
            TestNumber__c = '101',
            Result__c = 'C = Compliance',
            //SpeedCheckMethod__c = 'Stopping within One-Half the Range of Vision',
            PersonallyObserved__c = 'Yes'
        );
        obsList.add(obs1);
        /*Observation__c obs2 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID,
            Status__c                       = 'Submitted',
            Date__c                         = Date.today(), 
            Department__c                   = 'Transportation',
            Employee__c                     = employee.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = osrList[1].Id,
            Result__c = 'C = Compliance',
            TestNumber__c = '102',
            SpeedCheckMethod__c = 'Stopping within One-Half the Range of Vision',
            PersonallyObserved__c = 'Yes'
        );
        obsList.add(obs2);*/

        insert obsList; 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('Observation__c');
        String myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE Id = \''+obsList[0].Id+'\''; 
        List<Observation__c> obsToUpdateList = Database.query(myQuery); 
        Observation__c obsToUpdate = obsToUpdateList.get(0);
        obsToUpdate.TestNumber__c = '102';
        obsToUpdate.OccupationSpecificRequirement__c =  osrList[1].Id;
        update obsToUpdate;

		Test.stopTest();
	}
	public static testMethod void testCreateObservation2() {
		Test.startTest();
		Contact employee = [Select Id from Contact where LastName='Employee' Limit 1];
		Contact supervisor = [Select Id from Contact where LastName='Supervisor' Limit 1];
		List<OccupationSpecificRequirement__c> osrList = [Select Id from OccupationSpecificRequirement__c where Observation__r.TestNumber__c in ('101','102') ];
		
		List<Observation__c> obsList = new List<Observation__c>();
		Observation__c obs1 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID,
            Status__c                       = 'Draft',
            Date__c                         = Date.today(), 
            Department__c                   = 'Transportation',
            Employee__c                     = employee.Id,
            Supervisor__c                   = supervisor.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = osrList[0].Id,
            TestNumber__c = '101',
            Result__c = 'C = Compliance',
            SpeedCheckMethod__c = 'Stopping within One-Half the Range of Vision',
            PersonallyObserved__c = 'Yes'
        );
        obsList.add(obs1);

        insert obsList; 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('Observation__c');
        String myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE Id = \''+obsList[0].Id+'\''; 
        List<Observation__c> obsToUpdateList = Database.query(myQuery); 
        Observation__c obsToUpdate = obsToUpdateList.get(0);
        obsToUpdate.Status__c = 'Submitted';
        update obsToUpdate;

		Test.stopTest();
	}

	public static testMethod void testCreateObservation3() {
		Test.startTest();
		Contact employee = [Select Id from Contact where LastName='Employee' Limit 1];
		Contact supervisor = [Select Id from Contact where LastName='Supervisor' Limit 1];
		List<OccupationSpecificRequirement__c> osrList = [Select Id from OccupationSpecificRequirement__c where Observation__r.TestNumber__c in ('101','102') ];
		
		List<Observation__c> obsList = new List<Observation__c>();
		Observation__c obs1 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID,
            Status__c                       = 'Submitted',
            Date__c                         = Date.today(), 
            Department__c                   = 'Transportation',
            Employee__c                     = employee.Id,
            Supervisor__c                   = supervisor.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = osrList[0].Id,
            TestNumber__c = '101',
            Result__c = 'C = Compliance',
            //SpeedCheckMethod__c = 'Stopping within One-Half the Range of Vision',
            PersonallyObserved__c = 'Yes'
        );
        obsList.add(obs1);
        /*Observation__c obs2 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID,
            Status__c                       = 'Submitted',
            Date__c                         = Date.today(), 
            Department__c                   = 'Transportation',
            Employee__c                     = employee.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = osrList[1].Id,
            Result__c = 'C = Compliance',
            TestNumber__c = '102',
            SpeedCheckMethod__c = 'Stopping within One-Half the Range of Vision',
            PersonallyObserved__c = 'Yes'
        );
        obsList.add(obs2);*/

        insert obsList; 

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('Observation__c');
        String myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE Id = \''+obsList[0].Id+'\''; 
        List<Observation__c> obsToUpdateList = Database.query(myQuery); 
        Observation__c obsToUpdate = obsToUpdateList.get(0);
        obsToUpdate.Status__c = 'Removed';
        update obsToUpdate;

		Test.stopTest();
	}


	public static testMethod void testCreateObservation4() {
		Test.startTest();
		Contact employee = [Select Id from Contact where LastName='Employee' Limit 1];
		Contact supervisor = [Select Id from Contact where LastName='Supervisor' Limit 1];
		List<OccupationSpecificRequirement__c> osrList = [Select Id from OccupationSpecificRequirement__c where Observation__r.TestNumber__c in ('101','102') ];
		
		List<Observation__c> obsList = new List<Observation__c>();
		Observation__c obs1 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID,
            Status__c                       = 'Submitted',
            Date__c                         = Date.today(), 
            Department__c                   = 'Transportation',
            Employee__c                     = employee.Id,
            Supervisor__c                   = supervisor.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = osrList[0].Id,
            TestNumber__c = '101',
            Result__c = 'C = Compliance',
            //SpeedCheckMethod__c = 'Stopping within One-Half the Range of Vision',
            PersonallyObserved__c = 'Yes'
        );
        obsList.add(obs1);

        insert obsList;

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('EmployeeSpecificRequirement__c');
        String myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE Employee__c = \''+employee.Id+'\''; 
        List<EmployeeSpecificRequirement__c> esrList = Database.query(myQuery);

        RevSys_TargetHelper2.ObservationWrapper obsWrAP = new RevSys_TargetHelper2.ObservationWrapper('Add',obsList.get(0));
        EmployeeSpecificRequirement__c esr = RevSys_TargetHelper2.processEsrRequirement(obsWrAP,esrList.get(0));

		Test.stopTest();
	}
	
}