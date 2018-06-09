/**
*————————————————————————————————————————————————————
* @Name             EIS_Inspection_FindingFormCtrl
* @Author           Duy Tran
* @Created Date     06-09-2017
* @Used By          EIS_Inspection_FindingForm.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to perform actions for the Finding lightning component
*————————————————————————————————————————————————————
* @Changes
* 06-09-2017	Created resolvedOnSpot() as a way to save Finding
* 06-13-2017	Updated resolvedOnSpot() to the expected functionality. 
*				Set all of its children to corrected status. Set its Question to corrected status
* 06-18-2017	Redesign logic to correctly track the number of Corrective Action and Inspection statuses
**/
public class EIS_Inspection_FindingFormCtrl {
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Insert new Finding, Questions, and Corrective Actions if not already exist
    * Update Finding's description if Finding already exist
    *————————————————————————————————————————————————————
    * @param    findingDataMap		JSON representation of findind, question, inspection, corrective actions
    * @return   Map<String, String>		Map of updated Finding, Question, Inspection, and Corrective Actions
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> updateFindingDescription(Map<String, String> findingDataMap) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Finding__c finding = (Finding__c)JSON.deserialize(findingDataMap.get('findingJSON'), Finding__c.class);
            Questions__c question = (Questions__c)JSON.deserialize(findingDataMap.get('questionJSON'), Questions__c.class);
            Boolean newFinding = false;
            
            question.EIS_Issued__c = true;
            upsert question;
            
            if (String.isBlank(finding.Id)) {
                finding.RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID;
                finding.Question__c = question.Id;
                newFinding = true;
            }
            upsert finding;
            
            if (newFinding) {
                List<Corrective_Action__c> caList = new List<Corrective_Action__c>();
                caList.add(new Corrective_Action__c(
                    RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID,
                    EIS_Description__c = '',
                    EIS_Status__c = Label.EIS_Corrective_Action_Status_Not_Started,
                    EIS_Date_of_Not_Started_Status__c = Date.today(),
                    EIS_Finding__c = finding.Id
                ));
                insert caList;
                response.put('caList', JSON.serialize(caList));
                
                Audit_Inspections__c inspection = EIS_Inspection_MainCtrl.getInspectionRecord(findingDataMap.get('inspectionId'));
                response.put('inspection', JSON.serialize(inspection));
            }
            
            question = EIS_Inspection_MainCtrl.getQuestionsRecord(question.Id);
            response.put('finding', JSON.serialize(finding));
            response.put('question', JSON.serialize(question));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Set corrective actions and question to Corrected status
    * Insert a Corrected question if Finding's parent does not exist
    *————————————————————————————————————————————————————
    * @param    findingDataMap		JSON representation of findind, question, inspection, corrective actions
    * @return   Map<String, String>		Map of updated Finding, Question, Inspection, and Corrective Actions
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> resolvedOnSpot(Map<String, String> findingDataMap) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Finding__c finding = (Finding__c)JSON.deserialize(findingDataMap.get('findingJSON'), Finding__c.class);
            Questions__c question = (Questions__c)JSON.deserialize(findingDataMap.get('questionJSON'), Questions__c.class);
            List<Corrective_Action__c> caList = (List<Corrective_Action__c>)JSON.deserialize(findingDataMap.get('caListJSON'), List<Corrective_Action__c>.class);
            List<Corrective_Action__c> updateCaList = new List<Corrective_Action__c>();
            for (Corrective_Action__c ca : caList) {
                if (String.isBlank(ca.Id)) {
                    if (String.isNotBlank(ca.EIS_Description__c)) {
                        ca.RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID;
                        ca.EIS_Finding__c = finding.Id;
                        ca.EIS_Status__c = Label.EIS_Corrective_Action_Status_Correct;
                        ca.EIS_Date_of_Corrected_Status__c = Date.today();
                        updateCaList.add(ca);
                    }
                } else {
                    if (String.isEmpty(ca.EIS_Description__c)) {
                        ca.EIS_Description__c = Label.EIS_Form_Button_Resolve_On_Spot;
                    }
                    if (!Label.EIS_Corrective_Action_Status_Correct.equals(ca.EIS_Status__c)) {
                        ca.EIS_Status__c = Label.EIS_Corrective_Action_Status_Correct;
                        ca.EIS_Date_of_Corrected_Status__c = Date.today();
                    }
                    updateCaList.add(ca);
                }
            }
            upsert updateCaList;
            caList = null;
            update finding;
            
            question = EIS_Inspection_MainCtrl.getQuestionsRecord(question.Id);
            Audit_Inspections__c inspection = EIS_Inspection_MainCtrl.getInspectionRecord(findingDataMap.get('inspectionId'));
            
            response.put('caList', JSON.serialize(updateCaList));
            response.put('finding', JSON.serialize(finding));
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
    * Delete Finding and its childred
    * Retrieve updated Question and Inspection record
    *————————————————————————————————————————————————————
    * @param    findingDataMap		JSON representation of findind, question, inspection, corrective actions
    * @return   Map<String, String>		Map of updated Finding, Question, Inspection, and Corrective Actions
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> deleteFinding(Map<String, String> findingDataMap) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Finding__c finding = (Finding__c)JSON.deserialize(findingDataMap.get('findingJSON'), Finding__c.class);
            Questions__c question = (Questions__c)JSON.deserialize(findingDataMap.get('questionJSON'), Questions__c.class);
            Questions__c newQuestion = new Questions__c(
                RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID,
                Audit_Inspections__c = findingDataMap.get('inspectionId'),
                EIS_Metadata_Question_Id__c = question.EIS_Metadata_Question_Id__c,
                Points__c = question.Points__c,
                EIS_Issued__c = false,
                EIS_Corrected__c = true,
                EIS_Criticality__c = question.EIS_Criticality__c,
                EIS_Question_Text__c = question.EIS_Question_Text__c
            );
            List<Corrective_Action__c> caList = [SELECT Id FROM Corrective_Action__c WHERE EIS_Finding__c = :finding.Id];
            delete caList;
            delete finding;
            List<Finding__c> countFinding = [SELECT Id FROM Finding__c WHERE Question__c =: question.Id];
            if (countFinding.isEmpty()) {
                delete question;
                question = newQuestion;
            } else {
                question = EIS_Inspection_MainCtrl.getQuestionsRecord(question.Id);
            }
            caList = new List<Corrective_Action__c>();
            caList.add(new Corrective_Action__c(RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, EIS_Description__c = ''));
            finding = new Finding__c(RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID, Question__c = question.Id, EIS_Description__c = '');
            Audit_Inspections__c inspection = EIS_Inspection_MainCtrl.getInspectionRecord(findingDataMap.get('inspectionId'));
            
            response.put('caList', JSON.serialize(caList));
            response.put('finding', JSON.serialize(finding));
            response.put('question', JSON.serialize(question));
            response.put('inspection', JSON.serialize(inspection));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
}