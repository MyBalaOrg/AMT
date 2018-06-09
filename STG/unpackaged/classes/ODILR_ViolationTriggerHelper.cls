/*
Author: Raj Kumar Pandy
Description: The Helper Class for the ViolationsTrigger. The functionality of this class is to update the Disciplinary Violations List field on the Case object with the names of the Violation child records.
*/
public class ODILR_ViolationTriggerHelper {

    /*
    Method for updating the Violations field on the Case object
    */
    public static void UpdateCaseViolationList(List<Violation__c> ViolationList)
    {
        Set<Id> uniqueCaseIds = new Set<id>();
        List<Case> caseRecordsToBeUpdated = new List<Case>();
        Id violationRecordTypeId = Schema.SObjectType.Violation__c.getRecordTypeInfosByName().get(System.Label.ODILR_Discipline_Record_Type).getRecordTypeId(); 
        Id violationRecordTypeId1 = Schema.SObjectType.Violation__c.getRecordTypeInfosByName().get(System.Label.ODILR_Agreement_Issue_Record_Type).getRecordTypeId();

           //Exception Handler
            try
            {
                //Loop for fetching the Case ids related to the Violation record
            	for(Violation__c tempVl : ViolationList)
            	{
                	uniqueCaseIds.add(tempVl.ODILR_Case__c);
            	}
                
                //Checking if the set of CaseIDs is not null
                if(uniqueCaseIds!=NULL)
                {
                   for(Case caseRecord : [Select Id, Disciplinary_Violation_List__c,(Select id, ODILR_Violation__c, ODILR_Agreement_Issue__c, ODILR_Additional_Information__c from Case_Violations__r 
                                                                                     		WHERE RecordTypeId = :violationRecordTypeId OR RecordTypeId =:violationRecordTypeId1) from Case where Id IN : uniqueCaseIds])
               		{
                       caseRecord.Disciplinary_Violation_List__c = NULL;
                        
                   //Loop for updating the Violation List and Agreement Issue List fields with the child Violation record names
                   for(Violation__c tempVl : caseRecord.Case_Violations__r)
                   {
                       if(tempVl!=NULL)
                       {
                           //ARSS-215 - Rename Disciplinary Violations List combine both Violations and Agreement Issues,
                           //but the field either will have Violation issues or Agreement issues but not both.
                           if (tempVL.ODILR_Violation__c != NULL) {
                                if(caseRecord.Disciplinary_Violation_List__c==NULL)
                                	caseRecord.Disciplinary_Violation_List__c = tempVl.ODILR_Violation__c + '-' + tempVl.ODILR_Additional_Information__c;                            
                           		else
                                	caseRecord.Disciplinary_Violation_List__c = caseRecord.Disciplinary_Violation_List__c + ',' + tempVl.ODILR_Violation__c + '-' + tempVl.ODILR_Additional_Information__c ;
                           }
                               
                           else{
                               if (caseRecord.Disciplinary_Violation_List__c==NULL)
                                    caseRecord.Disciplinary_Violation_List__c = tempVl.ODILR_Agreement_Issue__c;
                                else
                                   caseRecord.Disciplinary_Violation_List__c = caseRecord.Disciplinary_Violation_List__c + ', '  + tempVl.ODILR_Agreement_Issue__c;                                                                                      
                           }
                       }
                   } 
                   caseRecordsToBeUpdated.add(caseRecord);                   
               }
                
               if(caseRecordsToBeUpdated.size() > 0)
               {
                   update caseRecordsToBeUpdated;
               }
             }  
           }
           Catch(Exception e)
           {
               system.debug('The Error message is '+e.getMessage()+' at line number '+e.getLineNumber());
           }
    }
}