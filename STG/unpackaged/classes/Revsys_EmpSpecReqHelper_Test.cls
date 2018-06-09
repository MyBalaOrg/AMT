/**
*___________________________________________________
*@Name:     Revsys_EmpSpecReqHelper_Test
*@Author:   Chuck Walley
*@Created:  Date: March 28, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for Revsys_HierarchyAssignmentHelper
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class Revsys_EmpSpecReqHelper_Test { 
    private static final String PENDING  = 'Pending';
    private static final String ACTIVE  = 'Active';
    private static final String DAYS  = 'Days';
   
    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {

        SPARTN_BypassRuleSettings__c orgsettings = SPARTN_BypassRuleSettings__c.getOrgDefaults();  
        orgsettings.Processes__c = true; 
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

        RevSys_TestDataHelper.buildCertificationData(); 

    }

    private static testmethod void test_determineRecord_Insert_0()
    {
        // GEt the Employee Specific Requirement 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_EMPLOYEE_SPECIFIC_REQUIREMENT);   
        String myQuery = myQuWrap.QueryString; 
        List<EmployeeSpecificRequirement__c> myEsrList = Database.query(myQuery); 

        EmployeeSpecificRequirement__c myEsr = myEsrList[0];

        myEsr.LastFulfilledDate__c = system.today();
        myEsr.ReportStatus__c = 'Pass'; 

        update myEsr; 

        // GEt the Employee Specific Requirement 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_EMPLOYEE_CERTIFICATION);   
        myQuery = myQuWrap.QueryString; 
        List<EmployeeCertification__c> myEcList = Database.query(myQuery); 

        EmployeeCertification__c myEc = myEcList[0];

        system.assert(true,myEc.IsReadyToCertify__c); 
        
    }

    private static testmethod void testUpdateReportFields() {
        Test.startTest();

        OccupationCertification__c occCert  =  new OccupationCertification__c();
        occCert.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert.Name = 'New Test Class Req';
        occCert.LengthOfPeriod__c = 8;
        occCert.NumberOfTestsPerPeriod__c = 2;
        occCert.Status__c = 'Active';
        
        insert occCert;

        List<OccupationRequirement__c> orList = new List<OccupationRequirement__c>();

        OccupationRequirement__c newOR = new OccupationRequirement__c();
        newOR.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR.Name =  'Test Requirement 1';
        newOR.Source__c = 'Employee Result Summary';
        newOR.SourceRecordType__c = 'Motor Vehicle Review';
        newOR.SourceTestType__c = Label.RevSys_Generic_State_Review;
        orList.add(newOR);

        OccupationRequirement__c newOR2 = new OccupationRequirement__c();
        newOR2.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR2.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR2.Name =  'Test Requirement 2';
        newOR2.Source__c = 'Employee Result Summary';
        newOR2.SourceRecordType__c = 'Motor Vehicle Review';
        newOR2.SourceTestType__c = Label.RevSys_Generic_National_Review;
        orList.add(newOR2);

        OccupationRequirement__c newOR3 = new OccupationRequirement__c();
        newOR3.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR3.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR3.Name =  'Test Requirement 3';
        newOR3.Source__c = RevSys_StaticUtility.OBSERVATION ;
        newOR3.SourceRecordType__c = Label.RevSys_Generic_Form1875_SourceRecordType;
        //newOR2.SourceTestType__c = Label.RevSys_Generic_National_Review;
        orList.add(newOR3);

        OccupationRequirement__c newOR4 = new OccupationRequirement__c();
        newOR4.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR4.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR4.Name =  'Test Requirement 4';
        newOR4.Source__c = Label.RevSys_ESR_Source_Emp_Result_Summary;
        newOR4.SourceRecordType__c = Label.RevSys_ESR_Medical_Hearing_and_Vision;
        newOR4.SourceTestType__c = Label.RevSys_Generic_Vision_Test;
        orList.add(newOR4);

        OccupationRequirement__c newOR5 = new OccupationRequirement__c();
        newOR5.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR5.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR5.Name =  'Test Requirement 5';
        newOR5.Source__c = Label.RevSys_ESR_Source_Emp_Result_Summary;
        newOR5.SourceRecordType__c = Label.RevSys_ESR_Medical_Hearing_and_Vision;
        newOR5.SourceTestType__c = Label.RevSys_Generic_Medical_Examination;
        orList.add(newOR5);

        OccupationRequirement__c newOR6 = new OccupationRequirement__c();
        newOR6.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR6.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR6.Name =  'Test Requirement 6';
        newOR6.Source__c = Label.RevSys_ESR_Source_Emp_Result_Summary;
        newOR6.SourceRecordType__c = Label.RevSys_ESR_Medical_Hearing_and_Vision;
        newOR6.SourceTestType__c = Label.RevSys_Generic_Hearing_Test;
        orList.add(newOR6); 


        OccupationRequirement__c newOR7 = new OccupationRequirement__c();
        newOR7.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR7.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR7.Name =  Label.RevSys_EfficiencyTest_FRA123;
        newOR7.Source__c = RevSys_StaticUtility.OBSERVATION ;
        newOR7.SourceRecordType__c = 'FORM-1872';
        //newOR2.SourceTestType__c = Label.RevSys_Generic_National_Review;
        orList.add(newOR7);

        OccupationRequirement__c newOR8 = new OccupationRequirement__c();
        newOR8.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR8.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR8.Name =  Label.RevSys_EfficiencyTest_FRA125;
        newOR8.Source__c = RevSys_StaticUtility.OBSERVATION ;
        newOR8.SourceRecordType__c = 'FORM-1872';
        //newOR2.SourceTestType__c = Label.RevSys_Generic_National_Review;
        orList.add(newOR8);

        OccupationRequirement__c newOR10 = new OccupationRequirement__c();
        newOR10.Status__c =  RevSys_StaticUtility.ACTIVE;
        newOR10.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        newOR10.Name =  Label.RevSys_EfficiencyTest_FRA303;
        newOR10.Source__c = RevSys_StaticUtility.OBSERVATION ;
        newOR10.SourceRecordType__c = 'FORM-1872';
        //newOR2.SourceTestType__c = Label.RevSys_Generic_National_Review;
        orList.add(newOR10);

        insert orList;


        List<OccupationSpecificRequirement__c> occSpecReqList = new List<OccupationSpecificRequirement__c>();       
        OccupationSpecificRequirement__c occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = orList[0].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c=DAYS;
        occSpecReqList.add(occSpecReqObj);

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = orList[1].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c=DAYS;
        occSpecReqList.add(occSpecReqObj);

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = orList[2].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c=DAYS;
        occSpecReqList.add(occSpecReqObj);

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = orList[3].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c=DAYS;
        occSpecReqList.add(occSpecReqObj);       

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = orList[4].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c=DAYS;
        occSpecReqList.add(occSpecReqObj);

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = orList[5].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c=DAYS;
        occSpecReqList.add(occSpecReqObj);

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = orList[6].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c=DAYS;
        occSpecReqList.add(occSpecReqObj);

        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = orList[7].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c=DAYS;
        occSpecReqList.add(occSpecReqObj);


        occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = orList[8].id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=1;
        occSpecReqObj.Frequency__c=DAYS;
        occSpecReqList.add(occSpecReqObj);


        insert occSpecReqList;

          Contact employeeA2 = new Contact
            (
                LastName            ='Employee', 
                FirstName           ='new', 
                Personnel_Number__c = 188291,
                Employment_Status__c = 'Active',
                Department          ='Transportation',
                Email               = 'new@new.com'
            );
            insert employeeA2;

        EmployeeCertification__c empCertObj = new EmployeeCertification__c();
        empCertObj.RecordTypeId =  RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        empCertObj.Certification__c = occCert.id;
        empCertObj.Employee__c = employeeA2.id;
        empCertObj.Status__c = 'Pending';
        insert empCertObj;

        List<EmployeeSpecificRequirement__c> newEsrList = new List<EmployeeSpecificRequirement__c>();
        List<EmployeeSpecificRequirement__c> esrList = [Select Id from EmployeeSpecificRequirement__c where EmployeeCertification__c=:empCertObj.Id];
        for(EmployeeSpecificRequirement__c esr : esrList) {
            esr.LastFulfilledDate__c = System.today();
            esr.ReportStatus__c = 'Pass';
            newEsrList.add(esr);
        }

        update newEsrList;
        EmployeeCertification__c ec = [Select Id,EfficiencyTestFRA303__c from EmployeeCertification__c where Id=:empCertObj.Id];
        //System.assertEquals(ec.EfficiencyTestFRA303__c,System.today());
    }
}