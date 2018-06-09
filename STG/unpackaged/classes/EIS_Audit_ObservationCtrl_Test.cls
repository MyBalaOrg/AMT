// Lakshmi 01/17/2018 - changes to fix ARSS-142
@isTest
public class EIS_Audit_ObservationCtrl_Test {
    @testSetup static void setup() {
        try {
            EIS_TestDataUtils.insertCustomSettings();
        } catch (DMLException e) {
            System.debug(e.getDmlMessage(0));
        }
    }
    
	@isTest
    public static void updateFinding_NotRepeat_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
        	Audit_Inspections__c audit = EIS_TestDataUtils.createInspection(null, null, EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID);
            Schema.DescribeFieldResult fieldResult = EIS_Audit_Question__mdt.Protocol_Name__c.getDescribe();
        	audit.EIS_Protocol_Name__c = EIS_Audit_BodyCtrl_Test.setListToString_Semicolon(EIS_StaticUtils.getPicklistValues(fieldResult));
            EIS_Audit_Question__mdt metaQ = [
                SELECT Question_Id__c, Question_Name__c, Qualifier_Name__c, Protocol_Name__c 
                FROM EIS_Audit_Question__mdt 
                WHERE Protocol_Name__c =: audit.EIS_Protocol_Name__c.split(';')[0] ORDER BY Question_Id__c LIMIT 1
            ];
            Questions__c question = new Questions__c(
                RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID,
            	EIS_Metadata_Question_Id__c = metaQ.Question_Id__c,
                Audit_Inspections__c = audit.Id,
        		EIS_Issued__c = false,
            	EIS_Corrected__c = true,
        		EIS_Criticality__c = Label.EIS_Questions_Criticality_Critical,
                EIS_Count_Finding_Transportation__c = 0, EIS_Count_Finding_Engineering__c = 0, EIS_Count_Finding_Environment__c = 0, EIS_Count_Finding_Material__c = 0, 
                EIS_Count_Finding_Mechanical__c = 0, EIS_Count_Repeat_Transportation__c = 0, EIS_Count_Repeat_Engineering__c = 0, EIS_Count_Repeat_Environment__c = 0, 
                EIS_Count_Repeat_Material__c = 0, EIS_Count_Repeat_Mechanical__c = 0, EIS_Observation_Level__c = Label.EIS_Questions_Obs_Level_PV,
        		EIS_Question_Text__c = metaQ.Question_Name__c,
                EIS_Qualifier_Name__c = metaQ.Qualifier_Name__c,
        		EIS_Protocol_Name__c = metaQ.Protocol_Name__c
            );
            String responsibleDept = Label.EIS_Finding_Department_Engineering + ';' + Label.EIS_Finding_Department_Environment + ';' +
                Label.EIS_Finding_Department_Material + ';' + Label.EIS_Finding_Department_Mechanical + ';' + Label.EIS_Finding_Department_Transportation;
            Finding__c finding = new Finding__c(
                RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID,
                EIS_Responsible_Department__c = responsibleDept,
                EIS_Repeat_Finding__c = false
            );
            
            Map<String, String> params = new Map<String, String>();
            params.put('auditId', audit.Id);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            params.put('clickedDepartment', Label.EIS_Finding_Department_Engineering);
            params.put('clickedRepeatFinding', 'true');
            
            Test.startTest();
            response = EIS_Audit_ObservationCtrl.updateFinding(params);
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            params.put('clickedDepartment', Label.EIS_Finding_Department_Environment);
            
            response = EIS_Audit_ObservationCtrl.updateFinding(params);
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            params.put('clickedDepartment', Label.EIS_Finding_Department_Material);
            
            response = EIS_Audit_ObservationCtrl.updateFinding(params);
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            params.put('clickedDepartment', Label.EIS_Finding_Department_Mechanical);
            
            response = EIS_Audit_ObservationCtrl.updateFinding(params);
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            params.put('clickedDepartment', Label.EIS_Finding_Department_Transportation);
            
            response = EIS_Audit_ObservationCtrl.updateFinding(params);
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            
            String resp = EIS_Audit_ObservationCtrl.getAuditInfo(audit.Id);
            Test.stopTest();
            
            System.assert(String.isNotBlank(finding.Id));
        }
    }
    
    @isTest
    public static void updateFinding_Repeat_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
        	Audit_Inspections__c audit = EIS_TestDataUtils.createInspection(null, null, EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID);
            Schema.DescribeFieldResult fieldResult = EIS_Audit_Question__mdt.Protocol_Name__c.getDescribe();
        	audit.EIS_Protocol_Name__c = EIS_Audit_BodyCtrl_Test.setListToString_Semicolon(EIS_StaticUtils.getPicklistValues(fieldResult));
            EIS_Audit_Question__mdt metaQ = [
                SELECT Question_Id__c, Question_Name__c, Qualifier_Name__c, Protocol_Name__c 
                FROM EIS_Audit_Question__mdt 
                WHERE Protocol_Name__c =: audit.EIS_Protocol_Name__c.split(';')[0] ORDER BY Question_Id__c LIMIT 1
            ];
            Questions__c question = new Questions__c(
                RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID,
            	EIS_Metadata_Question_Id__c = metaQ.Question_Id__c,
                Audit_Inspections__c = audit.Id,
        		EIS_Issued__c = false,
            	EIS_Corrected__c = true,
        		EIS_Criticality__c = Label.EIS_Questions_Criticality_Critical,
                EIS_Count_Finding_Transportation__c = 0, EIS_Count_Finding_Engineering__c = 0, EIS_Count_Finding_Environment__c = 0, EIS_Count_Finding_Material__c = 0, 
                EIS_Count_Finding_Mechanical__c = 0, EIS_Count_Repeat_Transportation__c = 0, EIS_Count_Repeat_Engineering__c = 0, EIS_Count_Repeat_Environment__c = 0, 
                EIS_Count_Repeat_Material__c = 0, EIS_Count_Repeat_Mechanical__c = 0, EIS_Observation_Level__c = Label.EIS_Questions_Obs_Level_PV,
        		EIS_Question_Text__c = metaQ.Question_Name__c,
                EIS_Qualifier_Name__c = metaQ.Qualifier_Name__c,
        		EIS_Protocol_Name__c = metaQ.Protocol_Name__c
            );
            String responsibleDept = Label.EIS_Finding_Department_Engineering + ';' + Label.EIS_Finding_Department_Environment + ';' +
                Label.EIS_Finding_Department_Material + ';' + Label.EIS_Finding_Department_Mechanical + ';' + Label.EIS_Finding_Department_Transportation;
            Finding__c finding = new Finding__c(
                RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID,
                EIS_Responsible_Department__c = responsibleDept,
                EIS_Repeat_Finding__c = true
            );
            
            Map<String, String> params = new Map<String, String>();
            params.put('auditId', audit.Id);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            params.put('clickedDepartment', Label.EIS_Finding_Department_Engineering);
            params.put('clickedRepeatFinding', 'true');
            
            Test.startTest();
            response = EIS_Audit_ObservationCtrl.updateFinding(params);
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            params.put('clickedDepartment', Label.EIS_Finding_Department_Environment);
            
            response = EIS_Audit_ObservationCtrl.updateFinding(params);
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            params.put('clickedDepartment', Label.EIS_Finding_Department_Material);
            
            response = EIS_Audit_ObservationCtrl.updateFinding(params);
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            params.put('clickedDepartment', Label.EIS_Finding_Department_Mechanical);
            
            response = EIS_Audit_ObservationCtrl.updateFinding(params);
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            params.put('clickedDepartment', Label.EIS_Finding_Department_Transportation);
            
            response = EIS_Audit_ObservationCtrl.updateFinding(params);
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            Test.stopTest();
            
            System.assert(String.isNotBlank(finding.Id));
        }
    }
        
    @isTest
    public static void deleteFinding_Test() {
        Map<String, String> response = null;
        User amtrakUser = EIS_TestDataUtils.createAmtrakUser(Label.EIS_Permission_Set_API_APM);
        System.runAs(amtrakUser) {
        	Audit_Inspections__c audit = EIS_TestDataUtils.createInspection(null, null, EIS_StaticUtils.INSPECTION_AUDIT_FORM_RTID);
            Schema.DescribeFieldResult fieldResult = EIS_Audit_Question__mdt.Protocol_Name__c.getDescribe();
        	audit.EIS_Protocol_Name__c = EIS_Audit_BodyCtrl_Test.setListToString_Semicolon(EIS_StaticUtils.getPicklistValues(fieldResult));
            EIS_Audit_Question__mdt metaQ = [
                SELECT Question_Id__c, Question_Name__c, Qualifier_Name__c, Protocol_Name__c 
                FROM EIS_Audit_Question__mdt 
                WHERE Protocol_Name__c =: audit.EIS_Protocol_Name__c.split(';')[0] ORDER BY Question_Id__c LIMIT 1
            ];
            Questions__c question = new Questions__c(
                RecordTypeId = EIS_StaticUtils.QUESTIONS_INSPECTION_RTID,
            	EIS_Metadata_Question_Id__c = metaQ.Question_Id__c,
                Audit_Inspections__c = audit.Id,
        		EIS_Issued__c = false,
            	EIS_Corrected__c = true,
        		EIS_Criticality__c = Label.EIS_Questions_Criticality_Critical,
                EIS_Count_Finding_Transportation__c = 0, EIS_Count_Finding_Engineering__c = 0, EIS_Count_Finding_Environment__c = 0, EIS_Count_Finding_Material__c = 0, 
                EIS_Count_Finding_Mechanical__c = 0, EIS_Count_Repeat_Transportation__c = 0, EIS_Count_Repeat_Engineering__c = 0, EIS_Count_Repeat_Environment__c = 0, 
                EIS_Count_Repeat_Material__c = 0, EIS_Count_Repeat_Mechanical__c = 0, EIS_Observation_Level__c = Label.EIS_Questions_Obs_Level_PV,
        		EIS_Question_Text__c = metaQ.Question_Name__c,
                EIS_Qualifier_Name__c = metaQ.Qualifier_Name__c,
        		EIS_Protocol_Name__c = metaQ.Protocol_Name__c
            );
            insert question;
            String responsibleDept = Label.EIS_Finding_Department_Engineering + ';' + Label.EIS_Finding_Department_Environment + ';' +
                Label.EIS_Finding_Department_Material + ';' + Label.EIS_Finding_Department_Mechanical + ';' + Label.EIS_Finding_Department_Transportation;
                
            Finding__c finding = new Finding__c(
                RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID,
                EIS_Responsible_Department__c = responsibleDept,
                Question__c = question.Id,
                EIS_Repeat_Finding__c = false
            );
            insert finding;
            
            Finding__c findingRepeat = new Finding__c(
                RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID,
                EIS_Responsible_Department__c = responsibleDept,
                Question__c = question.Id,
                EIS_Repeat_Finding__c = true
            );
            insert findingRepeat;
            
            Finding__c extraFinding = new Finding__c(
                RecordTypeId = EIS_StaticUtils.FINDING_INSPECTION_RTID,
                EIS_Responsible_Department__c = responsibleDept,
                Question__c = question.Id,
                EIS_Repeat_Finding__c = true
            );
            insert extraFinding;
            
            Map<String, String> params = new Map<String, String>();
            params.put('auditId', audit.Id);
            params.put('findingJSON', JSON.serialize(finding));
            params.put('questionJSON', JSON.serialize(question));
            
            Test.startTest();
            response = EIS_Audit_ObservationCtrl.deleteFinding(params);
            
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            params.put('findingJSON', JSON.serialize(findingRepeat));
            params.put('questionJSON', JSON.serialize(question));
            
            response = EIS_Audit_ObservationCtrl.deleteFinding(params);
            
            question = (Questions__c)JSON.deserialize(response.get('question'), Questions__c.class);
            params.put('findingJSON', JSON.serialize(extraFinding));
            params.put('questionJSON', JSON.serialize(question));
            
			response = EIS_Audit_ObservationCtrl.deleteFinding(params);            
            Test.stopTest();
            
            finding = (Finding__c)JSON.deserialize(response.get('finding'), Finding__c.class);
            System.assert(String.isBlank(finding.Id));
        }
    }
    
    @isTest
    public static void exceptionHanding_Test() {
        Test.startTest();
        Map<String, String> response = null;
        response = EIS_Audit_ObservationCtrl.updateFinding(null); 
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Audit_ObservationCtrl.deleteFinding(null); 
        System.assert(String.isNotBlank(response.get('errorMsg')));
        Test.stopTest();
    }
}