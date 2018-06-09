@isTest
public class AccountSelector_Test {
	
	@TestSetup
    public static void loadTestData(){
    	Account a = new Account();
    	a.Name ='Account1';
    	insert a;

    	Contact c               = new Contact();
		c.LastName			    ='Employee'; 
		c.FirstName			    ='Amy'; 
		c.Personnel_Number__c   = 1234567;
		c.Email 				= 'test.test@amtrak.com';
		insert c; 

		EPW_Organization__c epwOrg = new EPW_Organization__c();
		epwOrg.RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID;
		epwOrg.EPW_Organization_Number__c = '12345';
		epwOrg.Name = 'Test';
		insert epwOrg;
    }

	

	public static testMethod void testgetAccountByName(){

        Set<String> orgNameSet = new Set<String>();
        
        AccountSelector.DoFailTest = FALSE;
		SelectorWrapper selector1 =AccountSelector.getAccountByName(new Set<String>{Label.RevSys_Generic_Amtrak});
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(0, selector1.SObjectList.size());
        
        AccountSelector.DoFailTest = TRUE;
		SelectorWrapper selector2 = AccountSelector.getAccountByName(new Set<String>{Label.RevSys_Generic_Amtrak});
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
		System.assertEquals(0, selector2.SObjectList.size());  
        
    }
}