@isTest
private class DataFeedTileControllerTest {
	
	@isTest static void retrieveListsTest() {

		Account account = TestHandler.createAccount('testAccount');
        insert account;
            
        Contact contact = TestHandler.createTestContact('TestLastName', account.id, null, null);
        insert contact;

        Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.CEO_Case_Record_Type).getRecordTypeId();

		Case c = new Case(AccountId = account.Id,
                    ContactId = contact.Id,
                    RecordTypeId = rtId, Subject='Subject', Description='Description', Documentum_Link__c='https://www.google.com');
		insert c;
		CaseComment cc = new CaseComment(CommentBody = 'Case Test Comment Body', ParentId = c.Id, IsPublished = true );
		insert cc;

		Portal_Content__c content = new Portal_Content__c(Title__c = 'Testing', Description__c = 'Description', Article_URL__c='https://www.google.com');
		insert content;

		// Two objects
		List<String> properties = new List<String>();
		properties.add('Case');
		properties.add('Ask CEO Feedback');
		properties.add('Description');
		//Blank for Second field on first object
		properties.add('');
		properties.add('CaseComments');
		properties.add('ParentId');
		properties.add('CommentBody');
		properties.add('5');
		// Blank for Article URL
		properties.add('');
		properties.add('CreatedDate');
		properties.add('DESC');
		properties.add('');
		properties.add('');
		properties.add('');
		Map<String,List<String>> testResult = DataFeedTileController.retrieveLists(properties, true);

		//Single Object
		List<String> properties2 = new List<String>();
		properties2.add('Case');
		properties2.add('Ask CEO Feedback');
		properties2.add('Description');
		properties2.add('AccountId');
		// Blanks for secondary object
		properties2.add('');
		properties2.add('');
		properties2.add('');
		properties2.add('5');
		properties2.add('Documentum_Link__c');
		properties2.add('CreatedDate');
		properties2.add('DESC');
		properties2.add('');
		properties2.add('');
		properties2.add('');
		Map<String,List<String>> testResult2 = DataFeedTileController.retrieveLists(properties2, false);

		// Private Case Comments
		List<String> properties3 = new List<String>();
		properties3.add('Case');
		properties3.add('Ask CEO Feedback');
		properties3.add('Description');
		properties3.add('Status');
		properties3.add('');
		properties3.add('');
		properties3.add('');
		properties3.add('5');
		properties3.add('Documentum_Link__c');
		properties3.add('CreatedDate');
		properties3.add('DESC');
		properties3.add('');
		properties3.add('');
		properties3.add('');
		Map<String,List<String>> testResult3 = DataFeedTileController.retrieveLists(properties3, true);

		// Empty Record Type
		List<String> properties4 = new List<String>();
		properties4.add('Case');
		properties4.add('');
		properties4.add('Description');
		properties4.add('Status');
		properties4.add('');
		properties4.add('');
		properties4.add('');
		properties4.add('5');
		properties4.add('Documentum_Link__c');
		properties4.add('CreatedDate');
		properties4.add('DESC');
		properties4.add('Status');
		properties4.add('Closed');
		properties4.add('');
		Map<String,List<String>> testResult4 = DataFeedTileController.retrieveLists(properties4, true);

		System.assertEquals(testresult.size(), 1, 'Test Result Pass');
		System.assertEquals(testresult2.size(), 1, 'Test Result 2 Pass');
		System.assertEquals(testresult3.size(), 1, 'Test Result 3 Pass');
		System.assertEquals(testresult4, null, 'Test Result 4 Pass');

	}
	
	
}