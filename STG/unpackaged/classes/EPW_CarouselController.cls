/**
*___________________________________________________
*@Name: EPW_CarouselController
*@Author: Tejas
*@Created: Date: 11/1/2017
*@Used_By: Amtrak_Carousal_Slider lightning component
*___________________________________________________
*@Description: This class is used as controller for the Amtrak_Carousal_Slider lightning component
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public with sharing class EPW_CarouselController {
    /**
    *————————————————————————————————————————————————————
    * @Name: getPortalContent
    * @Description
    * Fetches Carousal object and its associated slides for a particular application
    *————————————————————————————————————————————————————
    * @param    application           application name from carousal object
    * @return   Carousel__c           Carousal object to be used for a specified application name
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static Carousel__c getPortalContent(String application) {
        Carousel__c carousel = null;
        
        if(!String.isBlank(application)) {
            List<Carousel__c> carousels = [
                SELECT Name, Application__c, Slider_Transition_Time__c, IsActive__c, Start_Date__c, End_Date__c,
                (SELECT Description__c, Image__c, IsActive__c, Subtitle__c, Title__c, Title_For_Button__c, 
                 Related_Content__c, Related_Content__r.Description__c, 
                 Related_Content__r.IsActive__c, Related_Content__r.Title__c, 
                 Related_Content__r.Content__c FROM Slides__r WHERE IsActive__c = true ORDER BY CreatedDate DESC) 
                FROM Carousel__c 
                WHERE IsActive__c = true AND Start_Date__c <= :DateTime.now() AND End_Date__c >= :DateTime.now() AND Application__c = :application
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if(carousels != null && carousels.size() > 0) {
                carousel = carousels[0];
            }
        }
        return carousel;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getPortalContentWithId
    * @Description
    * Fetches portal content object from the provided content Id
    *————————————————————————————————————————————————————
    * @param    contentId                   portal content Id                      
    * @return   List<portal_content__c>     Portal Content object            
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static List<portal_content__c> getPortalContentWithId(Id contentId) {
        return [SELECT Title__c, Content__c, Content_Type__c, Published_Date__c
                FROM Portal_Content__c 
                WHERE id =: contentId];
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getContents
    * @Description
    * Fetches background image from carousal object attachent object to be used in Amtrak_Carousal_Slider component
    *————————————————————————————————————————————————————
    * @param    parentId        Id of carousal object   
    * @return   Id              Id of ContentVersion object. This Id is appended at the end of 
    *                                               '/sfc/servlet.shepherd/version/download/' url. This url is used to set background image
    *                                               
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static Id getContents(Id parentId) {
        Id contentVersionId = null;
        if(parentId != null) {
            List<ContentDocumentLink> contentDoc = [Select ContentDocumentId from ContentDocumentLink where LinkedEntityId =: parentId LIMIT 1];
            if(contentDoc.size() > 0) {
                List<ContentVersion> contentVer = [SELECT Id FROM ContentVersion WHERE ContentDocumentId =: contentDoc.get(0).ContentDocumentId];
                contentVersionId = contentVer.size() > 0 ? contentVer.get(0).Id : null;
            }   
        }
        return contentVersionId;
    }
}