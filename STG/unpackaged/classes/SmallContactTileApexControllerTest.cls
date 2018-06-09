// ****************************************************************************************************************
// Title: Small Contact Tile Apex Controller Test Class
// Author:  Luke Kanter, Deloitte Digital
// Date:    February 13, 2017
//
// Modifications: 
// 1.00: Created
// 1.01: Modified to use new Position-Contact Data structure      
// ****************************************************************************************************************
@isTest(SeeAllData=False)
public class SmallContactTileApexControllerTest {
	// Tests that methods return false when no manager or subordinate exists
    static testmethod void testNullCase() {
        Account newAccount = new Account(Name='Account');
        insert newAccount;
        Position__C thisPosition = new Position__C(Name='Title', Position_ID__c='SELECTID');
        insert thisPosition;
        Test.startTest();
        Boolean isPosition = SmallContactTileApexController.hasManager('FAKEID');
        Boolean hasManager = SmallContactTileApexController.hasManager(thisPosition.Id);
        Boolean hasSubordinates = SmallContactTileApexController.hasSubordinates(thisPosition.Id);
        Test.stopTest();
        System.assertEquals(null, isPosition);
        System.assertEquals(false, hasManager);
        System.assertEquals(false, hasSubordinates);
    }
    
    // Tests that all methods return true when managers and subordinates exists
    static testmethod void testPositiveCase() {
        Position__C managerPosition = new Position__C(Name='Title', Position_ID__c='MANAGEID');
        insert managerPosition;
        Position__C thisPosition = new Position__C(Name='Title', Position_ID__c='SELECTID', Generated_Reports_To_Position__c= managerPosition.Id);
        insert thisPosition;
        Test.startTest();
        Boolean hasManager = SmallContactTileApexController.hasManager(thisPosition.Id);
        Boolean hasSubordinates = SmallContactTileApexController.hasSubordinates(managerPosition.Id);
        Test.stopTest();
        System.assertEquals(true, hasManager);
        System.assertEquals(true, hasSubordinates);
    }
 
}