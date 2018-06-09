/**
*___________________________________________________
*@Name: CarousalControllerTestFactory
*@Author: Tejas
*@Created: Date: 11/1/2017
*@Used_By: CarousalControllerTest class
*___________________________________________________
*@Description: This class is used as to provide factory methods for CarousalControllerTest class
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
public class CarousalControllerTestFactory {
    /**
    *------------------------------------------
    * @Name: getTestCarousal
    * @Description
    * creates and returns a test carousal object to be used inside CarousalControllerTest class
    *------------------------------------------
    * @param    testApplication		application name for Carousal object
    * @return   Carousel__c			Carousal for a particular application
    *------------------------------------------
    **/ 
    public static Carousel__c getTestCarousal(String testApplication) {
        Carousel__c carousal = new Carousel__c(
            Name = testApplication,
            Application__c = testApplication,
            End_Date__c = DateTime.now() + 2,	//past two days
            IsActive__c = true,					//test for active
            Start_Date__c = DateTime.now() - 2  // two days ahead
        );
        return carousal;
    }
    
    /**
    *------------------------------------------
    * @Name: getTestCarousalSlides
    * @Description
    * creates and returns slides associated with a carusal for testing in CarousalControllerTest class
    *------------------------------------------
    * @param    carousalId						Id of the Carousal object
    * 			noOfSlides						no of slide objects to be created
    * @return   List<SliderContent__c>			Slide objects associated with a Carousal object
    *------------------------------------------
    **/ 
    public static List<SliderContent__c> getTestCarousalSlides(Id carousalId, Integer noOfSlides) {
        List<SliderContent__c> slides = new List<SliderContent__c>();
        for(Integer i = 0; i < noOfSlides; i++) {
            slides.add(new SliderContent__c(
                Carousel__c = carousalId,
                Description__c = 'testDescription' + i,
                IsActive__c = true,
                Subtitle__c = 'testSubtitle' + i,
                Title__c = 'testTitle' + i,
                Title_For_Button__c = 'testTitleForButton' + i
            ));
        }
        return slides;
    }
    
    /**
    *------------------------------------------
    * @Name: getTestPortalContents
    * @Description
    * creates and returns test portal content objects to be used for testing in CarousalControllerTest class
    *------------------------------------------
    * @param    insertBool						specifies whether portal content object should be inserted 
    * 			noOfPortalContentRec			no of portal content to be created
    * @return   List<Portal_Content__c>			resulting portal content records
    *------------------------------------------
    **/
    public static Portal_Content__c getTestPortalContents(Boolean insertBool) {
        Portal_Content__c portCont = new Portal_Content__c();
        portCont.Title__c = 'Test Portal Content';   
        if(insertBool) insert portCont;
        return portCont;
    }
    
    /**
    *------------------------------------------
    * @Name: getContentDocument
    * @Description
    * 
    *------------------------------------------
    * @param    carouselId					
    * @return   Id						
    *------------------------------------------
    **/
    public static Id getContentDocument(Id carouselId) {
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Image',
            PathOnClient = 'TestImage.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion; 
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = carouselId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
        return contentVersion.Id;
    }
}