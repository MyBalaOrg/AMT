@isTest
public class EIS_Inspection_MainHeaderCtrlTest {
    
    public static testMethod void testGetContentSize()
    {
        contact con = new Contact
            (
                LastName = 'Test',
                Email = 'Test@exampletest.com'
            );
        insert con;

        Route__c rout = new Route__c
            (
                Name = 'Test'
            );
        insert rout;
 
        Train__c trn = new Train__c
            (
                Name = '1324',
                Route__c = rout.Id
            );
        insert trn;

        Food_Car__c fc = new Food_Car__c
            (
                Name = '1000',
                EIS_Food_Car_Type__c = 'Diner',
                EIS_Train__c = trn.Id
            );
        insert fc;

        Audit_Inspections__c ai = new   Audit_Inspections__c
            (
                RecordTypeId = EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID,
                Inspected_By__c = con.Id,
                OBS_Train_Manager__c = con.Id,
                OBS_Train_Manager_Crew_Base__c = 'BOS',
                Date_and_Time__c = Datetime.now(),
                PH_Submission_Status__c = 'Submitted'
            );
        insert ai;
        
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = ai.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        System.assertEquals('Submitted', ai.PH_Submission_Status__c);
        EIS_Inspection_MainHeaderCtrl.getContentSize(ai.Id);
    }
    
}