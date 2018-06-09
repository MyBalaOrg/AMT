/**
*___________________________________________________
*@Name: Revsys_OccupationRequirementValidation
*@Author: Chuck Walley
*@Created: Date: 03/01/2018
*@Used_By: Review Systems
*___________________________________________________
*@Description: Validates Occupation Requirement Records
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

global with sharing class Revsys_OccupationRequirementValidation {

    /**
    *————————————————————————————————————————————————————
    * @Name: checkForDupes()
    * @Description
    * checks for duplication by name 
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkDupeName(List<OccupationRequirement__c> theOcList, 
                                       Map<Id,SObject> theOldMap)
    {
        system.debug('HELPER Revsys_OccupationRequirementValidation checkDupeName-Start');     
        
        Set<String> myCheckNameSet = new Set<String>(); 
        Set<String> myCheckTestNameSet = new Set<String>(); 
        Set<String> myCheckTestNumSet  = new Set<String>(); 

        String errMsg;

        // Get the new records of those with a name change 
        List<SObject> mySObjCheckList 
            = SobjectNameDupeCheck.determineRecord(theOcList,theOldMap);

        if(mySObjCheckList.size() > 0) { 
            for(SObject mySObj :mySObjCheckList) { 

                system.debug('mySObj  ' + mySObj);

                String myName = (String)mySObj.get('Name'); 
                String myTestName = (String)mySObj.get('TestName__c'); 
                String myTestNum  = (String)mySObj.get('TestNumber__c'); 
                myCheckNameSet.add(myName); 
                myCheckTestNumSet.add(myTestNum); 
                myCheckTestNameSet.add(myTestName); 
            }
            // Call the selector to get any current records wtih the same name  
            SelectorWrapper myWrap 
                = OccupationRequirementSelector.getOccReqByName(myCheckNameSet); 

            errMsg = myWrap.ErrorMessage; 
            List<SObject> mySObjList = myWrap.SObjectList; 

            if(errMsg == null && mySObjList.size() > 0) {

                // Check the list of newly created or changed records against the list
                // of old records we just queried 
                errMsg = SobjectNameDupeCheck.checkForDupe(mySObjCheckList,mySObjList);
            }

            if(errMsg == null ) {
                errMsg = checkTestNumAndName(mySObjCheckList, myCheckTestNumSet, myCheckTestNameSet); 
            }
        }
        
        system.debug('HELPER RevSys_OccupationSpecificReqValidations checkDupeName-End'); 
        return errMsg;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: checkTestNumAndName()
    * @Description
    * checks for duplication by name 
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkTestNumAndName(List<OccupationRequirement__c> theOcList, 
                                             Set<String>   theCheckTestNumSet,
                                             Set<String>   theCheckTestNameSet)
    {
        system.debug('HELPER Revsys_OccupationRequirementValidation checkTestNumber-Start');     
        String errMsg; 

        List<OccupationRequirement__c> myCheckList = new List<OccupationRequirement__c>(); 

        for(OccupationRequirement__c theOc :theOcList) {
            if(theOc.RecordTypeId == RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID 
               && theOc.SourceRecordType__c == Label.RevSys_Observation_RT_Label_Test_1872)  {
                myCheckList.add(theOc); 
            }
        }

        if(myChecklist.size() > 0) {

            SelectorWrapper mySelWrap = OccupationRequirementSelector.getObsByTestNum(theCheckTestNumSet); 

            errMsg = mySelWrap.ErrorMessage;
            List<OccupationRequirement__c> myCheckNumList = mySelWrap.SObjectList; 

            mySelWrap = OccupationRequirementSelector.getObsByTestName(theCheckTestNameSet); 

            errMsg += mySelWrap.ErrorMessage;
            List<OccupationRequirement__c> myCheckNameList = mySelWrap.SObjectList; 

            errMsg = StringUtility.cleanupMessage(errMsg); 

            Set<String> myTestNumberSet = new Set<String>(); 
            Set<String> myTestNameSet   = new Set<String>(); 

            if(errMsg == null && 
               (myCheckNumList.size() > 0 || myCheckNameList.size() > 0) ) {

                for(OccupationRequirement__c myCheckNum :myCheckNumList) {
                    system.debug('myCheckNum  ' + myCheckNum);
                    myTestNumberSet.add(myCheckNum.TestNumber__c); 
                }

                for(OccupationRequirement__c myCheckName :myCheckNameList) {
                    myTestNameSet.add(myCheckName.TestName__c); 
                }

                system.debug('theOcList  ' + theOcList);
                system.debug('myTestNumberSet  ' + myTestNumberSet);
                system.debug('myTestNameSet  ' + myTestNameSet);


                for(OccupationRequirement__c theOc :theOcList) {

                    if(myTestNumberSet.contains(theOc.TestNumber__c)) {
                        String msg = Label.Revsys_Observation_Number_Dupe; 
                        msg = msg.replace(Label.Revsys_Junct_Object_Dupe_Replace, theOc.TestNumber__c); 

                        errMsg += msg; 
                    }
                    else if(myTestNameSet.contains(theOc.TestName__c)) {
                        String msg = Label.Revsys_Observation_Name_Dupe; 
                        msg = msg.replace(Label.Revsys_Junct_Object_Dupe_Replace, theOc.TestName__c); 

                        errMsg += msg; 
                    }
                }
            }
        }
        system.debug('HELPER RevSys_OccupationSpecificReqValidations checkTestNumber-End'); 
        return errMsg;
    }
}