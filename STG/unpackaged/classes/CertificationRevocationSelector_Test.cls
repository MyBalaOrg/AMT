@isTest
public class CertificationRevocationSelector_Test {
    
    public static testMethod void testGetActiveRevocationRecords(){
        CertificationRevocation__c certRev = new CertificationRevocation__c();
        Map<Id,EmployeeCertification__c> ecMap = new Map<Id,EmployeeCertification__c>();
        Map<Id,List<CertificationRevocation__c>> empCertRevocationMap = new Map<Id,List<CertificationRevocation__c>>();
        SelectorWrapper ecWrapper = EmployeeCertificationSelector.getEmpCertification(empCertRevocationMap.keySet());
        for(EmployeeCertification__c ecRec : (List<EmployeeCertification__c>) ecWrapper.sObjectList) {
                ecMap.put(ecRec.Id,ecRec);
            }
        SelectorWrapper revWrapper = CertificationRevocationSelector.getActiveRevocationRecords(ecMap.keySet(), 'IncidentDate__c', 'DESC');
        CertificationRevocationSelector.DoFailTest = FALSE;
        SelectorWrapper selector1 = CertificationRevocationSelector.getActiveRevocationRecords(ecMap.keySet(), 'IncidentDate__c', 'DESC');
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
        System.assertEquals(0,selector1.SObjectList.size());
        
        CertificationRevocationSelector.DoFailTest = TRUE;
        SelectorWrapper selector2 = CertificationRevocationSelector.getActiveRevocationRecords(ecMap.keySet(), 'IncidentDate__c', 'DESC');
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
        System.assertEquals(0, selector2.SObjectList.size());
        
    }
    
    public static testMethod void testGetCertRevocationbyEmpCertId(){
        Map<Id, EmployeeCertification__c> newEmpCertMap = new Map<Id, EmployeeCertification__c>();
        Set<Id> empCertIds = new Set<Id>();
         for(EmployeeCertification__c empCertObject : newEmpCertMap.values()) {
                empCertIds.add(empCertObject.Id);
            }
        SelectorWrapper certRevocationWrapper = CertificationRevocationSelector.getCertRevocationbyEmpCertId(empCertIds);
         CertificationRevocationSelector.DoFailTest = FALSE;
        SelectorWrapper selector1 = CertificationRevocationSelector.getCertRevocationbyEmpCertId(empCertIds);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
        System.assertEquals(0,selector1.SObjectList.size());
        
        CertificationRevocationSelector.DoFailTest = TRUE;
        SelectorWrapper selector2 = CertificationRevocationSelector.getCertRevocationbyEmpCertId(empCertIds);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
        System.assertEquals(0, selector2.SObjectList.size());
    }
}