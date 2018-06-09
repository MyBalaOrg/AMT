/**
*————————————————————————————————————————————————————
* @Name             EIS_TaskTriggerHelper
* @Author           Kumar Suyash
* @Created Date     06-01-2017
* @Used By          TaskTriggerHandler.apxc
*————————————————————————————————————————————————————
* @Description
* Helper class to handle trigger logic for Task object
*————————————————————————————————————————————————————
* @Description  Method to Update Contact Eamil Field on Task
*————————————————————————————————————————————————————
**/
public class EIS_TaskTriggerHelper {     
    
    public void updateTaskEmailFields(List<Task> newList) {
        
        set<ID> pIdSet = new set<ID>();
        set<ID> cIdSet = new set<ID>();
        for (Task t : newList){  // collect parentIds
            if (t.whoId == null ) {
                // NOT YET NEEDED
            }
            else {
                if (t.whoId.getSobjectType() == Contact.SObjectType && t.WhatId != null && t.WhatId.getSobjectType() == Permit_Plan__c.SObjectType) {
                    cIdSet.add(t.whoId);
                }
            }
                
            
            if (t.WhatId == null) { 
                // NOT YET NEEDED
            }
            else {
                if (t.WhatId.getSobjectType() == Permit_Plan__c.SObjectType) {
                    pIdSet.add(t.WhatId);
                }
            }
        }
        
        
        // Find the parents
        map<ID,Permit_Plan__c> pIdToPermitMap = new map<ID,Permit_Plan__c>([select id, EIS_Contact_1__r.Email,EIS_Contact_2__r.Email,
                                                                            EIS_Contact_3__r.Email,EIS_Contact_4__r.Email,EIS_Contact_5__r.Email 
                                                                            from Permit_Plan__c where id IN :pIdSet]);
        
        map<ID,Contact> cIdToContactMap = new map<ID,Contact>([select id, email 
                                                               from Contact where id IN :cIdSet]);
        
        // populate the custom Email field from parent
        for (Task t: newList){
            t.EIS_Contact_Name_Email_Id__c = cIdToContactMap.containsKey(t.whoId)
                ? cIdToContactMap.get(t.whoId).email
                : null; 
            
            t.Email_id_Contact_1__c = pIdToPermitMap.containsKey(t.WhatId) 
                ? pIdToPermitMap.get(t.WhatId).EIS_Contact_1__r.Email
                : null; 
            
            t.Email_id_Contact_2__c = pIdToPermitMap.containsKey(t.WhatId)
                ? pIdToPermitMap.get(t.WhatId).EIS_Contact_2__r.Email
                : null; 
            t.EIS_Email_id_Contact_3__c= pIdToPermitMap.containsKey(t.WhatId) 
                ? pIdToPermitMap.get(t.WhatId).EIS_Contact_3__r.Email
                : null; 
            t.EIS_Email_id_Contact_4__c= pIdToPermitMap.containsKey(t.WhatId) 
                ? pIdToPermitMap.get(t.WhatId).EIS_Contact_4__r.Email
                : null; 
            t.EIS_Email_id_Contact_5__c= pIdToPermitMap.containsKey(t.WhatId) 
                ? pIdToPermitMap.get(t.WhatId).EIS_Contact_5__r.Email
                : null;                      
            
            
        }
    }
}