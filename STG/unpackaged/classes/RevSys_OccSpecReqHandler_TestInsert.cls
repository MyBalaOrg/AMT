/**
*___________________________________________________
*@Name:     RevSys_OccSpecReqHandler_TestInsert
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
public class RevSys_OccSpecReqHandler_TestInsert { 
    
   
    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {

        RevSys_TestDataHelper.buildTestData();  

        List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();

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

        // Observations 

        List<OccupationRequirement__c> myObsList = new List<OccupationRequirement__c>
        ( 
            [SELECT ID, RecordTypeId, Name 
             FROM   OccupationRequirement__c
             WHERE  RecordTypeId = :RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID
             AND    Name = '100 - Test 100']
        );

        OccupationRequirement__c myObs = myObsList[0]; 

      
        //------------


        Violation__c myOverallViolation = new Violation__c
        ( 
            RecordTypeId = Revsys_StaticUtility.VIOLATION_SPARTN_OVERALL_VIOLATION_RECTYPE_ID ,
            CentralReportingIncidentId__c    = '123',
            IncidentDateTime__c              = DateTime.now(), 
            SPARTN_Nrpc3160Rule__c                  = null,
            ViolationType__c                 = myObs.Id,
            ViolationDescription__c          = 'Description' 
        ); 

        insert myOverallViolation; 

        Violation__c myEmployeeViolation = new Violation__c
        ( 
            RecordTypeId = Revsys_StaticUtility.VIOLATION_SPARTN_EMP_RECTYPE_ID ,
            ParentViolation__c = myOverallViolation.Id,
            SPARTN_Nrpc3160Rule__c                  = null,
            ViolationType__c                 = myObs.Id, 
            ViolationDescription__c          = 'Description',
            RemovedFromServiceDate__c        = Date.today(),
            Employee__c                      = myEmployee.Id 
        );  

        insert myEmployeeViolation; 

        OccupationCertification__c myTarget = new OccupationCertification__c
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCUPCERTIFICATION_SPARTN_VIOLATION_TARGET_RECTYPE_ID,
            Name                = 'Violation Target',
            Violation__c        = myEmployeeViolation.Id, 
            Status__c           = 'Active',
            Frequency__c        = 'Months',
            LengthOfPeriod__c   = 1,
            StartDate__c        = Date.today(), 
            EndDate__c          = date.today().addMonths(13)
        ); 

        insert myTarget; 

    }

    private static testmethod void testInsert()
    {

        List<OccupationCertification__c> myTargetList = new List<OccupationCertification__c> 
        (
            [SELECT Id, Name 
             FROM   OccupationCertification__c 
             WHERE  RecordTypeId = :Revsys_StaticUtility.OCCUPCERTIFICATION_SPARTN_VIOLATION_TARGET_RECTYPE_ID
             AND    Name = 'Violation Target' ]
        );

        OccupationCertification__c myTarget = myTargetList[0]; 

        // Observations 

        List<OccupationRequirement__c> myObsList = new List<OccupationRequirement__c>
        ( 
            [SELECT ID, RecordTypeId, Name 
             FROM   OccupationRequirement__c
             WHERE  RecordTypeId = :RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID
             AND    Name = '100 - Test 100']
        );

        OccupationRequirement__c myObs = myObsList[0]; 

        test.startTest(); 


            OccupationSpecificRequirement__c myTgtObs = new OccupationSpecificRequirement__c
            ( 
                RecordTypeId = Revsys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID,
                Target__c = myTarget.Id,
                Observation__c = myObs.Id
            ); 

            List<OccupationSpecificRequirement__c> myTgtObsList = new List<OccupationSpecificRequirement__c>(); 
            myTgtObsList.add(myTgtObs); 

            insert(myTgtObsList); 


        test.stopTest(); 
        
    }


}