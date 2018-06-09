/**
*___________________________________________________
*@Name:     Revsys_RecTypeUtility_Test
*@Author:   Chuck Walley
*@Created:  Date: March 15, 2018
*@Used_By:  SPARTN
*___________________________________________________
*@Description: Test for RevSus_RecTypeUtility_Test
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class Revsys_RecTypeUtility_Test { 
   

    // ********* 
     
    private static testmethod void test_convertIdToName() {
        
        RecordTypeSelector RecTypeSel = new RecordTypeSelector(null,'Name'); 

        SelectorWrapper mySelWrap = RecTypeSel.selectAllActiveRecordTypes(); 

        if(mySelWrap.ErrorMessage == null && mySelWrap.SobjectList.size() > 0) { 

            List<RecordType> myList = mySelWrap.SObjectList; 

            RecordType myCheckRecType = myList[0]; 

            String myName = Revsys_RecTypeUtility.convertIdToName(myCheckRecType.Id); 

            system.assertEquals(myCheckRecType.Name, myName); 

        }
    }

    // ********* 
     
    private static testmethod void test_convertNameToId() {
        
        RecordTypeSelector RecTypeSel = new RecordTypeSelector(null,'Name'); 

        SelectorWrapper mySelWrap = RecTypeSel.selectAllActiveRecordTypes(); 

        if(mySelWrap.ErrorMessage == null && mySelWrap.SobjectList.size() > 0) { 

            List<RecordType> myList = mySelWrap.SObjectList; 

            RecordType myCheckRecType = myList[0]; 

            Id myID = Revsys_RecTypeUtility.convertNameToId(myCheckRecType.SobjectType,myCheckRecType.Name); 

            system.assertEquals(myCheckRecType.Id, myId); 

        }
    }
}