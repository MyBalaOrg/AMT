/**
*___________________________________________________
*@Name: COERelatedCommuitiesController
*@Author: Tejas Khamakar
*@Created: Date: 1/12/2018
*@Used_By: COE_relatedCommunitiesCmp ligtning component
*___________________________________________________
*@Description: used by COE_relatedCommunitiesCmp ligtning component
*___________________________________________________
**/
public without sharing class COERelatedCommuitiesController {
    /**
    *————————————————————————————————————————————————————
    * @Name: getDiscussionForumFeeds
    * @Description
    * retrieves discussions from FeedItem object
    *————————————————————————————————————————————————————
    * @param -  
    * @return - List<FeedItem>						discussions
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static List<FeedItem> getDiscussionForumFeeds() {
        return [
            SELECT Id, Title
            FROM FeedItem 
            WHERE Type = 'QuestionPost' 
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];
    }
}