global class StationAuditTypePicklist extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('', 'Select a Value');
        return defaultValue;
    }
	
    global override VisualEditor.DynamicPickListRows getValues() {
        List<Station_Audit_Type__mdt> stationAuditValues = [SELECT MasterLabel, DeveloperName 
                                                            FROM Station_Audit_Type__mdt];
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
        
        for(Station_Audit_Type__mdt sav: stationAuditValues){
            VisualEditor.DataRow value = new VisualEditor.DataRow(sav.MasterLabel, sav.DeveloperName);
            myValues.addRow(value);
        }
        
        return myValues;
    }
}