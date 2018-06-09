@isTest
public class BatchSchedule_ODILRDocumentumIntg_Test {

    public static testmethod void batchTest()
    {
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employeech@test.com');
        insert employee;
        
        ODILR_Hierarchy_Setting__c cs = ODILR_Hierarchy_Setting__c.getOrgDefaults();
        cs.ODILR_Mulesoft_API_CID__c = '6f90b6663d40454a9b9a973d34164a46';
        cs.ODILR_Mulesoft_API_CSEC__c = 'EaB2983de66045e2a6D3da358bf4Bf1d';
        cs.ODILR_Mulesoft_API_Endpoint__c = 'https://dev-api.amtrak.com/sfdc-doc/folders/folder';
        cs.ODILR_MuleSoft_API_Timeout__c = 5000;
        cs.ODILR_MuleSoft_Batch_Size__c = 50;  
        upsert cs;
        
        List<RecordType> caseDecRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];
        
        List<Case> caseList = new List<Case>();
        List<Integration_Log__c> logList = new List<Integration_Log__c>();
        
        Case testDiscCaseObj = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase', 
                                         ODILR_ODI_Number__c = '123',
                                         Incident_Date__c = Date.Today(),
                                         Charge_Date__C = Date.Today(), 
                                         No_Of_Case_Violations__c = 1,
                                         Describe_Offense__c = 'Test offense',
                                         RecordTypeId = caseDecRecList[0].Id);
        caseList.add(testDiscCaseObj);        
        Case testDiscCaseObj1 = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase1', 
                                         ODILR_ODI_Number__c = '124',
                                         Incident_Date__c = Date.Today(),
                                         Charge_Date__C = Date.Today(), 
                                         No_Of_Case_Violations__c = 1,
                                         Describe_Offense__c = 'Test offense',
                                         RecordTypeId = caseDecRecList[0].Id);
        caseList.add(testDiscCaseObj1);
        Case testDiscCaseObj2 = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase2', 
                                         ODILR_ODI_Number__c = '125',
                                         Incident_Date__c = Date.Today(),
                                         Charge_Date__C = Date.Today(), 
                                         No_Of_Case_Violations__c = 1,
                                         Describe_Offense__c = 'Test offense',
                                         RecordTypeId = caseDecRecList[0].Id);
        caseList.add(testDiscCaseObj2);  
        insert caseList;
        for(Integer i=0 ;i<3;i++)
        {
            Integration_Log__c tempObj = new Integration_Log__c();
            tempObj.Error_Code__c = 400;            
            tempObj.Message_Type__c = 'Documentum-Mulesoft';
            tempObj.Status__c = 'Failure';             
            tempObj.Retry_Status__c = 'Failure';
            tempObj.Internal_Record_ID__c = caseList[i].id;
            logList.add(tempObj);
        }
        insert logList;
        
        Test.startTest();
        Batch_ODILR_DocumentumIntegration batchClassObj = new Batch_ODILR_DocumentumIntegration();
        database.executebatch(batchClassObj,90);
        Test.stopTest();
        
    }
    public static testmethod void schedulerTest()
    {
        ODILR_Hierarchy_Setting__c cs = ODILR_Hierarchy_Setting__c.getOrgDefaults();
        cs.ODILR_Mulesoft_API_CID__c = '6f90b6663d40454a9b9a973d34164a46';
        cs.ODILR_Mulesoft_API_CSEC__c = 'EaB2983de66045e2a6D3da358bf4Bf1d';
        cs.ODILR_Mulesoft_API_Endpoint__c = 'https://dev-api.amtrak.com/sfdc-doc/folders/folder';
        cs.ODILR_MuleSoft_API_Timeout__c = 5000;
        cs.ODILR_MuleSoft_Batch_Size__c = 50;  
        upsert cs;
        
        BatchSchedule_DocumentumIntegration scheduleObj = new BatchSchedule_DocumentumIntegration();
        String sch = '1 0 23 * * ?';
        Test.startTest();
        system.schedule('Test Schedule', sch, scheduleObj);
        Test.stopTest();
    }
}