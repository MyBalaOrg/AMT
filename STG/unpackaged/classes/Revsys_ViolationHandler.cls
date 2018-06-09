/**
*___________________________________________________
*@Name: Revsys_ViolationHandler
*@Author: Mona Bhutada
*@Created: Date: 01/29/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Violation Handler for Review Systems Records 
* This is invoked by the extension and invokes the Helper for further logic.  
* Put the logic in a helper/utility class. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class Revsys_ViolationHandler extends TriggerHandler {
  
    public override void afterInsert() {  
        
        system.debug('HANDLER ViolationHandler afterInsert-Start');   

        String errorMsg; 

        errorMsg = RevSys_ViolationHelper.checkForTargetCreation(newList, null);

        ViolationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errorMsg);   

        system.debug('HANDLER ViolationHandler afterInsert-End');   
    }

    public override void afterUpdate() {  
        
        system.debug('HANDLER ViolationHandler afterUpdate-Start');   

        String errorMsg; 

        errorMsg = RevSys_ViolationHelper.checkForTargetCreation(newList, (Map<Id,Violation__c>)oldMap);

        ViolationStaticUtility.TriggerErrorMessage = StringUtility.cleanupMessage(errorMsg);   

        system.debug('HANDLER ViolationHandler afterUpdate-End');   
    }
  
}