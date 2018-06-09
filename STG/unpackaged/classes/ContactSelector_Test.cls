@isTest
public class ContactSelector_Test {
    public static testMethod void testGetContacts(){
        Set<Id> contactIdSet = new Set<Id>();
        List<EmployeeCertification__c> newEmpCertList = new List<EmployeeCertification__c>();
        for(EmployeeCertification__c ecObj : newEmpCertList) {
             contactIdSet.add(ecObj.Employee__c);
        }
        SelectorWrapper wrapper = ContactSelector.getContacts(contactIdSet);
        
        ContactSelector.DoFailTest = FALSE;
		SelectorWrapper selector1 = ContactSelector.getContacts(contactIdSet);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(0,selector1.SObjectList.size());
        
        ContactSelector.DoFailTest = TRUE;
		SelectorWrapper selector2 = ContactSelector.getContacts(contactIdSet);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
		System.assertEquals(0, selector2.SObjectList.size());       
    }
    
    public static testMethod void testGetPositionIdFromContactId(){
        List<Id> contactIdList = new List<Id>();
        List<EmployeeCertification__c> newEmpCertList = new List<EmployeeCertification__c>();
        for(EmployeeCertification__c ecObj : newEmpCertList) {
             contactIdList.add(ecObj.Employee__c);
        }
        SelectorWrapper wrapper = ContactSelector.getPositionIdFromContactId(contactIdList);
        
        ContactSelector.DoFailTest = FALSE;
		SelectorWrapper selector1 = ContactSelector.getPositionIdFromContactId(contactIdList);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(0,selector1.SObjectList.size());
        
        ContactSelector.DoFailTest = TRUE;
		SelectorWrapper selector2 = ContactSelector.getPositionIdFromContactId(contactIdList);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
		System.assertEquals(0, selector2.SObjectList.size());       
    }
	
    public static testMethod void testGetContactsBySAPId(){
        Set<String> myUserEmployeeNumberList = new Set<String>();
        List<User> UserList = new List<User>();
        for(User Us : UserList){
             Integer tmp = Integer.valueOf(Us.EmployeeNumber);
                    myUserEmployeeNumberList.add(String.valueOf(tmp));
        }
        SelectorWrapper contactwrapper = ContactSelector.getContactsBySAPId(myUserEmployeeNumberList);
         ContactSelector.DoFailTest = FALSE;
		SelectorWrapper selector1 = ContactSelector.getContactsBySAPId(myUserEmployeeNumberList);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(0,selector1.SObjectList.size());
        
        ContactSelector.DoFailTest = TRUE;
		SelectorWrapper selector2 = ContactSelector.getContactsBySAPId(myUserEmployeeNumberList);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
		System.assertEquals(0, selector2.SObjectList.size());
    }
    
    public static testMethod void testgetContactsByDept(){
        Set<String> myDeptSet = new Set<String>();
        List<OccupationCertification__c> newOccCerList = new List<OccupationCertification__c>();
        for(OccupationCertification__c occCertObj : newOccCerList){
            myDeptSet.add(occCertObj.Department__c);
        }
         SelectorWrapper wrapper = ContactSelector.getContactsByDept(myDeptSet);
         ContactSelector.DoFailTest = FALSE;
		SelectorWrapper selector1 = ContactSelector.getContactsByDept(myDeptSet);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(0,selector1.SObjectList.size());
        
        ContactSelector.DoFailTest = TRUE;
		SelectorWrapper selector2 = ContactSelector.getContactsByDept(myDeptSet);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
		System.assertEquals(0, selector2.SObjectList.size());
    }
    
    public static testMethod void testGetContactIdFromPosition(){
         List<Id> contactIdList = new List<Id>();
        List<EmployeeCertification__c> newEmpCertList = new List<EmployeeCertification__c>();
        for(EmployeeCertification__c ecObj : newEmpCertList) {
             contactIdList.add(ecObj.Employee__c);
        }
         SelectorWrapper wrapper = ContactSelector.getContactIdFromPosition(contactIdList);
         ContactSelector.DoFailTest = FALSE;
		SelectorWrapper selector1 = ContactSelector.getContactIdFromPosition(contactIdList);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(0,selector1.SObjectList.size());
        
        ContactSelector.DoFailTest = TRUE;
		SelectorWrapper selector2 = ContactSelector.getContactIdFromPosition(contactIdList);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
		System.assertEquals(0, selector2.SObjectList.size());
    }
    
   public static testMethod void testGetContactsById(){
        Set<Id> contactIdSet = new Set<Id>();
        List<EmployeeCertification__c> newEmpCertList = new List<EmployeeCertification__c>();
        for(EmployeeCertification__c ecObj : newEmpCertList) {
             contactIdSet.add(ecObj.Employee__c);
        }
        SelectorWrapper wrapper = ContactSelector.getContactsById(contactIdSet);
        
        ContactSelector.DoFailTest = FALSE;
		SelectorWrapper selector1 = ContactSelector.getContactsById(contactIdSet);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(0,selector1.SObjectList.size());
        
        ContactSelector.DoFailTest = TRUE;
		SelectorWrapper selector2 = ContactSelector.getContactsById(contactIdSet);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
		System.assertEquals(0, selector2.SObjectList.size());       
    }
}