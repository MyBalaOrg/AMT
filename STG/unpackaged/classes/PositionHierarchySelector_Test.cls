/**
*___________________________________________________
*@Name: 	PositionHierarchySelector_Test
*@Author: 	Raj Kumar Pandy
*@Created: 	Date: 12/11/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Test for PositionHierarchySelector
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

@isTest
public class PositionHierarchySelector_Test {
    
    public static testmethod void PosHrSelectorTest(){
        Test.startTest();
        
            String myQuery = PositionHierarchySelector.getPosHrQueryString();
            List<EPW_Position_Hierarchy__c> posHrSet = [Select Id,EPW_Parent_Position_Hierarchy__c from EPW_Position_Hierarchy__c ];
            Set<Id> phId = new Set<Id>();
            for(EPW_Position_Hierarchy__c ph : posHrSet){
                phId.add(ph.Id);
            }
            SelectorWrapper getPos = PositionHierarchySelector.getPositionHierarchyById(phId);
            PositionHierarchySelector.doFailTest = true;
            getPos = PositionHierarchySelector.getPositionHierarchyById(phId);
       
            
        Test.stopTest();
    }   

	
    
}