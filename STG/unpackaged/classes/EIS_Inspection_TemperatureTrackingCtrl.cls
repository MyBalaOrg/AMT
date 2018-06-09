/**
*————————————————————————————————————————————————————
* @Name             EIS_Inspection_TemperatureTrackingCtrl
* @Author           Duy Tran
* @Created Date     08-12-2017
* @Used By          EIS_Inspection_TemperatureTrackingSection.cmp, EIS_Inspection_TemperatureTracking.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to generate and handle DML operations for Temperature Tracking on Inspection Form
*————————————————————————————————————————————————————
* @Changes
*
**/
public without sharing class EIS_Inspection_TemperatureTrackingCtrl {
    //Wrapper class to control Temperature Tracking lightning components
    public class TemperatureTracking {
        public String temperatureType {get; set;}
        public String trackingUnitLabel {get; set;}
        public String existingRecords {get; set;}
        public List<String> locationPicklist {get; set;}
        public List<String> locationTypePicklist {get; set;}
        public List<Tracking__c> trackingList {get; set;}
    }
    
	/**
    *————————————————————————————————————————————————————
    * @Description
    * Initialize temperature tracking wrapper for temperature tracking components
    *————————————————————————————————————————————————————
    * @param    inspectionId			Id of the current inspection form
    * @return   Map<String, String>		Map of TemperatureTrackingWrapper to set up temperature tracking components
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> initTemperatureTrackingSection(String inspectionId) {
        Map<String, String> response = new Map<String, String>();
        try {
            Audit_Inspections__c inspection = [SELECT Id, RecordType.DeveloperName FROM Audit_Inspections__c WHERE Id = :inspectionId];
            
            Map<String, List<Tracking__c>> trackingsMap = getTrackingMapByTempType(inspectionId);
            
            Schema.SObjectField theField = Tracking__c.EIS_Location__c.getDescribe().getSObjectField();
            Schema.SObjectField ctrlField = Tracking__c.EIS_Temperature_Type__c.getDescribe().getSObjectField();
            Map<String, List<String>> locationValuesMap = EIS_StaticUtils.getDependentOptionsImpl(theField, ctrlField);
            
            List<TemperatureTracking> tempTrackingWrappers = new List<TemperatureTracking>();
            if (inspection.RecordType.DeveloperName == (Label.EIS_Commissary_Inspection_Form_Record_Type) || inspection.RecordType.DeveloperName == (Label.EIS_Vendor_Inspection_Form_Record_Type)) {
                tempTrackingWrappers.add(getTemperatureTrackingWrapper(locationValuesMap, trackingsMap, Label.EIS_Tracking_Temp_Type_Refrigeration, Label.EIS_Form_Label_Temperature_Unit));
                tempTrackingWrappers.add(getTemperatureTrackingWrapper(locationValuesMap, trackingsMap, Label.EIS_Tracking_Temp_Type_Freezer, Label.EIS_Form_Label_Temperature_Unit));
                tempTrackingWrappers.add(getTemperatureTrackingWrapper(locationValuesMap, trackingsMap, Label.EIS_Tracking_Temp_Type_Hand_Wash, Label.EIS_Form_Label_Temperature_Unit));
                
                TemperatureTracking foodTT = getTemperatureTrackingWrapper(locationValuesMap, trackingsMap, Label.EIS_Tracking_Temp_Type_Food_Item, Label.EIS_Form_Label_Temperature_Unit);
                foodTT.locationTypePicklist = EIS_StaticUtils.getPicklistValues(Tracking__c.EIS_Location_Type__c.getDescribe());
                foodTT.trackingList[0].EIS_Food_Item__c = Label.EIS_Form_Default_Value_Food_Item;
                response.put('foodTrackingWrapper', JSON.serialize(foodTT));
                response.put('sectionHeader', Label.EIS_Form_Section_Header_Temperature_Tracking);
            } else if (inspection.RecordType.DeveloperName == (Label.EIS_Waterpoint_Inspection_Form_Record_Type)) {
                tempTrackingWrappers.add(getTemperatureTrackingWrapper(locationValuesMap, trackingsMap, Label.EIS_Tracking_Temp_Type_Hydrant, Label.EIS_Form_Label_Temperature_Hydrant_Unit));
                response.put('sectionHeader', Label.EIS_Form_Section_Header_Hydrants);
            }
            
            response.put('tempTrackingWrappers', JSON.serialize(tempTrackingWrappers));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
        }
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Upsert temperature tracking record
    * Return updated temperature tracking records
    *————————————————————————————————————————————————————
    * @param    params					JSON representation of tracking to be updated
    * @return   Map<String, String>		Map of updated tracking list
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static Map<String, String> saveTemperatureTrackingRecord(Map<String, String> params) {
        Map<String, String> response = new Map<String, String>();
        SavePoint sp = Database.setSavepoint();
        try {
            Tracking__c tracking = (Tracking__c)JSON.deserialize(params.get('trackingJSON'), Tracking__c.class);
            String inspectionId = params.get('inspectionId');
            String tempType = tracking.EIS_Temperature_Type__c;
            
            if (params.get('operation') == 'upsert') {
                tracking.EIS_Inspection_Form__c = params.get('inspectionId');
                if (tracking.EIS_Temperature_Type__c == Label.EIS_Tracking_Temp_Type_Hydrant) {
                    tracking.EIS_Unit__c = Label.EIS_Tracking_Unit_PPM;
                }
                upsert tracking;
            } else if (params.get('operation') == 'delete') {
                delete tracking;
            }
            
            List<Tracking__c> trackings = [
                SELECT Id, RecordTypeId, EIS_Inspection_Form__c, EIS_Food_Item__c, EIS_Location__c, EIS_Location_Type__c, EIS_Temperature__c, EIS_Temperature_Type__c, EIS_Unit__c
                FROM Tracking__c WHERE EIS_Inspection_Form__c = :inspectionId AND EIS_Temperature_Type__c = :tempType
                ORDER BY EIS_Location__c
            ];
            
            String existingRecords = getExistingRecordsString(trackings);
            
            if (trackings.isEmpty()) {
                trackings.add(new Tracking__c(EIS_Location__c = '', EIS_Temperature_Type__c = tempType, RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID));
            }
            
            response.put('trackingList', JSON.serialize(trackings));
            response.put('existingRecords', existingRecords);
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            Database.rollback(sp);
        }
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Query for Tracking records and group them by Temperature Type
    *————————————————————————————————————————————————————
    * @param    inspectionId						Id of the Inspection Form to retrieve Tracking records from
    * @return   Map<String, List<Tracking__c>>		Map of queried Tracking lists group by Temperature Type
    *————————————————————————————————————————————————————
    **/
    private static Map<String, List<Tracking__c>> getTrackingMapByTempType(String inspectionId) {
        Map<String, List<Tracking__c>> trackingsMap = new Map<String, List<Tracking__c>>();
        List<Tracking__c> trackings = [
            SELECT Id, RecordTypeId, EIS_Inspection_Form__c, EIS_Food_Item__c, EIS_Location__c, EIS_Location_Type__c, EIS_Temperature__c, EIS_Temperature_Type__c, EIS_Unit__c
            FROM Tracking__c WHERE EIS_Inspection_Form__c = :inspectionId
            ORDER BY EIS_Location__c
        ];
        for (Tracking__c t : trackings) {
            if (trackingsMap.get(t.EIS_Temperature_Type__c) == null) {
                trackingsMap.put(t.EIS_Temperature_Type__c, new List<Tracking__c>());
            }
            trackingsMap.get(t.EIS_Temperature_Type__c).add(t);
        }
        return trackingsMap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Initialize TemperatureTracking wrapper object based on Temperature Type
    *————————————————————————————————————————————————————
    * @param    locationValuesMap		Map of controlled picklist values group by Temperature Type
    * @param    trackingsMap			Map of queried Tracking lists group by Temperature Type
    * @param    tempType				Temperature Type value
    * @param    unitLabel				Label for the unit of temperature/hydrant values
    * @return   TemperatureTracking		TemperatureTracking wrapper object populated
    *————————————————————————————————————————————————————
    **/
    private static TemperatureTracking getTemperatureTrackingWrapper(Map<String, List<String>> locationValuesMap, Map<String, List<Tracking__c>> trackingsMap, String tempType, String unitLabel) {
        TemperatureTracking tt = new TemperatureTracking();
        tt.temperatureType = tempType;
        tt.locationPicklist = locationValuesMap.get(tempType);
        tt.existingRecords = '';
        if (trackingsMap.get(tempType) == null || trackingsMap.get(tempType).isEmpty()) {
            tt.trackingList = new List<Tracking__c>();
            tt.trackingList.add(new Tracking__c (
            	EIS_Location__c = tt.locationPicklist[0],
                EIS_Temperature_Type__c = tempType,
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID
            ));
        } else {
            tt.trackingList = trackingsMap.get(tempType);
            tt.existingRecords = getExistingRecordsString(tt.trackingList);
        }
        tt.trackingUnitLabel = unitLabel;
        
        return tt;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Initialize TemperatureTracking wrapper object based on Temperature Type
    *————————————————————————————————————————————————————
    * @param    trackingList	List of Tracking records queried
    * @return   String			String of Location values that's already been recorded
    *————————————————————————————————————————————————————
    **/
    private static String getExistingRecordsString(List<Tracking__c> trackingList) {
        String existingRecords = '';
        for (Tracking__c t : trackingList) {
            existingRecords += t.EIS_Location__c + ';';
        }
        return existingRecords.toLowerCase();
    }
}