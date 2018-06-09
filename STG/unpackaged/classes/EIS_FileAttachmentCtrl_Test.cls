@isTest
public class EIS_FileAttachmentCtrl_Test {
    @testSetup static void setup() {
        try {
            EIS_TestDataUtils.insertCustomSettings();
        } catch (DMLException e) {
            
        }
    }
    
    @isTest
    public static void exceptionHanding_Test() {
        Test.startTest();
        Map<String, String> response = null;
        EIS_FileAttachmentCtrl.deleteContentDocumentWithId(null);
        
        List<ContentDocumentLink> cdlList = EIS_FileAttachmentCtrl.getContentDocumentLinkList(null);
        System.assert(cdlList == null); 
        
        EIS_FileAttachmentCtrl faCtrl = new EIS_FileAttachmentCtrl();
        faCtrl.cv = null;
        faCtrl.uploadFile();
        Test.stopTest();
    }
    
	@isTest
    public static void uploadFile_Test() {
		Finding__c finding = EIS_TestDataUtils.createInspectionFinding(null);
        Test.setCurrentPageReference(new PageReference('Page.EIS_FileAttachmentPage'));
        System.currentPageReference().getParameters().put('id', finding.Id);
        EIS_FileAttachmentCtrl faCtrl = new EIS_FileAttachmentCtrl();
        faCtrl.cv = faCtrl.getCv();
        faCtrl.cv.VersionData = Blob.valueOf('Hello Kitty Island Adventure');
        faCtrl.cv.Title = 'Hello Kitty and The Trial of Magic Mountain';
        
        Test.startTest();
        faCtrl.uploadFile();
        List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :finding.Id];
        if (cdlList != null && !cdlList.isEmpty()) {
            for (ContentDocumentLink cdl : cdlList) {
                EIS_FileAttachmentCtrl.deleteContentDocumentWithId(cdl.Id);
            }
        }
        Test.stopTest();
        
        cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :finding.Id];
        System.assert(cdlList.isEmpty());
	}
}