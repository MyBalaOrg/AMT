/**
*___________________________________________________
*@Name:     SObjectJunctDupeCheck_Test
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
public class SObjectJunctDupeCheck_Test { 
   
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

        OccupationRequirement__c myReq2 = new OccupationRequirement__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name = 'That Requirement',
            Status__c = 'Active',
            Source__c = 'Observation',
            SourceRecordType__c = 'FORM-1872' 
        );

        insert myReq2; 

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
        List<OccupationSpecificRequirement__c> myOsrList = new List<OccupationSpecificRequirement__c>
        ( 
            [SELECT Id, RecordTypeId, Certification__c, Requirement__c, 
                    Frequency__c, LengthOfPeriod__c, Status__c 
             FROM   OccupationSpecificRequirement__c]
        );

        List<OccupationSpecificRequirement__c> myOsrCheckList 
            = SObjectJunctDupeCheck.determineRecord(myOsrList, null, 
                                                    'Certification__c', 'Requirement__c',
                                                    Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID); 

        system.assertEquals(1,myOsrCheckList.size() ); 
    }


    private static testmethod void test_determineRecord_Upsert_0()
    {
        List<OccupationSpecificRequirement__c> myOsrList = new List<OccupationSpecificRequirement__c>
        ( 
            [SELECT Id, RecordTypeId, Certification__c, Requirement__c, 
                    Frequency__c, LengthOfPeriod__c, Status__c 
             FROM   OccupationSpecificRequirement__c]
        );

        Map<Id,SObject> mySobjMap = new Map<Id,SObject>(); 

        for(OccupationSpecificRequirement__c myOsr :myOsrList) {
            
            SObject mySobj = myOsr; 
            mySobjMap.put(myOsr.Id,mySobj); 
        }

        List<OccupationSpecificRequirement__c> myOsrCheckList 
            = SObjectJunctDupeCheck.determineRecord(myOsrList, mySobjMap, 
                                                    'Certification__c', 'Requirement__c',
                                                    Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID); 

        system.assertEquals(0,myOsrCheckList.size() ); 
    }

    private static testmethod void test_determineRecord_Upsert_1()
    {
        List<OccupationSpecificRequirement__c> myOsrList = new List<OccupationSpecificRequirement__c>
        ( 
            [SELECT Id, RecordTypeId, Certification__c, Requirement__c, 
                    Frequency__c, LengthOfPeriod__c, Status__c 
             FROM   OccupationSpecificRequirement__c]
        );

        system.debug('myOsrList ' + myOsrList); 

        List<OccupationRequirement__c> thatReqList = new List<OccupationRequirement__c>
        (
            [SELECT ID, RecordTypeId, Name 
             FROM   OccupationRequirement__c
             WHERE  Name = 'That Requirement'] 
        );

        OccupationRequirement__c thatReq = thatReqList[0]; 

        Map<Id,SObject> mySobjMap = new Map<Id,SObject>(); 
        List<OccupationSpecificRequirement__c> myNewOsrList = new List<OccupationSpecificRequirement__c>(); 

        for(OccupationSpecificRequirement__c myOsr :myOsrList) {

            SObject mySobj = myOsr; 
            mySobjMap.put(myOsr.Id,mySobj); 

            OccupationSpecificRequirement__c myNewOsr = myOsr.clone(true,true,true,true); 

            myNewOsr.Requirement__c = thatReq.Id; 

           myNewOsrList.add(myNewOsr); 

        }

        List<OccupationSpecificRequirement__c> myOsrCheckList 
            = SObjectJunctDupeCheck.determineRecord(myNewOsrList, mySobjMap, 
                                                    'Certification__c', 'Requirement__c',
                                                    Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID); 

        system.assertEquals(1,myOsrCheckList.size() ); 
    }

    private static testmethod void test_checkForDupe_found()
    {
        String myQuery; 
        // Get all Certifications 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myOcList = Database.query(myQuery); 

        // Get all Requirements 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_REQUIREMENT);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationRequirement__c> myOrList = Database.query(myQuery); 

        // Get OSR records; 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_SPECIFIC_REQUIREMENT);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationSpecificRequirement__c> myOsrList = Database.query(myQuery); 

        system.debug('myOsrList ' + myOsrList); 

        // Get 'That Requirement' 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_REQUIREMENT);   
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE Name = \'That Requirement\' ';
        List<OccupationRequirement__c> thatReqList = Database.query(myQuery); 

        OccupationRequirement__c thatReq = thatReqList[0]; 

        List<OccupationSpecificRequirement__c> myNewOsrList = new List<OccupationSpecificRequirement__c>(); 

        for(OccupationSpecificRequirement__c myOsr :myOsrList) {

            OccupationSpecificRequirement__c myNewOsr = myOsr.clone(true,true,true,true); 

            myNewOsrList.add(myNewOsr); 

        }

        String errorMsg 
            = SObjectJunctDupeCheck.checkForDupe(myNewOsrList, myOsrList, 
                                                'Certification__c', myOcList,
                                                'Requirement__c',   myOrList); 

        system.assertNotEquals(null,errorMsg); 
    }



    private static testmethod void test_checkForDupe_notfound()
    {
        String myQuery; 
        // Get all Certifications 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationCertification__c> myOcList = Database.query(myQuery); 

        // Get all Requirements 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_REQUIREMENT);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationRequirement__c> myOrList = Database.query(myQuery); 

        // Get OSR records; 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_SPECIFIC_REQUIREMENT);   
        myQuery = myQuWrap.QueryString; 
        List<OccupationSpecificRequirement__c> myOsrList = Database.query(myQuery); 

        system.debug('myOsrList ' + myOsrList); 

        // Get 'That Requirement' 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_REQUIREMENT);   
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE Name = \'That Requirement\' ';
        List<OccupationRequirement__c> thatReqList = Database.query(myQuery); 

        OccupationRequirement__c thatReq = thatReqList[0]; 

        List<OccupationSpecificRequirement__c> myNewOsrList = new List<OccupationSpecificRequirement__c>(); 

        for(OccupationSpecificRequirement__c myOsr :myOsrList) {

            OccupationSpecificRequirement__c myNewOsr = myOsr.clone(true,true,true,true); 

            myNewOsr.Requirement__c = thatReq.Id; 

            myNewOsrList.add(myNewOsr); 

        }

        String errorMsg 
            = SObjectJunctDupeCheck.checkForDupe(myNewOsrList, myOsrList, 
                                                'Certification__c', myOcList,
                                                'Requirement__c',   myOrList); 


        system.assertEquals(null,errorMsg); 
    }
   

}