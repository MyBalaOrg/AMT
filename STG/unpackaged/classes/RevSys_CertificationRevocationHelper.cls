/**
*___________________________________________________
*@Name: RevSys_CertificationRevocationHelper
*@Author: Hemanth Kesapragada
*@Created: Date: 02/15/2018
*@Used_By: SPARTN
*___________________________________________________
*@Description: Helper class to accomodate business logic related to Certification Revocation Records.
* 
*___________________________________________________
*@Changes: 
* 05-18-2018. [Boom Bertetti] 
*            - Update logic to process revocation based on certification type (Engineer or Conductor)
*              and event type (Main Track or Non-Main Track)
*            - Update the revocation period for Drug & Alcohol violation      
*              based on when the violation occurence (on-duty or off-duty)
* 06-03-2018 
*            - Removed autoPopulateFields method
**/
public with sharing class RevSys_CertificationRevocationHelper {
	
    /**
    *————————————————————————————————————————————————————
    * @Name: updateEmployeeCerification()
    * @Description
    * When the certification revocation is removed, the Employee Certification becomes either current/Expired
    *————————————————————————————————————————————————————
    * @param    revocationList   List of Revocation records from Trigger
    * 			oldMap			 old revocation records
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String updateEmployeeCertification(List<CertificationRevocation__c> revocationList,Map<Id, CertificationRevocation__c> oldMap) {
    	system.debug('HELPER RevSys_CertificationRevocationHelper updateEmployeeCertification-Start'); 
    	String errMsg = '';
    	Set<Id> empCertId = new Set<Id>();
    	for(CertificationRevocation__c cRevocation : revocationList) {
            if (oldMap != null) {
        		CertificationRevocation__c oldRec = oldMap.get(cRevocation.Id);
        		if(String.isNotBlank(cRevocation.Status__c) && cRevocation.Status__c== Label.RevSys_Generic_Status_Inactive && cRevocation.Status__c!=oldRec.Status__c ) {
        			empCertId.add(cRevocation.EmployeeCertification__c);
        		}
            }
            else {
                empCertId.add(cRevocation.EmployeeCertification__c);
            }
    	}

    	if(!empCertId.isEmpty()) {
    		System.debug('**** removed Revocation empCertId '+empCertId);
    		errMsg = RevSys_EmployeeCertificationStatusHelper.processRevocationRecords(empCertId);
    	}

    	system.debug('HELPER RevSys_CertificationRevocationHelper updateEmployeeCertification-End'); 
    	return errMsg;

    }

    /**
    *————————————————————————————————————————————————————
    * @Name: processRevocationNew()
    * @Description
    * When the certification revocation is created, updated or deleted, process Revocation End Date based on 
    * Revocation Begin Date, Performing As, Track Type and CFR Violations.
    *————————————————————————————————————————————————————
    * @param    revocationList   List of Revocation records from Trigger
    *           oldMap           old revocation records
    *           isFromDelete    if the list is from isDelete trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String processRevocation(List<CertificationRevocation__c> revocationList, Map<Id, CertificationRevocation__c> oldMap, Boolean isFromDelete) {
        System.debug('=====> start processRevocationNew');
        String errMsg = '';
        Boolean isFromInsert = false;
        CertRevHelperWrapper crWrapper;
        List<CertificationRevocation__c> newCertRvList = new List<CertificationRevocation__c>();
        Map<Id, CertificationRevocation__c> certRevToUpdate = new Map<Id, CertificationRevocation__c>();
        Map<Id, EmployeeCertification__c> empCertToUpdate   = new Map<Id, EmployeeCertification__c>();
        Map<Id, EmployeeCertification__c> empCertToReset   = new Map<Id, EmployeeCertification__c>();
        Set<Id> empCertIdSet = new Set<Id>();
    //    Map<String, Map<String, Integer>> ecViolationFreqMap = new Map<String, Map<String, Integer>>();
    //    Map<String, Date> initialRevocationMap = new Map<String, Date>();
        Map<Id,EmployeeCertification__c> ecMap = new Map<Id,EmployeeCertification__c>();        

        
        if (oldMap == null && isFromDelete == false) {
            isFromInsert = true;
            for (CertificationRevocation__c certRv : revocationList) {
                if (certRv.EmployeeCertification__c != null 
                    && certRv.Status__c == Label.RevSys_Generic_Status_Active
                    && certRv.RecordTypeId == RevSys_StaticUtility.CERTIFICATION_REVOCATION_SPARTN_RECTYPE_ID) {
                    empCertIdSet.add(certRv.EmployeeCertification__c);
                    newCertRvList.add(certRv);
                }
            }
        }
        else if (oldMap != null || isFromDelete) {
            System.debug('=====> it is updated or deleted');
            for (CertificationRevocation__c certRv : revocationList) {
                if (oldMap != null) {
                    CertificationRevocation__c oldCertRv = oldMap.get(certRv.Id);
                    if (oldCertRv.Status__c != certRv.Status__c 
                        && certRv.EmployeeCertification__c != null 
                        && certRv.Status__c == Label.RevSys_Generic_Status_Inactive
                        && certRv.RecordTypeId == RevSys_StaticUtility.CERTIFICATION_REVOCATION_SPARTN_RECTYPE_ID) {
                        empCertIdSet.add(certRv.EmployeeCertification__c);
                    //    certRvToProcess.add(certRv);
                    }
                }
                else if (isFromDelete) {
                    System.debug('=====> it is delete');                    
                    if (certRv.EmployeeCertification__c != null 
                        && certRv.Status__c == Label.RevSys_Generic_Status_Active
                        && certRv.RecordTypeId == RevSys_StaticUtility.CERTIFICATION_REVOCATION_SPARTN_RECTYPE_ID) {
                        empCertIdSet.add(certRv.EmployeeCertification__c);
                    //    certRvToProcess.add(certRv);
                    }
                }
            }            
        }

        if (!empCertIdSet.isEmpty()) {
            //Get all the EC details from Certification revocation
            SelectorWrapper ecWrapper = EmployeeCertificationSelector.getEmpCertification(empCertIdSet);
            if(ecWrapper != null && String.isBlank(ecWrapper.ErrorMessage)) {
                for(EmployeeCertification__c ecRec : (List<EmployeeCertification__c>) ecWrapper.sObjectList) {
                    ecMap.put(ecRec.Id, ecRec);
                }
            } else if (ecWrapper != null) {
                crWrapper.errorMessage = ecWrapper.ErrorMessage;
            }
            //Get CRs from the a list of EC record Ids.
            SelectorWrapper certRevocationWrapper = CertificationRevocationSelector.getActiveRevocationRecords(ecMap.keySet(), 'RevocationBeginDate__c', 'DESC NULLS LAST');
            
            if(certRevocationWrapper != null && String.isBlank(certRevocationWrapper.ErrorMessage)) {
                List<CertificationRevocation__c> certRvtoProcessList = (List<CertificationRevocation__c>)certRevocationWrapper.SObjectList;
                certRvtoProcessList.addAll(newCertRvList);
                CertRevHelperWrapper crWrapperFrq = getViolationFreqMap(certRvtoProcessList, ecMap);
                List<CertificationRevocation__c> latestCertRvList = crWrapperFrq.latestCertRevocationList;
                System.debug('=====> latestCertRvList: ' + latestCertRvList.size());
            //    ecViolationFreqMap = crWrapperFrq.violationFrequencyMap;
            //    initialRevocationMap = crWrapperFrq.initialRevocationMap;
                
                if (isFromInsert) {
                    crWrapperFrq.isFromInsert = true;
                    crWrapper = getObjectsToupdateMap(ecMap, crWrapperFrq, newCertRvList);
                }
                else {
                    if (latestCertRvList != null && latestCertRvList.size() > 0) {
                        crWrapperFrq.isFromInsert = false;
                        crWrapper = getObjectsToupdateMap(ecMap, crWrapperFrq, latestCertRvList);
                    }
                    if (crWrapperFrq.employeeCertToUpdateMap != null) {
                        empCertToReset = resetEmpCertRevocation(crWrapperFrq.employeeCertToUpdateMap);
                    }
                }
            } else if (!String.isBlank(certRevocationWrapper.ErrorMessage)) {
                crWrapper.errorMessage += certRevocationWrapper.ErrorMessage;
            }
        }

        if (crWrapper != null) {
            certRevToUpdate = crWrapper.certRevoToUpdateMap;
            empCertToUpdate = crWrapper.employeeCertToUpdateMap;

            errMsg += crWrapper.errorMessage;
        }

        if (!empCertToReset.isEmpty()) {
            empCertToUpdate.putAll(empCertToReset);
        }

        System.debug('=====> empCertToUpdate: ' + empCertToUpdate.size());
        if(!empCertToUpdate.isEmpty()) {
            errMsg += DMLHelper.updateList(empCertToUpdate.values());
        }

        System.debug('=====> certRevToUpdate: ' + certRevToUpdate.size());
        if(!certRevToUpdate.isEmpty() && !isFromInsert) {
            errMsg += DMLHelper.updateList(certRevToUpdate.values());
        }

        return StringUtility.cleanUpMessage(errMsg);
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getObjectsToupdateMap()
    * @Description
    * Perform revocation logic based on Revocation Begin Date, Performing As, Track Type and CFR Violations.
    * Add the certification revocations and employee certifications to the maps if they have to be updated.
    *————————————————————————————————————————————————————
    * @param    ecMap   map of employee certificlations
    *           crWrapperFrq CertRevHelperWrapper
    *           revocationList  a list of Certification revocation to process
    * @return   CertRevHelperWrapper   Wrapper contains map of objects to update
    *————————————————————————————————————————————————————
    **/ 
    public static CertRevHelperWrapper getObjectsToupdateMap(Map<Id,EmployeeCertification__c> ecMap, 
                                                             CertRevHelperWrapper crWrapperFrq, 
                                                             List<CertificationRevocation__c> revocationList) {
        CertRevHelperWrapper crWrapper = new CertRevHelperWrapper();
        String ALLVIOLATION = 'All';
        Map<String, Map<String, Integer>> ecViolationFreqMap = new Map<String, Map<String, Integer>>();
        Map<String, Date> initialRevocationMap = new Map<String, Date>();
        Map<Id, Integer> lastTwelveMosViolationMap = new Map<Id, Integer>();

        if (crWrapperFrq.violationFrequencyMap != null) {
            ecViolationFreqMap = crWrapperFrq.violationFrequencyMap;
        }
        if (crWrapperFrq.initialRevocationMap != null) {   
            initialRevocationMap = crWrapperFrq.initialRevocationMap;
        }
        if (crWrapperFrq.violationLastTwelveMosMap != null) {
            lastTwelveMosViolationMap  = crWrapperFrq.violationLastTwelveMosMap;            
        }
        System.debug('=====> crWrapperFrq isFromInsert' + crWrapperFrq.isFromInsert);
        Map<Id, CertificationRevocation__c> certRevToUpdate = new Map<Id, CertificationRevocation__c>();
        Map<Id, EmployeeCertification__c> empCertToUpdate   = new Map<Id, EmployeeCertification__c>();

        for (CertificationRevocation__c certRv : revocationList) {
            String violation = (certRv.Violation__c == Label.RevSys_On_Duty_Drug_Alcohol_Violation ||
                                certRv.Violation__c == Label.RevSys_Off_Duty_Drug_Violation ) ? certRv.Violation__c : ALLVIOLATION;
            Integer probationPeriod = Integer.valueOf(Label.RevSys_Probation_Period);
            Integer lstTwelveMosViolations = lastTwelveMosViolationMap.get(certRv.EmployeeCertification__c);
            System.debug('=====> lstTwelveMosViolations ' + lstTwelveMosViolations);

            if (certRv.EmployeeCertification__c != null) {
                EmployeeCertification__c ec = ecMap.get(certRv.EmployeeCertification__c);

                System.debug('=====> getObjectsToupdateMap - ec.RevocationBeginDate__c' + ec.RevocationBeginDate__c);
                Map<String, Integer> violationFrequencyMap = ecViolationFreqMap.get(certRv.EmployeeCertification__c);

                if (!violationFrequencyMap.isEmpty() && violationFrequencyMap != null) {
                    Integer freq = (violationFrequencyMap.get(ALLVIOLATION) == null) ? 0 : violationFrequencyMap.get(ALLVIOLATION);
                    Integer onDutyFreq = (violationFrequencyMap.get(Label.RevSys_On_Duty_Drug_Alcohol_Violation) == null) ? 0 : violationFrequencyMap.get(Label.RevSys_On_Duty_Drug_Alcohol_Violation);
                    Integer offDutyFreq = (violationFrequencyMap.get(Label.RevSys_Off_Duty_Drug_Violation) == null) ? 0 : violationFrequencyMap.get(Label.RevSys_Off_Duty_Drug_Violation);
                    Integer revokedPeriod = 0;
                    Date revocationEndDate; 
                    String finalStatus = RevSys_StaticUtility.REVOKED;

                    if (initialRevocationMap.get(certRv.EmployeeCertification__c) != null) {
                        ec.RevocationBeginDate__c = initialRevocationMap.get(certRv.EmployeeCertification__c);
                    }

                    if (violation == Label.RevSys_On_Duty_Drug_Alcohol_Violation) {
                        if (onDutyFreq >= 2) {
                            System.debug('=====>  on-duty: more than 2');
                            revokedPeriod = Integer.valueOf(Label.RevSys_On_Duty_Drug_Alcohol_Violation_2nd_Offense);
                        }
                        else if (onDutyFreq == 1 && offDutyFreq == 1) {
                            System.debug('=====>  on-duty: with off-duty');
                            revokedPeriod = Integer.valueOf(Label.RevSys_On_and_Off_Duty_Violation);
                        }
                        else if (onDutyFreq == 1) {
                            System.debug('=====>  on-duty: 1');
                            revokedPeriod = Integer.valueOf(Label.RevSys_On_Duty_Drug_Alcohol_Violation_1st_Offense);
                        }

                        if (certRv.RevocationBeginDate__c != null) {
                            revocationEndDate = (certRv.RevocationBeginDate__c).addMonths(revokedPeriod);
                        }
                    }

                    if (violation == Label.RevSys_Off_Duty_Drug_Violation) {
                        if (offDutyFreq > 2) {
                            System.debug('=====>  off-duty: more than 2');
                            revokedPeriod = Integer.valueOf(Label.RevSys_Off_Duty_Drug_Violation_3rd_Offense);
                        }
                        else if (offDutyFreq == 2) {
                            System.debug('=====>  off-duty: 2');
                            revokedPeriod = Integer.valueOf(Label.RevSys_Off_Duty_Drug_Violation_2nd_Offense);
                        }
                        else if (onDutyFreq == 1 && offDutyFreq == 1) {
                            System.debug('=====>  off-duty: with on-duty');
                            revokedPeriod = Integer.valueOf(Label.RevSys_On_and_Off_Duty_Violation);
                        }
                        else if (offDutyFreq == 1) {
                            System.debug('=====>  off-duty: 1');
                            finalStatus = Label.RevSys_Off_Duty_Drug_Violation_1st_Offense;
                        }

                        if (certRv.RevocationBeginDate__c != null) {
                            revocationEndDate = (certRv.RevocationBeginDate__c).addMonths(revokedPeriod);
                        }
                    }

                    if (!String.isEmpty(certRv.Violation__c)) {
                        Date tempRevokeEndDate;
                        Integer firstProbationPeriod = Integer.valueOf(Label.RevSys_Probation_Period_1st_Offense);
                        Boolean updateTempRevokeEndDate = true;
                        System.debug('=====>  other violation certRv.RevocationBeginDate__c: ' + certRv.RevocationBeginDate__c);
                        if (freq == 1 ||
                            (freq == 2 && ec.RevocationBeginDate__c.addMonths(firstProbationPeriod) < certRv.RevocationBeginDate__c)) {
                            revokedPeriod = Integer.valueOf(Label.RevSys_Revocation_Period_1st_Offense);
                            if (certRv.TrackType__c == Label.RevSys_Track_Type_None_Main_Track && lstTwelveMosViolations <= 1) {
                                revokedPeriod = Math.round(revokedPeriod * 0.5); 
                            }
                            System.debug('=====>  other violation 1');
                            updateTempRevokeEndDate = false;
                            if (certRv.RevocationBeginDate__c != null) {
                                tempRevokeEndDate = (certRv.RevocationBeginDate__c).addDays(revokedPeriod);
                            }
                        }
                        else if (freq == 2) {
                            System.debug('=====>  other violation 2');
                            revokedPeriod = Integer.valueOf(Label.RevSys_Revocation_Period_2nd_Offense);
                        //    probationPeriod = Integer.valueOf(Label.RevSys_Probation_Period);
                        }
                        else if (freq == 3) {
                            System.debug('=====>  other violation 3');
                            revokedPeriod = Integer.valueOf(Label.RevSys_Revocation_Period_3rd_Offense);
                        //    probationPeriod = Integer.valueOf(Label.RevSys_Probation_Period);
                        }
                        else if (freq >= 4) {
                            System.debug('=====>  other violation 4 or more');
                            revokedPeriod = Integer.valueOf(Label.RevSys_Revocation_Period_4th_Offense);
                        //    probationPeriod = Integer.valueOf(Label.RevSys_Probation_Period);
                        }
                        System.debug('=====>  updateTempRevokeEndDate: ' +updateTempRevokeEndDate);
                        if (freq > 1 && updateTempRevokeEndDate == true) {
                            if (certRv.TrackType__c == Label.RevSys_Track_Type_None_Main_Track && lstTwelveMosViolations <= 1) {
                                revokedPeriod = Math.round(revokedPeriod * 0.5);
                            }

                            if (certRv.RevocationBeginDate__c != null) {
                                tempRevokeEndDate = (certRv.RevocationBeginDate__c).addMonths(revokedPeriod);
                            }
                        }
                        System.debug('=====> tempRevokeEndDate: ' + tempRevokeEndDate);
                     //   if (!crWrapperFrq.isFromInsert) {
                     //       revocationEndDate = tempRevokeEndDate;
                     //   }
                        if (tempRevokeEndDate > revocationEndDate || revocationEndDate == null) {
                            revocationEndDate = tempRevokeEndDate;
                        }
                    }

                    if (ec.RevocationBeginDate__c == null) {
                        ec.RevocationBeginDate__c = certRv.RevocationBeginDate__c;
                    }

                    Date probationEndDate = ec.RevocationBeginDate__c != null ? (ec.RevocationBeginDate__c).addMonths(probationPeriod) : null;
                    certRv.RevocationEndDate__c = revocationEndDate;
                    certRevToUpdate.put(certRv.Id, certRv);
                    System.debug('=====> ec.RevocationEndDate__c: ' + ec.RevocationEndDate__c);
                    System.debug('=====> revocationEndDate: ' + revocationEndDate);
                    System.debug('=====> ec.ProbationEndDate__c: ' + ec.ProbationEndDate__c);
                    System.debug('=====> probationEndDate: ' + probationEndDate);

                    if (ec.RevocationEndDate__c == null) {
                        ec.RevocationEndDate__c = revocationEndDate;
                    }

                    if (ec.ProbationEndDate__c == null) {
                        ec.ProbationEndDate__c = probationEndDate;
                    }

                    if (crWrapperFrq.isFromInsert) {
                        if (revocationEndDate > ec.RevocationEndDate__c && ec.RevocationEndDate__c != null) {
                            ec.RevocationEndDate__c = revocationEndDate;
                        }
                        if (probationEndDate > ec.ProbationEndDate__c && ec.ProbationEndDate__c != null) {
                            ec.ProbationEndDate__c = probationEndDate;
                        }
                    }
                    else {
                        ec.RevocationEndDate__c = revocationEndDate;
                        ec.ProbationEndDate__c = probationEndDate;
                    }

                    ec.Status__c = finalStatus;
                    ec.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
                    empCertToUpdate.put(ec.Id, ec);

                    System.debug('=====> freq: ' + freq);
                    System.debug('=====> onDutyFreq: ' + onDutyFreq);
                    System.debug('=====> offDutyFreq: ' + offDutyFreq);
                }
            }
        }
       crWrapper.employeeCertToUpdateMap = empCertToUpdate;
       crWrapper.certRevoToUpdateMap = certRevToUpdate;

        return crWrapper;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: resetEmpCertRevocation()
    * @Description
    * Clean up Employee Certification if it no longer has any associated active Certification Revocations.
    *————————————————————————————————————————————————————
    * @param    ecMapWithNoCertRev   map of employee certificlations that don't have any certification revocations.
    * @return   Map<Id,EmployeeCertification__c>   return back the map of employee certification with the updated dates values.
    *————————————————————————————————————————————————————
    **/ 
    public static Map<Id,EmployeeCertification__c> resetEmpCertRevocation(Map<Id,EmployeeCertification__c> ecMapWithNoCertRev) {

        for (EmployeeCertification__c ec : ecMapWithNoCertRev.values()) {
            ec.RevocationBeginDate__c = null;
            ec.RevocationEndDate__c = null;
            ec.ProbationEndDate__c = null;
            ec.ProcessFlag__c = Label.RevSys_EmpCert_ProcessFlag;
        }


        return ecMapWithNoCertRev;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getEmpCertWithcertRevsMap()
    * @Description
    * A helper method that gets a map of Certificatin Revocations list indexed by Employee Cetificaiton Id 
    *————————————————————————————————————————————————————
    * @param    certRvList   List of CertificationRevocation__c
    * @return   Map<String, List<CertificationRevocation__c>>   Map of List Certification Revocation indexed by Employee Certification Id
    *————————————————————————————————————————————————————
    **/ 
    public static Map<String, List<CertificationRevocation__c>> getEmpCertWithcertRevsMap(List<CertificationRevocation__c> certRvList) {
        Map<String, List<CertificationRevocation__c>> ecWcrMap = new Map<String, List<CertificationRevocation__c>>(); 

        for (CertificationRevocation__c certRv : certRvList) {
            if (!ecWcrMap.containsKey(certRv.EmployeeCertification__c)) {
                ecWcrMap.put(certRv.EmployeeCertification__c, new List<CertificationRevocation__c>());
            }

            ecWcrMap.get(certRv.EmployeeCertification__c).add(certRv);
        }

        return ecWcrMap;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: getViolationFreqMap()
    * @Description
    * A helper method that groups Map<String, Integer> by EmployeeCertification__c.Id and put them in another map.
    *————————————————————————————————————————————————————
    * @param    certRvList   List of CertificationRevocation__c
    * @return   Map<String, Map<String, Integer>>  Map of the map of violation frequecy 
    *————————————————————————————————————————————————————
    **/ 
    public static CertRevHelperWrapper getViolationFreqMap(List<CertificationRevocation__c> certRvList, Map<Id,EmployeeCertification__c> ecMap) {
        String ALLVIOLATION = 'All';
        Map<String, Map<String, Integer>> ecViolationFreqMap = new Map<String, Map<String, Integer>>();
        Map<String, Date> initialRevocationMap = new Map<String, Date>();
        Map<String, List<CertificationRevocation__c>> ecWcrMap = getEmpCertWithcertRevsMap(certRvList);
        Map<Id, EmployeeCertification__c> empCertWithoutCertRvMap = new Map<Id, EmployeeCertification__c>();
        List<CertificationRevocation__c> latestCertRvList = new List<CertificationRevocation__c>();
        Map<Id, Integer> violationLastTwelveMosMap = new Map<Id, Integer>();

        if (!ecMap.isEmpty()) {
            for (String  ecId : ecMap.keySet()) {
                Map<String, Integer> violationFrequencyMap = new Map<String, Integer>();
                EmployeeCertification__c ec = ecMap.get(ecId);
                Integer freq = 0;
                Integer onDutyFreq = 0;
                Integer offDutyFreq = 0;
                Date initialRevokedDate = ec.RevocationBeginDate__c;
                Date probationDate = ec.ProbationEndDate__c;
                Date latestRevocationEndDate;
                Integer totalCertRv = 0;
                Boolean crValidProbation = true;
                Integer violationLastTwelveMos = 0;

                if (ecWcrMap.get(ecId) != null) {
                    List<CertificationRevocation__c> certRevocationList = ecWcrMap.get(ecId);
                    totalCertRv = certRevocationList.size();
                    for (CertificationRevocation__c certRv : certRevocationList) {
                //    for (CertificationRevocation__c certRv : ecWcrMap.get(ecId)) 
                        String violation = (certRv.Violation__c == Label.RevSys_On_Duty_Drug_Alcohol_Violation ||
                                            certRv.Violation__c == Label.RevSys_Off_Duty_Drug_Violation ) ? certRv.Violation__c : ALLVIOLATION;
                        if (certRv.IncidentDate__c >= System.today().addMonths(-12)) {
                            violationLastTwelveMos++;
                        }

                        if (certRv.RevocationBeginDate__c != null) {
                            Date certRVprobationDate = certRv.RevocationBeginDate__c.addMonths(Integer.valueOf(Label.RevSys_Probation_Period));

                            if (certRVprobationDate < System.today()) {
                                crValidProbation = false;
                            }
                            else {
                                crValidProbation = true;
                            }
                            // Getting the earliest active certification revocation begin date
                            if (certRv.Status__c == Label.RevSys_Generic_Status_Active) {
                                if (initialRevokedDate == null) {
                                    initialRevokedDate = certRv.RevocationBeginDate__c;
                                }
                                if (probationDate != null && probationDate < System.today() && crValidProbation) {
                                    initialRevokedDate = certRv.RevocationBeginDate__c;
                                    probationDate = certRVprobationDate;
                                    System.debug('=====> here');
                                }

                                if (certRv.RevocationBeginDate__c < initialRevokedDate) {
                                    if (probationDate != null) {
                                        if (certRv.RevocationBeginDate__c >= initialRevokedDate && certRv.RevocationBeginDate__c <= probationDate) {
                                            initialRevokedDate = certRv.RevocationBeginDate__c;
                                        }
                                    }
                                    else {
                                        initialRevokedDate = certRv.RevocationBeginDate__c;
                                    }
                                    System.debug('=====> there');
                                    probationDate = initialRevokedDate.addMonths(Integer.valueOf(Label.RevSys_Probation_Period));
                                }

                                if (probationDate == null) {
                                    probationDate = certRVprobationDate;
                                }

                                if (certRv.RevocationEndDate__c != null && 
                                    (latestRevocationEndDate == null || latestRevocationEndDate < certRv.RevocationEndDate__c)) {
                                    latestRevocationEndDate = certRv.RevocationEndDate__c;
                                    latestCertRvList.add(certRv);
                                }
                            }
                            /*
                            if (!crValidProbation) {
                                probationDate = certRv.RevocationBeginDate__c.addDays(-1);
                            }
                            */
                        }
                        if (certRv.Status__c == Label.RevSys_Generic_Status_Active) {
                            if (!violationFrequencyMap.containsKey(violation)) {
                                if (violation == Label.RevSys_On_Duty_Drug_Alcohol_Violation) {
                                    violationFrequencyMap.put(violation, onDutyFreq);
                                }
                                else if (violation == Label.RevSys_Off_Duty_Drug_Violation) {
                                    violationFrequencyMap.put(violation, offDutyFreq);
                                }
                            //    else {
                                violationFrequencyMap.put(ALLVIOLATION, freq);
                             //   }
                            }
                            
                            if (violation == Label.RevSys_On_Duty_Drug_Alcohol_Violation) {
                                onDutyFreq = violationFrequencyMap.get(violation);
                                onDutyFreq++;
                                violationFrequencyMap.put(violation, onDutyFreq);
                            }
                            else if (violation == Label.RevSys_Off_Duty_Drug_Violation) {
                                offDutyFreq = violationFrequencyMap.get(violation);
                                offDutyFreq++;
                                violationFrequencyMap.put(violation, offDutyFreq);
                            }
                            // Add all active violations to this map
                            System.debug('=====> getMap certRv.RevocationBeginDate__c: ' + certRv.RevocationBeginDate__c);
                            System.debug('=====> getMap probationDate: ' + probationDate);
                            System.debug('=====> getMap initialRevokedDate: ' + initialRevokedDate);
                            if (initialRevokedDate != null && probationDate != null && crValidProbation) {
                                if ((certRv.RevocationBeginDate__c >= initialRevokedDate && certRv.RevocationBeginDate__c <= probationDate)
                                    || (violation == Label.RevSys_Off_Duty_Drug_Violation &&  certRv.RevocationBeginDate__c == null)) {
                                    System.debug('=====> getMap adding to freq certRv.RevocationBeginDate__c: ' + certRv.RevocationBeginDate__c);
                                    freq = violationFrequencyMap.get(ALLVIOLATION);
                                    freq++;
                                    violationFrequencyMap.put(ALLVIOLATION, freq); 
                                }
                            }
                            else if (violation == Label.RevSys_Off_Duty_Drug_Violation &&  certRv.RevocationBeginDate__c == null) {
                                System.debug('=====> getMap adding to freq when init date is null certRv.RevocationBeginDate__c: ' + certRv.RevocationBeginDate__c);
                                freq = violationFrequencyMap.get(ALLVIOLATION);
                                freq++;
                                violationFrequencyMap.put(ALLVIOLATION, freq); 
                            }
                            else if (totalCertRv == 1) {
                                freq = violationFrequencyMap.get(ALLVIOLATION);
                                freq++;
                                violationFrequencyMap.put(ALLVIOLATION, freq);                            
                            }  

                        //    if (i == 0) {
                        //        latestCertRvList.add(certRv);
                        //    }
                        }
                    }
                    ecViolationFreqMap.put(ecId, violationFrequencyMap);
                    initialRevocationMap.put(ecId, initialRevokedDate);
                    violationLastTwelveMosMap.put(ecId, violationLastTwelveMos);
                }
                else {
                    empCertWithoutCertRvMap.put(ecId, ec);
                }
            }
        }

        CertRevHelperWrapper crWrapper = new CertRevHelperWrapper();
        crWrapper.violationFrequencyMap = ecViolationFreqMap;
        crWrapper.initialRevocationMap = initialRevocationMap;
        crWrapper.latestCertRevocationList = latestCertRvList;
        crWrapper.employeeCertToUpdateMap = empCertWithoutCertRvMap;
        crWrapper.violationLastTwelveMosMap = violationLastTwelveMosMap;

        return crWrapper;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: CertRevHelperWrapper()
    * @Description
    * A class class contatins violationFrequencyMap and initialRevocationMap.
    *————————————————————————————————————————————————————
    **/ 
    public class CertRevHelperWrapper {
        public Boolean isFromInsert;
        public String errorMessage;
        public Map<String, Map<String, Integer>> violationFrequencyMap;
        public Map<String, Date> initialRevocationMap;
        public Map<Id, EmployeeCertification__c> employeeCertToUpdateMap;
        public Map<Id, CertificationRevocation__c> certRevoToUpdateMap;
        public List<CertificationRevocation__c> latestCertRevocationList;
        public Map<Id, Integer> violationLastTwelveMosMap;
    }

}