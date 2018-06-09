/**
*___________________________________________________
*@Name: RevSys_OccupationSpecificReqValidations
*@Author: Chuck Walley
*@Created: Date: 01/01/2018
*@Used_By: Review Systems
*___________________________________________________
*@Description: Validates Occupation Certification Records 
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

global with sharing class RevSys_OccupationSpecificReqValidations {

    private class DeptCraftMapWrapper {
        Public String                       ErrorMessage; 
        Public Map<String,Set<String>>      TestNumSetByDeptCraftMap;

        public DeptCraftMapWrapper(String theErrorMessage, Map<String,Set<String>>  theTestNumSetByDeptCraftMap) {
            ErrorMessage                = theErrorMessage;
            TestNumSetByDeptCraftMap    = theTestNumSetByDeptCraftMap; 
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: checkDeptCraftObsDupe()
    * @Description
    * Culls Occupation Specific Requirement records by Record Type 
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkDeptCraftObsDupe(List<OccupationSpecificRequirement__c>   theOsrList, 
                                               Map<Id,SObject> theOldMap)
    {
        system.debug('HELPER RevSys_OccupationSpecificReqValidations validateRecords-Start');     
        
        string errMsg;

        List<OccupationSpecificRequirement__c> myDeptCraftObsList = new List<OccupationSpecificRequirement__c>(); 

        for(OccupationSpecificRequirement__c theOsr :theOsrList) 
        {
            if(theOsr.RecordTypeId == RevSys_StaticUtility.OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID &&  
               theOsr.Status__c    == Label.RevSys_Generic_Status_Active)   {

                if(theOldMap == null) { 
                    myDeptCraftObsList.add(theOsr);
                }
                else {
                    SObject theOldSob = theOldMap.get(theOsr.Id); 
                    String myOldTestNumber 
                        = (String)theOldSob.get(Schema.OccupationSpecificRequirement__c.Test_Number__c);
                       
                    if(theOsr.Test_Number__c != myOldTestNumber ) {
                        myDeptCraftObsList.add(theOsr);
                    }
                } 
            }  
        }
         
        if(myDeptCraftObsList.size() > 0 ) { 
            errMsg = validateDeptCraftForObs(myDeptCraftObsList); 
        }
        
        system.debug('HELPER RevSys_OccupationSpecificReqValidations validateRecords-End'); 
        return errMsg;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: validateDeptCraftForObs()
    * @Description
    * Validate Dept/Craft combination for duplicate Observation Numbers 
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Occupation Certification records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String validateDeptCraftForObs(List<OccupationSpecificRequirement__c> theOsrList)
    {
        system.debug('HELPER RevSys_OccupationCertificationValidation validateDeptCraftForObs-Start');     
        
        string errMsg;

        // Make a map of Set of Test Numbers by Dept/Craft

        DeptCraftMapWrapper myDeptCraftWrap = mapTestNumSetByDeptCraft(theOsrList);
       
        errMsg = myDeptCraftWrap.ErrorMessage; 
        Map<String,Set<String>> myTestNumSetByDeptCraftMap = myDeptCraftWrap.TestNumSetByDeptCraftMap; 

        Set<String> myTestNumSet = new Set<String>(); 

        if(errMsg == null && myTestNumSetByDeptCraftMap.size() > 0) {

            // Now we have a set of Test Numbers keyed by Department/Craft Mashup

            for(OccupationSpecificRequirement__c theOsr :theOsrList)
            {
                String myMashKey = theOsr.ObservationDepartment2__c + '|' + 
                                   theOsr.ObservationCraft2__c; 

                myTestNumSet = myTestNumSetByDeptCraftMap.get(myMashKey); 

                if(myTestNumSet != null) { 
                    // Duplicate Check 

                    if(myTestNumSet.contains(theOsr.Test_Number__c) ) { 
                        // We found a dupe 
                        errMsg = Label.RevSys_OSR_TestNumber_Exists; 
                    }
                }
            }
        }
       
        system.debug('HELPER RevSys_OccupationCertificationValidation validateDeptCraftForObs-End'); 
        return errMsg;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: mapTestNumSetByDeptCraft()
    * @Description
    * Create a map - a Set of TestNumbers by DeptCraft combination
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Occupation Certification records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static DeptCraftMapWrapper mapTestNumSetByDeptCraft(List<OccupationSpecificRequirement__c> theOsrList)
    {
        system.debug('HELPER RevSys_OccupationCertificationValidation validateDeptCraftForObsDupeCheck-Start');     
        
        string errMsg;

        Set<String> myDeptCraftMashupSet    = new Set<String>(); 
        Set<String> myDeptSet               = new Set<String>();
        Set<String> myCraftSet              = new Set<String>();
        Set<String> myTestNumSet            = new Set<String>(); 

        for(OccupationSpecificRequirement__c theOsr :theOsrList)
        {
            myDeptSet.add(theOsr.ObservationDepartment2__c); 
            myCraftSet.add(theOsr.ObservationCraft2__c);
        }

        OccupationSpecificReqSelector OsrSelector = new OccupationSpecificReqSelector(); 

        SelectorWrapper myOsrSelectorWrap = OsrSelector.getOsrObsRecords(myDeptSet, myCraftSet); 

        errMsg = myOsrSelectorWrap.ErrorMessage; 
        List<OccupationSpecificRequirement__c> myExistingOsrList = myOsrSelectorWrap.SObjectList; 
       
        Map<String,Set<String>> myTestNumSetByDeptCraftMap = new Map<String,Set<String>>(); 

        if(errMsg == null && myExistingOsrList != null) { 

            for(OccupationSpecificRequirement__c myExisting :myExistingOsrList)
            { 
                String myMashKey = myExisting.ObservationDepartment2__c + '|' + 
                                   myExisting.ObservationCraft2__c; 

                myTestNumSet = myTestNumSetByDeptCraftMap.get(myMashKey); 
                if(myTestNumSet == null) { 
                    myTestNumSet = new Set<String>(); 
                }

                myTestNumSet.add(myExisting.Test_Number__c); 

                myTestNumSetByDeptCraftMap.put(myMashKey, myTestNumSet); 
            }
        }
        DeptCraftMapWrapper myDcWrap = new DeptCraftMapWrapper(errMsg,myTestNumSetByDeptCraftMap);  
        system.debug('HELPER RevSys_OccupationCertificationValidation validateDeptCraftForObs-End'); 
        return myDcWrap;

    }
    /**
    *————————————————————————————————————————————————————
    * @Name: checkCertDupe
    * @Description
    * Checks SPARTN Certification records for duplicates 
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkCertDupe(List<OccupationSpecificRequirement__c>   theOsrList, 
                                       Map<Id,SObject> theOldMap)
    {
        system.debug('HELPER RevSys_OccupationSpecificReqValidations checkCertDupe-Start');     
        
        string errMsg;

        List<OccupationSpecificRequirement__c> myListToCheck = new List<OccupationSpecificRequirement__c>(); 

        myListToCheck = SObjectJunctDupeCheck.determineRecord(theOsrList, theOldMap, 
                                                             'Certification__c', 'Requirement__c',
                                                             RevSys_StaticUtility.OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID); 
                
        if(myListToCheck.size() > 0) {

            Set<Id> myFKeyASet = new Set<Id>();  
            Set<Id> myFKeyBSet = new Set<Id>();  

            Set<String> myMashKeySet; 

            for(OccupationSpecificRequirement__c theOsr :myListToCheck) {
                myFKeyASet.add(theOsr.Certification__c);   
                myFKeyBSet.add(theOsr.Requirement__c);
            }

            // query Certifications for fKeyA
            SelectorWrapper mySelWrapC = OccupationCertificationSelector.getCertifications(myFKeyASet); 

            errMsg = mySelWrapC.ErrorMessage; 
            List<OccupationCertification__c> myOcList = mySelWrapC.SObjectList; 

            // query Requirements for fKeyB
            SelectorWrapper mySelWrapR = OccupationRequirementSelector.getOccRequirements(myFKeyBSet); 

            errMsg = mySelWrapC.ErrorMessage; 
            List<OccupationRequirement__c> myOrList = mySelWrapR.SObjectList; 

            OccupationSpecificReqSelector OsrSel = new OccupationSpecificReqSelector(); 
            SelectorWrapper mySwrap = OsrSel.getOsrJunctCert(myFKeyASet, myFKeyBSet); 

            errMsg = mySwrap.ErrorMessage; 
            List<OccupationSpecificRequirement__c> myOsrList = mySwrap.SObjectList; 

            myFKeyASet = new Set<Id>();  
            myFKeyBSet = new Set<Id>();  

            if(errMsg == null && myOsrList.size() > 0) {
                errMsg = SObjectJunctDupeCheck.checkForDupe(theOsrList, myListToCheck, 
                                                            'Certification__c', myOcList,
                                                            'Requirement__c', myOrList);
            }
        }
        
        system.debug('HELPER RevSys_OccupationSpecificReqValidations checkJunctDupe-End'); 
        return errMsg;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: checkObsTargetDupe
    * @Description
    * Checks SPARTN Target records (those used for Observations) for duplicates 
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkObsTargetDupe(List<OccupationSpecificRequirement__c>   theOsrList, 
                                            Map<Id,SObject> theOldMap)
    {
        system.debug('HELPER RevSys_OccupationSpecificReqValidations checkCertDupe-Start');     
        
        string errMsg;

        List<OccupationSpecificRequirement__c> myListToCheck = new List<OccupationSpecificRequirement__c>(); 

        for(OccupationSpecificRequirement__c theOsr :theOsrList) {
            if(theOsr.RecordTypeId == RevSys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID && 
               theOsr.Target__c != null) {
                myListToCheck.add(theOsr);
               }
        }

        myListToCheck = SObjectJunctDupeCheck.determineRecord(myListToCheck, theOldMap, 
                                                              'Observation__c', 'Target__c',
                                                              RevSys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID); 
       
        if(myListToCheck.size() > 0) {

            Set<Id> myFKeyASet = new Set<Id>();  
            Set<Id> myFKeyBSet = new Set<Id>();  

            Set<String> myMashKeySet; 

            for(OccupationSpecificRequirement__c theOsr :myListToCheck) {
                myFKeyASet.add(theOsr.Observation__c);   
                myFKeyBSet.add(theOsr.Target__c);
            }

            // query Certifications for fKeyB
            SelectorWrapper mySelWrapC = OccupationCertificationSelector.getTargetsById(myFKeyBSet); 

            errMsg = mySelWrapC.ErrorMessage; 
            List<OccupationCertification__c> myOcList = mySelWrapC.SObjectList; 

            // query Requirements for fKeyA
            SelectorWrapper mySelWrapR = OccupationRequirementSelector.getOccRequirements(myFKeyASet); 

            errMsg = mySelWrapC.ErrorMessage; 
            List<OccupationRequirement__c> myOrList = mySelWrapR.SObjectList; 

            OccupationSpecificReqSelector OsrSel = new OccupationSpecificReqSelector(); 
            SelectorWrapper mySwrap = OsrSel.getOsrJunctTarget(myFKeyASet, myFKeyBSet); 

            errMsg = mySwrap.ErrorMessage; 
            List<OccupationSpecificRequirement__c> myOsrList = mySwrap.SObjectList; 

            if(errMsg == null && myOsrList.size() > 0) {
                errMsg = SObjectJunctDupeCheck.checkForDupe(theOsrList, myListToCheck, 
                                                            'Observation__c',myOrList, 
                                                            'Target__c', myOcList); 
            }
        }
        
        system.debug('HELPER RevSys_OccupationSpecificReqValidations checkJunctDupe-End'); 
        return errMsg;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: checkReqTargetDupe
    * @Description
    * Checks SPARTN Target records (those used for Requirements) for duplicates 
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkReqTargetDupe(List<OccupationSpecificRequirement__c>   theOsrList, 
                                            Map<Id,SObject> theOldMap)
    {
        system.debug('HELPER RevSys_OccupationSpecificReqValidations checkCertDupe-Start');     
        
        string errMsg;

        List<OccupationSpecificRequirement__c> myListToCheck = new List<OccupationSpecificRequirement__c>(); 

        for(OccupationSpecificRequirement__c theOsr :theOsrList) {
            if(theOsr.RecordTypeId == RevSys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID && 
               theOsr.TargetRequirement__c != null) {
                myListToCheck.add(theOsr);
               }
        }

        myListToCheck = SObjectJunctDupeCheck.determineRecord(myListToCheck, theOldMap, 
                                                              'Observation__c', 'TargetRequirement__c',
                                                              RevSys_StaticUtility.OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID); 
       
        if(myListToCheck.size() > 0) {

            Set<Id> myFKeyASet = new Set<Id>();  
            Set<Id> myFKeyBSet = new Set<Id>();  

            Set<String> myMashKeySet; 

            for(OccupationSpecificRequirement__c theOsr :myListToCheck) {
                myFKeyASet.add(theOsr.Observation__c);   
                myFKeyBSet.add(theOsr.TargetRequirement__c);
            }

            Set<Id> myAllIdSet = new Set<Id>(); 
            myAllIdSet.addAll(myFKeyASet); 
            myAllIdSet.addAll(myFKeyBSet); 

            // query Requirements
            SelectorWrapper mySelWrap = OccupationRequirementSelector.getOccRequirements(myAllIdSet); 

            errMsg = mySelWrap.ErrorMessage; 
            List<OccupationRequirement__c> myOrList = mySelWrap.SObjectList; 


            // The Occ Req List contains Observations and Requirements
            // Separate into respective lists 
            List<OccupationRequirement__c> myOrObsList = new List<OccupationRequirement__c>(); 
            List<OccupationRequirement__c> myOrReqList = new List<OccupationRequirement__c>(); 

            for(OccupationRequirement__c myOr :myOrList) {
                if(myFKeyASet.contains(myOr.Id) ) {
                    myOrObsList.add(myOr);
                }
                else {
                    myOrReqList.add(myOr);
                }
            }

            // Get records which may be duplicates 
            OccupationSpecificReqSelector OsrSel = new OccupationSpecificReqSelector(); 
            SelectorWrapper mySwrap = OsrSel.getOsrJunctTarget(myFKeyASet, myFKeyBSet); 

            errMsg = mySwrap.ErrorMessage; 
            List<OccupationSpecificRequirement__c> myOsrList = mySwrap.SObjectList; 

            if(errMsg == null && myOsrList.size() > 0) {
                errMsg = SObjectJunctDupeCheck.checkForDupe(theOsrList, myListToCheck, 
                                                            'Observation__c',myOrObsList, 
                                                            'TargetRequirement__c', myOrReqList); 
            }
        }
        
        system.debug('HELPER RevSys_OccupationSpecificReqValidations checkJunctDupe-End'); 
        return errMsg;
    }

}