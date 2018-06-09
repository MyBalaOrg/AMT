/**
*___________________________________________________
*@Name: EPW_CarouselController_Test
*@Author: Tejas, Gaurav D
*@Created: Date: 11/1/2017
*@Used_By: Used to test CarousalController class
*___________________________________________________
*@Description: This class is used to test CarouselController class
*___________________________________________________
*@Changes: 
* 12/05/2017. Added test method for getting content id and document id
**/ 
@isTest
private class EPW_CarouselController_Test{
    /**
    *------------------------------------------
    * @Name: testGetPortalContentWithActiveCarousal
    * @Description
    * tests getPortalContent method of CarouselController class with IsActive__c flag of Carousal__c object true
    *------------------------------------------
    * @param    
    * @return   
    *------------------------------------------
    **/ 
    testmethod static void testGetPortalContentWithActiveCarousal() {
        //prepare test data
        String testApplication = 'Winter Carousel';
        Carousel__c carousal = CarousalControllerTestFactory.getTestCarousal(testApplication);
        insert carousal;
        List<SliderContent__c> slides = CarousalControllerTestFactory.getTestCarousalSlides(carousal.Id, 6);
        insert slides;
        
        //execute main logic
        Test.startTest();
        Carousel__c testCarousal = EPW_CarouselController.getPortalContent(testApplication);
        Test.stopTest();
        
        //assert the result
        System.assert(testCarousal != null);
        System.assertEquals(testApplication, testCarousal.Application__c);
        System.assertEquals(6, testCarousal.Slides__r.size());
    } 
    
    /**
    *------------------------------------------
    * @Name: testGetPortalContentWithInactiveCarousal
    * @Description
    * tests getPortalContent method of CarouselController class with IsActive__c flag of Carousal__c object false
    *------------------------------------------
    * @param    
    * @return   
    *------------------------------------------
    **/ 
    testmethod static void testGetPortalContentWithInactiveCarousal() {
        //prepare test data
        String testApplication = 'Winter Carousel';
        Carousel__c carousal = CarousalControllerTestFactory.getTestCarousal(testApplication);
        carousal.IsActive__c = false;
        insert carousal;
        List<SliderContent__c> slides = CarousalControllerTestFactory.getTestCarousalSlides(carousal.Id, 6);
        insert slides;
        
        //execute main logic
        Test.startTest();
        Carousel__c testCarousal = EPW_CarouselController.getPortalContent(testApplication);
        Test.stopTest();
        
        //assert the result
        System.assert(testCarousal == null);
    } 
    
    /**
    *------------------------------------------
    * @Name: testGetPortalContentWithInvalidAppName
    * @Description
    * tests getPortalContent method of CarouselController class with invalid appplication
    *------------------------------------------
    * @param    
    * @return   
    *------------------------------------------
    **/ 
    testmethod static void testGetPortalContentWithInvalidAppName() {
        //prepare test data
        String testApplication = 'Winter Carousel';
        Carousel__c carousal = CarousalControllerTestFactory.getTestCarousal(testApplication);
        insert carousal;
        List<SliderContent__c> slides = CarousalControllerTestFactory.getTestCarousalSlides(carousal.Id, 6);
        insert slides;
        
        //execute main logic
        Carousel__c testCarousal = EPW_CarouselController.getPortalContent('invalid application name');
        
        //assert the result
        System.assert(testCarousal == null);
    }

    /**
    *------------------------------------------
    * @Name: testGetPortalContentWithId
    * @Description
    * tests getPortalContentWithId method of CarouselController class
    *------------------------------------------
    * @param    
    * @return   
    *------------------------------------------
    **/ 
    testmethod static void testGetPortalContentWithId() {
        //prepare test data
        Portal_Content__c portalContent = CarousalControllerTestFactory.getTestPortalContents(true);
        
        //execute main logic
        Test.startTest();
        List<Portal_Content__c> returnedPortContent = EPW_CarouselController.getPortalContentWithId(portalContent.Id);
        Test.stopTest();
        //assert the result
        System.assert(returnedPortContent.size()>0 && returnedPortContent.get(0).Id == portalContent.Id, 'Portal Content fetched successfully');
    }

    /**
    *------------------------------------------
    * @Name: testGetContentWithLinkedId
    * @Description
    * tests getPortalContentWithId method of CarouselController class
    *------------------------------------------
    * @param    
    * @return   
    *------------------------------------------
    **/ 
    testmethod static void testGetContentWithLinkedId() {
        //prepare test data
        String testApplication = 'Winter Carousel';
        Carousel__c carousal = CarousalControllerTestFactory.getTestCarousal(testApplication);
        insert carousal;
        
        Id contentVerId = CarousalControllerTestFactory.getContentDocument(carousal.Id);
       
        //execute main logic
        Test.startTest();
        Id contVerId = EPW_CarouselController.getContents(carousal.Id);
        Test.stopTest();
        //assert the result
        System.assert(contVerId == contentVerId, 'Content Version fetched successfully');
    }
    
    /**
    *------------------------------------------
    * @Name: testGetContentWithNoDocLinkedId
    * @Description
    * tests testGetContentWithNoDocLinkedId method of CarouselController class
    *------------------------------------------
    * @param    
    * @return   
    *------------------------------------------
    **/ 
    testmethod static void testGetContentWithNoDocLinkedId() {
        //prepare test data
        String testApplication = 'Winter Carousel';
        Carousel__c carousal = CarousalControllerTestFactory.getTestCarousal(testApplication);
        insert carousal;
      
        //execute main logic
        Test.startTest();
        Id contVerId = EPW_CarouselController.getContents(carousal.Id);
        Test.stopTest();
        //assert the result
        System.assert(contVerId == null, 'No content version');
    }  
    
    /**
    *------------------------------------------
    * @Name: testPicklistValuesForCarousalDesigner
    * @Description
    * tests testPicklistValuesForCarousalDesigner class which is used to fetch picklist values from  
    *               Application__c field and set into the community builer desiner
    *------------------------------------------
    * @param    
    * @return   
    *------------------------------------------
    **/ 
    testmethod static void testPicklistValuesForCarousalDesigner() {
        //execute main logic
        Test.startTest();
        VisualEditor.DynamicPickList dynamicPicklist = new CarouselPicklistController();
        VisualEditor.DataRow defaultValue = dynamicPicklist.getDefaultValue();
        VisualEditor.DynamicPickListRows picklistValues = dynamicPicklist.getValues();
        Test.stopTest();
        
        //assert the result
        System.assertEquals('', defaultValue.getLabel());
        System.assertEquals('', defaultValue.getValue());
        System.assertEquals(Carousel__c.Application__c.getDescribe().getPicklistValues().size(), picklistValues.getDataRows().size());
    }
}