@isTest
public class ODILR_ViolationsTrigger_Test {
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
                                  Describe_Offense__c = 'Test offense',
                                  RecordTypeId = caseRecList[0].Id);
      insert testCaseObj;
    }
    
    private static testmethod void testViolationInsert()
    {
        Case testCaseobjct = [Select Id, RecordType.Name from Case where Subject = 'TestCase' LIMIT 1];
        List<Violation__c> violationList = new List<Violation__c>();
        
        List<RecordType> vlRecList = [Select Id from RecordType WHERE SobjectType = 'Violation__c' and Name = 'ODILR Discipline' Limit 1]; 
        if(vlRecList.size() <= 0)
            return;
        
        Violation__c testViolationObj1 = new Violation__c(ODILR_Case__c = testCaseObjct.id, ODILR_Violation__c = 'Absenteeism', ODILR_Additional_Information__c = 'Excessive',RecordTypeID = vlRecList[0].Id);
        Violation__c testViolationObj2 = new Violation__c(ODILR_Case__c = testCaseObjct.id, ODILR_Violation__c = 'Dishonesty', ODILR_Additional_Information__c = 'Bribery',RecordTypeID = vlRecList[0].Id);
           
        ViolationList.Add(testViolationObj1); 
        ViolationList.Add(testViolationObj2); 
            
        Test.startTest();
        insert violationList;
        Test.stopTest();
        
        Case tempCaseObj = [Select id, Disciplinary_Violation_List__c from Case where id=:testCaseobjct.id LIMIT 1];
        system.debug(tempCaseObj.Disciplinary_Violation_List__c);
        system.assertEquals(tempCaseObj.Disciplinary_Violation_List__c, testViolationObj1.ODILR_Violation__c+'-'+testViolationObj1.ODILR_Additional_Information__c  +','+testViolationObj2.ODILR_Violation__c+'-'+testViolationObj2.ODILR_Additional_Information__c);
    }
    
    
    private static testmethod void testViolationUpdate()
    {
        Case testCaseobjct = [Select Id, RecordType.Name from Case where Subject = 'TestCase' LIMIT 1];
        
        List<RecordType> vlRecList = [Select Id from RecordType WHERE SobjectType = 'Violation__c' and Name = 'ODILR Discipline' Limit 1]; 
        if(vlRecList.size() <= 0)
            return;
            
        Violation__c testViolationObj1 = new Violation__c(ODILR_Case__c = testCaseObjct.id, ODILR_Violation__c = 'Absenteeism', ODILR_Additional_Information__c = 'Excessive',RecordTypeID = vlRecList[0].Id);
        insert testViolationObj1;
        testViolationObj1.ODILR_Violation__c = 'Dishonesty';
        
        Test.startTest();
        update testViolationObj1;
        Test.stopTest();
        
        Case tempCaseObj = [Select id, Disciplinary_Violation_List__c from Case where id=:testCaseobjct.id LIMIT 1];
        system.debug(tempCaseObj.Disciplinary_Violation_List__c);
        system.assertEquals(tempCaseObj.Disciplinary_Violation_List__c, testViolationObj1.ODILR_Violation__c+'-'+testViolationObj1.ODILR_Additional_Information__c);
    }
    private static testmethod void testViolationdelete()
    {
        Case testCaseobjct = [Select Id, RecordType.Name from Case where Subject = 'TestCase' LIMIT 1];
        
        List<RecordType> vlRecList = [Select Id from RecordType WHERE SobjectType = 'Violation__c' and Name = 'ODILR Discipline' Limit 1]; 
        if(vlRecList.size() <= 0)
            return;
        
        Violation__c testViolationObj1 = new Violation__c(ODILR_Case__c = testCaseObjct.id, ODILR_Violation__c = 'Absenteeism', ODILR_Additional_Information__c = 'Excessive',RecordTypeID = vlRecList[0].Id);
        Violation__c testViolationObj2 = new Violation__c(ODILR_Case__c = testCaseObjct.id, ODILR_Violation__c = 'Dishonesty', ODILR_Additional_Information__c = 'Bribery',RecordTypeID = vlRecList[0].Id);
    
        insert testViolationObj1;
        insert testViolationObj2;
        
        Test.startTest();
        delete testViolationObj2;
        Test.stopTest();
        
        Case tempCaseObj = [Select id, Disciplinary_Violation_List__c from Case where id=:testCaseobjct.id LIMIT 1];
        system.debug(tempCaseObj.Disciplinary_Violation_List__c);
        system.assertEquals(tempCaseObj.Disciplinary_Violation_List__c, testViolationObj1.ODILR_Violation__c+'-'+testViolationObj1.ODILR_Additional_Information__c);
    }
}