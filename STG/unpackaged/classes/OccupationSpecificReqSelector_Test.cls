/**
*___________________________________________________
*@Name: 	OccupationSpecificReqSelector_Test
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 04/06/2018
*@Used_By: 	Global 
*___________________________________________________
*@Description: Test class for OccupationSpecificRequirementSelector Class 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class OccupationSpecificReqSelector_Test {

	@TestSetup
	public static void loadTestData(){

		OccupationCertification__c occCert  =  new OccupationCertification__c();
		occCert.RecordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID;
        occCert.Name = 'Occupation Certification 1';
        occCert.LengthOfPeriod__c = 8;
        occCert.NumberOfTestsPerPeriod__c = 2;
        occCert.Status__c = 'Active';
        insert occCert;


        List<OccupationRequirement__c> occReqList = new List<OccupationRequirement__c>();       
        OccupationRequirement__c occReqObj = new OccupationRequirement__c();
        occReqObj.Name = 'Occupation Requirement 1';
        occReqObj.Status__c =  'Active';
        occReqObj.RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID;
        insert occReqObj;

        OccupationSpecificRequirement__c occSpecReqObj = new OccupationSpecificRequirement__c();
        occSpecReqObj.Certification__c = occCert.id;
        occSpecReqObj.Requirement__c = occReqObj.id;
        occSpecReqObj.Status__c = 'Active';
        occSpecReqObj.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID;
        occSpecReqObj.LengthOfPeriod__c=5;
        occSpecReqObj.Frequency__c='Days';
        insert occSpecReqObj;


        //Insert Targets
        OccupationCertification__c  occert = new OccupationCertification__c(
			recordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID,
			TargetType__c = 'Supervisor',
			Department__c = 'Mechanical',
			Status__c = 'Active'
		);
		insert occert;

		OccupationRequirement__c obs = new OccupationRequirement__c(
			recordTypeId = Revsys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
			Name = 'Test Observation',
			Status__c = 'Active',
			Source__c = 'Observation',
			TestNumber__c = '101',
			TestName__c = 'Stopping vehicle'
		);
		insert obs;

		OccupationSpecificRequirement__c occSpecReqObj2 = new OccupationSpecificRequirement__c();
        occSpecReqObj2.Target__c = occert.id;
        occSpecReqObj2.Observation__c = obs.id;
        occSpecReqObj2.Status__c = 'Active';
        occSpecReqObj2.TargetRequirement__c = occReqObj.Id;
        occSpecReqObj2.RecordTypeId = RevSys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID;
        insert occSpecReqObj2;


        OccupationSpecificRequirement__c occSpecReqObj3 = new OccupationSpecificRequirement__c();
        occSpecReqObj3.ObservationDepartment2__c = 'Mechanical';
        occSpecReqObj3.ObservationCraft2__c = 'Other';
        occSpecReqObj3.Observation__c = obs.id;
        occSpecReqObj3.Status__c = 'Active';
        occSpecReqObj3.RecordTypeId = RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID;
        insert occSpecReqObj3;

	}

	public static testMethod void testGetSpecificRequirements() {
		Set<Id> reqIds = new Set<Id>();
		for(OccupationRequirement__c req: [Select Id from OccupationRequirement__c]) {
			reqIds.add(req.Id);
		}
		SelectorWrapper wrap = OccupationSpecificRequirementSelector.getSpecificRequirements(reqIds);
		System.assertNotEquals(0,wrap.SobjectList.size());

		//Test Bad
		OccupationSpecificRequirementSelector.DoFailTest = TRUE;
		wrap = OccupationSpecificRequirementSelector.getSpecificRequirements(reqIds);
		System.assertNotEquals(null,wrap.ErrorMessage);
	}

	public static testMethod void testGetById() {
		Set<Id> reqIds = new Set<Id>();
		for(OccupationSpecificRequirement__c req: [Select Id from OccupationSpecificRequirement__c]) {
			reqIds.add(req.Id);
		}
		SelectorWrapper wrap = OccupationSpecificRequirementSelector.getById(reqIds);
		System.assertNotEquals(0,wrap.SobjectList.size());

		//Test Bad
		OccupationSpecificRequirementSelector.DoFailTest = TRUE;
		wrap = OccupationSpecificRequirementSelector.getById(reqIds);
		System.assertNotEquals(null,wrap.ErrorMessage);
	}


	public static testMethod void testGetOccSpecificRequirementsFrmTestNum() {
		Set<String> reqIds = new Set<String>();
		for(OccupationRequirement__c req: [Select TestNumber__c from OccupationRequirement__c where Name='Test Observation']) {
			reqIds.add(req.TestNumber__c);
		}

		SelectorWrapper wrap = OccupationSpecificRequirementSelector.getOccSpecificRequirementsFrmTestNum(reqIds,new Set<String>());
		System.assertNotEquals(0,wrap.SobjectList.size());
		wrap = OccupationSpecificRequirementSelector.getOccSpecificRequirementsFrmTestNum(new Set<String>(),new Set<String>());

		//Test Bad
		OccupationSpecificRequirementSelector.DoFailTest = TRUE;
		wrap = OccupationSpecificRequirementSelector.getOccSpecificRequirementsFrmTestNum(reqIds,new Set<String>());
		System.assertNotEquals(null,wrap.ErrorMessage);
	}

	public static testMethod void testGetOccSpecReqCertification() {
		Set<Id> reqIds = new Set<Id>();
		for(OccupationCertification__c req: [Select Id from OccupationCertification__c]) {
			reqIds.add(req.Id);
		}

		SelectorWrapper wrap = OccupationSpecificRequirementSelector.getOccSpecReqCertification(reqIds);
		System.assertNotEquals(0,wrap.SobjectList.size());

		//Test Bad
		OccupationSpecificRequirementSelector.DoFailTest = TRUE;
		wrap = OccupationSpecificRequirementSelector.getOccSpecReqCertification(reqIds);
		System.assertNotEquals(null,wrap.ErrorMessage);
	}

	public static testMethod void testGetOccSpecReqTarget() {
		Set<Id> reqIds = new Set<Id>();
		for(OccupationCertification__c req: [Select Id from OccupationCertification__c]) {
			reqIds.add(req.Id);
		}

		SelectorWrapper wrap = OccupationSpecificRequirementSelector.getOccSpecReqTarget(reqIds);
		System.assertNotEquals(0,wrap.SobjectList.size());

		//Test Bad
		OccupationSpecificRequirementSelector.DoFailTest = TRUE;
		wrap = OccupationSpecificRequirementSelector.getOccSpecReqTarget(reqIds);
		System.assertNotEquals(null,wrap.ErrorMessage);
	}

	public static testMethod void testGetOsrTargetReq() {
		Set<Id> reqIds = new Set<Id>();
		for(OccupationRequirement__c req: [Select Id from OccupationRequirement__c]) {
			reqIds.add(req.Id);
		}

		SelectorWrapper wrap = OccupationSpecificRequirementSelector.getOsrTargetReq(reqIds);
		System.assertNotEquals(0,wrap.SobjectList.size());

		//Test Bad
		OccupationSpecificRequirementSelector.DoFailTest = TRUE;
		wrap = OccupationSpecificRequirementSelector.getOsrTargetReq(reqIds);
		System.assertNotEquals(null,wrap.ErrorMessage);
	}



	public static testMethod void testGetOsrObsRecords() {
		Set<String> deptSet = new Set<String>{'Mechanical'};
		Set<String> craftSet = new Set<String>{'Other'};
		OccupationSpecificReqSelector reqSelector = new OccupationSpecificReqSelector();

		SelectorWrapper wrap = reqSelector.getOsrObsRecords(deptSet,craftSet);
		System.assertNotEquals(0,wrap.SobjectList.size());
		reqSelector.DoFailTest = true;
		wrap = reqSelector.getOsrObsRecords(deptSet,craftSet);
		System.assertNotEquals(null,wrap.ErrorMessage);
	}

	public static testMethod void testGetOsrJunctCert() {
		Set<Id> certSet = new Set<Id>();
		Set<Id> reqSet = new Set<Id>();
		for(OccupationCertification__c oc: [Select Id from OccupationCertification__c]) {
			certSet.add(oc.Id);
		}

		for(OccupationRequirement__c oc: [Select Id from OccupationRequirement__c]) {
			reqSet.add(oc.Id);
		}
		OccupationSpecificReqSelector reqSelector = new OccupationSpecificReqSelector();

		SelectorWrapper wrap = reqSelector.getOsrJunctCert(certSet,reqSet);
		System.assertNotEquals(0,wrap.SobjectList.size());
		reqSelector.DoFailTest = true;
		wrap = reqSelector.getOsrJunctCert(certSet,reqSet);
		System.assertNotEquals(null,wrap.ErrorMessage);
	}

	public static testMethod void testGetOsrJunctTarget() {
		Set<Id> certSet = new Set<Id>();
		Set<Id> reqSet = new Set<Id>();
		for(OccupationCertification__c oc: [Select Id from OccupationCertification__c]) {
			certSet.add(oc.Id);
		}

		for(OccupationRequirement__c oc: [Select Id from OccupationRequirement__c]) {
			reqSet.add(oc.Id);
		}
		OccupationSpecificReqSelector reqSelector = new OccupationSpecificReqSelector();

		SelectorWrapper wrap = reqSelector.getOsrJunctTarget(reqSet,certSet);
		System.assertNotEquals(0,wrap.SobjectList.size());
		reqSelector.DoFailTest = true;
		wrap = reqSelector.getOsrJunctTarget(reqSet,certSet);
		System.assertNotEquals(null,wrap.ErrorMessage);
	}

	public static testMethod void testGetOsrObsRecsById() {
		Set<Id> osrSet = new Set<Id>();
		
		for(OccupationSpecificRequirement__c oc: [Select Id from OccupationSpecificRequirement__c]) {
			osrSet.add(oc.Id);
		}

		OccupationSpecificReqSelector reqSelector = new OccupationSpecificReqSelector();

		SelectorWrapper wrap = reqSelector.getOsrObsRecsById(osrSet);
		System.assertNotEquals(0,wrap.SobjectList.size());
		reqSelector.DoFailTest = true;
		wrap = reqSelector.getOsrObsRecsById(osrSet);
		System.assertNotEquals(null,wrap.ErrorMessage);

		OccupationSpecificReqSelector.getSubQueryStr(new List<String>(),'','','','','');
	}
    
}