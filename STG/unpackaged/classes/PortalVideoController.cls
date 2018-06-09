/**
*___________________________________________________
*@Name: PortalVideoController
*@Author: Gani
*@Created Date: 12/4/2017
*@Used_By: youtubeFeedCmp lightning component
*___________________________________________________
*@Description: This class is used as controller for the youtubeFeedCmp lightning component
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class PortalVideoController { 
     /**
    *————————————————————————————————————————————————————
    * @Name: getVideoId
    * @Description
    * Fetches the video id from the Sobject and field name specified in the design element
    *————————————————————————————————————————————————————
    * @param    objApiName           Sobject API name from the component design
	* @param    fieldApiName         Field name within the Sobject which will contain the video id 
    * @return   videoId         	 Video Id to be passed and displayed in the youtube component
    *————————————————————————————————————————————————————
    **/ 
    
    @AuraEnabled  
    public static String getVideoId(String objApiName, String fieldApiName){        
        String videoId = '';         
        DateTime currentDateTime = DateTime.Now();
        
        //Get the embed video id from the SObject and field received from the parameters
        try{
            String queryString = 'Select '+ String.escapeSingleQuotes(fieldApiName) + ' from ' + String.escapeSingleQuotes(objApiName) + ' where Is_Active__c = TRUE AND Start_Date__c <= :currentDateTime AND End_Date__c > :currentDateTime AND Default__c = FALSE AND ' + String.escapeSingleQuotes(fieldApiName) + ' != NULL ORDER BY CreatedDate DESC LIMIT 1';
            List<SObject> sObjectList = Database.query(queryString);       
            //Assign the active video id
            if(sObjectList.size() > 0){
                videoId = String.valueOf(sObjectList[0].get(fieldApiName)); 
            }
            else{
                //If video id not available for current time frame then look for default video id
                String defaultQueryString = 'Select '+ String.escapeSingleQuotes(fieldApiName) + ' from ' + String.escapeSingleQuotes(objApiName) + ' where Is_Active__c = TRUE AND Default__c = TRUE AND ' + String.escapeSingleQuotes(fieldApiName) + ' != NULL ORDER BY CreatedDate DESC LIMIT 1';
                List<SObject> defaultSObjectList = Database.query(defaultQueryString);   
                //Assign the active default video id
                if(defaultSObjectList.size() > 0){
                    videoId = String.valueOf(defaultSObjectList[0].get(fieldApiName)); 
                }                
            }            
        }
        //Catch any exceptions
        catch(exception e){
            system.debug('ERROR '+e.getMessage()); 
        }        
        //Return final video id to be displayed
        return videoId;
    }
}