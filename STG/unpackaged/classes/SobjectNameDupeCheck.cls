/**
*___________________________________________________
*@Name: SobjectNameDupeCheck
*@Author: Chuck Walley
*@Created: Date: 03/01/2018
*@Used_By: Review Systems
*___________________________________________________
*@Description: Checks for duplicate Name in objects
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/

global with sharing class SobjectNameDupeCheck {

    /**
    *————————————————————————————————————————————————————
    * @Name: determineRecord()
    * @Description
    * Determines if the name has changed and loads into a list for later processing
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static List<SObject> determineRecord(List<SObject> theSobjList, 
                                                Map<Id,SObject> theOldMap)
    {
        system.debug('HELPER SobjectNameDupeCheck determineRecord-Start');     
        
        string errMsg;

        List<SObject> myCheckSobjList = new List<SObject>(); 

        for(SObject theNewSobj :theSobjList) 
        {
            if(theOldMap == null) {

                myCheckSobjList.add(theNewSobj);

            }
            else {
                SObject theOldSobj = theOldMap.get(theNewSobj.Id); 

                String myNewName = (String)theNewSobj.get('Name'); 
                String myOldName = (String)theOldSobj.get('Name'); 

                if(myNewName != myOldName) {
                    myCheckSobjList.add(theNewSobj);
                }
            }
        }
        
        system.debug('HELPER SobjectNameDupeCheck determineRecord-End'); 
        return myCheckSobjList;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: checkForDupe()
    * @Description
    * Determines if the name has changed and loads into a list for later processing
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static String checkForDupe(List<SObject> theNewSobjList, 
                                      List<SObject> theOldSobjList) {

        system.debug('HELPER SobjectNameDupeCheck checkForDupe-Start');     

        string errMsg;

        Set<String> myCurrentNameSet = new Set<String>(); 

        for(SObject theOldSobj :theOldSobjList) {
           myCurrentNameSet.add((String)theOldSobj.get('Name')) ; 
        }

        for(SObject theNewSobj :theNewSobjList) { 

            String myNewName = (String)theNewSobj.get('Name'); 
            if(myCurrentNameSet.contains(myNewName)) {

                String msg = Label.Revsys_Record_Name_Dupe; 
                msg = msg.replace(Label.Revsys_Junct_Object_Dupe_Replace, myNewName); 

                errMsg += msg;
            }
        }

        errMsg = StringUtility.cleanupMessage(errMsg); 
        
        system.debug('HELPER SobjectNameDupeCheck determineRecord-End'); 
        return errMsg;
    }
}