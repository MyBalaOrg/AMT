public class OccupationCertificationStaticUtility {
    public static string TriggerErrorMessage; 
    
    //Occupation Certification - Record Type IDs 
    public static String OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID                
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.RevSys_OccCertification_RT_Label_Target).getRecordTypeId();
    public static String OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID                
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.RevSys_OccCertification_RT_Label_Certification).getRecordTypeId();
    public static String OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID                
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.RevSys_OccCertification_RT_SPARTN_Dept_Craft_for_Observations).getRecordTypeId(); 
    public static String OCCUPCERTIFICATION_SPARTN_REQUIREMENT_TARGET_RECTYPE_ID                
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.RevSys_OccCertification_RT_SPARTN_Requirement_Target).getRecordTypeId(); 
    public static String OCCUPCERTIFICATION_SPARTN_VIOLATION_TARGET_RECTYPE_ID                
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.RevSys_OccCertification_RT_SPARTN_Violation_Target).getRecordTypeId(); 
    public static Id OCC_CERT_SPARTN_VIOLATION_RECTYPE_ID 
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.SPARTN_Violation_Target).getRecordTypeId();     

}