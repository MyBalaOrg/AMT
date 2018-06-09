/* 
TITLE: SOBJECT SEARCH CONTROLLER TEST
AUTHOR: NATHAN SHINN, DELOITTE DIGITAL

USED BY: SObject Serch Component

MODIFICATIONS
1.00: JANUARY 31, 2017: CREATED
2.00: March 6, 2017 Modified to support Alternate use

*/
@isTest(SeeAllData=False)
private class OC_SObjectSearchControllerTest {
    /**
     * Test 1 run the generic search followed by the specific, Position Search
     */
    static testMethod void test1() {
        
        
        //create test data
        Account a = TestHandler.createAccount('Account');
        insert a;
        Position__c p = TestHandler.createTestPosition('Title','MANAGEID');
        p.Organization_Unit_Name__c='Title';
        insert p;
        Position__c p2 = TestHandler.createTestPosition('Title2', '111112');
        p2.Organization_Unit_Name__c='Title2';
        insert p2;
        Contact c = TestHandler.createTestContact('Manager', a.Id, p.Id, '1');
        insert  c;
        Contact c1 = TestHandler.createTestContact('Manager', a.Id, null, '1');
        insert  c1;
        
        //need to seed the test data when using SOSL
        Id[] fixedSearchResults= new Id[4];
        fixedSearchResults[0] = c.Id;
        fixedSearchResults[1] = p.Id;
        fixedSearchResults[2] = p2.Id;
        fixedSearchResults[3] = c1.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        //execute generic search Method
        OC_SObjectSearchController.Result[] r = OC_SObjectSearchController.lookup('Test', 'Contact','Id,LastName'.split(','));
        
        //execute specific, Employee search Method
        
        //create the search custom setting records
        list<OC_Component_FieldList__c> settings = new list<OC_Component_FieldList__c>();
        settings.add(TestHandler.createComponentFieldList('Name'
                                                          ,1
                                                          ,'Name'
                                                          ,'Contact'
                                                          ,'OrgChartEmployeeSearch'
                                                          ,'1'));
        settings.add(TestHandler.createComponentFieldList('Org Id'
                                                          ,1
                                                          ,'Position_Id__c'
                                                          ,'Position__c'
                                                          ,'OrgChartEmployeeSearch'
                                                          ,'2'));
        settings.add(TestHandler.createComponentFieldList('Org Unit'
                                                          ,1
                                                          ,'Organization_Unit_Name__c'
                                                          ,'Position__c'
                                                          ,'OrgChartEmployeeSearch'
                                                          ,'3'));
        
        insert settings;
        
        OC_SObjectSearchController.lookupEmployeePosition('Title');
        OC_SObjectSearchController.lookupEmployeePosition('Manager');
        
        Test.stopTest();
        
        //Verify Results
        System.assert(r.size() > 0);
        System.assert(r[0].SObjectId == c.Id);
    
    }
	
}