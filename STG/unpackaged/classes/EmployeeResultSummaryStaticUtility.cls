public class EmployeeResultSummaryStaticUtility {
    public static string TriggerErrorMessage;
    
    // Employee Result Summary
    public static Id EMP_RES_SUMM_TEST1872_RECTYPE_ID                 
        = Schema.SObjectType.EmployeeResultSummary__c.getRecordTypeInfosByName().get('Form-1872').getRecordTypeId(); 
    public static Id EMP_RES_SUMM_TEST1875_RECTYPE_ID                 
        = Schema.SObjectType.EmployeeResultSummary__c.getRecordTypeInfosByName().get('Form-1875').getRecordTypeId();
    public static Id EMP_RES_SUMM_TEST1876_RECTYPE_ID                 
        = Schema.SObjectType.EmployeeResultSummary__c.getRecordTypeInfosByName().get('Form-1876').getRecordTypeId(); 
    public static Id EMP_RES_SUMM_TEST1877_RECTYPE_ID                 
        = Schema.SObjectType.EmployeeResultSummary__c.getRecordTypeInfosByName().get('Form-1877').getRecordTypeId(); 
    public static Id EMP_RES_SUMM_TEST1878_RECTYPE_ID                 
        = Schema.SObjectType.EmployeeResultSummary__c.getRecordTypeInfosByName().get('Form-1878').getRecordTypeId();
    public static Id EMP_RES_SUMM_MEDICAL_RECTYPE_ID                 
        = Schema.SObjectType.EmployeeResultSummary__c.getRecordTypeInfosByName().get(Label.RevSys_EmpResSumm_RT_Label_Medical).getRecordTypeId();   
    public static Id EMP_RES_SUMM_EMPHISTORY_RECTYPE_ID                 
        = Schema.SObjectType.EmployeeResultSummary__c.getRecordTypeInfosByName().get(Label.RevSys_EmpResSumm_RT_Label_EmpHistory).getRecordTypeId();
    public static Id EMP_RES_SUMM_MOTORVEHICLE_RECTYPE_ID                 
        = Schema.SObjectType.EmployeeResultSummary__c.getRecordTypeInfosByName().get(Label.RevSys_EmpResSumm_RT_Label_Motor).getRecordTypeId(); 

}