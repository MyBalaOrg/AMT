@isTest
private class FileUploadCtrl_Test {

    static testMethod void testFileUpload() {
        Finding__c f = new Finding__c();
        f.RecordTypeId = Schema.SObjectType.Finding__c.getRecordTypeInfosByName().get('Station Audit').getRecordTypeId();
        insert f;
        
        FileUploadCtrl.saveTheChunk(f.Id, 'testFile', 'testData', 'text/plain', '');
        List<Attachment> attachments = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId =: f.Id];
        System.assertEquals('testFile', attachments.get(0).Name);
        
        
        FileUploadCtrl.saveTheChunk(f.Id,'testFile','chunk01','text/plain',attachments.get(0).id);
        
    }
}