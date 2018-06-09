/**
*————————————————————————————————————————————————————
* @Name             TaskTrigger_Test
* @Author           Kumar Suyash
* @Created Date     05-11-2017
* @Used By          Unit Test
*————————————————————————————————————————————————————
* @Description
* Test class for testing trigger logics on Task object
* Coverage on TaskTriggerHandler.apxc and EIS_TaskTriggerHelper.apxc
*————————————————————————————————————————————————————
**/

@isTest
private class TaskTrigger_Test {
    
    @isTest static void insertTaskEmailFieldsInsrtOperation_Test() {
        Contact testContact = EIS_TestDataUtils.createInternalContact(null);
        Site__c testSiteRecord = EIS_TestDataUtils.createMainSite(null);
        
        permit_Plan__c testPermit = new Permit_Plan__c(
            EIS_Site__c = testSiteRecord.Id,
            EIS_Permit_Plan_Name__c = 'Permit 1',
            EIS_Operating_Status__c = 'Active',
            EIS_Type_of_Permit_Plan__c = 'Air Quality Permit',
            EIS_Jurisdiction__c = 'Federal',
            EIS_Issuing_Agency__c = 'Weyland',
            EIS_Internal_Contact__c = testContact.Id,
            EIS_Permit_Number__c = '12345',
            EIS_Permit_Plan_Sub_Category__c = 'Title V',
            EIS_Renewal_Date__c = Date.today().addDays(365),
            RecordTypeId = EIS_StaticUtils.PERMIT_PLAN_MAIN_RTID
        );
        insert testPermit;
        
        Task firstTaskRecord = new Task(
            Subject = 'Test Task Site 1'
        );
        insert firstTaskRecord;
        firstTaskRecord.WhatId = null;
        firstTaskRecord.WhoId = null;
        update firstTaskRecord;
    }
    
    @isTest static void updateTaskEmailFieldsUpdateOperation_Test() {
        Account acc = new Account(Name = 'Suyash Barnwal');
        insert acc;
        
        Contact testContact = new Contact(LastName = 'Suyash', Account = acc,Employee_type__c = 'Internal');
        insert testContact;    
        
        Contact testContact1 = EIS_TestDataUtils.createInternalContact(null);
        
        Site__c testSiteRecord = EIS_TestDataUtils.createMainSite(null);
        
        permit_Plan__c testPermit = new Permit_Plan__c(
            RecordTypeId = EIS_StaticUtils.PERMIT_PLAN_MAIN_RTID,
            EIS_Site__c = testSiteRecord.Id,
            EIS_Permit_Plan_Name__c = 'Permit 1',
            EIS_Operating_Status__c = 'Active',
            EIS_Type_of_Permit_Plan__c = 'Air Quality Permit',
            EIS_Jurisdiction__c = 'Federal',
            EIS_Issuing_Agency__c = 'Weyland',
            EIS_Internal_Contact__c = testContact.Id,
            EIS_Permit_Number__c = '12345',
            EIS_Permit_Plan_Sub_Category__c = 'Title V',
            EIS_Renewal_Date__c = Date.today().addDays(365),
            EIS_Contact_1__c = testContact.Id, 
            EIS_Contact_2__c = testContact.Id, 
            EIS_Contact_3__c = testContact.Id, 
            EIS_Contact_4__c = testContact.Id, 
            EIS_Contact_5__c = testContact.Id  
            
        );
        insert testPermit;
        testPermit.EIS_Contact_1__c = testContact1.Id;
        testPermit.EIS_Contact_2__c = testContact1.Id; 
        testPermit.EIS_Contact_3__c = testContact1.Id;
        testPermit.EIS_Contact_4__c = testContact1.Id; 
        testPermit.EIS_Contact_5__c = testContact1.Id;
        testPermit.EIS_Permit_Number__c = '12345';
        update testPermit;
        
        Task secondTaskRecord = new Task(
            Subject = 'Test Task Site 1',
            WhoId = testContact.Id,
            WhatId = testPermit.Id
        );
        insert secondTaskRecord;
        secondTaskRecord.WhatId = testPermit.Id;
        secondTaskRecord.Subject = 'Test Task Site 2';
        secondTaskRecord.WhoId = testContact1.Id;
        update secondTaskRecord;
    }
    
}