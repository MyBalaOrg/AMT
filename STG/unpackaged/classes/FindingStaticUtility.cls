public class FindingStaticUtility  {
	public static string TriggerErrorMessage; 
	
	// Record Types
    public static Id FINDING_REVIEW_SYSTEMS_RECTYPE_ID                 
        = Schema.SObjectType.Finding__c.getRecordTypeInfosByName().get('Review Systems').getRecordTypeId();
}