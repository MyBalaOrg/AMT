/*
Author: Raj Kumar Pandy
Description: The Helper Class for the ViolationsTrigger. The functionality of this class is to update the Disciplinary Violations List field on the Case object with the names of the Violation child records.
*/
public class ODILR_DisciplinaryActionsTriggerHelper {

    /*
    Method for updating the Violations field on the Case object
    */
    public static void UpdateCaseDisciplinaryActionsList(List<Disciplinary_Action__c> DiscActionsList)
    {
        Set<Id> uniqueCaseIds = new Set<id>();
        List<Case> caseRecordsToBeUpdated = new List<Case>();

           //Exception Handler
            try
            {
                //Loop for fecthing the Case ids related to the Violation record
                for(Disciplinary_Action__c tempda : DiscActionsList)
                {
                    uniqueCaseIds.add(tempda.ODILR_Case__c);
                }
                
                //Checking if the set of CaseIDs is not null
                if(uniqueCaseIds!=NULL)
                {
                   for(Case caseRecord : [Select Id, Discipline_Assessed_List__c ,(Select id, ODILR_Discipline_Assessed__c, ODILR_No_Of_Days__c, ODILR_Appellate_Modification__c, ODILR_LR_Of_Days__c from Case_Discipline__r) from Case where Id IN : uniqueCaseIds])
                   {
                       caseRecord.Discipline_Assessed_List__c = NULL;
                       //Loop for updating the Violation List field with the child Violation record names
                       for(Disciplinary_Action__c tempda : caseRecord.Case_Discipline__r)
                       {
                           if(tempda != NULL)
                           {
                               if(caseRecord.Discipline_Assessed_List__c ==NULL && tempda.ODILR_Discipline_Assessed__c != NULL)
                                   caseRecord.Discipline_Assessed_List__c = tempda.ODILR_Discipline_Assessed__c + '*' + tempda.ODILR_No_Of_Days__c;                            
                               else if(tempda.ODILR_Discipline_Assessed__c != NULL)
                                   caseRecord.Discipline_Assessed_List__c = caseRecord.Discipline_Assessed_List__c + ',' + tempda.ODILR_Discipline_Assessed__c + '*' + tempda.ODILR_No_Of_Days__c;    
                           
                               if(caseRecord.Appellate_Modification_List__c ==NULL && tempda.ODILR_Appellate_Modification__c != NULL)
                                   caseRecord.Appellate_Modification_List__c = tempda.ODILR_Appellate_Modification__c + '*' + tempda.ODILR_LR_Of_Days__c;                            
                               else if(tempda.ODILR_Appellate_Modification__c != NULL)
                                   caseRecord.Appellate_Modification_List__c = caseRecord.Appellate_Modification_List__c  + ',' + tempda.ODILR_Appellate_Modification__c + '*' + tempda.ODILR_LR_Of_Days__c; 
                           
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