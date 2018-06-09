@isTest(SeeAllData = false)
public class RevSys_Obs_ButtonCmpController_Test {
	
    @TestSetup
    public static void loadTestData() {
        
        list<REVSYS_Custom_Settings__c>  revCSList = new list<REVSYS_Custom_Settings__c>();
        
        REVSYS_Custom_Settings__c revCS1 = new REVSYS_Custom_Settings__c();
        revCS1.Name = 'Enable Observation Soft Delete';
        revCS1.CSV_String__c = 'SPARTN_Target_Administrator';
        revCS1.CsvString__c = 'SPARTN_Target_Administrator';
        revCSList.add(revCS1);
        
        insert revCSList;
        
        // Create Occupation Requirements (Observations)  
        OccupationRequirement__c myOR1 = new OccupationRequirement__c 
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID, 
                TestNumber__c   = '100', 
                TestName__c     = 'Test 100',
                Name            = '100 - Test 100',
                Status__c       = 'Active',
                SpeedCheckMethod__c = 'Stopping within One-Half the Range of Vision',
                Check_Method_Required__c = 'Yes - Required'
            ); 
        
        insert myOR1;
        
        OccupationSpecificRequirement__c myOSR1 = new OccupationSpecificRequirement__c(
        	RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID,
            ObservationDepartment2__c = 'Mechanical',
            ObservationCraft2__c = 'Conductor',
            Observation__c = myOR1.Id,
            Status__c       = 'Active'
        );
        
        insert myOSR1;
        
        List<Contact> myContactList = new List<Contact>(); 
        Contact supervisorA = new Contact
            (
                //AccountId           = amtrakAcct.id, 
                LastName            ='Supervisor', 
                FirstName           ='Amy', 
                Personnel_Number__c = 10000000,
                Employment_Status__c = 'Active',
                Email               = 'amy.supervisor@amtrak.com',
                OnTheJobTrainingStartDate__c = system.today(),
                Department = 'Mechanical',
                Craft__c = 'Conductor'
                //PositionLookup__c   = PosSupervisorA.Id
            );
        myContactList.add(supervisorA); 
        insert myContactList;
        
        List<Observation__c> myObservationList = new List<Observation__c>(); 
		Observation__c obs1 = new Observation__c
        ( 
            RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID,
            Status__c                       = 'Draft',
            Date__c                         = Date.today(), 
            Department__c                   = 'Engineering ET',
            Employee__c                     = supervisorA.Id,
            Number_of_Workers_Observed__c = 1,
            OccupationSpecificRequirement__c = myOSR1.Id
        );
        myObservationList.add(obs1);
        insert myObservationList;
    }
    
    public static testMethod void testCheckPermissionSysAdmin(){
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.checkPermission();
        Test.stopTest();
    }
    
    public static testMethod void testCheckPermissionNonSysAdmin(){
        
        PermissionSet ps = [
            select Id
            from PermissionSet
            where Name = 'SPARTN_Target_Administrator'
        ];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Amtrak Employee'];
        
        User u1 = new User(Alias = 'Amtrak',Country='United Kingdom',Email='amtrak_emp@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='r8880', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='amtrak_emp_8880@rkoradiya.org');
        insert u1;
        
        PermissionSetAssignment assignment = new PermissionSetAssignment(
            AssigneeId = u1.Id,
            PermissionSetId = ps.Id
        );
        insert assignment;
		
        System.runAs(u1){
        	Test.startTest();
            Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.checkPermission();
            Test.stopTest();
        }
        
    }
    
    public static testMethod void testCheckPermissionNonSysAdminNoAcc(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Amtrak Employee'];
        
        User u1 = new User(Alias = 'Amtrak',Country='United Kingdom',Email='amtrak_emp@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='r8880', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='amtrak_emp_8880@rkoradiya.org');
        insert u1;
        
        System.runAs(u1){
        	Test.startTest();
            Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.checkPermission();
            Test.stopTest();
        }
        
    }
    
    public static testMethod void testSoftDeleteObservationNoExep(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.softDeleteObservation(myObservationList.get(0).Id);
        Test.stopTest();
        
    }
    
    public static testMethod void testSoftDeleteObservationNullObs(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        Id obsIdNull = null;
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.softDeleteObservation(obsIdNull);
        Test.stopTest();
        
    }
    
    public static testMethod void testSoftDeleteObservationNonBlankObsId(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        myObservationList.get(0).RecordTypeId = RevSys_StaticUtility.OBSERVATION_OBSERVATIONS_RECTYPE_ID;
        update myObservationList;
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.softDeleteObservation(myObservationList.get(0).Id);
        Test.stopTest();
        
    }
    
    public static testMethod void testSoftDeleteObservationBlankObsId(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.softDeleteObservation(myOR1.Id);
        Test.stopTest();
        
    }
    
    public static testMethod void testSearchTest(){
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        Map<String, String> params = new Map<String, String>();
        params.put('searchKey', '10');
        params.put('observationId', myObservationList.get(0).Id);
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.searchTest(params);
        Test.stopTest();
    }
    
    public static testMethod void testSearchTestExep(){
        
        Map<String, String> params = null;
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.searchTest(params);
        Test.stopTest();
    }
    
    public static testMethod void testSearchTestQueryExp(){
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        Map<String, String> params = new Map<String, String>();
        params.put('searchKey', '10');
        params.put('observationId', myOSR1.Id);
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.searchTest(params);
        Test.stopTest();
    }
    
    public static testMethod void testUpdateObservationTest(){
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        Map<String, String> params = new Map<String, String>();
        params.put('osrId', myOSR1.Id);
        params.put('observationId', myObservationList.get(0).Id);
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.updateObservationTest(params);
        Test.stopTest();
    }
    
    public static testMethod void testUpdateObservationTestWithExep(){
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        Map<String, String> params = new Map<String, String>();
        params.put('osrId', myOR1.Id);
        params.put('observationId', myObservationList.get(0).Id);
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.updateObservationTest(params);
        Test.stopTest();
    }
    
    public static testMethod void testUpdateObservationTestObsIdBlank(){
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        Map<String, String> params = new Map<String, String>();
        params.put('osrId', myOR1.Id);
        params.put('observationId', '');
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.updateObservationTest(params);
        Test.stopTest();
    }
    
    public static testMethod void testUpdateObservationTestOsrIdBlank(){
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        Map<String, String> params = new Map<String, String>();
        params.put('osrId', '');
        params.put('observationId', myObservationList.get(0).Id);
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.updateObservationTest(params);
        Test.stopTest();
    }
    
    public static testMethod void testUpdateObservationTestExp(){
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        
        Map<String, String> params = new Map<String, String>();
        params.put('osrId', myObservationList.get(0).Id);
        params.put('observationId', myOR1.Id);
        
        Test.startTest();
        Map<String, String> returnVal = RevSys_Obs_ButtonCmpController.updateObservationTest(params);
        Test.stopTest();
    }
    
}