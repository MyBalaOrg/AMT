/**
*___________________________________________________
*@Name:     RevSys_OccupationCertificationValid_Test
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
public class RevSys_OccupationCertificationValid_Test {
    
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
        //Create Targets
        List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();
        
        OccupationCertification__c occCert1  =  new OccupationCertification__c
        (
            RecordTypeId    = RevSys_StaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID, 
            Name            = 'Transportation/Engineer', 
            Department__c   = TRANSPORTATION,  
            Craft__c        = ENGINEER, 
            Status__c       = ACTIVE
        );
        occCertList.add(occCert1);

        OccupationCertification__c occCert2  =  new OccupationCertification__c
        (
            RecordTypeId    = RevSys_StaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID, 
            Name            = 'Mechanical/Engineer', 
            Department__c   = MECHANICAL,  
            Craft__c        = ENGINEER, 
            Status__c       = ACTIVE
        );
        occCertList.add(occCert2);

        OccupationCertification__c occCert3  =  new OccupationCertification__c
        (
            RecordTypeId    = RevSys_StaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID, 
            Name            = 'SYSTEM/All', 
            Department__c   = SYSTEMX,  
            Craft__c        = ALL, 
            Status__c       = ACTIVE
        );
        occCertList.add(occCert3);

        insert occCertList;
        
    }
    
    private static testmethod void testOK()
    {
        List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();

        OccupationCertification__c occCert1  =  new OccupationCertification__c
        (
            RecordTypeId    = RevSys_StaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID, 
            Name            = 'Transportation/Conductor', 
            Department__c   = TRANSPORTATION,  
            Craft__c        = CONDUCTOR, 
            Status__c       = ACTIVE
        );
        occCertList.add(occCert1);

        String errMsg; 
        
        Test.startTest();
            errMsg = RevSys_OccupationCertificationValidation.validateRecords(occCertList, null); 
        Test.stopTest();

        system.assertEquals(null, errMsg);
    }

    private static testmethod void testDupe()
    {
        List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();

        OccupationCertification__c occCert1  =  new OccupationCertification__c
        (
            RecordTypeId    = RevSys_StaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID, 
            Name            = 'Transportation/Engineer', 
            Department__c   = TRANSPORTATION,  
            Craft__c        = ENGINEER, 
            Status__c       = ACTIVE
        );
        occCertList.add(occCert1);

        String errMsg; 
        
        Test.startTest();
            errMsg = RevSys_OccupationCertificationValidation.validateRecords(occCertList, null);
        Test.stopTest();

        system.assertEquals(Label.RevSys_Dept_Craft_Combo_Exists, errMsg);
    }

    private static testmethod void testAlreadyHaveAll()
    {
        List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();

        OccupationCertification__c occCert1  =  new OccupationCertification__c
        (
            RecordTypeId    = RevSys_StaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID, 
            Name            = 'SYSTEM/Engineer', 
            Department__c   = SYSTEMX,  
            Craft__c        = ENGINEER, 
            Status__c       = ACTIVE
        );
        occCertList.add(occCert1);

        String errMsg; 
        
        Test.startTest();
            errMsg = RevSys_OccupationCertificationValidation.validateRecords(occCertList, null); 
        Test.stopTest();

        system.assertEquals(Label.RevSys_Dept_Craft_Combo_All_Exists, errMsg);
    }

    private static testmethod void testCannotAddAll()
    {
        List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();

        OccupationCertification__c occCert1  =  new OccupationCertification__c
        (
            RecordTypeId    = RevSys_StaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID, 
            Name            = 'MECHANICAL/ALL', 
            Department__c   = MECHANICAL,  
            Craft__c        = ALL, 
            Status__c       = ACTIVE
        );
        occCertList.add(occCert1);

        String errMsg; 
        
        Test.startTest();
            errMsg = RevSys_OccupationCertificationValidation.validateRecords(occCertList, null);  
        Test.stopTest();

        system.assertEquals(Label.RevSys_Dept_Craft_Combo_Cannot_Use_All, errMsg);
    }
}