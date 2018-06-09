/**
*___________________________________________________
*@Name:     Revsys_OccupationSpecReqHelper_Test
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
public class Revsys_OccupationSpecReqHelper_Test { 
    
   
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
            
         OccupationCertification__c certificate = new OccupationCertification__c();
		certificate.Status__c='Active';
		certificate.Name='Certificate1';
		certificate.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
		certificate.Frequency__c='Days';
		certificate.LengthOfPeriod__c=1;
		insert certificate;

		OccupationRequirement__c req= new OccupationRequirement__c();
		req.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
		req.Name = 'Requirement Name';
		req.Source__c= 'Employee Result Summary';
		req.SourceRecordType__c = 'Medical, Hearing and Vision';
		req.SourceTestType__c = 'Medical Examination';
		req.Status__c = 'Active';
		insert req;

		OccupationSpecificRequirement__c osr = new OccupationSpecificRequirement__c();
		osr.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
		osr.Certification__c = certificate.Id;
		osr.Requirement__c = req.Id;
		osr.Frequency__c = 'Days';
		osr.LengthOfPeriod__c = 10;
		insert osr;
     	
        EmployeeSpecificRequirement__c esrObject = new EmployeeSpecificRequirement__c();
        esrObject.OccupationSpecificRequirement__c = osr.Id;
        esrObject.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
      //  esrObject.Employee__c = emCertification.id;
    //    esrObject.EmployeeCertification__c = osr.Id;
        esrObject.Requirement__c = osr.Requirement__c;
        esrObject.Certification__c = osr.Certification__c;
        esrObject.Status__c = RevSys_StaticUtility.ACTIVE;
        esrObject.ReportStatus__c = Label.RevSys_Generic_Pending;
        
        insert esrObject;
        
    }

  	  private static testmethod void testO()
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

        OccupationSpecificRequirement__c myTgtObs = new OccupationSpecificRequirement__c
        ( 
            RecordTypeId = Revsys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID,
            Target__c = myTarget.Id,
            Observation__c = myObs.Id

        ); 

        List<OccupationSpecificRequirement__c> myTgtObsList = new List<OccupationSpecificRequirement__c>(); 
        myTgtObsList.add(myTgtObs); 

        test.startTest(); 

            Revsys_OccupationSpecReqHelper.addEmployeeViolationCheck(myTgtObsList); 


            List<Violation__c> myEmpViolationList = new List<Violation__c>
            ( 
                [SELECT Id, Name from Violation__c 
                 WHERE  RecordTypeId = :Revsys_StaticUtility.VIOLATION_SPARTN_EMP_RECTYPE_ID ]
            );

            Violation__c myEmpViolation = myEmpViolationList[0]; 

            system.assertEquals(myEmpViolation.Id, myTgtObs.Violation__c); 

        test.stopTest(); 
        
    }
    
      public static testmethod void testCreatedESR(){
        Test.startTest();
       

        Set<Id> ids = new Set<Id>();
        Set<Id> osrids = new Set<Id>();
        List<OccupationCertification__c> occCert = [SELECT Id from OccupationCertification__c WHERE Name = 'Certificate1'];
        for(OccupationCertification__c oc : occCert){
            ids.add(oc.Id);
        }
        List<OccupationSpecificRequirement__c> oSRobj = [SELECT Id from OccupationSpecificRequirement__c WHERE Certification__c IN :ids];
        for(OccupationSpecificRequirement__c osrs : oSRobj){
            osrids.add(osrs.Id);
            System.debug('osrids $$$ '+osrids);
        }//System.debug('osrids $$$ '+osrids);
        EmployeeSpecificRequirement__c esr = [SELECT Id, OccupationSpecificRequirement__c, Requirement__c from EmployeeSpecificRequirement__c WHERE OccupationSpecificRequirement__c IN :osrids];
        System.assertEquals(esr.OccupationSpecificRequirement__c, oSRobj.get(0).Id);
        Test.stopTest();
    }
  
}