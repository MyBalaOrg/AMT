/**
*___________________________________________________
*@Name: 	RevSys_EmployeeCertificationStatusHelper
*@Author: 	Hemanth Kesapragada
*@Created: 	Date: 01/16/2017
*@Used_By: 	SPARTN
*___________________________________________________
*@Description: Helper class to handle the status of  certificates
* 
*___________________________________________________
*@Changes: 
* 01/23/2017 [Hemanth] Renamed RevSys_EmployeeCertificationExprtnHelper to RevSys_EmployeeCertificationStatusHelper 
* 						in order to make it generic to update the Certification status.
**/
public with sharing class RevSys_EmployeeCertificationStatusHelper {
	/**
    *————————————————————————————————————————————————————
    * @Name: setExpiredStatus
    * @Description
    * Updates the status of the Employee Certificate records to 'Expired'
    * @param	expiredECList -  employeeCertfication records list
    *			
    * @returns void
    *————————————————————————————————————————————————————
    **/
	public static String setExpiredStatus(List<EmployeeCertification__c> empCertList) {
		System.debug('**** removed Revocation empCertId setExpiredStatus '+empCertList);
		String errMsg='';
		List<EmployeeCertification__c> ecListToUpdate = new List<EmployeeCertification__c>();
		if(!empCertList.isEmpty()) {
			for(EmployeeCertification__c ecRecord : empCertList) {
				ecRecord.Status__c = RevSys_StaticUtility.EXPIRED;
				ecRecord.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
				ecListToUpdate.add(ecRecord);
			}
		}

		if(!ecListToUpdate.isEmpty()) {
			errMsg = DMLHelper.updateList(ecListToUpdate);
		}
		return errMsg;

	}

	/**
    *————————————————————————————————————————————————————
    * @Name: setCurrentStatus
    * @Description
    * Updates the status of the Employee Certificate records to 'Current'
    * @param	empCertList -  employeeCertfication records list
    *			
    * @returns void
    *————————————————————————————————————————————————————
    **/
	public static String setCurrentStatus(List<EmployeeCertification__c> empCertList) {

		String errMsg = '';
		List<EmployeeCertification__c> ecListToUpdate = new List<EmployeeCertification__c>();
		if(!empCertList.isEmpty()) {
			for(EmployeeCertification__c ecRecord : empCertList) {
				ecRecord.Status__c = RevSys_StaticUtility.CURRENT;
				ecRecord.ProcessFlag__c = System.Label.RevSys_EmpCert_ProcessFlag;
				ecListToUpdate.add(ecRecord);
			}
		}

		if(!ecListToUpdate.isEmpty()) {
			errMsg = DMLHelper.updateList(ecListToUpdate);
		}
		return errMsg;
	}

	/**
    *————————————————————————————————————————————————————
    * @Name: processRevocationRecords
    * @Description
    * Updates the status of the revoked Employee Certificate records to 'Expired'/'Current' based on the certification validation
    * @param	revokedECList -  employeeCertfication records list that are revoked
    *			
    * @returns void
    *————————————————————————————————————————————————————
    **/
	public static String processRevocationRecords(Set<Id> empCertSet) {
		String errMsg='';
		List<EmployeeCertification__c> empCertList = new List<EmployeeCertification__c>();
		List<EmployeeCertification__c> newEmpCertList = new List<EmployeeCertification__c>();
		/*Set<Id> empCertSet= new Set<Id>();
		if(revokedECList!=null) {
			for(CertificationRevocation__c crRecord : revokedECList) {
				if(crRecord.RevocationEndDate__c <= System.today()) {
					empCertSet.add(crRecord.EmployeeCertification__c);
				}
			}
		}*/
		if(!empCertSet.isEmpty()) {
			SelectorWrapper wrapper = EmployeeCertificationSelector.getEmpCertification(empCertSet);
			if(wrapper!=null) {
				empCertList =  (List<EmployeeCertification__c>)wrapper.sObjectList;
			}
		}

		//Check the Revocation Begin Date and Revocation End Date
		for(EmployeeCertification__c empCert : empCertList) {
			if( !(System.today() <= empCert.RevocationEndDate__c &&  System.today() >= empCert.RevocationBeginDate__c) ) {
				newEmpCertList.add(empCert);
			}
		}

		if(!newEmpCertList.isEmpty()) {
			List<RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper> ecWrapperList = RevSys_EmployeeCertificationHelper.validateCertification(newEmpCertList);
			List<EmployeeCertification__c> ecToExpire = new List<EmployeeCertification__c>();
			List<EmployeeCertification__c> ecToCurrent = new List<EmployeeCertification__c>();
			for(RevSys_EmployeeCertificationHelper.EmployeeCertificationWrapper wrp : ecWrapperList) {
				if(wrp.hasError==false && wrp.ecRecord.ExpirationDate__c >= SYSTEM.today()) {
					ecToCurrent.add(wrp.ecRecord);
				} else {
					ecToExpire.add(wrp.ecRecord);
				}
			}
			if(!ecToExpire.isEmpty()) {
				errMsg = setExpiredStatus(ecToExpire);
			}
			if(!ecToCurrent.isEmpty()) {
				errMsg += setCurrentStatus(ecToCurrent);
			}
		}
		errMsg = StringUtility.cleanupMessage(errMsg);  
		return errMsg;
	}


}