/**
*___________________________________________________
*@Name:     RevSys_OrgSettingsUtil_Test
*@Author:   Abhishek
*@Created:  Date: 12/01/2017
*@Used_By:  Review Systems
*___________________________________________________
*@Description: Test for RevSys_OrgSettingsUtil
**/
@isTest
public class RevSys_OrgSettingsUtil_Test {
    
    /**
    *————————————————————————————————————————————————————
    * @Name: loadTestData
    * @Description  load test data before the Test execution 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    @TestSetup

    public static void testDataSetup(){
        insert(new SPARTN_BypassTriggerSettings__c(ObservationTrigger__c=true,FindingTrigger__c=true,
                                                 OccupationCertificationTrigger__c=true,ContactTrigger__c=true,
                                                 OccupationRequirementTrigger__c=true,
                                                 OccupationSpecificRequirementTrigger__c=true,EmployeeCertificationTrigger__c=true,
                                                  EmployeeResultSummaryTrigger__c=true,ViolationTrigger__c=true,
                                                  CertificationRevocationTrigger__c=true,PositionHierarchyTrigger__c=true,
                                                  EpwHierarchyAssignmentTrigger__c=true,EmployeeSpecificRequirementTrigger__c=true));
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: testRevSys_OrgSettingsUtil  
    * @Description
    * Fetches custom setting instance value RevSysBypassTriggerSettings__c
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testmethod void testRevSys_OrgSettingsUtil(){
       
        Boolean ObservationTrigger = RevSys_OrgSettingsUtil.isObservationTriggerBypassEnabled();
        system.assertEquals(true, ObservationTrigger);
        
        Boolean FindingTrigger = RevSys_OrgSettingsUtil.isFindingTriggerBypassEnabled();
        system.assertEquals(true, FindingTrigger);
        
        Boolean OccupationCertificationTrigger = RevSys_OrgSettingsUtil.isOccupationCertificationTriggerBypassEnabled();
        system.assertEquals(true, OccupationCertificationTrigger);
        
        Boolean ContactTrigger = RevSys_OrgSettingsUtil.isContactTriggerBypassEnabled();
        system.assertEquals(true, ContactTrigger);
        
        Boolean OccupationRequirementTrigger = RevSys_OrgSettingsUtil.isOccupationRequirementTriggerBypassEnabled();
        system.assertEquals(true, OccupationRequirementTrigger);
        
        Boolean OccupationSpecificRequirementTrigger = RevSys_OrgSettingsUtil.isOccupationSpecificRequirementTriggerBypassEnabled();
        system.assertEquals(true, OccupationSpecificRequirementTrigger);
        
         Boolean EmployeeCertificationTrigger = RevSys_OrgSettingsUtil.isEmployeeCertificationTriggerBypassEnabled();
        system.assertEquals(true, EmployeeCertificationTrigger);
        
        Boolean EmployeeResultSummaryTrigger = RevSys_OrgSettingsUtil.isEmployeeResultSummaryTriggerBypassEnabled();
        system.assertEquals(true, EmployeeResultSummaryTrigger);
		
		Boolean ViolationTrigger = RevSys_OrgSettingsUtil.isViolationTriggerBypassEnabled();
        system.assertEquals(true, ViolationTrigger);
		
		Boolean CertificationRevocationTrigger = RevSys_OrgSettingsUtil.isCertificationRevocationTriggerBypassEnabled();
        system.assertEquals(true, CertificationRevocationTrigger);
		
		Boolean PositionHierarchyTrigger = RevSys_OrgSettingsUtil.isPositionHierarchyTriggerBypassEnabled();
        system.assertEquals(true, PositionHierarchyTrigger);

        Boolean EpwHierarchyAssignmentTrigger = RevSys_OrgSettingsUtil.isEpwHierarchyAssignmentTriggerBypassEnabled();
        system.assertEquals(true, EpwHierarchyAssignmentTrigger);

        Boolean EmployeeSpecificRequirementTrigger = RevSys_OrgSettingsUtil.isEmployeeSpecificRequirementTriggerBypassEnabled();
        system.assertEquals(true, EmployeeSpecificRequirementTrigger);

     }
}