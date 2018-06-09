/**
*___________________________________________________
*@Name: StringUtility
*@Author: Chuck Walley
*@Created: Date: 11/4/2017
*@Used_By: Global
*___________________________________________________
*@Description:  General and helpful String Utilities 
*___________________________________________________
*@Changes: 
* 
**/
global with sharing class StringUtility { 
    
    /**
    *————————————————————————————————————————————————————
    * @Name: cleanupMessage
    * @Description
    * Removes "null" from error messages. helpful when stacking calls and 
    * appending the error messages. 
    *————————————————————————————————————————————————————
    * @param    theMessage      The Error Message
    * @return   String          Error message with "null" removed 
    *————————————————————————————————————————————————————
    **/
    public static String cleanupMessage(String theMessage) {
        String errMsg;     

        if(theMessage <> null) { 
            theMessage = theMessage.replace('null',''); 
        }          
        
        if(theMessage == ''  ) { 
            theMessage = null;                      
        }        
        return theMessage; 
    }
}