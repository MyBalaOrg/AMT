@isTest
public class EIS_Inspection_CorrectiveActionCtrl_Test {
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
        response = EIS_Inspection_CorrectiveActionCtrl.updateDescription('exception test');
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_CorrectiveActionCtrl.deleteCorrectiveAction(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_CorrectiveActionCtrl.clickNotStarted(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_CorrectiveActionCtrl.clickInProgress(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_CorrectiveActionCtrl.clickCorrected(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_CorrectiveActionCtrl.clickFailedCorrection(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_CorrectiveActionCtrl.saveAssignedToContact(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        Test.stopTest();
    }
    
    @isTest
    public static void updateDescription_Test() {
        String description = 'Hello Kitty Adventure';
        Corrective_Action__c ca = EIS_TestDataUtils.createInspectionCorrectiveAction(null);
        ca.EIS_Description__c = description;
        Test.startTest();
        Map<String, String> response = EIS_Inspection_CorrectiveActionCtrl.updateDescription(JSON.serialize(ca));
        ca = (Corrective_Action__c)JSON.deserialize(response.get('ca'), Corrective_Action__c.class);
        System.assert(!String.isBlank(ca.Id));
        System.assertEquals(description, ca.EIS_Description__c);
        Test.stopTest();
    }
    
    @isTest
    public static void deleteCorrectiveAction_Test() {
        Map<String, String> caDataMap = new Map<String, String>();
        Audit_Inspections__c inspection = EIS_TestDataUtils.createInspection(null, null, null);
        Questions__c question = EIS_TestDataUtils.createInspectionQuestion(inspection, null);
        Finding__c finding = EIS_TestDataUtils.createInspectionFinding(question);
        Corrective_Action__c ca = EIS_TestDataUtils.createInspectionCorrectiveAction(finding);
        caDataMap.put('inspectionId', inspection.Id);
        caDataMap.put('questionId', question.Id);
        caDataMap.put('findingId', finding.Id);
        caDataMap.put('caJSON', JSON.serialize(ca));
        
        Test.startTest();
        Map<String, String> response = EIS_Inspection_CorrectiveActionCtrl.deleteCorrectiveAction(caDataMap);
        ca = (Corrective_Action__c)JSON.deserialize(response.get('ca'), Corrective_Action__c.class);
        question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
        System.assert(String.isBlank(ca.Id));
        System.assertEquals(0, (Integer)question.EIS_Count_Corrected_CA__c);
        System.assertEquals(0, (Integer)question.EIS_Count_Not_Corrected_CA__c);
        Test.stopTest();
    }
    
    @isTest
    public static void clickNotStarted_Test() {
        Map<String, String> caDataMap = new Map<String, String>();
        setupCaDataMap(caDataMap);        
        
        Test.startTest();
        Map<String, String> response = EIS_Inspection_CorrectiveActionCtrl.clickNotStarted(caDataMap);
        Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(response.get('ca'), Corrective_Action__c.class);
        Questions__c question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
        Audit_Inspections__c inspection = (Audit_Inspections__c)JSON.deserialize(response.get('inspection'), Audit_Inspections__c.class);
        System.assertEquals('Not Started', ca.EIS_Status__c);
        System.assertEquals(1, (Integer)question.EIS_Count_Not_Corrected_CA__c);
        System.assertEquals('Not Started', inspection.PH_Corrective_Action_Status__c);
        Test.stopTest();
    }
    
    @isTest
    public static void clickInProgress_Test() {
        Map<String, String> caDataMap = new Map<String, String>();
        setupCaDataMap(caDataMap);
        
        Test.startTest();
        Map<String, String> response = EIS_Inspection_CorrectiveActionCtrl.clickInProgress(caDataMap);
        Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(response.get('ca'), Corrective_Action__c.class);
        Questions__c question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
        Audit_Inspections__c inspection = (Audit_Inspections__c)JSON.deserialize(response.get('inspection'), Audit_Inspections__c.class);
        System.assertEquals('In Progress', ca.EIS_Status__c);
        System.assertEquals(1, (Integer)question.EIS_Count_Not_Corrected_CA__c);
        //System.assertEquals('In Progress', inspection.PH_Corrective_Action_Status__c);
        Test.stopTest();
    }
    
    @isTest
    public static void clickCorrected_Test() {
        Map<String, String> caDataMap = new Map<String, String>();
        setupCaDataMap(caDataMap);
        
        Test.startTest();
        Map<String, String> response = EIS_Inspection_CorrectiveActionCtrl.clickCorrected(caDataMap);
               
        Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(response.get('ca'), Corrective_Action__c.class);
        Questions__c question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
        Audit_Inspections__c inspection = (Audit_Inspections__c)JSON.deserialize(response.get('inspection'), Audit_Inspections__c.class);
        System.assertEquals('Corrected', ca.EIS_Status__c);
        //System.assertEquals(1, (Integer)question.EIS_Count_Corrected_CA__c);
        //System.assertEquals('Corrected', inspection.PH_Corrective_Action_Status__c);
        Test.stopTest();
    }
    
    @isTest
    public static void clickFailedCorrection_Test() {
        Map<String, String> caDataMap = new Map<String, String>();
        setupCaDataMap(caDataMap);
        
        Test.startTest();
        Map<String, String> response = EIS_Inspection_CorrectiveActionCtrl.clickFailedCorrection(caDataMap);
        Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(response.get('ca'), Corrective_Action__c.class);
        Questions__c question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
        Audit_Inspections__c inspection = (Audit_Inspections__c)JSON.deserialize(response.get('inspection'), Audit_Inspections__c.class);
        //System.assertEquals('Failed Correction', ca.EIS_Status__c);
        //System.assertEquals(1, (Integer)question.EIS_Count_Not_Corrected_CA__c);
        //System.assertEquals('In Progress', inspection.PH_Corrective_Action_Status__c);
        Test.stopTest();
    }
    
    @isTest
    public static void saveAssignedToContact_Test() {
        Map<String, String> caDataMap = new Map<String, String>();
        setupCaDataMap(caDataMap);
        
        Test.startTest();
        Map<String, String> response = EIS_Inspection_CorrectiveActionCtrl.saveAssignedToContact(caDataMap);
        EIS_Inspection_CorrectiveActionCtrl.getContactsForTypeaheadSearch('Test');
        
        Corrective_Action__c ca = (Corrective_Action__c)JSON.deserialize(response.get('ca'), Corrective_Action__c.class);
        //System.assertNotEquals(null, ca.Id);
        Test.stopTest();
    }
    
    private static void setupCaDataMap(Map<String, String> caDataMap) {
        Audit_Inspections__c inspection = EIS_TestDataUtils.createInspection(null, null, null);
        Questions__c question = EIS_TestDataUtils.createInspectionQuestion(inspection, null);
        Finding__c finding = EIS_TestDataUtils.createInspectionFinding(question);
        Corrective_Action__c ca = new Corrective_Action__c();
        caDataMap.put('inspectionId', inspection.Id);
        caDataMap.put('questionId', question.Id);
        caDataMap.put('findingId', finding.Id);
        caDataMap.put('caJSON', JSON.serialize(ca));
    }
}