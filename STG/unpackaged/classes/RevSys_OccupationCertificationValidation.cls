/**
*___________________________________________________
*@Name: RevSys_OccupationCertificationValidation
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

global with sharing class RevSys_OccupationCertificationValidation {

    private class DeptCraftMapWrapper {
        Public String                       ErrorMessage; 
        Public Map<String,Set<String>>      CraftSetByDeptMap;

        public DeptCraftMapWrapper(String theErrorMessage, Map<String,Set<String>>  theCraftSetByDeptMap) {
            ErrorMessage        = theErrorMessage;
            CraftSetByDeptMap   = theCraftSetByDeptMap; 
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: validateRecords()
    * @Description
    * Culls Occupation Certification records by Record Type 
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Occupation Certification records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String validateRecords(List<OccupationCertification__c> theNewOccCertList, Map<Id, SObject> theOldMap)
    {
        system.debug('HELPER RevSys_OccupationCertificationValidation validateRecords-Start');     
        
        string errMsg;

        List<OccupationCertification__c> myDeptCraftObsList = new List<OccupationCertification__c>(); 

        for(OccupationCertification__c theNewOc :theNewOccCertList)
        {
            if(theNewOc.RecordTypeId == RevSys_StaticUtility.OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID &&  
               theNewOc.Status__c    == Label.RevSys_Generic_Status_Active)   {

                if(theOldMap == null) { 
                    myDeptCraftObsList.add(theNewOc);
                }
                else {
                    SObject theOldSob = theOldMap.get(theNewOc.Id); 
                    String myOldCraft
                        = (String)theOldSob.get(Schema.OccupationCertification__c.Craft__c);
                        String myOldStatus
                        = (String)theOldSob.get(Schema.OccupationCertification__c.Status__c);
                       
                    if( (theNewOc.Craft__c  != myOldCraft) ||   
                        (theNewOc.Status__c == Label.Revsys_Generic_Status_Active && 
                            theNewOc.Status__c != myOldStatus)) {
                            myDeptCraftObsList.add(theNewOc);
                    }
                } 
            }
        }

        if(myDeptCraftObsList.size() > 0 ) { 
            errMsg = validateDeptCraftForObs(myDeptCraftObsList); 
        }
        
        system.debug('HELPER RevSys_OccupationCertificationValidation validateRecords-End'); 
        return errMsg;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: validateDeptCraftForObs()
    * @Description
    * Culls Occupation Certification records by Record Type 
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Occupation Certification records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String validateDeptCraftForObs(List<OccupationCertification__c> theNewOccCertList)
    {
        system.debug('HELPER RevSys_OccupationCertificationValidation validateDeptCraftForObs-Start');     
        
        string errMsg;

        // I want to know the following: 
        // - Does this Combination already exist? 
        // - Does an "All" Craft record exist for this Specific Craft (checking for Specific)
        // - Does a Specific Craft record exist for this All record (Checking for All) 


        // Make a map of Set of Crafts by Dept Code 

        DeptCraftMapWrapper myDeptCraftWrap = mapCraftSetByDeptCode(theNewOccCertList);

        errMsg = myDeptCraftWrap.ErrorMessage; 
        Map<String,Set<String>> myCraftSetByDeptMap = myDeptCraftWrap.CraftSetByDeptMap; 

        Set<String> myCraftCodeSet = new Set<String>(); 

        if(errMsg == null && myCraftSetByDeptMap.size() > 0) {

            // Now we have a set of Craft Codes keyed by Department

            for(OccupationCertification__c theOc :theNewOccCertList)
            {
                myCraftCodeSet = myCraftSetByDeptMap.get(theOc.Department__c); 

                if(myCraftCodeSet != null) { 
                    // Duplicate Check 

                    if(myCraftCodeSet.contains(theOc.Craft__c) ) { 
                        // We found a dupe 
                        errMsg = Label.RevSys_Dept_Craft_Combo_Exists; 
                    } 
                    else if(theOc.Craft__c != Label.RevSys_Generic_All && 
                            myCraftCodeSet.contains(Label.RevSys_Generic_All)) {
                        // We have an All record and cannot add anything else 
                        errMsg = Label.RevSys_Dept_Craft_Combo_All_Exists; 
                    } 
                    else if(theOc.Craft__c == Label.RevSys_Generic_All)  {
                        // We have records and cannot add "All"
                        errMsg = Label.RevSys_Dept_Craft_Combo_Cannot_Use_All; 
                    } 
                }
            }
        }
        system.debug('HELPER RevSys_OccupationCertificationValidation validateDeptCraftForObs-End'); 
        return errMsg;
    }
    /**
    *————————————————————————————————————————————————————
    * @Name: mapCraftSetByDeptCode()
    * @Description
    * Culls Occupation Certification records by Record Type 
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Occupation Certification records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static DeptCraftMapWrapper mapCraftSetByDeptCode(List<OccupationCertification__c> theNewOccCertList)
    {
        system.debug('HELPER RevSys_OccupationCertificationValidation validateDeptCraftForObsDupeCheck-Start');     
        
        string errMsg;

        Set<String> myDeptSet  = new Set<String>(); 
        Set<String> myCraftSet = new Set<String>(); 

        for(OccupationCertification__c theNewOc :theNewOccCertList)
        {
            myDeptSet.add(theNewOc.Department__c); 
        }

        SelectorWrapper myOccCertSelectWrap = OccupationCertificationSelector.getDeptCraftRecs(myDeptSet); 

        errMsg = myOccCertSelectWrap.ErrorMessage; 
        List<OccupationCertification__c> myOcList = myOccCertSelectWrap.SObjectList; 

        Map<String,Set<String>> myCraftSetByDeptMap = new Map<String,Set<String>>(); 

        if(errMsg == null && myOcList != null) { 

            for(OccupationCertification__c myOc :myOcList)
            { 
                myCraftSet = myCraftSetByDeptMap.get(myOc.Department__c); 
                if(myCraftSet == null) { 
                    myCraftSet = new Set<String>(); 
                }

                myCraftSet.add(myOc.Craft__c); 

                myCraftSetByDeptMap.put(myOc.Department__c, myCraftSet); 
            }
        }

        DeptCraftMapWrapper myDcWrap = new DeptCraftMapWrapper(errMsg,myCraftSetByDeptMap);  
        system.debug('HELPER RevSys_OccupationCertificationValidation validateDeptCraftForObs-End'); 
        return myDcWrap;
    }

}