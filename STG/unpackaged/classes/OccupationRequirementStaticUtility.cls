public class OccupationRequirementStaticUtility {

    public static string TriggerErrorMessage;
    
    //Occupation Requirement - Record Type IDs
    public static String OCCREQUIREMENT_SPARTNOBSERVATION_RECTYPE_ID                
        = Schema.SObjectType.OccupationRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_OccRequirement_RT_Label_Observation).getRecordTypeId();
    public static String OCCREQUIREMENT_SPARTNREQUIREMENT_RECTYPE_ID                
        = Schema.SObjectType.OccupationRequirement__c.getRecordTypeInfosByName().get(Label.RevSys_OccRequirement_RT_Label_Requirement).getRecordTypeId();
}