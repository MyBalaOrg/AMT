/**
*————————————————————————————————————————————————————
* @Name             PermitTrigger_Test
* @Author           Kumar Suyash
* @Created Date     06-30-2017
* @Used By          Unit Test
*————————————————————————————————————————————————————
* @Description
* Test class for testing trigger logics on Permit object
* Coverage on PermitTriggerHandler.apxc and EIS_PermitTriggerHelper.apxc
*————————————————————————————————————————————————————
*
**/
@isTest
private class PermitTrigger_Test {
    @isTest static void insertTaskEmailFieldsInsrtOperation_Test() {
        Contact testContact = EIS_TestDataUtils.createInternalContact(null);
        Site__c testSite = EIS_TestDataUtils.createMainSite(null);
        Contact_List__c testContactList = EIS_TestDataUtils.createContactList(testContact, testSite, null);
        EmailTemplate newCompliance = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :Label.Email_Template_Site_Permit_Due_Date_Reminder];    
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_EMA);
        System.runAs(amtrakUser) {
            
            Permit_Plan__c testPermit = new Permit_Plan__c(
                EIS_Site__c = testSite.Id,
                EIS_Operating_Status__c = 'Active',
                EIS_6_Month_Update_Placeholder__c = datetime.newInstance(2017, 6, 25, 12, 30, 0),
                EIS_Type_of_Permit_Plan__c = 'Air Quality Permit',
                EIS_Jurisdiction__c = 'Federal',
                EIS_Issuing_Agency__c = 'Weyland',
                EIS_Internal_Contact__c = testContact.Id,
                EIS_Permit_Number__c = '12345',
                EIS_Permit_Plan_Sub_Category__c = 'Title V',
                EIS_Renewal_Date__c = Date.today().addDays(365)
            );
            
            Test.startTest();
            insert testPermit;
            testPermit.EIS_6_Month_Update_Placeholder__c = datetime.newInstance(2017, 6, 25, 22, 30, 0);
            update testPermit;
            
            new EIS_PermitTriggerHelper().sendEmailToSiteContactList(null);
            Test.stopTest();
            
        }
    }
}