/**
*___________________________________________________
*@Name:     EmployeeResultSummarySelector_Test
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
public class EmployeeResultSummarySelector_Test { 
    
   
    //Creating Test Data
    @TestSetup
    public static void loadTestData() {

        SPARTN_BypassRuleSettings__c orgsettings = SPARTN_BypassRuleSettings__c.getOrgDefaults();  
        orgsettings.Processes__c = true; 
        orgsettings.ValidationRules__c = true; 
        insert orgsettings;   

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
            EvaluationDate__c                   = system.today().addDays(-50), 
            Type__c                             = 'Vision Test',
            Result__c                           = 'No Restrictions',
            LicenseNumber__c                    = '1234',
            LicenseType__c                      = 'U.S. Driver\'s License',
            State__c                            = 'DC',
            StateReviewDate__c                  = system.today().addDays(-50), 
            NdrReviewDate__c                    = system.today().addDays(-50), 
            //NdrReviewed__c                      = true,
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

     /*************************************************************************
     Test 1:   Emloyee Result Summary set up in data load 
     *************************************************************************/
    private static testmethod void test_getEmployeeResultSummary() {
        
        try{
            // Get all Observation records
            QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('Observation__c');   
            String myQuery = myQuWrap.QueryString; 
            String errorMsg = myQuWrap.ErrorMessage;
            List<Observation__c> myObsList = Database.query(myQuery); 
            
            Set<Id> myObsIdSet = new Set<Id>(); 
            
            for(Observation__c myObs :myObsList) {
                myObsIdSet.add(myObs.Id);
            }
             // RevSys_EmpResultSummaryTriggerHandler.DoFailTest = TRUE;
            SelectorWrapper myErsWrap = EmployeeResultSummarySelector.getEmployeeResultSummary(myObsIdSet); 
          
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('error') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }

    }
     public static testMethod void testGetEmployeeResultSummary(){
        Map<Id,Observation__c> observationIdMap = new Map<Id,Observation__c>();
         SelectorWrapper wrap =  EmployeeResultSummarySelector.getEmployeeResultSummary(observationIdMap.keySet());
         
        EmployeeResultSummarySelector.DoFailTest = FALSE;
        SelectorWrapper selector1 = EmployeeResultSummarySelector.getEmployeeResultSummary(observationIdMap.keySet());
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
        System.assertEquals(0,selector1.SObjectList.size());
        
        EmployeeResultSummarySelector.DoFailTest = TRUE;
        SelectorWrapper selector2 = EmployeeResultSummarySelector.getEmployeeResultSummary(observationIdMap.keySet());
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
        System.assertEquals(0, selector2.SObjectList.size());
    }
    public static testMethod void testGetMotorVehicleReviewERS(){
        Set<Id> contactIdSet = new Set<Id>();
        List<EmployeeCertification__c> newEmpCertList = new List<EmployeeCertification__c>();
        for(EmployeeCertification__c ecObj : newEmpCertList) {
             contactIdSet.add(ecObj.Employee__c);
        }
        SelectorWrapper wrapper = EmployeeResultSummarySelector.getMotorVehicleReviewERS(contactIdSet);
        
        EmployeeResultSummarySelector.DoFailTest = FALSE;
        SelectorWrapper selector1 = EmployeeResultSummarySelector.getMotorVehicleReviewERS(contactIdSet);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
        System.assertEquals(0,selector1.SObjectList.size());
        
        EmployeeResultSummarySelector.DoFailTest = TRUE;
        SelectorWrapper selector2 = EmployeeResultSummarySelector.getMotorVehicleReviewERS(contactIdSet);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
        System.assertEquals(0, selector2.SObjectList.size());       
    }
    public static testMethod void testGetMedicalHearingVisionERS(){
        Set<Id> contactIdSet = new Set<Id>();
        List<EmployeeCertification__c> newEmpCertList = new List<EmployeeCertification__c>();
        for(EmployeeCertification__c ecObj : newEmpCertList) {
             contactIdSet.add(ecObj.Employee__c);
        }
        SelectorWrapper wrapper = EmployeeResultSummarySelector.getMedicalHearingVisionERS(contactIdSet);
        
        EmployeeResultSummarySelector.DoFailTest = FALSE;
        SelectorWrapper selector1 = EmployeeResultSummarySelector.getMedicalHearingVisionERS(contactIdSet);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
        System.assertEquals(0,selector1.SObjectList.size());
        
        EmployeeResultSummarySelector.DoFailTest = TRUE;
        SelectorWrapper selector2 = EmployeeResultSummarySelector.getMedicalHearingVisionERS(contactIdSet);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
        System.assertEquals(0, selector2.SObjectList.size());       
    }
    public static testMethod void testGetEmployeeSummaryRecords(){
           set<Id> myEmployee = new Set<Id>();
          set<Id> myRecordTypeIdSet = new Set<Id>();
         List<Observation__c> ObsList = new List <Observation__c>();
         set<Id> obsIdSet = new Set<Id>();
         myRecordTypeIdSet.add(RevSys_StaticUtility.EMP_RES_SUMM_TEST1878_RECTYPE_ID);
         for(observation__c obs : ObsList)
            {     
                myEmployee.add(obs.Employee__c); 
            }
           SelectorWrapper wrapper = ObservationSelector.getObservationsbyId(obsIdSet);
           wrapper = EmployeeResultSummarySelector.getEmployeeSummaryRecords(myEmployee,myRecordTypeIdSet);
        
        EmployeeResultSummarySelector.DoFailTest = FALSE;
        SelectorWrapper selector1 = EmployeeResultSummarySelector.getEmployeeSummaryRecords(myEmployee,myRecordTypeIdSet);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
        System.assertEquals(0,selector1.SObjectList.size());
        
        EmployeeResultSummarySelector.DoFailTest = TRUE;
        SelectorWrapper selector2 = EmployeeResultSummarySelector.getEmployeeSummaryRecords(myEmployee,myRecordTypeIdSet);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
        System.assertEquals(0, selector2.SObjectList.size());       
    }

    public static testMethod void testGetErsByEmpIdTestNumber(){
           set<Id> myEmployee = new Set<Id>();
          set<String> TestNumber = new Set<String>();
         List<Observation__c> ObsList = new List <Observation__c>();
         set<Id> obsIdSet = new Set<Id>();
         TestNumber.add(RevSys_StaticUtility.EMP_RES_SUMM_TEST1878_RECTYPE_ID);
         for(observation__c obs : ObsList)
            {     
                myEmployee.add(obs.Employee__c); 
            }
           SelectorWrapper wrapper =  ObservationSelector.getObservationsbyId(obsIdSet);
           wrapper = EmployeeResultSummarySelector.getErsByEmpIdTestNumber(myEmployee,TestNumber);
        
        EmployeeResultSummarySelector.DoFailTest = FALSE;
        SelectorWrapper selector1 = EmployeeResultSummarySelector.getErsByEmpIdTestNumber(myEmployee,TestNumber);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
        System.assertEquals(0,selector1.SObjectList.size());
        
        EmployeeResultSummarySelector.DoFailTest = TRUE;
        SelectorWrapper selector2 = EmployeeResultSummarySelector.getErsByEmpIdTestNumber(myEmployee,TestNumber);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
        System.assertEquals(0, selector2.SObjectList.size());       
    }

    public static testMethod void testGetErsByEmployeeAndSourceInfo(){ 
        Set<Id> myEmpIdSet = new Set<Id>();
        Set<Id> myRecTypeIdSet = new Set<Id>();
        Set<String> mySourceTestTypeSet = new Set<String>();
        List<EmployeeSpecificRequirement__c> newEsrList = new List<EmployeeSpecificRequirement__c>();
        
        Date myEarliestDate = system.Today().addDays(10);
        
        
         for(EmployeeSpecificRequirement__c newEsr :newEsrList) { 
            myEmpIdSet.add(newEsr.Employee__c); 
         }
          
        SelectorWrapper myErsWrap  = EmployeeResultSummarySelector.getErsByEmployeeAndSourceInfo(myEmpIdSet, myRecTypeIdSet, mySourceTestTypeSet,myEarliestDate);
        EmployeeResultSummarySelector.DoFailTest = FALSE;
        SelectorWrapper selector1 = EmployeeResultSummarySelector.getErsByEmployeeAndSourceInfo(myEmpIdSet, myRecTypeIdSet, mySourceTestTypeSet,myEarliestDate);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
        System.assertEquals(0,selector1.SObjectList.size());
        
        EmployeeResultSummarySelector.DoFailTest = TRUE;
        SelectorWrapper selector2 = EmployeeResultSummarySelector.getErsByEmployeeAndSourceInfo(myEmpIdSet, myRecTypeIdSet, mySourceTestTypeSet,myEarliestDate);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
        System.assertEquals(0, selector2.SObjectList.size());       
    }

}