/**
*___________________________________________________
*@Name: 	RevSys_UpdateEmployeeResultSummHelp_Test
*@Author: 	Chuck Walley
*@Created: 	Date: 11/12/2017
*@Used_By: 	Review Systems
*___________________________________________________
*@Description: Test for RevSys_ObservationHandler
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
* 11-28-2017. Changed by Hemanth Kesapragada -  Added methods to test - Update and Insert Employee Result Summary records
**/
@isTest(SeeAllData=false)

public class RevSys_UpdateEmployeeResultSummHelp_Test {   
    /**
    *————————————————————————————————————————————————————
    * @Name: testEntireClass
    * @Description	One long method to build data needed for 
    *				Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
   /* public static testMethod void testEntireClass() 
    {
        system.debug('TEST RevSys_UpdateEmployeeResultSummHelp_Test testEntireClass-Start');     
        
        RevSys_TestDataHelper.buildTestData();

        // get the observations 

        List<Observation__c> myObsList = new List<Observation__c>
        ( 
        	[SELECT Id, RecordTypeId, Date__c, Time__c, Department__c, 
        			Employee__c, Status__c
        	 FROM   Observation__c]
        );

        Set<Id> myObsIdSet = new Set<Id>(); 

        for(Observation__c myObs :myObsList)
        {
        	myObsIdSet.add(myObs.Id); 
            myObs.OperatedFromText__c = 'Test Operated From';
            myObs.OperatedToText__c = 'Test Operated To';
        	myObs.Status__c = 'Submitted'; 
        }

        List<Finding__c> myFindingList = new List<Finding__c>
     	( 
     		[SELECT Id, RecordTypeId, Observation__c, Category__c, 
     				Sub_category__c, Sequence__c, Score__c 
     		 FROM   Finding__c 
     		 WHERE  Observation__c IN :myObsIdSet]
     	);

     	system.assertNotEquals(0,myFindingList.size() ); 

     	for(Finding__c myFinding :myFindingList)
     	{
     		myFinding.Score__c = 4; 
     	}

     	Test.startTest(); 

     		UPDATE myFindingList; 

     		system.debug('myObsList ' + myObsList); 
     		system.debug('BEFORE THE UPDATE'); 

     		UPDATE myObsList; 

        Test.stopTest(); 

		system.debug('TEST RevSys_UpdateEmployeeResultSummHelp_Test testEntireClass-End');     
		return; 

    }*/
    /**
    *————————————————————————————————————————————————————
    * @Name: loadTestData
    * @Description  load test data before the Test execution 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 

    @TestSetup
    public static void loadTestData() {
        Contact employee = new Contact
        (
            LastName            ='Employee', 
            FirstName           ='Amy', 
            Department          = 'Mechanical',
            Craft__c            = 'Craft',
            Personnel_Number__c = 1234567,
            Email               = 'test.test@amtrak.com'
        );
        insert employee; 

        List<Observation__c> obsList = new List<Observation__c>();

        Observation__c obs = new Observation__c();
        obs.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID;
        obs.Status__c = 'Draft';
        obs.Date__c = Date.today();
        obs.Department__c = 'Mechanical';
        obs.Employee__c = employee.Id;
        obs.OperatedFromText__c = 'Test Operated From';
        obs.OperatedToText__c = 'Test Operated To';
        obs.Result__c = 'C = Compliance';
        obsList.add(obs);

        obs = new Observation__c();
        obs.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID;
        obs.Status__c = 'Draft';
        obs.Date__c = Date.today();
        obs.Department__c = 'Mechanical';
        obs.Employee__c = employee.Id;
        obs.OperatedFromText__c = 'Test Operated From';
        obs.OperatedToText__c = 'Test Operated To';
        obs.Result__c = 'C = Compliance';
        obsList.add(obs);

        obs = new Observation__c();
        obs.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID;
        obs.Status__c = 'Draft';
        obs.Date__c = Date.today();
        obs.Department__c = 'Mechanical';
        obs.Employee__c = employee.Id;
        obs.OperatedFromText__c = 'Test Operated From';
        obs.OperatedToText__c = 'Test Operated To';
        obs.Result__c = 'C = Compliance';
        obsList.add(obs);

        obs = new Observation__c();
        obs.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID;
        obs.Status__c = 'Draft';
        obs.Date__c = Date.today();
        obs.Department__c = 'Mechanical';
        obs.Employee__c = employee.Id;
        obs.OperatedFromText__c = 'Test Operated From';
        obs.OperatedToText__c = 'Test Operated To';
        obs.Result__c = 'C = Compliance';
        obsList.add(obs);

        obs = new Observation__c();
        obs.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID;
        obs.Status__c = 'Draft';
        obs.Date__c = Date.today();
        obs.Department__c = 'Mechanical';
        obs.Employee__c = employee.Id;
        obs.OperatedFromText__c = 'Test Operated From';
        obs.OperatedToText__c = 'Test Operated To';
        obs.Result__c = 'C = Compliance';
        obsList.add(obs);

        insert obsList;
        
        OccupationRequirement__c OccReqRec = new OccupationRequirement__c(
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
            TestNumber__c='Test123',
            TestName__c = 'Test',
            Source__c = 'Observation',
            SourceRecordType__c = 'FORM-1872'
        );
        insert OccReqRec;
        
        OccupationSpecificRequirement__c osrObj = new OccupationSpecificRequirement__c();
        osrObj.Observation__c = OccReqRec.id;
        osrObj.ObservationDepartment2__c = 'Mechanical';
        osrObj.ObservationCraft2__c = 'Conductor';
        osrObj.RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID;
        insert osrObj;

    }

    /**
    *————————————————————————————————————————————————————
    * @Name: testNewObservationCreation
    * @Description  Test to create new Employement REsult Summary 
    *               records when Observation is created and changed to Submitted state 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 

    public static testMethod void  testNewObservationCreation() {
        Test.startTest();

        Observation__c observ1 = [SELECT Id,RecordTypeId
                                 FROM Observation__c 
                                 WHERE REcordTypeId=:RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID
                                 LIMIT 1];
        OccupationSpecificRequirement__c osr = [Select Id from OccupationSpecificRequirement__c where RecordTypeId =: RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID];

        List<EmployeeResultSummary__c> ersList = [SELECT Id FROM EmployeeResultSummary__c WHERE Observation__c =:observ1.Id ];
        System.assertEquals(0,ersList.size());

        List<Observation__c> observList = new List<Observation__c>();

        observ1.Status__c = 'Submitted';
        observ1.OccupationSpecificRequirement__c = osr.Id;
        observList.add(observ1);

        Observation__c observ2 = [SELECT Id,RecordTypeId
                                 FROM Observation__c 
                                 WHERE REcordTypeId=:RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID
                                 LIMIT 1];
        observ2.Status__c = 'Submitted';
        observ2.OccupationSpecificRequirement__c = osr.Id;
        observList.add(observ2);

        Observation__c observ3 = [SELECT Id,RecordTypeId
                                 FROM Observation__c 
                                 WHERE REcordTypeId=:RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID
                                 LIMIT 1];
        observ3.Status__c = 'Submitted';
        observ3.OccupationSpecificRequirement__c = osr.Id;
        observList.add(observ3);

        Observation__c observ4 = [SELECT Id,RecordTypeId
                                 FROM Observation__c 
                                 WHERE REcordTypeId=:RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID
                                 LIMIT 1];
        observ4.Status__c = 'Submitted';
        observ4.OccupationSpecificRequirement__c = osr.Id;
        observList.add(observ4);

        Observation__c observ5 = [SELECT Id,RecordTypeId
                                 FROM Observation__c 
                                 WHERE REcordTypeId=:RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID
                                 LIMIT 1];
        observ5.Status__c = 'Submitted';
        observ5.OccupationSpecificRequirement__c = osr.Id;
        observList.add(observ5);

        update observList;


        ersList = [SELECT Id FROM EmployeeResultSummary__c];
        System.assertEquals(5,ersList.size());



        Test.stopTest();

    }


    /**
    *————————————————————————————————————————————————————
    * @Name: testUpdateObservationCreation
    * @Description  Test to update existing Employement REsult Summary 
    *               records when Observation with Submitted state is updated before 48hrs
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/
    public static testMethod void  testUpdateObservationCreation() {

       OccupationSpecificRequirement__c osr = [Select Id from OccupationSpecificRequirement__c where RecordTypeId =: RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID];
        Test.startTest();
        Contact employee = [SELECT Id from Contact Limit 1];

        Observation__c obs = new Observation__c();
        obs.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID;
        obs.Status__c = 'Submitted';
        obs.Date__c = Date.today();
        obs.OccupationSpecificRequirement__c = osr.Id;
        obs.Department__c = 'Mechanical';
        obs.Employee__c = employee.Id;
        obs.FormType__c = 'Form-1875';
        obs.RegionProperty__c = 'Central';
        obs.OperatedFromText__c = 'Test Operated From';
        obs.OperatedToText__c = 'Test Operated To';
        obs.Result__c = 'C = Compliance';

        insert obs;

        EmployeeResultSummary__c myErsRec = new EmployeeResultSummary__c();
        myErsRec.RecordTypeId =  RevSys_StaticUtility.EMP_RES_SUMM_TEST1872_RECTYPE_ID;
        myErsRec.Comments__c          = obs.Comments__c;
        myErsRec.EvaluationDate__c              = obs.Date__c;
        myErsRec.Employee__c          = obs.Employee__c; 
        myErsRec.RegionProperty__c = obs.RegionProperty__c;
        myErsRec.Result__c        = obs.Result__c;
        myErsRec.Observation__c   = obs.Id;

        insert myErsRec;

        System.assertEquals('Central',myErsRec.RegionProperty__c);

        Observation__c newObs = [SELECT Id,RegionProperty__c FROM Observation__c WHERE Id=:obs.Id];
        newObs.RegionProperty__c = 'Central';
        update newObs;

        EmployeeResultSummary__c esr = [SELECT RegionProperty__c from EmployeeResultSummary__c where Observation__c=:newObs.Id];
        System.assertEquals('Central',esr.RegionProperty__c);

        Test.stopTest();

    }

}