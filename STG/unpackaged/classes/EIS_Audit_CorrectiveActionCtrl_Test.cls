@isTest
public class EIS_Audit_CorrectiveActionCtrl_Test {
    @testSetup static void setup() {
        try {
            EIS_TestDataUtils.insertCustomSettings();
        } catch (DMLException e) {
            System.debug(e.getDmlMessage(0));
        }
    }
    
	@isTest
    public static void updateCorrectiveAction_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
        	Corrective_Action__c ca = EIS_TestDataUtils.createInspectionCorrectiveAction(null);
            Map<String, String> params = new Map<String, String>();
            params.put('caJSON', JSON.serialize(ca));
            Test.startTest();
            response = EIS_Audit_CorrectiveActionCtrl.updateCorrectiveAction(params);
            System.assert(String.isNotBlank(response.get('ca')));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateCorrectiveActionWithParent_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = EIS_TestDataUtils.createInspection(null, null, EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID);
            Questions__c question = EIS_TestDataUtils.createInspectionQuestion(audit, null);
            Finding__c finding = EIS_TestDataUtils.createInspectionFinding(question);
        	Corrective_Action__c ca = new Corrective_Action__c(RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, EIS_Status__c = 'Not Started', EIS_Finding__c = finding.Id);
            Map<String, String> params = new Map<String, String>();
            params.put('caJSON', JSON.serialize(ca));
            params.put('completionClicked', 'true');
            params.put('rejectionClicked', 'true');
            params.put('auditId', audit.Id);
            params.put('questionId', question.Id);
            Test.startTest();
            response = EIS_Audit_CorrectiveActionCtrl.updateCorrectiveActionWithParent(params);
            ca = (Corrective_Action__c)JSON.deserialize(response.get('ca'), Corrective_Action__c.class);        
            System.assert(String.isNotBlank(ca.Id));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void deleteCorrectiveAction_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = EIS_TestDataUtils.createInspection(null, null, EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID);
            Questions__c question = EIS_TestDataUtils.createInspectionQuestion(audit, null);
            Finding__c finding = EIS_TestDataUtils.createInspectionFinding(question);
        	Corrective_Action__c ca = EIS_TestDataUtils.createInspectionCorrectiveAction(finding);
            Map<String, String> params = new Map<String, String>();
            params.put('caJSON', JSON.serialize(ca));
            params.put('auditId', audit.Id);
            params.put('questionId', question.Id);
            Test.startTest();
            response = EIS_Audit_CorrectiveActionCtrl.deleteCorrectiveAction(params);
            System.assert(String.isNotBlank(response.get('question')));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getContactsForTypeaheadSearch_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
        	Contact drytuna = EIS_TestDataUtils.createInternalContact(null);
            Test.startTest();
            response = EIS_Audit_CorrectiveActionCtrl.getContactsForTypeaheadSearch(drytuna.FirstName);
            String listItem = response.get('listItems');
            System.assert(listItem.contains(drytuna.LastName));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void exceptionHanding_Test() {
        Test.startTest();
        Map<String, String> response = null;
        response = EIS_Audit_CorrectiveActionCtrl.deleteCorrectiveAction(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Audit_CorrectiveActionCtrl.updateCorrectiveActionWithParent(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
            
        response = EIS_Audit_CorrectiveActionCtrl.updateCorrectiveAction(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        Test.stopTest();
    }
}