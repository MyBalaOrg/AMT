@isTest
public class EIS_Audit_BodyCtrl_Test {
    @testSetup static void setup() {
        try {
            EIS_TestDataUtils.insertCustomSettings();
        } catch (DMLException e) {
            System.debug(e.getDmlMessage(0));
        }
    }
    
    @isTest
    public static void exceptionHanding_Test() {
        Test.startTest();
        Map<String, String> response = null;
        response = EIS_Audit_BodyCtrl.initializeProtocols(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Audit_BodyCtrl.initializeDepartments(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Audit_BodyCtrl.getCustomSections(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Audit_BodyCtrl.saveNewPositiveFinding(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Audit_BodyCtrl.editPositiveFinding(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Audit_BodyCtrl.deletePositiveFinding(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Audit_BodyCtrl.updateSubmitStatus(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        Test.stopTest();
    }
    
    @isTest
    public static void initializeProtocols_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = getAuditReadyForForm();
            Map<String, String> params = new Map<String, String>();
            params.put('auditId', audit.Id);
            
            Test.startTest();
            response = EIS_Audit_BodyCtrl.initializeProtocols(params);
            Audit_Inspections__c ai = (Audit_Inspections__c)JSON.deserialize(response.get('audit'), Audit_Inspections__c.class);
            System.assertNotEquals(null, ai);
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void initializeDepartments_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = getAuditReadyForForm();
            Map<String, String> params = new Map<String, String>();
            params.put('auditId', audit.Id);
            
            Test.startTest();
            response = EIS_Audit_BodyCtrl.initializeDepartments(params);
            Audit_Inspections__c ai = (Audit_Inspections__c)JSON.deserialize(response.get('audit'), Audit_Inspections__c.class);
            System.assertNotEquals(null, ai);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getCustomSections_Protocol_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = getAuditReadyForForm();
            Map<String, String> params = new Map<String, String>();
            params.put('auditId', audit.Id);
            params.put('tabName', Label.EIS_Audit_Form_Tab_Protocol);
            params.put('sideTabName', audit.EIS_Protocol_Name__c.split(';')[0]);
            
            Test.startTest();
            response = EIS_Audit_BodyCtrl.getCustomSections(params);
            System.assert(String.isNotBlank(response.get('customSectionList')));
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void getCustomSections_Department_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = getAuditReadyForForm();
            Map<String, String> params = new Map<String, String>();
            params.put('auditId', audit.Id);
            params.put('tabName', Label.EIS_Audit_Form_Tab_Department);
            params.put('sideTabName', Label.EIS_Finding_Department_Material);
            Test.startTest();
            response = EIS_Audit_BodyCtrl.getCustomSections(params);
            System.assert(String.isNotBlank(response.get('customSectionList')));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void addEditDeletePositiveFinding_Test() {
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = getAuditReadyForForm();
            Map<String, String> params = new Map<String, String>();
            Map<String, String> response = new Map<String, String>();
            params.put('auditId', audit.Id);
            params.put('newPositiveFinding', 'YT');
            params.put('selectedDepartments', '11111');
            
            Test.startTest();
            EIS_Audit_BodyCtrl.saveNewPositiveFinding(params);
            EIS_Audit_BodyCtrl.saveNewPositiveFinding(params);
            response = EIS_Audit_BodyCtrl.saveNewPositiveFinding(params);
            audit = (Audit_Inspections__c)JSON.deserialize(response.get('audit'), Audit_Inspections__c.class);
            System.assertEquals(3, audit.EIS_Count_Positive_Finding__c);
            System.assertEquals('YT;YT;YT', audit.EIS_Positive_Findings__c);
            
            params.put('selectedDepartments', '11111');
            params.put('newPositiveFinding', 'YnD');
            params.put('pfIndex', '0');
            response = EIS_Audit_BodyCtrl.editPositiveFinding(params);
            audit = (Audit_Inspections__c)JSON.deserialize(response.get('audit'), Audit_Inspections__c.class);
            System.assertEquals(3, audit.EIS_Count_Positive_Finding__c);
            System.assertEquals('YnD;YT;YT', audit.EIS_Positive_Findings__c);
            
            params.put('auditJSON', JSON.serialize(audit));
            params.put('deleteIndex', '1');
            response = EIS_Audit_BodyCtrl.deletePositiveFinding(params);
            audit = (Audit_Inspections__c)JSON.deserialize(response.get('audit'), Audit_Inspections__c.class);
            System.assertEquals(2, audit.EIS_Count_Positive_Finding__c);
            System.assertEquals('YnD;YT', audit.EIS_Positive_Findings__c);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateSubmitStatus_SubmittedHasError_Test() {
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        Map<String, String> response = null;
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = getAuditReadyForForm();
            Questions__c deleteQuestion = EIS_TestDataUtils.createInspectionQuestion(audit, null);
            deleteQuestion.EIS_Observation_Level__c = Label.EIS_Questions_Obs_Level_MP;
            deleteQUestion.EIS_Count_Finding_Engineering__c = 10;
            deleteQUestion.EIS_Count_Finding_Environment__c = 10;
            deleteQUestion.EIS_Count_Finding_Material__c = 10;
            deleteQUestion.EIS_Count_Finding_Mechanical__c = 10;
            deleteQUestion.EIS_Count_Finding_Transportation__c = 10;
            update deleteQuestion;
            Finding__c deleteFinding = EIS_TestDataUtils.createInspectionFinding(deleteQuestion);
            Corrective_Action__c deleteCA = EIS_TestDataUtils.createInspectionCorrectiveAction(deleteFinding);
            
            EIS_Audit_Question__mdt metaQ = [
                SELECT Question_Id__c, Question_Name__c, Qualifier_Name__c, Protocol_Name__c 
                FROM EIS_Audit_Question__mdt 
                WHERE Protocol_Name__c =: audit.EIS_Protocol_Name__c.split(';')[0] ORDER BY Question_Id__c LIMIT 1
            ];
            Questions__c question = EIS_TestDataUtils.createInspectionQuestion(audit, null);
            question.EIS_Protocol_Name__c = metaQ.Protocol_Name__c;
            question.EIS_Observation_Level__c = Label.EIS_Questions_Obs_Level_MP;
            question.EIS_Count_Finding_Engineering__c = 10;
            question.EIS_Count_Finding_Environment__c = 10;
            question.EIS_Count_Finding_Material__c = 10;
            question.EIS_Count_Finding_Mechanical__c = 10;
            question.EIS_Count_Finding_Transportation__c = 10;
            
            Test.startTest();
            update question;
            Finding__c finding = EIS_TestDataUtils.createInspectionFinding(question);
            finding.EIS_Description__c = 'hello';
            update finding;
            Corrective_Action__c ca = EIS_TestDataUtils.createInspectionCorrectiveAction(finding);
            
            Map<String, String> params = new Map<String, String>();
            params.put('newSubmitStatus', Label.EIS_Audit_Inspection_Submit_Status_Submit);
            params.put('auditId', audit.Id);
            
            response = EIS_Audit_BodyCtrl.updateSubmitStatus(params);
            System.assert(response.get('hasError') != null);
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void updateSubmitStatus_SubmittedNoError_Test() {
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        Map<String, String> response = null;
        System.runAs(amtrakUser) {
            Site__c testSite = EIS_TestDataUtils.createMainSite(null);
            Site__c testFacility = EIS_TestDataUtils.createMainFacility(testSite);
            Contact cont = EIS_TestDataUtils.createInternalContact(null);
            Contact_List__c contactList = EIS_TestDataUtils.createContactList(cont, testSite, null);
            Audit_Inspections__c audit = EIS_TestDataUtils.createInspection(testFacility, cont, EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID);
            Schema.DescribeFieldResult fieldResult = EIS_Audit_Question__mdt.Protocol_Name__c.getDescribe();
            audit.EIS_Protocol_Name__c = setListToString_Semicolon(EIS_StaticUtils.getPicklistValues(fieldResult));
            Questions__c question = EIS_TestDataUtils.createInspectionQuestion(audit, null);
            EIS_Audit_Question__mdt metaQ = [
                SELECT Question_Id__c, Question_Name__c, Qualifier_Name__c, Protocol_Name__c 
                FROM EIS_Audit_Question__mdt 
                WHERE Protocol_Name__c =: audit.EIS_Protocol_Name__c.split(';')[0] ORDER BY Question_Id__c LIMIT 1
            ];
            question.EIS_Protocol_Name__c = metaQ.Protocol_Name__c;
            
            Test.startTest();
            update audit;
            update question;
            Finding__c finding = EIS_TestDataUtils.createInspectionFinding(question);
            finding.EIS_Description__c = 'YT';
            update finding;
            Corrective_Action__c ca = EIS_TestDataUtils.createInspectionCorrectiveAction(finding);
            ca.EIS_Description__c = 'YT';
            ca.EIS_Due_Date__c = Date.today();
            ca.EIS_Assigned_to__c = cont.Id;
            update ca;
            
            Map<String, String> params = new Map<String, String>();
            params.put('newSubmitStatus', Label.EIS_Audit_Inspection_Submit_Status_Submit);
            params.put('auditId', audit.Id);
            
            response = EIS_Audit_BodyCtrl.updateSubmitStatus(params);
            //System.assert(response.get('hasError') == null);
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void updateSubmitStatus_Rejected_Test() {
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        Map<String, String> response = null;
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = getAuditReadyForForm();
            Map<String, String> params = new Map<String, String>();
            params.put('newSubmitStatus', Label.EIS_Audit_Inspection_Submit_Status_Reject);
            params.put('rejectionNote', 'YT');
            params.put('auditId', audit.Id);
            
            Test.startTest();
            response = EIS_Audit_BodyCtrl.updateSubmitStatus(params);
            audit = (Audit_Inspections__c)JSON.deserialize(response.get('audit'), Audit_Inspections__c.class);
            System.assert(String.isNotBlank(audit.EIS_Reason_For_Rejection__c));
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateSubmitStatus_Approved_Test() {
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        Map<String, String> response = null;
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = getAuditReadyForForm();
            Map<String, String> params = new Map<String, String>();
            params.put('newSubmitStatus', Label.EIS_Audit_Inspection_Submit_Status_Approve);
            params.put('auditId', audit.Id);
            Test.startTest();
            response = EIS_Audit_BodyCtrl.updateSubmitStatus(params);
            audit = (Audit_Inspections__c)JSON.deserialize(response.get('audit'), Audit_Inspections__c.class);
            System.assertEquals(audit.PH_Submission_Status__c, Label.EIS_Audit_Inspection_Submit_Status_Approve);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateSubmitStatus_Observation_Test() {
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        Map<String, String> response = null;
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = getAuditReadyForForm();
            Map<String, String> params = new Map<String, String>();
            params.put('newSubmitStatus', Label.EIS_Audit_Inspection_Submit_Status_Submit_Observation);
            params.put('auditId', audit.Id);
            Test.startTest();
            response = EIS_Audit_BodyCtrl.updateSubmitStatus(params);
            audit = (Audit_Inspections__c)JSON.deserialize(response.get('audit'), Audit_Inspections__c.class);
            System.assertEquals(audit.PH_Submission_Status__c, Label.EIS_Audit_Inspection_Submit_Status_Submit_Observation);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void updateSubmitStatus_Inactive_Test() {
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        Map<String, String> response = null;
        System.runAs(amtrakUser) {
            Audit_Inspections__c audit = getAuditReadyForForm();
            Map<String, String> params = new Map<String, String>();
            params.put('newSubmitStatus', 'toggleAuditInactivity');
            params.put('auditId', audit.Id);
            Test.startTest();
            response = EIS_Audit_BodyCtrl.updateSubmitStatus(params);
            Test.stopTest();
            
            audit = (Audit_Inspections__c)JSON.deserialize(response.get('audit'), Audit_Inspections__c.class);
            System.assert(!audit.EIS_Is_Active__c);
        }
    }
    
    public static Audit_Inspections__c getAuditReadyForForm() {
        Audit_Inspections__c audit = EIS_TestDataUtils.createAuditSFA(null, null, null);
        Schema.DescribeFieldResult fieldResult = EIS_Audit_Question__mdt.Protocol_Name__c.getDescribe();
        audit.EIS_Protocol_Name__c = setListToString_Semicolon(EIS_StaticUtils.getPicklistValues(fieldResult));
        Questions__c question = EIS_TestDataUtils.createInspectionQuestion(audit, null);
        EIS_Audit_Question__mdt metaQ = [
            SELECT Question_Id__c, Question_Name__c, Qualifier_Name__c, Protocol_Name__c, Form__c 
            FROM EIS_Audit_Question__mdt 
            WHERE Protocol_Name__c =: audit.EIS_Protocol_Name__c.split(';')[0] ORDER BY Question_Id__c LIMIT 1
        ];
        question.EIS_Metadata_Question_Id__c = metaQ.Question_Id__c;
        question.EIS_Issued__c = false;
        question.EIS_Corrected__c = true;
        question.EIS_Criticality__c = Label.EIS_Questions_Criticality_Critical;
        question.EIS_Question_Text__c = metaQ.Question_Name__c;
        question.EIS_Qualifier_Name__c = metaQ.Qualifier_Name__c;
        question.EIS_Protocol_Name__c = metaQ.Protocol_Name__c;
        update audit;
        update question;
        Finding__c finding = EIS_TestDataUtils.createInspectionFinding(question);
        fieldResult = Finding__c.EIS_Responsible_Department__c.getDescribe();
        List<String> listString = EIS_StaticUtils.getPicklistValues(fieldResult);
        listString.remove(0);
        finding.EIS_Responsible_Department__c = setListToString_Semicolon(listString);
        update finding;
        Corrective_Action__c ca = EIS_TestDataUtils.createInspectionCorrectiveAction(finding);
        ca.EIS_Status__c = Label.EIS_Corrective_Action_Status_Correct;
        update ca;
        return audit;
    }
    
    public static String setListToString_Semicolon(List<String> listString) {
        String result = '';
        for (String s : listString) {
            result += (s + ';');
        }
        return result;
    }
}