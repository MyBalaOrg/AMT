/*
Author: Raj Kumar Pandy
Description: The Helper Class for the CaseTrigger. The functionality of this class is to update the Email of the Handler and Union Supervisor/Director 
             on the email fields of the Case object record.
*/
public class ODILR_CaseTriggerHelper {
    
    
    public static boolean ContainsODILRCase(List<Case> caseTriggerRecords){
    
        boolean bContainsODILRCase = FALSE;
        
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        System.debug('Record Type Map is ' + rt_Map);
        
        for(Case eachCase : caseTriggerRecords){
            if(rt_Map != NULL && rt_Map.get(eachCase.RecordTypeId) != NULL && ((rt_Map.get(eachCase.RecordTypeId).getName() == System.Label.ODILR_Discipline_Record_Type) || 
              (rt_Map.get(eachCase.RecordTypeId).getName() == System.Label.ODILR_Claims_Record_Type)))
            {
                bContainsODILRCase = TRUE;
                break;
            }
        }
        
        return bContainsODILRCase;
    }

    //Method for Updating the Case fields for before Insert and before Update
    public static void caseUnionAssignment(List<Case> caseTriggerRecords)
    {
       Map<id,Union__c> unionMaps = new Map<id,Union__c>();
       Map<String,Union__c> unionNamesMaps = new Map<String,Union__c>();
       Set<ID> uniqueContactIDs = new Set<ID>();
       Set<ID> uniqueUnionIDs = new Set<ID>();
       try
       {
          Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
           
       //Loop for collecting the unique Union and Case IDs
       for(Case tempCaseObj : caseTriggerRecords)
       {
           if(rt_Map != NULL && rt_Map.get(tempCaseObj.RecordTypeId) != NULL && 
               ((rt_Map.get(tempCaseObj.RecordTypeId).getName() == System.Label.ODILR_Discipline_Record_Type) || 
                (rt_Map.get(tempCaseObj.RecordTypeId).getName() == System.Label.ODILR_Claims_Record_Type)
               )
             )
           {
               uniqueUnionIDs.add(tempCaseObj.Union__c);
               uniqueContactIDs.add(tempCaseObj.ODILR_Handler_Second_Level__c);
               uniqueContactIDs.add(tempCaseObj.ODILR_Handler_Third_Level__c);
               uniqueContactIDs.add(tempCaseObj.ODILR_Advocate__c);
           }
       }

       //Loop for assigning records to the unionMaps and unionNamesMaps
       for(Union__c tempUnion : [Select id, Name, ODILR_Director__r.Email from Union__c where ID IN : uniqueUnionIDs OR Name='FOP'] )
       {
           unionMaps.put(tempUnion.Id, tempUnion);
           unionNamesMaps.put(tempUnion.Name, tempUnion);
       }
       Map<id,Contact> contactMaps = new Map<id,Contact>([Select id, Email,ODILR_Supervisor__r.Email,ODILR_Is_LR_Handler__c from Contact where ODILR_Is_LR_Handler__c= True AND ID IN : uniqueContactIDs]);

        //Loop for updating the email fields and Union__c field with FOP union
        for(Case tempCaseObject : caseTriggerRecords)
        {
            if(rt_Map != NULL && rt_Map.get(tempCaseObject.RecordTypeId) != NULL && (rt_Map.get(tempCaseObject.RecordTypeId).getName() == System.Label.ODILR_Discipline_Record_Type) && tempCaseObject.Union__c == NULL)
            {
                if(unionNamesMaps.get('FOP')!=NULL)
                {
                    tempCaseObject.Union__c = unionNamesMaps.get('FOP').Id;
                }
            }
            if(tempCaseObject.ODILR_Handler_Second_Level__c!=NULL && contactMaps.get(tempCaseObject.ODILR_Handler_Second_Level__c)!=NULL && contactMaps.get(tempCaseObject.ODILR_Handler_Second_Level__c).ODILR_Supervisor__r.EMail != NULL)
            {
                tempCaseObject.Handler_Supv_Email_Second_Level__c = contactMaps.get(tempCaseObject.ODILR_Handler_Second_Level__c).ODILR_Supervisor__r.Email;
            
            }
            if(contactMaps.get(tempCaseObject.ODILR_Handler_Third_Level__c)!=NULL && contactMaps.get(tempCaseObject.ODILR_Handler_Third_Level__c).ODILR_Supervisor__r.Email!=NULL)
            {
                tempCaseObject.Handler_Supv_Email_Third_Level__c = contactMaps.get(tempCaseObject.ODILR_Handler_Third_Level__c).ODILR_Supervisor__r.Email;
            }
            if(contactMaps.get(tempCaseObject.ODILR_Advocate__c)!=NULL && contactMaps.get(tempCaseObject.ODILR_Advocate__c).ODILR_Supervisor__r.Email!=NULL)
            {
                tempCaseObject.Advocate_Supv_Email_Board_Level__c = contactMaps.get(tempCaseObject.ODILR_Advocate__c).ODILR_Supervisor__r.Email;
            }
            if(unionMaps.get(tempCaseObject.Union__c)!=NULL && unionMaps.get(tempCaseObject.Union__c).ODILR_Director__r.Email!=NULL)
            {
                tempCaseObject.Union_Director_Email__c = unionMaps.get(tempCaseObject.Union__c).ODILR_Director__r.Email;
            } 
        }
           
       }
       Catch(Exception e)
       {
           system.debug('The Error message is '+e.getMessage()+' at line number '+e.getLineNumber());
       }
    
    }
}