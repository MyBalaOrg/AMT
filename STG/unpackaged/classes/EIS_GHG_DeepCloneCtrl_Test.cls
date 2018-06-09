@isTest
public class EIS_GHG_DeepCloneCtrl_Test {
	@testSetup static void setup() {
        try {
            EIS_TestDataUtils.createLogisticGHGActivityType();
        } catch (DMLException e) {
            System.debug(e.getStackTraceString());
        }
    }
    
    @isTest
    public static void syncLineItemsFactorValue_Test() {
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
        
        Waste_Emissions__c ghgEntry = new Waste_Emissions__c(
        	RecordTypeId = EIS_StaticUtils.WASTE_EMISSIONS_GHG_RTID,
            EIS_Factor_Table__c = parentFactor.Id,
            EIS_eGRID_Subregion__c = subRegionMultiSelect[0] + ';' + subRegionMultiSelect[1]
        );
        insert ghgEntry;
        
        Test.startTest();
        EIS_GHG_DeepCloneCtrl.syncLineItemsFactorValue(ghgEntry.Id);
        Test.stopTest();
        List<Line_Item__c> liList = [SELECT Id From Line_Item__c WHERE EIS_Waste_Management__c = :ghgEntry.Id];
        System.assert(!liList.isEmpty());
    }
    
    @isTest
    public static void deepCloneLogisticRecord_Test() {
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
        Map<String, String> response = EIS_GHG_DeepCloneCtrl.deepCloneLogisticRecord(parentFactor.Id, String.valueOf(Date.today()), String.valueOf(Date.today()));
        String recordId = response.get('factorId');
        Test.stopTest();
        List<Logistic__c> oldList = [SELECT Id From Logistic__c WHERE EIS_Factor_Table__c = :parentFactor.Id];
        List<Logistic__c> newList = [SELECT Id From Logistic__c WHERE EIS_Factor_Table__c = :recordId];
        System.assertEquals(oldList.size(), newList.size());
    }
    
    @isTest
    public static void annualConsumptionEntry_Test() {
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
        
        Waste_Emissions__c ghgEntry = new Waste_Emissions__c(
        	RecordTypeId = EIS_StaticUtils.WASTE_EMISSIONS_GHG_RTID,
            EIS_Factor_Table__c = parentFactor.Id,
            EIS_eGRID_Subregion__c = subRegionMultiSelect[0] + ';' + subRegionMultiSelect[1]
        );
        insert ghgEntry;
        
        Test.startTest();
        String lineItemGroups = EIS_GHG_DeepCloneCtrl.getLineItemGroupList(ghgEntry.Id);
        List<EIS_GHG_DeepCloneCtrl.LineItemGroup> ligList = (List<EIS_GHG_DeepCloneCtrl.LineItemGroup>)JSON.deserialize(lineItemGroups, List<EIS_GHG_DeepCloneCtrl.LineItemGroup>.class);
        
        Boolean notFoundELL = true;
        for (Integer i = 0; i < ligList.size(); i++) {
            if (ligList[i].identifier.containsIgnoreCase(Label.EIS_Logistic_GHG_Activity_Electric_Line_Loss)) {
                if (notFoundELL) {
                    ligList[i].consumptionValue = 100.0;
                    ligList[i].conversionFactor = 0.6;
                    ligList[i].calculatedUMO = 'drytuna';
                    String errorMsg = EIS_GHG_DeepCloneCtrl.updateLineItemAnnualConsumption(JSON.serialize(ligList[i]));
                    System.assert(String.isBlank(errorMsg));
                    notFoundELL = false;
                }
            } else {
                if (i < 5) {
                    ligList[i].consumptionValue = 100.0;
                    ligList[i].conversionFactor = 0.6;
                    ligList[i].calculatedUMO = 'drytuna';
                    String errorMsg = EIS_GHG_DeepCloneCtrl.updateLineItemAnnualConsumption(JSON.serialize(ligList[i]));
                    System.assert(String.isBlank(errorMsg));
                }
            }
        }
        Test.stopTest();
    }
}