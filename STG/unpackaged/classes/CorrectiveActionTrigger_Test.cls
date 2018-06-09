@isTest
public class CorrectiveActionTrigger_Test {
    @testSetup static void setup() {
        try {
            EIS_TestDataUtils.insertCustomSettings();
        } catch (DMLException e) {
            
        }
    }
    
    @isTest
    public static void updateInspectionCA_AfterInsert_Test() {
        List<Audit_Inspections__c> inspections = EIS_TestDataUtils.createInspectionList(null, null);
        List<Questions__c> questions = EIS_TestDataUtils.createInspectionQuestionList(inspections);
        List<Finding__c> findings = EIS_TestDataUtils.createInspectionFindingList(questions);
        
        Test.startTest();
        List<Corrective_Action__c> caList = EIS_TestDataUtils.createInspectionCorrectiveActionList(findings);
        Test.stopTest();
        inspections = [SELECT EIS_Count_Not_Corrected_CA__c, EIS_Count_In_Progress_CA__c, EIS_Count_Started_CA__c, 
                       EIS_Count_Critical_Not_Corrected_CA__c, EIS_Count_Critical_Corrected_CA__c
                       FROM Audit_Inspections__c WHERE Id IN :inspections];
        questions = [SELECT EIS_Count_Not_Corrected_CA__c, EIS_Corrected__c FROM Questions__c WHERE Id IN :questions];
        
        Integer aiNotCorrected = 0, aiInProgress = 0, aiStarted = 0, qNotCorrected = 0;
        for (Audit_Inspections__c ai : inspections) {
            System.assertEquals(2, ai.EIS_Count_Critical_Corrected_CA__c);
            System.assertEquals(6, ai.EIS_Count_Critical_Not_Corrected_CA__c);
            System.assertEquals(12, ai.EIS_Count_Not_Corrected_CA__c);
            System.assertEquals(4, ai.EIS_Count_In_Progress_CA__c);
            System.assertEquals(12, ai.EIS_Count_Started_CA__c);
        }
        for (Questions__c q : questions) {
            System.assertEquals(q.EIS_Count_Not_Corrected_CA__c == 0, q.EIS_Corrected__c);
            System.assertEquals(6, q.EIS_Count_Not_Corrected_CA__c);
        }
    }
    
    @isTest
    public static void updateInspectionCA_AfterDelete_Test() {
        List<Audit_Inspections__c> inspections = EIS_TestDataUtils.createInspectionList(null, null);
        List<Questions__c> questions = EIS_TestDataUtils.createInspectionQuestionList(inspections);
        List<Finding__c> findings = EIS_TestDataUtils.createInspectionFindingList(questions);
        List<Corrective_Action__c> caList = EIS_TestDataUtils.createInspectionCorrectiveActionList(findings);
        
        Test.startTest();
        delete caList;
        Test.stopTest();
        inspections = [SELECT EIS_Count_Not_Corrected_CA__c, EIS_Count_In_Progress_CA__c, EIS_Count_Started_CA__c, 
                       EIS_Count_Critical_Not_Corrected_CA__c, EIS_Count_Critical_Corrected_CA__c
                       FROM Audit_Inspections__c WHERE Id IN :inspections];
        questions = [SELECT EIS_Count_Not_Corrected_CA__c, EIS_Corrected__c FROM Questions__c WHERE Id IN :questions];
        
        Integer aiNotCorrected = 0, aiInProgress = 0, aiStarted = 0, qNotCorrected = 0;
        for (Audit_Inspections__c ai : inspections) {
            System.assertEquals(0, ai.EIS_Count_Critical_Corrected_CA__c);
            System.assertEquals(0, ai.EIS_Count_Critical_Not_Corrected_CA__c);
            System.assertEquals(0, ai.EIS_Count_Not_Corrected_CA__c);
            System.assertEquals(0, ai.EIS_Count_In_Progress_CA__c);
            System.assertEquals(0, ai.EIS_Count_Started_CA__c);
        }
        for (Questions__c q : questions) {
            System.assertEquals(0, q.EIS_Count_Not_Corrected_CA__c);
        }
    }
    
    @isTest
    public static void updateInspectionCA_AfterUpdate_Test() {
        List<Audit_Inspections__c> inspections = EIS_TestDataUtils.createInspectionList(null, null);
        List<Questions__c> questions = EIS_TestDataUtils.createInspectionQuestionList(inspections);
        List<Finding__c> findings = EIS_TestDataUtils.createInspectionFindingList(questions);
        List<Corrective_Action__c> caList = EIS_TestDataUtils.createInspectionCorrectiveActionList(findings);
        
        for (Integer i = 0; i < caList.size(); i++) {
            if ('Not Started'.equals(caList[i].EIS_Status__c)) {
                caList[i].EIS_Status__c = 'In Progress';
            } else if ('In Progress'.equals(caList[i].EIS_Status__c)) {
                caList[i].EIS_Status__c = 'Corrected';
            } else if ('Corrected'.equals(caList[i].EIS_Status__c)) {
                caList[i].EIS_Status__c = 'Failed Correction';
            } else {
                caList[i].EIS_Status__c = 'Not Started';
            }
        }
        
        Test.startTest();
        update caList;
        Test.stopTest();
        inspections = [SELECT EIS_Count_Not_Corrected_CA__c, EIS_Count_In_Progress_CA__c, EIS_Count_Started_CA__c, 
                       EIS_Count_Critical_Not_Corrected_CA__c, EIS_Count_Critical_Corrected_CA__c
                       FROM Audit_Inspections__c WHERE Id IN :inspections];
        questions = [SELECT EIS_Count_Not_Corrected_CA__c, EIS_Corrected__c FROM Questions__c WHERE Id IN :questions];
        
        Integer aiNotCorrected = 0, aiInProgress = 0, aiStarted = 0, qNotCorrected = 0;
        for (Audit_Inspections__c ai : inspections) {
            System.assertEquals(2, ai.EIS_Count_Critical_Corrected_CA__c);
            System.assertEquals(6, ai.EIS_Count_Critical_Not_Corrected_CA__c);
            System.assertEquals(12, ai.EIS_Count_Not_Corrected_CA__c);
            System.assertEquals(4, ai.EIS_Count_In_Progress_CA__c);
            System.assertEquals(12, ai.EIS_Count_Started_CA__c);
        }
        for (Questions__c q : questions) {
            System.assertEquals(q.EIS_Count_Not_Corrected_CA__c == 0, q.EIS_Corrected__c);
            System.assertEquals(6, q.EIS_Count_Not_Corrected_CA__c);
        }
    }
    
    @isTest
    public static void updateInspectionCA_Audit_Test() {
        Audit_Inspections__c audit = EIS_TestDataUtils.createInspection(null, null, EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID);
        Questions__c question = EIS_TestDataUtils.createInspectionQuestion(audit, null);
        Finding__c finding = EIS_TestDataUtils.createInspectionFinding(question);
        List<Corrective_Action__c> caList = new List<Corrective_Action__c>();
        for (Integer i = 0; i < 4; i++) {
            caList.add(new Corrective_Action__c(
                RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, 
                EIS_Status__c = 'Not Started', 
                EIS_Corrective_Action_Type__c = 'Long Term',
                EIS_Finding__c = finding.Id
            ));
            caList.add(new Corrective_Action__c(
                RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, 
                EIS_Status__c = 'Corrected', 
                EIS_Corrective_Action_Type__c = 'Long Term',
                EIS_Finding__c = finding.Id
            ));
            caList.add(new Corrective_Action__c(
                RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, 
                EIS_Status__c = 'Not Started', 
                EIS_Corrective_Action_Type__c = 'Immediate',
                EIS_Finding__c = finding.Id
            ));
            caList.add(new Corrective_Action__c(
                RecordTypeId = EIS_StaticUtils.CORRECTIVEACTION_INSPECTION_RTID, 
                EIS_Status__c = 'Corrected', 
                EIS_Corrective_Action_Type__c = 'Immediate',
                EIS_Finding__c = finding.Id
            ));
        }
        Test.startTest();
        insert caList;
        question = [SELECT EIS_Count_Open_Immediate_CA__c, EIS_Count_Closed_Immediate_CA__c, EIS_Count_Open_Long_Term_CA__c, EIS_Count_Closed_Long_Term_CA__c
                    FROM Questions__c WHERE Id = :question.Id];
        //System.assertEquals(4, question.EIS_Count_Open_Immediate_CA__c);
        //System.assertEquals(4, question.EIS_Count_Closed_Immediate_CA__c);
        //System.assertEquals(4, question.EIS_Count_Open_Long_Term_CA__c);
        //System.assertEquals(4, question.EIS_Count_Closed_Long_Term_CA__c);
        
        caList[0].EIS_Status__c = 'Not Started';
        caList[1].EIS_Status__c = 'Corrected';
        caList[2].EIS_Status__c = 'Not Started';
        caList[3].EIS_Status__c = 'Corrected';
        caList[4].EIS_Status__c = 'Corrected';      
        caList[5].EIS_Status__c = 'Not Started';
        caList[6].EIS_Status__c = 'Corrected';
        caList[7].EIS_Status__c = 'Not Started';
        caList[8].EIS_Corrective_Action_Type__c = 'Immediate';      
        caList[9].EIS_Corrective_Action_Type__c = 'Immediate';
        caList[10].EIS_Corrective_Action_Type__c = 'Long Term';
        caList[11].EIS_Corrective_Action_Type__c = 'Long Term';
        caList[12].EIS_Status__c = 'Corrected';     caList[12].EIS_Corrective_Action_Type__c = 'Immediate';
        caList[13].EIS_Status__c = 'Not Started';   caList[13].EIS_Corrective_Action_Type__c = 'Immediate';
        caList[14].EIS_Status__c = 'Corrected';     caList[14].EIS_Corrective_Action_Type__c = 'Long Term';
        caList[15].EIS_Status__c = 'Not Started';   caList[15].EIS_Corrective_Action_Type__c = 'Long Term';
        update caList;
        question = [SELECT EIS_Count_Open_Immediate_CA__c, EIS_Count_Closed_Immediate_CA__c, EIS_Count_Open_Long_Term_CA__c, EIS_Count_Closed_Long_Term_CA__c
                    FROM Questions__c WHERE Id =: question.Id];
        //System.assertEquals(4, question.EIS_Count_Open_Immediate_CA__c);
        //System.assertEquals(4, question.EIS_Count_Closed_Immediate_CA__c);
        //System.assertEquals(4, question.EIS_Count_Open_Long_Term_CA__c);
        //System.assertEquals(4, question.EIS_Count_Closed_Long_Term_CA__c);
        
        delete caList;
        question = [SELECT EIS_Count_Open_Immediate_CA__c, EIS_Count_Closed_Immediate_CA__c, EIS_Count_Open_Long_Term_CA__c, EIS_Count_Closed_Long_Term_CA__c
                    FROM Questions__c WHERE Id =: question.Id];
        //System.assertEquals(0, question.EIS_Count_Open_Immediate_CA__c);
        //System.assertEquals(0, question.EIS_Count_Closed_Immediate_CA__c);
        //System.assertEquals(0, question.EIS_Count_Open_Long_Term_CA__c);
        //System.assertEquals(0, question.EIS_Count_Closed_Long_Term_CA__c);
        
        Test.stopTest();
    }
}