@isTest(SeeAllData = false)
public class Revsys_Non1872FindingsController_Test {
    
    @TestSetup
    public static void loadTestData() {
        
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
        
        //position list 
        List<Position__c> myPositionList = new List<Position__c>(); 
        
        Position__c PosSupervisorA = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Engineer',
                Job_Title__c                    = 'Transportation Engineer',
                Position_ID__c                  = '10000000',
                Cost_Center__c                  = '1234',
                Cost_Center_Name__c             = 'Cost Center',
                Region__c                       = 'Region 1',
                //Division__c                     = 'Division 11',
                //Subdivision__c                  = 'Subdivision 111', 
                Dept_Code_Description__c        = 'Transportation',
                //Craft_Code_Description__c       = 'Engineer',
                //Crew_Base__c                    = 'Base1',
                HoursOfSericeEmployee__c    = true,
                Personnel_Area__c               = '1234'
            );
        myPositionList.add(PosSupervisorA); 
        
        Position__c PosSupervisorB = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Conductor',
                Job_Title__c                    = 'Transportation Conductor',
                Position_ID__c                  = '20000000',
                Cost_Center__c                  = '1234',
                Cost_Center_Name__c             = 'Cost Center',
                Region__c                       = 'Region 1',
                //Division__c                     = 'Division 11',
                //Subdivision__c                  = 'Subdivision 111', 
                Dept_Code_Description__c        = 'Transportation',
                //Craft_Code_Description__c       = 'Conductor',
                //Crew_Base__c                    = 'Base1',
                HoursOfSericeEmployee__c    = true,
                Personnel_Area__c               = '1234'
            );
        myPositionList.add(PosSupervisorB); 
        
        Position__c PosEmployeeA1 = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Engineer',
                Job_Title__c                    = 'Transportation Engineer',
                Position_ID__c                  = '10000001',
                Cost_Center__c                  = '1234',
                Cost_Center_Name__c             = 'Cost Center',
                Region__c                       = 'Region 1',
                //Division__c                     = 'Division 11',
                //Subdivision__c                  = 'Subdivision 111', 
                Dept_Code_Description__c        = 'Transportation',
                //Craft_Code_Description__c       = 'Engineer',
                //Crew_Base__c                    = 'Base1',
                HoursOfSericeEmployee__c   = true,
                Personnel_Area__c               = '1234'
            );
        myPositionList.add(PosEmployeeA1); 
        
        INSERT myPositionList;
        
        Position__c PosEmployeeA2 = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Engineer',
                Job_Title__c                    = 'Transportation Engineer',
                Position_ID__c                  = '10000006',
                Cost_Center__c                  = '1234',
                Cost_Center_Name__c             = 'Cost Center',
                Region__c                       = 'Region 1',
                Generated_Reports_To_Position__c = myPositionList.get(0).Id,
                //Division__c                     = 'Division 11',
                //Subdivision__c                  = 'Subdivision 111', 
                Dept_Code_Description__c        = 'Transportation',
                //Craft_Code_Description__c       = 'Engineer',
                //Crew_Base__c                    = 'Base1',
                HoursOfSericeEmployee__c   = true,
                Personnel_Area__c               = '1234'
            );
        
        insert PosEmployeeA2;
        
        //contact
        List<Contact> myContactList = new List<Contact>(); 
        
        // supervisors
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
        
        Contact supervisorB = new Contact
            (
                //AccountId           = amtrakAcct.id, 
                LastName            ='Supervisor', 
                FirstName           ='Bob', 
                Personnel_Number__c = 20000000,
                Employment_Status__c = 'Active',
                Email               = 'bob.supervisor@amtrak.com',
                Department = 'Mechanical',
                Craft__c = 'Student Engineer'
                //PositionLookup__c   = PosSupervisorB.Id
            );
        myContactList.add(supervisorB);
        
        // employees for supervisor A
        
        Contact employeeA1 = new Contact
            (
                //AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Abigale', 
                Personnel_Number__c = 10000001,
                Employment_Status__c = 'Active',
                Email               = 'abigale.employee@amtrak.com',
                Department = 'Mechanical',
                Craft__c = 'Conductor'
            );
        myContactList.add(employeeA1);
        
        Contact employeeA2 = new Contact
            (
                LastName            ='TestLast1', 
                FirstName           ='TestFirst1', 
                Personnel_Number__c = 1110920,
                Employment_Status__c = 'Active',
                Email               = 'test1@amtrak.com',
                Department = 'Mechanical',
                Craft__c = 'Test Craft1'
            );
        myContactList.add(employeeA2);
        
        insert myContactList;
        
        OccupationCertification__c myOC = new OccupationCertification__c(
            Name = 'Test SPARTN Certification',
            Frequency__c = 'Months',
            LengthOfPeriod__c = 2,
            Status__c = 'Active',
            CertificationType__c = 'Conductor',
            RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID
        );
        
        insert myOC;
        
        myOSR1.Certification__c = myOC.Id;
        update myOSR1;
        
        Id conductorContactId = null;
        for(Contact c : myContactList){
            string firstName = c.FirstName;
            if(firstName.equalsIgnoreCase('Abigale')){
                conductorContactId = c.Id;
                break;
            }
        }
        
        //observations
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
        
        Observation__c obs2 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID,
                Status__c                       = 'Draft',
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = supervisorA.Id,
                Number_of_Workers_Observed__c = 1,
                OccupationSpecificRequirement__c = myOSR1.Id
            );
        myObservationList.add(obs2);
        
        Observation__c obs3 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID,
                Status__c                       = 'Draft',
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = supervisorA.Id,
                Number_of_Workers_Observed__c = 1,
                OccupationSpecificRequirement__c = myOSR1.Id
            );
        myObservationList.add(obs3);
        
        Observation__c obs4 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID,
                Status__c                       = 'Draft',
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = supervisorA.Id,
                Number_of_Workers_Observed__c = 1,
                OccupationSpecificRequirement__c = myOSR1.Id
            );
        myObservationList.add(obs4);
        
        insert myObservationList; 
    }
    
    public static testMethod void testNon1872FindingCtrl(){
        
        //occupation requirement
        OccupationRequirement__c myOR1 = [select Id, RecordTypeId, TestNumber__c, TestName__c, Name, Status__c from OccupationRequirement__c limit 10000];
        
        //OccupationSpecificRequirement__c
        OccupationSpecificRequirement__c myOSR1 = [select Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, Observation__c, Status__c from OccupationSpecificRequirement__c limit 10000];
        
        //contact list 
        List<Contact> myContactList = [select Id, LastName, FirstName, Personnel_Number__c, Email from Contact limit 10000];
        Contact contact1 = myContactList.get(0);
        
        //observations
        List<Observation__c> myObservationList = [select Id, RecordTypeId, Status__c, Date__c, Department__c, Employee__c, Number_of_Workers_Observed__c, OccupationSpecificRequirement__c from Observation__c limit 10000];
        Observation__c obs1 = myObservationList.get(0);
        
        Test.startTest();
        Revsys_Non1872FindingsController non1872 = new  Revsys_Non1872FindingsController();
        non1872.observationId = obs1.Id;
        non1872.getfindings();
        List<Finding__c> myFindingList = [SELECT Id FROM Finding__c WHERE Observation__c =: obs1.Id];
        System.assertEquals(0, myFindingList.size());
        Test.stopTest();
    }
    }