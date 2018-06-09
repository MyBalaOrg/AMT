@isTest
public class EIS_Inspection_TemperatureTracking_Test {
	@testSetup static void setup() {
        try {
            EIS_TestDataUtils.getBypassTriggerSettings();
        } catch (DMLException e) {
            
        }
    }
    
    @isTest
    public static void exceptionHanding_Test() {
        Test.startTest();
        Map<String, String> response = null;
        response = EIS_Inspection_TemperatureTrackingCtrl.initTemperatureTrackingSection(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        
        response = EIS_Inspection_TemperatureTrackingCtrl.saveTemperatureTrackingRecord(null);
        System.assert(String.isNotBlank(response.get('errorMsg')));
        Test.stopTest();
    }
    
    @isTest 
    public static void initTemperatureTrackingSection_Test() {
        List<Audit_Inspections__c> inspections = EIS_TestDataUtils.createInspectionList(null, null);
        List<Tracking__c> trackingList = new List<Tracking__c>();
        for (Audit_Inspections__c inspect : inspections) {
            trackingList.add(new Tracking__c(
                EIS_Inspection_Form__c = inspect.Id,
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Refrigeration,
                EIS_Location__c = 'Cooler 1'
            ));
            trackingList.add(new Tracking__c(
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Freezer,
                EIS_Location__c = 'Freeze 1'
            ));
            trackingList.add(new Tracking__c(
                EIS_Inspection_Form__c = inspect.Id,
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Hand_Wash,
                EIS_Location__c = 'Ice Machine'
            ));
            trackingList.add(new Tracking__c(
                EIS_Inspection_Form__c = inspect.Id,
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Food_Item,
                EIS_Location__c = 'Cooler 1'
            ));
            trackingList.add(new Tracking__c(
                EIS_Inspection_Form__c = inspect.Id,
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Hydrant,
                EIS_Location__c = 'Hydrant 1'
            ));
        }
        insert trackingList;
        
        Test.startTest();
        Map<String, String> response = new Map<String, String>();
        for (Audit_Inspections__c inspect : inspections) {
        	response = EIS_Inspection_TemperatureTrackingCtrl.initTemperatureTrackingSection(inspect.Id);
            System.assert(String.isNotBlank(response.get('tempTrackingWrappers')));
        }
        Test.stopTest();
    }
    
    @isTest 
    public static void saveTemperatureTrackingRecord_Test() {
        List<Audit_Inspections__c> inspections = EIS_TestDataUtils.createInspectionList(null, null);
        List<Tracking__c> trackingList = new List<Tracking__c>();
        for (Audit_Inspections__c inspect : inspections) {
            trackingList.add(new Tracking__c(
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Refrigeration,
                EIS_Location__c = 'Cooler 1'
            ));
            trackingList.add(new Tracking__c(
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Freezer,
                EIS_Location__c = 'Freeze 1'
            ));
            trackingList.add(new Tracking__c(
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Hand_Wash,
                EIS_Location__c = 'Ice Machine'
            ));
            trackingList.add(new Tracking__c(
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Food_Item,
                EIS_Location__c = 'Cooler 1'
            ));
            trackingList.add(new Tracking__c(
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Hydrant,
                EIS_Location__c = 'Hydrant 1'
            ));
        }
        insert trackingList;
        
        Test.startTest();
        Map<String, String> response = new Map<String, String>();
        Map<String, String> params = new Map<String, String>();
        for (Audit_Inspections__c inspect : inspections) {
            Tracking__c tempTracking = new Tracking__c(
                RecordTypeId = EIS_StaticUtils.TRACKING_TEMPERATURE_RTID,
                EIS_Temperature_Type__c = Label.EIS_Tracking_Temp_Type_Hydrant,
                EIS_Location__c = 'Hydrant 1', EIS_Temperature__c = 100.0
            );
            params.put('inspectionId', inspect.Id);
            params.put('trackingJSON', JSON.serialize(tempTracking));
            params.put('operation', 'upsert');
        	response = EIS_Inspection_TemperatureTrackingCtrl.saveTemperatureTrackingRecord(params);
            System.assert(String.isNotBlank(response.get('existingRecords')));
            List<Tracking__c> tempList = (List<Tracking__c>)JSON.deserialize(response.get('trackingList'), List<Tracking__c>.class);
            
            params.put('trackingJSON', JSON.serialize(tempList[0]));
            params.put('operation', 'delete');
            response = EIS_Inspection_TemperatureTrackingCtrl.saveTemperatureTrackingRecord(params);
            System.assert(String.isNotBlank(response.get('trackingList')));
        }
        Test.stopTest();
    }
}