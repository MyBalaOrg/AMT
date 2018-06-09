@isTest
public class EIS_Inspection_MainCtrl_Test {
    @testSetup static void setup() {
        try {
            EIS_TestDataUtils.insertCustomSettings();
        } catch (DMLException e) {
            
        }
    }
    
    @isTest
    public static void exceptionHanding_Test() {
        Test.startTest();
        Map<String, String> response = null;
        response = EIS_Inspection_MainCtrl.initInspection(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_MainCtrl.submitInspectionForm(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
            
        response = EIS_Inspection_MainCtrl.rejectInspectionForm(null, null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_MainCtrl.approveInspectionForm(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_MainCtrl.toggleIsActive(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));

        EIS_Inspection_MainCtrl.updateAdditionalNotes(null, null);
        Test.stopTest();
    }
    
    @isTest
    public static void initInspection_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_PHI);
        System.runAs(amtrakUser) {
            List<Audit_Inspections__c> aiList = EIS_TestDataUtils.createInspectionList(null, null);
            List<Questions__c> qList = EIS_TestDataUtils.createInspectionQuestionList(aiList);
            List<Finding__c> fList = EIS_TestDataUtils.createInspectionFindingList(qList);
            List<Corrective_Action__c> caList = EIS_TestDataUtils.createInspectionCorrectiveActionList(fList);
            updateQuestionsWithMetadata(aiList);
            
            Test.startTest();
            for (Audit_Inspections__c inspection : aiList) {
                response = EIS_Inspection_MainCtrl.initInspection(inspection.Id);
            }
            Test.stopTest();
        }
        Audit_Inspections__c ai = (Audit_Inspections__c)JSON.deserialize(response.get('inspection'), Audit_Inspections__c.class);
        System.assertEquals('Draft', ai.PH_Submission_Status__c);
    }
    
	@isTest
    public static void submitInspectionForm_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_PHI);
        System.runAs(amtrakUser) {
            List<Audit_Inspections__c> aiList = EIS_TestDataUtils.createInspectionList(null, null);
            Test.startTest();
            response = EIS_Inspection_MainCtrl.submitInspectionForm(aiList[0].Id);
            Test.stopTest();
        }
        Audit_Inspections__c ai = (Audit_Inspections__c)JSON.deserialize(response.get('inspection'), Audit_Inspections__c.class);
        System.assertEquals('Submitted', ai.PH_Submission_Status__c);
        System.assertNotEquals(null, ai.EIS_Correction_Deadline__c);
    }
    
    @isTest
    public static void rejectInspectionForm_Test() {
        Map<String, String> response = null;
        String reason = 'Reason for rejection';
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_PHA);
        System.runAs(amtrakUser) {
            List<Audit_Inspections__c> aiList = EIS_TestDataUtils.createInspectionList(null, null);
            Test.startTest();
            EIS_Inspection_MainCtrl.updateAdditionalNotes(aiList[0].Id, reason);
            response = EIS_Inspection_MainCtrl.rejectInspectionForm(aiList[0].Id, reason);
            EIS_Inspection_MainCtrl.toggleIsActive(aiList[0].Id);
            Test.stopTest();
        }
        Audit_Inspections__c ai = (Audit_Inspections__c)JSON.deserialize(response.get('inspection'), Audit_Inspections__c.class);
        System.assertEquals('Rejected', ai.PH_Submission_Status__c);
        System.assertEquals(reason, ai.EIS_Reason_For_Rejection__c);
        System.assertEquals(reason, ai.EIS_Additional_Notes__c);
    }
    
    @isTest
    public static void approveInspectionForm_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_PHA);
        System.runAs(amtrakUser) {
            List<Audit_Inspections__c> aiList = EIS_TestDataUtils.createInspectionList(null, null);
            Test.startTest();
            response = EIS_Inspection_MainCtrl.approveInspectionForm(aiList[0].Id);
            Test.stopTest();
        }
        Audit_Inspections__c ai = (Audit_Inspections__c)JSON.deserialize(response.get('inspection'), Audit_Inspections__c.class);
        System.assertEquals('Approved', ai.PH_Submission_Status__c);
    }
    
    private static void updateQuestionsWithMetadata(List<Audit_Inspections__c> aiList) {
        List<List<EIS_Questions__mdt>> metaList = new List<List<EIS_Questions__mdt>>();
        metaList.add(EIS_TestDataUtils.getMetadataQuestionList(EIS_StaticUtils.METAQUESTION_FORM_API_COMMISSARY));
        metaList.add(EIS_TestDataUtils.getMetadataQuestionList(EIS_StaticUtils.METAQUESTION_FORM_API_WATERPOINT));
        metaList.add(EIS_TestDataUtils.getMetadataQuestionList(EIS_StaticUtils.METAQUESTION_FORM_API_VENDOR));
        metaList.add(EIS_TestDataUtils.getMetadataQuestionList(EIS_StaticUtils.METAQUESTION_FORM_API_FOOD_CART));
        
        for (Integer i = 0; i < aiList.size(); i++) {
            List<Questions__c> qList = [SELECT Id FROM Questions__c WHERE Audit_Inspections__c = :aiList[i].Id];
            for (Integer j = 0; j < qList.size(); j++) {
                qList[j].EIS_Metadata_Question_Id__c = metaList[i][j].Id;
                qList[j].EIS_Question_Text__c = metaList[i][j].Question__c;
            }
            update qList;
        }
    }
}