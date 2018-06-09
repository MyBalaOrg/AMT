/*
 * User Trigger Handler class for Org Chart Application
 * 
 */
public class OC_UserTriggerHandler {
    
/*
 * Method to default user fields.
 */    
    public static void autopopulateFieldsForUsersBeforeInsert(List<User> newUsers) {
        try{
            for(User u : newUsers) {
                u.ForecastEnabled = false;
                u.UserPermissionsMobileUser = false;
                u.UserPreferencesApexPagesDeveloperMode = false;
                u.UserPermissionsCallCenterAutoLogin = false;
                u.EmailPreferencesAutoBccStayInTouch = false;
                u.UserPermissionsAvantgoUser = false;
                u.UserPreferencesCacheDiagnostics = false;
                u.DigestFrequency = 'N';
                u.UserPreferencesContentEmailAsAndWhen = false;
                u.UserPreferencesContentNoEmail = false;
                u.DefaultGroupNotificationFrequency = 'N';
                u.UserPreferencesDisableAllFeedsEmail = false;
                u.UserPreferencesDisableBookmarkEmail = false;
                u.UserPreferencesDisableChangeCommentEmail = false;
                u.UserPreferencesDisableEndorsementEmail = false;
                u.UserPreferencesDisableFileShareNotificationsForApi = false;
                u.UserPreferencesDisableFollowersEmail = false;
                u.UserPreferencesDisableLaterCommentEmail = false;
                u.UserPreferencesDisableLaterCommentEmail = false;
                u.UserPreferencesDisableMessageEmail = false;
                u.UserPreferencesDisableProfilePostEmail = false;
                u.UserPreferencesDisableSharePostEmail = false;
                u.UserPreferencesDisCommentAfterLikeEmail = false;
                u.UserPreferencesDisMentionsCommentEmail = false;
                u.UserPreferencesDisProfPostCommentEmail = false;
                u.UserPreferencesEnableAutoSubForFeeds = true;
                u.UserPermissionsInteractionUser = false;
                u.UserPreferencesHideBiggerPhotoCallout = false;
                u.UserPreferencesHideChatterOnboardingSplash = true;
                u.UserPreferencesHideCSNDesktopTask = true;
                u.UserPreferencesHideCSNGetChatterMobileTask = true;
                u.UserPreferencesHideEndUserOnboardingAssistantModal = true;
                u.UserPreferencesHideLightningMigrationModal = true;
                u.UserPreferencesHideS1BrowserUI = false;
                u.UserPreferencesHideSecondChatterOnboardingSplash = true;
                u.UserPreferencesHideSfxWelcomeMat = true;
                u.ReceivesAdminInfoEmails = true;
                u.UserPermissionsKnowledgeUser = false;
                u.UserPreferencesLightningExperiencePreferred = true;
                u.UserPermissionsMarketingUser = false;
                u.UserPermissionsOfflineUser = false;
                u.UserPreferencesPathAssistantCollapsed = false;
                u.UserPreferencesPreviewLightning = false;
                u.UserPreferencesReminderSoundOff = true;
                u.UserPermissionsSFContentUser = false;
                u.UserPreferencesShowCityToExternalUsers = false;
                u.UserPreferencesShowCityToGuestUsers = false;
                u.UserPreferencesShowCountryToExternalUsers = false;
                u.UserPreferencesShowCountryToGuestUsers = false;
                u.UserPreferencesShowFaxToExternalUsers = false;
                u.UserPreferencesShowFaxToGuestUsers = false;
                u.UserPreferencesShowManagerToExternalUsers = false;
                u.UserPreferencesShowManagerToGuestUsers = false;
                u.UserPreferencesShowMobilePhoneToExternalUsers = false;
                u.UserPreferencesShowMobilePhoneToGuestUsers = false;
                u.UserPreferencesShowPostalCodeToExternalUsers = false;
                u.UserPreferencesShowPostalCodeToGuestUsers = false;
                u.UserPreferencesShowProfilePicToGuestUsers = false;
                u.UserPreferencesShowStateToExternalUsers = false;
                u.UserPreferencesShowStateToGuestUsers	= false;
                u.UserPreferencesShowStreetAddressToExternalUsers = false;
                u.UserPreferencesShowStreetAddressToGuestUsers = false;
                u.UserPreferencesShowTitleToExternalUsers = true;
                u.UserPreferencesShowTitleToGuestUsers = false;
                u.UserPreferencesShowWorkPhoneToExternalUsers = false;
                u.UserPreferencesShowWorkPhoneToGuestUsers = false;
                
            }
            
        }catch(Exception e) {
            system.debug('EXCEPTION: '+e.getMessage());
        }
    }
    
    /*
     * Update user field to default values since not all values are allowed to be defaulted during insert.
     */ 
    public static void autopopulateFieldsForUsersAfterInsert(List<User> newUsers) {
        List<ID> userId = new List<ID>();
        List<user> userToBeUpdated = new List<user>();
        
        try{
            //Retrieve all the Ids from the users
            for(user u : newUsers) {
                userId.add(u.Id);
            }
            //Requery all the records to update in the same transaction.
            userToBeUpdated = [select id,
                               UserPreferencesActivityRemindersPopup,
                               ReceivesAdminInfoEmails,
                               EmailPreferencesAutoBcc,
                               UserPreferencesDisableLikeEmail,
                               UserPreferencesEventRemindersCheckboxDefault,
                               UserPreferencesSortFeedByComment,
                               EmailPreferencesStayInTouchReminder,
                               UserPreferencesTaskRemindersCheckboxDefault,
                               IsPortalEnabled
                               
                               from user where id in: userId];
            
            for(user u : userToBeUpdated) {
                u.EmailPreferencesAutoBcc = false;
                u.UserPreferencesActivityRemindersPopup = false;
                u.ReceivesAdminInfoEmails = false;
                u.UserPreferencesDisableLikeEmail = false;
                u.UserPreferencesEventRemindersCheckboxDefault = false;
                u.UserPreferencesSortFeedByComment = false;
                u.EmailPreferencesStayInTouchReminder = false;
                u.UserPreferencesTaskRemindersCheckboxDefault = false;
                u.IsPortalEnabled = false;
            }
            
            //Update users
            if(userToBeUpdated.size() > 0) 
                update userToBeUpdated;
            
            
        }catch(Exception e) {
            system.debug('EXCEPTION: '+e.getMessage());
        }
        
    }


}