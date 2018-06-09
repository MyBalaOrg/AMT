/**
*___________________________________________________
*@Name:      RevSys_ObservationFieldHistoryHelper    
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
public class RevSys_ObservationFieldHistoryHelper {
    
    /**
    *————————————————————————————————————————————————————
    * @Name: checkForAfterSubmitted
    * @Description
    * Mainline process for our custom Field History utility. 
    * @param    
    * @returns  
    *————————————————————————————————————————————————————
    **/
    public static void checkForAfterSubmitted(List<Observation__c> newObsList, 
                                                Map<Id,sObject> newMap, 
                                                Map<Id,sObject> oldMap)        {

        Map<Id, sObject> newMapForTracking = new Map<Id, sObject>(); 
        Map<Id, sObject> oldMapForTracking = new Map<Id, sObject>(); 

        for(Observation__c newObs :newObsList) 
        {
            SObject theOldSob = oldMap.get(newObs.Id); 
            String myOldStatus 
                    = (String)theOldSob.get(Schema.Observation__c.Status__c);

            if(newObs.Status__c == 'Submitted' && 
               myOldStatus      == 'Submitted') {
                newMapForTracking.put(newObs.Id, newObs); 
                oldMapForTracking.put(theOldSob.Id, theOldSob); 
            }
        }

        if (!newMapForTracking.isEmpty() && !oldMapForTracking.isEmpty()) {
            FieldHistoryUtility.setFieldHistoryTracking(oldMapForTracking, newMapForTracking, 
                                                        'Observation__c', 
                                                        'Observation__c');

        }
    }
}