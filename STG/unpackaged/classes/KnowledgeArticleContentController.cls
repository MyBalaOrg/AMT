/**
*___________________________________________________
*@Name: KnowledgeArticleContentController
*@Author: Tejas Khamakar
*@Created: Date: 1/12/2018
*@Used_By: COE_knowledgeArticleContent ligtning component
*___________________________________________________
*@Description: used by COE_knowledgeArticleContent ligtning component
*___________________________________________________
**/
public class KnowledgeArticleContentController {
    /**
    *————————————————————————————————————————————————————
    * @Name: getKnowledgeArticle
    * @Description
    * this function returns KnowledgeArticle record
    *————————————————————————————————————————————————————
    * @param -  knowledgeArticleId			Id of knowledge article
    * @return - Knowledge__kav				Knowledge article record
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static Knowledge__kav getKnowledgeArticle(Id knowledgeArticleId) {
        Knowledge__kav knowledgeArticle = null;
        if(knowledgeArticleId != null) {
            List<Knowledge__kav> knowledgeArticles = [
                SELECT Title, Summary, Body__c, LastPublishedDate, ArticleTotalViewCount, RecordTypeId,DepartmentArticleNumber__c
                FROM Knowledge__kav 
                WHERE Id = :knowledgeArticleId 
                LIMIT 1
            ];
            if(knowledgeArticles != null && knowledgeArticles.size() > 0) {
                knowledgeArticle = knowledgeArticles[0];
            }
        }
        return knowledgeArticle;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: getKnowledgeArticleRecordTypeName
    * @Description
    * this function returns the record type name of Knowledge article
    *————————————————————————————————————————————————————
    * @param -  knowledgeArticleRecordTypeId			Id of knowledge article record type
    * @return - String									Name of knowledge article record type
    *————————————————————————————————————————————————————
    **/ 
    @AuraEnabled
    public static String getKnowledgeArticleRecordTypeName(Id knowledgeArticleRecordTypeId) {
        String knowledgeArticleRecordTypeName = null;
        if(knowledgeArticleRecordTypeId != null) {
            knowledgeArticleRecordTypeName = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosById().get(knowledgeArticleRecordTypeId).getName();
        }
        return knowledgeArticleRecordTypeName;
    }
}