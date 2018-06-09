public class EmployeeCertificationStaticUtility {
    public static string TriggerErrorMessage;
    
    //EmployeeCertification -  Record Type IDs
     public static Id EMPCERT_SPARTNCERT_RECTYPE_ID
        = Schema.SObjectType.EmployeeCertification__c.getRecordTypeInfosByName().get(Label.RevSys_Emp_Cert_SPARTN_Cert_Record_Type).getRecordTypeId();
     public static Id EMPCERT_SPARTSUPV_RECTYPE_ID
        = Schema.SObjectType.EmployeeCertification__c.getRecordTypeInfosByName().get(Label.RevSys_Emp_Cert_SPARTN_SUPV_Record_Type).getRecordTypeId();

}