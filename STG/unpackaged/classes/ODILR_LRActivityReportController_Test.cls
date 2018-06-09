@isTest
public class ODILR_LRActivityReportController_Test {

    @testSetup    
    private static void setUp()
    {
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employee2@test.com',ODILR_Is_LR_Handler__c=True);
        insert employee;
        ODILR_Hierarchy_Setting__c cs = ODILR_Hierarchy_Setting__c.getOrgDefaults();
        cs.ODILR_Mulesoft_API_CID__c = '6f90b6663d40454a9b9a973d34164a46';
        cs.ODILR_Mulesoft_API_CSEC__c = 'EaB2983de66045e2a6D3da358bf4Bf1d';
        cs.ODILR_Mulesoft_API_Endpoint__c = 'https://dev-api.amtrak.com/sfdc-doc/folders/folder';
        cs.ODILR_MuleSoft_API_Timeout__c = 5000;
        upsert cs;
        List<RecordType> caseDecRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];
        Contact testContact = [Select Id, Name, ODILR_Supervisor__r.Email from Contact where Name = 'Employee' LIMIT 1];
        Union__c testUnionObj = new Union__c(Name = 'TestUnion', ODILR_Director__c = testContact.id);
        insert testUnionObj;
        Union__c testUnion = [Select Id from Union__c where Name = 'TestUnion' LIMIT 1];
        List<Case> caseList = new List<Case>();
        Case testCaseObj1 = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase',  
                                         ODILR_ODI_Number__c = '324',
                                         Charge_Date__c = Date.Today(),
                                         Incident_Date__c = Date.Today(),
                                         Outcome__c = 'Held',
                                         Describe_Offense__c = 'Test offense',
                                         ODILR_File_Number_Second_Level__c = '32322',
                                         Case_Level__c = 'Level 2',
                                         Appeal_Received_Date_Second_Level__c= Date.newInstance(2016,1,22),
                                         ODILR_Handler_Second_Level__c = testContact.id, 
                                         Decision_Second_Level__c = 'Paid',
                                         Decision_Date_Second_Level__c = Date.newInstance(2016,1,23),
                                         ODILR_File_Number_Third_Level__c = '434495',
                                         Appeal_Received_Date_Third_Level__c= Date.newInstance(2016,1,22),
                                         ODILR_Handler_Third_Level__c = testContact.id,  
                                         Decision_Third_Level__c = 'Paid',
                                         Decision_Date_Third_Level__c = Date.newInstance(2016,1,23),
                                         Date_Appealed_Board__c = Date.newInstance(2016,1,22),
                                         Entered_Date__c = Date.newInstance(2016,1,23),
                                         ODILR_Advocate__c= testContact.id, 
                                         Union__c = testUnion.id,
                                         Board_Number__c = '1DIV',
                                         RecordTypeId = caseDecRecList[0].Id);
        caseList.add(testCaseObj1);
        Case testCaseObj2 = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase', 
                                         ODILR_ODI_Number__c = '325',
                                         Charge_Date__c = Date.Today(),
                                         Incident_Date__c = Date.Today(),
                                         Outcome__c = 'Held',
                                         Describe_Offense__c = 'Test offense',
                                         ODILR_File_Number_Second_Level__c = '32322',
                                         Appeal_Received_Date_Second_Level__c= Date.newInstance(2017,2,22),
                                         Case_Level__c = 'Level 3',
                                         ODILR_Handler_Second_Level__c = testContact.id, 
                                         Decision_Second_Level__c = 'Paid',
                                         Decision_Date_Second_Level__c = Date.newInstance(2017,2,23),
                                         ODILR_File_Number_Third_Level__c = '434495',
                                         Appeal_Received_Date_Third_Level__c= Date.newInstance(2017,2,22),
                                         ODILR_Handler_Third_Level__c = testContact.id,  
                                         Decision_Third_Level__c = 'Paid',
                                         Decision_Date_Third_Level__c = Date.newInstance(2017,2,23),
                                         Date_Appealed_Board__c = Date.newInstance(2017,2,22),
                                         Entered_Date__c = Date.newInstance(2017,2,23),
                                         ODILR_Advocate__c= testContact.id, 
                                         Union__c = testUnion.id,
                                         Board_Number__c = '1DIV',
                                         RecordTypeId = caseDecRecList[0].Id);
        caseList.add(testCaseObj2);
        Case testCaseObj3 = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase', 
                                         ODILR_ODI_Number__c = '326',
                                         Charge_Date__c = Date.Today(),
                                         Incident_Date__c = Date.Today(),
                                         ODILR_Paid_Board_Level__c = 20,
                                         ODILR_Not_Paid_Board_Level__c = 25,
                                         Outcome__c = 'Held',
                                         Describe_Offense__c = 'Test offense',
                                         ODILR_File_Number_Second_Level__c = '32322',
                                         Appeal_Received_Date_Second_Level__c= Date.newInstance(2017,10,22),
                                         Case_Level__c = 'Board Level',
                                         ODILR_Handler_Second_Level__c = testContact.id, 
                                         Decision_Second_Level__c = 'Compromise',
                                         Decision_Date_Second_Level__c = Date.newInstance(2017,10,23),
                                         ODILR_File_Number_Third_Level__c = '434495',
                                         Appeal_Received_Date_Third_Level__c= Date.newInstance(2017,10,22),
                                         ODILR_Handler_Third_Level__c = testContact.id,  
                                         Decision_Third_Level__c = 'Compromise',
                                         Decision_Date_Third_Level__c = Date.newInstance(2017,10,23),
                                         Date_Appealed_Board__c = Date.newInstance(2017,10,22),
                                         Entered_Date__c = Date.newInstance(2017,10,23),
                                         Decision_Board_Level__c = 'Compromise',
                                         ODILR_Advocate__c= testContact.id, 
                                         Union__c = testUnion.id,
                                         Board_Number__c = '1DIV',
                                         RecordTypeId = caseDecRecList[0].Id);
        caseList.add(testCaseObj3);
        Case testCaseObj4 = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase', 
                                         ODILR_ODI_Number__c = '326',
                                         Charge_Date__c = Date.Today(),
                                         Incident_Date__c = Date.Today(),
                                         ODILR_Paid_Board_Level__c = 20,
                                         ODILR_Not_Paid_Board_Level__c = 25,
                                         Outcome__c = 'Held',
                                         Describe_Offense__c = 'Test offense',
                                         ODILR_File_Number_Second_Level__c = '32322',
                                         Appeal_Received_Date_Second_Level__c= Date.newInstance(2017,10,22),
                                         Case_Level__c = 'Board Level',
                                         ODILR_Handler_Second_Level__c = testContact.id, 
                                         Decision_Second_Level__c = 'Paid',
                                         Decision_Date_Second_Level__c = Date.newInstance(2017,10,23),
                                         ODILR_File_Number_Third_Level__c = '434495',
                                         Appeal_Received_Date_Third_Level__c= Date.newInstance(2017,10,22),
                                         ODILR_Handler_Third_Level__c = testContact.id,  
                                         Decision_Third_Level__c = 'Paid',
                                         Decision_Date_Third_Level__c = Date.newInstance(2017,10,23),
                                         Date_Appealed_Board__c = Date.newInstance(2017,10,22),
                                         Entered_Date__c = Date.newInstance(2017,10,23),
                                         ODILR_Advocate__c= testContact.id,
                                         Decision_Board_Level__c = 'Paid',
                                         Union__c = testUnion.id,
                                         Board_Number__c = '1DIV',
                                         RecordTypeId = caseDecRecList[0].Id);
        caseList.add(testCaseObj4);
        insert caseList;
    }

    private static testMethod void testLRActivityReportController_Level2()
    {
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employeech@test.com',ODILR_Is_LR_Handler__c=True);
        insert employee;
        
        Test.startTest();
        List<RecordType> caseDecRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];
        Case tempCaseObj = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase', 
                                         ODILR_ODI_Number__c = '123',
                                         Incident_Date__c = Date.Today(),
                                         Charge_Date__C = Date.Today(),
                                         Describe_Offense__c = 'Test offense',
                                         RecordTypeId = caseDecRecList[0].Id);
        insert tempCaseObj; 
        
        PageReference pageRef = Page.ODILR_LR_Activity_Report;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(tempCaseObj.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(tempCaseObj);
        ODILR_LRActivityReportController controllerObj = new ODILR_LRActivityReportController(sc);
        controllerObj.fromDate = Date.newInstance(2017,1,23);
        controllerObj.endDate = Date.newInstance(2017,8,23);
        controllerObj.getlrlevel();
        controllerObj.getreportType();
        controllerObj.getlevel();
        controllerObj.getselectedlevel();
        controllerObj.getselectedlrlevel();
        controllerObj.getselectedtype();
        controllerObj.selectedtype = 'ODILR Discipline';
        controllerObj.selectedlevel = 'Level 2';
        controllerObj.selectedlrlevel = 'None';
        controllerObj.lrOffice = 'ALL';
        List<SelectOption> selectOptions = controllerObj.getlevel();
        controllerObj.fetchRecords();
        Test.stopTest();
        
    }
        private static testMethod void testLRActivityReportController_Level3()
    {
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employeech@test.com',ODILR_Is_LR_Handler__c=True);
        insert employee;
        
        Test.startTest();
        List<RecordType> caseDecRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];
        Case tempCaseObj = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase', 
                                         ODILR_ODI_Number__c = '123',
                                         Incident_Date__c = Date.Today(),
                                         Charge_Date__C = Date.Today(),
                                         Describe_Offense__c = 'Test offense',
                                         RecordTypeId = caseDecRecList[0].Id);
        insert tempCaseObj; 
        
        PageReference pageRef = Page.ODILR_LR_Activity_Report;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(tempCaseObj.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(tempCaseObj);
        ODILR_LRActivityReportController controllerObj = new ODILR_LRActivityReportController(sc);
        controllerObj.fromDate = Date.newInstance(2017,1,23);
        controllerObj.endDate = Date.newInstance(2017,8,23);
        controllerObj.selectedtype = 'ODILR Discipline';
        controllerObj.selectedlevel = 'Level 3';
        controllerObj.selectedlrlevel = 'None';
        controllerObj.getlrlevel();
        controllerObj.getreportType();
        controllerObj.getlevel();
        controllerObj.getselectedlevel();
        controllerObj.getselectedlrlevel();
        controllerObj.getselectedtype();
        controllerObj.lrOffice = 'ALL';
        List<SelectOption> selectOptions = controllerObj.getlevel();
        controllerObj.fetchRecords();
        Test.stopTest();
    }
    private static testMethod void testLRActivityReportController_LevelBoard()
    {
        Account testAcc = new Account(Name='TestAccount');
        insert testAcc;
        Contact employee = new Contact(LastName='Employee', AccountId = testAcc.id, Email = 'employeech@test.com',ODILR_Is_LR_Handler__c=True);
        insert employee;
        
        Test.startTest();
        List<RecordType> caseDecRecList = [Select Id from RecordType WHERE SobjectType = 'Case' and Name = 'ODILR Discipline' Limit 1];
        Case tempCaseObj = new Case(ContactId = employee.Id,
                                         Subject = 'TestCase', 
                                         ODILR_ODI_Number__c = '123',
                                         Incident_Date__c = Date.Today(),
                                         Charge_Date__C = Date.Today(),
                                         Describe_Offense__c = 'Test offense',
                                         RecordTypeId = caseDecRecList[0].Id);
        insert tempCaseObj; 
        
        PageReference pageRef = Page.ODILR_LR_Activity_Report;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(tempCaseObj.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(tempCaseObj);
        ODILR_LRActivityReportController controllerObj = new ODILR_LRActivityReportController(sc);
        controllerObj.fromDate = Date.newInstance(2017,1,23);
        controllerObj.endDate = Date.newInstance(2017,8,23);
        controllerObj.currentDate = Date.newInstance(2017,8,23);
        controllerObj.getlrlevel();
        controllerObj.getreportType();
        controllerObj.getlevel();
        controllerObj.getselectedlevel();
        controllerObj.getselectedlrlevel();
        controllerObj.getselectedtype();
        controllerObj.selectedtype = 'ODILR Discipline';
        controllerObj.selectedlevel = 'Board Level';
        controllerObj.selectedlrlevel = 'None';
        controllerObj.lrOffice = 'ALL';
        List<SelectOption> selectOptions = controllerObj.getlevel();
        controllerObj.fetchRecords();
        controllerObj.renderPage();
        Test.stopTest();
    }
}