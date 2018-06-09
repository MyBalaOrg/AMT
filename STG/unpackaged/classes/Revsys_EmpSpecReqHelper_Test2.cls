/**
*___________________________________________________
*@Name:     Revsys_EmpSpecReqHelper_Test2
*@Author:   Chuck Walley
*@Created:  Date: March 28, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for Revsys_HierarchyAssignmentHelper
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class Revsys_EmpSpecReqHelper_Test2 {   
    
   
    //Creating Test Data
    @TestSetup
    public static void loadTestData() {

        SPARTN_BypassRuleSettings__c orgsettings = SPARTN_BypassRuleSettings__c.getOrgDefaults();  
        orgsettings.Processes__c = true; 
        orgsettings.ValidationRules__c = true; 
        insert orgsettings;   

        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Emp Cert: Num Days to Check for Reqs';
        setting.CsvString__c = '1200';    
        insert setting;

        setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Earliest Amtrak Date';
        setting.CsvString__c = '1971-10-30';    
        insert setting;

        // Occupation Requirements - Requirements 

        List<OccupationRequirement__c> myOccReqList = new List<OccupationRequirement__c>(); 

        OccupationRequirement__c myOr1 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name                = 'Medical Exam',
            Source__c           = 'Employee Result Summary',
            SourceRecordType__c = 'Medical, Hearing and Vision',
            SourceTestType__c   = 'Medical Examination',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr1); 

        OccupationRequirement__c myOr2 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name                = 'Hearing Exam',
            Source__c           = 'Employee Result Summary',
            SourceRecordType__c = 'Medical, Hearing and Vision',
            SourceTestType__c   = 'Hearing Test',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr2); 

        OccupationRequirement__c myOr3 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name                = 'Vision Exam',
            Source__c           = 'Employee Result Summary',
            SourceRecordType__c = 'Medical, Hearing and Vision',
            SourceTestType__c   = 'Vision Test',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr3); 

        OccupationRequirement__c myOr4 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name                = 'National Driving Review',
            Source__c           = 'Employee Result Summary',
            SourceRecordType__c = 'Motor Vehicle Review',
            SourceTestType__c   = 'National Review',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr4); 

        OccupationRequirement__c myOr5 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name                = 'State Driving Review',
            Source__c           = 'Employee Result Summary',
            SourceRecordType__c = 'Motor Vehicle Review',
            SourceTestType__c   = 'State Review',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr5); 

        OccupationRequirement__c myOr6 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name                = 'Employment History Review',
            Source__c           = 'Employee Result Summary',
            SourceRecordType__c = 'Employment History',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr6); 

        OccupationRequirement__c myOr7 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name                = '1872 Observation 101 Requirement',
            Source__c           = 'Observation',
            SourceRecordType__c = 'Form-1872',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr7); 

        OccupationRequirement__c myOr8 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name                = '1875 Observation Requirement',
            Source__c           = 'Observation',
            SourceRecordType__c = 'Form-1875',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr8); 

        OccupationRequirement__c myOr9 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name                = '1877 Observation Requirement',
            Source__c           = 'Observation',
            SourceRecordType__c = 'Form-1877',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr9); 

        // Occupation Requirements - Observations 

        OccupationRequirement__c myOr10 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
            Name                = '101 - Stopping within One-Half the Range of Vision',
            Source__c           = 'Observation',
            SourceRecordType__c = 'Form-1872',
            TestNumber__c       = '101',
            TestName__c         = 'Stopping within One-Half the Range of Vision',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr10); 

        OccupationRequirement__c myOr11 = new OccupationRequirement__c 
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
            Name                = '102 - Stop Signal',
            Source__c           = 'Observation',
            SourceRecordType__c = 'Form-1872',
            TestNumber__c       = '102',
            TestName__c         = 'Stop Signal',
            Status__c           = 'Active'
        );
        myOccReqList.add(myOr11); 

        INSERT myOccReqList; 

        // Occupation Certification - Certifications

        List<OccupationCertification__c> myOcList = new List<OccupationCertification__c>(); 

        OccupationCertification__c myOc1 = new OccupationCertification__c 
        (  
            RecordTypeId = Revsys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID, 
            Name                    = 'Conductor Certification', 
            CertificationType__c    = 'Conductor',
            StartDate__c            = system.today(), 
            Frequency__c            = 'Years',
            LengthOfPeriod__c       = 3,
            Status__c               = 'Active'
        );
        myOcList.add(myOc1); 

        OccupationCertification__c myOc2 = new OccupationCertification__c 
        (  
            RecordTypeId = Revsys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID, 
            Name                    = 'Engineer Certification', 
            CertificationType__c    = 'Engineer',
            StartDate__c            = system.today(), 
            Frequency__c            = 'Years',
            LengthOfPeriod__c       = 3,
            Status__c               = 'Active'
        );
        myOcList.add(myOc2); 

        INSERT myOcList; 

        // Occupation Specific Requirement - Certifications 

        List<OccupationSpecificRequirement__c> myOsrList = new List<OccupationSpecificRequirement__c>(); 

        OccupationSpecificRequirement__c myOsr1 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID, 
            Certification__c    = myOc1.Id,     // Conductor
            Requirement__c      = myOr1.Id,     // Medical Test
            Frequency__c        = 'Days',
            LengthOfPeriod__c   = 450,
            Status__c           = 'Active'
        );
        myOsrList.add(myOsr1); 

        OccupationSpecificRequirement__c myOsr2 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID, 
            Certification__c    = myOc1.Id,     // Conductor
            Requirement__c      = myOr2.Id,     // Hearing Test
            Frequency__c        = 'Days',
            LengthOfPeriod__c   = 450,
            Status__c           = 'Active'
        );
        myOsrList.add(myOsr2); 

        OccupationSpecificRequirement__c myOsr3 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID, 
            Certification__c    = myOc1.Id,     // Conductor
            Requirement__c      = myOr3.Id,     // Vision Test
            Frequency__c        = 'Days',
            LengthOfPeriod__c   = 450,
            Status__c           = 'Active'
        );
        myOsrList.add(myOsr3); 

        OccupationSpecificRequirement__c myOsr4 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID, 
            Certification__c    = myOc1.Id,     // Conductor
            Requirement__c      = myOr4.Id,     // National Driving Review
            Frequency__c        = 'Days',
            LengthOfPeriod__c   = 366,
            Status__c           = 'Active'
        );
        myOsrList.add(myOsr4); 

        OccupationSpecificRequirement__c myOsr5 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID, 
            Certification__c    = myOc1.Id,     // Conductor
            Requirement__c      = myOr5.Id,     // State Driving Review 
            Frequency__c        = 'Days',
            LengthOfPeriod__c   = 366,
            Status__c           = 'Active'
        );
        myOsrList.add(myOsr5); 

        OccupationSpecificRequirement__c myOsr6 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID, 
            Certification__c    = myOc1.Id,     // Conductor
            Requirement__c      = myOr6.Id,     // Employment History 
            Frequency__c        = 'Days',
            LengthOfPeriod__c   = 366,
            Status__c           = 'Active'
        );
        myOsrList.add(myOsr6); 

        OccupationSpecificRequirement__c myOsr8 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID, 
            Certification__c    = myOc1.Id,     // Conductor
            Requirement__c      = myOr8.Id,     // 1875
            Frequency__c        = 'Days',
            LengthOfPeriod__c   = 366,
            Status__c           = 'Active'
        );
        myOsrList.add(myOsr8); 

        OccupationSpecificRequirement__c myOsr9 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID, 
            Certification__c    = myOc1.Id,     // Conductor
            Requirement__c      = myOr9.Id,     // 1877 
            Frequency__c        = 'Days',
            LengthOfPeriod__c   = 366,
            Status__c           = 'Active'
        );
        myOsrList.add(myOsr9); 


        OccupationSpecificRequirement__c myOsr7 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID, 
            Certification__c    = myOc1.Id,     // Conductor
            Requirement__c      = myOr7.Id,     // 1872 101 
            Frequency__c        = 'Days',
            LengthOfPeriod__c   = 366,
            Status__c           = 'Active'
        );
        myOsrList.add(myOsr7); 

        OccupationSpecificRequirement__c myOsr71 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID, 
            Observation__c       = myOr10.Id, // 101
            TargetRequirement__c = myOr7.Id,  // 1872 101 Test 
            Frequency__c         = 'Days',
            LengthOfPeriod__c    = 366,
            Status__c            = 'Active'
        );
        myOsrList.add(myOsr71); 

        OccupationSpecificRequirement__c myOsr10 = new OccupationSpecificRequirement__c
        (  
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID,
            Observation__c              = myOr10.Id, // 101
            ObservationDepartment2__c   = 'Transportation',
            ObservationCraft2__c        = 'All',
            Status__c                   = 'Active'
        );
        myOsrList.add(myOsr10); 


        INSERT myOsrList; 

        List<Account> myAccountList = new List<Account>(); 

        Account amtrakAcct = new Account
        (
            Name='Amtrak'
        );
        myAccountList.add(amtrakAcct); 

        Account foreignRrAcct = new Account
        (
            Name = 'Foreign Railroad',
            Type = 'Foreign Railroad'
        );
        myAccountList.add(foreignRrAcct); 

        INSERT myAccountList; 

        // Contact 

        List<Contact> myContactList = new List<Contact>(); 

        // supervisors
        Contact supervisorA = new Contact
        (
            AccountId           = amtrakAcct.id, 
            LastName            ='Supervisor', 
            FirstName           ='Amy', 
            Personnel_Number__c = 10000000,
            Email               = 'amy.supervisor@amtrak.com',
            Department          = 'TRANSPORTATION',
            Craft__c            = 'Conductor',
            Employment_Status__c= 'Active'

        );
        myContactList.add(supervisorA); 

        Contact supervisorB = new Contact
        (
            AccountId           = amtrakAcct.id, 
            LastName            ='Supervisor', 
            FirstName           ='Bob', 
            Personnel_Number__c = 20000000,
            Email               = 'bob.supervisor@amtrak.com',
            Department          = 'TRANSPORTATION',
            Craft__c            = 'Engineer',
            Employment_Status__c= 'Active'

        );
        myContactList.add(supervisorB); 

        INSERT myContactList; 

        // Employment Result Summary 

        List<EmployeeResultSummary__c> mySummList = new List<EmployeeResultSummary__c>(); 

        EmployeeResultSummary__c mySum1 = new EmployeeResultSummary__c
        (  
            RecordTypeId = Revsys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID, 
            Employee__c         = supervisorA.Id, 
            EvaluationDate__c   = system.today().addDays(-50), 
            Type__c             = 'Medical Examination',
            Result__c           = 'Meets Medical Standards'
        );
        mySummList.add(mySum1);

        EmployeeResultSummary__c mySum2 = new EmployeeResultSummary__c
        (  
            RecordTypeId = Revsys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID, 
            Employee__c         = supervisorA.Id, 
            EvaluationDate__c   = system.today().addDays(-50), 
            Type__c             = 'Hearing Test',
            Result__c           = 'No Restrictions'
        );
        mySummList.add(mySum2);

        EmployeeResultSummary__c mySum3 = new EmployeeResultSummary__c
        (  
            RecordTypeId = Revsys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID, 
            Employee__c         = supervisorA.Id, 
            EvaluationDate__c   = system.today().addDays(-50), 
            Type__c             = 'Vision Test',
            FieldTestAdministered__c
                                = 'Yes',

            Result__c           = 'No Restrictions'
        );
        mySummList.add(mySum3);

        EmployeeResultSummary__c mySum4 = new EmployeeResultSummary__c
        (  
            RecordTypeId = Revsys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID,
            Employee__c                         = supervisorA.Id, 
            Result__c                           = 'Pass',
            LicenseNumber__c                    = '1234',
            LicenseType__c                      = 'U.S. Driver\'s License',
            State__c                            = 'DC',
            StateReviewDate__c                  = system.today().addDays(-50), 
            NdrReviewDate__c                    = system.today().addDays(-50), 
            AlcoholOrDrugViolationRevealed__c   = false
        );
        mySummList.add(mySum4);

        EmployeeResultSummary__c mySum5 = new EmployeeResultSummary__c
        (  
            RecordTypeId = Revsys_StaticUtility.EMP_RES_SUMM_EMPHISTORY_RECTYPE_ID, 
            Employee__c         = supervisorA.Id, 
            EvaluationDate__c   = system.today().addDays(-50), 
            WorkedForAnotherRrSinceLastCertDate__c 
                                = 'Yes', 
            ForeignRailroad__c  = foreignRrAcct.Id,
            StartDate__c        = system.today().addYears(-10),
            TerminationDate__c  = system.today().addYears(-1), 
            CanEmployeeBeCertified__c
                                = 'Yes'
        );
        mySummList.add(mySum5);

        INSERT mySummList;       

        // 1872 Observations

        List<Observation__c> myObsList = new List<Observation__c> (); 

        Observation__c myOb1 = new Observation__c 
        (  
            RecordTypeId = Revsys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID, 
            Status__c                        = 'Submitted',
            Date__c                          = Date.today(), 
            Employee__c                      = supervisorA.Id,
            OccupationSpecificRequirement__c = myOsr10.Id,  // 101 Transportation/All 
            Result__c                        = Label.Revsys_1872_Result_Compliant
        );
        myObsList.add(myOb1); 

        Observation__c myOb2 = new Observation__c 
        (  
            RecordTypeId = Revsys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID, 
            Status__c                        = 'Draft',
            Date__c                          = Date.today(), 
            Employee__c                      = supervisorA.Id
        );
        myObsList.add(myOb2); 

        Observation__c myOb3 = new Observation__c 
        (  
            RecordTypeId = Revsys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID, 
            Status__c                        = 'Draft',
            Date__c                          = Date.today(), 
            Employee__c                      = supervisorA.Id
        );
        myObsList.add(myOb3); 

        INSERT myObsList; 

         
        

        // Finding

        List<Finding__c> myFindList = new List<Finding__c>(); 

        Finding__c myFind2 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb2.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 10,
            Category__c         = 'Test-1875',
            Sub_category__c     = 'Operating Rules',
            Score__c            = 1
        ); 
        myFindList.add(myFind2); 

        myFind2 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb2.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 20,
            Category__c         = 'Test-1875',
            Sub_category__c     = 'Physical Characteristics',
            Score__c            = 1
        ); 
        myFindList.add(myFind2); 

        myFind2 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb2.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 100,
            Category__c         = 'Test-1875',
            Sub_category__c     = 'Train Speed',
            Score__c            = 1
        ); 
        myFindList.add(myFind2); 

        myFind2 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb2.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 130,
            Category__c         = 'Test-1875',
            Sub_category__c     = 'Safety',
            Score__c            = 1
        ); 
        myFindList.add(myFind2); 

        myFind2 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb2.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 140,
            Category__c         = 'Test-1875',
            Sub_category__c     = 'Signal Compliance',
            Score__c            = 1
        ); 
        myFindList.add(myFind2); 



        Finding__c myFind3 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb2.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 10,
            Category__c         = 'Test-1877',
            Sub_category__c     = 'Operating Rules',
            Score__c            = 1
        ); 
        myFindList.add(myFind3); 

        myFind3 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb2.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 130,
            Category__c         = 'Test-1877',
            Sub_category__c     = 'Safety',
            Score__c            = 1
        ); 
        myFindList.add(myFind3); 

        myFind3 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb2.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 140,
            Category__c         = 'Test-1877',
            Sub_category__c     = 'Signal Compliance',
            Score__c            = 1
        ); 
        myFindList.add(myFind3); 

        myFind3 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb2.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 190,
            Category__c         = 'Test-1877',
            Sub_category__c     = 'CFR Part 218',
            Score__c            = 1
        ); 
        myFindList.add(myFind3); 

        INSERT myFindList; 

        List<Observation__c> myUpdateObList = new List<Observation__c>(); 

        myOb2.Status__c = 'Submitted'; 
        myOb3.Status__c = 'Submitted'; 

        myUpdateObList.add(myOb2); 
        myUpdateObList.add(myOb3); 

        UPDATE myUpdateObList; 
                                                                    

    }
    /*
    *************************************************************************
    USE CASES: 
    Medical: (Evaluation Date) 
    (1) - Meets Medical Standards 
    (2) - Does Not Meet Medical Standards 
    (3) - Pending return of exam results 
    Hearing: (Evaluation Date) 
    (1) - No Restrictions
    (2) - Restrictions Hearing 
            - Hearing Aid - Both (x) 
            - Hearing Aid - Right 
            - Hearing Aid - Left 
    (3) - Failed Test 
    (4) - Pending return of exam results 
    Vision: (Evaluation Date) 
    (1) - No Restrictions
    (2) - Restrictions - Vision
            - Corrective Lenses (x)  
            - Corrective Lenses - Reading 
    (3) - Failed Test
            - Field Test for Color Recognition = No 
    (4) - Failed Test
            - Field Test for Color Recognition = Yes 
            - Field Test Result = Fail
    (5) - Failed Test
            - Field Test for Color Recognition = Yes 
            - Field Test Result = Pass
    (6) - Pending return of exam results 
    Employment History: (Evaluation Date)
    - Can Employee Be Certified?    
        (1) - Yes 
        (2) - No 
    Motor Vehicle Review: (State Review Date & National Review Date) 
        (1) - Status = Pass
        (2) - Status = Fail
        (3) - Status = Pending
    1872: Date
        (1) - Result = C = Compliance
        (2) - Result = 3 = Failure, Employee removed from service
    1875: 
        (1) - 1
        (2) - 4
    1877: 
        (1) - 1
        (2) - 4 
    *************************************************************************
    */



     /*************************************************************************
     Test 1:   Emloyee Result Summary set up in data load 
     *************************************************************************/
    private static testmethod void test_1() {
        
        // Get all OSR records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('OccupationSpecificRequirement__c');   
        String myQuery = myQuWrap.QueryString; 
        List<OccupationSpecificRequirement__c> myOsrList = Database.query(myQuery); 

        for(OccupationSpecificRequirement__c myRec :myOsrList) {
            system.debug('>>>>> OSR: ' + myRec); 
        }

        // Get all Contact records
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        // Certifications
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myOcList = Database.query(myQuery); 

        Map<String,OccupationCertification__c> myOcByNameMap = new Map<String,OccupationCertification__c>(); 

        for(OccupationCertification__c myOc :myOcList) {
            myOcByNameMap.put(myOc.Name, myOc); 
        }

        Contact myPeep = myEmpByFirstNameMap.get('Amy'); 
        OccupationCertification__c myCert = myOcByNameMap.get('Conductor Certification'); 


        EmployeeCertification__c myEmpCert = new EmployeeCertification__c 
        (  
            RecordTypeId = Revsys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID, 
            Employee__c         =  myPeep.Id,
            Certification__c    =  myCert.Id,
            Status__c           = 'Pending'
        );
       
        INSERT myEmpCert; 

        // Get all ESR records
        myQuWrap = QueryUtility.beginDynamicQuery('EmployeeSpecificRequirement__c');   
        myQuery = myQuWrap.QueryString; 
        List<EmployeeSpecificRequirement__c> myEsrList = Database.query(myQuery); 

        for(EmployeeSpecificRequirement__c myEsr :myEsrList) {
            system.debug('>>>>> ESR: ' + myEsr); 
        }
    }

    /*************************************************************************
     Test 2:   Emloyee Result Summary set up in data load 
     *************************************************************************/

    private static testmethod void test_2() {
        
        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        // pull the ESR Records 
  
        myQuWrap = QueryUtility.beginDynamicQuery('EmployeeResultSummary__c');   
        myQuery = myQuWrap.QueryString; 
        List<EmployeeResultSummary__c> mySummList = Database.query(myQuery); 

        EmployeeResultSummary__c myMedExam      = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myHearingExam  = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myVisionExam   = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myEmployeeHist = new EmployeeResultSummary__c();  
        EmployeeResultSummary__c myMotorVehRev  = new EmployeeResultSummary__c(); 


        for(EmployeeResultSummary__c mySum :mySummList) {
            
            if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID       && 
               mySum.Type__c      == 'Medical Examination') { 
                        myMedExam = mySum; 
                        system.debug('myMedExam ' + myMedExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID  && 
                    mySum.Type__c      == 'Hearing Test') { 
                        myHearingExam  = mySum;
                        system.debug('myHearingExam ' + myHearingExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID  && 
                    mySum.Type__c      == 'Vision Test') { 
                        myVisionExam   = mySum;
                        system.debug('myVisionExam ' + myVisionExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_EMPHISTORY_RECTYPE_ID) { 
                        myEmployeeHist = mySum;
                        system.debug('myEmployeeHist ' + myEmployeeHist);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID) { 
                        myMotorVehRev = mySum;
                        system.debug('myMotorVehRev ' + myMotorVehRev);
            }
        }

        EmployeeResultSummary__c myNewMedExam      = myMedExam.clone(false,false,false,false); 
        EmployeeResultSummary__c myNewHearingExam  = myHearingExam.clone(false,false,false,false); 
        EmployeeResultSummary__c myNewVisionExam   = myVisionExam.clone(false,false,false,false); 
        EmployeeResultSummary__c myNewEmployeeHist = myEmployeeHist.clone(false,false,false,false); 
        EmployeeResultSummary__c myNewMotorVehRev  = myMotorVehRev.clone(false,false,false,false); 


        myNewMedExam.Result__c = 'Does Not Meet Medical Standards'; 
        myNewMedExam.EvaluationDate__c = system.today().addDays(-40); 

        myNewHearingExam.Result__c = Label.RevSys_Generic_Restrictions_Hearing;   
        myNewHearingExam.RestrictionType__c = 'Hearing Aid - Both';                        
        myNewHearingExam.EvaluationDate__c = system.today().addDays(-40); 

        myNewVisionExam.Result__c = 'Restrictions - Vision'; 
        myNewVisionExam.RestrictionType__c = 'Corrective Lenses'; 
        myNewVisionExam.EvaluationDate__c  = system.today().addDays(-40); 

        myNewEmployeeHist.CanEmployeeBeCertified__c = 'No'; 
        myNewEmployeeHist.EvaluationDate__c = system.today().addDays(-40); 

        myNewMotorVehRev.Status__c = 'Fail';
        myNewMotorVehRev.StateReviewDate__c = system.today().addDays(-40); 
        myNewMotorVehRev.NdrReviewDate__c = system.today().addDays(-40); 

        List<EmployeeResultSummary__c> myNewSummList = new List<EmployeeResultSummary__c>(); 

        myNewSummList.add(myNewMedExam); 
        myNewSummList.add(myNewHearingExam); 
        myNewSummList.add(myNewVisionExam); 
        myNewSummList.add(myNewEmployeeHist); 
        myNewSummList.add(myNewMotorVehRev); 

        INSERT myNewSummList; 

        // pull the Observations

        Observation__c myOb1872 = new Observation__c(); 
        Observation__c myOb1875 = new Observation__c(); 
        Observation__c myOb1877 = new Observation__c(); 

        myQuWrap = QueryUtility.beginDynamicQuery('Observation__c');   
        myQuery = myQuWrap.QueryString; 
        List<Observation__c> myObList = Database.query(myQuery); 

        for(Observation__c myOb :myObList) {
            system.debug('myOb ' + myOb);

            if(myOb.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID) { 
                myOb1872 = myOb.clone(false,false,false,false); 
            }
            else if(myOb.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID) { 
                myOb1875 = myOb.clone(false,false,false,false); 
            }
            else if(myOb.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID) { 
                myOb1877 = myOb.clone(false,false,false,false); 
            }
        }

        List<Observation__c> myUpdateObList = new List<Observation__c>(); 

        myOb1872.Result__c = '3 = Failure, Employee removed from service'; 
        myOb1872.Status__c = 'Submitted';
        myOb1872.Number_of_Workers_Observed__c = 1;
        myOb1872.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID;

        myOb1875.Result__c = 'Fail'; 
        myOb1875.Status__c = 'Draft';
        myOb1875.Number_of_Workers_Observed__c = 1;
        myOb1875.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID;

        myOb1877.Result__c = 'Fail';
        myOb1877.Status__c = 'Draft';
        myOb1877.Number_of_Workers_Observed__c = 1;
        myOb1877.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID;


        myUpdateObList.add(myOb1872); 
        myUpdateObList.add(myOb1875); 
        myUpdateObList.add(myOb1877); 

        INSERT myUpdateObList; 


        List<Finding__c> myFindList = new List<Finding__c>(); 

        Finding__c myFind2 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb1875.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 10,
            Category__c         = 'Test-1875',
            Sub_category__c     = 'Operating Rules',
            Score__c            = 4

        ); 
        myFindList.add(myFind2); 

        Finding__c myFind3 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb1875.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 10,
            Category__c         = 'Test-1877',
            Sub_category__c     = 'Operating Rules',
            Score__c            = 4
        ); 
        myFindList.add(myFind3); 

        INSERT myFindList; 

        myUpdateObList = new List<Observation__c>(); 

        myOb1875.Status__c = 'Submitted';
        myOb1877.Status__c = 'Submitted';

        myUpdateObList.add(myOb1875);
        myUpdateObList.add(myOb1877);

        UPDATE myUpdateObList; 


        // Certifications
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myOcList = Database.query(myQuery); 

        Map<String,OccupationCertification__c> myOcByNameMap = new Map<String,OccupationCertification__c>(); 

        for(OccupationCertification__c myOc :myOcList) {
            myOcByNameMap.put(myOc.Name, myOc); 
        }

        Contact myPeep = myEmpByFirstNameMap.get('Amy'); 
        OccupationCertification__c myCert = myOcByNameMap.get('Conductor Certification'); 


        EmployeeCertification__c myEmpCert = new EmployeeCertification__c 
        (  
            RecordTypeId = Revsys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID, 
            Employee__c         =  myPeep.Id,
            Certification__c    =  myCert.Id,
            Status__c           = 'Pending'
        );

        List<EmployeeCertification__c> theInputList = new List<EmployeeCertification__c>(); 

        theInputList.add(myEmpCert); 


        String myErrMsg = RevSys_EmployeeCertificationHelper.createEmpSpecRequirement(theInputList); 

    }

    /*************************************************************************
     Test 3
     *************************************************************************/

    private static testmethod void test_3() {
        
        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        // pull the ESR Records 
  
        myQuWrap = QueryUtility.beginDynamicQuery('EmployeeResultSummary__c');   
        myQuery = myQuWrap.QueryString; 
        List<EmployeeResultSummary__c> mySummList = Database.query(myQuery); 

       
        EmployeeResultSummary__c myMedExam      = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myHearingExam  = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myVisionExam   = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myMotorVehRev  = new EmployeeResultSummary__c(); 


        for(EmployeeResultSummary__c mySum :mySummList) {
            
            if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID       && 
               mySum.Type__c      == 'Medical Examination') { 
                        myMedExam = mySum; 
                        system.debug('myMedExam ' + myMedExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID  && 
                    mySum.Type__c      == 'Hearing Test') { 
                        myHearingExam  = mySum;
                        system.debug('myHearingExam ' + myHearingExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID  && 
                    mySum.Type__c      == 'Vision Test') { 
                        myVisionExam   = mySum;
                        system.debug('myVisionExam ' + myVisionExam);
            }
           
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID) { 
                        myMotorVehRev = mySum;
                        system.debug('myMotorVehRev ' + myMotorVehRev);
            }
        }

        EmployeeResultSummary__c myNewMedExam      = myMedExam.clone(false,false,false,false); 
        EmployeeResultSummary__c myNewHearingExam  = myHearingExam.clone(false,false,false,false); 
        EmployeeResultSummary__c myNewVisionExam   = myVisionExam.clone(false,false,false,false); 
        EmployeeResultSummary__c myNewMotorVehRev  = myMotorVehRev.clone(false,false,false,false); 


        myNewMedExam.Result__c = Label.RevSys_ESR_Result_Pending_Return_of_Exam_Results; 
        myNewMedExam.EvaluationDate__c = system.today().addDays(-40); 

        myNewHearingExam.Result__c = 'Failed Test';                             
        myNewHearingExam.EvaluationDate__c = system.today().addDays(-40); 

        myNewVisionExam.Result__c = 'Failed Test'; 
        myNewVisionExam.FieldTestAdministered__c = 'No'; 
        myNewVisionExam.EvaluationDate__c  = system.today().addDays(-40); 

        myNewMotorVehRev.Status__c = 'Pending';
        myNewMotorVehRev.StateReviewDate__c = system.today().addDays(-40); 
        myNewMotorVehRev.NdrReviewDate__c = system.today().addDays(-40); 

        List<EmployeeResultSummary__c> myNewSummList = new List<EmployeeResultSummary__c>(); 

        myNewSummList.add(myNewMedExam); 
        myNewSummList.add(myNewHearingExam); 
        myNewSummList.add(myNewVisionExam); 
        myNewSummList.add(myNewMotorVehRev); 

        INSERT myNewSummList; 


        // pull the Observations

        Observation__c myOb1872 = new Observation__c(); 
        Observation__c myOb1875 = new Observation__c(); 
        Observation__c myOb1877 = new Observation__c(); 

        myQuWrap = QueryUtility.beginDynamicQuery('Observation__c');   
        myQuery = myQuWrap.QueryString; 
        List<Observation__c> myObList = Database.query(myQuery); 

        for(Observation__c myOb :myObList) {
            system.debug('myOb ' + myOb);

            if(myOb.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID) { 
                myOb1872 = myOb.clone(false,false,false,false); 
            }
            else if(myOb.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID) { 
                myOb1875 = myOb.clone(false,false,false,false); 
            }
            else if(myOb.RecordTypeId == RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID) { 
                myOb1877 = myOb.clone(false,false,false,false); 
            }
        }

        List<Observation__c> myUpdateObList = new List<Observation__c>(); 

        myOb1872.Result__c = 'C = Compliance'; 
        myOb1872.Status__c = 'Submitted';
        myOb1872.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID;

        myOb1875.Result__c = 'Pass'; 
        myOb1875.Status__c = 'Draft';
        myOb1875.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID;

        myOb1877.Result__c = 'Pass';
        myOb1877.Status__c = 'Draft';
        myOb1877.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID;


        myUpdateObList.add(myOb1872); 
        myUpdateObList.add(myOb1875); 
        myUpdateObList.add(myOb1877); 

        INSERT myUpdateObList; 


        List<Finding__c> myFindList = new List<Finding__c>(); 

        Finding__c myFind2 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb1875.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 10,
            Category__c         = 'Test-1875',
            Sub_category__c     = 'Operating Rules',
            Score__c            = 1
        ); 
        myFindList.add(myFind2); 

        Finding__c myFind3 = new Finding__c
        (   
            RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID, 
            Observation__c      = myOb1875.Id,
            IsCriticalItem__c   = true,
            Sequence__c         = 10,
            Category__c         = 'Test-1877',
            Sub_category__c     = 'Operating Rules',
            Score__c            = 1
        ); 
        myFindList.add(myFind3); 

        INSERT myFindList; 

        myUpdateObList = new List<Observation__c>(); 

        myOb1875.Status__c = 'Submitted';
        myOb1877.Status__c = 'Submitted';

        myUpdateObList.add(myOb1875);
        myUpdateObList.add(myOb1877);

        UPDATE myUpdateObList; 


        // Certifications
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myOcList = Database.query(myQuery); 

        Map<String,OccupationCertification__c> myOcByNameMap = new Map<String,OccupationCertification__c>(); 

        for(OccupationCertification__c myOc :myOcList) {
            myOcByNameMap.put(myOc.Name, myOc); 
        }

        Contact myPeep = myEmpByFirstNameMap.get('Amy'); 
        OccupationCertification__c myCert = myOcByNameMap.get('Conductor Certification'); 


        EmployeeCertification__c myEmpCert = new EmployeeCertification__c 
        (  
            RecordTypeId = Revsys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID, 
            Employee__c         =  myPeep.Id,
            Certification__c    =  myCert.Id,
            Status__c           = 'Pending'
        );

        List<EmployeeCertification__c> theInputList = new List<EmployeeCertification__c>(); 

        theInputList.add(myEmpCert); 

        String myErrMsg = RevSys_EmployeeCertificationHelper.createEmpSpecRequirement(theInputList); 

    }
    /*************************************************************************
     Test 4:   
     *************************************************************************/

    private static testmethod void test_4() {
        
        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        // pull the ESR Records 
  
        myQuWrap = QueryUtility.beginDynamicQuery('EmployeeResultSummary__c');   
        myQuery = myQuWrap.QueryString; 
        List<EmployeeResultSummary__c> mySummList = Database.query(myQuery); 

        EmployeeResultSummary__c myMedExam      = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myHearingExam  = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myVisionExam   = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myEmployeeHist = new EmployeeResultSummary__c();  
        EmployeeResultSummary__c myMotorVehRev  = new EmployeeResultSummary__c(); 


        for(EmployeeResultSummary__c mySum :mySummList) {
            
            if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID       && 
               mySum.Type__c      == 'Medical Examination') { 
                        myMedExam = mySum; 
                        system.debug('myMedExam ' + myMedExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID  && 
                    mySum.Type__c      == 'Hearing Test') { 
                        myHearingExam  = mySum;
                        system.debug('myHearingExam ' + myHearingExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID  && 
                    mySum.Type__c      == 'Vision Test') { 
                        myVisionExam   = mySum;
                        system.debug('myVisionExam ' + myVisionExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_EMPHISTORY_RECTYPE_ID) { 
                        myEmployeeHist = mySum;
                        system.debug('myEmployeeHist ' + myEmployeeHist);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID) { 
                        myMotorVehRev = mySum;
                        system.debug('myMotorVehRev ' + myMotorVehRev);
            }
        }

        EmployeeResultSummary__c myNewHearingExam  = myHearingExam.clone(false,false,false,false); 
        EmployeeResultSummary__c myNewVisionExam   = myVisionExam.clone(false,false,false,false); 
        EmployeeResultSummary__c myNewMotorVehRev  = myMotorVehRev.clone(false,false,false,false); 


        myNewHearingExam.Result__c = 'Pending return of exam results ';
        myNewHearingExam.EvaluationDate__c = system.today().addDays(-40); 

        myNewVisionExam.Result__c = 'Failed Test'; 
        myNewVisionExam.FieldTestAdministered__c = 'Yes'; 
        myNewVisionExam.FieldTestResult__c = 'Fail'; 
        myNewVisionExam.EvaluationDate__c  = system.today().addDays(-40); 

        myNewMotorVehRev.Status__c = 'Pass';
        myNewMotorVehRev.StateReviewDate__c = system.today().addDays(-40); 
        myNewMotorVehRev.NdrReviewDate__c = system.today().addDays(-40); 

        List<EmployeeResultSummary__c> myNewSummList = new List<EmployeeResultSummary__c>(); 

        myNewSummList.add(myNewHearingExam); 
        myNewSummList.add(myNewVisionExam); 
        myNewSummList.add(myNewMotorVehRev); 

        INSERT myNewSummList; 

        // Certifications
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myOcList = Database.query(myQuery); 

        Map<String,OccupationCertification__c> myOcByNameMap = new Map<String,OccupationCertification__c>(); 

        for(OccupationCertification__c myOc :myOcList) {
            myOcByNameMap.put(myOc.Name, myOc); 
        }

        Contact myPeep = myEmpByFirstNameMap.get('Amy'); 
        OccupationCertification__c myCert = myOcByNameMap.get('Conductor Certification'); 


        EmployeeCertification__c myEmpCert = new EmployeeCertification__c 
        (  
            RecordTypeId = Revsys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID, 
            Employee__c         =  myPeep.Id,
            Certification__c    =  myCert.Id,
            Status__c           = 'Pending'
        );

        List<EmployeeCertification__c> theInputList = new List<EmployeeCertification__c>(); 

        theInputList.add(myEmpCert); 

        String myErrMsg = RevSys_EmployeeCertificationHelper.createEmpSpecRequirement(theInputList); 

    }

    /*************************************************************************
     Test 5:   
     *************************************************************************/

    private static testmethod void test_5() {
        
        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        // pull the ESR Records 
  
        myQuWrap = QueryUtility.beginDynamicQuery('EmployeeResultSummary__c');   
        myQuery = myQuWrap.QueryString; 
        List<EmployeeResultSummary__c> mySummList = Database.query(myQuery); 

        EmployeeResultSummary__c myMedExam      = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myHearingExam  = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myVisionExam   = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myEmployeeHist = new EmployeeResultSummary__c();  
        EmployeeResultSummary__c myMotorVehRev  = new EmployeeResultSummary__c(); 


        for(EmployeeResultSummary__c mySum :mySummList) {
            
            if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID       && 
               mySum.Type__c      == 'Medical Examination') { 
                        myMedExam = mySum; 
                        system.debug('myMedExam ' + myMedExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID  && 
                    mySum.Type__c      == 'Hearing Test') { 
                        myHearingExam  = mySum;
                        system.debug('myHearingExam ' + myHearingExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID  && 
                    mySum.Type__c      == 'Vision Test') { 
                        myVisionExam   = mySum;
                        system.debug('myVisionExam ' + myVisionExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_EMPHISTORY_RECTYPE_ID) { 
                        myEmployeeHist = mySum;
                        system.debug('myEmployeeHist ' + myEmployeeHist);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID) { 
                        myMotorVehRev = mySum;
                        system.debug('myMotorVehRev ' + myMotorVehRev);
            }
        }

        EmployeeResultSummary__c myNewVisionExam   = myVisionExam.clone(false,false,false,false); 

        myNewVisionExam.Result__c = 'Failed Test'; 
        myNewVisionExam.FieldTestAdministered__c = 'Yes'; 
        myNewVisionExam.FieldTestResult__c = 'Pass'; 
        myNewVisionExam.EvaluationDate__c  = system.today().addDays(-40); 

        List<EmployeeResultSummary__c> myNewSummList = new List<EmployeeResultSummary__c>(); 

        myNewSummList.add(myNewVisionExam); 

        INSERT myNewSummList; 

        // Certifications
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myOcList = Database.query(myQuery); 

        Map<String,OccupationCertification__c> myOcByNameMap = new Map<String,OccupationCertification__c>(); 

        for(OccupationCertification__c myOc :myOcList) {
            myOcByNameMap.put(myOc.Name, myOc); 
        }

        Contact myPeep = myEmpByFirstNameMap.get('Amy'); 
        OccupationCertification__c myCert = myOcByNameMap.get('Conductor Certification'); 


        EmployeeCertification__c myEmpCert = new EmployeeCertification__c 
        (  
            RecordTypeId = Revsys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID, 
            Employee__c         =  myPeep.Id,
            Certification__c    =  myCert.Id,
            Status__c           = 'Pending'
        );

        List<EmployeeCertification__c> theInputList = new List<EmployeeCertification__c>(); 

        theInputList.add(myEmpCert); 

        String myErrMsg = RevSys_EmployeeCertificationHelper.createEmpSpecRequirement(theInputList); 

    }

    /*************************************************************************
     Test 6:   
     *************************************************************************/

    private static testmethod void test_6() {
        
        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        // pull the ESR Records 
  
        myQuWrap = QueryUtility.beginDynamicQuery('EmployeeResultSummary__c');   
        myQuery = myQuWrap.QueryString; 
        List<EmployeeResultSummary__c> mySummList = Database.query(myQuery); 

        EmployeeResultSummary__c myMedExam      = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myHearingExam  = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myVisionExam   = new EmployeeResultSummary__c(); 
        EmployeeResultSummary__c myEmployeeHist = new EmployeeResultSummary__c();  
        EmployeeResultSummary__c myMotorVehRev  = new EmployeeResultSummary__c(); 


        for(EmployeeResultSummary__c mySum :mySummList) {
            
            if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID       && 
               mySum.Type__c      == 'Medical Examination') { 
                        myMedExam = mySum; 
                        system.debug('myMedExam ' + myMedExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID  && 
                    mySum.Type__c      == 'Hearing Test') { 
                        myHearingExam  = mySum;
                        system.debug('myHearingExam ' + myHearingExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID  && 
                    mySum.Type__c      == 'Vision Test') { 
                        myVisionExam   = mySum;
                        system.debug('myVisionExam ' + myVisionExam);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_EMPHISTORY_RECTYPE_ID) { 
                        myEmployeeHist = mySum;
                        system.debug('myEmployeeHist ' + myEmployeeHist);
            }
            else if(mySum.RecordTypeId == RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID) { 
                        myMotorVehRev = mySum;
                        system.debug('myMotorVehRev ' + myMotorVehRev);
            }
        }

        EmployeeResultSummary__c myNewVisionExam   = myVisionExam.clone(false,false,false,false); 

        myNewVisionExam.Result__c = 'Pending return of exam results ';
        myNewVisionExam.EvaluationDate__c  = system.today().addDays(-40); 

        List<EmployeeResultSummary__c> myNewSummList = new List<EmployeeResultSummary__c>(); 

        myNewSummList.add(myNewVisionExam); 

        INSERT myNewSummList; 

        // Certifications
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myOcList = Database.query(myQuery); 

        Map<String,OccupationCertification__c> myOcByNameMap = new Map<String,OccupationCertification__c>(); 

        for(OccupationCertification__c myOc :myOcList) {
            myOcByNameMap.put(myOc.Name, myOc); 
        }

        Contact myPeep = myEmpByFirstNameMap.get('Amy'); 
        OccupationCertification__c myCert = myOcByNameMap.get('Conductor Certification'); 


        EmployeeCertification__c myEmpCert = new EmployeeCertification__c 
        (  
            RecordTypeId = Revsys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID, 
            Employee__c         =  myPeep.Id,
            Certification__c    =  myCert.Id,
            Status__c           = 'Pending'
        );

        List<EmployeeCertification__c> theInputList = new List<EmployeeCertification__c>(); 

        theInputList.add(myEmpCert); 

        String myErrMsg = RevSys_EmployeeCertificationHelper.createEmpSpecRequirement(theInputList); 

    }


}