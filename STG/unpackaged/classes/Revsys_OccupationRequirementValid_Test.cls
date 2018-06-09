/**
*___________________________________________________
*@Name:     Revsys_OccupationRequirementValid_Test
*@Author:   Chuck Walley
*@Created:  Date: 01/01/2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for RevSys_OccupationCertificationValidation 
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class Revsys_OccupationRequirementValid_Test { 
    
    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {
        OccupationCertification__c myCert = new OccupationCertification__c
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID,
                Name                = 'This Certification', 
                Status__c           = 'Active',
                Frequency__c        = 'Months',
                LengthOfPeriod__c   = 1,
                StartDate__c        = Date.today(), 
                EndDate__c          = date.today().addMonths(13)
            ); 
        
        insert myCert; 
        
        OccupationRequirement__c myReq = new OccupationRequirement__c
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
                Name = 'This Requirement',
                Status__c = 'Active',
                Source__c = 'Observation',
                SourceRecordType__c = 'FORM-1872',
                TestNumber__c = '100',
                TestName__c = 'test'
            );
        
        insert myReq; 
        
        OccupationRequirement__c newReq = new OccupationRequirement__c
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
                Name = 'Another Requirement',
                Status__c = 'Active',
                Source__c = 'Observation',
                SourceRecordType__c = 'FORM-1872',
                TestNumber__c = '105',
                TestName__c = 'Test Name 2'
            );
        
        insert newReq; 
        
        OccupationSpecificRequirement__c myCertReq = new OccupationSpecificRequirement__c
            ( 
                RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID,
                Certification__c = myCert.Id, 
                Requirement__c = myReq.Id, 
                Frequency__c = 'Days',
                LengthOfPeriod__c = 900,
                Status__c = 'Active'
            ); 
        
        insert(myCertReq); 
        
    }
    
    private static testmethod void test_determineRecord_Insert_0()
    {
        
        OccupationRequirement__c myReq = new OccupationRequirement__c
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
                Name = 'This Requirement',
                Status__c = 'Active',
                Source__c = 'Observation',
                SourceRecordType__c = 'Form-1872' 
            );
        
        List<OccupationRequirement__c> myReqList = new List<OccupationRequirement__c>(); 
        myReqList.add(myReq); 
        
        String errorMsg 
            = Revsys_OccupationRequirementValidation.checkDupeName(myReqList,null); 
        
        system.assertNotEquals(null,errorMsg); 
    }
    
    private static testmethod void test_determineRecord_Insert_1()
    {
        
        OccupationRequirement__c myReq = new OccupationRequirement__c
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
                Name = 'That Other Requirement',
                Status__c = 'Active',
                Source__c = 'Observation',
                SourceRecordType__c = 'Form-1872' 
            );
        
        List<OccupationRequirement__c> myReqList = new List<OccupationRequirement__c>(); 
        myReqList.add(myReq); 
        
        String errorMsg 
            = Revsys_OccupationRequirementValidation.checkDupeName(myReqList,null); 
        
        system.assertEquals(null,errorMsg); 
    }
    private static testmethod void test_determineRecord_Insert_2()
    {
        system.debug('----------------This is Inser2');
        OccupationRequirement__c newReq = new OccupationRequirement__c
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
                Name = 'Another Requirement',
                Status__c = 'Active',
                Source__c = 'Observation',
                SourceRecordType__c = 'FORM-1872',
                TestNumber__c = '101',
                TestName__c = 'Test Name 5'
            );
        
        insert newReq; 
        
        OccupationRequirement__c newReq2 = new OccupationRequirement__c
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
                Name = 'Another Requirement',
                Status__c = 'Active',
                Source__c = 'Observation',
                SourceRecordType__c = 'FORM-1872',
                TestNumber__c = '102',
                TestName__c = 'Test Name 3'
            );
        insert newReq2;
        
        OccupationRequirement__c exst = [Select Id,TestNumber__c,TestName__c from OccupationRequirement__c where Id=:newReq2.Id];
        exst.TestNumber__c = '106';
        exst.TestName__c = 'Test Name 4';
        update exst;
        
        OccupationRequirement__c myReq = new OccupationRequirement__c
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
                Name = 'That Other Requirement',
                Status__c = 'Active',
                Source__c = 'Observation',
                SourceRecordType__c = 'Form-1872',
                TestName__c = 'Test Name 7',
                TestNumber__c = '107'
                
            );
        
        List<OccupationRequirement__c> myReqList = new List<OccupationRequirement__c>(); 
        myReqList.add(myReq); 
        set<string> set1 = new Set<String>();
        set1.add('106');
        set<string> set2 = new Set<String>();
        set2.add('Test Name 4');
        String errorMsg 
            = Revsys_OccupationRequirementValidation.checkTestNumAndName(myReqList,set1,set2);
        
        system.assertEquals(null,errorMsg); 
    }
    private static testmethod void test_determineRecord_Insert_3()
    {
        OccupationRequirement__c newReq = new OccupationRequirement__c
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
                Name = 'Another Requirement',
                Status__c = 'Active',
                Source__c = 'Observation',
                SourceRecordType__c = 'FORM-1872',
                TestNumber__c = '109'
            );
        
        insert newReq; 
        
        List<OccupationRequirement__c> myReqList = new List<OccupationRequirement__c>(); 
        myReqList.add(newReq); 
        set<string> set1 = new Set<String>();
        set1.add('109');
        set<string> set2 = new Set<String>();
        set2.add('Test Name 9');
        String errorMsg 
            = Revsys_OccupationRequirementValidation.checkTestNumAndName(myReqList, set1,set2);
    }
}