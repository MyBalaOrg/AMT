@isTest
public class EIS_Inspection_FindingFormCtrl_Test {
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
        response = EIS_Inspection_FindingFormCtrl.updateFindingDescription(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_FindingFormCtrl.resolvedOnSpot(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_FindingFormCtrl.deleteFinding(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        Test.stopTest();
    }
    
	@isTest
    public static void updateFindingDescription_Test() {
        String description = 'Hello Kitty Adventure';
        List<Audit_Inspections__c> aiList = EIS_TestDataUtils.createInspectionList(null, null);
        Questions__c question = new Questions__c(
            RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID, 
            Audit_Inspections__c = aiList[0].Id, 
            EIS_Criticality__c = Label.EIS_Questions_Criticality_Critical, 
            Points__c = 5
        );
        Finding__c finding = new Finding__c(EIS_Description__c = description);
        Map<String, String> findingDataMap = new Map<String, String>();
        findingDataMap.put('findingJSON', JSON.serialize(finding));
        findingDataMap.put('questionJSON', JSON.serialize(question));
        findingDataMap.put('inspectionId', aiList[0].Id);
        Map<String, String> response;
        Test.startTest();
        response = EIS_Inspection_FindingFormCtrl.updateFindingDescription(findingDataMap);
        Test.stopTest();
        
        finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
        question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
        System.assert(String.isNotBlank(finding.Id));
        System.assert(String.isNotBlank(question.Id));
        System.assertEquals(description, finding.EIS_Description__c);
    }
    
    @isTest
    public static void resolvedOnSpot_Test() {
        String description = 'Hello Kitty Adventure';
        List<Audit_Inspections__c> aiList = EIS_TestDataUtils.createInspectionList(null, null);
        List<Questions__c> qList = EIS_TestDataUtils.createInspectionQuestionList(aiList);
        List<Finding__c> fList = EIS_TestDataUtils.createInspectionFindingList(qList);
        List<Corrective_Action__c> caList = EIS_TestDataUtils.createInspectionCorrectiveActionList(fList);
        caList[4] = new Corrective_Action__c(EIS_Description__c = description);
        Map<String, String> findingDataMap = new Map<String, String>();
        findingDataMap.put('findingJSON', JSON.serialize(fList[0]));
        findingDataMap.put('questionJSON', JSON.serialize(qList[0]));
        findingDataMap.put('inspectionId', aiList[0].Id);
        findingDataMap.put('caListJSON', JSON.serialize(caList));
        Map<String, String> response;
        Test.startTest();
        response = EIS_Inspection_FindingFormCtrl.resolvedOnSpot(findingDataMap);
        Test.stopTest();
        
        caList = (List<Corrective_Action__c>)JSON.deserialize(response.get('caList'), List<Corrective_Action__c>.class);
        System.assertEquals(Label.EIS_Form_Button_Resolve_On_Spot, caList[0].EIS_Description__c);
        System.assertEquals(Label.EIS_Corrective_Action_Status_Correct, caList[1].EIS_Status__c);
        System.assertEquals(description, caList[4].EIS_Description__c);
    }
    
    @isTest
    public static void deleteFinding_Test() {
        String description = 'Hello Kitty Adventure';
        List<Audit_Inspections__c> aiList = EIS_TestDataUtils.createInspectionList(null, null);
        List<Questions__c> qList = EIS_TestDataUtils.createInspectionQuestionList(aiList);
        List<Finding__c> fList = EIS_TestDataUtils.createInspectionFindingList(qList);
        List<Corrective_Action__c> caList = EIS_TestDataUtils.createInspectionCorrectiveActionList(fList);
        
        Test.startTest();
        Map<String, String> findingDataMap = new Map<String, String>();
        findingDataMap.put('findingJSON', JSON.serialize(fList[0]));
        findingDataMap.put('questionJSON', JSON.serialize(qList[0]));
        findingDataMap.put('inspectionId', aiList[0].Id);
        Map<String, String> response;
        response = EIS_Inspection_FindingFormCtrl.deleteFinding(findingDataMap);
        findingDataMap.put('findingJSON', JSON.serialize(fList[1]));
        response = EIS_Inspection_FindingFormCtrl.deleteFinding(findingDataMap);
        Test.stopTest();
        
        Questions__c question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
        System.assert(question.EIS_Corrected__c);
        System.assert(String.isBlank(question.Id));
    }
}