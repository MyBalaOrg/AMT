/**
*___________________________________________________
*@Name:      RevSys_FieldHistoryHelper    
*@Author:    Chuck Walley   
*@Created:   January 15, 2018
*@Used_By:   All
*___________________________________________________
*@Description: 
* Custom utility to capture field changes in any object. 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_FieldHistoryHelper {
    
    /**
    *————————————————————————————————————————————————————
    * @Name: updateScoresOnObservation
    * @Description
    * Mainline process for our custom Field History utility. 
    * @param    
    * @returns  
    *————————————————————————————————————————————————————
    **/
    public static void updateScoresOnObservation(Map<Id,sObject> oldMap, 
                                                 Map<ID,sObject> newMap, 
                                                 String objectName, 
                                                 String lookupFieldName) {

        // Get the list of fields we want to track from a Field Set called 
        // FieldHistoryTracking

        final List<Schema.FieldSetMember> trackedFields = Schema.getGlobalDescribe()
                                            .get(objectName).getDescribe().FieldSets.getMap()
                                            .get('FieldHistoryTracking').getFields(); 

        List<Schema.FieldSetMember> referenceFields = new List<Schema.FieldSetMember>();
        List<sObject> newObjectList = new List<sObject>();
        Set<Id> referenceIDSet = new Set<Id>();
        Map<Id, String> referenceIdToNameMap = new Map<Id, String>();
        
        if (!trackedFields.isEmpty()) {

            List<FieldHistory__c> fieldChanges = new List<FieldHistory__c>();
            
            // Loop through the New Map values 

            for (SObject newObject : newMap.values()) {
                
                SObject oldObject = oldMap.get(newObject.Id);
                
                // We have the new and old records 
                // Loop through the fields from FieldHistoryTracking

                for (Schema.FieldSetMember fsm : trackedFields) {
                    
                    String fieldName  = fsm.getFieldPath();
                    String fieldLabel = fsm.getLabel();

                    System.Debug('FieldName = ' + fieldName);
                    System.Debug('fieldLabel = ' + fieldLabel);

                    // We want to capture the scores and put them on the Observation

                    if(fieldName == 'Score__c' && 
                        newObject.get(fieldName) != oldObject.get(fieldName)) {
                        
                        FieldHistory__c historyRecord = new FieldHistory__c();
                        String oldValue;
                        String newValue;

                        oldValue = oldObject.get(fieldName) != null ? String.valueOf(oldObject.get(fieldName)) : '';
                        newValue = newObject.get(fieldName) != null ? String.valueOf(newObject.get(fieldName)) : '';  

                        String myQuestion = (String)newObject.get(Schema.Finding__c.Sub_category__c);

                        String myParentObjectIdStr = (String)newObject.get(Schema.Finding__c.Observation__c);
                        Id     myParentObjectId    = Id.valueOf(myParentObjectIdStr); 
                   
                        historyRecord.put('Observation__c', myParentObjectId);

                        historyRecord.ObjectName__c     = 'Observation__c';
                        historyRecord.RelatedTo__c      = myParentObjectId; 
                        historyRecord.FieldUpdateDateTime__c    
                                                        = DateTime.valueOf(newObject.get('LastModifiedDate'));
                        historyRecord.Name              = 'Score: ' + myQuestion;
                        historyRecord.fieldApiName__c   = null;
                        historyRecord.ChangedBy__c      = UserInfo.getUserId();
                        historyRecord.OldValue__c       = oldValue;
                        historyRecord.NewValue__c       = newValue;
                        
                        fieldChanges.add(historyRecord);
                    }
               }
            }

            String errorMsg; 

            if (!fieldChanges.isEmpty()) {

                system.debug('fieldChanges ' + fieldChanges); 
                errorMsg = DmlHelper.insertList(fieldChanges); 

                system.debug('ERRORS -- ' + errorMsg); 
            }

        } // END  if (!trackedFields.isEmpty()){       
    }

}