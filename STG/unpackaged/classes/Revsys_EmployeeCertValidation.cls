/**
*___________________________________________________
*@Name: Revsys_EmployeeCertValidation
*@Author: Chuck Walley
*@Created: Date: 03/04/2018
*@Used_By: Review Systems
*___________________________________________________
*@Description: Checks Employee Certification records for duplicates
* 
*___________________________________________________
*@Changes: 
* 04-05-2018 checkSupervisorQualificationDupe()  [cwalley]
**/

global with sharing class Revsys_EmployeeCertValidation {

    /**
    *————————————————————————————————————————————————————
    * @Name: checkEmployeeCertDupe
    * @Description
    * Culls Occupation Specific Requirement records by Record Type 
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkEmpCertDupe(List<EmployeeCertification__c> theEcList, 
                                          Map<Id,SObject> theOldMap)
    {
        system.debug('HELPER Revsys_EmployeeCertValidation checkEmpCertDupe-Start');     
        
        string errMsg;

        List<EmployeeCertification__c> myListToCheck = new List<EmployeeCertification__c>();

        for(EmployeeCertification__c theEc :theEcList) {
            if(theEc.RecordTypeId == RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID && 
               theEc.Archived__c  != true) {
                    myListToCheck.add(theEc); 
               }
        }

        myListToCheck = SObjectJunctDupeCheck.determineRecord(myListToCheck, theOldMap, 
                                                             'Certification__c', 'Employee__c',
                                                              RevSys_StaticUtility.EMPCERT_SPARTNCERT_RECTYPE_ID); 
        if(myListToCheck.size() > 0) {

            Set<Id> myFKeyASet = new Set<Id>();  
            Set<Id> myFKeyBSet = new Set<Id>();  

            Set<String> myMashKeySet; 

            for(EmployeeCertification__c theEc :myListToCheck) {
                myFKeyASet.add(theEc.Certification__c);   
                myFKeyBSet.add(theEc.Employee__c);
            }

            // query Certifications for fKeyA
            SelectorWrapper mySelWrapC = OccupationCertificationSelector.getCertifications(myFKeyASet); 

            errMsg = mySelWrapC.ErrorMessage; 
            List<OccupationCertification__c> myOcList = mySelWrapC.SObjectList; 

            // query Employees for fKeyB
            SelectorWrapper mySelWrapE = ContactSelector.getContacts(myFKeyBSet); 

            errMsg = mySelWrapE.ErrorMessage; 
            List<Contact> myEmpList = mySelWrapE.SObjectList; 

            SelectorWrapper mySwrap = EmployeeCertificationSelector.getEmpCertByCertAndEmpIds(myFKeyASet, myFKeyBSet); 

            errMsg = mySwrap.ErrorMessage; 
            List<EmployeeCertification__c> myEcList = mySwrap.SObjectList; 

            myFKeyASet = new Set<Id>();  
            myFKeyBSet = new Set<Id>();  

            if(errMsg == null && myEcList.size() > 0) {
                errMsg = SObjectJunctDupeCheck.checkForDupe(myListToCheck, myEcList, 
                                                            'Certification__c',myOcList, 
                                                            'Employee__c', myEmpList);
            }

            if(errMsg == null) {
                    errMsg = checkCertTypeDupe(myListToCheck, myEmpList); 
            }
        }
        
        system.debug('HELPER Revsys_EmployeeCertValidation checkEmpCertDupe-End'); 
        return errMsg;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: checkCertTypeDupe
    * @Description
    * Culls Occupation Specific Requirement records by Record Type 
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkCertTypeDupe(List<EmployeeCertification__c> theEcList, 
                                           List<Contact> theEmpList)
                                          
    {
        system.debug('HELPER Revsys_EmployeeCertValidation checkCertTypeDupe-Start');     

        string errMsg;

        Map<Id,String> myEmpNameByIdMap = SObjectJunctDupeCheck.mapNameById(theEmpList);

        Set<Id> myEmpIdSet = new Set<Id>(); 
        Set<String> myCertTypeSet = new Set<String>(); 

        for(EmployeeCertification__c theEc :theEcList) {
            myEmpIdSet.add(theEc.Employee__c);
            myCertTypeSet.add(theEc.CertificationType__c);
        }

        SelectorWrapper mySwrap 
            = EmployeeCertificationSelector.getByEmpIdAndCertType(myEmpIdSet, myCertTypeSet); 

        errMsg = mySwrap.ErrorMessage;
        List<EmployeeCertification__c> myEcList = mySwrap.SObjectList; 

        system.debug('myEcList  '  + myEcList);

        if(errMsg == null && myEcList.size() > 0) {

            Set<String> myMashSet = new Set<String>(); 

            for(EmployeeCertification__c myEc :myEcList) {
                myMashSet.add(String.valueOf(myEc.Employee__c) + myEc.CertificationType__c); 
            }

            for(EmployeeCertification__c theEc :theEcList) { 

                String myMashKey = String.valueOf(theEc.Employee__c) + theEc.CertificationType__c;
                if(myMashSet.contains(myMashKey)) {

                    String myReplacement = '\'' + myEmpNameByIdMap.get(theEc.Employee__c) + ' - ' 
                                                + theEc.CertificationType__c + '\'';

                    String Msg = Label.Revsys_Junct_Object_Dupe; 
                    Msg = Msg.replace(Label.Revsys_Junct_Object_Dupe_Replace, myReplacement); 

                    errMsg += Msg; 
                }
            }
        }
        
        system.debug('HELPER Revsys_EmployeeCertValidation checkCertTypeDupe-End'); 
        return errMsg;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: checkSupervisorQualificationDupe
    * @Description - validates Supervision Qualification records. 
    * Culls Occupation Specific Requirement records by Record Type 
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkSupervisorQualificationDupe(List<EmployeeCertification__c> theEcList, 
                                                          Map<Id,SObject> theOldMap)
    {
        system.debug('HELPER Revsys_EmployeeCertValidation checkSupervisorQualificationDupe-Start');

        string errMsg;

        List<EmployeeCertification__c>   myListToCheck = new List<EmployeeCertification__c>();
        Map<Id,EmployeeCertification__c> myEmpCertMap  = new Map<Id,EmployeeCertification__c>(); 

        Set<Id> myEmpIdSet = new Set<Id>(); 

        // Determine if we want to evaluate this record 
        // - It has to be a Spartn Supervisor Qualification record
        // - If it is a new insert, we want to check it 
        // - If it is an update, check it if the Employee has changed 

        for(EmployeeCertification__c theEc :theEcList) {

            if(theEc.RecordTypeId == RevSys_StaticUtility.EMPCERT_SPARTSUPV_RECTYPE_ID && 
               theEc.Archived__c  != true) {
                
                if(theOldMap == null) {
                    myEmpIdSet.add(theEc.Employee__c); 
                }
                else {
                    
                    SObject myOldSobj = theOldMap.get(theEc.Id); 
                    EmployeeCertification__c myOldEc = (EmployeeCertification__c)myOldSobj; 
                    if(theEc.Employee__c != myOldEc.Employee__c) {

                        myEmpIdSet.add(theEc.Employee__c); 
                    }
                }
            }
        }


        // We've culled our records and are ready to check

        if(myEmpIdSet.size() > 0 ) {
            
            // Get the current Supervisor Qualification records 
            SelectorWrapper myEcWrap = EmployeeCertificationSelector.getSupervisorEmpCert(myEmpIdSet); 

            if(myEcWrap.ErrorMessage == null && myEcWrap.SobjectList.size() > 0) { 
                // Put them in a map 
                for(EmployeeCertification__c myEc :(List<EmployeeCertification__c>)myEcWrap.SObjectList) {
                    myEmpCertMap.put(myEc.Employee__c,myEc); 
                }
            }
            // Validation Check ++ 
            for(EmployeeCertification__c theEc :theEcList) {

                // Get the employee out of the current map 
                EmployeeCertification__c myCurrentEmpCert 
                        = myEmpCertMap.get(theEc.Employee__c); 

                if(myCurrentEmpCert != null) {
                    // The employee is a part of the current supervisor map 
                    // Validation Error Encountered 
                    String Msg = Label.Revsys_Supervisor_Qual_Record_Dupe; 
                    errMsg = Msg.replace(Label.Revsys_Junct_Object_Dupe_Replace, 
                                      myCurrentEmpCert.Employee__r.Name); 
                }
            }
        }
        
        system.debug('HELPER Revsys_EmployeeCertValidation checkSupervisorQualificationDupe-End'); 
        return errMsg;
    }

}