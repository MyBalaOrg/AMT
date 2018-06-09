/**
*___________________________________________________
*@Name: 	OccupationRequirementSelector_Test
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 04/07/2018
*@Used_By: 	Global 
*___________________________________________________
*@Description: Test class for OccupationRequirementSelector_Test Class 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class OccupationRequirementSelector_Test {

	@TestSetup
	public static void loadTestData() {

		List<OccupationRequirement__c> reqList = new List<OccupationRequirement__c>();
		OccupationRequirement__c req1 = new OccupationRequirement__c(
			recordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
			Name = 'Test Observation',
			Status__c = 'Active',
			Source__c = 'Observation',
			TestNumber__c = '101',
			TestName__c = 'Stopping vehicle'
		);
		reqList.add(req1);

		OccupationRequirement__c req2 = new OccupationRequirement__c(
			recordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID,
			Name = 'Test Requirement',
			Status__c = 'Active',
			Source__c = 'Employee Result Summary',
			SourceRecordType__c = 'Medical, Hearing and Vision',
			SourceTestType__c = 'Hearing Test'
		);
		reqList.add(req2);

		insert reqList;
	}

	public static testMethod void testGetOccRequirements(){
		Set<Id> occReqId = new Set<Id>();
		for(OccupationRequirement__c occR : [Select Id from OccupationRequirement__c]) {
			occReqId.add(occR.Id);
		}

		SelectorWrapper orWrap = OccupationRequirementSelector.getOccRequirements(occReqId);
		System.assertNotEquals(0,orWrap.SobjectList.size());
		//Test Bad
		OccupationRequirementSelector.DoFailTest = TRUE;
		orWrap = OccupationRequirementSelector.getOccRequirements(occReqId);
		System.assertNotEquals(null,orWrap.ErrorMessage);
	}


	public static testMethod void testGetOccReqByName(){
		Set<String> occReqName = new Set<String>();
		for(OccupationRequirement__c occR : [Select Name from OccupationRequirement__c]) {
			occReqName.add(occR.Name);
		}

		SelectorWrapper orWrap = OccupationRequirementSelector.getOccReqByName(occReqName);
		System.assertNotEquals(0,orWrap.SobjectList.size());
		//Test Bad
		OccupationRequirementSelector.DoFailTest = TRUE;
		orWrap = OccupationRequirementSelector.getOccReqByName(occReqName);
		System.assertNotEquals(null,orWrap.ErrorMessage);
	}

	public static testMethod void testGetObsByTestNum(){
		Set<String> testNumSet = new Set<String>();
		Set<String> testNameSet = new Set<String>();

		for(OccupationRequirement__c occR : [Select TestNumber__c,TestName__c from OccupationRequirement__c]) {
			testNumSet.add(occR.TestNumber__c);
			testNameSet.add(occR.TestName__c);
		}

		SelectorWrapper orWrap = OccupationRequirementSelector.getObsByTestNum(testNumSet);
		System.assertNotEquals(0,orWrap.SobjectList.size());
		orWrap = OccupationRequirementSelector.getObsByTestName(testNameSet);
		System.assertNotEquals(0,orWrap.SobjectList.size());
		//Test Bad
		OccupationRequirementSelector.DoFailTest = TRUE;
		orWrap = OccupationRequirementSelector.getObsByTestNum(testNumSet);
		System.assertNotEquals(null,orWrap.ErrorMessage);
		orWrap = OccupationRequirementSelector.getObsByTestName(testNameSet);
		System.assertNotEquals(null,orWrap.ErrorMessage);
	}
	
}