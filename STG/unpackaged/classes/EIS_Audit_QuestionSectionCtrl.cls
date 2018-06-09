/**
*————————————————————————————————————————————————————
* @Name             EIS_Audit_QuestionSectionCtrl
* @Author           Duy Tran
* @Created Date     07-05-2017
* @Used By          EIS_Audit_QuestionSection.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to generate and handle DML operations for Audit form
* Handle specific actions from the EIS_Audit_QuestionSection component
*————————————————————————————————————————————————————
* @Changes
*
**/
public without sharing class EIS_Audit_QuestionSectionCtrl {
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Parse params data and generate a List of Question for a Section
    * Question is a wrapper object that hold Questions__c record and its Finding__c children
    *————————————————————————————————————————————————————
    * @param    params					contains data to help querying the right information
    * @return   Map<String, String>		data to populate EIS_Audit_Body lightning component and its children
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> getCustomQuestions(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        try {
            List<String> departments = EIS_StaticUtils.getPicklistValues(Finding__c.EIS_Responsible_Department__c.getDescribe());
            List<EIS_Audit_Question__mdt> metaQuestions = getMetaAuditQuestions(params.get('sideTabName'), params.get('sectionHeader'), params.get('recordTypeAPI'));
            List<EIS_Audit_BodyCtrl.Question> customQuestionList = new List<EIS_Audit_BodyCtrl.Question>();
            for (Integer i = 0; i < metaQuestions.size(); i++) {
                EIS_Audit_BodyCtrl.Question newQuestion = new EIS_Audit_BodyCtrl.Question(metaQuestions[i], params.get('auditId'));
                newQuestion.customObservationList.add(new EIS_Audit_BodyCtrl.Observation(departments, metaQuestions[i].Question_Citation__c));
                customQuestionList.add(newQuestion);
            }
            response.put('customQuestionList', JSON.serialize(customQuestionList));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Update Questions__c record
    *————————————————————————————————————————————————————
    * @param    questionJSON			JSON representation of the Questions__c record to be updated
    * @return   Map<String, String>		Reponse map holds updated audit and question record
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> updateQuestionFields(String questionJSON) {
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            Questions__c question = (Questions__c)JSON.deserialize(questionJSON, Questions__c.class);
            update question;
            question = EIS_Audit_BodyCtrl.getQuestionById(question.Id);
            Audit_Inspections__c audit = EIS_Audit_BodyCtrl.getAuditById(question.Audit_Inspections__c);
            response.put('audit', JSON.serialize(audit));
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
    * Helper method to query for metadata questions by protocol and qualifier
    *————————————————————————————————————————————————————
    * @param    protocol						String value of protocol label
    * @param	qualifier						String value of qualifier label
    * @return   List<EIS_Audit_Question__mdt>	List of metadata question related to Audit form
    *————————————————————————————————————————————————————
    **/
    private static List<EIS_Audit_Question__mdt> getMetaAuditQuestions(String protocol, String qualifier, String formName) {
        formName = '%' + formName + '%';
        System.debug(formName + ' ' + protocol + ' ' + qualifier);
        List<EIS_Audit_Question__mdt> metaQuestions = [
            SELECT Id, Point__c, Protocol_Name__c, Qualifier_Name__c, Question_Id__c, Question_Name__c, Review_Checklist__c, Question_Citation__c
            FROM EIS_Audit_Question__mdt
            WHERE Form__c LIKE :formName AND Protocol_Name__c LIKE :protocol AND Qualifier_Name__c LIKE :qualifier
            ORDER BY Question_Id__c ASC
        ];
        return metaQuestions;
    }
}