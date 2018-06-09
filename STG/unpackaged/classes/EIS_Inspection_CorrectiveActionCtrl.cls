/**
*————————————————————————————————————————————————————
* @Name             EIS_Inspection_CorrectiveActionCtrl
* @Author           Duy Tran
* @Created Date     06-09-2017
* @Used By          EIS_Inspection_CorrectiveAction.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to perform actions for the Corrective Action component
*————————————————————————————————————————————————————
* @Changes
* 06-09-2017	Created clickNotStarted to save Corrective Actions
* 06-13-2017	Created a methods for each status button clicked to save Corrective Actions
* 06-16-2017	Removed counting of to be updated Corrective Actions
**/
public class EIS_Inspection_CorrectiveActionCtrl {
    /**
*————————————————————————————————————————————————————
* @Description
* Update description of the Corrective Action
*————————————————————————————————————————————————————
* @param    caJSON		JSON representation of the Corrective Action record
* @return   Map<String, String>		Map of updated Corrective Action, Question, and Inspection
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> updateDescription(String caJSON) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(caJSON, Corrective_Action__c.class);
            update ca;
            response.put('ca', JSON.serialize(ca));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Update description of the Corrective Action
*————————————————————————————————————————————————————
* @param    caJSON		JSON representation of the Corrective Action record
* @return   Map<String, String>		Map of updated Corrective Action, Question, and Inspection
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> saveAssignedToContact(Map<String, String> caDataMap) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(caDataMap.get('caJSON'), Corrective_Action__c.class); 
            Boolean newCA = false;
            if (String.isBlank(ca.Id)) {
                ca.RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID;
                ca.EIS_Finding__c = caDataMap.get('findingId');
                ca.EIS_Status__c = Label.EIS_Corrective_Action_Status_Not_Started;
                ca.EIS_Date_of_Not_Started_Status__c = Date.today();
                newCA = true;
            }
            upsert ca;
            // Requery for updated data after update
            ca = [
                SELECT Id, EIS_Status__c, EIS_Date_of_Not_Started_Status__c, EIS_Description__c, EIS_Assigned_to__c, EIS_Assigned_to__r.Name, EIS_Finding__c,
                EIS_Date_of_In_Progress_Status__c, EIS_Date_of_Corrected_Status__c, EIS_Date_of_Correction_Failed_Status__c
                FROM Corrective_Action__c WHERE Id = :ca.Id
            ];
            if (newCA) {
                Audit_Inspections__c inspection = EIS_Inspection_MainCtrl.getInspectionRecord(caDataMap.get('inspectionId'));
                Questions__c question = EIS_Inspection_MainCtrl.getQuestionsRecord(caDataMap.get('questionId'));
                response.put('question', JSON.serialize(question));
                response.put('inspection', JSON.serialize(inspection));
            }
            response.put('ca', JSON.serialize(ca));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Delete current Corrective Action
* Query for updated inspection and question record
*————————————————————————————————————————————————————
* @param    caDataMap		Map of user entered data for Corrective Action
* @return   Map<String, String>		Map of updated Corrective Action, Question, and Inspection
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> deleteCorrectiveAction(Map<String, String> caDataMap) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(caDataMap.get('caJSON'), Corrective_Action__c.class);        
            if (String.isNotBlank(ca.Id)) {
                delete ca;
                
                Corrective_Action__c newCA = new Corrective_Action__c(
                    RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID,
                    EIS_Finding__c = caDataMap.get('findingId')
                );
                Audit_Inspections__c inspection = EIS_Inspection_MainCtrl.getInspectionRecord(caDataMap.get('inspectionId'));
                Questions__c question = EIS_Inspection_MainCtrl.getQuestionsRecord(caDataMap.get('questionId'));  
                response.put('ca', JSON.serialize(newCA));
                response.put('question', JSON.serialize(question));
                response.put('inspection', JSON.serialize(inspection));
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
* Parse the caDataMap to collect user entered data for Corrective Action
* Upsert a Not Started corrective action
* Update corresponding question and inspection
*————————————————————————————————————————————————————
* @param    caDataMap		Map of user entered data for Corrective Action
* @return   Map<String, String>		Map of updated Corrective Action, Question, and Inspection
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> clickNotStarted(Map<String, String> caDataMap) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(caDataMap.get('caJSON'), Corrective_Action__c.class);        
            if (String.isBlank(ca.Id)) {
                ca.RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID;
                ca.EIS_Finding__c = caDataMap.get('findingId');
            }
            ca.EIS_Status__c = Label.EIS_Corrective_Action_Status_Not_Started;
            ca.EIS_Date_of_Not_Started_Status__c = Date.today();
            upsert ca;
            
            Audit_Inspections__c inspection = EIS_Inspection_MainCtrl.getInspectionRecord(caDataMap.get('inspectionId'));
            Questions__c question = EIS_Inspection_MainCtrl.getQuestionsRecord(caDataMap.get('questionId'));        
            
            response.put('ca', JSON.serialize(ca));
            response.put('question', JSON.serialize(question));
            response.put('inspection', JSON.serialize(inspection));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Parse the caDataMap to collect user entered data for Corrective Action
* Upsert an In Progress corrective action
* Update corresponding question and inspection
*————————————————————————————————————————————————————
* @param    caDataMap		Map of user entered data for Corrective Action
* @return   Map<String, String>		Map of updated Corrective Action, Question, and Inspection
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> clickInProgress(Map<String, String> caDataMap) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(caDataMap.get('caJSON'), Corrective_Action__c.class);        
            if (String.isBlank(ca.Id)) {
                ca.RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID;
                ca.EIS_Finding__c = caDataMap.get('findingId');
            }
            ca.EIS_Status__c = Label.EIS_Corrective_Action_Status_In_Progress;
            ca.EIS_Date_of_In_Progress_Status__c = Date.today();
            upsert ca;
            
            Audit_Inspections__c inspection = EIS_Inspection_MainCtrl.getInspectionRecord(caDataMap.get('inspectionId'));
            Questions__c question = EIS_Inspection_MainCtrl.getQuestionsRecord(caDataMap.get('questionId'));        
            
            response.put('ca', JSON.serialize(ca));
            response.put('question', JSON.serialize(question));
            response.put('inspection', JSON.serialize(inspection));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;    
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Parse the caDataMap to collect user entered data for Corrective Action
* Upsert a Corrected corrective action
* Update corresponding question and inspection
*————————————————————————————————————————————————————
* @param    caDataMap		Map of user entered data for Corrective Action
* @return   Map<String, String>		Map of updated Corrective Action, Question, and Inspection
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> clickCorrected(Map<String, String> caDataMap) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(caDataMap.get('caJSON'), Corrective_Action__c.class);        
            if (String.isBlank(ca.Id)) {
                ca.RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID;
                ca.EIS_Finding__c = caDataMap.get('findingId');
            }
            ca.EIS_Status__c = Label.EIS_Corrective_Action_Status_Correct;
            
            if(ca.EIS_Date_of_Corrected_Status__c == null){
                ca.EIS_Date_of_Corrected_Status__c = Date.today();
            }
            upsert ca;
            
            Audit_Inspections__c inspection = EIS_Inspection_MainCtrl.getInspectionRecord(caDataMap.get('inspectionId'));
            Questions__c question = EIS_Inspection_MainCtrl.getQuestionsRecord(caDataMap.get('questionId'));        
            
            response.put('ca', JSON.serialize(ca));
            response.put('question', JSON.serialize(question));
            response.put('inspection', JSON.serialize(inspection));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    /**
*————————————————————————————————————————————————————
* @Description
* Parse the caDataMap to collect user entered data for Corrective Action
* Upsert a Failed Correction corrective action
* Update corresponding question and inspection
*————————————————————————————————————————————————————
* @param    caDataMap		Map of user entered data for Corrective Action
* @return   Map<String, String>		Map of updated Corrective Action, Question, and Inspection
*————————————————————————————————————————————————————
**/
    @AuraEnabled
    public static Map<String, String> clickFailedCorrection(Map<String, String> caDataMap) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(caDataMap.get('caJSON'), Corrective_Action__c.class);        
            if (String.isBlank(ca.Id)) {
                ca.RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID;
                ca.EIS_Finding__c = caDataMap.get('findingId');
            }
            ca.EIS_Status__c = Label.EIS_Corrective_Action_Status_Fail_Correction;
            ca.EIS_Date_of_Correction_Failed_Status__c = Date.today();
            upsert ca;
            
            Audit_Inspections__c inspection = EIS_Inspection_MainCtrl.getInspectionRecord(caDataMap.get('inspectionId'));
            Questions__c question = EIS_Inspection_MainCtrl.getQuestionsRecord(caDataMap.get('questionId'));        
            
            response.put('ca', JSON.serialize(ca));
            response.put('question', JSON.serialize(question));
            response.put('inspection', JSON.serialize(inspection));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    // Calling Typeahead search function from Audit controller
    @AuraEnabled
    public static Map<String, String> getContactsForTypeaheadSearch(String searchKey) {
        return EIS_Audit_CorrectiveActionCtrl.getContactsForTypeaheadSearch(searchKey);
    }
}