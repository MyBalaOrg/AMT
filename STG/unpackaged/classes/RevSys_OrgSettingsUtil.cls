/**
*___________________________________________________
*@Name: RevSys_OrgSettingsUtil 
*@Author: Chuck Walley
*@Created: Date: 11/14/2017
*@Used_By: Review Systems
*___________________________________________________
*@Description: Controls execution or bypass of triggers 
*              via custom settings.
*___________________________________________________
*@Changes: 
* MM-DD-YYYY. Explanation of the change.
*___________________________________________________
*@Change_1.1:
*@Author: Raj Kumar Pandy
*11-21-2017. Added the method isOccupationCertificationTriggerBypassEnabled() for the OccupationCertification Trigger.
**/
public class RevSys_OrgSettingsUtil {
    
    public static Boolean isObservationTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.ObservationTrigger__c;        
    }
    
    public static Boolean isFindingTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.FindingTrigger__c;        
    }
    
    public static Boolean isOccupationCertificationTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.OccupationCertificationTrigger__c;      
    }
    public static Boolean isContactTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.ContactTrigger__c;        
    }
    
    public static Boolean isOccupationRequirementTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.OccupationRequirementTrigger__c;        
    }

    public static Boolean isOccupationSpecificRequirementTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.OccupationSpecificRequirementTrigger__c;        
    }
    
    public static Boolean isEmployeeCertificationTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.EmployeeCertificationTrigger__c; 
    }
    public static Boolean isEmployeeResultSummaryTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.EmployeeResultSummaryTrigger__c; 
    }
    public static Boolean isViolationTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.ViolationTrigger__c; 
    }
    public static Boolean isCertificationRevocationTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.CertificationRevocationTrigger__c; 
    }
    public static Boolean isPositionTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance(); 
        return settings.PositionTrigger__c; 
    }
    public static Boolean isPositionHierarchyTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.PositionHierarchyTrigger__c; 
    }

    public static Boolean isEpwHierarchyAssignmentTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.EpwHierarchyAssignmentTrigger__c; 
    }

    public static Boolean isEmployeeSpecificRequirementTriggerBypassEnabled(){
        SPARTN_BypassTriggerSettings__c settings = SPARTN_BypassTriggerSettings__c.getInstance();
        return settings.EmployeeSpecificRequirementTrigger__c; 
    }

}