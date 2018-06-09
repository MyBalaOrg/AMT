/**
*————————————————————————————————————————————————————
* @Name             EIS_GeoLocatorRemoterTest
* @Created Date     08-02-2017
* @Used By          EIS_GeoLocatorRemoter 
*————————————————————————————————————————————————————
* @Description
* Used to unit test EIS_GeoLocatorRemoter class
* 
*————————————————————————————————————————————————————
* @Changes
* 
**/
@isTest
public class EIS_GeoLocatorRemoterTest {
    @isTest
    public static void testFindAll() {
        EIS_TestDataUtils.insertCustomSettings();
        Incidents__c incident = new Incidents__c();
        incident.SpillLocation__Latitude__s = 66.06;
        incident.SpillLocation__Longitude__s =32.08;
        incident.recordtypeid=Schema.SObjectType.Incidents__c .getRecordTypeInfosByName().get('Spill Main').getRecordTypeId();
        incident.EIS_Corrective_Action__c =true;
        incident.EIS_Date_Time_of_Incident__c = Date.today();
        insert incident;
        PageReference pageRef = Page.EIS_Map;
        Test.setCurrentPage(pageRef);
        EIS_GeoLocatorRemoter controller = new EIS_GeoLocatorRemoter();
        // String npReturn = (controller.resetSearch().getUrl())!=null?controller.resetSearch().getUrl():'null';
        controller.resetSearch();
        controller.SearchIncidents();
        List<Incidents__c> incidents = EIS_GeoLocatorRemoter.getAllIncidents(null,null);
        system.assert(incidents.size()>0);
    }
    
}