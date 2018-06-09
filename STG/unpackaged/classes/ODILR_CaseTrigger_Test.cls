@isTest
public class ODILR_CaseTrigger_Test {
    
    @testSetup
    private static void setup()
    {
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        
        Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employee1@test.com');
        insert employee;
        Contact supervisorContact1 = new Contact(LastName='SupervisorContact', AccountId = testAcc.id, Email = 'supervisor@test.com');
        insert supervisorContact1;
        Contact testContact = new Contact(LastName='TestContact', AccountId = testAcc.id, ODILR_Supervisor__c = supervisorContact1.Id, Email= 'contact@test.com', ODILR_Is_LR_Handler__c=True);
        insert testContact;
        Contact supervisorContact2 = new Contact(LastName='SupervisorContact2', AccountId = testAcc.id, Email = 'supervisor2@test.com');
        insert supervisorContact2;
        Contact testContact2 = new Contact(LastName='TestContact2', AccountId = testAcc.id, ODILR_Supervisor__c = supervisorContact2.Id, Email= 'contact2@test.com', ODILR_Is_LR_Handler__c=True);
        insert testContact2;
         Union__c testUnion = new Union__c(Name = 'TestUnion', ODILR_Director__c = testContact.id);
        insert testUnion;
        ODILR_Hierarchy_Setting__c cs = ODILR_Hierarchy_Setting__c.getOrgDefaults();
        cs.ODILR_Mulesoft_API_CID__c = '6f90b6663d40454a9b9a973d34164a46';
        cs.ODILR_Mulesoft_API_CSEC__c = 'EaB2983de66045e2a6D3da358bf4Bf1d';
        cs.ODILR_Mulesoft_API_Endpoint__c = 'https://dev-api.amtrak.com/sfdc-doc/folders/folder';
        cs.ODILR_MuleSoft_API_Timeout__c = 5000;
        upsert cs;
        List<RecordType> caseDecRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];
        Case testCaseSetUpObj = new Case(ContactId = employee.Id,
                                         ODILR_ODI_Number__c = '324',
                                         Charge_Date__c = Date.Today(),
                                         Incident_Date__c = Date.Today(),
                                         Subject = 'TestCase',  
                                         Outcome__c = 'Held',
                                         Union__c = testUnion.id,
                                         RecordTypeId = caseDecRecList[0].Id,
                                         Describe_Offense__c = 'Test offense',
                                         ODILR_File_Number_Second_Level__c = '32321',
                                         Appeal_Received_Date_Second_Level__c= Date.Today(),
                                         ODILR_Handler_Second_Level__c = testContact.id,
                                         Decision_Second_Level__c = 'Paid',
                                         Decision_Date_Second_Level__c = Date.Today(),
                                         ODILR_File_Number_Third_Level__c = '434494',
                                         Appeal_Received_Date_Third_Level__c= Date.Today(),
                                         ODILR_Handler_Third_Level__c = testContact.id,
                                         Decision_Third_Level__c = 'Paid',
                                         Decision_Date_Third_Level__c = Date.Today(),
                                         ODILR_Advocate__c= testContact.id);
                                        
                                        
        insert testCaseSetUpObj;
    }
    
    private static testmethod void testCaseInsert()
    {
        
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employee2@test.com');
        insert employee;
        
        Contact testContact = [Select Id, Name, ODILR_Supervisor__r.Email from Contact where Name = 'TestContact' LIMIT 1];
        Union__c testUnion = [Select Id from Union__c where Name = 'TestUnion' LIMIT 1];
        List<RecordType> caseDecRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];
        Case testCaseObj = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase',  
                                         ODILR_ODI_Number__c = '303',
                                         Charge_Date__c = Date.Today(),
                                         Incident_Date__c = Date.Today(),
                                         Outcome__c = 'Held',
                                         Describe_Offense__c = 'Test offense',
                                         ODILR_File_Number_Second_Level__c = '32849',
                                         Appeal_Received_Date_Second_Level__c= Date.Today(),
                                         ODILR_Handler_Second_Level__c = testContact.id, 
                                         Decision_Second_Level__c = 'Paid',
                                         Decision_Date_Second_Level__c = Date.Today(),
                                         ODILR_File_Number_Third_Level__c = '434890',
                                         Appeal_Received_Date_Third_Level__c= Date.Today(),
                                         ODILR_Handler_Third_Level__c = testContact.id,  
                                         Decision_Third_Level__c = 'Paid',
                                         Decision_Date_Third_Level__c = Date.Today(),
                                         ODILR_Advocate__c= testContact.id, 
                                         Union__c = testUnion.id,
                                         RecordTypeId = caseDecRecList[0].Id);
        Test.startTest();
        insert testCaseObj;
        Test.stopTest();
        Case tempCaseObj = [Select id,Subject, Handler_Supv_Email_Second_Level__c, Handler_Supv_Email_Third_Level__c, Advocate_Supv_Email_Board_Level__c,Union_Director_Email__c from Case where id=:testCaseObj.id LIMIT 1];
        system.assertEquals(tempCaseObj.Handler_Supv_Email_Second_Level__c, testContact.ODILR_Supervisor__r.Email);
        system.assertEquals(tempCaseObj.Handler_Supv_Email_Third_Level__c, testContact.ODILR_Supervisor__r.Email);
        system.assertEquals(tempCaseObj.Advocate_Supv_Email_Board_Level__c, testContact.ODILR_Supervisor__r.Email);
    }
     private static testmethod void testCaseUpdate()
    {
       Case testCaseObj = [Select id,Subject, Handler_Supv_Email_Second_Level__c, Handler_Supv_Email_Third_Level__c, Advocate_Supv_Email_Board_Level__c,Union_Director_Email__c from Case where Subject = 'TestCase' LIMIT 1];
        Contact testContact = [Select Id, Name, ODILR_Supervisor__r.Email from Contact where Name = 'TestContact2' LIMIT 1];
        testCaseObj.ODILR_Handler_Second_Level__c = testContact.id;
        Test.startTest(); 
        update testCaseObj;
        Test.stopTest();
        Case tempCaseObj = [Select id,Subject, Handler_Supv_Email_Second_Level__c, Handler_Supv_Email_Third_Level__c, Advocate_Supv_Email_Board_Level__c,Union_Director_Email__c from Case where id=:testCaseObj.id LIMIT 1];
        system.assertEquals(tempCaseObj.Handler_Supv_Email_Second_Level__c, testContact.ODILR_Supervisor__r.Email);
    }
      private static testmethod void testCustomSettings()
    {
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        Contact employee = new Contact(LastName='Employee', FirstName='Test', Personnel_Number__c = 57839,AccountId = testAcc.id, Email = 'employee3@test.com');
        insert employee;
        List<RecordType> caseRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Claims' Limit 1];
        Contact testContact = [Select Id, Name, ODILR_Supervisor__r.Email from Contact where Name = 'TestContact' LIMIT 1];
        Union__c testUnion = [Select Id from Union__c where Name = 'TestUnion' LIMIT 1];
        Case testCaseObj = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase',  
                                         Outcome__c = 'Held',
                                         ODILR_ODI_Number__c = '3378',
                                         Charge_Date__c = Date.Today(),
                                         Incident_Date__c = Date.Today(),
                                         Describe_Offense__c = 'Test offense',
                                         ODILR_File_Number_Second_Level__c = '323763',
                                         Appeal_Received_Date_Second_Level__c= Date.Today(),
                                         ODILR_Handler_Second_Level__c = testContact.id, 
                                         Decision_Second_Level__c = 'Paid',
                                         Decision_Date_Second_Level__c = Date.Today(),
                                         ODILR_File_Number_Third_Level__c = '434420',
                                         Appeal_Received_Date_Third_Level__c= Date.Today(),
                                         ODILR_Handler_Third_Level__c = testContact.id,  
                                         Decision_Third_Level__c = 'Paid',
                                         Decision_Date_Third_Level__c = Date.Today(),
                                         ODILR_Advocate__c= testContact.id, 
                                         Union__c = testUnion.id,
                                         Board_Level_Case_Number__c = '78393',
                                         Board_Number__c = '1DIV',
                                         Entered_Date__c = Date.today(),
                                         No_Of_Case_Agreement_Issues__c = 1,
                                         RecordTypeId = caseRecList[0].Id);
        Test.startTest();
        insert testCaseObj;
        Test.stopTest();
        Case tempCaseObj = [Select id,Subject, Handler_Supv_Email_Second_Level__c, Handler_Supv_Email_Third_Level__c, Advocate_Supv_Email_Board_Level__c,Union_Director_Email__c from Case where id=:testCaseObj.id LIMIT 1];
        system.assertEquals(tempCaseObj.Handler_Supv_Email_Second_Level__c, 'supervisor@test.com');
        system.assertEquals(tempCaseObj.Handler_Supv_Email_Third_Level__c, 'supervisor@test.com');
        system.assertEquals(tempCaseObj.Advocate_Supv_Email_Board_Level__c, 'supervisor@test.com');
        
    }
    
    private static testmethod void testChildRecords()
    {    
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employeech@test.com');
        insert employee;
                
        List<RecordType> caseDecRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];
        List<RecordType> caseClmRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Claims' Limit 1];
        
        Case testDiscCaseObj = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase', 
                                         ODILR_ODI_Number__c = '123',
                                         Incident_Date__c = Date.Today(),
                                         Charge_Date__C = Date.Today(), 
                                         No_Of_Case_Violations__c = 1,
                                         Describe_Offense__c = 'Test offense',
                                         RecordTypeId = caseDecRecList[0].Id);
        insert testDiscCaseObj;        
        
        List<RecordType> vioDiscRecList = [Select Id from RecordType WHERE SobjectType = 'Violation__c' and Name = 'ODILR Discipline' Limit 1];
        
        try{
            Violation__c vioDisc = new Violation__c(ODILR_Case__c = testDiscCaseObj.Id, ODILR_Violation__c = 'Absenteeism', ODILR_Additional_Information__c = 'Excessive',RecordTypeId = vioDiscRecList[0].Id);
            insert vioDisc;
        }
        catch(DMLException ex){
            System.debug('Exception occured creating violation');
        }
        
        Case tempCaseObjUpd = [Select id,No_Of_Case_Violations__c,No_Of_Case_Agreement_Issues__c  from Case where id=:testDiscCaseObj.id LIMIT 1];
        System.debug('No1 ' + tempCaseObjUpd.No_Of_Case_Violations__c + ' No2 ' + tempCaseObjUpd.No_Of_Case_Agreement_Issues__c);
        
        Disciplinary_Action__c da = new Disciplinary_Action__c(ODILR_Case__c = tempCaseObjUpd.Id, ODILR_Discipline_Assessed__c = 'Other', ODILR_No_Of_Days__c = 3);
        insert da;
        da.ODILR_No_Of_Days__c = 5;
        update da;
        delete da;
    }
    public static testmethod void testFOPUnion()
    {
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        Union__c testUnion = new Union__c(Name='FOP');
        insert testUnion;
        Position__c pos = new Position__c(Position_ID__c = '233',Personnel_SubArea_Text__c = 'FOP');
        insert pos;
        Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employeech@test.com', PositionLookup__c= pos.Id);
        insert employee;
        
        
        List<RecordType> caseDecRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];
        
        Case testDiscCaseObj = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase', 
                                         ODILR_ODI_Number__c = '123',
                                         Incident_Date__c = Date.Today(),
                                         Charge_Date__C = Date.Today(),
                                         Describe_Offense__c = 'Test offense',
                                         RecordTypeId = caseDecRecList[0].Id);
        Test.startTest();
        insert testDiscCaseObj;        
        Test.stopTest();
        Case tempCaseObj = [Select id,Subject, Union__c from Case where id=:testDiscCaseObj.id LIMIT 1];
        system.assertEquals(testUnion.Id,tempCaseObj.Union__c);
        
    }
    
    public static testmethod void testMuleSoftAPICallout()
    {
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employeech@test.com');
        insert employee;
        Union__c testUnion = new Union__c(Name='FOP');
        insert testUnion;
        List<RecordType> caseDecRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];
        
        Case testDiscCaseObj = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase', 
                                         ODILR_ODI_Number__c = '123',
                                         Incident_Date__c = Date.Today(),
                                         Charge_Date__C = Date.Today(),
                                         Describe_Offense__c = 'Test offense',
                                         RecordTypeId = caseDecRecList[0].Id);
        Test.setMock(HttpCalloutMock.class, new caseMuleSoftMock());
        Test.startTest();
        insert testDiscCaseObj;        
        Test.stopTest();
        
    }
    private class caseMuleSoftMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            return res;
        }
    }
}