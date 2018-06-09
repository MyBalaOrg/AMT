@isTest
public class AuditSummaryReportControllerTest {
    
    static testmethod void testGetCategoryPicklistValues() {
        AuditSummaryReportController aR= new AuditSummaryReportController();
        List<String> catValues = aR.getCategoryPicklistValues();
        System.assert(catValues.size() > 0);
    }
    
    static testMethod void testSettersGetters() {
        List<AuditSummaryReportController.findingWrapperClass> tempList = new List<AuditSummaryReportController.findingWrapperClass>();
        AuditSummaryReportController aR= new AuditSummaryReportController();
        for(Integer i = 0;i<5;i++) {
            AuditSummaryReportController.findingWrapperClass fw = new AuditSummaryReportController.findingWrapperClass();
            fw.caseID = '';
            fw.Category = 'test'+i;
            fw.compliantCount = '5';
            fw.nonCompliantCount = '5';
            tempList.add(fw);
        }
        
        ar.setFindingWrapperList(tempList);
        List<AuditSummaryReportController.findingWrapperClass> testList = ar.getFindingWrapperList();
        system.assert(testList.size() > 0);
      
        ar.setAuditID('testID');
        String Id = ar.getAuditID();
        System.assertEquals('testID', Id);
        
    }
    
    static testmethod void testAggregation() {
        AuditSummaryReportController aR= new AuditSummaryReportController();
        List<RecordType> recTypes = [select id from recordtype where developername = 'Station_Audit' AND sobjecttype = 'Audit_Inspections__c'];
    	String auditRecTypeId = recTypes.get(0).Id;
        
        List<RecordType> recTypes1 = [select id from recordtype where developername = 'Station_Audit' AND sobjecttype = 'Finding__c'];
    	String findingRecTypeId = recTypes1.get(0).Id;
        
        Station__c st = new Station__c();
        st.Name = 'testStation';
        insert st;
        
        Audit_Inspections__c aI = new Audit_Inspections__c();
       aI.Comments__c = 'testComments';
        aI.RecordTypeId = auditRecTypeId;
        aI.Status__c = 'Submitted';
        aI.Station__c = st.Id;
        insert aI;
        
        Finding__c f1 = new Finding__c();
        f1.RecordTypeId = findingRecTypeId;
        f1.Category__c = 'A. APPROACH TO THE STATION';
        f1.Sub_category__c = 'testSubCat1';
        f1.IsCompliant__c = 'Yes';
        f1.Audit__c = aI.Id;
        insert f1;
        
        
        Finding__c f2 = new Finding__c();
        f2.RecordTypeId = findingRecTypeId;
        f2.Category__c = 'A. APPROACH TO THE STATION';
        f2.Sub_category__c = 'testSubCat2';
        f2.IsCompliant__c = 'No';
        f2.Audit__c = aI.Id;
        insert f2;
        
        Finding__c f4 = new Finding__c();
        f4.RecordTypeId = findingRecTypeId;
        f4.Category__c = 'B. PARKING AREA';
        f4.Sub_category__c = 'testSubCat1';
        f4.IsCompliant__c = 'Yes';
        f4.Audit__c = aI.Id;
        insert f4;
        
        
        Finding__c f3 = new Finding__c();
        f3.RecordTypeId = findingRecTypeId;
        f3.Category__c = 'B. PARKING AREA';
        f3.Sub_category__c = 'testSubCat2';
        f3.IsCompliant__c = 'Yes';
        f3.Audit__c = aI.Id;
        insert f3;
        
        Finding__c f5 = new Finding__c();
        f5.RecordTypeId = findingRecTypeId;
        f5.Category__c = 'C. SITE/STATION STRUCTURE EXTERIOR';
        f5.Sub_category__c = 'testSubCat1';
        f5.IsCompliant__c = 'N/A';
        f5.Audit__c = aI.Id;
        insert f5;
        
        
        Finding__c f6 = new Finding__c();
        f6.RecordTypeId = findingRecTypeId;
        f6.Category__c = 'C. SITE/STATION STRUCTURE EXTERIOR';
        f6.Sub_category__c = 'testSubCat2';
        f6.IsCompliant__c = 'N/A';
        f6.Audit__c = aI.Id;
        insert f6;
        
        Finding__c f7 = new Finding__c();
        f7.RecordTypeId = findingRecTypeId;
        f7.Category__c = 'D. STATION STRUCTURE INTERIOR - WAITING ROOM';
        f7.Sub_category__c = 'testSubCat1';
        f7.IsCompliant__c = 'No';
        f7.Audit__c = aI.Id;
        insert f7;
        
        
        Finding__c f8 = new Finding__c();
        f8.RecordTypeId = findingRecTypeId;
        f8.Category__c = 'D. STATION STRUCTURE INTERIOR - WAITING ROOM';
        f8.Sub_category__c = 'testSubCat2';
        f8.IsCompliant__c = 'N/A';
        f8.Audit__c = aI.Id;
        insert f8;
        
        
        aR.setAuditID(aI.Id);
        
        
    }

}