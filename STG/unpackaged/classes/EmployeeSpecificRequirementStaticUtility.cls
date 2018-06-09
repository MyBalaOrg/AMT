public class EmployeeSpecificRequirementStaticUtility {
    public static string TriggerErrorMessage;
    
    //Employee Specific Requirement - Record Type IDs
    public static String EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID                  
        = Schema.SObjectType.EmployeeSpecificRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_EmpSpecReq_RT_Label_Target).getRecordTypeId();
    public static String EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID                
        = Schema.SObjectType.EmployeeSpecificRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_EmpSpecReq_RT_Label_Cert).getRecordTypeId();
    public static Id EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID
         = Schema.SObjectType.EmployeeSpecificRequirement__c.getRecordTypeInfosByName().get('SPARTN Target').getRecordTypeId(); 
}