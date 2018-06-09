/**
*————————————————————————————————————————————————————
* @Name             EIS_Audit_ObservationCtrl
* @Author           Duy Tran
* @Created Date     07-05-2017
* @Used By          EIS_Audit_Observation.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to generate and handle DML operations for Finding records from Audit Form
*————————————————————————————————————————————————————
* @Changes
*Lakshmi 12/26/2017 - Changes to fix ARSS-142
**/
public without sharing class EIS_Audit_ObservationCtrl {
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Insert new Finding, Questions, and Corrective Actions if not already exist
    * Update Finding's description if Finding already exist
    *————————————————————————————————————————————————————
    * @param    params                  JSON representation of finding, question, audit Id, corrective actions
    * @return   Map<String, String>     Map of updated Finding, Question, Inspection, and Corrective Actions
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> updateFinding(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            Finding__c finding = (Finding__c)JSON.deserialize(params.get('findingJSON'), Finding__c.class);
            Questions__c question = (Questions__c)JSON.deserialize(params.get('questionJSON'), Questions__c.class);
            Boolean newFinding = false, newQuestion = String.isEmpty(question.Id);
            if (newQuestion) { question = updateQuestionFields(params, question, finding); }
            
            if (String.isBlank(finding.Id)) {
                finding.RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID;
                finding.Question__c = question.Id;
                newFinding = true;
            }
            system.debug('========'+finding);
            upsert finding;
            
            Audit_Inspections__c audit = null;
            if (newFinding) {
                insertNewCorrectiveAction(finding.Id, response);
                audit = EIS_Audit_BodyCtrl.getAuditById(params.get('auditId'));
                audit.EIS_Count_Negative_Finding__c += 1;
                system.debug('audit : '+audit);
                update audit;
            }
            question = EIS_Audit_BodyCtrl.getQuestionById(question.Id);
            if (!newQuestion) { question = updateQuestionFields(params, question, finding); }
            if (audit == null) {
                audit = EIS_Audit_BodyCtrl.getAuditById(params.get('auditId'));
            }
            response.put('audit', JSON.serialize(audit));
            response.put('question', JSON.serialize(question));
            response.put('finding', JSON.serialize(finding));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Helper method to update Question fields based on user's action
    *————————————————————————————————————————————————————
    * @oaram    params      JSON representation of action made from Observation component
    * @param    question    Old Questions__c record             
    * @param    finding     Finding record to be updated
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private static Questions__c updateQuestionFields(Map<String, String> params, Questions__c question, Finding__c finding) {
        String clickedDept = params.get('clickedDepartment');
        Set<String> departments = new Set<String>();
        if (String.isNotBlank(finding.EIS_Responsible_Department__c)) {
            departments.addAll(finding.EIS_Responsible_Department__c.split(';'));
        }
        if (String.isNotBlank(clickedDept)) {
            if (clickedDept.equalsIgnoreCase(Label.EIS_Finding_Department_Engineering)) {
                if (finding.EIS_Repeat_Finding__c) {
                    question.EIS_Count_Repeat_Engineering__c += (departments.contains(Label.EIS_Finding_Department_Engineering)) ? 1 : -1;
                } else {
                    question.EIS_Count_Finding_Engineering__c += (departments.contains(Label.EIS_Finding_Department_Engineering)) ? 1 : -1;
                }
                
            } else if (clickedDept.equalsIgnoreCase(Label.EIS_Finding_Department_Environment)) {
                if (finding.EIS_Repeat_Finding__c) {
                    question.EIS_Count_Repeat_Environment__c += (departments.contains(Label.EIS_Finding_Department_Environment)) ? 1 : -1;
                } else {
                    question.EIS_Count_Finding_Environment__c += (departments.contains(Label.EIS_Finding_Department_Environment)) ? 1 : -1;
                }
            } else if (clickedDept.equalsIgnoreCase(Label.EIS_Finding_Department_Material)) {
                if (finding.EIS_Repeat_Finding__c) {
                    question.EIS_Count_Repeat_Material__c += (departments.contains(Label.EIS_Finding_Department_Material)) ? 1 : -1;
                } else {
                    question.EIS_Count_Finding_Material__c += (departments.contains(Label.EIS_Finding_Department_Material)) ? 1 : -1;
                }
                
            } else if (clickedDept.equalsIgnoreCase(Label.EIS_Finding_Department_Mechanical)) {
                if (finding.EIS_Repeat_Finding__c) {
                    question.EIS_Count_Repeat_Mechanical__c += (departments.contains(Label.EIS_Finding_Department_Mechanical)) ? 1 : -1;
                } else {
                    question.EIS_Count_Finding_Mechanical__c += (departments.contains(Label.EIS_Finding_Department_Mechanical)) ? 1 : -1;
                }
                
            } else if (clickedDept.equalsIgnoreCase(Label.EIS_Finding_Department_Transportation)) {
                if (finding.EIS_Repeat_Finding__c) {
                    question.EIS_Count_Repeat_Transportation__c += (departments.contains(Label.EIS_Finding_Department_Transportation)) ? 1 : -1;
                } else {
                    question.EIS_Count_Finding_Transportation__c += (departments.contains(Label.EIS_Finding_Department_Transportation)) ? 1 : -1;
                }
            }
        }
        if (String.isNotBlank(params.get('clickedRepeatFinding'))) {
            if (departments.contains(Label.EIS_Finding_Department_Engineering)) {
                question.EIS_Count_Finding_Engineering__c += (finding.EIS_Repeat_Finding__c ? -1 : 1);
                question.EIS_Count_Repeat_Engineering__c += (finding.EIS_Repeat_Finding__c ? 1 : -1);
            }
            if (departments.contains(Label.EIS_Finding_Department_Environment)) {
                question.EIS_Count_Finding_Environment__c += (finding.EIS_Repeat_Finding__c ? -1 : 1);
                question.EIS_Count_Repeat_Environment__c += (finding.EIS_Repeat_Finding__c ? 1 : -1);
            }
            if (departments.contains(Label.EIS_Finding_Department_Material)) {
                question.EIS_Count_Finding_Material__c += (finding.EIS_Repeat_Finding__c ? -1 : 1);
                question.EIS_Count_Repeat_Material__c += (finding.EIS_Repeat_Finding__c ? 1 : -1);
            }
            if (departments.contains(Label.EIS_Finding_Department_Mechanical)) {
                question.EIS_Count_Finding_Mechanical__c += (finding.EIS_Repeat_Finding__c ? -1 : 1);
                question.EIS_Count_Repeat_Mechanical__c += (finding.EIS_Repeat_Finding__c ? 1 : -1);
            }
            if (departments.contains(Label.EIS_Finding_Department_Transportation)) {
                question.EIS_Count_Finding_Transportation__c += (finding.EIS_Repeat_Finding__c ? -1 : 1);
                question.EIS_Count_Repeat_Transportation__c += (finding.EIS_Repeat_Finding__c ? 1 : -1);
            }
        }
        if (String.isBlank(question.Id)) {
            question.EIS_Issued__c = true;
            question.EIS_Corrected__c = false;
        }
        upsert question;
        return question;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Delete Finding and its childred
    * Retrieve updated Question and Audit record and update department tracking fields
    *————————————————————————————————————————————————————
    * @param    params                  JSON representation of finding, question, audit id, corrective actions
    * @return   Map<String, String>     Map of updated Finding, Question, Inspection, and Corrective Actions
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> deleteFinding(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            Finding__c finding = (Finding__c)JSON.deserialize(params.get('findingJSON'), Finding__c.class);
            Boolean repeatFinding = finding.EIS_Repeat_Finding__c;
            String responsibleDepartment = finding.EIS_Responsible_Department__c + '';
            String regulatoryCitation = finding.EIS_Regulatory_Citation__c;
            Questions__c question = (Questions__c)JSON.deserialize(params.get('questionJSON'), Questions__c.class);
            // Initializing a new question placeholder in case all findings are deleted
            Questions__c newQuestion = new Questions__c(
                RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID,
                Audit_Inspections__c = params.get('auditId'),
                 Points__c = 4,EIS_Issued__c = false, EIS_Corrected__c = true, EIS_Criticality__c = Label.EIS_Questions_Criticality_Critical, EIS_Count_Finding_Transportation__c = 0,
                EIS_Count_Finding_Engineering__c = 0, EIS_Count_Finding_Environment__c = 0, EIS_Count_Finding_Material__c = 0, EIS_Count_Finding_Mechanical__c = 0, 
                EIS_Metadata_Question_Id__c = question.EIS_Metadata_Question_Id__c, EIS_Count_Repeat_Transportation__c = 0,
                EIS_Count_Repeat_Engineering__c = 0, EIS_Count_Repeat_Environment__c = 0, EIS_Count_Repeat_Material__c = 0, EIS_Count_Repeat_Mechanical__c = 0,
                EIS_Question_Text__c = question.EIS_Question_Text__c,
                EIS_Qualifier_Name__c = question.EIS_Qualifier_Name__c,
                EIS_Protocol_Name__c = question.EIS_Protocol_Name__c
            );
            
            // Update counter if Question isn't going to be deleted
            List<Finding__c> countFinding = [SELECT Id FROM Finding__c WHERE Question__c =: question.Id];
            if (countFinding.size() > 1) {
                if (responsibleDepartment.contains(Label.EIS_Finding_Department_Engineering)) {
                    if (repeatFinding) {
                        question.EIS_Count_Repeat_Engineering__c -= 1;
                    } else {
                        question.EIS_Count_Finding_Engineering__c -= 1;
                    }
                }
                if (responsibleDepartment.contains(Label.EIS_Finding_Department_Environment)) {
                    if (repeatFinding) {
                        question.EIS_Count_Repeat_Environment__c -= 1;
                    } else {
                        question.EIS_Count_Finding_Environment__c -= 1;
                    }
                }
                if (responsibleDepartment.contains(Label.EIS_Finding_Department_Material)) {
                    if (repeatFinding) {
                        question.EIS_Count_Repeat_Material__c -= 1;
                    } else {
                        question.EIS_Count_Finding_Material__c -= 1;
                    }
                }
                if (responsibleDepartment.contains(Label.EIS_Finding_Department_Mechanical)) {
                    if (repeatFinding) {
                        question.EIS_Count_Repeat_Mechanical__c -= 1;
                    } else {
                        question.EIS_Count_Finding_Mechanical__c -= 1;
                    }
                }
                if (responsibleDepartment.contains(Label.EIS_Finding_Department_Transportation)) {
                    if (repeatFinding) {
                        question.EIS_Count_Repeat_Transportation__c -= 1;
                    } else {
                        question.EIS_Count_Finding_Transportation__c -= 1;
                    }
                }
                update question;
                question = EIS_Audit_BodyCtrl.getQuestionById(question.Id);
            }
            // Deleting finding and its children
            List<Corrective_Action__c> caList = [SELECT Id FROM Corrective_Action__c WHERE EIS_Finding__c = :finding.Id];
            delete caList;
            delete finding;
            if (countFinding.size() == 1) {
                delete question;
                question = newQuestion;
            }
            caList = new List<Corrective_Action__c>();
            caList.add(new Corrective_Action__c(RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, EIS_Description__c = ''));
            finding = new Finding__c(
                RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID, 
                Question__c = question.Id, EIS_Description__c = '', EIS_Regulatory_Citation__c = regulatoryCitation
            );
            
            Audit_Inspections__c audit = EIS_Audit_BodyCtrl.getAuditById(params.get('auditId'));
            audit.EIS_Count_Negative_Finding__c -= 1;
            update audit;
            response.put('audit', JSON.serialize(audit));
            response.put('caList', JSON.serialize(caList));
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
    * Helper method to insert new Corrective Action and set its JSON in the response
    *————————————————————————————————————————————————————
    * @param    findingId       Id value of the current Finding record
    * @param    response        JSON representation of finding, question, audit, corrective actions list
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private static void insertNewCorrectiveAction(String findingId, Map<String, String> response) {
        List<Corrective_Action__c> caList = new List<Corrective_Action__c>();
        caList.add(new Corrective_Action__c(
            RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID,
            EIS_Description__c = '',
            EIS_Corrective_Action_Type__c = Label.EIS_Corrective_Action_Type_Immediate,
            EIS_Status__c = Label.EIS_Corrective_Action_Status_Not_Started,
            EIS_Date_of_Not_Started_Status__c = Date.today(),
            EIS_Finding__c = findingId
        ));
        insert caList;
        response.put('caList', JSON.serialize(caList));
    }
    @AuraEnabled
    public static String getAuditInfo(Id auditId) {
        return JSON.serialize([Select Id, EIS_Department_Weight_Environment__c, EIS_Department_Weight_Engineering__c, EIS_Department_Weight_Material__c, EIS_Department_Weight_Mechanical__c, EIS_Department_Weight_Transportation__c From Audit_Inspections__c Where Id =: auditId]);
    }
}