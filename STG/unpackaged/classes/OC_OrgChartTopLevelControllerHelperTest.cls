@isTest(SeeAllData=False)
public class OC_OrgChartTopLevelControllerHelperTest {
     @testSetup static void setup() {
        Organization_Chart__c orgChart = new Organization_Chart__c();
        orgChart.Name = 'OrgChartData';
        orgChart.Advanced_Search_URL__c = 'advanced search url';
        orgChart.Export_All_URL__c = 'export All URL';
        orgChart.Origin_Tile_Title__c = 'Amtrak Summary';
        insert orgChart;
    }
    
     //Test method downloadDocument
    static testmethod void testDownloadDocument() {
        Document document;
        
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'My Document';
        document.FolderId = [select id from folder where name = 'Test Folder'].id;
        insert document;
        
        String url = OC_OrgChartTopLevelApexControllerHelper.getJobAidDoc('My Document');
        System.assert(url!=null);
    }
    
    //Unit Test for method getActiveStatuses
    static testmethod void testactiveStatus() {
     List<String> activeStatus = new List<String>();
     activeStatus = OC_OrgChartTopLevelApexControllerHelper.getActiveStatuses();   
    }
    
    //Unit Test for method getTerminatedStatuses
    static testmethod void testTerminatedStatus() {
       List<String> terminatedStatus = new List<String>();
     terminatedStatus = OC_OrgChartTopLevelApexControllerHelper.getTerminatedStatuses();   
    
    }
    
       
    //Tests retrieveSearchUrl method to make sure it doesn't return null
    static testmethod void testretrieveReportURL() {
        String url = OC_OrgChartTopLevelApexControllerHelper.exportAllURL();
        System.assertEquals('export All URL', url);
        
    }
    
     static testmethod void testGetObjectName() {
        String pre = '003';
        String objName =  OC_OrgChartTopLevelApexControllerHelper.findObjectNameFromRecordIdPrefix(pre);
         System.assertEquals('Contact', objName);
    }
    
    static testmethod void testGetContact() {
        Account newAccount = new Account(Name='Account');
        insert newAccount;
        
        Contact managerContact = new Contact(LastName='Manager', AccountId= newAccount.Id,Employment_Status__c= 'Active');
        insert managerContact;
        
        OC_OrgChartTopLevelApexControllerHelper.getContact(managerContact.id);
        system.assert(managerContact!=null);
    }

}