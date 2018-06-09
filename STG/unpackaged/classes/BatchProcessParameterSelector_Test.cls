@isTest
public class BatchProcessParameterSelector_Test {
   
    Public static testMethod void testGetBatchProcessParamRecords(){
        
         SelectorWrapper wrapper =  BatchProcessParameterSelector.getBatchProcessParamRecords();
        
        BatchProcessParameterSelector.DoFailTest = FALSE;
		SelectorWrapper selector1 = BatchProcessParameterSelector.GetBatchProcessParamRecords();
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(4,selector1.SObjectList.size());
        
        BatchProcessParameterSelector.DoFailTest = TRUE;
		SelectorWrapper selector2 = BatchProcessParameterSelector.GetBatchProcessParamRecords();
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage); 
		System.assertEquals(0, selector2.SObjectList.size());
        
    }

}