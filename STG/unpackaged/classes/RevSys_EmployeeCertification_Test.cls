/**
*___________________________________________________
*@Name: 	RevSys_EmployeeCertification_Test
*@Author: 	Raj Kumar Pandy
*@Created: 	Date: 12/7/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Test for RevSys_EmployeeCertificationHelper
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class RevSys_EmployeeCertification_Test {
    
    private static final String PENDING  = 'Pending';
    private static final String CURRENT  = 'Current';
    private static final String ACTIVE  = 'Active';
    private static final String DAYS  = 'Days';
    
    //Creating Test Data
	@TestSetup
	public static void loadTestData()
    {

        SPARTN_BypassRuleSettings__c orgsettings = SPARTN_BypassRuleSettings__c.getOrgDefaults();  
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


        OccupationCertification__c occCert  =  new OccupationCertification__c();
		occCert.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert.Name = 'Occupation Certification 1';
        occCert.LengthOfPeriod__c = 8;
        occCert.NumberOfTestsPerPeriod__c = 2;
        occCert.Status__c = ACTIVE;
        
        insert occCert;

        OccupationCertification__c occCert2  =  new OccupationCertification__c();
        occCert2.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert2.Name = 'Occupation Certification 2';
        occCert2.LengthOfPeriod__c = 8;
        occCert2.NumberOfTestsPerPeriod__c = 2;
        occCert2.Status__c = ACTIVE;
        insert occCert2;
        
        List<OccupationRequirement__c> occReqList = new List<OccupationRequirement__c>();       
        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 1';
        occReqObj.Status__c = ACTIVE;
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqList.add(occReqObj);
        
        occReqObj= new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Req 2';
        occReqObj.Status__c = ACTIVE;
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqList.add(occReqObj);

        occReqObj= new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Req 3';
        occReqObj.Status__c = ACTIVE;
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqList.add(occReqObj);
        
        insert occReqList;
        
        List<OccupationSpecificRequirement__c> occSpecReqList = new List<OccupationSpecificRequirement__c>();       
        OccupationSpecificRequirement__c occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqList[0].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c='Years';
        occSpecReqList.add(occSpecReqObj);
        
        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqList[1].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c='Years';
        occSpecReqList.add(occSpecReqObj);

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert2.id;
        occSpecReqObj.Requirement__c = occReqList[2].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c='Years';
        occSpecReqList.add(occSpecReqObj);
        
        insert occSpecReqList; 
        
        Contact employee = new Contact
		(
			LastName			='Employee', 
			FirstName			='Amy', 
			Personnel_Number__c = 1234567,
			Email 				= 'test.test@amtrak.com',
            Employment_Status__c = 'Active',
            Department = 'Transportation'
		);
		insert employee; 

    }
    
    private static testmethod void createEmpCertTest()
    {
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        List<OccupationSpecificRequirement__c> occSpecReqList = new List<OccupationSpecificRequirement__c>();
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 1' LIMIT 1];
        occSpecReqList = occCert.Occupation_Specific_Requirements1__r;
        
       
        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = PENDING;
        
        Test.startTest();
        insert empCertObj;
        
        //update empCertObj;
        Test.stopTest();
        
        List<EmployeeSpecificRequirement__c> empSpecReqList = new List<EmployeeSpecificRequirement__c>();
        EmployeeCertification__c temEmpCertObj = [Select id,RecordTypeId,Certification__c,Employee__c,Status__c,ExpirationDate__c, (Select id from Employee_Specific_Requirements__r) from EmployeeCertification__c WHERE Certification__c =: occCert.id LIMIT 1];
        empSpecReqList = temEmpCertObj.Employee_Specific_Requirements__r;
        
        system.debug('The Result '+occSpecReqList.size());
        system.debug('The Result '+empSpecReqList.size());
        system.assertEquals(occSpecReqList.size(), empSpecReqList.size());

    }

    //Test EmployeeCertificationHelper validateCertification Method
    //Test without any ESR created for the Employee Certification
    public static testMethod void testValidationCertificationNoESR(){
        Test.startTest();
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 2' LIMIT 1];

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = PENDING;
        insert empCertObj;

        EmployeeCertification__c temEmpCertObj = [Select id,RevocationBeginDate__c,RevocationEndDate__c,RecordTypeId,Certification__c,Employee__c,Status__c,ExpirationDate__c,(Select id from Employee_Specific_Requirements__r) from EmployeeCertification__c WHERE Id =: empCertObj.id];
        List<EmployeeSpecificRequirement__c> esrList = temEmpCertObj.Employee_Specific_Requirements__r;
        delete esrList;

        List<RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper> wrapperList  = RevSys_EmployeeCertificationHelper.validateCertification(new List<EmployeeCertification__c>{temEmpCertObj});
        System.assertEquals(Label.Revsys_Error_for_Certification_with_no_Requirements_data_setup,wrapperList.get(0).errorMsg);

        Test.stopTest();

    }

     //Test EmployeeCertificationHelper validateCertification Method
     //Certification with incomplete requirements
    public static testMethod void testValidationCertificationNoReq(){
        Test.startTest();
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 2' LIMIT 1];

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = PENDING;
        insert empCertObj;

        EmployeeCertification__c temEmpCertObj = [Select id,RevocationBeginDate__c,RevocationEndDate__c,RecordTypeId,Certification__c,Employee__c,Status__c,ExpirationDate__c,(Select id from Employee_Specific_Requirements__r) from EmployeeCertification__c WHERE Id =: empCertObj.id];

        List<RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper> wrapperList  = RevSys_EmployeeCertificationHelper.validateCertification(new List<EmployeeCertification__c>{temEmpCertObj});
        System.assertEquals(true, wrapperList.get(0).errorMsg.contains(Label.RevSys_Error_Message_Certificate_Validation));

        Test.stopTest();

    }

     //Test EmployeeCertificationHelper validateCertification Method
     //Certification with incomplete requirements
    public static testMethod void testNoOSR(){
        Test.startTest();
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 2' LIMIT 1];
        List<OccupationSpecificRequirement__c> osrList = [Select Id from OccupationSpecificRequirement__c];
        delete osrList;
        try{
        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = PENDING;
        insert empCertObj;
        } catch(Exception e) {
            Boolean b = e.getMessage().contains(Label.Revsys_Certification_does_not_have_any_Occupation_Specific_Requirements_defined)?true:false;
            System.assertEquals(true,b);
        }

        Test.stopTest();

    }

    //Test EmployeeCertificationHelper validateCertification Method
    //Without MVR Record
    public static testMethod void testValidationCertificationNoMVR(){
        Test.startTest();
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 2' LIMIT 1];

        OccupationRequirement__c newOR = new OccupationRequirement__c();
        newOR.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR.Name =  'Test Requirement 2';
        newOR.Source__c = 'Employee Result Summary';
        newOR.SourceRecordType__c = 'Motor Vehicle Review';
        newOR.SourceTestType__c = Label.RevSys_Generic_State_Review;
        insert newOR;

        OccupationSpecificRequirement__c newOsr  =  new OccupationSpecificRequirement__c();
        newOsr.RecordTypeId    = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        newOsr.Status__c       = RevSys_StaticUtility.ACTIVE;
        newOsr.Frequency__c = 'Days';
        newOsr.LengthOfPeriod__c = 1;
        newOsr.Certification__c = occCert.Id;
        newOsr.Requirement__c = newOR.Id;
        insert newOsr;

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = PENDING;
        insert empCertObj;

        EmployeeCertification__c temEmpCertObj = [Select id,RevocationBeginDate__c,RevocationEndDate__c,RecordTypeId,Certification__c,Employee__c,Status__c,ExpirationDate__c,(Select id from Employee_Specific_Requirements__r) from EmployeeCertification__c WHERE Id =: empCertObj.id];
        List<EmployeeSpecificRequirement__c> ecListToUpdate = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : temEmpCertObj.Employee_Specific_Requirements__r) {
            esr.LastFulfilledDate__c = System.today();
            ecListToUpdate.add(esr);
        }
        update ecListToUpdate;

         // Motor Vehicle Review Form for Contact
        EmployeeResultSummary__c vehicleReviewForm = new EmployeeResultSummary__c
        (
            RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID,
            Employee__c = employee.Id,
            Status__c = Label.RevSys_Generic_Fail,
            StateReviewDate__c = System.today()
        );
        insert vehicleReviewForm;

        List<RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper> wrapperList  = RevSys_EmployeeCertificationHelper.validateCertification(new List<EmployeeCertification__c>{temEmpCertObj});
        System.assertEquals(true, wrapperList.get(0).hasError);


        vehicleReviewForm.Status__c = Label.RevSys_Generic_Pass;
        update vehicleReviewForm;

        wrapperList  = RevSys_EmployeeCertificationHelper.validateCertification(new List<EmployeeCertification__c>{temEmpCertObj});
        System.assertEquals(false, wrapperList.get(0).hasError);
        Test.stopTest();

    }

    //Test EmployeeCertificationHelper validateCertification Method
    //ESR realed to ERS (Medical exisits but failed result)
    public static testMethod void testValidationCertificationFailMHV(){
        Test.startTest();
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 2' LIMIT 1];

        OccupationRequirement__c newOR = new OccupationRequirement__c();
        newOR.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR.Name =  'Test Requirement 2';
        newOR.Source__c = 'Employee Result Summary';
        newOR.SourceRecordType__c = 'Medical, Hearing and Vision';
        newOR.SourceTestType__c = 'Medical Examination';
        insert newOR;

        OccupationSpecificRequirement__c newOsr  =  new OccupationSpecificRequirement__c();
        newOsr.RecordTypeId    = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        newOsr.Status__c       = RevSys_StaticUtility.ACTIVE;
        newOsr.Frequency__c = 'Days';
        newOsr.LengthOfPeriod__c = 1;
        newOsr.Certification__c = occCert.Id;
        newOsr.Requirement__c = newOR.Id;
        insert newOsr;

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = PENDING;
        insert empCertObj;

        EmployeeCertification__c temEmpCertObj = [Select id,RevocationBeginDate__c,RevocationEndDate__c,RecordTypeId,Certification__c,Employee__c,Status__c,ExpirationDate__c,(Select id from Employee_Specific_Requirements__r) from EmployeeCertification__c WHERE Id =: empCertObj.id];
        List<EmployeeSpecificRequirement__c> ecListToUpdate = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : temEmpCertObj.Employee_Specific_Requirements__r) {
            esr.LastFulfilledDate__c = System.today().addDays(-1);
            ecListToUpdate.add(esr);
        }
        update ecListToUpdate;

        // Medical, Hearing and Vision for Contact
        EmployeeResultSummary__c mvhForm = new EmployeeResultSummary__c
        (   
            EvaluationDate__c = System.today(),
            RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID,
            Employee__c = employee.Id,
            Result__c = Label.RevSys_ESR_Result_DN_Meet_Medical_Standards,
            Type__c = Label.RevSys_Generic_Medical_Examination,
            Comments__c = 'Test Comments'
        );
        insert mvhForm;

        List<RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper> wrapperList  = RevSys_EmployeeCertificationHelper.validateCertification(new List<EmployeeCertification__c>{temEmpCertObj});
        System.assertEquals(true, wrapperList.get(0).hasError);

       
        mvhForm.Result__c = Label.RevSys_ESR_Result_Meets_Medical_Standards;
        update mvhForm;


        wrapperList  = RevSys_EmployeeCertificationHelper.validateCertification(new List<EmployeeCertification__c>{temEmpCertObj});
        System.assertEquals(false, wrapperList.get(0).hasError); 
        Test.stopTest();

    }

    //Test EmployeeCertificationHelper validateCertification Method
    //Set the status of valid Certification
    public static testMethod void testUpdateCertification(){
        Test.startTest();
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 2' LIMIT 1];

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = PENDING;
        insert empCertObj;

        EmployeeCertification__c temEmpCertObj = [Select id,RecordTypeId,Certification__c,Employee__c,Status__c,ExpirationDate__c,(Select id from Employee_Specific_Requirements__r) from EmployeeCertification__c WHERE Id =: empCertObj.id];
        List<EmployeeSpecificRequirement__c> ecListToUpdate = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : temEmpCertObj.Employee_Specific_Requirements__r) {
            esr.LastFulfilledDate__c = System.today();
            ecListToUpdate.add(esr);
        }
        update ecListToUpdate;


        // Motor Vehicle Review Form for Contact
        EmployeeResultSummary__c vehicleReviewForm = new EmployeeResultSummary__c
        (
            RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID,
            Employee__c = employee.Id,
            Status__c = RevSys_StaticUtility.PASS
        );
        insert vehicleReviewForm;


       String errorMsg  = RevSys_EmployeeCertificationHelper.updateCertification(new List<EmployeeCertification__c>{temEmpCertObj});
       System.assertEquals(null,errorMsg);

        /*EmployeeCertification__c ec = [Select Id,Status__c from EmployeeCertification__c where Id !=:empCertObj.Id ];
        System.assertEquals(RevSys_StaticUtility.CURRENT,ec.Status__c);*/

        Test.stopTest();

    }

    //Testing RevSys_EmployeeCertificationStatusHelper class
    //SetExpired Method
    public static testMethod void testSetExpiredStatus() {
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 1' LIMIT 1];

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = PENDING;
        insert empCertObj;

        RevSys_EmployeeCertificationStatusHelper.setExpiredStatus(new List<EmployeeCertification__c>{empCertObj});

        EmployeeCertification__c ec = [Select Id,Status__c from EmployeeCertification__c where Id =:empCertObj.Id];
        System.assertEquals(RevSys_StaticUtility.EXPIRED,ec.Status__c);

    }

    //SetExpired Method
    public static testMethod void testSetCurrentStatus() {

        

        Test.startTest();

        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 1' LIMIT 1];

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = 'Expired';
        empCertObj.LastCertificationDate__c = system.today().addDays(-100);


        List<EmployeeCertification__c> myEcList = new List<EmployeeCertification__c>(); 
        myEcList.add(empCertObj); 

        String errMsg = DmlHelper.insertList(myEcList);

        SYSTEM.DEBUG('XXXXXXXXXXXXXXXx errMsg  ' + errMsg); 

        empCertObj.LastCertificationDate__c = system.today(); 

        RevSys_EmployeeCertificationStatusHelper.setCurrentStatus(myEcList);

        Test.stopTest(); 

        //Certification History
        EmployeeCertification__c ec = [Select Id,Status__c from EmployeeCertification__c where Id !=:empCertObj.Id];
        System.assertEquals(RevSys_StaticUtility.CURRENT,ec.Status__c);

    }

    //EmployeeCertificationHistory
    public static testMethod void testCreateCertificationHistory(){
        Test.startTest();
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 2' LIMIT 1];

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = PENDING;
        insert empCertObj;

        List<EmployeeSpecificRequirement__c> ecListToUpdate = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : empCertObj.Employee_Specific_Requirements__r) {
            esr.LastFulfilledDate__c = System.today();
            ecListToUpdate.add(esr);
        }
        update ecListToUpdate;

        CertificationRevocation__c cert = new CertificationRevocation__c();
        cert.IncidentDate__c = System.today();
        cert.Description__c = 'Test Description';
        cert.EmployeeCertification__c = empCertObj.Id;
        cert.PerformingAs__c = 'Conductor'; 
        cert.TrackType__c = 'Main Track';
        cert.RevocationBeginDate__c = System.today();
        insert cert;

        RevSys_EmployeeCertificationStatusHelper.setCurrentStatus(new List<EmployeeCertification__c>{empCertObj});  

        EmployeeCertification__c ec = [Select Id,Status__c,CertificationNumber__c from EmployeeCertification__c where Id =:empCertObj.Id];
        //System.assertEquals(RevSys_StaticUtility.PENDING,ec.Status__c);

        //EmployeeCertification__c newCert = [Select Id,Status__c from EmployeeCertification__c where CertificationNumber__c= :ec.CertificationNumber__c order by createdDate desc Limit 1];
        //System.assertEquals(RevSys_StaticUtility.CURRENT,newCert.Status__c);
        Test.stopTest();
    }

    //Test Create Supervisor Targets
    public static testMethod void testCreateCertificateTargets(){
    Test.startTest();

    OccupationCertification__c certificate = new OccupationCertification__c();
    certificate.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
    certificate.Name='New Occupation';
    certificate.CertificationType__c = 'Conductor';
    certificate.Frequency__c = 'Months';
    certificate.LengthOfPeriod__c = 1;
    certificate.Status__c = 'Active';
    insert certificate;

    List<OccupationCertification__c> occList = new List<OccupationCertification__c>();
    OccupationCertification__c occ = new OccupationCertification__c();
    occ.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
    occ.TargetType__c = 'Certification';
    occ.ParentCertification__c = certificate.Id;
    occ.Name = 'Certification target';
    occ.Frequency__c = 'Months';
    occ.LengthOfPeriod__c = 1;
    occ.Status__c = 'Active';
    occ.NumberOfTestsPerPeriod__c = 1;
    occ.StartDate__c = System.today();
    occ.Department__c = 'Transportation';
    occList.add(occ);

    occ = new OccupationCertification__c();
    occ.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
    occ.TargetType__c = 'Certification';
    occ.ParentCertification__c = certificate.Id;
    occ.Name = 'Nwe Certification target';
    occ.Frequency__c = 'Months';
    occ.LengthOfPeriod__c = 1;
    occ.Status__c = 'Active';
    occ.NumberOfTestsPerPeriod__c = 1;
    occ.StartDate__c = System.today();
    occ.Department__c = 'Transportation';
    occList.add(occ);
    insert occList;

    List<OccupationSpecificRequirement__c> osrList = new List<OccupationSpecificRequirement__c>();
    OccupationSpecificRequirement__c osr = new OccupationSpecificRequirement__c();
    osr.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
    osr.LengthOfPeriod__c = 1;
    osr.Certification__c = certificate.Id;
    osr.Target__c = occList[0].Id;
    osr.Frequency__c = 'Years';
    osr.Status__c='Active';
    osrList.add(osr);

    osr = new OccupationSpecificRequirement__c();
    osr.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
    osr.LengthOfPeriod__c = 1;
    osr.Certification__c = certificate.Id;
    osr.Target__c = occList[1].Id;
    osr.Frequency__c = 'Years';
    osr.Status__c='Active';
    osrList.add(osr);
    insert osrList;


    Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
   
    EmployeeCertification__c empCertObj = new EmployeeCertification__c();
    empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
    empCertObj.Certification__c = certificate.id;
    empCertObj.Employee__c = employee.id;
    empCertObj.Status__c = RevSys_StaticUtility.CURRENT;
    empCertObj.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
    insert empCertObj;

    List<EmployeeSpecificRequirement__c> esr = [Select Id from EmployeeSpecificRequirement__c where Target__c =:occ.Id and Employee__c=:employee.Id];
    System.assertNotEquals(0,esr.size());
    Test.stopTest();

    }

    public static testMethod void testEstablishSupervisorTargets() {
        Test.startTest();

        OccupationCertification__c supTarget = new  OccupationCertification__c();
        supTarget.Name = 'Supervisor Target';
        supTarget.TargetType__c = 'Supervisor';
        supTarget.Status__c= 'Active';
        supTarget.SupervisorType__c = 'Applies to all Observations';
        supTarget.Frequency__c = 'Months';
        supTarget.LengthOfPeriod__c = 1;
        supTarget.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
        supTarget.StartDate__c = System.today();
        supTarget.Department__c = 'Transportation';
        insert supTarget;

        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        
        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTSUPV_RECTYPE_ID;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = 'Inactive';
        insert empCertObj;

        empCertObj.Status__c = 'Active';
        update empCertObj;  
        Test.stopTest();
    }

    public static testMethod void testValidationCertification2() {
        Test.startTest();

        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Emp Cert: Num Days to Check for Reqs';
        setting.CsvString__c = '1200';    
        insert setting;

        setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Earliest Amtrak Date';
        setting.CsvString__c = '1971-10-30';    
        insert setting;

        Contact employee = new Contact
        (
            LastName            ='Employee', 
            FirstName           ='Amy2', 
            Personnel_Number__c = 1234123,
            Employment_Status__c = 'Active',
            Email               = 'test.test13@amtrak.com',
            Department = 'Transportation',
            Craft__c = 'System'
        );
        insert employee; 

        OccupationCertification__c occCert  =  new OccupationCertification__c();
        occCert.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert.Name = 'NewOcc1212';
        occCert.LengthOfPeriod__c = 1;
        occCert.Frequency__c = 'Months';
        occCert.CertificationType__c = 'Student Engineer';
        //occCert.NumberOfTestsPerPeriod__c = 2;
        occCert.Status__c = RevSys_StaticUtility.ACTIVE;
        insert occCert;


        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'NewReq1212';
        occReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occReqObj.SourceRecordType__c = 'Form-1875';
        occReqObj.Source__c = 'Observation';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        insert occReqObj;

        OccupationSpecificRequirement__c occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqObj.id;
        occSpecReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c='Months';
        insert occSpecReqObj;


        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = 'Pending';
        empCertObj.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        insert empCertObj;

        /*empCertObj.Status__c = 'Current';
        empCertObj.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        update empCertObj;*/

        List<EmployeeSpecificRequirement__c> esrList = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : [Select ReportStatus__c,LastFulfilledDate__c from EmployeeSpecificRequirement__c where EmployeeCertification__c=:empCertObj.Id]) {
            esr.LastFulfilledDate__c = System.today();
            esr.ReportStatus__c  = 'Fail';
            esrList.add(esr);
        }
        update esrList;

        List<RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper> wrapperList  = RevSys_EmployeeCertificationHelper.validateCertification(new List<EmployeeCertification__c>{empCertObj});
        System.assertEquals(true, wrapperList.get(0).hasError); 
        Test.stopTest();
    }

    public static testMethod void testValidationCertification3() {
        Test.startTest();

        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Emp Cert: Num Days to Check for Reqs';
        setting.CsvString__c = '1200';    
        insert setting;

        setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Earliest Amtrak Date';
        setting.CsvString__c = '1971-10-30';    
        insert setting;

        Contact employee = new Contact
        (
            LastName            ='Employee', 
            FirstName           ='Amy2', 
            Personnel_Number__c = 1234123,
            Employment_Status__c = 'Active',
            Email               = 'test.test13@amtrak.com',
            Department = 'Transportation',
            Craft__c = 'System'
        );
        insert employee; 

        OccupationCertification__c occCert  =  new OccupationCertification__c();
        occCert.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert.Name = 'NewOcc1212';
        occCert.LengthOfPeriod__c = 1;
        occCert.Frequency__c = 'Months';
        occCert.CertificationType__c = 'Student Engineer';
        //occCert.NumberOfTestsPerPeriod__c = 2;
        occCert.Status__c = RevSys_StaticUtility.ACTIVE;
        insert occCert;


        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'NewReq1212';
        occReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occReqObj.SourceRecordType__c = 'Employment History';
        occReqObj.Source__c = 'Employee Result Summary';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        insert occReqObj;

        OccupationSpecificRequirement__c occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqObj.id;
        occSpecReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c='Months';
        insert occSpecReqObj;


        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = 'Pending';
        empCertObj.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        insert empCertObj;

        List<EmployeeSpecificRequirement__c> esrList = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : [Select ReportStatus__c,LastFulfilledDate__c from EmployeeSpecificRequirement__c where EmployeeCertification__c=:empCertObj.Id]) {
            esr.LastFulfilledDate__c = System.today();
            esr.ReportStatus__c  = 'Fail';
            esrList.add(esr);
        }
        update esrList;

        List<RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper> wrapperList  = RevSys_EmployeeCertificationHelper.validateCertification(new List<EmployeeCertification__c>{empCertObj});
        System.assertEquals(true, wrapperList.get(0).hasError); 
        Test.stopTest();
    }

    public static testMethod void testReplaceLastCertifiedDate() {
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c, (Select id from Occupation_Specific_Requirements1__r) from OccupationCertification__c where Name = 'Occupation Certification 1' LIMIT 1];

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = 'Current';
        empCertObj.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
        insert empCertObj;
        Test.startTest();
        empCertObj.CertificationReCertificationDate__c  = System.today();
        update empCertObj;

        Map<Id,EmployeeCertification__c> oldMap = new Map<Id,EmployeeCertification__c>();
        oldMap.put(empCertObj.Id, empCertObj);
        RevSys_EmployeeCertificationHelper.replaceLastCertifiedDate(new List<EmployeeCertification__c>{empCertObj},oldMap);
        Test.stopTest();

    }

}