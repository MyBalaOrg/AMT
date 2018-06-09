/**
*___________________________________________________
*@Name: 	RevSys_EmployeeResultSummary_Test
*@Author: 	Raj Kumar Pandy
*@Created: 	Date: 12/11/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Test for RevSys_EmployeeResultSummaryHelper
* 
*___________________________________________________
*@Changes: 
*05-21-2018 ETR-1211; ETR-1259: Utilize specific values for Failed Vision and Failed Hearing Tests, 
*                               instead of "Failed Test."
**/
@isTest
public class RevSys_EmployeeResultSummary_Test {
    
    private static final String ACTIVE  = 'Active';
    
    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {

        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();
        setting.Name = 'Valid Employee Department';
        setting.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';
        insert setting;

        List<Contact> conList = new List<Contact>();

        Contact employee = new Contact();
        employee.LastName			='Employee';
        employee.FirstName			='Amy';
        employee.Craft__c = 'Conductor';
        employee.Personnel_Number__c = 1234567;
        employee.Email 				= 'test.test@amtrak.com';
        employee.ClassOfService__c   = 'Train Service Engineer';       
        conList.add(employee);

        
        
        Contact employee2 = new Contact();
        employee2.LastName			='Employee_2';
        employee2.FirstName			='Jamie';
        employee2.Personnel_Number__c = 12345;
        employee.Craft__c = 'Conductor';
        employee2.Email 				= 'test.test2@amtrak.com';
        employee2.ClassOfService__c   = 'Conductor';       
        conList.add(employee2);
        
        insert conList; 


        EPW_Organization__c Org2 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_SPARTN_RECTYPE_ID, 
            Name = 'Spartn', 
            EPW_Organization_Number__c = '2',
            EPW_Status__c = 'Active'
        );
        insert Org2;

        EPW_Position_Hierarchy__c myPoHi1 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
            EPW_Position_Organization__c = Org2.Id,
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert myPoHi1;

        EPW_Hierarchy_Assignment__c myHiAsgn1 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = conList[1].Id,
            EPW_Position_Hierarchy__c = myPoHi1.Id,
            EPW_Status__c = 'Active'
        );
        insert myHiAsgn1;

        EPW_Position_Hierarchy__c myPoHi2 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
            EPW_Position_Organization__c = Org2.Id,
            EPW_Parent_Position_Hierarchy__c = myPoHi1.Id,
            Name = 'Leve2 Employee A',
            EPW_Position_ID__c =  '1000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert myPoHi2;

        EPW_Hierarchy_Assignment__c myHiAsgn2 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = conList[0].Id,
            EPW_Position_Hierarchy__c = myPoHi2.Id,
            EPW_Status__c = 'Active'
        );
        insert myHiAsgn2;

        
        OccupationRequirement__c occReqSourceObj = new OccupationRequirement__c();
        occReqSourceObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID;
        occReqSourceObj.Name = 'Occ Req Source';
        occReqSourceObj.Status__c = ACTIVE;
        occReqSourceObj.TestNumber__c = '12345';
        occReqSourceObj.TestName__c = 'Test Source';
        insert occReqSourceObj;
        
        List<OccupationRequirement__c> occReqList = new List<OccupationRequirement__c>();
        
        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.RecordTypeId = RevSYs_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqObj.Status__c = ACTIVE;
        occReqObj.Source__c = 'Observation';
        occReqObj.SourceRecordType__c = 'FORM-1872';
        occReqObj.SourceTestNumber__c = occReqSourceObj.Id;
        occReqObj.TestName__c = 'TestName';
        occReqObj.TestNumber__c = '101';
        occReqList.add(occReqObj);
        
        occReqObj = new OccupationRequirement__c();
        occReqObj.RecordTypeId = RevSYs_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqObj.Status__c = ACTIVE;
        occReqObj.Source__c = 'Employee Result Summary';
        occReqObj.SourceRecordType__c = 'Employment History';
        occReqObj.SourceTestNumber__c = occReqSourceObj.Id;
        occReqList.add(occReqObj);
        
        occReqObj = new OccupationRequirement__c();
        occReqObj.RecordTypeId = RevSYs_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqObj.Status__c = ACTIVE;
        occReqObj.Source__c = 'Employee Result Summary';
        occReqObj.SourceRecordType__c = 'Motor Vehicle Review';
        occReqObj.SourceTestType__c = 'State Review';
        occReqObj.SourceTestNumber__c = occReqSourceObj.Id;
        occReqList.add(occReqObj);
        
        occReqObj = new OccupationRequirement__c();
        occReqObj.RecordTypeId = RevSYs_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqObj.Status__c = ACTIVE;
        occReqObj.Source__c = 'Employee Result Summary';
        occReqObj.SourceRecordType__c = 'Motor Vehicle Review';
        occReqObj.SourceTestType__c = 'National Review';
        occReqObj.SourceTestNumber__c = occReqSourceObj.Id;
        occReqList.add(occReqObj);
        
        occReqObj = new OccupationRequirement__c();
        occReqObj.RecordTypeId = RevSYs_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqObj.Status__c = ACTIVE;
        occReqObj.Source__c = 'Observation';
        occReqObj.SourceRecordType__c = 'FORM-1877';
        occReqObj.SourceTestNumber__c = occReqSourceObj.Id;
        occReqList.add(occReqObj);
        
        occReqObj = new OccupationRequirement__c();
        occReqObj.RecordTypeId = RevSYs_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqObj.Status__c = ACTIVE;
        occReqObj.Source__c = 'Employee Result Summary';
        occReqObj.SourceRecordType__c = 'Medical, Hearing and Vision';
        occReqObj.SourceTestType__c = 'Hearing Test';
        occReqList.add(occReqObj);
        
        occReqObj = new OccupationRequirement__c();
        occReqObj.RecordTypeId = RevSYs_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqObj.Status__c = ACTIVE;
        occReqObj.Source__c = 'Employee Result Summary';
        occReqObj.SourceRecordType__c = 'Medical, Hearing and Vision';
        occReqObj.SourceTestType__c = 'Vision Test';
        occReqList.add(occReqObj);
        
        occReqObj = new OccupationRequirement__c();
        occReqObj.RecordTypeId = RevSYs_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqObj.Status__c = ACTIVE;
        occReqObj.Source__c = 'Employee Result Summary';
        occReqObj.SourceRecordType__c = 'Medical, Hearing and Vision';
        occReqObj.SourceTestType__c = 'Medical Examination';
        occReqList.add(occReqObj);
        
        occReqObj = new OccupationRequirement__c();
        occReqObj.RecordTypeId = RevSYs_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID;
        occReqObj.Status__c = ACTIVE;
        occReqObj.TestNumber__c = '101';
        occReqObj.Source__c = 'Observation';
        occReqObj.SourceRecordType__c = 'FORM-1872';
        occReqList.add(occReqObj);
        
        insert occReqList;
        
        List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();
        OccupationCertification__c occCertObj = new OccupationCertification__c();
        occCertObj.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        OccCertObj.Name = 'Occupation Cert';
        OccCertObj.Status__c = ACTIVE;
        OccCertObj.Frequency__c = 'Days';
        OccCertObj.LengthOfPeriod__c = 2;
        occCertList.add(occCertObj);
        
        occCertObj = new OccupationCertification__c();
        occCertObj.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
        OccCertObj.Name = 'Occupation Cer 1';
        OccCertObj.Status__c = ACTIVE;
        OccCertObj.Frequency__c = 'Months';
        OccCertObj.StartDate__c = Date.today();
        OccCertObj.TargetType__c = 'Occupation';
        OccCertObj.Department__c = 'Mechanical';
        OccCertObj.Craft__c = 'Conductor';
        OccCertObj.NumberOfTestsPerPeriod__c = 2;
        OccCertObj.LengthOfPeriod__c = 2;
        occCertList.add(occCertObj);
        insert occCertList;
        
        List<OccupationSpecificRequirement__c> occSpecReqList = new List<OccupationSpecificRequirement__c>();
        OccupationSpecificRequirement__c OccSpecReqObj = new OccupationSpecificRequirement__c();
        OccSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        OccSpecReqObj.Certification__c = occCertList[0].Id;
        OccSpecReqObj.Frequency__c = 'Days';
        OccSpecReqObj.Requirement__c = occReqList[3].id;
        OccSpecReqObj.Status__c = ACTIVE;
        OccSpecReqObj.LengthOfPeriod__c = 2;
        occSpecReqList.add(OccSpecReqObj);
        
        OccSpecReqObj = new OccupationSpecificRequirement__c();
        OccSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        OccSpecReqObj.Certification__c = occCertList[0].Id;
        OccSpecReqObj.Frequency__c = 'Days';
        OccSpecReqObj.Requirement__c = occReqList[1].id;
        OccSpecReqObj.Status__c = ACTIVE;
        OccSpecReqObj.LengthOfPeriod__c = 2;
        occSpecReqList.add(OccSpecReqObj);
        
        OccSpecReqObj = new OccupationSpecificRequirement__c();
        OccSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        OccSpecReqObj.Certification__c = occCertList[0].Id;
        OccSpecReqObj.Frequency__c = 'Days';
        OccSpecReqObj.Requirement__c = occReqList[5].id;
        OccSpecReqObj.Status__c = ACTIVE;
        OccSpecReqObj.LengthOfPeriod__c = 2;
        occSpecReqList.add(OccSpecReqObj);
        
        OccSpecReqObj = new OccupationSpecificRequirement__c();
        OccSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        OccSpecReqObj.Certification__c = occCertList[0].Id;
        OccSpecReqObj.Frequency__c = 'Days';
        OccSpecReqObj.Requirement__c = occReqList[6].id;
        OccSpecReqObj.Status__c = ACTIVE;
        OccSpecReqObj.LengthOfPeriod__c = 2;
        occSpecReqList.add(OccSpecReqObj);
        
        OccSpecReqObj = new OccupationSpecificRequirement__c();
        OccSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        OccSpecReqObj.Certification__c = occCertList[0].Id;
        OccSpecReqObj.Frequency__c = 'Days';
        OccSpecReqObj.Requirement__c = occReqList[7].id;
        OccSpecReqObj.Status__c = ACTIVE;
        OccSpecReqObj.LengthOfPeriod__c = 2;
        occSpecReqList.add(OccSpecReqObj);
        
        OccSpecReqObj = new OccupationSpecificRequirement__c();
        OccSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID;
        OccSpecReqObj.ObservationDepartment2__c = 'Mechanical';
        OccSpecReqObj.Status__c = ACTIVE;
        OccSpecReqObj.ObservationCraft2__c = 'Conductor';
        OccSpecReqObj.Observation__c = occReqList[8].id;
        occSpecReqList.add(OccSpecReqObj);
        
        OccSpecReqObj = new OccupationSpecificRequirement__c();
        OccSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        OccSpecReqObj.Certification__c = occCertList[0].Id;
        OccSpecReqObj.Frequency__c = 'Days';
        OccSpecReqObj.Requirement__c = occReqList[4].id;
        OccSpecReqObj.Status__c = ACTIVE;
        OccSpecReqObj.LengthOfPeriod__c = 2;
        occSpecReqList.add(OccSpecReqObj);
        
        insert occSpecReqList;
        
        
        List<EmployeeSpecificRequirement__c> esrList = new List<EmployeeSpecificRequirement__c>();
        EmployeeSpecificRequirement__c esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.Status__c = ACTIVE;
        esrObj.Requirement__c = occReqList[0].id;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.Status__c = ACTIVE;
        esrObj.Requirement__c = occReqList[1].id;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.Status__c = ACTIVE;
        esrObj.Requirement__c = occReqList[2].id;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.Status__c = ACTIVE;
        esrObj.Requirement__c = occReqList[3].id;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.Status__c = ACTIVE;
        esrObj.Requirement__c = occReqList[4].id;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.Status__c = ACTIVE;
        esrObj.Requirement__c = occReqList[5].id;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        esrObj.Certification__c = OccCertList[0].id;
        esrObj.Requirement__c = occReqList[3].id;
        esrObj.OccupationSpecificRequirement__c = occSpecReqList[0].id;
        esrObj.Status__c = ACTIVE;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        esrObj.Certification__c = OccCertList[0].id;
        esrObj.Requirement__c = occReqList[1].id;
        esrObj.OccupationSpecificRequirement__c = occSpecReqList[1].id;
        esrObj.Status__c = ACTIVE;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        esrObj.Certification__c = OccCertList[0].id;
        esrObj.Requirement__c = occReqList[5].id;
        esrObj.OccupationSpecificRequirement__c = occSpecReqList[2].id;
        esrObj.Status__c = ACTIVE;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        esrObj.Certification__c = OccCertList[0].id;
        esrObj.Requirement__c = occReqList[6].id;
        esrObj.OccupationSpecificRequirement__c = occSpecReqList[3].id;
        esrObj.Status__c = ACTIVE;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        esrObj.Certification__c = OccCertList[0].id;
        esrObj.Requirement__c = occReqList[7].id;
        esrObj.OccupationSpecificRequirement__c = occSpecReqList[4].id;
        esrObj.Status__c = ACTIVE;
        esrList.add(esrObj);
        
        esrObj = new EmployeeSpecificRequirement__c();
        esrObj.Employee__c = employee.id;
        esrObj.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        esrObj.Certification__c = OccCertList[0].id;
        esrObj.Requirement__c = occReqList[4].id;
        esrObj.OccupationSpecificRequirement__c = occSpecReqList[6].id;
        esrObj.Status__c = ACTIVE;
        esrList.add(esrObj);
                
        insert esrList;
        
        Observation__c obsObj = new Observation__c();
        obsObj.RecordTypeId = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID;
        obsObj.Employee__c = employee.id;
        obsObj.TestNumber__c = '12345';
        obsObj.NonComplianceRuleNumber__c = '1';
        obsObj.SupervisorsCommentSelection__c = 'Details';
        obsObj.Comments__c = 'None';
        obsObj.Status__c = 'Submitted';
        obsObj.OccupationSpecificRequirement__c = occSpecReqList[5].id;
        obsObj.Result__c = '1 = Failure, verbal counseling';
        insert obsObj;
        
        List<EmployeeResultSummary__c> ersList = new List<EmployeeResultSummary__c>();
        EmployeeResultSummary__c ersObj = new EmployeeResultSummary__c();
        ersObj.RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_TEST1872_RECTYPE_ID;
        ersObj.Employee__c = employee.id;
        ersObj.EvaluationDate__c = Date.today();
        ersObj.Observation__c = obsObj.Id;
        ersList.add(ersObj);
        
        ersObj = new EmployeeResultSummary__c();
        ersObj.RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_EMPHISTORY_RECTYPE_ID;
        ersObj.Employee__c = employee.id;
        ersObj.Result__c = 'C = Compliance';
        ersObj.EvaluationDate__c = Date.today();       
        ersList.add(ersObj);
        
        ersObj = new EmployeeResultSummary__c();
        ersObj.RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID;
        ersObj.Employee__c = employee.id;
        ersObj.NdrReviewDate__c = Date.today();
        ersObj.StateReviewDate__c = Date.today();
        ersObj.EapEvaluationDate__c = Date.today();
        ersObj.Result__c = 'C = Complaince';
        ersObj.AlcoholOrDrugViolationRevealed__c = true;
        ersObj.EapCounselor__c = conList[1].id;
        ersObj.LicenseNumber__c = '122';
        ersObj.LicenseType__c = 'U.S. Driver\'s License';
        ersObj.State__c = 'AK';
        esrObj.Status__c = 'Pass';
        ersObj.ConvictionDate__c = Date.today();
        ersObj.ViolationDescription__c = 'test description';
        ersList.add(ersObj);
        
        ersObj = new EmployeeResultSummary__c();
        ersObj.RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID;
        ersObj.Employee__c = employee2.id;
        ersObj.StateReviewDate__c = Date.today();
        ersObj.NdrReviewDate__c = Date.today();
        ersObj.EapEvaluationDate__c = Date.today();
        ersObj.Result__c = 'C = Complaince';
        ersObj.AlcoholOrDrugViolationRevealed__c = true;
        ersObj.EapCounselor__c = conList[1].id;
        ersObj.LicenseNumber__c = '122';
        ersObj.LicenseType__c = 'U.S. Driver\'s License';
        ersObj.State__c = 'AK';
        esrObj.Status__c = 'Pass';
        ersObj.ConvictionDate__c = Date.today();
        ersObj.ViolationDescription__c = 'test description';
          ersObj.Status__c = 'Pending';
        ersObj.CanEmployeeBeCertified__c = 'Yes';
        ersList.add(ersObj);
        
        ersObj = new EmployeeResultSummary__c();
        ersObj.RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_TEST1877_RECTYPE_ID;
        ersObj.Employee__c = employee.id;
        ersObj.EvaluationDate__c = Date.today();
          ersObj.Status__c = 'Pending';
        ersObj.CanEmployeeBeCertified__c = 'Yes';
        ersList.add(ersObj);
        
        ersObj = new EmployeeResultSummary__c();
        ersObj.RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID;
        ersObj.Employee__c = employee.id;
        ersObj.EvaluationDate__c = Date.today();
        ersObj.Type__c = 'Vision Test';
        ersObj.Result__c = 'Restrictions - Vision';
		ersObj.RestrictionType__c = 'Corrective Lenses - Reading';
        ersObj.FieldTestAdministered__c = 'No';
        ersObj.FieldTestDate__c = Date.today();
        ersObj.CanEmployeeBeCertified__c= 'Yes';
        ersObj.Comments__c = 'This is a Medical Exam';
          ersObj.Status__c = 'Pending';
        ersList.add(ersObj);
        
        ersObj = new EmployeeResultSummary__c();
        ersObj.RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID;
        ersObj.Employee__c = employee.id;
        ersObj.EvaluationDate__c = Date.today();
        ersObj.Type__c = 'Medical Examination';
        ersObj.Result__c = 'Pending return of exam results';
        ersObj.CanEmployeeBeCertified__c = 'Yes';
        ersObj.Comments__c = 'This is a Medical Exam';
          ersObj.Status__c = 'Pending';
        ersList.add(ersObj);
        
        ersObj = new EmployeeResultSummary__c();
        ersObj.RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID;
        ersObj.Employee__c = employee.id;
        ersObj.EvaluationDate__c = Date.today();
        ersObj.Type__c = 'Hearing Test';
        ersObj.Result__c = 'Pending return of exam results';
        ersObj.Comments__c = 'This is a Medical Exam';
        ersObj.Status__c = 'Pending';
        ersList.add(ersObj);
        
        insert ersList;
        
       
    }
    
    private static testmethod void EmployeeResultSummaryTriggerTest(){
        try{
       
       RevSys_EmpResultSummaryTriggerHandler.DoFailTest = TRUE;
              EmployeeResultSummary__c ersObj2 = new EmployeeResultSummary__c();
       
        ersObj2.RecordTypeId = RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID;
        Date todayDate = Date.today();
        ersObj2.EvaluationDate__c = todayDate.addDays(2);
        ersObj2.Type__c = 'Vision Test';
        ersObj2.Result__c = 'Restrictions - Vision';
		ersObj2.RestrictionType__c = 'Corrective Lenses - Reading';
        ersObj2.FieldTestAdministered__c = 'No';
        insert ersObj2;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('error') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
    }
    private static testmethod void processObservation1872Test()
    {
        EmployeeResultSummary__c ersObj = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_TEST1872_RECTYPE_ID LIMIT 1];
        OccupationRequirement__c occReqObj = [Select id from OccupationRequirement__c where SourceRecordType__c = 'FORM-1872' LIMIT 1];
        
        Test.startTest();
        ersObj.Result__c = 'C = Compliance';
        update ersObj;
        Test.stopTest();
        
        EmployeeSpecificRequirement__c esrObj = [Select Id, LastFulfilledDate__c from EmployeeSpecificRequirement__c where Requirement__c =: occReqObj.id LIMIT 1];
        system.assertEquals(ersObj.EvaluationDate__c, esrObj.LastFulfilledDate__c);
        
    }
    
    private static testmethod void processObservationNon1872Test()
    {
        EmployeeResultSummary__c ersObj = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_TEST1877_RECTYPE_ID LIMIT 1];
        
        Test.startTest();
        ersObj.Result__c = 'C = Compliance';
        ersObj.QualificationStatus__c = Label.RevSys_Qualified;
        update ersObj;
        Test.stopTest();
        
        EmployeeSpecificRequirement__c esrObj = [Select Id, LastFulfilledDate__c from EmployeeSpecificRequirement__c where SourceRecordType__c = 'FORM-1877' AND RecordTypeId =: Revsys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID LIMIT 1];
        system.assertEquals(ersObj.EvaluationDate__c, esrObj.LastFulfilledDate__c);
        
    }
    
    private static testmethod void empHistoryTest()
    {
        EmployeeResultSummary__c ersObj = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_EMPHISTORY_RECTYPE_ID LIMIT 1];
        OccupationRequirement__c occReqObj = [Select id from OccupationRequirement__c where SourceRecordType__c = 'Employment History' LIMIT 1];
        
        
        Test.startTest();
        ersObj.CanEmployeeBeCertified__c = 'Yes';
        update ersObj;
        Test.stopTest();
        
        EmployeeSpecificRequirement__c esrObj = [Select Id, LastFulfilledDate__c from EmployeeSpecificRequirement__c where Requirement__c =: occReqObj.id LIMIT 1];
        system.assertEquals(ersObj.EvaluationDate__c, esrObj.LastFulfilledDate__c);
        
    }
    private static testmethod void empHistoryTest_Negative()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User Us = new User(Alias = 'standt', Email='systemadministrator@test.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, EmployeeNumber = '12345678',
                           TimeZoneSidKey='America/Los_Angeles', UserName='systemadministrator@test.com');
        insert Us;
        
        Test.startTest();
        
        system.runAs(Us){
            List<Contact> conList = new List<Contact>();
            Contact employee = new Contact();
            employee.LastName			='Employee';
            employee.FirstName			='Amy';
            employee.Craft__c = 'Conductor';
            employee.Personnel_Number__c = 1234567;
            employee.Email 				= 'test.test@amtrak.com';
            employee.ClassOfService__c   = 'Train Service Engineer';       
            conList.add(employee);
            
            List<EmployeeResultSummary__c> ersList = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_EMPHISTORY_RECTYPE_ID];
            OccupationRequirement__c occReqObj = [Select id from OccupationRequirement__c where SourceRecordType__c = 'Employment History' LIMIT 1];
            List<EmployeeResultSummary__c> tempList = new List<EmployeeResultSummary__c>();
            Set<String> myUserEmployeeNumber = new Set<String>();
            
            for(EmployeeResultSummary__c ersObj : ersList)
            {
                ersObj.EvaluationDate__c = System.today();
                ersObj.CanEmployeeBeCertified__c = 'No';
                tempList.add(ersObj);
        }
        update tempList;
       
            List<EmployeeResultSummary__c> medTempList = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID];
            
            if(medTempList.size() > 0){
                if((Us.EmployeeNumber)!= null){
                    Integer tmp = Integer.valueOf(Us.EmployeeNumber);
                    myUserEmployeeNumber.add(String.valueOf(tmp));
                    system.debug('myUserEmployeeNumber' + myUserEmployeeNumber);
                }      
            }
            
      		SelectorWrapper contactwrapper = ContactSelector.getContactsBySAPId(myUserEmployeeNumber);
            if(contactwrapper!=null){
                conList = (List<Contact>)contactwrapper.SObjectList;
                
                if(conList.size()>0){
                    for(EmployeeResultSummary__c tempEsrObj : medTempList)
                    {
                        tempEsrObj.HealthServicesNurse__c = conList[0].id;
                    }
                }
            }
       
            
        }
         Test.stopTest();
        EmployeeSpecificRequirement__c esrObj = [Select Id, ReportStatus__c from EmployeeSpecificRequirement__c where RecordTypeId =: RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID AND SourceRecordType__c = 'Employment History' LIMIT 1];
		system.assertEquals(Label.RevSys_Generic_Fail, esrObj.ReportStatus__c);
        
    }
    private static testmethod void motorVehicleTest()
    {
      EmployeeResultSummary__c ersObj = [Select Id, EvaluationDate__c, NdrReviewDate__c, StateReviewDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID LIMIT 1];
        Map<Id, OccupationRequirement__c> occReqMap = new Map<Id, OccupationRequirement__c>([Select id from OccupationRequirement__c where SourceRecordType__c = 'Motor Vehicle Review']);
        
        Set<ID> occReqIds = new Set<ID>();
        occReqIds = occReqMap.keySet();
        
        Test.startTest();
        ersObj.Status__c = Label.RevSys_Generic_Pass;
        update ersObj;
        Test.stopTest();
        List<EmployeeSpecificRequirement__c> esrList = [Select Id, LastFulfilledDate__c from EmployeeSpecificRequirement__c where Requirement__c IN : occReqIds];
        system.assertEquals(ersObj.NdrReviewDate__c, esrList[0].LastFulfilledDate__c);
        //system.assertEquals(ersObj.StateReviewDate__c, esrList[1].LastFulfilledDate__c);
    }  

    private static testmethod void motorVehicle_fail()
    {
       List<EmployeeResultSummary__c> ersList = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID];
        List<EmployeeResultSummary__c> upList = new List<EmployeeResultSummary__c>();
        
        Test.startTest();
        for(EmployeeResultSummary__c ersObj : ersList)
        {
            ersObj.Result__c = Label.RevSys_Generic_Fail ;
            upList.add(ersObj);
        }
        update upList;
        Test.stopTest();
        
        //EmployeeSpecificRequirement__c esrObj = [Select Id, ReportStatus__c from EmployeeSpecificRequirement__c where SourceTestType__c =:Label.RevSys_Generic_Vision_Test LIMIT 1];
        //system.assertEquals(Label.RevSys_Generic_Fail, esrObj.ReportStatus__c);
    } 
   
    private static testmethod void medicalTest()
    {
        List<EmployeeResultSummary__c> ersList = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID];
        OccupationRequirement__c occReqObj = [Select id from OccupationRequirement__c where SourceRecordType__c = 'Medical, Hearing and Vision' LIMIT 1];
        List<EmployeeResultSummary__c> upList = new List<EmployeeResultSummary__c>();
        
        Test.startTest();
        for(EmployeeResultSummary__c ersObj : ersList)
        {
            ersObj.Result__c = Label.Revsys_Generic_Pass_with_no_restrictions;
            ersObj.RestrictionType__c = NULL;
            ersObj.FieldTestDate__c = NULL;
            upList.add(ersObj);
        }
        update upList;
        Test.stopTest();
        
        EmployeeSpecificRequirement__c esrObj = [Select Id, LastFulfilledDate__c from EmployeeSpecificRequirement__c where Requirement__c =: occReqObj.id LIMIT 1];
        system.assertEquals(upList[0].EvaluationDate__c, esrObj.LastFulfilledDate__c);
    }
    
    private static testmethod void medicalTest_DnMeet()
    {
        List<EmployeeResultSummary__c> ersList = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID];
        List<EmployeeResultSummary__c> upList = new List<EmployeeResultSummary__c>();
        
        Test.startTest();
        for(EmployeeResultSummary__c ersObj : ersList)
        {
            ersObj.Result__c = Label.RevSys_ESR_Result_DN_Meet_Medical_Standards;
            ersObj.RestrictionType__c = NULL;
            ersObj.FieldTestDate__c = NULL;
            ersObj.MedicalComments__c = 'Comments';
            upList.add(ersObj);
        }
        update upList;
        Test.stopTest();
        
        EmployeeSpecificRequirement__c esrObj = [Select Id, ReportStatus__c from EmployeeSpecificRequirement__c where SourceTestType__c =:Label.RevSys_Generic_Medical_Examination LIMIT 1];
        system.assertEquals(Label.RevSys_Generic_Fail, esrObj.ReportStatus__c);
    }
    private static testmethod void medicalTest_PendingResults()
    {
       List<EmployeeResultSummary__c> ersList = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID];
        List<EmployeeResultSummary__c> upList = new List<EmployeeResultSummary__c>();
        
        Test.startTest();
        for(EmployeeResultSummary__c ersObj : ersList)
        {
            ersObj.Result__c = Label.RevSys_ESR_Result_Pending_Return_of_Exam_Results;
            ersObj.RestrictionType__c = NULL;
            ersObj.FieldTestDate__c = NULL;
            upList.add(ersObj);
        }
        update upList;
        Test.stopTest();
        
        EmployeeSpecificRequirement__c esrObj = [Select Id, ReportStatus__c from EmployeeSpecificRequirement__c where SourceTestType__c =:Label.RevSys_Generic_Medical_Examination LIMIT 1];
        system.assertEquals(Label.RevSys_Generic_Pending, esrObj.ReportStatus__c); 
    }
    private static testmethod void medicalTest_GenericRestrictions()
    {
       List<EmployeeResultSummary__c> ersList = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID];
        List<EmployeeResultSummary__c> upList = new List<EmployeeResultSummary__c>();
        
        Test.startTest();
        for(EmployeeResultSummary__c ersObj : ersList)
        {
            ersObj.Result__c = Label.Revsys_Generic_no_restrictions;
            ersObj.RestrictionType__c = NULL;
            ersObj.FieldTestDate__c = NULL;
            upList.add(ersObj);
        }
        update upList;
        Test.stopTest();
        
        EmployeeSpecificRequirement__c esrObj = [Select Id, ReportStatus__c from EmployeeSpecificRequirement__c where SourceTestType__c =:Label.RevSys_Generic_Hearing_Test AND ReportStatus__c =: Label.RevSys_Generic_Pass LIMIT 1];
        system.assertEquals(Label.RevSys_Generic_Pass, esrObj.ReportStatus__c); 
    }
    private static testmethod void medicalTest_fail()
    {
       List<EmployeeResultSummary__c> ersList = [Select Id, EvaluationDate__c from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MEDICAL_RECTYPE_ID];
        List<EmployeeResultSummary__c> upList = new List<EmployeeResultSummary__c>();
        
        Test.startTest();
        for(EmployeeResultSummary__c ersObj : ersList)
        {
            ersObj.Result__c = Label.RevSys_Medical_Failed_Vision_Test;
            
            if(ersObj.Type__c == 'Vision Test' || ersObj.Type__c == 'Hearing Test'){
                ersObj.FieldTestAdministered__c = 'Yes';
                ersObj.FieldTestResult__c = Label.RevSys_Generic_Pass;
                ersObj.FieldTestDate__c = Date.today();
                if(ersObj.Type__c == 'Vision Test'){
                    ersObj.RestrictionType__c = 'Corrective Lenses';
                }
                else{
                    ersObj.RestrictionType__c = 'Hearing Aid - Left';
                }
            }else{
                ersObj.FieldTestAdministered__c = 'No';
                ersObj.RestrictionType__c = NULL;
                ersObj.FieldTestDate__c = NULL;
            }
            upList.add(ersObj);
        }
        update upList;
        Test.stopTest();
        
        EmployeeSpecificRequirement__c esrObj = [Select Id, ReportStatus__c from EmployeeSpecificRequirement__c where SourceTestType__c =:Label.RevSys_Generic_Vision_Test LIMIT 1];
        system.assertEquals(Label.RevSys_Generic_Fail, esrObj.ReportStatus__c);
    }
    private static testmethod void autoPopulateFieldsTest(){
        EmployeeResultSummary__c ersObjBeforeUpdate = [Select Id,Status__c, NdrReviewDate__c  from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID LIMIT 1];
        system.assertEquals(ersObjBeforeUpdate.Status__c,'Pending' );
        
        EmployeeResultSummary__c ersObjMVR2BeforeUpdate = [Select Id,Status__c,ClassOfService__c, NdrReviewDate__c  from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID And ClassOfService__c='Conductor' LIMIT 1];
        
        List<EmployeeResultSummary__c> ersList = new List<EmployeeResultSummary__c>();
        
        Test.startTest();
        //checks and sets the Status for Engineers ClassOfService
        ersObjBeforeUpdate.NdrReviewDate__c = Date.today();
        ersObjBeforeUpdate.EapEvaluationDate__c = Date.today();
        ersObjBeforeUpdate.Status__c = 'Fail';
        ersList.add(ersObjBeforeUpdate);
        
        //checks and sets the Status for Conductors ClassOfService
        ersObjMVR2BeforeUpdate.EapEvaluationDate__c = Date.today();
        ersObjMVR2BeforeUpdate.Status__c = 'Fail';
        ersList.add(ersObjMVR2BeforeUpdate);
        update ersList;
        Test.stopTest();
        
        EmployeeResultSummary__c ersObjAfterUpdate = [Select Id,EapEvaluationDate__c,NdrReviewDate__c,ClassOfService__c,StateReviewDate__c,AlcoholOrDrugViolationRevealed__c,Status__c  from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID LIMIT 1];
        system.assertEquals(ersObjAfterUpdate.Status__c,'Pass' );
        
        EmployeeResultSummary__c ersObjMVR2AfterUpdate = [Select Id,EapEvaluationDate__c,NdrReviewDate__c,ClassOfService__c,StateReviewDate__c,AlcoholOrDrugViolationRevealed__c,Status__c  from EmployeeResultSummary__c where RecordTypeId =: RevSys_StaticUtility.EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID LIMIT 1];
        system.assertEquals(ersObjMVR2AfterUpdate.Status__c,'Pass' );
    }
    
    private static testmethod void testProcessSupervisor(){
        test.startTest();
        String ers = RevSys_EmployeeResultSummaryHelper.processSupervisor(new  List<EmployeeResultSummary__c>());
         test.stopTest();
    }
    
}