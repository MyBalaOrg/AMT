/**
*___________________________________________________
*@Name: RevSys_EmpCert_RecordDetailCtrl_Test
*@Author: Hemanth Kesapragada
*@Created: Date: 01/12/2017
*@Used_By: SPARTN
*___________________________________________________
*@Description: 
* Test class for the RevSys_EmpCert_RecordDetailController class
*___________________________________________________
*@Changes: 
**/
@isTest
private class RevSys_EmpCert_RecordDetailCtrl_Test {
	@TestSetup
	public static void loadTestData() {

        
        Id myAmtrakEmployeeProfileId = [SELECT Id FROM Profile WHERE Name = 'Amtrak Employee'].Id;
        User userSupervisorA = new User 
        ( 
            FirstName           = 'Amy',
            LastName            = 'Supervisor',
            Username            = 'test.test@amtrak.com',
            Alias               = 'superamy',
            Email               = 'amy.supervisor@amtrak.com.ifi',
            Status__c           = 'Active',
            EmployeeNumber      = '10000000',
            ProfileId           =  myAmtrakEmployeeProfileId,
            TimeZoneSidKey      = 'America/New_York',
            EmailEncodingKey    = 'UTF-8',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US'
            );
        insert userSupervisorA; 

        PermissionSet perm = [Select Id from PermissionSet where Name='SPARTN_Target_Administrator'];


        PermissionSetAssignment assign = new PermissionSetAssignment();
        assign.PermissionSetId = perm.Id;
        assign.AssigneeId = userSupervisorA.Id;
        insert assign;




        
	}

    private static void buildTestData() {
        OccupationCertification__c certificate = new OccupationCertification__c();
        certificate.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        certificate.Name='New Occupation';
        certificate.CertificationType__c = 'Conductor';
        certificate.Frequency__c = 'Months';
        certificate.LengthOfPeriod__c = 1;
        certificate.Status__c = 'Active';
        insert certificate;

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
        insert occ;

        OccupationSpecificRequirement__c osr = new OccupationSpecificRequirement__c();
        osr.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        osr.LengthOfPeriod__c = 1;
        osr.Certification__c = certificate.Id;
        osr.Target__c = occ.Id;
        osr.Frequency__c = 'Months';
        osr.Status__c='Active';
        insert osr;
        
        Contact employee = new Contact
        (
            LastName            ='Employee', 
            FirstName           ='Amy', 
            Personnel_Number__c = 1234567,
            Employment_Status__c = 'Active',
            Email               = 'test.test@amtrak.com',
            Department = 'Transportation'
        );
        insert employee; 

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = certificate.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = RevSys_StaticUtility.CURRENT;
        empCertObj.ProcessFlag__c  = Label.RevSys_EmpCert_ProcessFlag;
        insert empCertObj;


        REVSYS_Custom_Settings__c cs = new REVSYS_Custom_Settings__c();
        cs.Name = 'Hide Employee Certification Buttons';
        cs.CSVString__c = 'SPARTN_Target_Administrator';
        insert cs;

        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Emp Cert: Num Days to Check for Reqs';
        setting.CsvString__c = '1200';    
        insert setting;

        setting = new SPARTN_Custom_Settings__c();  
        setting.Name = 'Earliest Amtrak Date';
        setting.CsvString__c = '1971-10-30';    
        insert setting;
    }
	
	/**
    *————————————————————————————————————————————————————
    * @Name: testGetEmpCertificationsNoAccess
    * @Description
    * test method to test GetEmpCertificationsMethod
    *————————————————————————————————————————————————————
    **/
    public static testMethod void testGetEmpCertificationsNoAccess() {
      Test.startTest();
      User user = [Select Id from User Where Username='test.test@amtrak.com'];
      System.runAs(user) {
        buildTestData();
        EmployeeCertification__c ecRecord = [Select Id,Status__c from EmployeeCertification__c Limit 1];
        Map<String, String> responseMap = RevSys_EmpCert_RecordDetailController.getEmpCertifications(ecRecord.Id);
        System.assertEquals(Boolean.valueOf(responseMap.get('hasPermission')),false); 
    }
    Test.stopTest();
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: testGetEmpCertificationsNoAccess
    * @Description
    * test method to test GetEmpCertificationsMethod
    *————————————————————————————————————————————————————
    **/
    public static testMethod void testGetEmpCertifications() {
      Test.startTest();
      buildTestData();
      EmployeeCertification__c ecRecord = [Select Id,Status__c from EmployeeCertification__c Limit 1];
      Map<String, String> responseMap = RevSys_EmpCert_RecordDetailController.getEmpCertifications(ecRecord.Id);
      System.assertEquals(Boolean.valueOf(responseMap.get('hasPermission')),true); 
      Test.stopTest();
  }

	/**
    *————————————————————————————————————————————————————
    * @Name: testSaveLastPrintedDetails
    * @Description
    * test method to test GetEmpCertificationsMethod
    *————————————————————————————————————————————————————
    **/
	public static testMethod void testSaveLastPrintedDetails() {
		Test.startTest();
        buildTestData();
		EmployeeCertification__c ecRecord = [Select Id,Status__c,LastPrintedDate__c,LastPrintedBy__c from EmployeeCertification__c Limit 1];
		System.assertEquals(null,ecRecord.LastPrintedBy__c);
		Map<String,String> response = RevSys_EmpCert_RecordDetailController.saveLastPrintedDetails(ecRecord.Id);
		System.assertEquals(null,response.get('errorMsg'));
		sObject newSObject = (Sobject) Json.deserialize(response.get('empCert'),Sobject.class);
		EmployeeCertification__c newRecord = (EmployeeCertification__c) newSObject;
		System.assertEquals(System.today(),newRecord.LastPrintedDate__c);

	}
	/**
    *————————————————————————————————————————————————————
    * @Name: testvalidateCertification
    * @Description
    * test method to test GetEmpCertificationsMethod
    *————————————————————————————————————————————————————
    **/
    public static testMethod void testvalidateCertification() {
    	Test.startTest();
       // buildTestData();

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
            FirstName           ='Amy', 
            Personnel_Number__c = 1234567,
            Employment_Status__c = 'Active',
            Email               = 'test.test@amtrak.com',
            Department = 'Transportation',
            Craft__c = 'System'
        );
        insert employee; 

        OccupationCertification__c occCert  =  new OccupationCertification__c();
        occCert.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert.Name = 'Occupation Certification 1';
        occCert.LengthOfPeriod__c = 1;
        occCert.Frequency__c = 'Months';
        occCert.CertificationType__c = 'Student Engineer';
        //occCert.NumberOfTestsPerPeriod__c = 2;
        occCert.Status__c = RevSys_StaticUtility.ACTIVE;
        insert occCert;

        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 4';
        occReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occReqObj.SourceRecordType__c = 'Medical, Hearing and Vision';
        occReqObj.Source__c = 'Employee Result Summary';
        occReqObj.SourceTestType__c = 'Vision Test';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        insert occReqObj;

        OccupationSpecificRequirement__c occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqObj.id;
        occSpecReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=5;
        occSpecReqObj.Frequency__c='Months';
        insert occSpecReqObj;

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = 'Pending';
        empCertObj.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        insert empCertObj;

        empCertObj.Status__c = 'Current';
        empCertObj.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        update empCertObj;

        EmployeeCertification__c temEmpCertObj = [Select id,RecordTypeId,Certification__c,Employee__c,Status__c,ExpirationDate__c,(Select id from Employee_Specific_Requirements__r) from EmployeeCertification__c where Id=:empCertObj.Id];
        List<EmployeeSpecificRequirement__c> ecListToUpdate = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : temEmpCertObj.Employee_Specific_Requirements__r) {
            esr.LastFulfilledDate__c = System.today();
            esr.ReportStatus__c = 'Pass';
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

    	EmployeeCertification__c myECListToValidate =  [Select Id,Employee__c,Certification__c,RecordTypeId,
                                                    ExpirationDate__c,LastCertificationDate__c,Status__c,ProcessFlag__c 
                                                    from EmployeeCertification__c where Id=:empCertObj.Id];

		Map<String,String> requestParams = new Map<String,String>();
		requestParams.put('empCertRecord',JSON.serialize(myECListToValidate));
        Map<String,String> response = RevSys_EmpCert_RecordDetailController.validateCertification(requestParams);
       	System.assertEquals(System.Label.RevSys_EmpCert_Certify_Success,response.get('successMsg'));
       	

        ecListToUpdate = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : temEmpCertObj.Employee_Specific_Requirements__r) {
            esr.LastFulfilledDate__c = System.today();
            esr.ReportStatus__c = 'Fail';
            ecListToUpdate.add(esr);
        }
        update ecListToUpdate;

        myECListToValidate =  [Select Id,Employee__c,Certification__c,RecordTypeId,
                                                    ExpirationDate__c,LastCertificationDate__c,Status__c,ProcessFlag__c 
                                                    from EmployeeCertification__c where Id=:empCertObj.Id];
		requestParams.put('empCertRecord',JSON.serialize(myECListToValidate));
        response = RevSys_EmpCert_RecordDetailController.validateCertification(requestParams);

        Test.stopTest();
	}


    /**
    *————————————————————————————————————————————————————
    * @Name: testgetLatestCertificationRecord
    * @Description
    * 
    *————————————————————————————————————————————————————
    **/
    public static testMethod void testgetLatestCertificationRecord() {
        buildTestData();
        EmployeeCertification__c ecListToUpdate =  [Select Id,Employee__c,Certification__c,RecordTypeId,
                                                    ExpirationDate__c,LastCertificationDate__c,Status__c,ProcessFlag__c 
                                                    from EmployeeCertification__c Limit 1];
        ecListToUpdate.CertificationNumber__c = 'AMT-1234';
        update ecListToUpdate;

        EmployeeCertification__c ec = ecListToUpdate.clone();
        ec.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        insert ec;

        EmployeeCertification__c validatedEC =  RevSys_EmpCert_RecordDetailController.getLatestCertificationRecord('AMT-1234');

    }


    /**
    *————————————————————————————————————————————————————
    * @Name: testLastRideTaken
    * @Description
    * test method to test GetEmpCertificationsMethod
    *————————————————————————————————————————————————————
    **/
    public static testMethod void testLastRideTaken() {
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
            FirstName           ='Amy', 
            Personnel_Number__c = 1234567,
            Employment_Status__c = 'Active',
            Email               = 'test.test@amtrak.com',
            Department = 'Transportation',
            Craft__c = 'System'
        );
        insert employee; 

        OccupationCertification__c occCert  =  new OccupationCertification__c();
        occCert.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert.Name = 'Occupation Certification 1';
        occCert.LengthOfPeriod__c = 1;
        occCert.Frequency__c = 'Months';
        occCert.CertificationType__c = 'Student Engineer';
        //occCert.NumberOfTestsPerPeriod__c = 2;
        occCert.Status__c = RevSys_StaticUtility.ACTIVE;
        insert occCert;

        List<OccupationRequirement__c> occReqList = new List<OccupationRequirement__c>();       
        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 1';
        occReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occReqObj.SourceRecordType__c = 'Form-1875';
        occReqObj.Source__c = 'Observation';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqList.add(occReqObj);

        occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 2';
        occReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occReqObj.SourceRecordType__c = 'Form-1876';
        occReqObj.Source__c = 'Observation';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqList.add(occReqObj);

        occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 3';
        occReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occReqObj.SourceRecordType__c = 'Form-1877';
        occReqObj.Source__c = 'Observation';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqList.add(occReqObj);

        occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 4';
        occReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occReqObj.SourceRecordType__c = 'Medical, Hearing and Vision';
        occReqObj.Source__c = 'Employee Result Summary';
        occReqObj.SourceTestType__c = 'Vision Test';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqList.add(occReqObj);
        
        insert occReqList;

        List<OccupationSpecificRequirement__c> occSpecReqList = new List<OccupationSpecificRequirement__c>();  

        OccupationSpecificRequirement__c occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqList[0].id;
        occSpecReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c='Months';
        occSpecReqList.add(occSpecReqObj);

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqList[1].id;
        occSpecReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=5;
        occSpecReqObj.Frequency__c='Months';
        occSpecReqList.add(occSpecReqObj);

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqList[2].id;
        occSpecReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=5;
        occSpecReqObj.Frequency__c='Months';
        occSpecReqList.add(occSpecReqObj);

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqList[3].id;
        occSpecReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=5;
        occSpecReqObj.Frequency__c='Months';
        occSpecReqList.add(occSpecReqObj);
        insert occSpecReqList;


        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = 'Pending';
        empCertObj.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        insert empCertObj;

        empCertObj.Status__c = 'Current';
        empCertObj.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        update empCertObj;

        List<EmployeeSpecificRequirement__c> ecListToUpdate = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : [Select Id,LastFulfilledDate__c from EmployeeSpecificRequirement__c where EmployeeCertification__c=:empCertObj.Id]) {
            esr.LastFulfilledDate__c = System.today();
            esr.Restrictions__c = 'Corrective Lenses';
            ecListToUpdate.add(esr);
        }
        update ecListToUpdate;

       // EmployeeCertification__c ecRecord = [Select Id,Status__c,LastPrintedDate__c,LastPrintedBy__c from EmployeeCertification__c Limit 1];
        //System.assertEquals(null,ecRecord.LastPrintedBy__c);
        Map<String,String> response = RevSys_EmpCert_RecordDetailController.saveLastPrintedDetails(empCertObj.Id);
        RevSys_EmpCert_RecordDetailController.doFailFlag = true;
        response = RevSys_EmpCert_RecordDetailController.saveLastPrintedDetails(empCertObj.Id);
        //System.assertEquals(null,response.get('errorMsg'));
        //sObject newSObject = (Sobject) Json.deserialize(response.get('empCert'),Sobject.class);
        //EmployeeCertification__c newRecord = (EmployeeCertification__c) newSObject;
        //System.assertEquals(System.today(),newRecord.LastPrintedDate__c);

    }

    /**
    *————————————————————————————————————————————————————
    * @Name: testLastRideTaken
    * @Description
    * test method to test GetEmpCertificationsMethod
    *————————————————————————————————————————————————————
    **/
    public static testMethod void testLastRideTaken2() {
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
            FirstName           ='Amy', 
            Personnel_Number__c = 1234567,
            Employment_Status__c = 'Active',
            Email               = 'test.test@amtrak.com',
            Department = 'Transportation',
            Craft__c = 'System'
        );
        insert employee; 

        OccupationCertification__c occCert  =  new OccupationCertification__c();
        occCert.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert.Name = 'Occupation Certification 1';
        occCert.LengthOfPeriod__c = 1;
        occCert.Frequency__c = 'Months';
        occCert.CertificationType__c = 'Engineer';
        //occCert.NumberOfTestsPerPeriod__c = 2;
        occCert.Status__c = RevSys_StaticUtility.ACTIVE;
        insert occCert;

        List<OccupationRequirement__c> occReqList = new List<OccupationRequirement__c>();       
        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 1';
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

        empCertObj.Status__c = 'Current';
        empCertObj.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        update empCertObj;

        List<EmployeeSpecificRequirement__c> ecListToUpdate = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : [Select Id,LastFulfilledDate__c from EmployeeSpecificRequirement__c where EmployeeCertification__c=:empCertObj.Id]) {
            esr.LastFulfilledDate__c = System.today();
            esr.Restrictions__c = 'Corrective Lenses';
            ecListToUpdate.add(esr);
        }
        update ecListToUpdate;

        Map<String,String> response = RevSys_EmpCert_RecordDetailController.saveLastPrintedDetails(empCertObj.Id);
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: testLastRideTaken
    * @Description
    * test method to test GetEmpCertificationsMethod
    *————————————————————————————————————————————————————
    **/
    public static testMethod void testLastRideTaken3() {
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
            FirstName           ='Amy', 
            Personnel_Number__c = 1234567,
            Employment_Status__c = 'Active',
            Email               = 'test.test@amtrak.com',
            Department = 'Transportation',
            Craft__c = 'System'
        );
        insert employee; 

        OccupationCertification__c occCert  =  new OccupationCertification__c();
        occCert.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert.Name = 'Occupation Certification 1';
        occCert.LengthOfPeriod__c = 1;
        occCert.Frequency__c = 'Months';
        occCert.CertificationType__c = 'Conductor';
        //occCert.NumberOfTestsPerPeriod__c = 2;
        occCert.Status__c = RevSys_StaticUtility.ACTIVE;
        insert occCert;

        List<OccupationRequirement__c> occReqList = new List<OccupationRequirement__c>();       
        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 1';
        occReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occReqObj.SourceRecordType__c = 'Form-1877';
        occReqObj.Source__c = 'Observation';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqList.add(occReqObj);

        occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 2';
        occReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occReqObj.SourceRecordType__c = 'Medical, Hearing and Vision';
        occReqObj.Source__c = 'Employee Result Summary';
        occReqObj.SourceTestType__c = 'Hearing Test';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqList.add(occReqObj);

        insert occReqList;

        OccupationSpecificRequirement__c occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqList[0].id;
        occSpecReqObj.Status__c = RevSys_StaticUtility.ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c='Months';
        insert occSpecReqObj;

        OccupationSpecificRequirement__c occSpecReqObj2 = new OccupationSpecificRequirement__c();
        occSpecReqObj2.Certification__c = occCert.id;
        occSpecReqObj2.Requirement__c = occReqList[1].id;
        occSpecReqObj2.Status__c = RevSys_StaticUtility.ACTIVE;
        occSpecReqObj2.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj2.LengthOfPeriod__c=1;
        occSpecReqObj2.Frequency__c='Months';
        insert occSpecReqObj2;

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employee.id;
        empCertObj.Status__c = 'Pending';
        empCertObj.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        insert empCertObj;

        empCertObj.Status__c = 'Current';
        empCertObj.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        update empCertObj;

        List<EmployeeSpecificRequirement__c> ecListToUpdate = new List<EmployeeSpecificRequirement__c>();
        for(EmployeeSpecificRequirement__c esr : [Select Id,LastFulfilledDate__c from EmployeeSpecificRequirement__c where EmployeeCertification__c=:empCertObj.Id]) {
            esr.LastFulfilledDate__c = System.today();
            esr.Restrictions__c = 'Corrective Lenses';
            ecListToUpdate.add(esr);
        }
        update ecListToUpdate;
        
        Map<String,String> response = RevSys_EmpCert_RecordDetailController.saveLastPrintedDetails(empCertObj.Id);
    }
}