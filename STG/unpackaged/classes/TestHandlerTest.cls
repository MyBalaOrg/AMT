/*
 *Class to Test the TestHandler class 
 */

@isTest
public class TestHandlerTest {
    
    static testmethod void testCreateUserMethod() {
       		Profile pf = [SELECT Id FROM Profile WHERE Name = 'Amtrak Employee'];
            UserRole ur = new UserRole(Name = 'Finance Approver');
            insert ur;
            User usr = TestHandler.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName');
        	system.assert(usr != null);
    }
    
    static testmethod void testCreateContacts() {
        Contact testContacts = TestHandler.createTestContacts(1)[0];
        Account acc = TestHandler.createAccount('test Account');
        insert acc;
        Position__c p = TestHandler.createTestPosition('testPos', 'DUMMY');
        insert p;
        Contact testContact = TestHandler.createTestContact('testName',acc.Id ,p.id , 'Active');
        
        OC_Component_FieldList__c c = TestHandler.createComponentFieldList('test', 1, 'SobjectField', 'SobjectName', 'applicationContext','name');
    }

}