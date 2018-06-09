@isTest
public class FieldConversionMapSelector_Test {
    
    public static testMethod void testGetByOrgUnitAndJobNumber(){
        Set<String> myJobCodeSet = new Set<String>();
        Set<String> myOrgUnitSet = new Set<String>();
        Set<Id> myOrgIdSet     = new Set<Id>(); 
        List<EPW_Position_Hierarchy__c> amPosHiList = new List<EPW_Position_Hierarchy__c>();
        Id myAmtrakOrgRecTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID; 
        
        SelectorWrapper myOrgSelWrap = EpwOrganizationSelector.getById(myOrgIdSet, myAmtrakOrgRecTypeId);
        
        for(EPW_Position_Hierarchy__c amPosHi :amPosHiList) { 
            myJobCodeSet.add(amPosHi.EPW_Job_Number__c); 
            myOrgIdSet.add(amPosHi.EPW_Position_Organization__c); 
        }
        for(EPW_Organization__c myOrg :(List<EPW_Organization__c>)myOrgSelWrap.SObjectList) {
                myOrgUnitSet.add(myOrg.EPW_Organization_Number__c); 
            }
   		SelectorWrapper myFieldConWrap = FieldConversionMapSelector.getByOrgUnitAndJobNumber(myJobCodeSet,myOrgUnitSet);
        
        FieldConversionMapSelector.DoFailTest = FALSE;
		SelectorWrapper selector1 = FieldConversionMapSelector.getByOrgUnitAndJobNumber(myJobCodeSet,myOrgUnitSet);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(0,selector1.SObjectList.size());
        
        FieldConversionMapSelector.DoFailTest = TRUE;
		SelectorWrapper selector2 = FieldConversionMapSelector.getByOrgUnitAndJobNumber(myJobCodeSet,myOrgUnitSet);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
		System.assertEquals(0, selector2.SObjectList.size());
        
    }
    

}