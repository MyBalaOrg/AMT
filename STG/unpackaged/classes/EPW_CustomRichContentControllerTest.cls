/**
*___________________________________________________
*@Name: CustomRichContentControllerTest_Test
*@Author: Tejas Khamakar
*@Created: Date: 1/18/2017
*@Used_By: To test CustomRichContentController
*___________________________________________________
*@Description: To test CustomRichContentController
*___________________________________________________
**/
@isTest
private class EPW_CustomRichContentControllerTest {
    /**
    *————————————————————————————————————————————————————
    * @Name: testGetRichTextContentWitValidFilters
    * @Description
    * tests method getRichTextContent with valid filters
    *————————————————————————————————————————————————————
    * @param -  
    * @return - 
    *————————————————————————————————————————————————————
    **/ 
    testmethod static void testGetRichTextContentWithValidFilters() {
        //prepare data
        Portal_Content__c portalContent = new Portal_Content__c(
            Title__c = 'testTitle',
            Image__c = 'testImage',
            Content__c = 'testContent',
            Application__c = 'testApplication',
            RecordTypeId = Schema.SObjectType.Portal_Content__c.getRecordTypeInfosByName().get('Data Tile Feed Content').getRecordTypeId(),
            IsActive__c = true,
            Start_Date__c = DateTime.now() - 2,
            End_Date__c = DateTime.now() + 2  
        );  
        insert portalContent;
        
        //execute logic
        Portal_Content__c resultingPortalContent = (Portal_Content__c)EPW_CustomRichContentController.getRichTextContent('testApplication', 'Portal_Content__c', 'Content__c', 'Data Tile Feed Content', portalContent.Title__c);
        System.debug(resultingPortalContent);
        //assert result
        System.assertEquals(portalContent.Id, resultingPortalContent.Id);
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: testGetRichTextContentWitValidFilters
    * @Description
    * tests method getRichTextContent with invalid filters  
    *————————————————————————————————————————————————————
    * @param -  
    * @return - 
    *————————————————————————————————————————————————————
    **/ 
    testmethod static void testGetRichTextContentWithInvalidFilters() {
        //prepare data
        Portal_Content__c portalContent = new Portal_Content__c(
            Title__c = 'testTitle',
            Image__c = 'testImage',
            Content__c = 'testContent',
            Application__c = 'testApplication',
            RecordTypeId = Schema.SObjectType.Portal_Content__c.getRecordTypeInfosByName().get('Data Tile Feed Content').getRecordTypeId(),
            IsActive__c = true,
            Start_Date__c = DateTime.now() - 2,
            End_Date__c = DateTime.now() + 2
        );
        insert portalContent;
        
        //execute logic
        Portal_Content__c resultingPortalContent = (Portal_Content__c)EPW_CustomRichContentController.getRichTextContent('testApplicationInvalid', 'Portal_Content__c', 'Content__c', 'Data Tile Feed Content', portalContent.Title__c);
        
        //assert result
        System.assertEquals(null, resultingPortalContent);
    }
}