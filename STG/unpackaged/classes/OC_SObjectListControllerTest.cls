/* 
TITLE: SOBJECT LIST CONTROLLER TEST
AUTHOR: NATHAN SHINN, DELOITTE DIGITAL

MODIFICATIONS
1.00: JANUARY 31, 2017: CREATED
2.00: March 6, 2017 Modified to support Alternate use
*/
@isTest
private class OC_SObjectListControllerTest {
	/**
     * Test 1 supply a query without a "WHERE" clause
     */
     static testMethod void test1() {
        //Create test records 
        Contact c = TestHandler.createTestContact('Test', null, null, '1');
        c.FirstName='Test';
        c.Email='Test@test.com';
        insert c;
         
        Contact c2 = TestHandler.createTestContact('Test2', null, null, '1');
        c.FirstName='Test2';
        c.Email='Tes2t@test.com';
        c.ReportsToId = c.Id;
        insert c2;
         
        String strQuery = 'SELECT Id, Name, ReportsTo.Name FROM CONTACT';
        
        Test.startTest();
        //execute the Controller Method
        OC_SObjectListController.sObjectWrapper r = OC_SObjectListController.fetchRecords(strQuery);
        Test.stopTest();
        
        //Verify Results
        System.assert(r.lstFieldApi.size() > 0);
        System.assert(r.lstFieldLabel.size() > 0);
        System.assert(r.lstSobject.size() > 0);
    }
    /**
     * Test 2 supply a query with a "WHERE" clause
     */
    static testMethod void test2() {
        //Create a test record 
        Contact c = TestHandler.createTestContact('Test', null, null, '1');
        c.FirstName='Test';
        c.Email='Test@test.com';
        insert c;
         
        Contact c2 = TestHandler.createTestContact('Test2', null, null, '1');
        c.FirstName='Test2';
        c.Email='Tes2t@test.com';
        c.ReportsToId = c.Id;
        insert c2;
         
        String strQuery = 'SELECT Id, Name, ReportsTo.Name FROM Contact WHERE Id = \''+c2.Id+'\'';
        
        Test.startTest();
        //execute the Controller Method
        OC_SObjectListController.sObjectWrapper r = OC_SObjectListController.fetchRecords(strQuery);
        Test.stopTest();
        
        //Verify Results 
        System.assert(r.lstFieldApi.size() > 0);
        System.assert(r.lstFieldLabel.size() > 0);
        System.assert(r.lstSobject.size() > 0);
    }
}