/**
*————————————————————————————————————————————————————
* @Name             EIS_WasteEmissionsTriggerHelper_Test
* @Author           Duy Tran
* @Created Date     07-05-2017
* @Used By          Code Coverage Test
*————————————————————————————————————————————————————
* @Description
* Code coverage for EIS_WasteEmissionsTriggerHelper.apxc
* 
*————————————————————————————————————————————————————
* @Changes
*
**/
@isTest
public class EIS_WasteEmissionsTriggerHelper_Test {
	@testSetup static void setup() {
        try {
            //EIS_TestDataUtils.getBypassTriggerSettings();
            System.debug(EIS_TestDataUtils.createLogisticGHGActivityType().size());
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
        }
    }
    
    //Testing EIS_WasteEmissionsTriggerHelper.generateLineItemsForGHG_AfterInsert()
    @isTest
    public static void generateLineItemsForGHG_AfterInsert_Test() {
        Logistic__c parentFactor = EIS_TestDataUtils.getGWPFactorTable();
        insert parentFactor;
        
        List<Logistic__c> childrenFactors = new List<Logistic__c>();
        List<String> subRegionMultiSelect = new List<String>();
        for (String region : EIS_TestDataUtils.logisticSubRegions) {
            childrenFactors.add(EIS_TestDataUtils.getEGridFactorTable(region, parentFactor.Id));
            subRegionMultiSelect.add(region);
        }
        childrenFactors.addAll(EIS_TestDataUtils.getEmissionFactorTable(parentFactor.Id));
        insert childrenFactors;
        
        Test.startTest();
        Waste_Emissions__c ghgEntry = new Waste_Emissions__c(
        	RecordTypeId = EIS_StaticUtils.WASTE_EMISSIONS_GHG_RTID,
            EIS_Factor_Table__c = parentFactor.Id,
            EIS_eGRID_Subregion__c = subRegionMultiSelect[0] + ';' + subRegionMultiSelect[1]
        );
        insert ghgEntry;
        Test.stopTest();
        
        List<Line_Item__c> liList = [SELECT Id From Line_Item__c WHERE EIS_Waste_Management__c = :ghgEntry.Id];
        System.assert(!liList.isEmpty());
    }
}