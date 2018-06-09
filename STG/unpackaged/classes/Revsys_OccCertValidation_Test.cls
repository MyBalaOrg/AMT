/**
*___________________________________________________
*@Name:     SobjectNameDupeCheck_Test
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
public class Revsys_OccCertValidation_Test { 

    
   
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
            SourceRecordType__c = 'FORM-1872' 
        );

        insert myReq; 

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

        OccupationCertification__c myCert = new OccupationCertification__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID,
            Name                = 'That Other Certification', 
            Status__c           = 'Active',
            Frequency__c        = 'Months',
            LengthOfPeriod__c   = 1,
            StartDate__c        = Date.today(), 
            EndDate__c          = date.today().addMonths(13)
        ); 

        List<OccupationCertification__c> myCertList = new List<OccupationCertification__c>(); 
        myCertList.add(myCert); 

        String errorMsg 
            = Revsys_OccCertValidation.checkDupeName(myCertList,null); 

        system.assertEquals(null,errorMsg); 
    }

    private static testmethod void test_determineRecord_Insert_1()
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

        List<OccupationCertification__c> myCertList = new List<OccupationCertification__c>(); 
        myCertList.add(myCert); 

        String errorMsg 
            = Revsys_OccCertValidation.checkDupeName(myCertList,null); 

        system.assertNotEquals(null,errorMsg); 
    }



}