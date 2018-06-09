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
public class SobjectNameDupeCheck_Test { 

    
   
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

    private static testmethod void test_determineRecord_Insert()
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

        List<OccupationCertification__c> myCheckCertList 
            = SobjectNameDupeCheck.determineRecord(myCertList,null); 

        system.assertEquals(1,myCheckCertList.size() ); 
    }

    private static testmethod void test_determineRecord_Update_0()
    {

        List<OccupationCertification__c> myOldCertList = new List<OccupationCertification__c>
        (
            [SELECT Id, Name 
             FROM OccupationCertification__c] 
        );

        Map<Id,SObject> myOldMap = new Map<Id,SObject>(); 
        List<OccupationCertification__c> myNewList = new List<OccupationCertification__c>(); 

        for(OccupationCertification__c myOld :myOldCertList) {
            OccupationCertification__c myNew = myOld.clone(true,true,true,true); 

            SObject myOldSobj = myOld; 
            myOldMap.put(myOld.Id,myOldSobj); 

            myNewList.add(myNew); 
        }

        List<OccupationCertification__c> myCheckCertList 
            = SobjectNameDupeCheck.determineRecord(myNewList,myOldMap); 

        system.assertEquals(0,myCheckCertList.size() ); 
    }

    private static testmethod void test_determineRecord_Update_1()
    {

        List<OccupationCertification__c> myOldCertList = new List<OccupationCertification__c>
        (
            [SELECT Id, Name 
             FROM OccupationCertification__c] 
        );

        Map<Id,SObject> myOldMap = new Map<Id,SObject>(); 
        List<OccupationCertification__c> myNewList = new List<OccupationCertification__c>(); 

        for(OccupationCertification__c myOld :myOldCertList) {
            OccupationCertification__c myNew = myOld.clone(true,true,true,true); 

            SObject myOldSobj = myOld; 
            myOldMap.put(myOld.Id,myOldSobj); 

            myNew.Name = 'That Certification';
            myNewList.add(myNew); 
        }

        List<OccupationCertification__c> myCheckCertList 
            = SobjectNameDupeCheck.determineRecord(myNewList,myOldMap); 

        system.assertEquals(1,myCheckCertList.size() ); 
    }


    private static testmethod void test_checkForDupe_found()
    {

        List<OccupationCertification__c> myOldCertList = new List<OccupationCertification__c>
        (
            [SELECT Id, Name 
             FROM OccupationCertification__c] 
        );

        List<OccupationCertification__c> myNewList = new List<OccupationCertification__c>(); 

        for(OccupationCertification__c myOld :myOldCertList) {
            OccupationCertification__c myNew = myOld.clone(true,true,true,true); 

            myNewList.add(myNew); 
        }

        String errorMsg 
            = SobjectNameDupeCheck.checkForDupe(myNewList,myOldCertList); 

        system.assertNotEquals(null,errorMsg); 
    }

    private static testmethod void test_checkForDupe_notfound()
    {

        List<OccupationCertification__c> myOldCertList = new List<OccupationCertification__c>
        (
            [SELECT Id, Name 
             FROM OccupationCertification__c] 
        );

        List<OccupationCertification__c> myNewList = new List<OccupationCertification__c>(); 

        for(OccupationCertification__c myOld :myOldCertList) {
            OccupationCertification__c myNew = myOld.clone(true,true,true,true); 

            myNew.Name = 'Something Else'; 
            myNewList.add(myNew); 
        }

        String errorMsg 
            = SobjectNameDupeCheck.checkForDupe(myNewList,myOldCertList); 

        system.assertEquals(null,errorMsg); 
    }

}