/**
*___________________________________________________
*@Name: 	ObservationSelector_Test
*@Author: 	Boom Bertetti
*@Created: 	Date: 1/3/2018
*@Used_By: 	Everyone
*___________________________________________________
*@Description: Test for ObservationSelector
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
private class ObservationSelector_Test
{
    @TestSetup
    public static void loadTestData() {
        Contact c               = new Contact();
		c.LastName			    ='Employee'; 
		c.FirstName			    ='Amy'; 
		c.Personnel_Number__c   = 1234567;
		c.Email 				= 'test.test@amtrak.com';
		insert c; 

    	Observation__c obs        = new Observation__c();
        obs.RecordTypeId          = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID;
        obs.Status__c             = 'Draft';
        obs.EvaluationDateTime__c = Datetime.now();
        obs.Employee__c           = c.Id;
        obs.TestNumber__c		  = '101';

    	Observation__c obs2        = new Observation__c();
        obs2.RecordTypeId          = RevSys_StaticUtility.OBSERVATION_TEST1872_RECTYPE_ID;
        obs2.Status__c             = 'Draft';
        obs2.EvaluationDateTime__c = Datetime.now();
        obs2.Employee__c           = c.Id;
        obs2.Result__c			   = 'C = Compliance';
        
		insert new List<Observation__c>{obs, obs2};
            
        List<EmployeeSpecificRequirement__c> lstESR = new List<EmployeeSpecificRequirement__c>();    
		EmployeeSpecificRequirement__c ESR = new EmployeeSpecificRequirement__c(
            TotalAchieved__c=0,
            Employee__c=c.Id,
            StartDate__c = system.today().AddDays(-2),
            EndDate__c= system.today().AddDays(2)
        );
        lstESR.add(ESR);
        
         OccupationCertification__c occCert2  =  new OccupationCertification__c();
        occCert2.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert2.Name = 'Occupation Certification 2';
        occCert2.LengthOfPeriod__c = 8;
        occCert2.NumberOfTestsPerPeriod__c = 2;
        occCert2.Status__c = 'Active';
        insert occCert2;
        
        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 1';
        occReqObj.Status__c = 'Active';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        occReqObj.TestNumber__c = '101';
        insert occReqObj;
            
        OccupationSpecificRequirement__c occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert2.id;
        occSpecReqObj.Requirement__c = occReqObj.id;
        occSpecReqObj.Status__c = 'Active';
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=5;
       
        
        insert occSpecReqObj;

    }

	private static testmethod void selectObservationsTest() {
		Set<Id> observationIds = new Set<Id>();
        Map<String, String> soqlAttributes = new Map<String, String>();
        soqlAttributes.put('orderBy', 'TestName__c');
        soqlAttributes.put('limitNumber', '1');
        soqlAttributes.put('offsetNumber', '1');
        
		for (Observation__c obs : [SELECT Id FROM Observation__c]) {
			observationIds.add(obs.Id);
		}

		// Test positive
		SelectorWrapper selector1 = new ObservationSelector(observationIds, soqlAttributes).selectById();
		System.assertEquals(1, selector1.SObjectList.size());

		SelectorWrapper selector2 = new ObservationSelector(observationIds).selectAllFieldsById();
		System.assertEquals(1, selector1.SObjectList.size());
        
        SelectorWrapper selector6 = new ObservationSelector(observationIds, soqlAttributes).selectAllFieldsById();
		System.assertEquals(1, selector6.SObjectList.size());

		// Test negative
		Map<String, String> badAttributesMap = new Map<String, String>();
		badAttributesMap.put('orderBy', 'badfield');

		SelectorWrapper selector3 = new ObservationSelector(observationIds, badAttributesMap).selectById();
		System.assertNotEquals(null, selector3.ErrorMessage);

		SelectorWrapper selector4 = new ObservationSelector(observationIds, badAttributesMap).selectAllFieldsById();
		System.assertNotEquals(null, selector4.ErrorMessage);

	}

	private static testmethod void selectObservationsWithFindingsTest() {
		Set<Id> observationIds = new Set<Id>();
		for (Observation__c obs : [SELECT Id FROM Observation__c]) {
			observationIds.add(obs.Id);
		}

		// Test positive
		SelectorWrapper selector1 = new ObservationSelector(observationIds).selectByIdWithFindings();
		System.assertEquals(2, selector1.SObjectList.size());

		// Test negative
		Map<String, String> badAttributesMap = new Map<String, String>();
		badAttributesMap.put('orderBy', 'badfield');

		SelectorWrapper selector2 = new ObservationSelector(observationIds, badAttributesMap).selectByIdWithFindings();
		System.assertNotEquals(null, selector2.ErrorMessage);

	}
    
    private static testmethod void selectByEmployeeTest() {
		Set<Id> employeeIds = new Set<Id>();
		for (Observation__c obs : [SELECT Id, Employee__c FROM Observation__c]) {
			employeeIds.add(obs.Employee__c);
		}

		// Test positive
		ObservationSelector observationSelectorNew = new ObservationSelector();
        observationSelectorNew.DoFailTest = FALSE;
		SelectorWrapper selector1 = observationSelectorNew.selectByEmployee(employeeIds);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(2, selector1.SObjectList.size());

		// Test negative
		ObservationSelector observationSelectorNew1 = new ObservationSelector();
        observationSelectorNew1.DoFailTest = TRUE;
		SelectorWrapper selector2 = observationSelectorNew1.selectByEmployee(employeeIds);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage);     
        system.assertNotEquals(null,selector2.ErrorMessage); 
      
	}
    
    private static testmethod void getObservationsbyIdTest() {
		Set<Id> observationIds = new Set<Id>();
		for (Observation__c obs : [SELECT Id FROM Observation__c]) {
			observationIds.add(obs.Id);
		}

		// Test positive

		SelectorWrapper selector1 = ObservationSelector.getObservationsbyId(observationIds);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(2, selector1.SObjectList.size());

		// Test negative
		ObservationSelector.DoFailTest1 = TRUE;
		SelectorWrapper selector2 = ObservationSelector.getObservationsbyId(observationIds);
        system.debug('selector2.ErrorMessage  ' + selector2.ErrorMessage);     
        system.assertNotEquals(null,selector2.ErrorMessage); 

	}
    
     private static testmethod void selectByEmployeeOrderEvaluationDateTest() {
		Set<Id> employeeIds = new Set<Id>();
		for (Observation__c obs : [SELECT Id, Employee__c FROM Observation__c]) {
			employeeIds.add(obs.Employee__c);
		}

		SelectorWrapper selector1 = ObservationSelector.selectByEmployeeOrderEvaluationDate(employeeIds);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(1, selector1.SObjectList.size());

	
	}
    
     private static testmethod void selectByEmployeeAndRecTypeTest() {
        Set<Id> myRecTypeIdSet = new Set<Id>();
        Set<Id> employeeIdSet = new Set<Id>();
        Id myForm1875Id = Revsys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID; 
        Id myForm1877Id = Revsys_StaticUtility.OBSERVATION_TEST1877_RECTYPE_ID; 

        myRecTypeIdSet.add(myForm1875Id); 
        myRecTypeIdSet.add(myForm1877Id);

         
        for (Contact employee : [SELECT Id FROM Contact where Personnel_Number__c =: 1234567]) {
			employeeIdSet.add(employee.Id);
		}

		SelectorWrapper selector1 = new ObservationSelector().selectByEmployeeAndRecType(employeeIdSet, myRecTypeIdSet, Datetime.now());
        system.debug('selectByEmployeeAndRecTypeTest.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(0, selector1.SObjectList.size());
         
        ObservationSelector newObservationSelector = new ObservationSelector();
        newObservationSelector.DoFailTest = TRUE;
		SelectorWrapper selector2 = newObservationSelector.selectByEmployeeAndRecType(employeeIdSet, myRecTypeIdSet, Datetime.now());
        system.debug('selectByEmployeeAndRecTypeTest.ErrorMessage  ' + selector2.ErrorMessage); 
        system.assertNotEquals(null,selector2.ErrorMessage);       
	
	}
    
     private static testmethod void selectByEmployeeAndTestNumTest(){
         Set<Id> myEmpIdSet = new Set<Id>();
         Set<String> myTestNumSet = new Set<String>();
         for (Contact employee : [SELECT Id FROM Contact where Personnel_Number__c =: 1234567]) {
			myEmpIdSet.add(employee.Id);
		} 
         for(OccupationSpecificRequirement__c osr : [Select Id,Test_Number__c from OccupationSpecificRequirement__c]){
             myTestNumSet.add(osr.Test_Number__c);
         }
         ObservationSelector ObsSel = new ObservationSelector();    
         SelectorWrapper myObsWrapper = ObsSel.selectByEmployeeAndTestNum(myEmpIdSet, myTestNumSet, Datetime.now()); 
         System.debug('myObsWrapper message '+ myObsWrapper.ErrorMessage);
         System.assertEquals(null, myObsWrapper.ErrorMessage);
         
    }


}