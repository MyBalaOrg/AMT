@isTest
private class StationAuditTypePicklist_Test {
	
    static testMethod void getDefaultValueTest() {
        StationAuditTypePicklist sa1 = new StationAuditTypePicklist();
        
        Test.startTest();
        sa1.getDefaultValue();
        Test.stopTest();
    }
    
    static testMethod void getValuesTest() {
        StationAuditTypePicklist sa2 = new StationAuditTypePicklist();
        
        Test.startTest();
        sa2.getValues();
        Test.stopTest();
    }    
}