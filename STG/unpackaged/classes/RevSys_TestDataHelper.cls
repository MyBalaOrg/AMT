/*___________________________________________________
*@Name:     RevSys_TestDataHelper
*@Author:   Chuck Walley
*@Created:  Date: 11/12/2017
*@Used_By:  Review Systems
*___________________________________________________
*@Description: Generates test data for Review Systems test classes 
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest(SeeAllData=false)

public class RevSys_TestDataHelper {  
    /**
    *————————————————————————————————————————————————————
    * @Name: buildTestData
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void buildTestData() 
    {
        system.debug('HELPER RevSys_TestDataHelper buildTestData-Start');     
        
        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Emp Cert: Num Days to Check for Reqs';
        setting.CsvString__c = '1200';    
        insert setting;

        setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Earliest Amtrak Date';
        setting.CsvString__c = '1971-10-30';    
        insert setting;

        // Bypass validation rules because they will be added ad infinitum

        SPARTN_BypassRuleSettings__c orgs = SPARTN_BypassRuleSettings__c.getOrgDefaults();  
        orgs.Processes__c = true; 
        orgs.ValidationRules__c = true; 
        orgs.WorkflowRules__c = true; 
        insert orgs; 

        system.debug('orgs ' + orgs); 

        // Account 

        List<Account> myAccountList = new List<Account>(); 

        Account amtrakAcct = new Account
        (
            Name='Amtrak'
        );
        myAccountList.add(amtrakAcct); 

        Account foreignRrAcct = new Account
        (
            Name='Foreign Railroad'
        );
        myAccountList.add(foreignRrAcct); 

        system.debug('AAAAAAAAAA Inserting Account'); 

        INSERT myAccountList; 


        // POSITION

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

        Position__c PosEmployeeA2 = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Engineer',
                Job_Title__c                    = 'Transportation Engineer',
                Position_ID__c                  = '10000002',
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
            myPositionList.add(PosEmployeeA2); 

        Position__c PosEmployeeA3 = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Engineer',
                Job_Title__c                    = 'Transportation Engineer',
                Position_ID__c                  = '10000003',
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
            myPositionList.add(PosEmployeeA3); 

        Position__c PosEmployeeB1 = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Conductor',
                Job_Title__c                    = 'Transportation Conductor',
                Position_ID__c                  = '10000004',
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
            myPositionList.add(PosEmployeeB1); 

        Position__c PosEmployeeB2 = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Conductor',
                Job_Title__c                    = 'Transportation Conductor',
                Position_ID__c                  = '10000005',
                Cost_Center__c                  = '1234',
                Cost_Center_Name__c             = 'Cost Center',
                Region__c                       = 'Region 1',
                //Division__c                     = 'Division 11',
                //Subdivision__c                  = 'Subdivision 111', 
                Dept_Code_Description__c        = 'Transportation',
                //Craft_Code_Description__c       = 'Conductor',
                //Crew_Base__c                    = 'Base1',
                HoursOfSericeEmployee__c   = true,
                Personnel_Area__c               = '1234'
            );
            myPositionList.add(PosEmployeeB2); 

        Position__c PosEmployeeB3 = new Position__c
            (
                //RecordTypeId                    = null,
                Name                            = 'Transportation Conductor',
                Job_Title__c                    = 'Transportation Conductor',
                Position_ID__c                  = '10000006',
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
            myPositionList.add(PosEmployeeB3); 


        INSERT myPositionList;


        // Contact 

        List<Contact> myContactList = new List<Contact>(); 

        // supervisors
            Contact supervisorA = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Supervisor', 
                FirstName           ='Amy', 
                Department          ='Transportation',
                Employment_Status__c = 'Active',
                Personnel_Number__c = 10000000,
                Email               = 'amy.supervisor@amtrak.com',
                PositionLookup__c   = PosSupervisorA.Id
            );
            myContactList.add(supervisorA); 

            Contact supervisorB = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Supervisor', 
                FirstName           ='Bob', 
                Personnel_Number__c = 20000000,
                Employment_Status__c = 'Active',
                Department          ='Transportation',
                Email               = 'bob.supervisor@amtrak.com',
                PositionLookup__c   = PosSupervisorB.Id
            );
            myContactList.add(supervisorB); 

        // employees for supervisor A

            Contact employeeA1 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Abigale', 
                Personnel_Number__c = 10000001,
                Employment_Status__c = 'Active',
                Department          ='Transportation',
                Email               = 'abigale.employee@amtrak.com',
                PositionLookup__c   = PosEmployeeA1.Id
            );
            myContactList.add(employeeA1); 

            Contact employeeA2 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Adam', 
                Personnel_Number__c = 10000002,
                Employment_Status__c = 'Active',
                Department          ='Transportation',
                Email               = 'adam.employee@amtrak.com',
                PositionLookup__c   = PosEmployeeA2.Id
            );
            myContactList.add(employeeA2); 

            Contact employeeA3 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Ali', 
                Personnel_Number__c = 10000003,
                Employment_Status__c = 'Active',
                Department          ='Transportation',
                Email               = 'ali.employee@amtrak.com',
                PositionLookup__c   = PosEmployeeA3.Id
            );
            myContactList.add(employeeA3); 

        // employees for supervisor B

            Contact employeeB1 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Babu', 
                Personnel_Number__c = 20000001,
                Employment_Status__c = 'Active',
                Department          ='Transportation',
                Email               = 'babu.employee@amtrak.com',
                PositionLookup__c   = PosEmployeeB1.Id
            );
            myContactList.add(employeeB1); 

            Contact employeeB2 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Barbara', 
                Personnel_Number__c = 20000002,
                Employment_Status__c = 'Active',
                Department          ='Transportation',
                Email               = 'barbara.employee@amtrak.com',
                PositionLookup__c   = PosEmployeeB2.Id
            );
            myContactList.add(employeeB2); 

            Contact employeeB3 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Bose', 
                Personnel_Number__c = 20000003,
                Employment_Status__c = 'Active',
                Department          ='Transportation',
                Email               = 'bose.employee@amtrak.com',
                PositionLookup__c   = PosEmployeeB3.Id
            );
            myContactList.add(employeeB3); 

        // nurse
            Contact nurseA = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Nurse', 
                FirstName           ='Nancy', 
                Personnel_Number__c = 30000000,
                Department          ='Transportation',
                Email               = 'nancy.nurse@amtrak.com'
            );
            myContactList.add(nurseA); 

        system.debug('BBBBBBBBBB Inserting Contact'); 

        INSERT myContactList; 

        // New System Admin User 

        User mySysAdminUser =  
        [    SELECT Id FROM User 
             WHERE  Id != :UserInfo.getUserId() 
             AND    Profile.Name = 'System Administrator'
             AND    IsActive = true
             LIMIT  1
        ];

        // USERS 

        System.runAs(mySysAdminUser) {


            Id myAmtrakEmployeeProfileId = [SELECT Id FROM Profile WHERE Name = 'Amtrak Employee'].Id;
            
            List<User> myUserList = new List<User>(); 


            User userSupervisorA = new User 
            ( 
                FirstName           = 'Amy',
                LastName            = 'Supervisor',
                Username            = 'amy.supervisor@amtrak.com',
                Alias               = 'superamy',
                Email               = 'amy.supervisor@amtrak.com',
                Status__c           = 'Active',
                EmployeeNumber      = '10000000',
                ProfileId           = myAmtrakEmployeeProfileId,
                TimeZoneSidKey      = 'America/New_York',
                EmailEncodingKey    = 'UTF-8',
                LanguageLocaleKey   = 'en_US',
                LocaleSidKey        = 'en_US'
            );
            myUserList.add(userSupervisorA); 

            User userSupervisorB = new User 
            ( 
                FirstName           = 'Bob',
                LastName            = 'Supervisor',
                Username            = 'bob.supervisor@amtrak.com',
                Alias               = 'superbob',
                Email               = 'bob.supervisor@amtrak.com',
                Status__c           = 'Active',
                EmployeeNumber      = '20000000',
                ProfileId           = myAmtrakEmployeeProfileId,
                TimeZoneSidKey      = 'America/New_York',
                EmailEncodingKey    = 'UTF-8',
                LanguageLocaleKey   = 'en_US',
                LocaleSidKey        = 'en_US'
            );
            myUserList.add(userSupervisorB); 

            User userNurseA = new User 
            ( 
                FirstName           = 'Nancy',
                LastName            = 'Nurse',
                Username            = 'nancy.nurse@amtrak.com',
                Alias               = 'nursenan',
                Email               = 'nancy.nurse@amtrak.com',
                Status__c           = 'Active',
                EmployeeNumber      = '30000000',
                ProfileId           = myAmtrakEmployeeProfileId,
                TimeZoneSidKey      = 'America/New_York',
                EmailEncodingKey    = 'UTF-8',
                LanguageLocaleKey   = 'en_US',
                LocaleSidKey        = 'en_US'
            );
            myUserList.add(userNurseA); 

            system.debug('CCCCCCCCCC Inserting Users'); 

            INSERT myUserList; 
        }

        // Map contacts

        List<Contact> myEmployeeList = new List<Contact> 
        ( 
            [SELECT Id, Name, Email, Personnel_Number__c
             FROM   Contact ]
        );

        Map<String,Contact> myContactMap = new Map<String,Contact>(); 

        for(Contact myEmployee :myEmployeeList)
        {
            myContactMap.put(myEmployee.Email,myEmployee); 
        }

        Contact myEmployee = myContactMap.get('abigale.employee@amtrak.com'); 

        system.assertNotEquals(null,myEmployee); 

        // Create Occupation Requirements (Observations)  
        OccupationRequirement__c myObs1 = new OccupationRequirement__c 
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID, 
            TestNumber__c   = '100', 
            TestName__c     = 'Test 100',
            Name            = '100 - Test 100',
            Status__c       = 'Active'
        ); 

        insert myObs1; 

     
        RuleViolation__c myRuleVio = new RuleViolation__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.RULEVIOLATION_SPARTN_SPARTN_NRPC_3164_VIOLATION_RECTYPE_ID, 
            Name                    = 'Rule Violation', 
            Description__c          = 'Rule Violation', 
            RichTextDescription__c  = 'Rule Violation', 
            Sequence__c             = 1,
            Status__c               = 'Active'
        );

        insert myRuleVio; 

        List<Observation__c> myObservationList = new List<Observation__c>(); 

        // Create observations

        User mySysAdminUser2 =  
        [    SELECT Id FROM User 
             WHERE  Id != :UserInfo.getUserId() 
             AND    Profile.Name = 'System Administrator'
             AND    IsActive = true
             LIMIT  1
        ];

        // USERS 

        System.runAs(mySysAdminUser2) {

            Observation__c obs1 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID,
                Status__c                       = 'Submitted',
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = myEmployee.Id,
                OperatedFromText__c 			= '123',
                OperatedToText__c				='246',
                Number_of_Workers_Observed__c = 1
            );
            myObservationList.add(obs1);

            Observation__c obs2 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1876_RECTYPE_ID,
                Status__c                       = 'Submitted',
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = myEmployee.Id,
                 OperatedFromText__c 			= '123',
                OperatedToText__c				='246',
                Number_of_Workers_Observed__c = 1
            );
            myObservationList.add(obs2);

            Observation__c obs3 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID,
                Status__c                       = 'Submitted',
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = myEmployee.Id,
                 OperatedFromText__c 			= '123',
                OperatedToText__c				='246',
                Number_of_Workers_Observed__c = 1
            );
            myObservationList.add(obs3);

            Observation__c obs4 = new Observation__c
            ( 
                RecordTypeId                    = RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID,
                Status__c                       = 'Submitted',
                Date__c                         = Date.today(), 
                Department__c                   = 'Engineering ET',
                Employee__c                     = myEmployee.Id,
                 OperatedFromText__c 			= '123',
                OperatedToText__c				='246',
                Number_of_Workers_Observed__c = 1
            );
            myObservationList.add(obs4);

            system.debug('DDDDDDDDDDD Inserting Observations'); 

            insert myObservationList; 

            system.debug('HELPER RevSys_TestDataHelper buildTestData-End');     
            return; 
        }

    }
    public static testMethod void buildCertificationData() {

        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Emp Cert: Num Days to Check for Reqs';
        setting.CsvString__c = '1200';    
        insert setting;

        setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Earliest Amtrak Date';
        setting.CsvString__c = '1971-10-30';    
        insert setting;

        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test LastName';
        c.Employment_Status__c = 'Active';
        c.Department = 'Mechanical';
        insert c;

        OccupationCertification__c oc = new OccupationCertification__c();
        oc.Status__c = RevSys_StaticUtility.ACTIVE;
        oc.Name = 'Test OC';
        oc.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        oc.Frequency__c = 'Months';
        oc.LengthOfPeriod__c = 10;
        insert oc;

        OccupationRequirement__c oreq = new OccupationRequirement__c();
        oreq.Status__c =  RevSys_StaticUtility.ACTIVE;
        oreq.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        oreq.Name =  'Test Requirement';
        oreq.Source__c = 'Observation';
        oreq.SourceRecordType__c = 'FORM-1872';
        oreq.TestNumber__c ='TestNumber';
        oreq.TestName__c ='101';
        insert oreq;

        OccupationSpecificRequirement__c osr  =  new OccupationSpecificRequirement__c();
        osr.RecordTypeId    = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        osr.Status__c       = RevSys_StaticUtility.ACTIVE;
        osr.Frequency__c = 'Days';
        osr.LengthOfPeriod__c = 1;
        osr.Certification__c = oc.Id;
        osr.Requirement__c = oreq.Id;
        insert osr;

        EmployeeCertification__c ecRecord = new EmployeeCertification__c();
        ecRecord.Status__c = RevSys_StaticUtility.PENDING;
        ecRecord.Employee__c = c.Id;
        ecRecord.Certification__c = oc.Id;
        ecRecord.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        insert ecRecord;
    }
}