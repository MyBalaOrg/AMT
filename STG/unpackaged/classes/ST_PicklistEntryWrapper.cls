/**
*___________________________________________________
*@Name: ST_PicklistEntryWrapper
*@Author: Jialin Ding
*@Created: Date: 5/16/2017
*@Used_By: SafeTrends App
*___________________________________________________
*@Description: This is the wrapper class which is use to deserialize the JSON format of dependent picklist.
*
*___________________________________________________
*@Changes:
* MM-DD-YYY. Explanation of the change.
**/

public class ST_PicklistEntryWrapper{
    
    public ST_PicklistEntryWrapper(){            
        }
   
   public String active {get;set;}
   public String defaultValue {get;set;}
   public String label {get;set;}
   public String value {get;set;}
   public String validFor {get;set;}
}