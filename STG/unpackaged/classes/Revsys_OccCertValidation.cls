/**
*___________________________________________________
*@Name: Revsys_OccCertValidation
*@Author: Chuck Walley
*@Created: Date: 03/01/2018
*@Used_By: Review Systems
*___________________________________________________
*@Description: Validates Occupation Certification Records
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

global with sharing class Revsys_OccCertValidation {

    /**
    *————————————————————————————————————————————————————
    * @Name: checkDupeName()
    * @Description
    * checks for duplication by name 
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Certification records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkDupeName(List<SObject> theSobjList, 
                                       Map<Id,SObject> theOldMap)
    {
        system.debug('HELPER Revsys_OccupationRequirementValidation checkForDupes-Start');     
        
        Set<String> myCheckNameSet = new Set<String>(); 

        String errMsg;

        // Get the new records of those with a name change 
        List<SObject> mySObjCheckList 
            = SobjectNameDupeCheck.determineRecord(theSobjList,theOldMap);

        if(mySObjCheckList.size() > 0) { 
            for(SObject mySObj :mySObjCheckList) { 
                String myName = (String)mySObj.get('Name'); 
                myCheckNameSet.add(myName); 
            }
            // Call the selector to get any current records wtih the same name  
            SelectorWrapper myWrap 
                = OccupationCertificationSelector.getOccCertByName(myCheckNameSet); 

            errMsg = myWrap.ErrorMessage; 
            List<SObject> mySObjList = myWrap.SObjectList; 

            if(errMsg == null && mySObjList.size() > 0) {

                // Check the list of newly created or changed records against the list
                // of old records we just queried 
                errMsg = SobjectNameDupeCheck.checkForDupe(theSobjList,mySObjCheckList);
            }
        }
        
        system.debug('HELPER RevSys_OccupationSpecificReqValidations validateRecords-End'); 
        return errMsg;
    }
}