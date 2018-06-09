/**
*————————————————————————————————————————————————————
* @Name             EIS_Audit_CorrectiveActionCtrl
* @Author           Duy Tran
* @Created Date     07-05-2017
* @Used By          EIS_Audit_CorrectiveAction.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to generate and handle DML operations for Corrective Action records from Audit Form
*————————————————————————————————————————————————————
* @Changes
*
**/
public without sharing class EIS_Audit_CorrectiveActionCtrl {
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Update Corrective Action record from params and requery for other updated fields
    *————————————————————————————————————————————————————
    * @param    params					JSON representation of Corrective Action data
    * @return   Map<String, String>		Map of updated Corrective Action data
    *————————————————————————————————————————————————————
    **/
	@AuraEnabled
    public static Map<String, String> updateCorrectiveAction(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(params.get('caJSON'), Corrective_Action__c.class); 
            if (String.isNotBlank(ca.Id)) {
                update ca;
                ca = [SELECT Id, RecordTypeId, EIS_Status__c, EIS_Description__c, EIS_Assigned_to__c, EIS_Finding__c, EIS_Due_Date__c, EIS_Date_of_Corrected_Status__c, EIS_Corrective_Action_Type__c,
                      EIS_Date_of_Correction_Failed_Status__c, EIS_Progress_Notes__c, EIS_Rejection_Notes__c, EIS_RAO_Sign_Off__c, EIS_Sign_Off_Date__c, EIS_Closed_By__c,
                      EIS_Assigned_to__r.Name, EIS_Assigned_to__r.Phone, EIS_RAO_Sign_Off__r.Name
                      FROM Corrective_Action__c WHERE Id =: ca.Id];
                response.put('ca', JSON.serialize(ca));
            }
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Update Corrective Action record from params and requery for other updated fields
    * Insert Corrective Action record if not already exist
    * Requery for parent records and update the front end
    *————————————————————————————————————————————————————
    * @param    params					JSON representation of Corrective Action data and its parent Ids
    * @return   Map<String, String>		Map of updated Audit, Questions, Findings, and Corrective Actions
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> updateCorrectiveActionWithParent(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(params.get('caJSON'), Corrective_Action__c.class);        
            if (String.isBlank(ca.Id)) {
                ca.RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID;
                ca.EIS_Finding__c = params.get('findingId');
            }
            if (String.isNotBlank(params.get('completionClicked'))) {
                ca.EIS_Closed_By__c = (UserInfo.getFirstName() + ' ' + UserInfo.getLastName()).trim();
                ca.EIS_Date_of_Corrected_Status__c = Date.today();
            }
            if (String.isNotBlank(params.get('rejectionClicked'))) {
                ca.EIS_Date_of_Correction_Failed_Status__c = Date.today();
            }
            if (String.isBlank(ca.EIS_Corrective_Action_Type__c)) {
                ca.EIS_Corrective_Action_Type__c = Label.EIS_Corrective_Action_Type_Immediate;
            }
            upsert ca;
            
            Audit_Inspections__c audit = EIS_Audit_BodyCtrl.getAuditById(params.get('auditId'));
            Questions__c question = EIS_Audit_BodyCtrl.getQuestionById(params.get('questionId'));        
            
            response.put('ca', JSON.serialize(ca));
            response.put('question', JSON.serialize(question));
            response.put('audit', JSON.serialize(audit));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Delete Corrective Action record based on its Id
    * Query and return updated Question and Audit records
    *————————————————————————————————————————————————————
    * @param    params					JSON representation of Corrective Action data and its parent Ids
    * @return   Map<String, String>		Map of updated Audit, Questions
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> deleteCorrectiveAction(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(params.get('caJSON'), Corrective_Action__c.class);
            delete ca;
            Audit_Inspections__c audit = EIS_Audit_BodyCtrl.getAuditById(params.get('auditId'));
            Questions__c question = EIS_Audit_BodyCtrl.getQuestionById(params.get('questionId'));
            response.put('question', JSON.serialize(question));
            response.put('audit', JSON.serialize(audit));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Retrieve a list of Contact and populate the Wrapper Object with contact values
    * Contact values are used for typeahead search from front end
    *————————————————————————————————————————————————————
    * @param    searchKey				String value of desired search value
    * @return   Map<String, String>		Map contains JSON of a list of queried contact values
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> getContactsForTypeaheadSearch(String searchKey) {
        Map<String, String> response = new Map<String, String>();
        try {
            List<StaticUtils.SearchItem> listItems = new List<StaticUtils.SearchItem>();
            searchKey = '%' + String.escapeSingleQuotes(searchKey) + '%';
            List<Contact> searchContacts = [SELECT Id, Name, Phone FROM Contact WHERE Name LIKE :searchKey ORDER BY Name ASC LIMIT 10000];
            System.debug(searchContacts);
            for (Integer i = 0; i < searchContacts.size(); i++) {
                StaticUtils.SearchItem item = new StaticUtils.SearchItem();
                item.recordId = searchContacts[i].Id;
                item.label = searchContacts[i].Name;
                item.phone = searchContacts[i].Phone;
                listItems.add(item);
            }
            response.put('listItems', JSON.serialize(listItems));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        
        return response;
    }
}