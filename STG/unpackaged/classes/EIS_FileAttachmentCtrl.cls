/**
*————————————————————————————————————————————————————
* @Name             EIS_FileAttachmentCtrl
* @Author           Duy Tran
* @Created Date     07-05-2017
* @Used By          EIS_FileAttachmentPage.vfp, EIS_FileAttachment.cmp
*————————————————————————————————————————————————————
* @Description
* Controller for uploading files
*————————————————————————————————————————————————————
* @Changes
*
**/
public without sharing class EIS_FileAttachmentCtrl {
	public transient ContentVersion cv;		// The content version to be inserted
    public ContentVersion getCv() {
        cv = new ContentVersion();
        return cv;
    }
    public Boolean fileUploadProcessed {get; set;}
    public String message {get; set;}
    public String messageType {get; set;}
    public String documentList {get; set;}
	
    // Method for inserting Content Version and Content Document
    public void uploadFile() {
        SavePoint sp = Database.setSavepoint();
        try {
            // Setting up content version for insertion
            String parentId = String.valueOf(ApexPages.currentPage().getParameters().get('id'));
            cv.PathOnClient = '/' + cv.Title;
            cv.Origin = 'H';
            insert cv;
			cv = [SELECT Id, Title, PathOnClient, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            
            // Linking the Content Version to its parent record
	        ContentDocumentLink cdl = new ContentDocumentLink();
	        cdl.LinkedEntityId = parentId; 
	        cdl.ContentDocumentId = cv.ContentDocumentId;
	        cdl.ShareType = 'V';
	        insert cdl;
			
	        messageType = 'success';
            message = 'File upload processed successful';
            // Retrieve list of files belong to the parent record
			documentList = JSON.serialize(getContentDocumentLinkList(parentId));
        } catch (Exception e) {
            message = e.getMessage();
            messageType = 'error';
            Database.rollback(sp);
        }
        fileUploadProcessed = true;
    } 
    
    // Method for retrieving all uploaded files for the parent record
    @AuraEnabled
    public static List<ContentDocumentLink> getContentDocumentLinkList(String parentId) {
        try {
            List<ContentDocumentLink> cdlList = [
                SELECT Id, ContentDocument.LatestPublishedVersionId, ContentDocument.Title, ContentDocumentId, ContentDocument.FileExtension 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :parentId 
                ORDER BY ContentDocument.Title
            ];
            for (ContentDocumentLink cdl : cdlList) {
                cdl.ContentDocument.Title = reduceStringLength(cdl.ContentDocument.Title);
            }
            
            return cdlList;
        } catch (Exception e){
            System.debug(e.getMessage());
        }
        return null;
    }
    
    // Method for deleting an uploaded file
    @AuraEnabled
    public static void deleteContentDocumentWithId(String documentId) {
        try {
            ContentDocumentLink cdl = new ContentDocumentLink(Id = documentId);
        	delete cdl;
        } catch (Exception e){
            System.debug(e.getMessage());
        }
    }
    
    // Method for formatting the name of the file to be displayed on the front end. Reducing it to 30 characters max.
    private static String reduceStringLength(String item) {
        if (String.isNotBlank(item) && item.length() > 30) {
            String left = item.substring(0, 17);
            String right = item.substring(item.length() - 13);
            item = left + '...' + right;
        }
        return item;
    }
}