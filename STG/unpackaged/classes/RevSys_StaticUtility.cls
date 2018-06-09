/**
*___________________________________________________
*@Name: RevSys_StaticUtility
*@Author: Chuck Walley
*@Created: Date: 11/4/2017
*@Used_By: Everything
*___________________________________________________
*@Description: Static Utility to constants
*
*___________________________________________________
*@Changes: 
* MM-DD-YYY. Explanation of the change.
**/
public class RevSys_StaticUtility  {

    // CONSTANTS 

    public static Integer INTEGER_ZERO = 0; 
    public static String  REVSYS_APP_NAME = 'Review Systems'; 
    public static String  OBSERVATION_STATUS_COMPLETE = 'Submitted'; // PKUNDU 20/11/17: ETR-128 :- Replaced Completed with Submitted  
    public static final String INACTIVE = 'Inactive';
    public static final String ACTIVE = 'Active';
    public static final String MONTHS = 'Months';
    public static final String SPARTN_TARGET = 'SPARTN Target';
    public static final String SPARTN = 'SPARTN';
    public static final String EMPLOYEE_CERT_EMAIL = 'Employee Cert Email';
    public static final String FAILED = 'Failed';
    public static final String EXPIRED = 'Expired';
    public static final String CERTIFICATION = 'Certification';
    public static final String SUPERVISOR = 'Supervisor';
    public static final String CURRENT = 'Current';
    public static final String PENDING = 'Pending';
    public static final String REVOKED = 'Revoked';
    public static final String SPARTN_CERTIFICATION = 'SPARTN Certification';
    public static final String OCCUPATION = 'Occupation';
    public static final String PASS = 'Pass';
    public static final String EMPLOYEE_RESULT_SUMM = 'Employee Result Summary';
    public static final String EMPLOYMENT_HISTORY = 'Employment History';
    public static final String STUDENT_ENGINEER = 'Student Engineer';
    public static final Decimal LENGTH_OF_PERIOD = 1;
    public static final Decimal NUMBER_OF_TESTS_PER_PERIOD = 1;
    public static final String OBSERVATION = 'Observation';

    // OBJECT API NAMES 

    public static String OBJAPI_FINDING                         = 'Finding__c'; 
    public static String OBJAPI_OBSERVATION                     = 'Observation__c'; 
    public static String OBJAPI_STATION_AUDIT_SETTING           = 'Station_Audit_Setting__mdt';
    public static String OBJAPI_SCORE_DEFINITION_SETTING        = 'SPARTN_Score_Definition__mdt';
    public static String OBJAPI_OCCUPATION_CERTIFICATION        = 'OccupationCertification__c';
    public static String OBJAPI_EMPLOYEE_CERTIFICATION          = 'EmployeeCertification__c';
    public static String OBJAPI_OCCUPATION_SPECIFIC_REQUIREMENT = 'OccupationSpecificRequirement__c';
    public static String OBJAPI_OCCUPATION_REQUIREMENT          = 'OccupationRequirement__c';
    public static String OBJAPI_EMPLOYEE_SPECIFIC_REQUIREMENT   = 'EmployeeSpecificRequirement__c';
    public static String OBJAPI_EMPLOYEE_RESULT_SUMMARY         = 'EmployeeResultSummary__c';
    public static String OBJAPI_BATCH_PROCESS_PARAMETER         = 'BatchProcessParameter__mdt';
    public static String OBJAPI_ASYNC_APEX_JOB                  = 'AsyncApexJob';
    public static String OBJAPI_CONTACT                         = 'Contact';
    public static String OBJAPI_USER                            = 'User';
    public static String OBJAPI_EMPLOYEE_HIERARCHY              = 'EmployeeHierarchy__c';
    public static String OBJAPI_VIOLATION                       = 'Violation__c';
    public static String OBJAPI_POSITION                        = 'Position__c';
    public static String OBJAPI_CERTIFICATION_REVOCATION        = 'CertificationRevocation__c';
    public static String OBJAPI_HIERARCHY_ASSIGNMENT            = 'EPW_Hierarchy_Assignment__c';
    public static String OBJAPI_POSITION_HIERARCHY              = 'EPW_Position_Hierarchy__c';
    public static String OBJAPI_ORGANIZATION                    = 'EPW_Organization__c';
    public static String OBJAPI_FIELDCONVERSIONMAP              = 'FieldConversionMap__c';
    public static String OBJAPI_ACCOUNT                         = 'Account';

    // RECORD TYPES 

    // Contact
    public static Id CONTACT_FOREIGNRREMPLOYEE_RECTYPE_ID                 
        = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('SPARTN Foreign Railroad Employee').getRecordTypeId(); 

    //EmployeeCertification -  Record Type IDs
     public static Id EMPCERT_SPARTNCERT_RECTYPE_ID
        = Schema.SObjectType.EmployeeCertification__c.getRecordTypeInfosByName().get(Label.RevSys_Emp_Cert_SPARTN_Cert_Record_Type).getRecordTypeId();
     public static Id EMPCERT_SPARTSUPV_RECTYPE_ID
        = Schema.SObjectType.EmployeeCertification__c.getRecordTypeInfosByName().get(Label.RevSys_Emp_Cert_SPARTN_SUPV_Record_Type).getRecordTypeId();

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
    
    // FieldConversionMap
    public static Id FIELDCONVERSIONMAP_SPARTNCRAFT_RECTYPE_ID                 
        = Schema.SObjectType.FieldConversionMap__c.getRecordTypeInfosByName().get(Label.RevSys_FieldConversionMap_RT_Label_SPARTN_Craft).getRecordTypeId();
    public static Id FIELDCONVERSIONMAP_SPARTNLOCATION_RECTYPE_ID                 
        = Schema.SObjectType.FieldConversionMap__c.getRecordTypeInfosByName().get(Label.RevSys_FieldConversionMap_RT_Label_SPARTN_Location).getRecordTypeId();

    // Finding
    public static Id FINDING_REVIEW_SYSTEMS_RECTYPE_ID                 
        = Schema.SObjectType.Finding__c.getRecordTypeInfosByName().get('Review Systems').getRecordTypeId();

    // Observation
    public static Id OBSERVATION_OBSERVATIONS_RECTYPE_ID                 
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get('Observations').getRecordTypeId();
         
    public static Id OBSERVATION_TEST1872_RECTYPE_ID                 
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1872).getRecordTypeId(); 
    public static Id OBSERVATION_TEST1875_RECTYPE_ID                 
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1875).getRecordTypeId(); 
    public static Id OBSERVATION_TEST1876_RECTYPE_ID                 
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1876).getRecordTypeId(); 
    public static Id OBSERVATION_TEST1877_RECTYPE_ID                 
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1877).getRecordTypeId(); 
    public static Id OBSERVATION_TEST1878_RECTYPE_ID                 
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1878).getRecordTypeId(); 


    public static String OBSERVATION_OBSERVATIONS_RECTYPE_NAME                 
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get('Observations').getName();
         
    public static String OBSERVATION_TEST1872_RECTYPE_NAME                
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1872).getName(); 
    public static String OBSERVATION_TEST1875_RECTYPE_NAME                
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1875).getName();
    public static String OBSERVATION_TEST1876_RECTYPE_NAME                
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1876).getName(); 
    public static String OBSERVATION_TEST1877_RECTYPE_NAME                
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1877).getName(); 
    public static String OBSERVATION_TEST1878_RECTYPE_NAME                
        = Schema.SObjectType.Observation__c.getRecordTypeInfosByName().get(Label.RevSys_Observation_RT_Label_Test_1878).getName(); 
    
    //Occupation Certification - Record Type IDs 
    public static String OCCUPCERTIFICATION_SPARTNTARGET_RECTYPE_ID                
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.RevSys_OccCertification_RT_Label_Target).getRecordTypeId();
    public static String OCCUPCERTIFICATION_SPARTNCERT_RECTYPE_ID                
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.RevSys_OccCertification_RT_Label_Certification).getRecordTypeId();
   public static String OCCUPCERTIFICATION_DEPTCERT_FOR_OBS_RECTYPE_ID                
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.RevSys_OccCertification_RT_SPARTN_Dept_Craft_for_Observations).getRecordTypeId(); 
    public static Id OCC_CERT_SPARTNTARGET_RECTYPE_ID
         = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(SPARTN_TARGET).getRecordTypeId(); 
    public static String OCCUPCERTIFICATION_SPARTN_REQUIREMENT_TARGET_RECTYPE_ID                
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.RevSys_OccCertification_RT_SPARTN_Requirement_Target).getRecordTypeId(); 
    public static String OCCUPCERTIFICATION_SPARTN_VIOLATION_TARGET_RECTYPE_ID                
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.RevSys_OccCertification_RT_SPARTN_Violation_Target).getRecordTypeId(); 
    
    public static Id OCC_CERT_SPARTN_VIOLATION_RECTYPE_ID 
        = Schema.SObjectType.OccupationCertification__c.getRecordTypeInfosByName().get(Label.SPARTN_Violation_Target).getRecordTypeId(); 

    //Occupation Requirement - Record Type IDs
    public static String OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID                
        = Schema.SObjectType.OccupationRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_OccRequirement_RT_Label_Observation).getRecordTypeId();
    public static String OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID                
        = Schema.SObjectType.OccupationRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_OccRequirement_RT_Label_Requirement).getRecordTypeId();
    
    //Employee Specific Requirement - Record Type IDs
    public static String EMPSPECREQUIREMENT_SPARTNTARGET_RECTYPE_ID                  
        = Schema.SObjectType.EmployeeSpecificRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_EmpSpecReq_RT_Label_Target).getRecordTypeId();
    public static String EMPSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID                
        = Schema.SObjectType.EmployeeSpecificRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_EmpSpecReq_RT_Label_Cert).getRecordTypeId();
    public static Id EMP_SPEC_REQ_SPARTNTARGET_RECTYPE_ID
         = Schema.SObjectType.EmployeeSpecificRequirement__c.getRecordTypeInfosByName().get(SPARTN_TARGET).getRecordTypeId(); 
        
    
    //Occupation Specific Requirement - Record Type IDs
    public static String OCCSPECREQUIREMENT_SPARTNCERT_RECTYPE_ID                
        = Schema.SObjectType.OccupationSpecificRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_OccSpecReq_RT_Label_Certification).getRecordTypeId();
    public static String OCCSPECREQUIREMENT_DEPTCERT_FOR_OBS_RECTYPE_ID                 
        = Schema.SObjectType.OccupationSpecificRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_OccSpecReq_RT_SPARTN_Dept_Craft_for_Observations).getRecordTypeId();    
    public static Id OCC_SPEC_REQ_SPARTNTARGET_RECTYPE_ID
     = Schema.SObjectType.OccupationSpecificRequirement__c.getRecordTypeInfosByName().get(SPARTN_TARGET).getRecordTypeId();

    // Rule Violation
    public static Id RULEVIOLATION_SPARTN_SPARTN_NRPC_3164_VIOLATION_RECTYPE_ID 
        = Schema.SObjectType.RuleViolation__c.getRecordTypeInfosByName().get(Label.Revsys_Rule_Violation_RT_SPARTN_NRPC_3164_Violation).getRecordTypeId(); 

    // Violation
    public static Id VIOLATION_SPARTN_EMP_RECTYPE_ID 
        = Schema.SObjectType.Violation__c.getRecordTypeInfosByName().get(Label.SPARTN_Employee_Violation).getRecordTypeId(); 
    public static Id VIOLATION_SPARTN_OVERALL_VIOLATION_RECTYPE_ID 
        = Schema.SObjectType.Violation__c.getRecordTypeInfosByName().get(Label.Revsys_Violation_RT_Overall_Violation).getRecordTypeId(); 

   /* //Employee Hierarchy 
    public static Id EMPLOYEE_HIERARCHY_SPARTN_RECTYPE_ID
        = Schema.SObjectType.EmployeeHierarchy__c.getRecordTypeInfosByName().get(SPARTN).getRecordTypeId(); */

    //Position
   /* public static Id POSITION_CREW_BASE_RECTYPE_ID
        = Schema.SObjectType.Position__c.getRecordTypeInfosByName().get(Label.RevSys_Position_RT_Label_Crew_Base).getRecordTypeId(); */
    
    //Position Hierarchy
    public static Id POSITION_HIERARCHY_SPARTN_RECTYPE_ID
        = Schema.SObjectType.EPW_Position_Hierarchy__c.getRecordTypeInfosByName().get(Label.RevSys_Position_Hr_RT_Spartn).getRecordTypeId(); 
     //public static Id POSITION_HIERARCHY_AMTRAK_RECTYPE_ID
     //   = Schema.SObjectType.EPW_Position_Hierarchy__c.getRecordTypeInfosByName().get('Amtrak Employee').getRecordTypeId(); 
     public static Id POSITION_HIERARCHY_AMTRAK_RECTYPE_ID
        = Schema.SObjectType.EPW_Position_Hierarchy__c.getRecordTypeInfosByName().get(Label.RevSys_PositionHierarchy_RT_Label_Amtrak).getRecordTypeId(); 
    
    //ORGANIZATION
     public static Id ORGANIZATION_AMTRAKORG_RECTYPE_ID
        = Schema.SObjectType.EPW_Organization__c.getRecordTypeInfosByName().get(Label.RevSys_Organiztion_RT_Label_AmtrakOrg).getRecordTypeId(); 

     public static Id ORGANIZATION_SPARTN_RECTYPE_ID
        = Schema.SObjectType.EPW_Organization__c.getRecordTypeInfosByName().get(Label.RevSys_Organiztion_RT_Label_Spartn).getRecordTypeId(); 

    // Certification Revocation
    public static Id CERTIFICATION_REVOCATION_SPARTN_RECTYPE_ID
        = Schema.SObjectType.CertificationRevocation__c.getRecordTypeInfosByName().get(Label.RevSys_Certification_Revocation_RT_Label).getRecordTypeId(); 
}