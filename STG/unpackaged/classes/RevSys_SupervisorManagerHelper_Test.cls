/**
*___________________________________________________
*@Name: RevSys_SupervisorManagerHelper_Test
*@Author: Hemanth Kesapragada
*@Created: Date: 12/19/2017
*@Used_By: SPARTN
*___________________________________________________
*@Description: Test class for RevSys_SupervisorManagerHelper class.
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
private class RevSys_SupervisorManagerHelper_Test {

	@TestSetup
	public static void loadData() {
		List<Contact> contactList = new List<Contact>();
		Contact employee = new Contact
		(
			LastName			='Employee', 
			FirstName			='Amy', 
			Department 			= 'Mechanical',
			Craft__c 			= 'Test Craft2',
			Personnel_Number__c = 1234,
			Email 				= 'test.test@amtrak.com'
		);
		insert employee;

		Contact supervisor = new Contact
		(
			LastName			='Supervisor', 
			FirstName			='John', 
			Department 			= 'Mechanical',
			Craft__c 			= 'Test Craft2',
			Personnel_Number__c = 12345,
			Email 				= 'super.test@amtrak.com'
		);
		insert supervisor;

		Contact manager = new Contact
		(
			LastName			='Manager', 
			FirstName			='Ned', 
			Department 			= 'Mechanical',
			Craft__c 			= 'Test Craft2',
			Personnel_Number__c = 123456,
			Email 				= 'manager.test@amtrak.com'
		);
		insert manager;

		SPARTN_Custom_Settings__c setting = new SPARTN_Custom_Settings__c();
        setting.Name = 'Valid Employee Department';
        setting.CsvString__c = 'TRANSPORTATION,ENGINEERING,MECHANICAL';
        insert setting;


		EPW_Organization__c Org2 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_SPARTN_RECTYPE_ID, 
            Name = 'Spartn', 
            EPW_Organization_Number__c = '2',
            EPW_Status__c = 'Active'
        );
        insert Org2;

        EPW_Organization__c Org1 = new EPW_Organization__c
        ( 
            RecordTypeId = Revsys_StaticUtility.ORGANIZATION_AMTRAKORG_RECTYPE_ID, 
            Name = 'Amtrak', 
            EPW_Organization_Number__c = '1',
            EPW_Status__c = 'Active'
        );
        insert Org1;

        
        //Spartn PH
		EPW_Position_Hierarchy__c myPoHi1 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
            EPW_Position_Organization__c = Org2.Id,
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert myPoHi1;

        EPW_Hierarchy_Assignment__c myHiAsgn1 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = supervisor.Id,
            EPW_Position_Hierarchy__c = myPoHi1.Id,
            EPW_Status__c = 'Active'
        );
        insert myHiAsgn1;

        EPW_Position_Hierarchy__c myPoHi2 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_SPARTN_RECTYPE_ID, 
            EPW_Position_Organization__c = Org2.Id,
            EPW_Parent_Position_Hierarchy__c = myPoHi1.Id,
            Name = 'Leve2 Employee A',
            EPW_Position_ID__c =  '1000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert myPoHi2;

        EPW_Hierarchy_Assignment__c myHiAsgn2 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = employee.Id,
            EPW_Position_Hierarchy__c = myPoHi2.Id,
            EPW_Status__c = 'Active'
        );
        insert myHiAsgn2;


        //Amtrak PH
		EPW_Position_Hierarchy__c amtrakPH = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            Name = 'Leve1 Supervisor A',
            EPW_Position_ID__c =  '10000000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert amtrakPH;

        EPW_Hierarchy_Assignment__c amtrakHA = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = manager.Id,
            EPW_Position_Hierarchy__c = amtrakPH.Id,
            EPW_Status__c = 'Active'
        );
        insert amtrakHA;

        EPW_Position_Hierarchy__c amtrakPH2 = new EPW_Position_Hierarchy__c
        (   RecordTypeId = Revsys_StaticUtility.POSITION_HIERARCHY_AMTRAK_RECTYPE_ID, 
            EPW_Position_Organization__c = Org1.Id,
            EPW_Parent_Position_Hierarchy__c = amtrakPH.Id,
            Name = 'Leve2 Employee A',
            EPW_Position_ID__c =  '1000',
            EPW_Status__c = 'Active',
            EPW_Dept_Code_Description__c = 'Transportation'
        );
        insert amtrakPH2;

        EPW_Hierarchy_Assignment__c amtrakHA2 = new EPW_Hierarchy_Assignment__c
        ( 
            EPW_Contact__c = employee.Id,
            EPW_Position_Hierarchy__c = amtrakPH2.Id,
            EPW_Status__c = 'Active'
        );
        insert amtrakHA2;
	}

	public static testMethod void testRetrieveSupervisorId() {
		Test.startTest();

		Contact supervisor = [Select Id from Contact where LastName='Supervisor' Limit 1];
		Contact employee = [Select Id from Contact where LastName='Employee' Limit 1];


		Map<Id,Id> empSuperMap = RevSys_SupervisorManagerHelper.retrieveSupervisorId(new List<Id>{employee.Id});
		System.assertEquals(supervisor.Id,empSuperMap.get(employee.Id));

		Test.stopTest();
	}

	public static testMethod void testRetrieveManagerId() {
		Test.startTest();

		Contact manager = [Select Id from Contact where LastName='Manager' Limit 1];
		Contact employee = [Select Id from Contact where LastName='Employee' Limit 1];


		Map<Id,Id> empManagerMap = RevSys_SupervisorManagerHelper.retrieveManagerId(new List<Id>{employee.Id});
		System.assertEquals(manager.Id,empManagerMap.get(employee.Id));

		Test.stopTest();
	}


	
}