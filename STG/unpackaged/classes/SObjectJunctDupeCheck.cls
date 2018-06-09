/**
*___________________________________________________
*@Name: SObjectJunctDupeCheck
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

global with sharing class SObjectJunctDupeCheck {

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
    public static List<SObject> determineRecord(List<SObject>   theSobjList, 
                                                Map<Id,SObject> theOldMap, 
                                                String theFKeyA, 
                                                String theFKeyB,
                                                Id     theRecordTypeId)
    {
        system.debug('HELPER SobjectNameDupeCheck determineRecord-Start'); 

        string errMsg;

        List<SObject> myCheckSobjList = new List<SObject>(); 

        for(SObject theNewSobj :theSobjList) 
        {
            Id myNewRectypeId = (Id)theNewSobj.get('RecordTypeId'); 

            if(myNewRecTypeId == theRecordTypeId) {

                if(theOldMap == null) {

                    myCheckSobjList.add(theNewSobj);
                }
                else {
                    SObject theOldSobj = theOldMap.get(theNewSobj.Id); 

                    String myNewFKeyA = (String)theNewSobj.get(theFKeyA); 
                    String myNewFKeyB = (String)theNewSobj.get(theFKeyB); 
                    String myNewMash  = myNewFKeyA + myNewFKeyB; 

                    String myOldFKeyA = (String)theOldSobj.get(theFKeyA); 
                    String myOldFKeyB = (String)theOldSobj.get(theFKeyB); 
                    String myOldMash  = myOldFKeyA + myOldFKeyB; 

                    if(myNewMash != myOldMash) {
                        myCheckSobjList.add(theNewSobj);
                    }
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
                                      List<SObject> theOldSobjList,
                                      String theFKeyA, List<SObject> theFKeyAList, 
                                      String theFKeyB, List<SObject> theFKeyBList)   {

        system.debug('HELPER SobjectNameDupeCheck checkForDupe-Start');   

        string errMsg;

        Map<Id,String> myFkeyANameMap = mapNameById(theFKeyAList);
        Map<Id,String> myFkeyBNameMap = mapNameById(theFKeyBList);

        Set<String> myCurrentMashKeySet = new Set<String>(); 

        // Build a set of mashkeys from the Old List 
        for(SObject theOldSobj :theOldSobjList) {
            
            Id myFKeyA = (Id)theOldSobj.get(theFKeyA); 
            Id myFKeyB = (Id)theOldSobj.get(theFKeyB); 
            myCurrentMashKeySet.add(String.valueof(myFKeyA) + '-' + String.valueOf(myFKeyB)); 
        }

        for(SObject theNewSobj :theNewSobjList) { 

            Id myFKeyA = (Id)theNewSobj.get(theFKeyA); 
            Id myFKeyB = (Id)theNewSobj.get(theFKeyB); 
            String myNewMashKey = String.valueof(myFKeyA) + '-' + String.valueOf(myFKeyB); 

            if(myCurrentMashKeySet.contains(myNewMashKey)) {

                String myReplacement = '\'' + myFkeyANameMap.get(myFKeyA) + ' - ' 
                                            + myFkeyBNameMap.get(myFKeyB) + '\'';

                String Msg = Label.Revsys_Junct_Object_Dupe; 
                Msg = Msg.replace(Label.Revsys_Junct_Object_Dupe_Replace, myReplacement); 

                errMsg += Msg; 
            }
        }

        errMsg = StringUtility.cleanupMessage(errMsg); 
        
        system.debug('HELPER SobjectNameDupeCheck determineRecord-End'); 
        return errMsg;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: mapNameById
    * @Description
    * Determines if the name has changed and loads into a list for later processing
    *————————————————————————————————————————————————————
    * @param    theOsrList      List of Occupation Specific Requirement records, generally from the trigger
    * @return   String          Error message
    *————————————————————————————————————————————————————
    **/ 
    public static Map<Id,String> mapNameById(List<SObject> theSobjList)  {

        system.debug('HELPER SobjectNameDupeCheck checkForDupe-Start');     
          
        Map<Id,String> myNameByIdMap = new Map<Id,String>();

        for(SObject theSObj :theSObjList) {

            Id     myId   = (Id)theSobj.get('Id');  
            String myName = (String)theSObj.get('Name'); 
            myNameByIdMap.put(myId,myName); 
        }

        
        system.debug('HELPER SobjectNameDupeCheck determineRecord-End'); 
        return myNameByIdMap;
    }
}