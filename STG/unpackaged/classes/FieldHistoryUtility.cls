/**
*___________________________________________________
*@Name:      FieldHistoryUtility    
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
public class FieldHistoryUtility {
    
    /**
    *————————————————————————————————————————————————————
    * @Name: setFieldHistoryTracking
    * @Description
    * Mainline process for our custom Field History utility. 
    * @param    
    * @returns  
    *————————————————————————————————————————————————————
    **/
    public static void setFieldHistoryTracking(Map<Id,sObject> oldMap, 
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

                    // If the same, then get the next record 
                    if (newObject.get(fieldName) == oldObject.get(fieldName)) {
                        continue;
                    }

                    // Get Lookup field info, then get the next record  

                    if (fsm.getType() == Schema.DisplayType.REFERENCE) {
                        System.Debug('Lookup FieldName = ' + fieldName);
                        referenceFields.add(fsm);
                        newObjectList.add(newObject);
                        referenceIDSet.add((Id)oldObject.get(fieldName));
                        referenceIDSet.add((Id)newObject.get(fieldName));                       
                        continue;
                    }
                    
                    
                    FieldHistory__c historyRecord = new FieldHistory__c();
                    String oldValue;
                    String newValue;

                    // Don't bother with encrypted fields 

                    if (fsm.getType() == Schema.DisplayType.ENCRYPTEDSTRING){
                        continue;
                    }

                    // Long Text Field
                    else if (fsm.getType() == Schema.DisplayType.TEXTAREA){
                        historyRecord.OldValueRichText__c = oldObject.get(fieldName) != null ? String.valueOf(oldObject.get(fieldName)) : '';
                        historyRecord.NewValueRichText__c = newObject.get(fieldName) != null ? String.valueOf(newObject.get(fieldName)) : '';
                        oldValue = 'Please see history record for value.';
                        newValue = 'Please see history record for value.';
                    }
                    // Date 
                    else if (fsm.getType() == Schema.DisplayType.DATE){
                        oldValue = oldObject.get(fieldName) != null ? Date.valueOf(oldObject.get(fieldName)).format() : '';
                        newValue = newObject.get(fieldName) != null ? Date.valueOf(newObject.get(fieldName)).format() : '';
                    }
                    // Date Time
                    else if (fsm.getType() == Schema.DisplayType.DATETIME){
                        oldValue = oldObject.get(fieldName) != null ? DateTime.valueOf(oldObject.get(fieldName)).format() : '';
                        newValue = newObject.get(fieldName) != null ? DateTime.valueOf(newObject.get(fieldName)).format() : '';
                    }
                    // Default (String) 
                    else {                                        
                        oldValue = oldObject.get(fieldName) != null ? String.valueOf(oldObject.get(fieldName)) : '';
                        newValue = newObject.get(fieldName) != null ? String.valueOf(newObject.get(fieldName)) : '';                                                                   
                    }

                    // Adding Text, TextArea, Date and DateTime updates to the List.

                    Boolean isLookupPresent = doesFieldExist('FieldHistory__c',lookupFieldName); 

                    if(isLookupPresent) {
                        historyRecord.put(lookupFieldName, newObject.Id);
                    }

                    historyRecord.ObjectName__c     = objectName;
                    historyRecord.RelatedTo__c      = String.valueOf(newObject.Id); 
                    historyRecord.FieldUpdateDateTime__c    
                                                    = DateTime.valueOf(newObject.get('LastModifiedDate'));
                    historyRecord.Name              = fieldLabel;
                    historyRecord.fieldApiName__c   = fieldName;
                    historyRecord.ChangedBy__c      = UserInfo.getUserId();
                    historyRecord.OldValue__c       = oldValue;
                    historyRecord.NewValue__c       = newValue;
                    
                    fieldChanges.add(historyRecord);

                   
                }  // End for (Schema.FieldSetMember fsm : trackedFields)
            }  //  for (SObject newObject : newMap.values(

            // We've just completed looping through our new map values 


            // This logic handles reference (lookup) fields 

            System.Debug('ReferenceIDSet = ' + referenceIDSet);
            if (!referenceIDSet.isEmpty()) {
                referenceIdToNameMap = getReferenceFieldUpdates(referenceIDSet);
            }

            if(referenceFields.size() > 0) {

                for (SObject newObject : newObjectList) {
                    
                    SObject oldObject = oldMap.get(newObject.Id);
                    
                    for (Schema.FieldSetMember fsm : referenceFields) {
                        
                        String fieldName  = fsm.getFieldPath();
                        String fieldLabel = fsm.getLabel();
                        
                        if (newObject.get(fieldName) == oldObject.get(fieldName)) {
                            continue;
                        }
                        
                        FieldHistory__c historyRecord = new FieldHistory__c();

                        String oldLookupValue = oldObject.get(fieldName) != null ? referenceIdToNameMap.get((Id)oldObject.get(fieldName)) : '';
                        String newLookupValue = newObject.get(fieldName) != null ? referenceIdToNameMap.get((Id)newObject.get(fieldName)) : '';
                        
                        Boolean isLookupPresent = doesFieldExist('FieldHistory__c',lookupFieldName); 

                        if(isLookupPresent) {
                            historyRecord.put(lookupFieldName, newObject.Id);
                        }

                        historyRecord.ObjectName__c     = objectName;
                        historyRecord.RelatedTo__c      = String.valueOf(newObject.Id); 
                        historyRecord.FieldUpdateDateTime__c    
                                                        = DateTime.valueOf(newObject.get('LastModifiedDate'));
                        historyRecord.Name              = fieldLabel;
                        historyRecord.fieldApiName__c   = fieldName;
                        historyRecord.ChangedBy__c      = UserInfo.getUserId();
                        historyRecord.OldValue__c       = oldLookupValue;
                        historyRecord.NewValue__c       = newLookupValue;
                        
                        fieldChanges.add(historyRecord);
                    }
                }
            }

            String errorMsg; 

            if (!fieldChanges.isEmpty()) {

                errorMsg = DmlHelper.insertList(fieldChanges); 

                system.debug('ERRORS -- ' + errorMsg); 
            }

        } // END  if (!trackedFields.isEmpty()){       
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: getReferenceFieldUpdates()
    * @Description
    * 
    * @param    recordIdSet - the set of record Ids for which we want to 
    *                         obtain the name 
    * @returns  resultMap   - a map of field names by record Id 
    *————————————————————————————————————————————————————
    **/
    @TestVisible
    private static Map<Id, String> getReferenceFieldUpdates(Set<Id> recordIdSet) {
        Map<Id, String> resultMap = new Map<Id, String>();
        Map<String, Set<Id>> objNameToIdMap = new Map<String, Set<Id>>();
        
        for (Id recordId : recordIdSet){
            if (recordId != null){
                String sObjName = recordId.getSObjectType().getDescribe().getName();
                if (objNameToIdMap.containsKey(sObjName)){
                    objNameToIdMap.get(sObjName).add(recordId);
                }
                else {
                    objNameToIdMap.put(sObjName, new Set<Id>{recordId});
                }
            }
            else {
                resultMap.put(null, '');
            }
        }
        
        for (String objectName : objNameToIdMap.keySet()){
            Set<Id> tempIdSet = objNameToIdMap.get(objectName);

            String nameField = getNameUniqueField(objectName);

            String queryString = 'select ' + nameField + ' from ' + objectName + ' where Id IN :tempIdSet';
            
            for (sObject resultObject : Database.query(queryString)){
                resultMap.put((Id) resultObject.get('Id'), String.valueOf(resultObject.get(nameField)));
            }
        }
        
        return resultMap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getNameUniqueField
    * @Description
    * Returns a map of all sObject names (keys) to sObject tokens (values) 
    * for the standard and custom objects defined in your organization.
    * @param    
    * @returns  
    *————————————————————————————————————————————————————
    **/
    @TestVisible
    private static String getNameUniqueField(String objectName){

        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();    

        String strResult = null;

        // Get a map of all fields in the object 
        Map<String, Schema.SObjectField> mapFields = schemaMap.get(objectName).getDescribe().Fields.getMap();

        // Name field 
        for(Schema.SObjectField objField : mapFields.values()) {
            Schema.DescribeFieldResult descField = objField.getDescribe();
            if(descField.isNameField()) {
                strResult = descField.getName();
                break;
            }
        }
        
        if(strResult != null) {
            return strResult;
        }
        
        /*
        // AutoNumber
        for(Schema.SObjectField objField : mapFields.values()) {
            Schema.DescribeFieldResult descField = objField.getDescribe();
            if(descField.isAutoNumber()) {
                strResult = descField.getName();
                break;
            }
        }
        
        if(strResult != null) {
            return strResult;
        }

        // Unique 
        for(Schema.SObjectField objField : mapFields.values()) {
            Schema.DescribeFieldResult descField = objField.getDescribe();
            if(descField.isUnique()) {
                strResult = descField.getName();
                break;
            }
        }*/
        return strResult;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: doesFieldExist
    * @Description
    * Determines if we have a field name in an Object. 
    * In this case, we are checking to see if we have created a 
    * lookup field for the history. Else, we just use the generic key. 
    * @param    objName - the name of the object 
    *           fieldName - the field in question
    * @returns  Boolean
    *————————————————————————————————————————————————————
    **/
    @TestVisible
    private static boolean doesFieldExist(String objName, string fieldName)
    {
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        }
        catch(Exception ex) {}
         
        return false;
    }

}