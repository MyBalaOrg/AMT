/**
*___________________________________________________
*@Name:     Revsys_EmployeeCertValidation_Test
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
public class Revsys_EmployeeCertValidation_Test { 

  
   
    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {
        RevSys_TestDataHelper.buildTestData();

        List<Contact> myContactList = new List<Contact>
        (  
            [SELECT Id, Email 
             FROM Contact]
        );

        Map<String,Id> myContactIdByEmailMap = new Map<String,Id>(); 

        for(Contact myCon :myContactList) {
            myContactIdByEmailMap.put(myCon.Email, myCon.Id); 
        }

        Id myEmpId = myContactIdByEmailMap.get('abigale.employee@amtrak.com');

        OccupationCertification__c myCert = new OccupationCertification__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID,
            Name                = 'This Certification', 
            Status__c           = 'Active',
            Frequency__c        = 'Months',
            LengthOfPeriod__c   = 1,
            StartDate__c        = Date.today(), 
            EndDate__c          = date.today().addMonths(13),
            CertificationType__c= 'Conductor'
        ); 

        insert myCert; 

        OccupationCertification__c myCert2 = new OccupationCertification__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID,
            Name                = 'Another Certification', 
            Status__c           = 'Active',
            Frequency__c        = 'Months',
            LengthOfPeriod__c   = 1,
            StartDate__c        = Date.today(), 
            EndDate__c          = date.today().addMonths(13),
            CertificationType__c= 'Conductor'
        );
        insert myCert2;

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
            Name = 'another Requirement',
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

        insert myCertReq; 

         OccupationSpecificRequirement__c myCertReq2 = new OccupationSpecificRequirement__c
        ( 
            RecordTypeId = Revsys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID,
            Certification__c = myCert2.Id, 
            Requirement__c = myReq2.Id, 
            Frequency__c = 'Days',
            LengthOfPeriod__c = 900,
            Status__c = 'Active'
        ); 

        insert myCertReq2; 

        List<EmployeeCertification__c> ecList = new List<EmployeeCertification__c>();
        EmployeeCertification__c ecRecord = new EmployeeCertification__c
        (
            Status__c = RevSys_StaticUtility.PENDING,
            Employee__c = myEmpId,
            Certification__c = myCert.Id,
            RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID
        );
        ecList.add(ecRecord);
        //insert ecRecord;


        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        Contact myContact = myEmpByFirstNameMap.get('Amy'); 
        
        EmployeeCertification__c myNewSup1 = new EmployeeCertification__c
        (  
            RecordTypeId = Revsys_StaticUtility.EMPCERT_SPARTSUPV_RECTYPE_ID, 
            Employee__c = myContact.Id,
            Status__c   = 'Active'
        );
        ecList.add(myNewSup1);

        INSERT ecList; 


    }

    private static testmethod void test_Insert_bad()
    {

        // Get EC records; 
        Id myRecTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_EMPLOYEE_CERTIFICATION);
        String myQuery  = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :myRecTypeId '; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 

        // Create a dupe 
        List<EmployeeCertification__c> myNewEcList = new List<EmployeeCertification__c>(); 

        for(EmployeeCertification__c myEc :myEcList) {
            EmployeeCertification__c myNewEc = myEc.clone(false,true,false,false); 
            myNewEcList.add(myNewEc); 
        }

        System.debug('------------- > ' +myNewEcList);
        test.startTest(); 

            String myMsg; 
            try {
                insert myNewEcList;
            } catch(DmlException qe) {
                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myMsg = qe.getMessage();
            }

            system.assertNotEquals(null,myMsg); 

        test.stopTest(); 
        
    }

    private static testmethod void test_Insert_badWithSameCertificationType()
    {

        // Get EC records; 
        Id myRecTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;

        OccupationCertification__c oc = [Select Id from OccupationCertification__c where Name='Another Certification' Limit 1];

        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_EMPLOYEE_CERTIFICATION);
        String myQuery  = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :myRecTypeId '; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 

        // Create a dupe 
        List<EmployeeCertification__c> myNewEcList = new List<EmployeeCertification__c>(); 

        for(EmployeeCertification__c myEc :myEcList) {
            EmployeeCertification__c myNewEc = myEc.clone(false,true,false,false); 
            myNewEc.Certification__c  = oc.Id;
            myNewEcList.add(myNewEc); 
        }

        System.debug('------------- > ' +myNewEcList);
        test.startTest(); 

            String myMsg; 
            try {
                insert myNewEcList;
            } catch(DmlException qe) {
                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myMsg = qe.getMessage();
            }

            system.assertNotEquals(null,myMsg); 

        test.stopTest(); 
        
    }

   private static testmethod void test_Insert_good()
    {

         Contact employeeA2 = new Contact
            (
                LastName            ='new', 
                FirstName           ='Adam', 
                Personnel_Number__c = 12342,
                Employment_Status__c = 'Active',
                Department          ='Transportation',
                Email               = 'CoolAmtrak@amtrak.com'
            );
            insert employeeA2;
            Id myEmpId = employeeA2.Id;
        OccupationCertification__c myCert = new OccupationCertification__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID,
            Name                = 'A Different Certification', 
            Status__c           = 'Active',
            Frequency__c        = 'Months',
            LengthOfPeriod__c   = 1,
            StartDate__c        = Date.today(), 
            EndDate__c          = date.today().addMonths(13),
            CertificationType__c = 'Conductor'
        ); 

        insert myCert; 

        OccupationRequirement__c myReq = new OccupationRequirement__c
        ( 
            RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
            Name = 'That Requirement',
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

        insert myCertReq; 

        EmployeeCertification__c ecRecord = new EmployeeCertification__c
        (
            Status__c = RevSys_StaticUtility.PENDING,
            Employee__c = myEmpId,
            Certification__c = myCert.Id,
            RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID
        );


        test.startTest(); 

            String myMsg; 
            try {
                insert ecRecord;
            } catch(DmlException qe) {
                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myMsg = qe.getMessage();
            }

            system.assertEquals(null,myMsg); 

        test.stopTest(); 
        
    }

    private static testmethod void test_checkSupervisorQualificationDupe_good()
    {
        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        Contact myContact = myEmpByFirstNameMap.get('Bob'); 

        Id myRecType = Revsys_StaticUtility.EMPCERT_SPARTSUPV_RECTYPE_ID; 
        // Get all Supervisor
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_EMPLOYEE_CERTIFICATION);   
        myQuery  = myQuWrap.QueryString; 
        myQuery += ' WHERE RecordTypeId = :myRecType '; 
        List<EmployeeCertification__c> mySuperList = Database.query(myQuery); 
        
        EmployeeCertification__c mySuper = mySuperList[0]; 

        mySuper.Employee__c = myContact.Id; 

        test.startTest(); 

            String myMsg; 
            try {
                update mySuper;
            } catch(DmlException qe) {
                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myMsg = qe.getMessage();
            }

            system.assertEquals(null,myMsg); 

        test.stopTest(); 
        
    }

    private static testmethod void test_checkSupervisorQualificationDupe_Error()
    {
        // Get all Contact records
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        String myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 

        Map<String,Contact> myEmpByFirstNameMap = new Map<String,Contact>(); 

        for(Contact myEmp :myEmpList) {
            myEmpByFirstNameMap.put(myEmp.FirstName, myEmp); 
        }

        Contact myContact = myEmpByFirstNameMap.get('Amy'); 


        EmployeeCertification__c myNewSup2 = new EmployeeCertification__c
        (  
            RecordTypeId = Revsys_StaticUtility.EMPCERT_SPARTSUPV_RECTYPE_ID, 
            Employee__c = myContact.Id,
            Status__c   = 'Active'
        );

        test.startTest(); 

            String myMsg; 
            try {
                insert myNewSup2;
            } catch(DmlException qe) {
                system.debug(System.Label.SOQL_Query_Error + qe.getMessage() );
                myMsg = qe.getMessage();
            }

            system.assertNotEquals(null,myMsg); 

        test.stopTest(); 
        
    }
}