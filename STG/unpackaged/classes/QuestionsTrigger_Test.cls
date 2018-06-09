@isTest
public class QuestionsTrigger_Test {
    @testSetup static void setup() {
        try {
            EIS_TestDataUtils.insertCustomSettings();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
	@isTest 
    public static void updateInspections_AfterInsert_Test() {
        List<Audit_Inspections__c> inspections = EIS_TestDataUtils.createInspectionList(null, null);
        Test.startTest();
        EIS_TestDataUtils.createInspectionQuestionList(inspections);
        Test.stopTest();
        
        inspections = [SELECT Id, PH_Score__c, EIS_Count_Critical_Questions__c, EIS_Count_Non_Critical_Questions__c FROM Audit_Inspections__c WHERE Id IN :inspections];
        for (Audit_Inspections__c ai : inspections) {
			System.assertEquals(1, ai.EIS_Count_Non_Critical_Questions__c);            
            System.assertEquals(1, ai.EIS_Count_Critical_Questions__c);
            System.assertEquals(93, ai.PH_Score__c);
        }
    }
    
    @isTest 
    public static void updateInspections_AfterDelete_Test() {
        List<Audit_Inspections__c> inspections = EIS_TestDataUtils.createInspectionList(null, null);
        List<Questions__c> questions = EIS_TestDataUtils.createInspectionQuestionList(inspections);
        
        Test.startTest();
        delete questions;
        Test.stopTest();
        
        inspections = [SELECT Id, PH_Score__c, EIS_Count_Critical_Questions__c, EIS_Count_Non_Critical_Questions__c FROM Audit_Inspections__c WHERE Id IN :inspections];
        for (Audit_Inspections__c ai : inspections) {
            System.assertEquals(0, ai.EIS_Count_Non_Critical_Questions__c);
            System.assertEquals(0, ai.EIS_Count_Critical_Questions__c);
            System.assertEquals(100, ai.PH_Score__c);
        }
    }
    
    @isTest
    public static void updateFoodCart_AfterInsertDelete_Test() {
        Audit_Inspections__c inspection = EIS_TestDataUtils.createInspection(null, null, EIS_StaticUtils.INSPECTION_FOOD_CAR_RTID);
        List<Questions__c> questions = new List<Questions__c>();
        questions.add(new Questions__c(RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID, EIS_Criticality__c = 'critical', Audit_Inspections__c = inspection.Id, EIS_Section_Name__c = 'OBS Critical Violations', Points__c = 5));
        questions.add(new Questions__c(RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID, EIS_Criticality__c = 'critical', Audit_Inspections__c = inspection.Id, EIS_Section_Name__c = 'Mechanical Critical Violations', Points__c = 5));
        questions.add(new Questions__c(RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID, EIS_Criticality__c = 'noncritical', Audit_Inspections__c = inspection.Id, EIS_Section_Name__c = 'OBS Other Important', Points__c = 2));
        questions.add(new Questions__c(RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID, EIS_Criticality__c = 'noncritical', Audit_Inspections__c = inspection.Id, EIS_Section_Name__c = 'Mechanical Other Important', Points__c = 2));
        Test.startTest();
        insert questions;
        inspection = [SELECT Id, PH_Score__c, OBS_Critical_Violations__c, Mech_Critical_Violations__c, OBS_Noncritical_Violations__c, Mech_Noncritical_Violations__c
                      FROM Audit_Inspections__c WHERE Id = :inspection.Id];
        System.assertEquals(86, inspection.PH_Score__c);
        System.assertEquals(1, inspection.OBS_Critical_Violations__c);
        System.assertEquals(1, inspection.Mech_Critical_Violations__c);
        System.assertEquals(1, inspection.OBS_Noncritical_Violations__c);
        System.assertEquals(1, inspection.Mech_Noncritical_Violations__c);
        
        delete questions;
        inspection = [SELECT Id, PH_Score__c, OBS_Critical_Violations__c, Mech_Critical_Violations__c, OBS_Noncritical_Violations__c, Mech_Noncritical_Violations__c
                      FROM Audit_Inspections__c WHERE Id = :inspection.Id];
        System.assertEquals(100, inspection.PH_Score__c);
        System.assertEquals(0, inspection.OBS_Critical_Violations__c);
        System.assertEquals(0, inspection.Mech_Critical_Violations__c);
        System.assertEquals(0, inspection.OBS_Noncritical_Violations__c);
        System.assertEquals(0, inspection.Mech_Noncritical_Violations__c);
        Test.stopTest();
    }
    
    @isTest
    public static void auditQuestions_AfterInsertAndUpdate_Test() {
        Audit_Inspections__c audit = EIS_Audit_BodyCtrl_Test.getAuditReadyForForm();
        Questions__c question = new Questions__c(
        	RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID,
            Audit_Inspections__c = audit.Id,
            Points__c = 4, EIS_Issued__c = true, EIS_Corrected__c = false, EIS_Criticality__c = Label.EIS_Questions_Criticality_Critical, EIS_Count_Finding_Transportation__c = 10,
            EIS_Count_Finding_Engineering__c = 10, EIS_Count_Finding_Environment__c = 10, EIS_Count_Finding_Material__c = 10, EIS_Count_Finding_Mechanical__c = 10, 
            EIS_Count_Repeat_Transportation__c = 10, EIS_Count_Repeat_Engineering__c = 10, EIS_Count_Repeat_Environment__c = 10, EIS_Count_Repeat_Material__c = 10, 
            EIS_Count_Repeat_Mechanical__c = 10, EIS_Observation_Level__c = Label.EIS_Questions_Obs_Level_MP
        );
        Test.startTest();
        insert question;
        question.EIS_Observation_Level__c = Label.EIS_Questions_Obs_Level_PV;
        question.EIS_Corrected__c = true;
        update question;
        question.EIS_Observation_Level__c = Label.EIS_Questions_Obs_Level_MP;
        question.EIS_Corrected__c = true;
        update question;
        delete question;
        Test.stopTest();
    }
}