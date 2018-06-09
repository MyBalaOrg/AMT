/** 
*————————————————————————————————————————————————————
* @Name             EIS_StaticUtils
* @Author           Duy Tran
* @Created Date     07-05-2017
* @Used By          All other apex classes from AEPHIS
*————————————————————————————————————————————————————
* @Description
* Common utilities method and constants used by other classes from AEPHIS
*————————————————————————————————————————————————————
* @Changes
*
**/
public class EIS_StaticUtils {
    // Wrapper Class for primarily used in search functionality
    public class SearchItem {
        public Id recordId {get; set;}			// Id of the record being looked up
        public String searchValue {get; set;}	// Append all desired searchable value to this field
        public String label {get; set;}			// Used for label in the selectable drop down list
        public String phone {get; set;}			// Additional field to carry more information
    }
    
    // Add more attributes if needed
    public final static Id LOCATION_MAIN_RTID = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(Label.EIS_Location_Main_Record_Type_Label).getRecordTypeId();
    public final static Id SITE_MAIN_RTID = Schema.SObjectType.Site__c.getRecordTypeInfosByName().get(Label.EIS_Site_Main_Record_Type_Label).getRecordTypeId();
    public final static Id FACILITY_MAIN_RTID = Schema.SObjectType.Site__c.getRecordTypeInfosByName().get(Label.EIS_Site_Facility_Record_Type_Label).getRecordTypeId();  
    public final static Id PERMIT_PLAN_MAIN_RTID = Schema.SObjectType.Permit_Plan__c.getRecordTypeInfosByName().get(Label.EIS_Permit_Plan).getRecordTypeId();  
    public final static Id INSPECTION_COMMISSARY_RTID = Schema.SObjectType.Audit_Inspections__c.getRecordTypeInfosByName().get(Label.EIS_Inspection_Commissary_Record_Type_Label).getRecordTypeId();
    public final static Id INSPECTION_WATERPOINT_RTID = Schema.SObjectType.Audit_Inspections__c.getRecordTypeInfosByName().get(Label.EIS_Inspection_Waterpoint_Record_Type_Label).getRecordTypeId();
    public final static Id INSPECTION_VENDOR_RTID = Schema.SObjectType.Audit_Inspections__c.getRecordTypeInfosByName().get(Label.EIS_Inspection_Vendor_Record_Type_Label).getRecordTypeId();
    public final static Id INSPECTION_FOOD_CAR_RTID = Schema.SObjectType.Audit_Inspections__c.getRecordTypeInfosByName().get(Label.EIS_Inspection_Food_Car_Record_Type_Label).getRecordTypeId();
    public final static Id INSPECTION_AUDIT_FORM_RTID = Schema.SObjectType.Audit_Inspections__c.getRecordTypeInfosByName().get(Label.EIS_Inspection_Audit_Form_Record_Type_Label).getRecordTypeId();
    public final static Id INSPECTION_SFA_FORM_RTID = Schema.SObjectType.Audit_Inspections__c.getRecordTypeInfosByName().get(Label.EIS_Inspection_SFA_Form_Record_Type_Label).getRecordTypeId();    
    public final static Id CORRECTIVEACTION_INSPECTION_RTID = Schema.SObjectType.Corrective_Action__c.getRecordTypeInfosByName().get(Label.EIS_Corrective_Action_Inspection_Record_Type_Label).getRecordTypeId();   
    public final static Id FINDING_INSPECTION_RTID = Schema.SObjectType.Finding__c.getRecordTypeInfosByName().get(Label.EIS_Finding_Inspection_Record_Type_Label).getRecordTypeId();   
    public final static Id QUESTIONS_INSPECTION_RTID = Schema.SObjectType.Questions__c.getRecordTypeInfosByName().get(Label.EIS_Questions_Inspection_Record_Type_Label).getRecordTypeId();  
    public final static Id LINE_ITEM_GHG_RTID = Schema.SObjectType.Line_Item__c.getRecordTypeInfosByName().get(Label.EIS_Line_Item_GHG_Record_Type_Label).getRecordTypeId();    
    public final static Id WASTE_EMISSIONS_GHG_RTID = Schema.SObjectType.Waste_Emissions__c.getRecordTypeInfosByName().get(Label.EIS_Waste_Emission_GHG_Record_Type_Label).getRecordTypeId();
    public final static Id TRACKING_TEMPERATURE_RTID = Schema.SObjectType.Tracking__c.getRecordTypeInfosByName().get(Label.EIS_Tracking_Temperature_Tracking_Record_Type_Label).getRecordTypeId();
    public final static Id LOGISTIC_GHG_ACTIVITY_TYPE_RTID = Schema.SObjectType.Logistic__c.getRecordTypeInfosByName().get(Label.EIS_Logistic_GHG_Activity_Record_Type_Label).getRecordTypeId();
    public final static Id LOGISTIC_GHG_FACTOR_TABLE_RTID = Schema.SObjectType.Logistic__c.getRecordTypeInfosByName().get(Label.EIS_Logistic_GHG_Factor_Table_Record_Type_Label).getRecordTypeId();
    public final static Id LOGISTIC_GHG_EGRID_TABLE_RTID = Schema.SObjectType.Logistic__c.getRecordTypeInfosByName().get(Label.EIS_Logistic_GHG_eGrid_Record_Type_Label).getRecordTypeId();
    public final static Id LOGISTIC_GHG_EMISSION_TABLE_RTID = Schema.SObjectType.Logistic__c.getRecordTypeInfosByName().get(Label.EIS_Logistic_GHG_Emission_Record_Type_Label).getRecordTypeId();
    public final static Id Compliance_Action_Main_RTID = Schema.SObjectType.Incidents__c.getRecordTypeInfosByName().get(Label.Compliance_Action_Main_Label).getRecordTypeId();
    public final static Id EIS_Spill_Main_label_RTID = Schema.SObjectType.Incidents__c.getRecordTypeInfosByName().get(Label.EIS_Spill_Main_label).getRecordTypeId();
    
    //Custom Metadata values
    public final static String METAQUESTION_FORM_API_COMMISSARY = Label.EIS_Commissary_Inspection_Form_Record_Type;
    public final static String METAQUESTION_FORM_API_WATERPOINT = Label.EIS_Waterpoint_Inspection_Form_Record_Type;
    public final static String METAQUESTION_FORM_API_VENDOR = Label.EIS_Vendor_Inspection_Form_Record_Type;
    public final static String METAQUESTION_FORM_API_FOOD_CART = Label.EIS_Food_Car_Inspection_Form_Record_Type;
    
    // Check if current user is a System Admin
    public static Boolean userIsSystemAdmin() {
        return StaticUtils.userIsSystemAdmin();
    }
    
    //Get Picklist Values from a Field
    public static List<String> getPicklistValues(Schema.DescribeFieldResult fieldResult) {
        return StaticUtils.getPicklistValues(fieldResult);
    }
    
    public static Boolean hasAccess() {
        return StaticUtils.hasAccess(String.valueOf(Label.EIS_Custom_Permission_API_AEPHIS_User)); 
    }    
    // Get dependent picklist options
    public static Map<String, List<String>> getDependentOptionsImpl(Schema.SObjectField theField, Schema.SObjectField ctrlField) {
        return StaticUtils.getDependentOptionsImpl(theField, ctrlField);
    }
    
    // Retrieve upper limit for the Activity Type Open SOQL
    public static Integer getGHGActivityTypeUpperLimit() {
        Integer dmlLimit = Limits.getLimitDMLRows();
        List<String> logisticActivities = StaticUtils.getPicklistValues(Logistic__c.EIS_Activity__c.getDescribe());
    	List<String> logisticSources = StaticUtils.getPicklistValues(Logistic__c.EIS_Source__c.getDescribe());
        Map<String, List<String>> logisticSourceTypeMap = StaticUtils.getDependentOptionsImpl(Logistic__c.EIS_Source_Type__c.getDescribe().getSObjectField(), 
                                                                                              Logistic__c.EIS_Source__c.getDescribe().getSObjectField());
        Integer maxSourceTypeCount = 1;
        for (String source : logisticSourceTypeMap.keySet()) {
            if (logisticSourceTypeMap.get(source).size() > maxSourceTypeCount) {
                maxSourceTypeCount = logisticSourceTypeMap.get(source).size();
            }
        }
        
        // Find the total possible unique combination of source type, source, and activity type
        Integer calcLimit = maxSourceTypeCount * logisticActivities.size() * logisticSources.size();
        
        return (calcLimit > dmlLimit) ? dmlLimit : calcLimit;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Return the source, scope, source type combination to be used for mapping
    *————————————————————————————————————————————————————
    * @param    logistic	Logistic record to retrieve data from
    * @param	sourceType	String value of source type. To be used when logistic source type is of multiple values
    * @return   String		combination of source, scope, and source type
    *————————————————————————————————————————————————————
    **/
    public static String getEmissionKeyForMap(Logistic__c logistic, String sourceType) {
        if (String.isBlank(sourceType)) {
            return logistic.EIS_Source__c + ' ' + logistic.EIS_Scope__c + ' ' + logistic.EIS_Source_Type__c;
        } else {
            return logistic.EIS_Source__c + ' ' + logistic.EIS_Scope__c + ' ' + sourceType;
        }
    }
}