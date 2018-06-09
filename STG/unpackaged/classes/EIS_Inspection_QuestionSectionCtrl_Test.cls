@isTest
public class EIS_Inspection_QuestionSectionCtrl_Test {
    @testSetup static void setup() {
        try {
            EIS_TestDataUtils.insertCustomSettings();
        } catch (DMLException e) {
            
        }
    }
    
	@isTest
    public static void countCorrectiveActions_Test() {
        List<Audit_Inspections__c> aiList = EIS_TestDataUtils.createInspectionList(null, null);
        List<Questions__c> qList = EIS_TestDataUtils.createInspectionQuestionList(aiList);
        List<Finding__c> fList = EIS_TestDataUtils.createInspectionFindingList(qList);
        List<Corrective_Action__c> caList = EIS_TestDataUtils.createInspectionCorrectiveActionList(fList);
        List<Id> qIds = new List<Id>();
        for(Questions__c q : qList) {
            qIds.add(q.Id);
        }
        List<Integer> result;
        Test.startTest();
        result = EIS_Inspection_QuestionSectionCtrl.countCorrectiveActions(JSON.serialize(qIds));
        EIS_Inspection_QuestionSectionCtrl.countCorrectiveActions(JSON.serialize(aiList));
        Test.stopTest();
        Integer corrected = caList.size() / 8;
        System.assertEquals(corrected, result[0]);
        System.assertEquals(corrected * 3, result[1]);
        System.assertEquals(corrected, result[2]);
        System.assertEquals(corrected * 3, result[3]);
    }
}