/**
*___________________________________________________
*@Name: 	RevSys_OccupationRequirement_Test
*@Author: 	Raj Kumar Pandy
*@Created: 	Date: 11/29/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Test for RevSys_OccupationRequirementHelper
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class RevSys_OccupationRequirement_Test {
    
    private static final String ACTIVE  = 'Active';
    private static final String INACTIVE = 'Inactive';
    
    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {
        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 1';
        occReqObj.Frequency__c = 'Years';
        occReqObj.LengthOfPeriod__c = 5;
        occReqObj.Status__c = ACTIVE;
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        
        insert occReqObj;
        
        Contact employee = new Contact
            (
                LastName			='Employee', 
                FirstName			='Amy', 
                Personnel_Number__c = 1234567,
                Email 				= 'test.test@amtrak.com'
            );
        insert employee; 
        
        OccupationCertification__c occCert  =  new OccupationCertification__c();
        occCert.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert.Name = 'Occupation Certification 1';
        occCert.LengthOfPeriod__c = 8;
        occCert.NumberOfTestsPerPeriod__c = 2;
        occCert.Status__c = ACTIVE;
        insert occCert;
    }
    
    private static testmethod void deactivateOccSpecReq()
    {
        OccupationRequirement__c occReq = [Select id, Status__c from OccupationRequirement__c where Name = 'Occupation Requirement 1' LIMIT 1];
        OccupationCertification__c occCert = [Select id, Status__c from OccupationCertification__c where Name = 'Occupation Certification 1' LIMIT 1];
        
        OccupationSpecificRequirement__c occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReq.id;
        occSpecReqObj.Status__c = ACTIVE;
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        
        insert occSpecReqObj;
        
        Test.startTest();
        occReq.Status__c = INACTIVE;
        update occReq;
        Test.stopTest();
        
        OccupationSpecificRequirement__c tempOccSpecReq = [Select Status__c from OccupationSpecificRequirement__c where Requirement__c =:occReq.id LIMIT 1];
        system.assertEquals(INACTIVE, tempOccSpecReq.Status__c);
        
    }
    
    private static testmethod void testDeactivateEmpSpecReq()
    {
        OccupationRequirement__c occReq = [Select id, Status__c from OccupationRequirement__c where Name = 'Occupation Requirement 1' LIMIT 1];
        
        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        
        EmployeeSpecificRequirement__c empSpecReqObj = new EmployeeSpecificRequirement__c();
        empSpecReqObj.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID;
        empSpecReqObj.Employee__c = employee.id;
        empSpecReqObj.Requirement__c = occReq.id;
        empSpecReqObj.Status__c = ACTIVE;
        
        insert empSpecReqObj;
        
        Test.startTest();
        occReq.Status__c = INACTIVE;
        update occReq;
        Test.stopTest();
        
        EmployeeSpecificRequirement__c tempEmpCertObj = [Select id, Certification__c, Status__c from EmployeeSpecificRequirement__c where Requirement__c =: occReq.id LIMIT 1];
        system.assertEquals(INACTIVE, tempEmpCertObj.Status__c);    
    }
    public static testMethod void testTriggerExeption() {
        Test.startTest();
        try {
            RevSys_OccRequirementTriggerHandler.DoFailTest = true;
            OccupationRequirement__c occReqObj = new OccupationRequirement__c();
            occReqObj.Name = 'Occupation Requirement 1';
            occReqObj.Frequency__c = 'Years';
            occReqObj.LengthOfPeriod__c = 5;
            occReqObj.Status__c = ACTIVE;
            occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
            insert occReqObj;
        }catch(Exception e) {
            Boolean b = e.getMessage().contains('Error')?true:false;
            System.assertEquals(true,b);
        }
        Test.stopTest();
    }
}