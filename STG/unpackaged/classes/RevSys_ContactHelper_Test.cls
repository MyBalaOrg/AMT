/**
*___________________________________________________
*@Name: 	RevSys_ContactHelper_Test
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 11/23/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Test for RevSys_ContactHelper
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class RevSys_ContactHelper_Test {
	private static final String MECHANICAL = 'Mechanical';
	private static final String ACTIVE  = 'Active';
	private static final String INACTIVE = 'Inactive';
	//private static final String CRAFT = 'Test Craft2';
	private static final String CRAFT = 'Conductor';

	//Creating Test Data
	@TestSetup
	public static void loadTestData() {

		REVSYS_Custom_Settings__c cs = new REVSYS_Custom_Settings__c();
		cs.CsvString__c = 'TRANSPORTATION,MECHANICAL,ENGINEERING';
		cs.Name = 'Valid Employee Department';
		insert cs;

		Account acc = new Account
        (
        	Name='Amtrak'
        );
        insert acc;
		//Create Targets
		List<OccupationCertification__c> occCertList = new List<OccupationCertification__c>();

		OccupationCertification__c occCert  =  new OccupationCertification__c();
		occCert.RecordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID;
		occCert.Name = 'Occupation Certification 1';
		occCert.Department__c = MECHANICAL;
		occCert.Craft__c = CRAFT;
		occCert.Status__c = ACTIVE;
		occCert.Frequency__c = 'Months';
		occCert.LengthOfPeriod__c = 2;
		occCert.TargetType__c = RevSys_StaticUtility.OCCUPATION;
		occCert.NumberOfTestsPerPeriod__c = 2;
		occCertList.add(occCert);

		occCert  =  new OccupationCertification__c();
		occCert.RecordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID;
		occCert.Name = 'Occupation Certification 2';
		occCert.Department__c = MECHANICAL;
		occCert.Craft__c = CRAFT;
		occCert.Status__c = ACTIVE;
		occCert.Frequency__c = 'Quarters';
		occCert.LengthOfPeriod__c = 2;
		occCert.NumberOfTestsPerPeriod__c = 2;
		occCert.TargetType__c = RevSys_StaticUtility.OCCUPATION;
		occCertList.add(occCert);

		occCert  =  new OccupationCertification__c();
		occCert.RecordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID;
		occCert.Name = 'Occupation Certification 13';
		occCert.Department__c = MECHANICAL;
		occCert.Craft__c = CRAFT;
		occCert.Status__c = ACTIVE;
		occCert.Frequency__c = 'Half-Years';
		occCert.LengthOfPeriod__c = 2;
		occCert.NumberOfTestsPerPeriod__c = 2;
		occCert.TargetType__c = RevSys_StaticUtility.OCCUPATION;
		occCertList.add(occCert);

        occCert  =  new OccupationCertification__c();
		occCert.RecordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID;
		occCert.Name = 'Occupation Certification 4';
		occCert.Department__c = MECHANICAL;
		occCert.Craft__c = CRAFT;
		occCert.Status__c = ACTIVE;
		occCert.Frequency__c = 'Calendar-Years';
		occCert.LengthOfPeriod__c = 2;
		occCert.NumberOfTestsPerPeriod__c = 2;
		occCert.TargetType__c = RevSys_StaticUtility.OCCUPATION;
		occCertList.add(occCert);
        
        occCert  =  new OccupationCertification__c();
		occCert.RecordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID;
		occCert.Name = 'Occupation Certification 5';
		occCert.Department__c = MECHANICAL;
		occCert.Craft__c = CRAFT;
		occCert.Status__c = ACTIVE;
		occCert.Frequency__c = 'Months';
		occCert.LengthOfPeriod__c = 2;
		occCert.NumberOfTestsPerPeriod__c = 2;
		occCert.TargetType__c = RevSys_StaticUtility.OCCUPATION;
		occCertList.add(occCert);
        
        
        insert occCertList;
        
  	/*	EPW_Position_Hierarchy__c position = new EPW_Position_Hierarchy__c();
        position.EPW_Position_ID__c = '78762';
        position.Name = 'Director';
    //    position.EPW_Dept_Code_Description__c = 'TRANSPORTATION';
        insert position;*/
        
        Spartn_Custom_Settings__c csd = new Spartn_Custom_Settings__c();
        csd.Name='Valid Employee Department';
        csd.CSVString__c = 'TRANSPORTATION,MECHANICAL,ENGINEERING';
        insert csd;
        
      /*  EPW_Position_Hierarchy__c positionHr = new EPW_Position_Hierarchy__c();
        positionHr.EPW_Position_ID__c = '78238';
        positionHr.Name = 'Supervisor';
       // positionHr.EPW_Dept_Code_Description__c = 'MECHANICAL';
        insert positionHr;*/
        
     /*   EPW_Hierarchy_Assignment__c hrAssgnmnt = new  EPW_Hierarchy_Assignment__c();
        hrAssgnmnt.EPW_Position_Hierarchy__c = positionHr.Id;
        insert hrAssgnmnt;*/
        
		Contact employee = new Contact
		(
			LastName			='Employee', 
			FirstName			='Amy', 
			Department 			= 'MECHANICAL',
			Craft__c 			= CRAFT,
			Personnel_Number__c = 1234567,
			Email 				= 'test.test@amtrak.com',
            Railroad__c			= 'MBTA',
            Employment_Status__c = 'Active'
		);
		insert employee;
	}

	//Validating the new Contact created in Test Setup
	public static testMethod void testContactCreate() {
		Test.startTest();
		Contact employee = [SELECT Id,(SELECT Id FROM Employee_Specific_Requirements__r) 
							FROM Contact 
							where Personnel_Number__c=1234567 
							LIMIT 1];
		List<EmployeeSpecificRequirement__c> esrList  = employee.Employee_Specific_Requirements__r;

		System.assertEquals(5,esrList.size());
		System.debug(esrList.size());

		Test.stopTest();

	}

	//Validating the update Contact when a new target is available.
	//Expected Result: the new target should be associated to the contact along with the old targets when the contact is updted 
	public static testMethod void testContactUpdate() {
		Test.startTest();

		OccupationCertification__c occCert  =  new OccupationCertification__c();
		occCert.RecordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID;
		occCert.Name = 'Occupation Certification 3';
		occCert.Department__c = MECHANICAL;
		occCert.Craft__c = CRAFT;
		occCert.Status__c = ACTIVE;
		occCert.Frequency__c = 'Months';
		occCert.LengthOfPeriod__c = 2;
		occCert.NumberOfTestsPerPeriod__c = 2;
		occCert.TargetType__c = RevSys_StaticUtility.OCCUPATION;
		insert occCert;

		Contact employee = [SELECT Id,LastName,(SELECT Id FROM Employee_Specific_Requirements__r) 
							FROM Contact 
							where Personnel_Number__c=1234567 
							LIMIT 1];


		List<EmployeeSpecificRequirement__c> esrList  = employee.Employee_Specific_Requirements__r;
		System.assertEquals(6,esrList.size());

		//employee.LastName = 'Update Employee';
		//update employee;

		employee = [SELECT Id,LastName,(SELECT Id FROM Employee_Specific_Requirements__r) 
							FROM Contact 
							where Personnel_Number__c=1234567 
							LIMIT 1];
		esrList  = employee.Employee_Specific_Requirements__r;
		System.assertEquals(6,esrList.size());

		Test.stopTest();

	}

	//Validating the update Contact when there are no new targets and the contact has old targets associated.
	//Expected result: Since there are no targets to the employee, the exisiting ESR should be "INACTIVE"
	public static testMethod void testContactUpdate2() {
		Test.startTest();

		List<OccupationCertification__c> occCerList = [SELECT Id,Status__c from OccupationCertification__c];
		delete occCerList;

		Contact employee = [SELECT Id,LastName,(SELECT Id,Status__c FROM Employee_Specific_Requirements__r) 
							FROM Contact 
							where Personnel_Number__c=1234567 
							LIMIT 1];


		List<EmployeeSpecificRequirement__c> esrList  = employee.Employee_Specific_Requirements__r;
		Set<String> sts = new Set<String>();
		if(esrList!=null) {
			for(EmployeeSpecificRequirement__c esr : esrList) {
				sts.add(esr.status__c);
			}
		}

		System.assertEquals(!sts.contains(INACTIVE),true);

		//employee.LastName = 'Update Employee';
		//update employee;

		employee = [SELECT Id,LastName,(SELECT Id,Status__c FROM Employee_Specific_Requirements__r) 
							FROM Contact 
							where Personnel_Number__c=1234567 
							LIMIT 1];
		esrList  = employee.Employee_Specific_Requirements__r;
		sts = new Set<String>();
		if(esrList!=null) {
			for(EmployeeSpecificRequirement__c esr : esrList) {
				sts.add(esr.status__c);
			}
		}
		System.assertEquals(!sts.contains(ACTIVE),false);

		Test.stopTest();

	}

	//Validating the update Contact when the target's Department/craft is changed and contact is updated
	//Expected Result: The ESR associated to the changed target should be made inactive as it no longer matches the department and craft
	public static testMethod void testContactUpdate3() {
		Test.startTest();        

		OccupationCertification__c occRec = [SELECT Id,Status__c,Department__c
											 FROM OccupationCertification__c
											 WHERE Name='Occupation Certification 1'
											 LIMIT 1];
		occRec.Department__c = 'Mechanical';
        occRec.MatchEmployeeAttribute__c = 'Gang';
		update occRec;

		Contact employee = [SELECT Id,LastName,(SELECT Id FROM Employee_Specific_Requirements__r) 
							FROM Contact 
							where Personnel_Number__c=1234567 
							LIMIT 1];

		//employee.LastName = 'Update Employee';
        employee.SPARTN_Requirement__c = 'Gang';
		update employee;

		employee = [SELECT Id,LastName,(SELECT Id FROM Employee_Specific_Requirements__r WHERE Status__c= :ACTIVE) 
							FROM Contact 
							where Personnel_Number__c=1234567 
							LIMIT 1];

		List<EmployeeSpecificRequirement__c> esrList  = employee.Employee_Specific_Requirements__r;
		System.assertEquals(5,esrList.size());

		Test.stopTest();

	}
    public static testMethod void testEstablishTarget() {
		Test.startTest();        

		OccupationCertification__c occRec = [SELECT Id,Status__c,Department__c
											 FROM OccupationCertification__c
											 WHERE Name='Occupation Certification 1'
											 LIMIT 1];
		occRec.Department__c = 'Mechanical';
		update occRec;

		Contact employee = [SELECT Id,LastName,(SELECT Id FROM Employee_Specific_Requirements__r) 
							FROM Contact 
							where Personnel_Number__c=1234567 
							LIMIT 1];

		//employee.LastName = 'Update Employee';
        employee.Craft__c = null;
        employee.Department = 'New Orleans';
		update employee;


		employee = [SELECT Id,LastName,(SELECT Id FROM Employee_Specific_Requirements__r WHERE Status__c= :ACTIVE) 
							FROM Contact 
							where Personnel_Number__c=1234567 
							LIMIT 1];

		List<EmployeeSpecificRequirement__c> esrList  = employee.Employee_Specific_Requirements__r;

		Test.stopTest();

	}
    
    //Cannot be tested as Contact has a new RecordType
    /*public static testMethod void testDefaultFieldValue(){
        Test.startTest();
        


        Contact emp = [SELECT Id,Account.Name,Railroad__c from Contact WHERE Personnel_Number__c = 1234567 LIMIT 1];
    	//System.assertEquals('Amtrak', emp.Account.Name, 'Not the desired output');
        Test.stopTest();
    }*/
    //method for errormessage
    public static testmethod void testErrorMsg(){
    	Test.startTest();
    	try{ 
    		Contact employee = [SELECT Id,LastName,Craft__c FROM Contact 
							where Personnel_Number__c=1234567 
							LIMIT 1];

		employee.LastName = 'Update Employee';
		employee.Height__c = 123;
		employee.Craft__c = '';
		employee.Department='test';
		update employee;

    	}
    	Catch(exception e)
    	{
    	//	System.assert(e.getMessage().contains('error Message.'));
        //    System.assert(e.getMessage().contains('Height__c'));
        // System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));

    	}


    	Test.stopTest();
    }
    
    public static testmethod void testEstablishTargetHelper(){
        Test.startTest();
        RevSys_ContactTriggerHandler.DoFailTest = TRUE;
        try{
            Contact employee = new Contact();
        employee.LastName = 'Update Employee';
		employee.Height__c = 123;
		employee.Craft__c = '';
		employee.Department='test';
		insert employee;
            
        }catch(Exception e){
            Boolean b = e.getMessage().contains('Error')?true:false;
                System.assertEquals(true,b);
        }
        
        Test.stopTest();
    }

}