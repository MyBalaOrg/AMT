/**
*___________________________________________________
*@Name:      Revsys_FindingFieldHistoryHelper    
*@Author:    Chuck Walley   
*@Created:   February 1, 2018
*@Used_By:   SPARTN
*___________________________________________________
*@Description: 
* Determines when the Field History utility should 
* be called
*___________________________________________________
*@Changes: 
* 04-20-2018. Move the invocation of FieldHistoryUtility outside for loop.
**/
public class Revsys_FindingFieldHistoryHelper {
    /**
    *————————————————————————————————————————————————————
    * @Name: checkForAfterSubmitted
    * @Description
    * Mainline process for our custom Field History utility. 
    * @param    
    * @returns  
    *————————————————————————————————————————————————————
    **/
    public static void checkForAfterSubmitted(List<Finding__c> newFindList, 
                                                Map<Id,sObject> newMap, 
                                                Map<Id,sObject> oldMap)        {

        Map<Id, sObject> newMapForTracking = new Map<Id, sObject>(); 
        Map<Id, sObject> oldMapForTracking = new Map<Id, sObject>(); 

        for(Finding__c newFind :newFindList) 
        {
            SObject theOldFind = oldMap.get(newFind.Id); 
            Decimal myOldScore 
                    = (Decimal)theOldFind.get(Schema.Finding__c.Score__c); 

            if(myOldScore != null &&  
               myOldScore != newFind.Score__c)
            {
                newMapForTracking.put(newFind.Id, newFind); 
                oldMapForTracking.put(theOldFind.Id, theOldFind); 
            }
        }
        if (!newMapForTracking.isEmpty() && !oldMapForTracking.isEmpty()) {
            FieldHistoryUtility.setFieldHistoryTracking(oldMapForTracking, newMapForTracking, 'Finding__c', 'Finding__c');
            RevSys_FieldHistoryHelper.updateScoresOnObservation(oldMapForTracking, newMapForTracking, 'Finding__c', 'Finding__c');
        }
    }
}