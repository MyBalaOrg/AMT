@isTest
public class EIS_Audit_QuestionSectionCtrl_Test {
    @testSetup static void setup() {
        try {
            EIS_TestDataUtils.insertCustomSettings();
        } catch (DMLException e) {
            System.debug(e.getDmlMessage(0));
        }
    }
    
	@isTest
    public static void getCustomQuestions_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
        	Audit_Inspections__c audit = EIS_Audit_BodyCtrl_Test.getAuditReadyForForm();
            Questions__c question = [SELECT EIS_Protocol_Name__c, EIS_Qualifier_Name__c FROM Questions__c WHERE Audit_Inspections__c = :audit.Id LIMIT 1];
            System.debug('Question');
            System.debug(question);
            Map<String, String> params = new Map<String, String>();
            params.put('auditId', audit.Id);
            params.put('sectionHeader', question.EIS_Qualifier_Name__c);
            params.put('sideTabName', question.EIS_Protocol_Name__c);
            params.put('recordTypeAPI', Label.EIS_Audit_Inspection_Form_Record_Type);
            Test.startTest();
            response = EIS_Audit_QuestionSectionCtrl.getCustomQuestions(params);
            System.assert(String.isNotBlank(response.get('customQuestionList')));
            
            params.put('recordTypeAPI', Label.EIS_SFA_Inspection_Form_Record_Type);
            response = EIS_Audit_QuestionSectionCtrl.getCustomQuestions(params);
            System.assert(String.isNotBlank(response.get('customQuestionList')));
            
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void updateQuestionFields_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
            Test.startTest();
            Audit_Inspections__c audit = EIS_TestDataUtils.createInspection(null, null, EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID);
            Questions__c question = EIS_TestDataUtils.createInspectionQuestion(audit, null);
            
            response = EIS_Audit_QuestionSectionCtrl.updateQuestionFields(JSON.serialize(question));
            System.assert(String.isNotBlank(response.get('question')));
            
            response = EIS_Audit_QuestionSectionCtrl.updateQuestionFields('exception test');
            System.assert(String.isNotBlank(response.get('errorMsg')));
            Test.stopTest();
        }
        
    }
}