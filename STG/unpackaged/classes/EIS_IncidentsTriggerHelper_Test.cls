@isTest
public class EIS_IncidentsTriggerHelper_Test {
	@testSetup static void setup() {
        try {
            EIS_TestDataUtils.getBypassTriggerSettings();
        } catch (DMLException e) {
            
        }
    }
    
    @isTest 
    public static void sendEmailToSiteContactList_AfterInsert_Test() {
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_EMA);
        System.runAs(amtrakUser) {
            Site__c site = EIS_TestDataUtils.createMainSite(null);
        	Contact_List__c cont = EIS_TestDataUtils.createContactList(null, site, null);
            Incidents__c incident = new Incidents__c(
            	RecordTypeId = Schema.SObjectType.Incidents__c.getRecordTypeInfosByName().get('Compliance Action Main').getRecordTypeId(),
                EIS_Site__c = site.Id, EIS_Date_of_Action__c = Date.today(), EIS_Agency_Name__c = 'Dry Tuna', EIS_Agency_Type__c = 'Federal', EIS_Status__c = 'Open',
                EIS_Action_Type__c = 'Inspection', EIS_Action_Sub_Type__c = 'Routine', EIS_Detailed_Description__c = 'Dry Tuna', EIS_Program_Area__c = 'Dry Tuna',
                EIS_Verbal_Notification__c = Date.today(), EIS_Written_Notification__c = Date.today()
            );
            Test.startTest();
            upsert incident;
            new EIS_IncidentsTriggerHelper().sendEmailToSiteContactList_AfterInsert(null);
            Test.stopTest();
        }
    }
}