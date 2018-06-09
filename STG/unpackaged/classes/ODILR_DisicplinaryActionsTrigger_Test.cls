@isTest
public class ODILR_DisicplinaryActionsTrigger_Test {
@testSetup
    private static void setup()
    {
      Account testAcc = new Account(Name='TestAccount');
      insert testAcc;
      
      Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employeevt@test.com');
      insert employee;
      
      ODILR_Hierarchy_Setting__c cs = ODILR_Hierarchy_Setting__c.getOrgDefaults();
      cs.ODILR_Mulesoft_API_CID__c = '6f90b6663d40454a9b9a973d34164a46';
      cs.ODILR_Mulesoft_API_CSEC__c = 'EaB2983de66045e2a6D3da358bf4Bf1d';
      cs.ODILR_Mulesoft_API_Endpoint__c = 'https://dev-api.amtrak.com/sfdc-doc/folders/folder';
      cs.ODILR_MuleSoft_API_Timeout__c = 5000;
      upsert cs;
        
      
      List<RecordType> caseRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];      
      Case testCaseObj = new Case(Subject = 'TestCase',
                                  ContactId=employee.Id, 
                                  ODILR_ODI_Number__c = '324',
                                  Charge_Date__c = Date.Today(),
                                  Incident_Date__c = Date.Today(),
                                  RecordTypeId = caseRecList[0].Id,
                                  Describe_Offense__c = 'Test offense',
                                  No_Of_Case_Violations__c = 1);
                       
      insert testCaseObj;
    }
    
    private static testmethod void testDisciplinaryActionInsert()
    {
        Case testCaseobjct = [Select Id, RecordType.Name from Case where Subject = 'TestCase' LIMIT 1];
        List<Disciplinary_Action__c> discActionList = new List<Disciplinary_Action__c>();
                
        Disciplinary_Action__c testDiscAction1 = new Disciplinary_Action__c(ODILR_Case__c = testCaseObjct.id, ODILR_Discipline_Assessed__c = 'Suspend', ODILR_No_Of_Days__c = 5);
        Disciplinary_Action__c testDiscAction2 = new Disciplinary_Action__c(ODILR_Case__c = testCaseObjct.id, ODILR_Discipline_Assessed__c = 'Deferred', ODILR_No_Of_Days__c = 6, ODILR_Appellate_Modification__c = 'Suspend', ODILR_LR_Of_Days__c = 3 );
        discActionList.Add(testDiscAction1);
        discActionList.Add(testDiscAction2);
        
        Test.startTest();
        insert discActionList;
        Test.stopTest();
        
        Case tempCaseObj = [Select id, Discipline_Assessed_List__c, Appellate_Modification_List__c from Case where id=:testCaseobjct.id LIMIT 1];
        system.debug('Discipline assessed list is ' + tempCaseObj.Discipline_Assessed_List__c);
        system.assertEquals(tempCaseObj.Discipline_Assessed_List__c, testDiscAction1.ODILR_Discipline_Assessed__c +'*'+ testDiscAction1.ODILR_No_Of_Days__c + ',' + testDiscAction2.ODILR_Discipline_Assessed__c +'*'+ testDiscAction2.ODILR_No_Of_Days__c);
        system.assertEquals(tempCaseObj.Appellate_Modification_List__c , testDiscAction2.ODILR_Appellate_Modification__c +'*'+ testDiscAction2.ODILR_LR_Of_Days__c);
    }
    
    
    private static testmethod void testDisciplinaryActionUpdate()
    {
        Case testCaseobjct = [Select Id, RecordType.Name from Case where Subject = 'TestCase' LIMIT 1];
        List<Disciplinary_Action__c> discActionList = new List<Disciplinary_Action__c>();
                
        Disciplinary_Action__c testDiscAction1 = new Disciplinary_Action__c(ODILR_Case__c = testCaseObjct.id, ODILR_Discipline_Assessed__c = 'Suspend', ODILR_No_Of_Days__c = 5);
        insert testDiscAction1 ;
        testDiscAction1.ODILR_Discipline_Assessed__c = 'Deferred';
        
        Test.startTest();
        update testDiscAction1;
        Test.stopTest();
        
        Case tempCaseObj = [Select id, Discipline_Assessed_List__c, Appellate_Modification_List__c from Case where id=:testCaseobjct.id LIMIT 1];
        system.debug(tempCaseObj.Discipline_Assessed_List__c);
        system.assertEquals(tempCaseObj.Discipline_Assessed_List__c, testDiscAction1.ODILR_Discipline_Assessed__c +'*'+ testDiscAction1.ODILR_No_Of_Days__c);
    }
    
    private static testmethod void testDisciplinaryActiondelete()
    {
        Case testCaseobjct = [Select Id, RecordType.Name from Case where Subject = 'TestCase' LIMIT 1];
        List<Disciplinary_Action__c> discActionList = new List<Disciplinary_Action__c>();
                
        Disciplinary_Action__c testDiscAction1 = new Disciplinary_Action__c(ODILR_Case__c = testCaseObjct.id, ODILR_Discipline_Assessed__c = 'Suspend', ODILR_No_Of_Days__c = 5);
        Disciplinary_Action__c testDiscAction2 = new Disciplinary_Action__c(ODILR_Case__c = testCaseObjct.id, ODILR_Discipline_Assessed__c = 'Suspend', ODILR_No_Of_Days__c = 7, ODILR_Appellate_Modification__c = 'Deferred', ODILR_LR_Of_Days__c = 6);
           
        insert testDiscAction1; 
        insert testDiscAction2; 
            
        Test.startTest();
        delete testDiscAction2;
        Test.stopTest();
        
        Case tempCaseObj = [Select id, Discipline_Assessed_List__c, Appellate_Modification_List__c from Case where id=:testCaseobjct.id LIMIT 1];
        system.assertEquals(tempCaseObj.Discipline_Assessed_List__c, testDiscAction1.ODILR_Discipline_Assessed__c +'*'+ testDiscAction1.ODILR_No_Of_Days__c);
    }
}