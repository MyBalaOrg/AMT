/**
*————————————————————————————————————————————————————
* @Name             ODILR_Case_MainCtrlTest
* @Author           Sarang Padhye
* @Created Date     09-17-2017
* @Used By          ODILR_Case_Main.cmp
*————————————————————————————————————————————————————
* @Description
* Test class for the ODILR_Case_MainCtrlTest
* 
*————————————————————————————————————————————————————
* @Changes
*
**/
@isTest
public class ODILR_Case_MainCtrlTest {
    
    static testMethod void testGetDisciplineCaseFields() {
        
        String caseTabLabelDetail = '';
        String caseTabLabelEmpInfo = '';
        String caseTabLabelDescOff = '';
        String caseTabLabelODI = '';
        String caseTabLabelODIOffense = '';
        String caseTabLabelLR2 = '';
        String caseTabLabelLR3 = '';
        String caseTabLabelBoard = '';
        
        caseTabLabelDetail = ODILR_Case_MainCtrl.getDisciplineCaseFields(Label.ODILR_Case_Tab_Label_Detail);
        system.assert(caseTabLabelDetail!='');
        
        caseTabLabelEmpInfo = ODILR_Case_MainCtrl.getDisciplineCaseFields(Label.ODILR_Case_Tab_Label_Employee_Info);
        system.assert(caseTabLabelEmpInfo!='');
        
        caseTabLabelDescOff = ODILR_Case_MainCtrl.getDisciplineCaseFields(Label.ODILR_Case_Tab_Label_Describe_Offense);
        system.assert(caseTabLabelDescOff!='');
        
        caseTabLabelODI = ODILR_Case_MainCtrl.getDisciplineCaseFields(Label.ODILR_Case_Tab_Label_ODI);
        system.assert(caseTabLabelODI!='');
        
        caseTabLabelODIOffense = ODILR_Case_MainCtrl.getDisciplineCaseFields(Label.ODILR_Case_Tab_Label_ODI_Outcome);
        system.assert(caseTabLabelODIOffense!='');
        
        caseTabLabelLR2 = ODILR_Case_MainCtrl.getDisciplineCaseFields(Label.ODILR_Case_Tab_Label_LR2);
        system.assert(caseTabLabelLR2!='');
        
        caseTabLabelLR3 = ODILR_Case_MainCtrl.getDisciplineCaseFields(Label.ODILR_Case_Tab_Label_LR3);
        system.assert(caseTabLabelLR3!='');
        
        caseTabLabelBoard = ODILR_Case_MainCtrl.getDisciplineCaseFields(Label.ODILR_Case_Tab_Label_Board);
        system.assert(caseTabLabelBoard!='');
    }
    
    static testMethod void testGetClaimsCaseFields() {
        
        String caseTabLabelDetail = '';
        String caseTabLabelEmpInfo = '';
        String caseTabLabelDescOff = '';
        String caseTabLabelODIOffense = '';
        String caseTabLabelLR2 = '';
        String caseTabLabelLR3 = '';
        String caseTabLabelBoard = ''; 
        
        caseTabLabelDetail = ODILR_Case_MainCtrl.getClaimsCaseFields(Label.ODILR_Case_Tab_Label_Detail);
        system.assert(caseTabLabelDetail!='');
        
        caseTabLabelEmpInfo = ODILR_Case_MainCtrl.getClaimsCaseFields(Label.ODILR_Case_Tab_Label_Employee_Info);
        system.assert(caseTabLabelEmpInfo!='');
        
        caseTabLabelDescOff = ODILR_Case_MainCtrl.getClaimsCaseFields(Label.ODILR_Case_Tab_Label_Describe_Offense);
        system.assert(caseTabLabelDescOff!='');
         
        caseTabLabelLR2 = ODILR_Case_MainCtrl.getClaimsCaseFields(Label.ODILR_Case_Tab_Label_LR2);
        system.assert(caseTabLabelLR2!='');
        
        caseTabLabelLR3 = ODILR_Case_MainCtrl.getClaimsCaseFields(Label.ODILR_Case_Tab_Label_LR3);
        system.assert(caseTabLabelLR3!='');
        
        caseTabLabelBoard = ODILR_Case_MainCtrl.getClaimsCaseFields(Label.ODILR_Case_Tab_Label_Board);
        system.assert(caseTabLabelBoard!='');
        
    }
    
    static testMethod void testGetCaseTabList() {
        List<String> tablist = new List<String>();
        tabList = ODILR_Case_MainCtrl.getCaseTabList(Label.ODILR_Discipline_Record_Type);
        system.assert(tabList.size() > 0);        
    }
    
    static testMethod void testGetFieldNameFromReferenceName() {
        system.assert(ODILR_Case_MainCtrl.getFieldNameFromReferenceName('test__r') == 'test__c');
    }
    
    static testMethod void testInitializeCaseCreationPage() {
        String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.ODILR_Claims_Record_Type).getRecordTypeId();
        Map<String, String> response = ODILR_Case_MainCtrl.initializeCaseCreationPage(recordTypeId);
        system.assert(!response.isEmpty());
        
        Map<String, String> errResponse = ODILR_Case_MainCtrl.initializeCaseCreationPage('');
        system.assert(!errResponse.isEmpty());
    }
    
    static testMethod void testSaveNewCaseRecord() {
        Account account = TestHandler.createAccount('testAccount');
        insert account;
            
        Contact contact = TestHandler.createTestContact('TestLastName', account.id, null, null);
        insert contact;
        
        ODILR_Hierarchy_Setting__c cs = ODILR_Hierarchy_Setting__c.getOrgDefaults();
        cs.ODILR_Mulesoft_API_CID__c = '6f90b6663d40454a9b9a973d34164a46';
        cs.ODILR_Mulesoft_API_CSEC__c = 'EaB2983de66045e2a6D3da358bf4Bf1d';
        cs.ODILR_Mulesoft_API_Endpoint__c = 'https://dev-api.amtrak.com/sfdc-doc/folders/folder';
        cs.ODILR_MuleSoft_API_Timeout__c = 5000;
        upsert cs;
        
        Case newCase = new Case();
        newCase.AccountId = account.Id;
        newCase.Case_Level__c = 'Level 1';
        newCase.ContactId = contact.Id;
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.ODILR_Claims_Record_Type).getRecordTypeId();
        
        String caseJson = JSON.serialize(newCase);
        
        ODILR_Case_MainCtrl.saveNewCaseRecord(caseJson);
        
        ODILR_Case_MainCtrl.saveNewCaseRecord('');

        ODILR_Case_MainCtrl.initializeCaseRecord(newCase.Id, Label.ODILR_Claims_Record_Type);
        ODILR_Case_MainCtrl.initializeCaseRecord(newCase.Id, '');
        ODILR_Case_MainCtrl.initializeCaseRecord('', Label.ODILR_Claims_Record_Type);
        ODILR_Case_MainCtrl.saveCaseRecord(Label.ODILR_Claims_Record_Type, caseJson);
        ODILR_Case_MainCtrl.getItemsForTypeaheadSearch('test','Case', 'Does Not Exist');
        ODILR_Case_MainCtrl.getItemsForTypeaheadSearch('TestLastName','Contact', 'Does Not Exist');
        
        Case newCase2 = new Case();
        newCase2.AccountId = account.Id;
        newCase2.Case_Level__c = 'Level 1';
        newCase2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.ODILR_Discipline_Record_Type).getRecordTypeId();
        String caseJson2 = JSON.serialize(newCase2);
        
        ODILR_Case_MainCtrl.saveNewCaseRecord(caseJson2);
        
        ODILR_Case_MainCtrl.saveNewCaseRecord('');
    }

}