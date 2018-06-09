/**
*___________________________________________________
*@Name:     Revsys_HierarchyAssignmentHelper_Test
*@Author:   Chuck Walley
*@Created:  Date: March 15, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for Revsys_HierarchyAssignmentHelper
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class Revsys_HierarchyAssignmentHelper_Test { 
    
    //Creating Test Data
    @TestSetup
    public static void loadTestData()
    {
        // Account 
        
        List<Account> myAccountList = new List<Account>(); 
        
        Account amtrakAcct = new Account
            (
                Name='Amtrak'
            );
        myAccountList.add(amtrakAcct); 
        
        Account foreignRrAcct = new Account
            (
                Name='Foreign Railroad'
            );
        myAccountList.add(foreignRrAcct); 
        
        system.debug('AAAAAAAAAA Inserting Account'); 
        
        INSERT myAccountList; 
        
        // Contact 
        
        List<Contact> myContactList = new List<Contact>(); 
        
        // supervisors
        Contact supervisorA = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Supervisor', 
                FirstName           ='Amy', 
                Personnel_Number__c = 10000000,
                Email               = 'amy.supervisor@amtrak.com'
                
            );
        myContactList.add(supervisorA); 
        
        Contact supervisorB = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Supervisor', 
                FirstName           ='Bob', 
                Personnel_Number__c = 20000000,
                Email               = 'bob.supervisor@amtrak.com'
                
            );
        myContactList.add(supervisorB); 
        
        // employees for supervisor A
        
        Contact employeeA1 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Abigale', 
                Personnel_Number__c = 10000001,
                Email               = 'abigale.employee@amtrak.com'
                
            );
        myContactList.add(employeeA1); 
        
        Contact employeeA2 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Adam', 
                Personnel_Number__c = 10000002,
                Email               = 'adam.employee@amtrak.com'
                
            );
        myContactList.add(employeeA2); 
        
        Contact employeeA3 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Ali', 
                Personnel_Number__c = 10000003,
                Email               = 'ali.employee@amtrak.com'
                
            );
        myContactList.add(employeeA3); 
        
        // employees for supervisor B
        
        Contact employeeB1 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Babu', 
                Personnel_Number__c = 20000001,
                Email               = 'babu.employee@amtrak.com'
                
            );
        myContactList.add(employeeB1); 
        
        Contact employeeB2 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Barbara', 
                Personnel_Number__c = 20000002,
                Email               = 'barbara.employee@amtrak.com'
                
            );
        myContactList.add(employeeB2); 
        
        Contact employeeB3 = new Contact
            (
                AccountId           = amtrakAcct.id, 
                LastName            ='Employee', 
                FirstName           ='Bose', 
                Personnel_Number__c = 20000003,
                Email               = 'bose.employee@amtrak.com'
                
            );
        myContactList.add(employeeB3); 
        
        system.debug('BBBBBBBBBB Inserting Contact'); 
        
        INSERT myContactList; 
        
        // Organization
        
        List<EPW_Organization__c> myOrgList = new List<EPW_Organization__c>(); 
        
        EPW_Organization__c Org1 = new EPW_Organization__c
            ( 
                RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID,   
                Name = 'Amtrak Org', 
                EPW_Organization_Number__c = '1',
                EPW_Status__c = 'Active'
            );
        myOrgList.add(Org1);
        
        EPW_Organization__c Org2 = new EPW_Organization__c
            ( 
                RecordTypeId = Revsys_StaticUtility.ORGANIZATION_SPARTN_RECTYPE_ID, 
                Name = 'Spartn', 
                EPW_Organization_Number__c = '2',
                EPW_Status__c = 'Active'
            );
        myOrgList.add(Org2);
        
        insert myOrgList; 
        
        // Position Hierarchy
        
        List<EPW_Position_Hierarchy__c> myPoHiList = new List<EPW_Position_Hierarchy__c>(); 
        
        EPW_Position_Hierarchy__c myPoHi1 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve1 Supervisor A',
             EPW_Position_ID__c =  '10000000',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            );
        //myPoHiList.add(myPoHi1); 
        
        insert myPoHi1;
        
        EPW_Position_Hierarchy__c myPoHi2 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve1 Supervisor B',
             EPW_Position_ID__c =  '20000000',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            );
        //myPoHiList.add(myPoHi2); 
        
        insert myPoHi2;
        
        EPW_Position_Hierarchy__c myPoHi3 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
             EPW_Parent_Position_Hierarchy__c = myPoHi1.Id, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve2 Employee A - 1',
             EPW_Position_ID__c =  '10000001',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            );
        myPoHiList.add(myPoHi3); 
        
        EPW_Position_Hierarchy__c myPoHi4 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
             EPW_Parent_Position_Hierarchy__c = myPoHi1.Id, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve2 Employee A - 2',
             EPW_Position_ID__c =  '10000002',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            );
        myPoHiList.add(myPoHi4); 
        
        EPW_Position_Hierarchy__c myPoHi5 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
             EPW_Parent_Position_Hierarchy__c = myPoHi1.Id, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve2 Employee A - 3',
             EPW_Position_ID__c =  '10000003',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            );
        myPoHiList.add(myPoHi5); 
        
        EPW_Position_Hierarchy__c myPoHi6 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
             EPW_Parent_Position_Hierarchy__c = myPoHi2.Id, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve2 Employee B - 1',
             EPW_Position_ID__c =  '20000001',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            );
        myPoHiList.add(myPoHi6); 
        
        EPW_Position_Hierarchy__c myPoHi7 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
             EPW_Parent_Position_Hierarchy__c = myPoHi2.Id, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve2 Employee B - 1',
             EPW_Position_ID__c =  '20000002',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation'
            );
        myPoHiList.add(myPoHi7); 
        
        EPW_Position_Hierarchy__c myPoHi8 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
             EPW_Parent_Position_Hierarchy__c = myPoHi2.Id, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve2 Employee B - 1',
             EPW_Position_ID__c =  '20000003',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation' 
            );
        myPoHiList.add(myPoHi8); 
        
        EPW_Position_Hierarchy__c myPoHi11 = new EPW_Position_Hierarchy__c
            (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
             EPW_Parent_Position_Hierarchy__c = myPoHi2.Id, 
             EPW_Position_Organization__c = Org1.Id,
             Name = 'Leve2 Employee B - 1',
             EPW_Position_ID__c =  '20000004',
             EPW_Status__c = 'Active',
             EPW_Dept_Code_Description__c = 'Transportation' 
            );
        myPoHiList.add(myPoHi11);
        
        insert myPoHiList; 
        
        SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();
        setting.Name = 'Valid Employee Department';
        setting.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';
        insert setting;

        Observation__c obs        = new Observation__c();
        obs.RecordTypeId          = RevSys_StaticUtility.OBSERVATION_TEST1878_RECTYPE_ID;
        obs.Status__c             = 'Submitted';
        obs.EvaluationDateTime__c = Datetime.now();
        obs.Employee__c           = myContactList[2].Id;
        obs.TestNumber__c		  = '101';
        insert obs;

    }
    
    
    private static testmethod void test_determineRecord_AccuracyTest()
    {
        String myQuery; 
        // Get all Position Hierarchy Records 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_POSITION_HIERARCHY);   
        myQuery = myQuWrap.QueryString; 
        List<EPW_Position_Hierarchy__c> myPoHiList = Database.query(myQuery); 
        
        Map<String,EPW_Position_Hierarchy__c> myPoHiByNameMap = new Map<String,EPW_Position_Hierarchy__c>(); 
        
        for(EPW_Position_Hierarchy__c myPoHi :myPoHiList) {
            myPoHiByNameMap.put(myPoHi.Name, myPoHi); 
        }
        
        // Get all Contact records
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 
        
        Map<String,Contact> myEmpByEmailMap = new Map<String,Contact>(); 
        
        for(Contact myEmp :myEmpList) {
            myEmpByEmailMap.put(myEmp.Email, myEmp); 
        }
        
        List<EPW_Hierarchy_Assignment__c> myHaList = new List<EPW_Hierarchy_Assignment__c>(); 
        
        // --- 
        
        EPW_Position_Hierarchy__c myPoHi = myPoHiByNameMap.get('Leve1 Supervisor A'); 
        Contact myEmp1 = myEmpByEmailMap.get('amy.supervisor@amtrak.com');
        
        EPW_Hierarchy_Assignment__c myHiAsgn1 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = myEmp1.Id,
                EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        myHaList.add(myHiAsgn1); 
        
        // --- 
        
        myPoHi = myPoHiByNameMap.get('Leve1 Supervisor B'); 
        myEmp1 = myEmpByEmailMap.get('bob.supervisor@amtrak.com');
        
        myHiAsgn1 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = myEmp1.Id,
                EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        myHaList.add(myHiAsgn1); 
        
        // --- 
        
        myPoHi = myPoHiByNameMap.get('Leve2 Employee A - 1'); 
        myEmp1 = myEmpByEmailMap.get('abigale.employee@amtrak.com');
        
        myHiAsgn1 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = myEmp1.Id,
                EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        myHaList.add(myHiAsgn1); 
        
        // --- 
        
        myPoHi = myPoHiByNameMap.get('Leve2 Employee A - 2'); 
        myEmp1 = myEmpByEmailMap.get('adam.employee@amtrak.com');
        
        myHiAsgn1 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = myEmp1.Id,
                EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        myHaList.add(myHiAsgn1); 
        
        INSERT myHaList;   
        
        // Check to ensure the Spartn Hierarchy Assignment record was created 
        
        // Get some Hierarchy Assignment Records 
        Id myEmployeeId = myEmp1.Id; 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_HIERARCHY_ASSIGNMENT); 
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE EPW_Contact__c = :myEmployeeId '; 
        List<EPW_Hierarchy_Assignment__c> myHaList2 = Database.query(myQuery); 
        
        system.assertEquals(2,myHaList2.size() ); 
        
        // Supervisor Email Check 
        
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_HIERARCHY_ASSIGNMENT); 
        myQuery = myQuWrap.QueryString; 
        myHaList2 = Database.query(myQuery); 
        
        Map<Id, EPW_Hierarchy_Assignment__c> myOldHaMap = new Map<Id,EPW_Hierarchy_Assignment__c>(); 
        List<EPW_Hierarchy_Assignment__c> myNewHaList = new List<EPW_Hierarchy_Assignment__c>(); 
        
        for(EPW_Hierarchy_Assignment__c myHa :myHaList2) {
            myOldHaMap.put(myHa.Id,myHa); 
            EPW_Hierarchy_Assignment__c myNewHa = myHa.clone(true,false,false,false); 
            myNewHa.SupervisorEmail__c = 'amy.supervisor@amtrak.com';
            myNewHaList.add(myNewHa);
        }
        
        String errMsg = Revsys_HierarchyAssignmentHelper.getSupervisorEmail(myNewHaList,myOldHaMap); 
        
        
        
    }
    private static testmethod void test_determineRecord_AccuracyTest1()
    {
        String myQuery; 
        // Get all Position Hierarchy Records 
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_POSITION_HIERARCHY);   
        myQuery = myQuWrap.QueryString; 
        List<EPW_Position_Hierarchy__c> myPoHiList = Database.query(myQuery); 
        
        Map<String,EPW_Position_Hierarchy__c> myPoHiByNameMap = new Map<String,EPW_Position_Hierarchy__c>(); 
        
        for(EPW_Position_Hierarchy__c myPoHi :myPoHiList) {
            myPoHiByNameMap.put(myPoHi.Name, myPoHi); 
        }
        
        // Get all Contact records
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_CONTACT);   
        myQuery = myQuWrap.QueryString; 
        List<Contact> myEmpList = Database.query(myQuery); 
        
        Map<String,Contact> myEmpByEmailMap = new Map<String,Contact>(); 
        
        for(Contact myEmp :myEmpList) {
            myEmpByEmailMap.put(myEmp.Email, myEmp); 
        }
        
        List<EPW_Hierarchy_Assignment__c> myHaList = new List<EPW_Hierarchy_Assignment__c>(); 
        
        // --- 
        
        EPW_Position_Hierarchy__c myPoHi = myPoHiByNameMap.get('Leve1 Supervisor A'); 
        Contact myEmp1 = myEmpByEmailMap.get('amy.supervisor@amtrak.com');
        
        EPW_Hierarchy_Assignment__c myHiAsgn1 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = myEmp1.Id,
                EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        myHaList.add(myHiAsgn1); 
        
        // --- 
        
        myPoHi = myPoHiByNameMap.get('Leve1 Supervisor B'); 
        myEmp1 = myEmpByEmailMap.get('bob.supervisor@amtrak.com');
        
        myHiAsgn1 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = myEmp1.Id,
                EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        myHaList.add(myHiAsgn1); 
        
        // --- 
        
        myPoHi = myPoHiByNameMap.get('Leve2 Employee A - 1'); 
        myEmp1 = myEmpByEmailMap.get('abigale.employee@amtrak.com');
        
        myHiAsgn1 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = myEmp1.Id,
                EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        myHaList.add(myHiAsgn1); 
        
        // --- 
        
        myPoHi = myPoHiByNameMap.get('Leve2 Employee A - 2'); 
        myEmp1 = myEmpByEmailMap.get('adam.employee@amtrak.com');
        
        myHiAsgn1 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = myEmp1.Id,
                EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        myHaList.add(myHiAsgn1); 
        
        INSERT myHaList;   
        
        // Check to ensure the Spartn Hierarchy Assignment record was created 
        
        // Get some Hierarchy Assignment Records 
        Id myEmployeeId = myEmp1.Id; 
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_HIERARCHY_ASSIGNMENT); 
        myQuery = myQuWrap.QueryString; 
        myQuery += ' WHERE EPW_Contact__c = :myEmployeeId '; 
        List<EPW_Hierarchy_Assignment__c> myHaList2 = Database.query(myQuery); 
        
        system.assertEquals(2,myHaList2.size() ); 
        
        // Supervisor Email Check 
        
        myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_HIERARCHY_ASSIGNMENT); 
        myQuery = myQuWrap.QueryString; 
        myHaList2 = Database.query(myQuery); 
        
        Map<Id, EPW_Hierarchy_Assignment__c> myOldHaMap = new Map<Id,EPW_Hierarchy_Assignment__c>(); 
        List<EPW_Hierarchy_Assignment__c> myNewHaList = new List<EPW_Hierarchy_Assignment__c>(); 
        
        for(EPW_Hierarchy_Assignment__c myHa :myHaList2) {
            myOldHaMap.put(myHa.Id,myHa); 
            EPW_Hierarchy_Assignment__c myNewHa = myHa.clone(true,false,false,false); 
            myNewHa.SupervisorEmail__c = 'amy.supervisor@amtrak.com';
            myNewHaList.add(myNewHa);
        }
        
        String errMsg = Revsys_HierarchyAssignmentHelper.getSupervisorEmail(myNewHaList,myOldHaMap); 
        Revsys_PositionHierarchyHelper2.processSupervisorPositionHierarchy(myPoHiList);
        
        //Test Bad
        
        Id myAmtrakOrgRecTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID; 
        
        Set<Id> badValue = new Set<Id>();
        EpwOrganizationSelector.DoFailTest = TRUE;
        SelectorWrapper selectorWrapper = EpwOrganizationSelector.getById(badValue, myAmtrakOrgRecTypeId);
        System.assertNotEquals(null,selectorWrapper.ErrorMessage);
        
    }

     public static testMethod void testTriggerExept() {
        Test.startTest();
        try {
            Revsys_EpwHierarchyAssignmentHandler.DoFailTest = true;  
            EPW_Hierarchy_Assignment__c epeHrAs = new EPW_Hierarchy_Assignment__c();
            Contact epwCon =  [SELECT id from Contact where Email = 'amy.supervisor@amtrak.com'];
            epeHrAs.EPW_Contact__c = epwCon.Id;
            insert epeHrAs;
                
        }catch(Exception e) {
            Boolean b = e.getMessage().contains('Error')?true:false;
            System.assertEquals(true,b);
        }
        Test.stopTest();
    }
    private static testmethod void test_determineRecord_AccuracyTest2()
    {
        Contact c = [Select id from contact where email='abigale.employee@amtrak.com'];
        EPW_Position_Hierarchy__c myPohi = [Select id from EPW_Position_Hierarchy__c Limit 1 ];   
        
        Test.startTest();
        EPW_Hierarchy_Assignment__c myHiAsgn0 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = c.Id,
                EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        insert myHiAsgn0;
        Test.stopTest();
    /*    String errorMessage=NUll;
        Set<Id> empIdSet = new Set<Id>();
		empIdSet.add(obs.Employee__c);        
        SelectorWrapper wrapper = ObservationSelector.selectByEmployeeOrderEvaluationDate(empIdSet);
        Map<Id,DateTime> ContactLastTestTakenDateMap = new Map<Id,DateTime>();
        ContactLastTestTakenDateMap.put(obs.Employee__c, obs.EvaluationDateTime__c);
        String errorMessage1=Revsys_HierarchyAssignmentHelper.updateContactLastTesttakenDate(myHaList,myOldHaMap);
        System.assertequals(errorMessage1,''); */
        

        
        
    }
     private static testmethod void test_determineRecord_AccuracyTest3()
    {
        Contact c = [Select id from contact where email='abigale.employee@amtrak.com'];
        EPW_Position_Hierarchy__c myPohi = [Select id from EPW_Position_Hierarchy__c Limit 1 ];   
        
        
        EPW_Hierarchy_Assignment__c myHiAsgn0 = new EPW_Hierarchy_Assignment__c
            ( 
                EPW_Contact__c = c.Id,
                EPW_Position_Hierarchy__c = myPoHi.Id,
                EPW_Status__c = 'Active',
                SupervisorEmail__c = 'bob.supervisor@amtrak.com'
            );
        insert myHiAsgn0;
        Test.startTest();
        myHiAsgn0.EPW_Status__c = 'InActive';
        Update myHiAsgn0;
        Test.stopTest();
    }
}