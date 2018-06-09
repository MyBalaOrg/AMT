public class RevSys_1872InfoController {
	
    /*
     * @creted by: Rajat
	* To get all the pick list value of list of picklist fields
	* @param objectAPIName : api name of salesforce object
	* @param strToAPIMap : map with key = ui attribute name & value = field api name
	*
	* @return Map<String, list<String>> : map with key = ui attribute name & value = pick list values
	**/
    @AuraEnabled
    public static Map<String, list<String>> getPicklistValues(Map<String, String> strToAPIMap){
        
		System.debug('strToAPIMap :: ' + strToAPIMap);
        
		Map<String, list<String>> picklistValuesMap = new Map<String, list<String>>();
        
        if(strToAPIMap != null && strToAPIMap.size() > 0){
            
            Schema.sObjectType sobject_type = Observation__c.getSObjectType(); //grab the sobject Observation__c
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            
            for(String fieldName : strToAPIMap.keySet()){
                //get picklist entry
                List<Schema.PicklistEntry> pickListValues = field_map.get(strToAPIMap.get(fieldName)).getDescribe().getPickListValues();
                
                list<String> pickListStrlist = new list<String>();
                pickListStrlist.add('--None--');
                for (Schema.PicklistEntry picklistVal : pickListValues) {
                    pickListStrlist.add(picklistVal.getLabel());
                }
                
                picklistValuesMap.put(fieldName, pickListStrlist);
                
            }
        }
        System.debug('picklistValuesMap :: ' + picklistValuesMap);
        
        return picklistValuesMap;
    }
}