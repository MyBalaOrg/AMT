/**
*___________________________________________________
*@Name:     FindingSelector_Test
*@Author:   Boom Bertetti
*@Created:  Date: 1/3/2018
*@Used_By:  Everyone
*___________________________________________________
*@Description: Test for FindingSelector
* 
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
@isTest
private class FindingSelector_Test {

    @TestSetup
    public static void loadTestData() {
        Contact c               = new Contact();
        c.LastName              ='Employee'; 
        c.FirstName             ='Amy'; 
        c.Personnel_Number__c   = 1234567;
        c.Email                 = 'test.test@amtrak.com';
        insert c; 

        Observation__c obs        = new Observation__c();
        obs.RecordTypeId          = RevSys_StaticUtility.OBSERVATION_TEST1875_RECTYPE_ID;
        obs.Status__c             = 'Draft';
        obs.EvaluationDateTime__c = Datetime.now();
        obs.Employee__c           = c.Id;
        insert obs;
        
        
    }

    private static testmethod void selectFindingsTest() {
       
        Set<Id> observationIds = new Set<Id>();
        for (Observation__c obs : [SELECT Id FROM Observation__c]) {
            observationIds.add(obs.Id);
        }
		 test.startTest();
        // Test positive
        SelectorWrapper selector1 = new FindingSelector().getObsLimitedRelatedFindings(observationIds);
        system.debug('selector1.ErrorMessage  ' + selector1.ErrorMessage); 
        system.assertEquals(null,selector1.ErrorMessage); 
		System.assertEquals(0, selector1.SObjectList.size());
       
        List<Finding__c> testFindings = (List<Finding__c>)selector1.SObjectList;

        Set<Id> findingIds = new Set<Id>();
        for (Finding__c finding : testFindings) {
            findingIds.add(finding.Id);
        }

        SelectorWrapper selector2 = new FindingSelector(findingIds).selectById();
        //System.assert(selector2.SObjectList.size() > 0);

        SelectorWrapper selector3 = new FindingSelector(findingIds).selectAllFieldsById();
        //System.assert(selector3.SObjectList.size() > 0);

        // Test negative
        Map<String, String> badAttributesMap = new Map<String, String>();
        badAttributesMap.put('orderBy', 'badfield');

        SelectorWrapper selector4 = new FindingSelector(findingIds, badAttributesMap).selectById();
        //System.assertNotEquals(null, selector4.ErrorMessage);

        SelectorWrapper selector5 = new FindingSelector(findingIds, badAttributesMap).selectAllFieldsById();
        //System.assertNotEquals(null, selector5.ErrorMessage);
        
        SelectorWrapper selector6 = FindingSelector.getObsRelatedFindings(observationIds);
        
       
        Finding__c find = new Finding__c();
        find.At_Risk_Checkbox__c = false;
        find.RecordTypeId = Revsys_StaticUtility.FINDING_REVIEW_SYSTEMS_RECTYPE_ID;
        find.QuestionLastModifiedVersion__c = 10;
        insert find;
        
        Integer LastModVer = (Integer) find.QuestionLastModifiedVersion__c;
        FindingSelector findSel = new FindingSelector();
        SelectorWrapper selector7 = findSel.getObsLimitedRelatedFindingsVersion(observationIds,LastModVer);
        FindingSelector.getSubQueryStr(new List<String>(),'','','','',''); 
        
        FindingSelector.DoFailTest = TRUE;
        selector1 = new FindingSelector().getObsLimitedRelatedFindings(observationIds);
        selector6 = FindingSelector.getObsRelatedFindings(observationIds);
        selector7 = findSel.getObsLimitedRelatedFindingsVersion(observationIds,LastModVer);
         test.stopTest();
        
    }
}