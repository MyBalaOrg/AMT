/**
*___________________________________________________
*@Name: RevSys_RecTypeUtility
*@Author: Chuck Walley
*@Created: Date: 11/12/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Utility to convert the record type Id to the Record Type Name 
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
global with sharing class RevSys_RecTypeUtility {

	public static Map<Id,RecordType> RecTypeMap           = new Map<Id,RecordType>(); 
    public static Map<String,RecordType> RecTypeByNameMap = new Map<String,RecordType>(); 

    /**
    *————————————————————————————————————————————————————
    * @Name: convertIdToName
    * @Description
    *	Loads the map if needed 
    *	Looks at a Map of RecordTypes by Id and returns the name.
    *————————————————————————————————————————————————————
    * @param    theNewObsList	List of Observation records, generally from the trigger
    * @return   void			Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static String convertIdToName(Id myRecTypeId)
    {
        system.debug('HELPER RevSys_RecTypeUtility convertIdToName-Start');     
        
       	if(RecTypeMap.size() == 0) {
       		RecordTypeSelector RecTypeSel = new RecordTypeSelector(null,'Name'); 

            SelectorWrapper mySelWrap = RecTypeSel.selectAllActiveRecordTypes(); 

            if(mySelWrap.ErrorMessage == null && mySelWrap.SobjectList.size() > 0) { 

                for(RecordType myRc :(List<RecordType>)mySelWrap.SObjectList) {
                    
                    RecTypeMap.put(myRc.Id,myRc); 
                }
            }
       	}

       	RecordType myRecType = RecTypeMap.get(myRecTypeId); 

       	String myRecTypeName; 

       	if(myRecType != null)
       	{
       		myRecTypeName = myRecType.Name; 
       	}

       	system.debug('myRecTypeName ' + myRecTypeName); 

		system.debug('HELPER RevSys_RecTypeUtility convertIdToName-End');     
		return myRecTypeName;
    }

    /**
    *————————————————————————————————————————————————————
    * @Name: convertNameToId
    * @Description
    *   Loads the map if needed 
    *   Looks at a Map of RecordTypes by Id and returns the name.
    *————————————————————————————————————————————————————
    * @param    theNewObsList   List of Observation records, generally from the trigger
    * @return   void            Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static Id convertNameToId(String theObjectName, String theRecTypeName)
    {
        system.debug('HELPER RevSys_RecTypeUtility convertIdToName-Start');     
        
        if(RecTypeByNameMap.size() == 0) {
            RecordTypeSelector RecTypeSel = new RecordTypeSelector(null,'Name'); 

            SelectorWrapper mySelWrap = RecTypeSel.selectAllActiveRecordTypes(); 

            if(mySelWrap.ErrorMessage == null && mySelWrap.SobjectList.size() > 0) { 

                for(RecordType myRc :(List<RecordType>)mySelWrap.SObjectList) {
                    
                    String myMashKey = myRc.SobjectType + '|' + myRc.Name; 

                    RecTypeByNameMap.put(myMashKey,myRc); 
                }
            }
        }

        Id myRecTypeId; 

        String myMashKey = theObjectName + '|' + theRecTypeName; 

        RecordType myRecType = RecTypeByNameMap.get(myMashKey); 

        if(myRecType != null)
        {
            myRecTypeId = myRecType.Id; 
        }

        system.debug('HELPER RevSys_RecTypeUtility convertIdToName-End');     
        return myRecTypeId;
    }



}