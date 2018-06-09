// ****************************************************************************************************************
// Title: Org Chart Top Level Apex Controller Test Class
// Author:  Luke Kanter, Deloitte Digital
// Date:    February 13, 2017
//
// Modifications: 
// 1.00: Created 
// 1.01: Modified to use new Position-Contact Data structure    
// ****************************************************************************************************************
@isTest(SeeAllData=False)
public class OC_OrgChartTopLevelApexControllerTest {
   @testSetup static void setup() {
        Organization_Chart__c orgChart = new Organization_Chart__c();
        orgChart.Name = 'OrgChartData';
        orgChart.Advanced_Search_URL__c = 'advanced search url';
        orgChart.Export_All_URL__c = 'export All URL';
        orgChart.Origin_Tile_Title__c = 'Amtrak Summary';
        insert orgChart;
       
   }
    
    // Tests that all methods return null when there is no position with the specified ID
    static testmethod void testNullCase() {
        
        Test.startTest();
        //passing in hard-coded Id values in Id format that are not visible to the test
        OC_OrgChartTopLevelApexController.Employee selected = OC_OrgChartTopLevelApexController.querySelectedEmployee('a034C000002Rmp1');
        OC_OrgChartTopLevelApexController.Employee manager = OC_OrgChartTopLevelApexController.queryManager('a034C000002Rmp1');
        List<OC_OrgChartTopLevelApexController.Employee> subs = OC_OrgChartTopLevelApexController.querySubordinates('a034C000002Rmp1');
        Test.stopTest();
        
        //verifying results
        System.assertEquals(null, selected);
        System.assertEquals(null, manager);
        System.assertEquals(null, subs);
    }
    
    // Tests that an Employee wrapper with position info is returned when there is no contact associated with the position
    static testmethod void testVacantCase() {
        Position__C vacantPosition = TestHandler.createTestPosition('Title', 'VACANTID');
        insert vacantPosition;
        
        Test.startTest();
        OC_OrgChartTopLevelApexController.Employee selected = OC_OrgChartTopLevelApexController.querySelectedEmployee(vacantPosition.Id);
        Test.stopTest();
        System.assertEquals(vacantPosition.Id, selected.position.Id);
    }
    
    // Tests that a dummy position such as an org unit does not return Vacant Position
    static testmethod void testDummyCase() {
        
        Position__C dummyPosition = TestHandler.createTestPosition('Title', 'DUMMYID');
        insert dummyPosition;
        Test.startTest();
        OC_OrgChartTopLevelApexController.Employee selected = OC_OrgChartTopLevelApexController.querySelectedEmployee(dummyPosition.Id);
        Test.stopTest();
        System.assertEquals(dummyPosition.Id, selected.position.Id);
        
    }
    
    // Tests that all methods return the correct ID when the queried contact's ID does exist
    static testmethod void testPositiveCase() {
        Account newAccount = new Account(Name='Account');
        insert newAccount;
        Position__C managerPosition = new Position__C(Name='Title', Position_ID__c='MANAGEID');
        insert managerPosition;
        Contact managerContact = new Contact(LastName='Manager', AccountId= newAccount.Id, PositionLookup__c= managerPosition.Id, Employment_Status__c= 'Active');
        insert managerContact;
        Position__C thisPosition = new Position__C(Name='Title', Position_ID__c='SELECTID', Generated_Reports_To_Position__c= managerPosition.Id);
        insert thisPosition;
        Contact thisContact = new Contact(LastName='Madison', FirstName='Billy', AccountId= newAccount.Id, PositionLookup__c= thisPosition.Id, Employment_Status__c= 'Active');
        insert thisContact;
        Position__C secondPosition = new Position__C(Name='Title', Position_ID__c='SECONDID', Generated_Reports_To_Position__c= managerPosition.Id);
        insert secondPosition;
        Contact secondContact = new Contact(LastName='Washington', FirstName='George', AccountId= newAccount.Id, PositionLookup__c= secondPosition.Id, Employment_Status__c= 'Active');
        insert secondContact;
        Position__C thirdPosition = new Position__C(Name='Title', Position_ID__c='THIRDID', Generated_Reports_To_Position__c= managerPosition.Id);
        insert thirdPosition;
        Contact thirdContact = new Contact(LastName='Trump', FirstName='Donald', AccountId= newAccount.Id, PositionLookup__c= thirdPosition.Id, Employment_Status__c= 'Active');
        insert thirdContact;
        Position__C dummyPosition = new Position__C(Name='Title', Position_ID__c='DUMMYID', Generated_Reports_To_Position__c= managerPosition.Id);
        insert dummyPosition;
        Position__C vacantPosition = new Position__C(Name='Title', Position_ID__c='VACANTID', Generated_Reports_To_Position__c= dummyPosition.Id);
        insert vacantPosition;
        Test.startTest();
        OC_OrgChartTopLevelApexController.Employee selected = OC_OrgChartTopLevelApexController.querySelectedEmployee(thisPosition.Id);
        OC_OrgChartTopLevelApexController.Employee manager = OC_OrgChartTopLevelApexController.queryManager(thisPosition.Id);
        List<OC_OrgChartTopLevelApexController.Employee> subs = OC_OrgChartTopLevelApexController.querySubordinates(managerPosition.Id);
        OC_OrgChartTopLevelApexController.Employee noManager = OC_OrgChartTopLevelApexController.queryManager(managerPosition.Id);
        OC_OrgChartTopLevelApexController.Employee dummyManager = OC_OrgChartTopLevelApexController.queryManager(vacantPosition.Id);
        List<OC_OrgChartTopLevelApexController.Employee> vacantSubs = OC_OrgChartTopLevelApexController.querySubordinates(dummyPosition.Id);
        thirdPosition.Generated_Reports_To_Position__c = vacantPosition.Id;
        update thirdPosition;
        OC_OrgChartTopLevelApexController.Employee vacantManager = OC_OrgChartTopLevelApexController.queryManager(thirdPosition.Id);
        Test.stopTest();
        System.assertEquals(thisPosition.Id, selected.position.Id);
        System.assertEquals(managerPosition.Id, manager.position.Id);
        System.assertNotEquals(null, subs.get(0).position.Id);
        System.assertEquals(null, noManager);
    }
    
    //  Tests that when no position with the specified Id exists,
    //  that the default contact (Amtrak Summary) will be returned
    static testmethod void testDefault() {
        
        
        Account newAccount = TestHandler.createAccount('Account');
        insert newAccount;
        
        Position__c defaultPosition = TestHandler.createTestPosition('Summary', '90210999');
        insert defaultPosition;
        
        
        //Contact defaultContact = new Contact(LastName='Amtrak Summary', AccountId= newAccount.Id, PositionLookup__c=defaultPosition.Id, Employment_Status__c= 'Active');
        
        
        Contact defaultContact = TestHandler.createTestContact('Amtrak Summary', newAccount.Id, defaultPosition.Id,'Active');
        insert defaultContact;
        Test.startTest();
        OC_OrgChartTopLevelApexController.Employee amtrakSummary = OC_OrgChartTopLevelApexController.querySelectedEmployee('');
        Test.stopTest();
        System.assertNotEquals(null, amtrakSummary);
    }
    
   
    }