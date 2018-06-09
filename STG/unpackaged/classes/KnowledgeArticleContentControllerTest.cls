/**
*___________________________________________________
*@Name: KnowledgeArticleContentControllerTest
*@Author: Tejas Khamakar
*@Created: Date: 12/4/2018
*@Used_By: KnowledgeArticleContentController class
*___________________________________________________
*@Description: used to test KnowledgeArticleContentController class
*___________________________________________________
**/
@isTest
private class KnowledgeArticleContentControllerTest {
	/**
    *————————————————————————————————————————————————————
    * @Name: testGetKnowledgeArticleMethodWithValidId
    * @Description
    * to test getKnowledgeArticle method of KnowledgeArticleContentController class with valid knowledge id
    *————————————————————————————————————————————————————
    * @param -  
    * @return - 
    *————————————————————————————————————————————————————
    **/ 
    testmethod static void testGetKnowledgeArticleMethodWithValidId() {
        //prepare test data
        Profile p = [select Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User adminUser = new User(alias = 'testadmn', 
                                 email='testadmin@test.com', 
                                 emailencodingkey='UTF-8', 
                                 lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', 
                                 profileid = p.Id, 
                                 timezonesidkey='America/Los_Angeles', 
                                 username='testadminunique@testcoe.com');
        insert adminUser;

        Knowledge__kav knowledge = new Knowledge__kav(
            Title = 'testTitle',
            Summary = 'testSummary',
            Body__c = 'testBody',
            UrlName = 'testUrl',
            Department__c = 'Engineering'
        );
        insert knowledge;
        
        //execute main logic
        Knowledge__kav result = null;
        system.runas(adminUser) {
            result = KnowledgeArticleContentController.getKnowledgeArticle(knowledge.Id);
        }
        
        //assert results
        System.assertEquals(knowledge.Id, result.Id);
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: testGetKnowledgeArticleMethodWithInvalidId
    * @Description
    * to test getKnowledgeArticle method of KnowledgeArticleContentController class with invalid knowledge id
    *————————————————————————————————————————————————————
    * @param -  
    * @return - 
    *————————————————————————————————————————————————————
    **/ 
    testmethod static void testGetKnowledgeArticleMethodWithInvalidId() {
        //prepare test data
        Profile p = [select Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User adminUser = new User(alias = 'testadmn', 
                                 email='testadmin@test.com', 
                                 emailencodingkey='UTF-8', 
                                 lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', 
                                 profileid = p.Id, 
                                 timezonesidkey='America/Los_Angeles', 
                                 username='testadminunique@testcoe.com');
        insert adminUser;
        
        Knowledge__kav knowledge = new Knowledge__kav(
            Title = 'testTitle',
            Summary = 'testSummary',
            Body__c = 'testBody',
            UrlName = 'testUrl',
            Department__c = 'Engineering'
        );
        insert knowledge;
        
        //execute main logic
        Knowledge__kav result = null;
        system.runas(adminUser) {
            result = KnowledgeArticleContentController.getKnowledgeArticle(null);
        }
        
        //assert results
        System.assertEquals(null, result);
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: testGetKnowledgeArticleRecordTypeNameMethodWithValidId
    * @Description
    * to test getKnowledgeArticleRecordTypeName method of KnowledgeArticleContentController class with valid record type id
    *————————————————————————————————————————————————————
    * @param -  
    * @return - 
    *————————————————————————————————————————————————————
    **/ 
    testmethod static void testGetKnowledgeArticleRecordTypeNameMethodWithValidId() {
        //prepare test data
        Profile p = [select Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User adminUser = new User(alias = 'testadmn', 
                                 email='testadmin@test.com', 
                                 emailencodingkey='UTF-8', 
                                 lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', 
                                 profileid = p.Id, 
                                 timezonesidkey='America/Los_Angeles', 
                                 username='testadminunique@testcoe.com');
        insert adminUser;
        
        String recordTypeName = 'General';
        Id recordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        
        //execute main logic
        String resultingRecordTypeName = null;
        system.runas(adminUser) {
            resultingRecordTypeName = KnowledgeArticleContentController.getKnowledgeArticleRecordTypeName(recordTypeId);
        }
        
        //assert results
        System.assertEquals(recordTypeName, resultingRecordTypeName);
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Name: testGetKnowledgeArticleRecordTypeNameMethodWithInvalidId
    * @Description
    * to test getKnowledgeArticleRecordTypeName method of KnowledgeArticleContentController class with invalid record type id
    *————————————————————————————————————————————————————
    * @param -  
    * @return - 
    *————————————————————————————————————————————————————
    **/ 
    testmethod static void testGetKnowledgeArticleRecordTypeNameMethodWithInvalidId() {
        //prepare test data
        Profile p = [select Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User adminUser = new User(alias = 'testadmn', 
                                 email='testadmin@test.com', 
                                 emailencodingkey='UTF-8', 
                                 lastname='Testing', languagelocalekey='en_US', 
                                 localesidkey='en_US', 
                                 profileid = p.Id, 
                                 timezonesidkey='America/Los_Angeles', 
                                 username='testadminunique@testcoe.com');
        insert adminUser;
        
        //execute main logic
        String resultingRecordTypeName = null;
        system.runas(adminUser) {
            resultingRecordTypeName = KnowledgeArticleContentController.getKnowledgeArticleRecordTypeName(null);
        }
        
        //assert results
        System.assertEquals(null, resultingRecordTypeName);
    }
}