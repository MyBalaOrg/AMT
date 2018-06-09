@isTest
public class QueryUtility_Test {
/*    public static testmethod void test1()
    {  
        String test;
        OccupationRequirement__c newReq = new OccupationRequirement__c
            ( 
                RecordTypeId = RevSys_StaticUtility.OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID,
                Name = 'Another Requirement',
                Status__c = 'Active',
                Source__c = 'Observation',
                SourceRecordType__c = 'FORM-1872',
                TestNumber__c = '109'
            );
        insert newReq;
        QueryUtility qUtil = new QueryUtility();
        QueryUtility.beginDynamicQuery(test);
    }
    public static testmethod void test2()
    {  
        QueryUtility qUtil = new QueryUtility();
        List<String> strList = new List<String>();
        qUtil.setSelectFields(strList);
    }
 */   
    
    
    public static testmethod void beginDynamicQueryTest(){
        
        QueryUtilityWrapper myQuWrap = QueryUtility.beginDynamicQuery(RevSys_StaticUtility.OBJAPI_OCCUPATION_SPECIFIC_REQUIREMENT);   
        System.debug('Error message '+ myQuWrap.ErrorMessage);
        System.assertEquals(NULL, myQuWrap.ErrorMessage);
        
        QueryUtilityWrapper myQuWrap1 = QueryUtility.beginDynamicQuery('DummyObject');   
        System.debug('Error message '+ myQuWrap1.ErrorMessage);
        System.assertNotEquals(NULL, myQuWrap1.ErrorMessage);
        
    }
    
   
}