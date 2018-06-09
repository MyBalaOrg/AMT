// ****************************************************************************************************************
// Class: User Trigger Handler
// Author:  Sarang Padhye, Deloitte Digital
// Date:    Feb 24, 2017
// Description: Test Class for the User Trigger
//
// Modifications: 
// 1.00: Created     
//
@isTest
public class OC_UserTriggerTest {
    
    
    static testMethod void defaultValuesTest()
    {
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole ur = new UserRole(Name = 'Finance Approver');
        insert ur;
        User usr = TestHandler.createTestUser(ur.Id, pf.Id, 'Test FirstName', 'Test LastName');
        try
        {
            insert usr;
            
            User u = [select id,IsPortalEnabled,UserPreferencesTaskRemindersCheckboxDefault,EmailPreferencesStayInTouchReminder,UserPreferencesSortFeedByComment,UserPreferencesEventRemindersCheckboxDefault,UserPreferencesDisableLikeEmail,ReceivesAdminInfoEmails,EmailPreferencesAutoBcc,UserPreferencesApexPagesDeveloperMode,UserPreferencesHideCSNGetChatterMobileTask from user where id =: usr.id];
            system.assertEquals(false, u.IsPortalEnabled);
            system.assertEquals(true, u.UserPreferencesHideCSNGetChatterMobileTask);
        }
        Catch(DMLException e)
        {
            system.debug('EXCEPTION : '+e.getMessage());
        }
        
    }
    
    
}