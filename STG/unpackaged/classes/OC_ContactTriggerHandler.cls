/*
* Contact Trigger Handler class for Org Chart Application
*/

public class OC_ContactTriggerHandler {
    
    
    /*
    * Method which calls a future method to update usert
    */    
    public static void deactivateUsers(List<contact> contacts) {
        
        system.debug('In deactivateUsers');
        
        try {
            Set<String> personnelNumbersToBeUpdateText = new Set<String>();
            
            List<String> terminatedStatuses= new List<String>();
            terminatedStatuses= Label.OC_Terminated_Status.split('\\,');
            
            //Retrieve all the personnel numbers of inactive employees
            for(Contact c : contacts) {
                for(String terminatedSts : terminatedStatuses){
                if(c.Employment_Status__c == terminatedSts)
                    personnelNumbersToBeUpdateText.add(String.valueOf((Integer)c.personnel_number__c));
                }
            }
            
            //Call Future Method to bypass Mixed DML Operation error
            if(personnelNumbersToBeUpdateText.size() > 0) OC_ContactTriggerAsynch.updateUsersAsynch(personnelNumbersToBeUpdateText);
        } catch(Exception e) {
            system.debug('Exception '+e.getMessage());
        }
     
    }
}