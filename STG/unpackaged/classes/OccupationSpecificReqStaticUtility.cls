public class OccupationSpecificReqStaticUtility  {
    public static string TriggerErrorMessage;
    
    //Occupation Specific Requirement - Record Type IDs
    public static String OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID                
        = Schema.SObjectType.OccupationSpecificRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_OccSpecReq_RT_Label_Certification).getRecordTypeId();
    public static String OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID                 
        = Schema.SObjectType.OccupationSpecificRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_OccSpecReq_RT_SPARTN_Dept_Craft_for_Observations).getRecordTypeId();    
    public static Id OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID
        = Schema.SObjectType.OccupationSpecificRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_OccSpecReq_RT_Label_SPARTN_Target).getRecordTypeId();
}