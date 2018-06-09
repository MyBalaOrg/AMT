// ****************************************************************************************************************
// Class: Contact Trigger Handler
// Author:  Sarang Padhye, Deloitte Digital
// Date:    Feb 24, 2017
// Description: Test Class for the Contact Trigger
//
// Modifications: 
// 1.00: Created     
//
@isTest
public class OC_ContactTriggerTest {
   
    //Method which tests that the user deactivates when the contact is inactive
    static testmethod void PositiveTest() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        system.debug('User '+UserInfo.getUserId());
        System.runAs (thisUser) {  
            Contact testContact = TestHandler.createTestContacts(1)[0];
            insert testContact;
            
            Profile pf = [SELECT Id FROM Profile WHERE Name = 'Amtrak Employee'];
            UserRole ur = new UserRole(Name = 'Finance Approver');
            insert ur;
            User usr = TestHandler.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName');
            usr.EmployeeNumber = testContact.Position_ID__c;
            
            insert usr;
            testContact.Employment_Status__c = 'Separated';
            update testContact;
            
            System.assertEquals(false, usr.isActive);            
        }
        
    }
    
}