/**
*___________________________________________________
*@Name: 	OccupationCertificationSelector_Test
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 04/06/2018
*@Used_By: 	Global 
*___________________________________________________
*@Description: Test class for OccupationCertificationSelector Class 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class OccupationCertificationSelector_Test {
	
	@TestSetup
	public static void loadTestData(){

		List<OccupationCertification__c> occList = new List<OccupationCertification__c>();
		
		OccupationCertification__c  occert = new OccupationCertification__c(
			recordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID,
			TargetType__c = 'Supervisor',
			Department__c = 'Mechanical',
			Status__c = 'Active'
		);
		occList.add(occert);
		OccupationCertification__c  occert1 = new OccupationCertification__c(
			recordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID,
			TargetType__c = 'Occupation',
			Department__c = 'Mechanical',
			Status__c = 'Active'
		);
		occList.add(occert1);

		OccupationCertification__c  occert2 = new OccupationCertification__c(
			recordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID,
			Status__c = 'Active',
			Name='Sample Certification'
		);
		occList.add(occert2);

		OccupationCertification__c  violationTarget = new OccupationCertification__c(
			recordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTN_VIOLATION_RECTYPE_ID,
			Status__c = 'Active'
		);
		occList.add(violationTarget);

		OccupationCertification__c  deptAndCraft = new OccupationCertification__c(
			recordTypeId = RevSys_StaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID,
			Status__c = 'Active',
			Department__c = 'Mechanical'
		);
		occList.add(deptAndCraft);

		insert occList;

		OccupationCertification__c  occert3 = new OccupationCertification__c(
			recordTypeId = RevSys_StaticUtility.OCC_CERT_SPARTNTARGET_RECTYPE_ID,
			ParentCertification__c =occList.get(2).Id ,
			TargetType__c = 'Certification',
			Status__c = 'Active'
		);
		
		insert occert3;

	}

	public static testMethod void testGetTargets() {
		Set<String> depts = new Set<String>{'Mechanical'};
		SelectorWrapper selWrap = OccupationCertificationSelector.getTargets(depts,'Occupation');

		selWrap = OccupationCertificationSelector.getTargets(depts,'Supervisor');
		System.assertNotEquals(0,selWrap.SObjectList.size());
		//Test Bad
		OccupationCertificationSelector.DoFailTest = TRUE;
		selWrap = OccupationCertificationSelector.getTargets(depts,'Supervisor');
		System.assertNotEquals(null,selWrap.ErrorMessage);
	}

	public static testMethod void testGetTargetsById() {
		Set<Id> occList = new Set<Id>();
		for(OccupationCertification__c occ : [Select Id from OccupationCertification__c]) {
			occList.add(occ.Id);
		}
		SelectorWrapper selWrap = OccupationCertificationSelector.getTargetsById(occList);
		System.assertNotEquals(0,selWrap.SObjectList.size());
		//Test Bad
		OccupationCertificationSelector.DoFailTest = TRUE;
		selWrap = OccupationCertificationSelector.getTargetsById(occList);
		System.assertNotEquals(null,selWrap.ErrorMessage);
	}

	public static testMethod void testGetCertifications() {
		Set<Id> occList = new Set<Id>();
		for(OccupationCertification__c occ : [Select Id from OccupationCertification__c where recordTypeId=:RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID]) {
			occList.add(occ.Id);
		}
		
		SelectorWrapper selWrap = OccupationCertificationSelector.getCertifications(occList);
		System.assertNotEquals(0,selWrap.SObjectList.size());
		//Test Bad
		OccupationCertificationSelector.DoFailTest = TRUE;
		selWrap = OccupationCertificationSelector.getCertifications(occList);
		System.assertNotEquals(null,selWrap.ErrorMessage);
	}

	public static testMethod void testGetCertificationTargets() {
		Set<Id> occList = new Set<Id>();
		for(OccupationCertification__c occ : [Select Id from OccupationCertification__c where recordTypeId=:RevSys_StaticUtility.OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID]) {
			occList.add(occ.Id);
		}
		System.debug('occList '+occList);
		SelectorWrapper selWrap = OccupationCertificationSelector.getCertificationTargets(occList);
		System.assertNotEquals(0,selWrap.SObjectList.size());
		//Test Bad
		OccupationCertificationSelector.DoFailTest = TRUE;
		selWrap = OccupationCertificationSelector.getCertificationTargets(occList);
		System.assertNotEquals(null,selWrap.ErrorMessage);
	}


	public static testMethod void testGetViolationTargets() {
		Set<Id> occList = new Set<Id>();
		for(OccupationCertification__c occ : [Select Id from OccupationCertification__c where recordTypeId=:RevSys_StaticUtility.OCC_CERT_SPARTN_VIOLATION_RECTYPE_ID]) {
			occList.add(occ.Id);
		}
		SelectorWrapper selWrap = OccupationCertificationSelector.getViolationTargets(occList);
		System.assertNotEquals(0,selWrap.SObjectList.size());
		//Test Bad
		OccupationCertificationSelector.DoFailTest = TRUE;
		selWrap = OccupationCertificationSelector.getViolationTargets(occList);
		System.assertNotEquals(null,selWrap.ErrorMessage);
	}

	public static testMethod void testGetDeptCraftRecs() {
		Set<String> occList = new Set<String>{'Mechanical'};
		SelectorWrapper selWrap = OccupationCertificationSelector.getDeptCraftRecs(occList);
		System.assertNotEquals(0,selWrap.SObjectList.size());
		//Test Bad
		OccupationCertificationSelector.DoFailTest = TRUE;
		selWrap = OccupationCertificationSelector.getDeptCraftRecs(occList);
		System.assertNotEquals(null,selWrap.ErrorMessage);
	}

	public static testMethod void testAppliestoAllObs() {
		SelectorWrapper selWrap = OccupationCertificationSelector.getAppliesToAllObsTargets();
		System.assertNotEquals(0,selWrap.SObjectList.size());
		//Test Bad
		OccupationCertificationSelector.DoFailTest = TRUE;
		selWrap = OccupationCertificationSelector.getAppliesToAllObsTargets();
		System.assertNotEquals(null,selWrap.ErrorMessage);
	}

	public static testMethod void testGetOccCertByName() {
		Set<String> certName = new Set<String>{'Sample Certification'};
		SelectorWrapper selWrap = OccupationCertificationSelector.getOccCertByName(certName);
		System.assertNotEquals(0,selWrap.SObjectList.size());
		//Test Bad
		OccupationCertificationSelector.DoFailTest = TRUE;
		selWrap = OccupationCertificationSelector.getOccCertByName(certName);
		System.assertNotEquals(null,selWrap.ErrorMessage);
	}

    public static testMethod void testGetTargetsByViolation() {
        Set<Id> vioList = new Set<Id>();
        for(OccupationCertification__c occ : [Select Id, Violation__c from OccupationCertification__c where recordTypeId=:RevSys_StaticUtility.OCC_CERT_SPARTN_VIOLATION_RECTYPE_ID]) {
            vioList.add(occ.Violation__c);
        }
        SelectorWrapper selWrap = OccupationCertificationSelector.getTargetsByViolation(vioList);
        System.assertNotEquals(0,selWrap.SObjectList.size());
        //Test Bad
        OccupationCertificationSelector.DoFailTest = TRUE;
        selWrap = OccupationCertificationSelector.getTargetsByViolation(vioList);
        System.assertNotEquals(null,selWrap.ErrorMessage);
    }
	
}