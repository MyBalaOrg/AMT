/**
*————————————————————————————————————————————————————
* @Name             EIS_GHG_DeepCloneCtrl
* @Author           Duy Tran
* @Created Date     07-25-2017
* @Used By          EIS_GHG_DeepClone.cmp
*————————————————————————————————————————————————————
* @Description
* Controller class to deep clone existing factor table
*————————————————————————————————————————————————————
* @Changes
*
**/
public class EIS_GHG_DeepCloneCtrl {
    public class LineItemGroup {
        public String identifier {get; set;}
        public Decimal consumptionValue {get; set;}
        public Decimal conversionFactor {get; set;}
        public String calculatedUMO {get; set;}
        public Boolean disableConsumptionValue {get; set;}
        public Set<String> idSet {get; set;}
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Deep clone the factor table given its record Id. Also clone its children and assign new Look Up Id 
    *————————————————————————————————————————————————————
    * @param    recordId	Id of the Logistic record to be cloned
    * @param	startDate	Start Date value for the new cloned record
    * @param	endDate		End Date value for the new cloned record
    * @return   String		Id of the newly cloned record
    *————————————————————————————————————————————————————
    **/
	@AuraEnabled
    public static Map<String, String> deepCloneLogisticRecord(String recordId, String startDate, String endDate) {
        Map<String, String> response = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        try {
            Logistic__c factorTable = [
                SELECT Id, RecordTypeId, EIS_Activity__c, EIS_Source__c, EIS_Source_Type__c, EIS_Scope__c, EIS_UOM__c, EIS_Electric_Line_Loss__c, EIS_Natural_Gas_Line_Loss__c,
                CH4__c, CO2__c, N2O__c, R_11__c, R_12__c, R_123__c, R_134a__c, R_22__c, R_27__c, R_401a__c, R_404a__c, R_407a__c, 
                R_407C__c, R_408a__c, R_409a__c, R_410a__c, R_502__c, SF6__c
                FROM Logistic__c 
                WHERE Id =: recordId
            ];
            List<Logistic__c> childrenFactors = [
                SELECT Id, RecordTypeId, EIS_Source__c, EIS_Source_Type__c, EIS_Scope__c, EIS_eGRID_Subregion__c, 
                CO2__c, CH4__c, N2O__c, EIS_UOM__c, EIS_Emission_Gas__c, EIS_Emission_Factor__c
                FROM Logistic__c 
                WHERE EIS_Factor_Table__c =: recordId
            ];
            
            Logistic__c newFactorTable = factorTable.clone(false, true, false, false);
            newFactorTable.EIS_Start_Date__c = Date.valueOf(startDate);
            newFactorTable.EIS_End_Date__c = Date.valueOf(endDate);
            insert newFactorTable;
            List<Logistic__c> newChildrenFactors = new List<Logistic__c>();
            for (Logistic__c child : childrenFactors) {
                Logistic__c newChild = child.clone(false, true, false, false);
                newChild.EIS_Factor_Table__c = newFactorTable.Id;
                newChildrenFactors.add(newChild);
            }
            
            if (!newChildrenFactors.isEmpty()) {
                insert newChildrenFactors;
            }
            response.put('factorId', String.valueOf(newFactorTable.Id));
        } catch (Exception e) {
            response.put('errorMsg', e.getMessage());
            System.debug(e.getMessage());
            Database.rollback(sp);
        }
        
        return response;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Check all factor tables and update old Line Item values
    *————————————————————————————————————————————————————
    * @param    recordId	Id of the Waste & Emission record
    * @return   String		return error message
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static String syncLineItemsFactorValue(String wasteId) {
        Waste_Emissions__c waste = [SELECT Id, RecordTypeId, EIS_Factor_Table__c FROM Waste_Emissions__c WHERE Id = :wasteId];
        if (waste.RecordTypeId != EIS_StaticUtils.WASTE_EMISSIONS_GHG_RTID) { 
            return 'This functionality may only be used for ' + Label.EIS_Waste_Emission_GHG_Record_Type_Label + ' record type.'; 
        }
        
        Logistic__c gwpFactor = [
            SELECT Id, EIS_Activity__c, EIS_Source__c, EIS_Source_Type__c, EIS_Scope__c, EIS_UOM__c, EIS_Electric_Line_Loss__c, EIS_Natural_Gas_Line_Loss__c,
            CH4__c, CO2__c, N2O__c, R_11__c, R_12__c, R_123__c, R_134a__c, R_22__c, R_27__c, R_401a__c, R_404a__c, R_407a__c, 
            R_407C__c, R_408a__c, R_409a__c, R_410a__c, R_502__c, SF6__c
            FROM Logistic__c 
            WHERE Id = :waste.EIS_Factor_Table__c
        ];
        
        Map<String, Logistic__c> emissionMap = getEmissionFactorMap(waste.EIS_Factor_Table__c);
        Map<String, Logistic__c> eGridMap = getEGridFactorMap(waste.EIS_Factor_Table__c);
        
        List<Line_Item__c> lineItems = [
            SELECT Id, EIS_UOM__c, EIS_GWP_Factor_Value__c, EIS_Factor_Value__c, EIS_Chemical_Compound__c, EIS_eGRID_Subregion__c, 
            	EIS_GHG_Activity__c, EIS_GHG_Source__c, EIS_GHG_Source_Type__c, EIS_GHG_Scope__c
            FROM Line_Item__c WHERE EIS_Waste_Management__c = :wasteId
        ];
        for (Integer i = 0; i < lineItems.size(); i ++) {
            String fieldName = '';
            if (String.isNotBlank(lineItems[i].EIS_Chemical_Compound__c)) {
                fieldName = String.valueOf(lineItems[i].EIS_Chemical_Compound__c).replaceAll('-', '_') + '__c';
            } else if (String.isNotBlank(lineItems[i].EIS_GHG_Source_Type__c)) {
                fieldName = String.valueOf(lineItems[i].EIS_GHG_Source_Type__c).replaceAll('-', '_') + '__c';
            }
            try {
                /** POPULATE FACTOR VALUE **/
                if (eGridMap.get(lineItems[i].EIS_eGRID_Subregion__c) != null) {
                    //populate eGrid factor values if found
                    if (eGridMap.get(lineItems[i].EIS_eGRID_Subregion__c).get(fieldName) != null) {
                        lineItems[i].EIS_Factor_Value__c = (Decimal)eGridMap.get(lineItems[i].EIS_eGRID_Subregion__c).get(fieldName);
                        lineItems[i].EIS_UOM__c = eGridMap.get(lineItems[i].EIS_eGRID_Subregion__c).EIS_UOM__c;
                    }
                } else {
                    //populate emission factor value if found
                    String emissionKey = lineItems[i].EIS_GHG_Source__c + ' ' + lineItems[i].EIS_GHG_Scope__c + ' ' + lineItems[i].EIS_GHG_Source_Type__c;
                    if (emissionMap.get(emissionKey) != null) {
                        if (emissionMap.get(emissionKey).get(fieldName) != null) {
                            lineItems[i].EIS_Factor_Value__c = (Decimal)emissionMap.get(emissionKey).get(fieldName);
                            lineItems[i].EIS_UOM__c = emissionMap.get(emissionKey).EIS_UOM__c;
                        }
                    }
                }
                
                /** POPULATE GWP FACTOR VALUE **/
                if (String.valueOf(Label.EIS_Logistic_GHG_Activity_Gas_Line_Loss).equalsIgnoreCase(lineItems[i].EIS_GHG_Activity__c)) {
                    //Natural Gas Line Loss
                    lineItems[i].EIS_GWP_Factor_Value__c = gwpFactor.EIS_Natural_Gas_Line_Loss__c;
                } else if (String.valueOf(Label.EIS_Logistic_GHG_Activity_Electric_Line_Loss).equalsIgnoreCase(lineItems[i].EIS_GHG_Activity__c)) {
                    //Electric Line Loss
                    lineItems[i].EIS_GWP_Factor_Value__c = gwpFactor.EIS_Electric_Line_Loss__c;
                } else if (String.valueOf(Label.EIS_Logistic_GHG_Source_SF6).equalsIgnoreCase(lineItems[i].EIS_GHG_Source__c)) {
                    //Sulfur Hexafluoride
                    lineItems[i].EIS_GWP_Factor_Value__c = gwpFactor.SF6__c;
                } else {
                    //All other field values
                    if (gwpFactor.get(fieldName) != null) {
                        lineItems[i].EIS_GWP_Factor_Value__c = (Decimal)gwpFactor.get(fieldName);
                    }
                }
            } catch (SObjectException e) {
                // No action needed because the String fieldName does not match a valid field, so it should be skipped and not handled.
            }
        }
        
        String errorMsg = null;
        try {
            update lineItems;
        } catch (Exception e) {
            errorMsg = e.getMessage();
            System.debug(errorMsg);
        }
        return errorMsg;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Organize logistic records into a map with key value equals to EIS_Fuel_Type_CPD_Fuel_Type__c
    *————————————————————————————————————————————————————
    * @param    parentId	Id of the GWP Factor Table
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private static Map<String, Logistic__c> getEmissionFactorMap(String parentId) {
        List<Logistic__c> emissionFactors = [
            SELECT Id, EIS_Activity__c, EIS_Source__c, EIS_Source_Type__c, EIS_Scope__c, EIS_UOM__c, CO2__c, CH4__c, N2O__c
            FROM Logistic__c 
            WHERE RecordType.DeveloperName = :Label.EIS_Logistic_GHG_Emission_Record_Type
            AND EIS_Factor_Table__c = :parentId
        ];
        Map<String, Logistic__c> factorMap = new Map<String, Logistic__c>();
        for (Logistic__c emission : emissionFactors) {
            factorMap.put(EIS_StaticUtils.getEmissionKeyForMap(emission, null), emission);
        }
        return factorMap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Organize logistic records into a map with key value equals to EIS_eGRID_Subregion__c
    *————————————————————————————————————————————————————
    * @param    parentId	Id of the GWP Factor Table
    * @return   void
    *————————————————————————————————————————————————————
    **/
    private static Map<String, Logistic__c> getEGridFactorMap(String parentId) {
        List<Logistic__c> eGridFactors = [
            SELECT Id, EIS_eGRID_Subregion__c, CO2__c, CH4__c, N2O__c, EIS_UOM__c
            FROM Logistic__c 
            WHERE RecordType.DeveloperName = :Label.EIS_Logistic_GHG_eGrid_Record_Type
            AND EIS_Factor_Table__c = :parentId
        ];
        Map<String, Logistic__c> factorMap = new Map<String, Logistic__c>();
        for (Logistic__c eGrid : eGridFactors) {
            factorMap.put(eGrid.EIS_eGRID_Subregion__c, eGrid);
        }
        return factorMap;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Retrieve all line items for this record and generate a list of LineItemGroup
    *————————————————————————————————————————————————————
    * @param    recordId	Id of the Waste & Emission record
    * @return   String		JSON representation of the LineItemGroup list
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static String getLineItemGroupList(String wasteId) {
        List<Line_Item__c> lineItems = [
            SELECT Id, EIS_eGRID_Subregion__c, EIS_GHG_Activity__c, EIS_GHG_Source__c, EIS_GHG_Source_Type__c, EIS_GHG_Scope__c 
            FROM Line_Item__c WHERE EIS_Waste_Management__c = :wasteId
        ];
        Map<String, LineItemGroup> ligMap = new Map<String, LineItemGroup>();
        String liKey;
        for (Line_Item__c li : lineItems) {
            liKey = li.EIS_GHG_Activity__c 
                + (String.isBlank(li.EIS_GHG_Source__c) ? '' : ' - ' + li.EIS_GHG_Source__c)
                + (String.isBlank(li.EIS_GHG_Scope__c) ? '' : ' - ' + li.EIS_GHG_Scope__c)
                + ((String.isBlank(li.EIS_GHG_Source_Type__c) || li.EIS_GHG_Source__c == Label.EIS_Logistic_GHG_Source_Refrigerants) ? '' : ' - ' + li.EIS_GHG_Source_Type__c)
                + (String.isBlank(li.EIS_eGRID_Subregion__c) ? '' : ' - ' + li.EIS_eGRID_Subregion__c);
            if (ligMap.get(liKey) == null) {
                LineItemGroup lig = new LineItemGroup();
                lig.disableConsumptionValue = li.EIS_GHG_Activity__c.equalsIgnoreCase(Label.EIS_Logistic_GHG_Activity_Electric_Line_Loss);
                lig.identifier = liKey;
                lig.idSet = new Set<String>();
                lig.idSet.add(li.Id);
                ligMap.put(liKey, lig);
            } else {
                ligMap.get(liKey).idSet.add(li.Id);
            }
        }
        
        List<LineItemGroup> ligList = new List<LineItemGroup>();
        List<String> identifierList = new List<String>();
        identifierList.addAll(ligMap.keySet());
        identifierList.sort();
        for (String identifier : identifierList) {
            ligList.add(ligMap.get(identifier));
        }
        
        return JSON.serialize(ligList);
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Update all line items in lineItemIds with the annual consumption value and other related fields\
    * Electric Line Loss annual consumption value is auto calculated from other electric items
    *————————————————————————————————————————————————————
    * @param    recordId	Id of the Waste & Emission record
    * @return   String		JSON representation of the LineItemGroup list
    *————————————————————————————————————————————————————
    **/
    @AuraEnabled
    public static String updateLineItemAnnualConsumption(String selectedLigJSON) {
        // Front End validation will prevent user from updating records with empty data
        String errorMsg = '';
        try {
            LineItemGroup selectedLig = (LineItemGroup)JSON.deserialize(selectedLigJSON, LineItemGroup.class);
            List<Line_Item__c> lineItems = [
                SELECT Id, EIS_Consumption_Value__c, EIS_Chemical_Compound__c, EIS_Waste_Management__c, EIS_GWP_Factor_Value__c, EIS_eGRID_Subregion__c 
                FROM Line_Item__c WHERE Id IN :selectedLig.idSet
            ];
            if (selectedLig.identifier.containsIgnoreCase(Label.EIS_Logistic_GHG_Activity_Electric_Line_Loss)) {
                Map<String, Decimal> consumptionMap = getConsumptionMap(lineItems[0]);
                for (Integer i = 0; i < lineItems.size(); i++) {
                    lineItems[i].EIS_Consumption_Value__c = consumptionMap.get(lineItems[i].EIS_Chemical_Compound__c);
                    if (selectedLig.conversionFactor != null) {
                        lineItems[i].EIS_Conversion_Factor__c = selectedLig.conversionFactor;
                    }
                    if (String.isNotBlank(selectedLig.calculatedUMO)) {
                        lineItems[i].EIS_Calculated_UOM__c = selectedLig.calculatedUMO;
                    }
                }
            } else {
                for (Integer i = 0; i < lineItems.size(); i++) {
                    if (selectedLig.consumptionValue != null) {
                        lineItems[i].EIS_Consumption_Value__c = selectedLig.consumptionValue;
                    }
                    if (selectedLig.conversionFactor != null) {
                        lineItems[i].EIS_Conversion_Factor__c = selectedLig.conversionFactor;
                    }
                    if (String.isNotBlank(selectedLig.calculatedUMO)) {
                        lineItems[i].EIS_Calculated_UOM__c = selectedLig.calculatedUMO;
                    }
                }
            }
            
            update lineItems;
        } catch (Exception e) {
            errorMsg = e.getMessage();
            System.debug(errorMsg);
        }
        
        return errorMsg;
    }
    
    /**
    *————————————————————————————————————————————————————
    * @Description
    * Generate a Map of consumption values group by Chemical Compound (EIS_Chemical_Compound__c)
    *————————————————————————————————————————————————————
    * @param    electricLineLoss		Line_Item__c record for the selected Electric Line Loss
    * @return   Map<String, Decimal>	Map of chemical compound and total consumption values by subregion
    *————————————————————————————————————————————————————
    **/
    private static Map<String, Decimal> getConsumptionMap(Line_Item__c electricLineLoss) {
        Decimal lineLossCoefficient = electricLineLoss.EIS_GWP_Factor_Value__c / (1.0 - electricLineLoss.EIS_GWP_Factor_Value__c);
        List<Line_Item__c> eGridItems = [
            SELECT Id, EIS_Consumption_Value__c, EIS_Chemical_Compound__c FROM Line_Item__c
            WHERE EIS_eGRID_Subregion__c = :electricLineLoss.EIS_eGRID_Subregion__c 
            AND EIS_Waste_Management__c = :electricLineLoss.EIS_Waste_Management__c
            AND EIS_GHG_Activity__c != :Label.EIS_Logistic_GHG_Activity_Electric_Line_Loss
            ORDER BY EIS_Chemical_Compound__c 
        ];
        Map<String, Decimal> consumptionMap = new Map<String, Decimal>();
        Decimal tempConsumption = null;
        for (Line_Item__c item : eGridItems) {
            tempConsumption = consumptionMap.get(item.EIS_Chemical_Compound__c);
            if (tempConsumption == null) {
                consumptionMap.put(item.EIS_Chemical_Compound__c, item.EIS_Consumption_Value__c * lineLossCoefficient);
            } else {
                consumptionMap.put(item.EIS_Chemical_Compound__c, tempConsumption + (item.EIS_Consumption_Value__c * lineLossCoefficient));
            }
        }
        
        return consumptionMap;
    }
}