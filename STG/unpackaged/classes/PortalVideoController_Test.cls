/**
*___________________________________________________
*@Name: PortalVideoController_Test
*@Author: Kumar Suyash
*@Created: Date: 11/1/2017
*@Used_By: Used to test PortalVideoController class
*___________________________________________________
*@Description: This class is used to test PortalVideoController class
*___________________________________________________
*@Changes: 
**/
@isTest
public class PortalVideoController_Test {
    //Test data setup
    @TestSetup
    public static void loadTestData() {
        Portal_Video__c pVObj = new Portal_Video__c(
            Title__c = 'CEO Portal Video Test',Description__c ='Home page video of the CEO portal',
            Video_Id__c ='35_5rh5c2ZM', Start_Date__c = DateTime.Now(),
            End_Date__c = DateTime.Now().addMonths(1), Is_Active__c= true,
            Default__c =false
        );
        insert pVObj;       
    }   

    public static testMethod void  testGetVideoId(){
        Test.startTest();
        String actualResult = PortalVideoController.getVideoId('Portal_Video__c','Video_Id__c') ;
        System.assertEquals('35_5rh5c2ZM', actualResult);
        Test.stopTest();
    }
    
    public static testMethod void  testGetVideoIdElseBlock(){
        Test.startTest();
        Portal_Video__c videoRec = [Select Default__c from Portal_Video__c Limit 1];
        videoRec.Default__c = true;
        update videoRec;
        String actualResult = PortalVideoController.getVideoId('Portal_Video__c','Video_Id__c') ;
        System.assertEquals('35_5rh5c2ZM', actualResult);
        Test.stopTest();
    }
    
    public static testMethod void  testGetVideoIdException(){
        Test.startTest();
        String actualResult = PortalVideoController.getVideoId('ABC__c','Video_Id__c') ;
        System.assertEquals('', actualResult);
        Test.stopTest();
    }    
}