/**
*————————————————————————————————————————————————————
* @Name             EIS_WasteEmissionsTriggerHelper
* @Author           Duy Tran
* @Created Date     07-05-2017
* @Used By          WasteEmissionsTriggerHandler
*————————————————————————————————————————————————————
* @Description
* Retrieve all GHG Activity Types and Factor Tables to generate Line Items
* 
*————————————————————————————————————————————————————
* @Changes
*
**/
public class EIS_WasteEmissionsTriggerHelper {
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Retrieve all GHG Activity Types and Factor Tables to generate Line Items
    * Bulk Loading will not be available
    *————————————————————————————————————————————————————
    * @param    newList					List of newly created Waste_Emissions__c records
    * @return   void
    *————————————————————————————————————————————————————
    **/
    public void generateLineItemsForGHG_AfterInsert(List<Waste_Emissions__c> newList) {
    	// Preventing bulk data upload for GHG Data Entry
        if (newList.size() > 1) { return; }
        
        // Logic below are for GHG only
        Waste_Emissions__c wasteDataEntry = newList[0];
        if (wasteDataEntry.RecordTypeId != EIS_StaticUtils.WASTE_EMISSIONS_GHG_RTID) { return; }
        
        // Retrieve all activity types Logistic
        List<Logistic__c> ghgActivityTypes = [
            SELECT Id, EIS_Activity__c, EIS_Source__c, EIS_Source_Type__c, EIS_Scope__c
            FROM Logistic__c 
            WHERE RecordType.DeveloperName = :Label.EIS_Logistic_GHG_Activity_Record_Type
            LIMIT :EIS_StaticUtils.getGHGActivityTypeUpperLimit()
        ];
        
        // Retrieve all factor values from the parent Factor Table
        Logistic__c gwpFactor = [
            SELECT Id, EIS_UOM__c, EIS_Electric_Line_Loss__c, EIS_Natural_Gas_Line_Loss__c,
            CH4__c, CO2__c, N2O__c, R_11__c, R_12__c, R_123__c, R_134a__c, R_22__c, R_27__c, R_401a__c, R_404a__c, R_407a__c, 
            R_407C__c, R_408a__c, R_409a__c, R_410a__c, R_502__c, SF6__c
            FROM Logistic__c 
            WHERE Id = :wasteDataEntry.EIS_Factor_Table__c
        ];
        
        Map<String, Logistic__c> eGridFactorsMap = new Map<String, Logistic__c>();
        if (String.isNotBlank(wasteDataEntry.EIS_eGRID_Subregion__c)) {
            populateEGridFactorsMapBySubRegion(eGridFactorsMap, wasteDataEntry);
        }
        
        Map<String, Logistic__c> emissionFactorsMap = new Map<String, Logistic__c>();
        populateEmissionFactorsMap(emissionFactorsMap, wasteDataEntry);
        
        List<Line_Item__c> lineItems = new List<Line_Item__c>();
        // Iterate through the activity type records and create line items for each condition
        for (Logistic__c activityType : ghgActivityTypes) {
            if (String.valueOf(Label.EIS_Logistic_GHG_Source_Electricity).equalsIgnoreCase(activityType.EIS_Source__c)) {
                //eGrid line items
                if (String.isNotBlank(wasteDataEntry.EIS_eGRID_Subregion__c)) {
                    poppulateElectricityLineItems(lineItems, gwpFactor, eGridFactorsMap, wasteDataEntry, activityType);
                }
            } else if (String.valueOf(Label.EIS_Logistic_GHG_Source_SF6).equalsIgnoreCase(activityType.EIS_Source__c)) {
                //Sulfur Hexafluoride
                lineItems.add(getNewLineItem(wasteDataEntry.Id, null, null, activityType, 'SF6', gwpFactor.EIS_UOM__c, null, gwpFactor.SF6__c));
            } else if (String.valueOf(Label.EIS_Logistic_GHG_Source_Refrigerants).equalsIgnoreCase(activityType.EIS_Source__c)) {
                //Refridgerants
                populateGWPLineItems(lineItems, gwpFactor, wasteDataEntry, activityType);
            } else if (String.valueOf(Label.EIS_Logistic_GHG_Activity_Electric_Line_Loss).equalsIgnoreCase(activityType.EIS_Activity__c)) {
                //Electric Line Loss
                poppulateElectricityLineItems(lineItems, gwpFactor, eGridFactorsMap, wasteDataEntry, activityType);
            } else if (String.valueOf(Label.EIS_Logistic_GHG_Activity_Gas_Line_Loss).equalsIgnoreCase(activityType.EIS_Activity__c)) {
                //Natural Gas Line Loss
                lineItems.add(getNewLineItem(wasteDataEntry.Id, null, null, activityType, null, gwpFactor.EIS_UOM__c, null, gwpFactor.EIS_Natural_Gas_Line_Loss__c));
            } else {
                //Emission line items
                populateEmissionLineItems(lineItems, gwpFactor, emissionFactorsMap, wasteDataEntry, activityType);
            }
        }
        
        try {
            insert lineItems;
        	System.debug(lineItems.size());
        } catch (Exception e) {
            System.debug(e.getMessage());
            wasteDataEntry.addError('System failed to create Line Items with the following error: ' + e.getMessage());
        }
        
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Initialize Line Item data for insertion
    *————————————————————————————————————————————————————
    * @param    ghgId				EIS_Waste_Management__c look up	
    * @param    subRegion			EIS_eGRID_Subregion__c
    * @param    activityType		EIS_GHG_Activity__c, EIS_GHG_Source__c, EIS_GHG_Scope__c, EIS_GHG_Source_Type__c
    * @param    gasType				EIS_Cal_Methodology__c
    * @param    uom					EIS_UOM__c
    * @param    factorValue			EIS_Factor_Value__c
    * @param    gwpFactorValue		EIS_GWP_Factor_Value__c
    * @return   Line_Item__c		return Line Item record to be inserted
    *————————————————————————————————————————————————————
    **/
    private Line_Item__c getNewLineItem(Id ghgId, String subRegion, String sourceType, Logistic__c activityType, String gasType, String uom, Decimal factorValue, Decimal gwpFactorValue) {
        Line_Item__c lt = new Line_Item__c();
        
        lt.RecordTypeId = EIS_StaticUtils.LINE_ITEM_GHG_RTID;
        lt.EIS_Waste_Management__c = ghgId;
        lt.EIS_GHG_Activity__c = activityType.EIS_Activity__c;
        lt.EIS_GHG_Source__c = activityType.EIS_Source__c;
        lt.EIS_GHG_Scope__c = activityType.EIS_Scope__c;
        if (String.isBlank(subRegion)) {
            lt.EIS_GHG_Source_Type__c = sourceType;
        } else {
            lt.EIS_eGRID_Subregion__c = subRegion;
        }
        lt.EIS_Chemical_Compound__c = gasType;
        lt.EIS_UOM__c = uom;
        if (factorValue != null) { lt.EIS_Factor_Value__c = factorValue; }
        if (gwpFactorValue != null) { lt.EIS_GWP_Factor_Value__c = gwpFactorValue; }
        
        return lt;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Iterate through items in emission table and initialize Line Item records
    *————————————————————————————————————————————————————
    * @param    lineItems			List of Line Items to be insert
    * @param    gwpFactor			Top level factor table (GWP)
    * @param    sourceTypes			List of unique source types
    * @param    wasteDataEntry		Waste_Emissions__c look up record
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private void populateEmissionLineItems(List<Line_Item__c> lineItems, Logistic__c gwpFactor, Map<String, Logistic__c> emissionFactorsMap, Waste_Emissions__c wasteDataEntry, Logistic__c activityType) {
        if (String.isNotBlank(activityType.EIS_Source_Type__c)) {
            Logistic__c emissionFactor;
            for (String sourceType : activityType.EIS_Source_Type__c.split(';')) {
                emissionFactor = emissionFactorsMap.get(EIS_StaticUtils.getEmissionKeyForMap(activityType, sourceType));
                if (emissionFactor != null) {
                    if (emissionFactor.CO2__c != null) {
                        lineItems.add(getNewLineItem(wasteDataEntry.Id, null, sourceType, activityType, 'CO2', emissionFactor.EIS_UOM__c, emissionFactor.CO2__c, gwpFactor.CO2__c));
                    }
                    if (emissionFactor.CH4__c != null) {
                        lineItems.add(getNewLineItem(wasteDataEntry.Id, null, sourceType, activityType, 'CH4', emissionFactor.EIS_UOM__c, emissionFactor.CH4__c, gwpFactor.CH4__c));
                    }
                    if (emissionFactor.N2O__c != null) {
                        lineItems.add(getNewLineItem(wasteDataEntry.Id, null, sourceType, activityType, 'N2O', emissionFactor.EIS_UOM__c, emissionFactor.N2O__c, gwpFactor.N2O__c));
                    }
                }
            }
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Iterate through items in eGrid table and initialize Line Item records
    *————————————————————————————————————————————————————
    * @param    lineItems			List of Line Items to be insert
    * @param    gwpFactor			Top level factor table (GWP)
    * @param    eGridFactorsMap		Map of subRegions and its corresponding Logistic record
    * @param    wasteDataEntry		Waste_Emissions__c look up record
    * @param	activityType		Activity Table record
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private void poppulateElectricityLineItems(List<Line_Item__c> lineItems, Logistic__c gwpFactor, Map<String, Logistic__c> eGridFactorsMap, Waste_Emissions__c wasteDataEntry, Logistic__c activityType) {
        if (String.isNotBlank(wasteDataEntry.EIS_eGRID_Subregion__c)) {
            Logistic__c eGridFactor;
            for (String subRegion : wasteDataEntry.EIS_eGRID_Subregion__c.split(';')) {
                eGridFactor = eGridFactorsMap.get(subRegion);
                if (eGridFactor != null) {
                    lineItems.add(getNewLineItem(wasteDataEntry.Id, subRegion, null, activityType, 'CH4', eGridFactor.EIS_UOM__c, eGridFactor.CH4__c, gwpFactor.CH4__c));
                    lineItems.add(getNewLineItem(wasteDataEntry.Id, subRegion, null, activityType, 'CO2', eGridFactor.EIS_UOM__c, eGridFactor.CO2__c, gwpFactor.CO2__c));
                    lineItems.add(getNewLineItem(wasteDataEntry.Id, subRegion, null, activityType, 'N2O', eGridFactor.EIS_UOM__c, eGridFactor.N2O__c, gwpFactor.N2O__c));
                }
            }
            eGridFactor = null;
        }
    }
	
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Iterate through items in GWP factor table and initialize Line Item records
    *————————————————————————————————————————————————————
    * @param    lineItems			List of Line Items to be insert
    * @param    gwpFactor			Top level factor table (GWP)
    * @param    wasteDataEntry			Waste_Emissions__c look up record
    * @param	activityType			Activity Table record
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private void populateGWPLineItems(List<Line_Item__c> lineItems, Logistic__c gwpFactor, Waste_Emissions__c wasteDataEntry, Logistic__c activityType) {
        if (String.isNotBlank(activityType.EIS_Source_Type__c)) {
            for (String sourceType : activityType.EIS_Source_Type__c.split(';')) {
                String fieldName = sourceType.replaceAll('-', '_') + '__c';
                try {
                    if (gwpFactor.get(fieldName) != null) {
                        lineItems.add(getNewLineItem(wasteDataEntry.Id, null, sourceType, activityType, null, gwpFactor.EIS_UOM__c, null, (Decimal)gwpFactor.get(fieldName)));
                    }
                } catch (SObjectException e) {
                    // No action needed because the String fieldName does not match a valid field, so it should be skipped and not handled.
                }
            }
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Retrieve eGrid factor records and organize them in a Map
    *————————————————————————————————————————————————————
    * @param    eGridFactorsMap		Map of subRegions and its corresponding Logistic record
    * @param    wasteDataEntry		Waste_Emissions__c look up record
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private void populateEGridFactorsMapBySubRegion(Map<String, Logistic__c> eGridFactorsMap, Waste_Emissions__c wasteDataEntry) {
        List<Logistic__c> eGridFactors = [
            SELECT Id, RecordType.DeveloperName, EIS_eGRID_Subregion__c, CO2__c, CH4__c, N2O__c, EIS_UOM__c
            FROM Logistic__c 
            WHERE EIS_Factor_Table__c = :wasteDataEntry.EIS_Factor_Table__c
            AND RecordType.DeveloperName = :Label.EIS_Logistic_GHG_eGrid_Record_Type
            AND EIS_eGRID_Subregion__c IN :wasteDataEntry.EIS_eGRID_Subregion__c.split(';')
        ];
        for (Logistic__c eGrid : eGridFactors) {
            eGridFactorsMap.put(eGrid.EIS_eGRID_Subregion__c, eGrid);
        }
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Retrieve emission factor records and organize them in a Map
    *————————————————————————————————————————————————————
    * @param    eGridFactorsMap		Map of emission description and emission factor
    * @param    wasteDataEntry		Waste_Emissions__c look up record
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private void populateEmissionFactorsMap(Map<String, Logistic__c> emissionFactorsMap, Waste_Emissions__c wasteDataEntry) {
        List<Logistic__c> emissionFactors = [
            SELECT Id, EIS_Source__c, EIS_Source_Type__c, EIS_Scope__c, EIS_UOM__c, CO2__c, CH4__c, N2O__c
            FROM Logistic__c 
            WHERE RecordType.DeveloperName = :Label.EIS_Logistic_GHG_Emission_Record_Type
            AND EIS_Factor_Table__c = :wasteDataEntry.EIS_Factor_Table__c
        ];
        for (Logistic__c emission : emissionFactors) {
            if (String.isNotBlank(emission.EIS_Source_Type__c)) {
                for (String sourceType : emission.EIS_Source_Type__c.split(';')) {
                    emissionFactorsMap.put(EIS_StaticUtils.getEmissionKeyForMap(emission, sourceType), emission);
                }
            }
        }
        emissionFactors = null;
    }
}