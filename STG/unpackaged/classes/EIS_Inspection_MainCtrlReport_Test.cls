/**
*—————————————————————————————————————————————————————————————————————————
* @Name             EIS_Inspection_MainCtrlReport_Test
* @Author           Kumar Suyash
* @Created Date     07-5-2017
* @Used By          EIS_Inspection_MainCtrlReport
*—————————————————————————————————————————————————————————————————————————
* @Description
* Test Class for EIS_Inspection_MainCtrlReport 
*—————————————————————————————————————————————————————————————————————————
* @Changes
* 
**/
@isTest
public class EIS_Inspection_MainCtrlReport_Test{
    @isTest
    public static void test1(){
        EIS_TestDataUtils.insertCustomSettings();
        Test.startTest();
            //Create Test Data
            Account acc = EIS_TestDataUtils.createAccount('TestAcc');
            Contact  con = EIS_TestDataUtils.createInternalContact(acc);
            Id recId1 = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(Label.EIS_Location_Main_Record_Type_Label).getRecordTypeId();
            Location__c loc1 = new Location__C(RecordTypeId = recId1, Name = 'Hello Kitty Island');
            insert loc1;
            Site__c facility = EIS_TestDataUtils.createMainFacility(null);
            Id recId = Schema.SObjectType.Audit_Inspections__c.getRecordTypeInfosByName().get(Label.EIS_Inspection_Commissary_Record_Type_Label).getRecordTypeId();
            Audit_Inspections__c auditInsp = EIS_TestDataUtils.createInspection(facility, con, recId);
            auditInsp.EIS_Department_Score_Engineering__c = 0;
            questions__c ques = EIS_TestDataUtils.createInspectionQuestion(auditInsp, 'critical');
            ques = new Questions__c(Id = ques.Id);
        	ques.EIS_Metadata_Question_Id__c = 'Test';
        	ques.EIS_Observation_Level__c = 'Potential Violation';//'Management Practice';
            update ques;
        
        	ques = new Questions__c(Id = ques.Id);
        	ques.EIS_Observation_Level__c = 'Potential Violation';
            update ques;
            Finding__c findgs = EIS_TestDataUtils.createInspectionFinding(ques);
        
        
        	Tracking__c tr = EIS_TestDataUtils.createTrackingRecord(auditInsp.Id,Label.EIS_Tracking_Temp_Type_Refrigeration);
            List<tracking__c> trackingList = new List<tracking__c>();
        	trackingList.add(tr);
            //Call the constructor
            Test.setCurrentPage(Page.EIS_AuditInspectionReportV2);
            ApexPages.StandardController sc = new ApexPages.StandardController(auditInsp);
            EIS_Inspection_MainCtrlReport ctrlClass = new EIS_Inspection_MainCtrlReport(sc);  
              
            
            ctrlClass.getAllQuestions();
            ctrlClass.RecordQuestions_Query();
            ctrlClass.getCorrectiveActions();
        	ctrlClass.getTrackingRecords(trackingList, Label.EIS_Tracking_Temp_Type_Refrigeration);
        Test.stopTest();
    }
    
    @isTest
    public static void test2(){
        EIS_TestDataUtils.insertCustomSettings();
        Test.startTest();
            //Create Test Data
            Account acc = EIS_TestDataUtils.createAccount('TestAcc');
            Contact  con = EIS_TestDataUtils.createInternalContact(acc);
            Id recId1 = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(Label.EIS_Location_Main_Record_Type_Label).getRecordTypeId();
            Location__c loc1 = new Location__C(RecordTypeId = recId1, Name = 'Hello Kitty Island');
            insert loc1;
            Site__c facility = EIS_TestDataUtils.createMainFacility(null);
            Id recId = Schema.SObjectType.Audit_Inspections__c.getRecordTypeInfosByName().get(Label.EIS_Inspection_Commissary_Record_Type_Label).getRecordTypeId();
            Audit_Inspections__c auditInsp = EIS_TestDataUtils.createInspection(facility, con, recId);
            auditInsp.EIS_Department_Score_Engineering__c = 0;
            questions__c ques = EIS_TestDataUtils.createInspectionQuestion(auditInsp, 'critical');
            ques = new Questions__c(Id = ques.Id);
        	ques.EIS_Metadata_Question_Id__c = 'Test';
        	ques.EIS_Observation_Level__c = 'Management Practice';
            update ques;
        
        	Finding__c findgs = EIS_TestDataUtils.createInspectionFinding(ques);
        
        
        	Tracking__c tr = EIS_TestDataUtils.createTrackingRecord(auditInsp.Id,Label.EIS_Tracking_Temp_Type_Refrigeration);
            List<tracking__c> trackingList = new List<tracking__c>();
        	trackingList.add(tr);
            //Call the constructor
            Test.setCurrentPage(Page.EIS_AuditInspectionReportV2);
            ApexPages.StandardController sc = new ApexPages.StandardController(auditInsp);
            EIS_Inspection_MainCtrlReport ctrlClass = new EIS_Inspection_MainCtrlReport(sc);  
              
            
            ctrlClass.getAllQuestions();
            ctrlClass.RecordQuestions_Query();
            ctrlClass.getCorrectiveActions();
        	ctrlClass.getTrackingRecords(trackingList, Label.EIS_Tracking_Temp_Type_Refrigeration);
        Test.stopTest();
    }
}