/**
*___________________________________________________
*@Name:     StringUtility_Test
*@Author:     Chuck Walley
*@Created:     Date: 11/12/2017
*@Used_By:     Review Systems
*___________________________________________________
*@Description: Test for StringUtility
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest(SeeAllData=false)

public class StringUtility_Test {   
    
    /**
    *————————————————————————————————————————————————————
    * @Name: testCleanUpMessage
    * @Description  One long method to build data needed for 
    *               Review System test classes 
    *————————————————————————————————————————————————————
    * @param    null Nothing
    * @return   void Nothing
    *————————————————————————————————————————————————————
    **/ 
    public static testMethod void testCleanUpMessage() 
    {
        system.debug('TEST StringUtility_Test testCleanUpMessage-Start');   

        String myMessage = 'This is a message'; 

        myMessage = StringUtility.cleanupMessage(myMessage); 

        system.assertEquals('This is a message',myMessage); 

        String NULLMSG; 

        myMessage  = NULLMSG;
        myMessage += NULLMSG;
        myMessage += NULLMSG;
        myMessage += NULLMSG;

        system.debug('myMessage ' + myMessage); 
        system.assertEquals('nullnullnullnull',myMessage); 

        myMessage = StringUtility.cleanupMessage(myMessage); 

        system.assertEquals(null,myMessage); 

        myMessage  = NULLMSG;
        myMessage += NULLMSG;
        myMessage += 'This is a message'; 
        myMessage += NULLMSG;
        myMessage += NULLMSG;

        myMessage = StringUtility.cleanupMessage(myMessage); 

        system.assertEquals('This is a message',myMessage); 
        
        system.debug('TEST StringUtility_Test testCleanUpMessage-Start');   
    }
}