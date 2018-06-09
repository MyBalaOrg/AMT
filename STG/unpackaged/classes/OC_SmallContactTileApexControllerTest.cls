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
public class OC_SmallContactTileApexControllerTest {
	// Tests that methods return false when no manager or subordinate exists
    static testmethod void testNullCase() {
        Account newAccount = TestHandler.createAccount('Account');
        insert newAccount;
        Position__C thisPosition = TestHandler.createTestPosition('Title', 'SELECTID');
        insert thisPosition;
        Test.startTest();
        Boolean isPosition = OC_SmallContactTileApexController.hasManager('FAKEID');
        Boolean hasManager = OC_SmallContactTileApexController.hasManager(thisPosition.Id);
        Boolean hasSubordinates = OC_SmallContactTileApexController.hasSubordinates(thisPosition.Id);
        Test.stopTest();
        System.assertEquals(false, isPosition);
        System.assertEquals(false, hasManager);
        System.assertEquals(false, hasSubordinates);
    }
    
    // Tests that all methods return true when managers and subordinates exists
    static testmethod void testPositiveCase() {
        Position__C managerPosition = TestHandler.createTestPosition('Title','MANAGEID');
        insert managerPosition;
        Position__C thisPosition = TestHandler.createTestPosition('Title', 'SELECTID');
        thisPosition.Generated_Reports_To_Position__c = managerPosition.id;
        insert thisPosition;
        Test.startTest();
        Boolean hasManager = OC_SmallContactTileApexController.hasManager(thisPosition.Id);
        Boolean hasSubordinates = OC_SmallContactTileApexController.hasSubordinates(managerPosition.Id);
        Test.stopTest();
        System.assertEquals(true, hasManager);
        System.assertEquals(true, hasSubordinates);
    }
 
}