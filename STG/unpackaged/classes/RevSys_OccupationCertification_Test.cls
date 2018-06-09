/**
*___________________________________________________
*@Name:     RevSys_OccupationCertification_Test
*@Author:   Raj Kumar Pandy
*@Created:  Date: 11/28/2017
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for RevSys_OccupationCertificationHelper
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest(SeeAllData=false)
public class RevSys_OccupationCertification_Test {
    
    private static final String MECHANICAL = 'Mechanical';
    private static final String ACTIVE  = 'Active';
    private static final String INACTIVE = 'Inactive';
    private static final String CRAFT = 'Test Craft2';
    private static final String SUPERVISOR = 'Supervisor';
    private static final String CURRENT = 'Current';
    private static final String PENDING = 'Pending';
    
    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {

        Contact supe = new Contact
        (
            LastName            ='Supervisor Amy', 
            FirstName           ='Amy', 
            Department          = MECHANICAL,
            Personnel_Number__c = 51331,
            Employment_Status__c = 'Active',
            Email               = 'new@amtrak.com.test'
        );
        insert supe;

        Contact emp = new Contact
        (
            LastName            ='Tim', 
            FirstName           ='The Employee', 
            Department          = MECHANICAL,
            Craft__c            = 'Engineer',
            Employee_Type__c     = 'Internal',
            Employment_Status__c = 'Active',
            HoursOfServiceEmployee__c = true,
            Division__c             = 'Central',
            SPARTN_Requirement__c = 'Blue Signal',
            Personnel_Number__c = 18826,
            Email               = 'emp@amtrak.com.test'
        );
        insert emp;


        EmployeeCertification__c supEmp = new EmployeeCertification__c();
        supEmp.RecordTypeId = RevSYs_StaticUtility.EMPCERT_SPARTSUPV_RECTYPE_ID;
        supEmp.Employee__c = supe.id;
        supEmp.Status__c = 'Active';
        insert supEmp;

        OccupationCertification__c certification = new OccupationCertification__c();
        certification.Name = 'Occupation Certification';
        certification.CertificationType__c = 'Conductor';
        certification.LengthOfPeriod__c = 1;
        certification.Frequency__c = 'Months';
        certification.Status__c = 'Active';
        certification.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        insert certification;

        EmployeeCertification__c ec = new EmployeeCertification__c();
        ec.Status__c='Current';
        ec.Certification__c= certification.Id;
        ec.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
        ec.Employee__c = supe.Id;
        ec.ProcessFlag__c = 'CertifyProcess';
        insert ec;
        
    }
     public static testmethod void testCreateSupervisorTargets()
    {
       
        Test.startTest();
            OccupationCertification__c sup = new OccupationCertification__c();
            sup.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
            sup.TargetType__c = RevSys_StaticUtility.SUPERVISOR;
            sup.SupervisorType__c = 'Applies to all Observations';
            sup.SourceRecordType__c = 'FORM-1872';
            sup.Name = 'Sup Target';
            sup.Frequency__c = 'Months';
            sup.LengthOfPeriod__c = 1;
            sup.NumberOfTestsPerPeriod__c=10;
            sup.Status__c='Active';
            sup.StartDate__c = System.today();
            sup.Department__c = MECHANICAL;
            insert sup;
        Test.stopTest();

        Contact con = [Select Id from Contact where LastName='Supervisor Amy' Limit 1];

        List<EmployeeSpecificRequirement__c> esrList = [Select Id from EmployeeSpecificRequirement__c where Target__c=:sup.Id and Employee__c=:con.Id];
        System.assertEquals(1,esrList.size());

    }
    
     public static testmethod void testCreateCertificationTargets()
    {
        Contact con = [Select Id from Contact where LastName='Supervisor Amy' Limit 1];
        OccupationCertification__c certification = [Select Id from OccupationCertification__c where Name='Occupation Certification' Limit 1];

        Test.startTest();
            OccupationCertification__c certTarget = new OccupationCertification__c();
            certTarget.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
            certTarget.TargetType__c = RevSys_StaticUtility.CERTIFICATION;
            certTarget.SourceRecordType__c = 'FORM-1872';
            certTarget.ParentCertification__c = certification.Id;
            certTarget.Name = 'Certification Target';
            certTarget.Frequency__c = 'Months';
            certTarget.LengthOfPeriod__c = 1;
            certTarget.NumberOfTestsPerPeriod__c=10;
            certTarget.Status__c='Active';
            certTarget.StartDate__c = System.today();
            certTarget.Department__c = MECHANICAL;
            insert certTarget;
        Test.stopTest();


        List<EmployeeSpecificRequirement__c> esrList = [Select Id from EmployeeSpecificRequirement__c where Target__c=:certTarget.Id and Employee__c=:con.Id];
        System.assertEquals(1,esrList.size());

    }

     public static testmethod void testGeneralTargets()
    {
        Contact con = [Select Id,Craft__c from Contact where LastName='Tim' Limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User testUser = new User(
            Alias = 'newUser', 
            Email='newuser@testorg.com.amtrakepw.test',
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='newuser123@testorg.com.amtrakepw.test');
        
        insert testUser;

        PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'SPARTN_SysAdmin_Access'];
        if (ps != null) {
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps.Id );
        }

        System.runAs(testUser) {

            Test.startTest();
                OccupationCertification__c occT = new OccupationCertification__c();
                occT.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
                occT.TargetType__c = RevSys_StaticUtility.OCCUPATION;
                occT.SourceRecordType__c = 'FORM-1872';
                occT.Name = 'Occupational New Target';
                occT.Frequency__c = 'Months';
                occT.LengthOfPeriod__c = 1;
                occT.NumberOfTestsPerPeriod__c=10;
                occT.Status__c='Active';
                occT.StartDate__c = System.today();
                occT.Department__c = MECHANICAL;
                occT.EmployeeDivision__c = 'Delaware Shops';
                occT.EmployeeType__c = 'External';
                occT.HoursOfServiceEmployee__c = true;
                occt.MatchEmployeeAttribute__c = 'Blue Signal';
                //occt.MultiCraft__c = 'Engineer';
                insert occT;
            Test.stopTest();


            List<EmployeeSpecificRequirement__c> esrList = [Select Id from EmployeeSpecificRequirement__c where Target__c=:occT.Id and Employee__c=:con.Id];
            //System.assertEquals(1,esrList.size());
        }

    }

    public static testMethod void testDeactivateChildTargets() {

         Contact con = [Select Id from Contact where LastName='Tim' Limit 1];


        Test.startTest();
            OccupationCertification__c occT = new OccupationCertification__c();
            occT.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
            occT.TargetType__c = RevSys_StaticUtility.OCCUPATION;
            occT.SourceRecordType__c = 'FORM-1872';
            occT.Name = 'Occupational New Target';
            occT.Frequency__c = 'Months';
            occT.LengthOfPeriod__c = 1;
            occT.NumberOfTestsPerPeriod__c=10;
            occT.Status__c='Active';
            occT.StartDate__c = System.today();
            occT.Department__c = MECHANICAL;
            occT.EmployeeDivision__c = 'Delaware Shops';
            occT.EmployeeType__c = 'External';
            occT.HoursOfServiceEmployee__c = true;
            occt.MatchEmployeeAttribute__c = 'Blue Signal';
           // occt.MultiCraft__c = 'Engineer';
            insert occT;

            occT.Status__c=RevSys_StaticUtility.INACTIVE;
            update occT;

        Test.stopTest();

        List<EmployeeSpecificRequirement__c> esrList = [Select Id from EmployeeSpecificRequirement__c where Target__c=:occT.Id and Employee__c=:con.Id and Status__c='Active'];
        System.assertEquals(0,esrList.size());

    }


    public static testMethod void testDeactivateChildEC() {

         Contact con = [Select Id from Contact where LastName='Tim' Limit 1];


        Test.startTest();
            OccupationCertification__c certification = new OccupationCertification__c();
            certification.Name = 'New Cert';
            certification.CertificationType__c = 'Conductor';
            certification.LengthOfPeriod__c = 1;
            certification.Frequency__c = 'Months';
            certification.Status__c = 'Active';
            certification.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
            insert certification;

            EmployeeCertification__c ec = new EmployeeCertification__c();
            ec.Status__c='Current';
            ec.Certification__c= certification.Id;
            ec.RecordTypeId = RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID;
            ec.Employee__c = con.Id;
            ec.ProcessFlag__c = 'CertifyProcess';
            insert ec;

            certification.Status__c='Inactive';
            update certification;

        Test.stopTest();

        List<EmployeeSpecificRequirement__c> esrList = [Select Id from EmployeeSpecificRequirement__c where Certification__c=:certification.Id and Employee__c=:con.Id and Status__c='Active'];
        EmployeeCertification__c checkEC = [Select Status__c from EmployeeCertification__c where Id=:ec.Id];
        System.assertEquals('Expired',checkEC.Status__c);

    }

    public static testMethod void testTriggerException() {
        
        Test.startTest();
        try {
            RevSys_OccCertificationTriggerHandler.DoFailTest=true;
            OccupationCertification__c certTarget = new OccupationCertification__c();
            certTarget.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
            certTarget.TargetType__c = RevSys_StaticUtility.CERTIFICATION;
            //certTarget.ParentCertification__c = occt.Id;
            certTarget.Name = 'Exception Target';
            certTarget.Department__c = MECHANICAL;
            insert certTarget;
        } catch (Exception e) {
                Boolean b = e.getMessage().contains('Error')?true:false;
                System.assertEquals(true,b);
        }
        Test.stopTest();

    }
    
}