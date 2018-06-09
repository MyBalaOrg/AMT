/**
*___________________________________________________
*@Name:     RevSys_OccupationSpecificReqValid_Test
*@Author:   Chuck Walley
*@Created:  Date: 01/01/2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for RevSys_OccupationSpecificReqValidation 
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class RevSys_OccupationSpecificReqValid_Test { 

    private static final String TRANSPORTATION  = 'Transportation'; 
    private static final String MECHANICAL      = 'Mechanical';  
    private static final String SYSTEMX         = 'System';
    private static final String ENGINEER        = 'Engineer';
    private static final String CONDUCTOR       = 'Conductor';
    private static final String ALL             = 'All';
    private static final String ACTIVE          = 'Active';
   
    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {
        // Create Occupation Requirements (Observations)  

        List<OccupationRequirement__c> myObsList = new List<OccupationRequirement__c>(); 

        OccupationRequirement__c myObs1 = new OccupationRequirement__c 
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID, 
            TestNumber__c   = '100', 
            TestName__c     = 'Test 100',
            Name            = '100 - Test 100',
            Status__c       = 'Active'
        ); 

        myObsList.add(myObs1);  

        OccupationRequirement__c myObs2 = new OccupationRequirement__c 
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID, 
            TestNumber__c   = '200', 
            TestName__c     = 'Test 200',
            Name            = '200 - Test 200',
            Status__c       = 'Active'
        ); 

        myObsList.add(myObs2);

        OccupationRequirement__c myObs3 = new OccupationRequirement__c 
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID, 
            TestNumber__c   = '300', 
            TestName__c     = 'Test 300',
            Name            = '300 - Test 300',
            Status__c       = 'Active'
        ); 

        myObsList.add(myObs3);

        OccupationRequirement__c myObs4 = new OccupationRequirement__c 
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID, 
            TestNumber__c   = '400', 
            TestName__c     = 'Test 400',
            Name            = '400 - Test 400',
            Status__c       = 'Active'
        ); 

        myObsList.add(myObs4);

        OccupationRequirement__c myObs5 = new OccupationRequirement__c 
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID, 
            TestNumber__c   = '500', 
            TestName__c     = 'Test 500',
            Name            = '500 - Test 500',
            Status__c       = 'Active'
        ); 

        myObsList.add(myObs5);

        INSERT myObsList; 

        List<OccupationRequirement__c> myObsOutList = new List<OccupationRequirement__c>
        ( 
            [SELECT Id, Name, Status__c, TestNumber__c, TestName__c 
             FROM   OccupationRequirement__c 
             WHERE  RecordTypeId = :RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID]
        );

        Map<String,OccupationRequirement__c> myObsByTestNumMap = new Map<String,OccupationRequirement__c>(); 

        for(OccupationRequirement__c myObs :myObsOutList)
        {
            myObsByTestNumMap.put(myObs.TestNumber__c, myObs); 
        }

        OccupationRequirement__c myObs100 = myObsByTestNumMap.get('100'); 

        List<OccupationSpecificRequirement__c> myDeptCraftObsList = new List<OccupationSpecificRequirement__c>(); 

        OccupationSpecificRequirement__c myDeptCraftObs1 = new OccupationSpecificRequirement__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID,
            ObservationDepartment2__c   = TRANSPORTATION,
            ObservationCraft2__c        = ENGINEER,
            Observation__c              = myObs100.Id, 
            Status__c                   = 'Active'
        ); 

        myDeptCraftObsList.add(myDeptCraftObs1); 

        OccupationSpecificRequirement__c myDeptCraftObs2 = new OccupationSpecificRequirement__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID,
            ObservationDepartment2__c   = MECHANICAL,
            ObservationCraft2__c        = ALL,
            Observation__c              = myObs100.Id, 
            Status__c                   = 'Active'
        ); 

        myDeptCraftObsList.add(myDeptCraftObs2); 

        insert myDeptCraftObsList; 


        List<OccupationCertification__c> myOcInsertList = new List<OccupationCertification__c>(); 


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
        myOcInsertList.add(myCert); 

        OccupationCertification__c myTarget = new OccupationCertification__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID,
            Name                = 'This Target', 
            Status__c           = 'Active',
            Frequency__c        = 'Months',
            NumberOfTestsPerPeriod__c
                                = 10,
            LengthOfPeriod__c   = 1,
            StartDate__c        = Date.today(), 
            EndDate__c          = date.today().addMonths(13)
        ); 
        myOcInsertList.add(myTarget); 

        insert myOcInsertList; 

        List<OccupationRequirement__c> myOrInsertList = new List<OccupationRequirement__c>(); 

        OccupationRequirement__c myReq = new OccupationRequirement__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name = 'This Requirement',
            Status__c = 'Active',
            Source__c = 'Observation',
            SourceRecordType__c = 'FORM-1872' 
        );
        myOrInsertList.add(myReq); 

        OccupationRequirement__c myReq2 = new OccupationRequirement__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name = 'That Requirement',
            Status__c = 'Active',
            Source__c = 'Observation',
            SourceRecordType__c = 'FORM-1872' 
        );
        myOrInsertList.add(myReq2); 

        insert myOrInsertList; 

        List<OccupationSpecificRequirement__c> myOsrInsertList = new List<OccupationSpecificRequirement__c>(); 

        OccupationSpecificRequirement__c myCertReq = new OccupationSpecificRequirement__c
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID,
            Certification__c = myCert.Id, 
            Requirement__c = myReq.Id, 
            Frequency__c = 'Days',
            LengthOfPeriod__c = 900,
            Status__c = 'Active'
        ); 
        myOsrInsertList.add(myCertReq);

        OccupationSpecificRequirement__c myTargetObs = new OccupationSpecificRequirement__c
        ( 
            RecordTypeId = Revsys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID,
            Observation__c = myObs1.Id, 
            Target__c = myTarget.Id, 
            Status__c = 'Active'
        ); 
        myOsrInsertList.add(myTargetObs);


        insert(myOsrInsertList); 




    }

    private static testmethod void testInsert()
    {
        List<OccupationRequirement__c> myObsList = new List<OccupationRequirement__c>
        ( 
            [SELECT Id, Name, Status__c, TestNumber__c, TestName__c 
             FROM   OccupationRequirement__c 
             WHERE  RecordTypeId = :RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID]
        );

        Map<String,OccupationRequirement__c> myObsByTestNumMap = new Map<String,OccupationRequirement__c>(); 

        for(OccupationRequirement__c myObs :myObsList)
        {
            myObsByTestNumMap.put(myObs.TestNumber__c, myObs); 
        }

        OccupationRequirement__c myObs100 = myObsByTestNumMap.get('100'); 
        OccupationRequirement__c myObs200 = myObsByTestNumMap.get('200'); 
        OccupationRequirement__c myObs300 = myObsByTestNumMap.get('300'); 
        OccupationRequirement__c myObs400 = myObsByTestNumMap.get('400'); 
        OccupationRequirement__c myObs500 = myObsByTestNumMap.get('500'); 

        List<OccupationSpecificRequirement__c> myNewList = new List<OccupationSpecificRequirement__c>(); 

        OccupationSpecificRequirement__c myNew1 = new OccupationSpecificRequirement__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID,
            ObservationDepartment2__c   = TRANSPORTATION,
            ObservationCraft2__c        = ENGINEER,
            Observation__c              = myObs100.Id, 
            Status__c                   = 'Active'
        ); 

        myNewList.add(myNew1); 

        List<OccupationSpecificRequirement__c> myOsrList = new List<OccupationSpecificRequirement__c>
        ( 
            [SELECT Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, 
                    Observation__c, Status__c, Test_Number__c, TestName__c
             FROM   OccupationSpecificRequirement__c 
             WHERE  RecordTypeId = :RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID]
        );

        system.debug('THE EXISTING OSR LIST: ' + myOsrList); 
        system.debug('MY NEW OSR LIST: ' + myNewList); 

        test.startTest(); 

            String myMsg; 

            try {
                
                insert myNewList; 

            } catch(DmlException qe) {

                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myMsg = qe.getMessage();
            }

            system.debug('MY MSG: ' + myMsg);  

        test.stopTest(); 
        
    }

    private static testmethod void testUpdate()
    {
        List<OccupationRequirement__c> myObsList = new List<OccupationRequirement__c>
        ( 
            [SELECT Id, Name, Status__c, TestNumber__c, TestName__c 
             FROM   OccupationRequirement__c 
             WHERE  RecordTypeId = :RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID]
        );

        Map<String,OccupationRequirement__c> myObsByTestNumMap = new Map<String,OccupationRequirement__c>(); 

        for(OccupationRequirement__c myObs :myObsList)
        {
            myObsByTestNumMap.put(myObs.TestNumber__c, myObs); 
        }

        OccupationRequirement__c myObs100 = myObsByTestNumMap.get('100'); 
        OccupationRequirement__c myObs200 = myObsByTestNumMap.get('200'); 
        OccupationRequirement__c myObs300 = myObsByTestNumMap.get('300'); 
        OccupationRequirement__c myObs400 = myObsByTestNumMap.get('400'); 
        OccupationRequirement__c myObs500 = myObsByTestNumMap.get('500'); 

        List<OccupationSpecificRequirement__c> myOsrList = new List<OccupationSpecificRequirement__c>
        ( 
            [SELECT Id, RecordTypeId, ObservationDepartment2__c, ObservationCraft2__c, 
                    Observation__c, Status__c 
             FROM   OccupationSpecificRequirement__c 
             WHERE  RecordTypeId = :RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID]
        );

        for(OccupationSpecificRequirement__c myOsr :myOsrList )
        {
            myOsr.Observation__c = myObs500.Id; 
        }

        test.startTest(); 

            update myOsrList; 
            

        test.stopTest(); 
        
    }


    private static testmethod void test_checkCertDupe_0()
    {
        String myQuery; 
        Id myRecTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID; 

        // Get OSR records; 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_SPECIFIC_REQUIREMENT);   
        myQuery  = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :myRecTypeId '; 
        List<OccupationSpecificRequirement__c> myOsrList = Database.query(myQuery); 


        // Get 'That Requirement' 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_REQUIREMENT);   
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE Name = \'That Requirement\' ';
        List<OccupationRequirement__c> thatReqList = Database.query(myQuery); 

        OccupationRequirement__c thatReq = thatReqList[0]; 

        List<OccupationSpecificRequirement__c> myNewOsrList = new List<OccupationSpecificRequirement__c>(); 

        for(OccupationSpecificRequirement__c myOsr :myOsrList) {
            OccupationSpecificRequirement__c myNewOsr = myOsr.clone(false,true,false,false); 
            myNewOsr.Requirement__c = thatReq.Id; 
            myNewOsrList.add(myNewOsr); 
        }


        test.startTest(); 

            String myMsg; 

            try {
                insert myNewOsrList; 
            } catch(DmlException qe) {
                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myMsg = qe.getMessage();
            }
            system.debug('MY MSG: ' + myMsg);  

            system.assertEquals(null,myMsg); 

        test.stopTest(); 
        
    }

    private static testmethod void test_checkCertDupe_1()
    {
        String myQuery; 
        Id myRecTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID; 

        // Get OSR records; 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_SPECIFIC_REQUIREMENT);   
        myQuery  = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :myRecTypeId '; 
        List<OccupationSpecificRequirement__c> myOsrList = Database.query(myQuery); 

        List<OccupationSpecificRequirement__c> myNewOsrList = new List<OccupationSpecificRequirement__c>(); 

        for(OccupationSpecificRequirement__c myOsr :myOsrList) {
            OccupationSpecificRequirement__c myNewOsr = myOsr.clone(false,true,false,false); 
            myNewOsrList.add(myNewOsr); 
        }


        test.startTest(); 

            String myMsg; 

            try {
                insert myNewOsrList; 
            } catch(DmlException qe) {
                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myMsg = qe.getMessage();
            }
            system.debug('MY MSG: ' + myMsg);  

            system.assertNotEquals(null,myMsg); 

        test.stopTest(); 
        
    }


    private static testmethod void test_checkTargetDupe_0()
    {
        String myQuery; 
        Id myRecTypeId = RevSys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID; 

        // Get OSR records; 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_SPECIFIC_REQUIREMENT);   
        myQuery  = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :myRecTypeId '; 
        List<OccupationSpecificRequirement__c> myOsrList = Database.query(myQuery); 


        // Get '200 Test' 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_REQUIREMENT);   
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE TestNumber__c = \'200\' ';
        List<OccupationRequirement__c> thatReqList = Database.query(myQuery); 

        OccupationRequirement__c thatReq = thatReqList[0]; 

        List<OccupationSpecificRequirement__c> myNewOsrList = new List<OccupationSpecificRequirement__c>(); 

        for(OccupationSpecificRequirement__c myOsr :myOsrList) {
            OccupationSpecificRequirement__c myNewOsr = myOsr.clone(false,true,false,false); 
            myNewOsr.Observation__c = thatReq.Id; 
            myNewOsrList.add(myNewOsr); 
        }


        test.startTest(); 

            String myMsg; 

            try {
                insert myNewOsrList; 
            } catch(DmlException qe) {
                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myMsg = qe.getMessage();
            }
            system.debug('MY MSG: ' + myMsg);  

            system.assertEquals(null,myMsg); 

        test.stopTest(); 
        
    }

    private static testmethod void test_checkTargetDupe_1()
    {
        String myQuery; 
        Id myRecTypeId = RevSys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID; 

        // Get OSR records; 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_SPECIFIC_REQUIREMENT);   
        myQuery  = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :myRecTypeId '; 
        List<OccupationSpecificRequirement__c> myOsrList = Database.query(myQuery); 

        List<OccupationSpecificRequirement__c> myNewOsrList = new List<OccupationSpecificRequirement__c>(); 

        for(OccupationSpecificRequirement__c myOsr :myOsrList) {
            OccupationSpecificRequirement__c myNewOsr = myOsr.clone(false,true,false,false); 
            //myNewOsr.Requirement__c = thatReq.Id; 
            myNewOsrList.add(myNewOsr); 
        }


        test.startTest(); 

            String myMsg; 

            try {
                insert myNewOsrList; 
            } catch(DmlException qe) {
                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myMsg = qe.getMessage();
            }
            system.debug('MY MSG: ' + myMsg);  

            system.assertNotEquals(null,myMsg); 

        test.stopTest(); 
        
    }
  
}