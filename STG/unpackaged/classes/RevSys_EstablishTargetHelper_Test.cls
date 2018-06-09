/**
*___________________________________________________
*@Name:     RevSys_EstablishTargetHelper_Test
*@Author:   Raj Pandy
*@Created:  Date: 03/18/2018
*@Used_By:  Review Systems
*___________________________________________________
*@Description: Test for RevSys_ObservationHandler
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest(SeeAllData=false)

public class RevSys_EstablishTargetHelper_Test {
    
    @TestSetup
    public static void dataSetup(){
        List<Contact> contactList = new List<Contact>();
        Contact employee = new Contact
        (
            LastName            ='Employee', 
            FirstName           ='Amy', 
            Department          = 'Mechanical',
            Craft__c            = 'Other',
            Personnel_Number__c = 1234567,
            Division__c         = 'Northwest',
            Email               = 'test.test@amtrak.com',
            Railroad__c         = 'MBTA',
            Employment_Status__c = 'Active',
            HoursOfServiceEmployee__c = false,
            SPARTN_Requirement__c = 'Gang'
        );
        contactList.add(employee);

        employee = new Contact
        (
            LastName            ='Employee', 
            FirstName           ='Amy2', 
            Department          = 'Mechanical',
            Craft__c            = 'N/A',
            Personnel_Number__c = 123123,
            Employment_Status__c = 'Active',
            Division__c         = 'Northwest',
            Email               = 'test.test12@amtrak.com',
            Railroad__c         = 'MBTA',
            HoursOfServiceEmployee__c = false,
            SPARTN_Requirement__c = 'Gang'
        );
        contactList.add(employee);

        employee = new Contact
        (
            LastName            ='Employee', 
            FirstName           ='Amy3', 
            Department          = 'Mechanical',
            //Craft__c            = 'N/A',
            Personnel_Number__c = 123999,
            Employment_Status__c = 'Active',
            Division__c         = 'Northwest',
            Email               = 'test.test123@amtrak.com',
            Railroad__c         = 'MBTA',
            HoursOfServiceEmployee__c = false,
            SPARTN_Requirement__c = 'Gang'
        );
        contactList.add(employee);

        insert contactList;
    }

    public static testMethod void testEstablistTargetsFromOccCert() {


        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('CONTACT');
        String myQuery  = myQuWrap.QueryString; 
        List<Contact> contactList = Database.query(myQuery); 


        OccupationCertification__c occT = new OccupationCertification__c();
        occT.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
        occT.TargetType__c = RevSys_StaticUtility.OCCUPATION;
        occT.SourceRecordType__c = 'FORM-1872';
        occT.Name = 'Occupational New Target';
        occT.Frequency__c = 'Months';
        occT.LengthOfPeriod__c = 2;
        occT.NumberOfTestsPerPeriod__c=10;
        occT.Status__c='Active';
        occT.StartDate__c = System.today();
        occT.MultiCraft__c = 'Manager';
        occT.Department__c = 'Transportation';
        occT.EmployeeDivision__c = 'Central';
        occT.EmployeeType__c = 'Internal';
        occT.HoursOfServiceEmployee__c = true;
        occt.MatchEmployeeAttribute__c = 'Blue Signal';
        insert occT;

        myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');
        myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE ID = \''+occT.Id+'\''; 
        List<OccupationCertification__c> occList = Database.query(myQuery);
        RevSys_EstablishTargetHelper.establistTargetsFromOccCert(contactList,occList,RevSys_StaticUtility.OCCUPATION);

        occT.Department__c = 'Mechanical';
        update occT;

        myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');
        myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE ID = \''+occT.Id+'\''; 
        occList = Database.query(myQuery);
        RevSys_EstablishTargetHelper.establistTargetsFromOccCert(contactList,occList,RevSys_StaticUtility.OCCUPATION);

        occT.MultiCraft__c = 'All';
        update occT;

        myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');
        myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE ID = \''+occT.Id+'\''; 
        occList = Database.query(myQuery);
        RevSys_EstablishTargetHelper.establistTargetsFromOccCert(contactList,occList,RevSys_StaticUtility.OCCUPATION);

        occT.MultiCraft__c = 'Other';
        update occT;

        myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');
        myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE ID = \''+occT.Id+'\''; 
        occList = Database.query(myQuery);
        RevSys_EstablishTargetHelper.establistTargetsFromOccCert(contactList,occList,RevSys_StaticUtility.OCCUPATION);

        occT.EmployeeDivision__c = 'Delaware Shops';
        update occT;

        myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');
        myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE ID = \''+occT.Id+'\''; 
        occList = Database.query(myQuery);
        RevSys_EstablishTargetHelper.establistTargetsFromOccCert(contactList,occList,RevSys_StaticUtility.OCCUPATION);

        occT.EmployeeType__c = 'External';
        update occT;

        myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');
        myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE ID = \''+occT.Id+'\''; 
        occList = Database.query(myQuery);
        RevSys_EstablishTargetHelper.establistTargetsFromOccCert(contactList,occList,RevSys_StaticUtility.OCCUPATION);

        occT.HoursOfServiceEmployee__c = false;
        update occT;

        myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');
        myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE ID = \''+occT.Id+'\''; 
        occList = Database.query(myQuery);
        RevSys_EstablishTargetHelper.establistTargetsFromOccCert(contactList,occList,RevSys_StaticUtility.OCCUPATION);


        occT.MatchEmployeeAttribute__c = 'Gang';
        update occT;

        myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');
        myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE ID = \''+occT.Id+'\''; 
        occList = Database.query(myQuery);
        RevSys_EstablishTargetHelper.establistTargetsFromOccCert(contactList,occList,RevSys_StaticUtility.OCCUPATION);


    }

    public static testMethod void testEstablistTargetsFromOccCertSuper() {
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery('CONTACT');
        String myQuery  = myQuWrap.QueryString; 
        List<Contact> contactList = Database.query(myQuery); 

        OccupationCertification__c occT = new OccupationCertification__c();
        occT.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
        occT.TargetType__c = RevSys_StaticUtility.OCCUPATION;
        occT.SourceRecordType__c = 'FORM-1872';
        occT.Name = 'Occupational New Target';
        occT.Frequency__c = 'Quarters';
        occT.LengthOfPeriod__c = 2;
        occT.NumberOfTestsPerPeriod__c=10;
        occT.Status__c='Active';
        occT.StartDate__c = System.today();
        occT.MultiCraft__c = 'Other';
        occT.Department__c = 'Mechanical';
        occT.EmployeeDivision__c = 'Delaware Shops';
        occT.EmployeeType__c = 'Internal';
        occT.HoursOfServiceEmployee__c = false;
        occt.MatchEmployeeAttribute__c = 'Gang';
        occt.DivisionOfObservation__c  = 'Northwest';
        insert occT;

        myQuWrap = QueryUtility.beginDynamicQuery('OccupationCertification__c');
        myQuery  = myQuWrap.QueryString; 
        myQuery  += ' WHERE ID = \''+occT.Id+'\''; 
        List<OccupationCertification__c> occList = Database.query(myQuery);
        RevSys_EstablishTargetHelper.establistTargetsFromOccCert(contactList,occList,RevSys_StaticUtility.SUPERVISOR);

    }
    public static testMethod void testContactSupervisor() {

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
        supTarget.MultiCraft__c = 'Other';
        supTarget.Department__c = 'Mechanical';
        supTarget.EmployeeDivision__c = 'Delaware Shops';
        supTarget.EmployeeType__c = 'Internal';
        supTarget.HoursOfServiceEmployee__c = false;
        supTarget.MatchEmployeeAttribute__c = 'Gang';
        supTarget.DivisionOfObservation__c  = 'Northwest';
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

    public static testMethod void testContactTargets() {

        Test.startTest();

        List<OccupationCertification__c> occTList = new List<OccupationCertification__c>();
        
        OccupationCertification__c occT = new OccupationCertification__c();
        occT.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
        occT.TargetType__c = RevSys_StaticUtility.OCCUPATION;
        occT.SourceRecordType__c = 'FORM-1872';
        occT.Name = 'Other Target';
        occT.Frequency__c = 'Quarters';
        occT.LengthOfPeriod__c = 2;
        occT.NumberOfTestsPerPeriod__c=10;
        occT.Status__c='Active';
        occT.StartDate__c = System.today();
        occT.MultiCraft__c = 'Other';
        occT.Department__c = 'Mechanical';
        occT.EmployeeDivision__c = 'Delaware Shops';
        occT.EmployeeType__c = 'Internal';
        occT.HoursOfServiceEmployee__c = false;
        occt.MatchEmployeeAttribute__c = 'Gang';
        occt.DivisionOfObservation__c  = 'Northwest';
        occTList.add(occt);

        occT = new OccupationCertification__c();
        occT.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
        occT.TargetType__c = RevSys_StaticUtility.OCCUPATION;
        occT.SourceRecordType__c = 'FORM-1872';
        occT.Name = 'Occupational New Target';
        occT.Frequency__c = 'Quarters';
        occT.LengthOfPeriod__c = 2;
        occT.NumberOfTestsPerPeriod__c=10;
        occT.Status__c='Active';
        occT.StartDate__c = System.today();
        occT.MultiCraft__c = 'Other';
        occT.Department__c = 'Mechanical';
        occT.EmployeeDivision__c = 'Delaware Shops';
        occT.EmployeeType__c = 'Internal';
        occT.HoursOfServiceEmployee__c = false;
        occt.MatchEmployeeAttribute__c = 'Gang';
        occt.DivisionOfObservation__c  = 'Northwest';
        occTList.add(occt);

        insert occTList;

        Contact employee = [SELECT Id,LastName FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        
        EmployeeSpecificRequirement__c esr = new EmployeeSpecificRequirement__c();
        esr.Target__c = occTList[0].Id;
        esr.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID;
        esr.Status__c='Active';
        esr.Employee__c = employee.Id;
        insert esr;

        esr = new EmployeeSpecificRequirement__c();
        esr.Target__c = occTList[1].Id;
        esr.RecordTypeId = RevSys_StaticUtility.EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID;
        esr.Status__c='Inactive';
        esr.Employee__c = employee.Id;
        insert esr;
        

        update employee; 


        Test.stopTest();
    }

    public static testMethod void testContactOccupationTarget2(){

        Test.startTest();
        OccupationCertification__c supTarget = new  OccupationCertification__c();
        supTarget.Name = 'NewSuperVisorTarget';
        supTarget.TargetType__c = 'Occupation';
        supTarget.Status__c= 'Active';
        supTarget.Frequency__c = 'Months';
        supTarget.NumberOfTestsPerPeriod__c=5;
        supTarget.LengthOfPeriod__c = 1;
        supTarget.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID;
        supTarget.StartDate__c = System.today();
        supTarget.Department__c = 'Transportation';
        insert supTarget;

        Contact employee = [SELECT Id,LastName,Department FROM Contact where Personnel_Number__c=1234567 LIMIT 1];
        employee.Department = 'Transportation';
        update employee;

        System.assertNotEquals(0,[Select Id from EmployeeSpecificRequirement__c where Employee__c =:employee.id].size());
        Test.stopTest();

    }



}