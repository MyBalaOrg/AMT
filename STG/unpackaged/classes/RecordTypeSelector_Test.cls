/**
*___________________________________________________
*@Name:     RecordTypeSelector_Test
*@Author:   Vaibhav Athikam
*@Created:  Date: April 10, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for RecordTypeSelector
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class RecordTypeSelector_Test {

    public static testMethod void selectActiveRecordTypesTest(){
        
        RecordTypeSelector RecTypeSel = new RecordTypeSelector('Contact','Name'); 
        RecTypeSel.DoFailTest = FALSE;
        SelectorWrapper mySelWrap = RecTypeSel.selectActiveRecordTypes(); 
        System.debug('Error message '+ mySelWrap.ErrorMessage);
        System.assertNotEquals(null, mySelWrap.SObjectList.size());
        
        RecordTypeSelector RecTypeSelector = new RecordTypeSelector(null,'Name'); 
        RecTypeSelector.DoFailTest = TRUE;
        SelectorWrapper mySelWrap1 = RecTypeSelector.selectActiveRecordTypes(); 
        System.debug('Error message '+ mySelWrap1.ErrorMessage);
        System.assertNotEquals(null, mySelWrap1.ErrorMessage);
        
    }
    
    public static testMethod void selectAllActiveRecordTypesTest(){
        
        RecordTypeSelector RecTypeSel = new RecordTypeSelector('Contact','Name'); 
        SelectorWrapper mySelWrap = RecTypeSel.selectAllActiveRecordTypes(); 
        System.debug('Error message '+ mySelWrap.ErrorMessage);
        System.assertNotEquals(null, mySelWrap.SObjectList.size());
        
        RecordTypeSelector RecTypeSelector = new RecordTypeSelector(null,'Name'); 
        RecTypeSelector.DoFailTest = TRUE;
        SelectorWrapper mySelWrap1 = RecTypeSelector.selectAllActiveRecordTypes(); 
        System.debug('Error message '+ mySelWrap1.ErrorMessage);
        System.assertNotEquals(null, mySelWrap1.ErrorMessage);
        
    }
    
}