@isTest
public class AMTRAK_Case_RecordTypeCheckTest {
    @isTest
    public static void verifyAppNameForCase_New_Test() {
        List<Schema.RecordTypeInfo> infos = Case.SObjectType.getDescribe().getRecordTypeInfos();
        Map<String, String> response;
        
        Test.startTest();
        for (Schema.RecordTypeInfo info : infos) {
            if (info.isAvailable() && !info.isMaster()) {
                response = new Map<String, String>();
                response = AMTRAK_Case_RecordTypeCheck.verifyAppNameForCase_New(info.getRecordTypeId());
                System.assert(String.isNotBlank(response.get('recordTypeName')));
                System.assert(response.get('appName') != null);
            }
        }
        response = AMTRAK_Case_RecordTypeCheck.verifyAppNameForCase_New(null);
        Test.stopTest();
    }
    
    @isTest
    public static void verifyAppNameForCase_Edit_Test() {
        Account account = TestHandler.createAccount('testAccount');
        insert account;
            
        Contact contact = TestHandler.createTestContact('TestLastName', account.id, null, null);
        insert contact;
        
        ODILR_Hierarchy_Setting__c cs = ODILR_Hierarchy_Setting__c.getOrgDefaults();
        cs.ODILR_Mulesoft_API_CID__c = '6f90b6663d40454a9b9a973d34164a46';
        cs.ODILR_Mulesoft_API_CSEC__c = 'EaB2983de66045e2a6D3da358bf4Bf1d';
        cs.ODILR_Mulesoft_API_Endpoint__c = 'https://dev-api.amtrak.com/sfdc-doc/folders/folder';
        cs.ODILR_MuleSoft_API_Timeout__c = 5000;
        upsert cs;
        
        List<Case> testCases = new List<Case>();
        List<Schema.RecordTypeInfo> infos = Case.SObjectType.getDescribe().getRecordTypeInfos();
        for (Schema.RecordTypeInfo info : infos) {
            if (info.isAvailable() && !info.isMaster()) {
                testCases.add(new Case(
                    AccountId = account.Id,
                    Case_Level__c = 'Level 1',
                    ContactId = contact.Id,
                    RecordTypeId = info.getRecordTypeId(),
                    ODILR_ODI_Number__c = '12345' + info.getRecordTypeId(),
                    Incident_Date__c = Date.today(),
                    Describe_Offense__c = 'Test offense',
                    Charge_Date__c = Date.today()
                ));
            }
        }
        insert testCases;
        Map<String, String> response;
        
        Test.startTest();
        for (Case testCase : testCases) {
            response = new Map<String, String>();
            response = AMTRAK_Case_RecordTypeCheck.verifyAppNameForCase_Edit(testCase.Id);
            System.assert(String.isNotBlank(response.get('recordTypeName')));
            System.assert(response.get('appName') != null);
        }
        response = AMTRAK_Case_RecordTypeCheck.verifyAppNameForCase_New(null);
        Test.stopTest();
    }
}